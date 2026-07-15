# ADR 0003 · Shake is scoped revocation, not deletion

- Status: Accepted
- Date: 2026-07-01

## Context

In Chalked, erasure was authority — a deliberate, accountable act, not a blunt
"clear everything." Sketched needs the same: a way to revoke provisional state
that is scoped, auditable, and safe for human presence.

## Decision

`shake(stage, scope, actor)` is **scoped revocation**. It supports scopes for all
generated layers, a single agent, a single layer, a timestamp-onward keyframe
revocation, and an unsafe-flag sweep
([`../05_SHAKE_AND_REVOCATION.md`](../05_SHAKE_AND_REVOCATION.md)). Before any
clearing, shake filters out **preserved** layers — the human/video layer and any
layer marked non-shakeable — regardless of scope or caller. Removals go through
`Stage.removeLayer` so each is independently audited, plus one summary `shake`
event.

## Consequences

- "Shake clears generated residue, not human presence" is enforced in one place
  (`isPreserved`) and covered by tests.
- `from-timestamp` revokes only later keyframes, keeping the layer — enabling
  time-scoped undo without destroying provenance.
- Because shake removes via the `system` actor and human layers are unmutable by
  non-humans, there is no path — scoped or not — that clears human presence.
- The `unsafe` scope gives a future verifier harness a clean hook to auto-revoke
  layers judged unsafe after the fact.
