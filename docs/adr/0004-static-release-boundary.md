# ADR-0004 · Static release boundary (MVP-1)

**Status:** accepted, 2026-07-10
**Context:** ADR-0001 made localhost the shared center; MVP-0
(`docs/01_MVP0_CONTRACT.md`) declared the app dark-local — no deploy, no
`getUserMedia`, no network. The AGI-26 poster (27 July 2026) needs a
scannable public artifact people can use on their own phones. This ADR
opens exactly enough of the MVP-0 boundary to ship, and no more.

## Decision

Sketched ships as a **static site** (Vite build, GitHub Pages) with
**draw mode as the presented interface at `/`**. No server is introduced.
The zero-order properties MVP-0 protected are kept, on disk and in code:

- **No server, ever.** The build is static files. There is no Sketched
  backend, no proxy, no analytics, no telemetry. View-source is a
  complete audit.
- **All state stays on device.** Human ink and session state live in
  `localStorage`. Nothing is uploaded.
- **Camera is on-device only.** `getUserMedia` (opened only by the human,
  never an agent) renders into the human-video ground layer for local
  compositing and snapshotting. Frames are never recorded, never sent —
  except the single still snapshot the human explicitly sends to a seated
  agent (below), and only then.
- **The only outbound call is one the human unlocks.** A seated agent
  calls its provider (Anthropic or OpenRouter) **directly from the
  browser with the user's own key**, one request per "ask" tap. No key
  is written to storage; it lives in memory for the session.

## What did NOT change (the invariants MVP-0 exists for)

- Every stroke is a real Stage mutation on a **human-owned, human-mutable**
  ink layer. Agents have no path to it (`mutableBy: "human"`), and shake
  preserves it (`shakeable: false`).
- The agent seat is a real `Agent` behind the **Gatekeeper**: it emits
  only `annotate` proposals, which are consent-checked and audited. There
  is no code path from the seat to the canvas or to a human layer. The
  `stage.test.ts` / `gatekeeper.test.ts` invariants are unchanged and
  still pass (48/48).
- Shake is scoped revocation; "clear notes" shakes the agent's layer only.
- The audit log is the real one, surfaced under "under the hood."

## Consequences

- Draw mode (`src/draw/`) is the face; the panel workbench moves to
  `/stage`; `/book` and `/flow` are unchanged. Same Stage underneath all.
- Releasing the site also publishes `public/book` (the textbook) and
  `public/media` (certified explainers). Intended: one release = the toy,
  the book, and the receipts, one discipline.
- The BYOK agent path is genuinely optional. With no key seated, Sketched
  is a fully working governed draw-toy with an empty, reserved seat —
  the Content B pattern, at the interaction layer.

## Non-goals (still deferred)

Multi-user boards, any hosted/relayed agent, persistent cloud storage,
recording. If a hosted "house seat" is ever added for a demo, it is a
new ADR with its own honest boundary note — not a silent change here.
