#!/usr/bin/env bash
set -euo pipefail

# Generate image from prompt file and send to chat.
# Usage: zturbo_from_prompt_file.sh [target_chat]

TARGET_CHAT="${1:-+61452044218}"
PROMPT_FILE="/home/node/.openclaw/workspace/prompt.txt"
CHANNEL="${OPENCLAW_CHANNEL:-whatsapp}"

: "${FAL_KEY:?FAL_KEY is required}"

if [[ ! -s "$PROMPT_FILE" ]]; then
  echo "Prompt file is empty: $PROMPT_FILE" >&2
  exit 1
fi

PROMPT="$(cat "$PROMPT_FILE")"

PAYLOAD="$(node -e 'const p=process.argv[1]||""; process.stdout.write(JSON.stringify({prompt:p}));' "$PROMPT")"

RESP="$(curl -sS https://fal.run/fal-ai/z-image/turbo \
  -H "Authorization: Key ${FAL_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")"

IMAGE_URL="$(node -e '
const fs=require("fs");
const t=fs.readFileSync(0,"utf8");
let j; try{j=JSON.parse(t)}catch{process.exit(2)}
const u=j?.images?.[0]?.url||"";
if(!u){console.error(t);process.exit(3)}
process.stdout.write(u);
' <<<"$RESP")"

openclaw message send \
  --channel "$CHANNEL" \
  --target "$TARGET_CHAT" \
  --media "$IMAGE_URL" \
  -m "已按提示词文档生成（Z-Image Turbo）。"

echo "$IMAGE_URL"
