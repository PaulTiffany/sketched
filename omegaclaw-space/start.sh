#!/usr/bin/env bash
set -euo pipefail

: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY Space secret is required}"

PORT="${PORT:-7860}"
MAX_LOOPS="${OMEGACLAW_MAX_LOOPS:-1}"

if [[ ! "${MAX_LOOPS}" =~ ^[0-9]+$ ]] || (( MAX_LOOPS < 1 || MAX_LOOPS > 12 )); then
  echo "OMEGACLAW_MAX_LOOPS must be an integer from 1 through 12" >&2
  exit 64
fi

MODEL_ARGS=()
if [[ -n "${OMEGACLAW_MODEL:-}" ]]; then
  MODEL_ARGS+=("model=${OMEGACLAW_MODEL}")
fi

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
  "WS_TOKEN=${OMEGACLAW_WS_TOKEN:-}" \
  "provider=OpenRouter" \
  "embeddingprovider=Local" \
  "securityPolicyPath=/PeTTa/repos/OmegaClaw-Core/profile/policy.yaml" \
  "memoryDirectory=\$MEMORY_DIR" \
  "maxNewInputLoops=${MAX_LOOPS}" \
  "maxWakeLoops=0" \
  "${MODEL_ARGS[@]}"
