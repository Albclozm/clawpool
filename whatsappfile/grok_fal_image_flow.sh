#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   grok_fal_image_flow.sh "your prompt" [target_chat]
#
# Env required:
#   SHUBIAO_API_KEY   # for grok text step (api.shubiaobiao.com)
#   FAL_KEY           # for fal image generation
#
# Optional env:
#   GROK_MODEL        # default: grok-4
#   OPENCLAW_CHANNEL  # default: whatsapp

PROMPT_RAW="${1:-}"
TARGET_CHAT="${2:-+61452044218}"

if [[ -z "$PROMPT_RAW" ]]; then
  echo "Usage: $0 \"prompt\" [target_chat]" >&2
  exit 1
fi

: "${SHUBIAO_API_KEY:?SHUBIAO_API_KEY is required}"
: "${FAL_KEY:?FAL_KEY is required}"

GROK_MODEL="${GROK_MODEL:-grok-4}"
CHANNEL="${OPENCLAW_CHANNEL:-whatsapp}"

# 1) Send user prompt to Grok (as requested), ask it to return final image prompt text only.
GROK_RESP="$(curl -sS https://api.shubiaobiao.com/v1/chat/completions \
  -H "Authorization: Bearer ${SHUBIAO_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  \"model\": \"${GROK_MODEL}\",
  \"messages\": [
    {\"role\":\"system\",\"content\":\"Return only the final image prompt text. Do not add markdown or explanation.\"},
    {\"role\":\"user\",\"content\":${PROMPT_RAW@Q}}
  ]
}
JSON
)" )"

FINAL_PROMPT="$(node -e '
const fs = require("fs");
const t = fs.readFileSync(0, "utf8");
let j; try { j = JSON.parse(t); } catch { process.exit(2); }
const c = j?.choices?.[0]?.message?.content || "";
if (!c) process.exit(3);
process.stdout.write(String(c).trim());
' <<<"$GROK_RESP")"

# 2) Call fal image API with that prompt
FAL_RESP="$(curl -sS https://fal.run/fal-ai/z-image/turbo \
  -H "Authorization: Key ${FAL_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(cat <<JSON
{
  \"prompt\": ${FINAL_PROMPT@Q}
}
JSON
)")"

IMAGE_URL="$(node -e '
const fs=require("fs");
const t=fs.readFileSync(0,"utf8");
let j; try{j=JSON.parse(t)}catch{process.exit(2)}
const u=j?.images?.[0]?.url || "";
if(!u) process.exit(3);
process.stdout.write(u);
' <<<"$FAL_RESP")"

# 3) Send image URL back to chat
openclaw message send \
  --channel "$CHANNEL" \
  --target "$TARGET_CHAT" \
  --media "$IMAGE_URL" \
  -m "已按你的提示词生成（Grok→FAL）：${FINAL_PROMPT}"

echo "OK: $IMAGE_URL"
