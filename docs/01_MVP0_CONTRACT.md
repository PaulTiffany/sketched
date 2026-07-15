# 01 · MVP-0 Contract

This document is the honest boundary of what exists today. No fake AI claims. No
fake realtime guarantees. No "we already built the metaverse" energy.

## MVP-0 IS

- A **local-first** TypeScript/React/Vite app that runs on `localhost`.
- A **stage** that owns all state and audits every change (`core/stage.ts`).
- A **layer model** with ownership, mutability, provenance, and shakeability.
- A **timeline** of keyframed parameters with step sampling.
- A **shake** operation that is scoped and preserves human presence.
- A **consent policy** seam (auto / manual) that gates mutations.
- An **agent proposal protocol** and a **gatekeeper** — the only doorway agents
  have into the stage.
- A **provenance / audit log** that makes a run legible afterward.
- Input modes **blank** and **mock** (a synthetic pattern; no camera).
- A **chroma/bluescreen placeholder** that documents the pipeline and is a no-op.
- A minimal UI: stage view, layer list, knobs, audit log, and demo buttons.
- Tests for the core invariants.

## MVP-0 IS NOT

- ❌ Real AI or generative models. `MockAgent` is a deterministic stand-in.
- ❌ Real camera, microphone, or screen capture. Those modes are declared but
  never initiated. Nothing calls `getUserMedia` in MVP-0.
- ❌ Realtime / low-latency guarantees. The timeline is logical ticks, not frames.
- ❌ Networked, deployed, or multi-user. It is dark-local. No push, no publish.
- ❌ Persistent storage of any personal media. Nothing is recorded or uploaded.
- ❌ A finished chroma pipeline. `applyChroma` returns the frame unchanged.
- ❌ Deepfake / person-substitution. There is no such path, by design.

## Invariants MVP-0 already enforces (with tests)

- An agent cannot mutate or create the human/video layer. (`stage.test.ts`)
- Shake clears generated layers and preserves human presence. (`stage.test.ts`)
- A proposal becomes a mutation only through the gatekeeper. (`gatekeeper.test.ts`)
- Every accepted mutation produces an audit event. (`stage.test.ts`)
- Generated layers carry ownership and provenance. (`stage.test.ts`)

## MVP-1 delta (2026-07-10, static release)

Shipped as a static site with **draw mode as the presented interface at
`/`** for the AGI-26 poster. The MVP-0 "IS NOT" list is amended in exactly
three places, each documented in [`adr/0004`](adr/0004-static-release-boundary.md):

- **Now deployed** (static files, GitHub Pages) — but still **no server**:
  no backend, proxy, analytics, or telemetry. View-source remains a
  complete audit.
- **Camera now allowed, on-device only** — `getUserMedia` opened by the
  human (never an agent), composited and snapshotted locally. Never
  recorded, never uploaded.
- **One human-unlocked outbound call** — a seated agent calls its provider
  directly from the browser with the user's own key, one request per
  "ask". Key held in memory only.

Everything else in "IS NOT" still holds: no multi-user, no hosted agent,
no persistent cloud storage, no recording, no deepfake path. Every stroke
is still a human-owned Stage mutation; the agent seat is still Gatekeeper-
gated and audited; the invariant tests (48/48) are unchanged.

## Decisions (recorded as ADRs)

- Localhost is the shared center — [`adr/0001`](adr/0001-localhost-shared-center.md)
- Agents request, they do not control — [`adr/0002`](adr/0002-agents-request-not-control.md)
- Shake is scoped revocation, not deletion — [`adr/0003`](adr/0003-shake-is-scoped-revocation.md)
- Static release boundary (draw mode, camera, BYOK agent) — [`adr/0004`](adr/0004-static-release-boundary.md)

## If you can't install dependencies

The intended commands are `npm install`, `npm run dev`, `npm test`, `npm run build`.
Even without installs, the source and docs stand on their own and describe the
full intended behavior.
