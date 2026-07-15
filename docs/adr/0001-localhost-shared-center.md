# ADR 0001 · Localhost is the shared center

- Status: Accepted
- Date: 2026-07-01

## Context

Sketched inherits Chalked's stance: the interesting surface is a **shared center**
the human witnesses directly, not a remote service the human reaches through. MVP-0
is dark-local — no push, no publish, no deploy.

## Decision

`localhost` is the shared center. The app runs local-first with **no hidden network
calls**. The dev server binds to `127.0.0.1`. There are no secrets in the repo and
no external service dependencies in MVP-0. Any future networked mode (multi-agent
bridge, collaboration) must be an explicit, documented direction with its own
consent design — never a quiet addition.

## Consequences

- Contributors can run and reason about the whole system offline.
- The audit log is complete because there is nothing off-box to lose track of.
- Networking becomes a deliberate future direction, not an ambient assumption.
- `getUserMedia`, uploads, and remote calls are absent by construction (see
  [`../09_SAFETY_CONSENT_BOUNDARIES.md`](../09_SAFETY_CONSENT_BOUNDARIES.md)).
