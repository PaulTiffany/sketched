# 06 · Provenance and Audit

**The audit log is what lets the toy become a tool.**

Provenance is attached to things (layers, assets). The audit log is the ordered
record of events. Together they make a run legible after the fact.

## Provenance (on every layer / generated object)

```ts
interface Provenance {
  createdBy: Actor;    // human | agent:<id> | system
  createdAt: number;
  dependsOn: string[]; // ids of layers/assets/proposals relied upon
  reason?: string;     // why it exists
}
```

`dependsOn` is what lets shake and future verifiers reason about consequences
instead of blindly deleting.

## Audit events

Every mutation answers these questions, captured in `AuditEvent`:

| Question | Field |
| --- | --- |
| Who / what requested this? | `actor` |
| What changed? | `type`, `summary`, `details` |
| Which layer was affected? | `layerId` |
| What did it depend on? | `dependsOn` |
| Was consent required? | `consentRequired` |
| Was consent granted? | `consentGranted` |
| Can it be shaken / reverted? | `reversible` |
| When? | `at` |

### Event types

`proposal.received`, `proposal.accepted`, `proposal.rejected`,
`consent.granted`, `consent.denied`,
`layer.created`, `layer.updated`, `layer.removed`, `param.keyframed`, `shake`.

## The log is append-only

`AuditLog` only appends. It is never rewritten — that is what "memory under
constraint" means. You can query it by actor, by layer, or by type
(`byActor`, `byLayer`, `byType`) to reconstruct exactly what happened and why.

## Why this matters

A single accepted agent action leaves a legible trail:
`proposal.received → consent.granted → layer.created → proposal.accepted`.
A rejected one leaves:
`proposal.received → consent.denied → proposal.rejected`, with human presence
provably untouched. Anyone (or any verifier agent) can read the log and confirm
the invariants held for the whole run.
