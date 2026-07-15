# ADR 0002 · Agents request, they do not control

- Status: Accepted
- Date: 2026-07-01

## Context

The whole premise is that the human is the authority-bearing observer. If agents
could mutate stage state directly, the audit log would be advisory and the
human-presence guarantee would be best-effort. We need it to be structural.

## Decision

Agents interact with the stage **only** by emitting `Proposal`s
([`../04_AGENT_PROTOCOL.md`](../04_AGENT_PROTOCOL.md)) that pass through the
`Gatekeeper`. The `Stage` is the single mutator, and it enforces the human-layer
invariant centrally in `actorMayMutate` — for every call path, not just the gated
one. Direct denied mutations throw `MutationDeniedError`; gated denials become
recorded rejections. "Agents propose; the surface disposes."

## Consequences

- The audit log is complete by construction: nothing mutates state without a
  `Stage` method, and every `Stage` method audits.
- Swapping consent policies (`Auto`/`Manual`/future) can never weaken the
  invariant, because the invariant lives in the `Stage`, not the policy.
- The doorway is small and serializable, so a remote/file-based agent bridge can
  be added later without changing the trust model.
- An `OverreachingAgent` is kept in the codebase specifically to prove, in tests,
  that reaching for human presence always fails.
