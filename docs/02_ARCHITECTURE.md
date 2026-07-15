# 02 · Architecture

## Data flow

```
input stream / blank stage
        │
        ▼
   observed frame            (video/inputModes.ts — blank or mock in MVP-0)
        │
        ▼
    layer stack              (core/layer.ts, held by core/stage.ts)
        │
        ▼
  agent proposals            (agents/agentProtocol.ts, agents/mockAgent.ts)
        │
        ▼
    gatekeeper               (agents/gatekeeper.ts)
        │  observe → translate → gate → consent → act → audit
        ▼
  consent policy             (core/consent.ts)
        │
        ▼
  timeline mutation          (core/timeline.ts, applied via core/stage.ts)
        │
        ▼
     render                  (components/StageView.tsx)
        │
        ▼
    audit log                (core/provenance.ts — every step recorded)
```

## Modules

| Module | Responsibility |
| --- | --- |
| `core/stage.ts` | The single authority over state. Holds layers, timeline, audit. Enforces the human-layer invariant centrally. Every mutation is audited. |
| `core/layer.ts` | Layer kinds, ownership, mutability, shakeability, provenance shape. |
| `core/timeline.ts` | Keyframes: `(layer, param) → value @ t`. Step sampling. Scoped clearing for shake. |
| `core/provenance.ts` | Actors, provenance records, audit events, the append-only `AuditLog`. |
| `core/consent.ts` | Consent policies (`Auto`, `Manual`). Answers "required?" and "granted?". Never mutates. |
| `core/shake.ts` | Scoped revocation. Always preserves human presence and non-shakeable layers. |
| `agents/agentProtocol.ts` | The `Proposal` format and `Agent` interface — the only doorway in. |
| `agents/gatekeeper.ts` | Runs the loop: receive → consent → act (or reject) → audit. |
| `agents/mockAgent.ts` | Deterministic stand-in proposers (`MockAgent`, `OverreachingAgent`). |
| `video/inputModes.ts` | Input mode registry + synthetic mock frames. No capture in MVP-0. |
| `video/chromaPlaceholder.ts` | Documented, no-op chroma/bluescreen pipeline. |
| `components/*` | React views: stage, layer panel, knobs, audit log. |

## Key design choices

- **The Stage is the only mutator.** Nothing writes layer state except through
  `Stage` methods, and each one records an audit event. This is why the audit log
  is complete rather than best-effort.
- **The invariant lives in one place.** `actorMayMutate` (in `core/stage.ts`) is
  the single guard. Human presence is unmutable by agents no matter the call path.
- **Consent is advisory data, the gatekeeper is the actor.** The policy computes a
  decision; the gatekeeper enforces it. Swapping policies never risks the invariant.
- **The React layer is a thin view.** The `Stage` is a plain mutable object held in
  a ref; the UI bumps a version counter to re-render. No state framework needed for
  MVP-0.

## Threading time

MVP-0 uses **logical ticks**, not wall-clock frames. `Stage.sampleAt(t)` folds the
timeline's keyframes into each layer's live params. "Advance tick" in the UI drives
this. Real frame timing is a later direction (see [`10_ROADMAP.md`](10_ROADMAP.md)).
