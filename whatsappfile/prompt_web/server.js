#!/usr/bin/env node
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.env.PORT || process.argv[2] || 8788);
const HOST = process.env.HOST || '0.0.0.0';
const ROOT = path.resolve(__dirname, '..');
const PROMPT_FILE = path.join('/home/node/.openclaw/workspace', 'prompt.txt');
const INDEX_FILE = path.join(__dirname, 'index.html');

function readPrompt() {
  try { return fs.readFileSync(PROMPT_FILE, 'utf8'); } catch { return ''; }
}
function writePrompt(text) {
  fs.writeFileSync(PROMPT_FILE, text, 'utf8');
}
function send(res, code, body, type = 'text/plain; charset=utf-8') {
  res.writeHead(code, {
    'Content-Type': type,
    'Cache-Control': 'no-store',
  });
  res.end(body);
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);

  if (req.method === 'GET' && url.pathname === '/') {
    const html = fs.readFileSync(INDEX_FILE, 'utf8');
    return send(res, 200, html, 'text/html; charset=utf-8');
  }

  if (req.method === 'GET' && url.pathname === '/api/prompt') {
    return send(res, 200, JSON.stringify({ prompt: readPrompt() }), 'application/json; charset=utf-8');
  }

  if (req.method === 'POST' && url.pathname === '/api/prompt') {
    let raw = '';
    req.on('data', c => {
      raw += c;
      if (raw.length > 2_000_000) req.destroy();
    });
    req.on('end', () => {
      try {
        const data = JSON.parse(raw || '{}');
        const prompt = String(data.prompt || '');
        writePrompt(prompt);
        return send(res, 200, JSON.stringify({ ok: true }), 'application/json; charset=utf-8');
      } catch (e) {
        return send(res, 400, JSON.stringify({ ok: false, error: e.message }), 'application/json; charset=utf-8');
      }
    });
    return;
  }

  return send(res, 404, 'Not Found');
});

server.listen(PORT, HOST, () => {
  console.log(`Prompt web is running at http://${HOST}:${PORT}`);
  console.log(`Prompt file: ${PROMPT_FILE}`);
});
