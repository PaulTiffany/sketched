---
title: Z0 Real OmegaClaw
emoji: 🧠
colorFrom: gray
colorTo: yellow
sdk: docker
app_port: 7860
suggested_hardware: cpu-basic
---

# Z0 Real OmegaClaw

A minimal public-reader deployment of the official `asi-alliance/OmegaClaw-Core` runtime for the single-file Z0 surface at `https://paultiffany.github.io/sketched/`.

The Space exposes:

- `GET /health` — verified runtime/relay state
- `POST /api/turn` — submit one governed reader turn
- `GET /api/turn/{request_id}` — poll the result
- `WS /agent` — internal official OmegaClaw WebSocket channel

Required Space secret:

- `OPENROUTER_API_KEY`

Optional secrets/variables:

- `Z0_ACCESS_TOKEN` — require a shared demo token from the browser
- `OMEGACLAW_MODEL` — provider-specific model override
- `Z0_RATE_LIMIT_PER_HOUR` — default `12`
- `OMEGACLAW_MAX_LOOPS` — default `4`

This profile keeps the official filesystem policy enabled, disables scheduled autonomous wake loops, disables knowledge import at startup, allows only one public turn at a time, and returns the first OmegaClaw channel response to Z0.
