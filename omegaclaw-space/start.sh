#!/usr/bin/env bash
set -euo pipefail

: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY Space secret is required}"

PORT="${PORT:-7860}"
MAX_LOOPS="${OMEGACLAW_MAX_LOOPS:-1}"
# OmegaClaw needs an agent-capable model, not merely a cheap chat model.
# gpt-oss-20b supports native tool/function calling and structured outputs
# while remaining extremely inexpensive on OpenRouter.
MODEL="${OMEGACLAW_MODEL:-openai/gpt-oss-20b}"

if [[ ! "${MAX_LOOPS}" =~ ^[0-9]+$ ]] || (( MAX_LOOPS < 1 || MAX_LOOPS > 12 )); then
  echo "OMEGACLAW_MAX_LOOPS must be an integer from 1 through 12" >&2
  exit 64
fi

if [[ -z "${MODEL}" ]]; then
  echo "OMEGACLAW_MODEL must not be empty" >&2
  exit 64
fi

# The agent channel is loopback-only in gateway.py. Do not pass a shared
# secret through OmegaClaw configuration because upstream logs config values.
unset OMEGACLAW_WS_TOKEN || true

python3 -m uvicorn gateway:app --host 0.0.0.0 --port "${PORT}" &
GATEWAY_PID=$!

cleanup() {
  kill "${GATEWAY_PID}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

exec /PeTTa/repos/OmegaClaw-Core/entrypoint.sh \
  "commchannel=websocket" \
  "WS_URL=ws://127.0.0.1:${PORT}/agent" \
  "WS_TOKEN=" \
  "provider=OpenRouter" \
  "model=${MODEL}" \
  "embeddingprovider=Local" \
  "securityPolicyPath=/PeTTa/repos/OmegaClaw-Core/profile/policy.yaml" \
  "memoryDirectory=\$MEMORY_DIR" \
  "maxNewInputLoops=${MAX_LOOPS}" \
  "maxWakeLoops=0"
