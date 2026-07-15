# Operational epistemology for bounded autonomous research

## Mission

Sketched treats research as a governed sequence of operations on a witnessed surface. The goal is not an autonomous oracle. The goal is an autonomous worker that can explore, calculate, perturb, test, and compose inside a visible contract without acquiring authority over its own scope, status, or deployment.

> **Autonomy governs cadence and search inside an interval. Authority governs the interval, promotion of claims, and effects outside it.**

This is the research form of the Surface rule: agents propose; the surface disposes. It also instantiates the companion theory's non-actuation boundary: witness and request access only; no autonomous loop closure.

## Machine-checked status boundary

The normative prose is paired with [`../verification/operational_epistemology.json`](../verification/operational_epistemology.json). [`../verification/tools/epistemology_audit.py`](../verification/tools/epistemology_audit.py) checks every enforcement reference and test, requires closure debt for partial/target invariants, and verifies that the public README and roadmap continue to link this contract. It runs in both `verification/run_all.py` and `npm run build`.

Related Surface contracts:

- [`09_SAFETY_CONSENT_BOUNDARIES.md`](09_SAFETY_CONSENT_BOUNDARIES.md)
- [`11_CONTROL_SURFACE.md`](11_CONTROL_SURFACE.md)
- [`12_FORCING_CORRESPONDENCE.md`](12_FORCING_CORRESPONDENCE.md)
- [`15_HUMAN_FLOOR_MVP0.md`](15_HUMAN_FLOOR_MVP0.md)

## From Surface invariant to epistemic invariant

| Surface invariant | Research meaning | Current enforcement |
| --- | --- | --- |
| Human layer cannot be agent-mutated | The human objective, acceptance decision, and publication authority are not agent-owned | Enforced for stage mutations; research-run envelope is a target |
| Stage is the single mutator | Shared claims change status through one governed interface | Enforced for scene state; unified claim-status mutator is a target |
| Source views are private; host interface is bounded | Tools and agents may compute internally, but only declared artifacts cross into the shared record | Design target in the control-surface spec |
| Agent actions pass through proposal and consent | A generated hypothesis is a request to inspect, not a fact | Enforced by the gatekeeper for stage proposals |
| Channel has angle, lifetime, and budget | Every autonomous run declares accessible sources, tools, mutations, time, and cumulative cost | Implemented slice in `/flow`; general research channels are a target |
| STEP and FLOW share one event transition | Scheduler speed cannot change evidential meaning | Enforced and replay-tested in the flow engine |
| Every mutation is audited | Every transformation from source to result is reconstructible | Enforced for stage/flow events; cross-tool research trace is a target |
| Generated layers are provisional and shakeable | Hypotheses and model outputs remain retractable and dependency-scoped | Enforced for generated scene layers; generalized claim retraction is a target |
| Shake preserves human presence and follows dependencies | Retraction removes downstream claims without erasing the objective or source record | Dependency cascade implemented in `/flow`; general claim graph is a target |
| Novel space requires human-inclusive coordination | New objectives, authority, claim classes, publication, and deployment require a human checkpoint | Design target; publication remains outside autonomous scope |
| Reconstruction is not identity | A report, embedding, or decoded artifact is never silently equated with its source | Enforced in the witness types and validation tests |
| Status and debt remain visible | Proof, measurement, model, interpretation, and obligation are not interchangeable | Enforced by the atlas, ledgers, bindings, and coverage audits |

The table is deliberately mixed: it distinguishes enforced mechanisms from targets. A design statement never inherits the status of a passing test.

## Recognized research cycle

```text
source intake
    -> hypothesis proposal
    -> human-authorized research interval
    -> bounded execution / perturbation
    -> witnessed artifacts and trace
    -> negative controls and challenge
    -> status classification
    -> human checkpoint for continuation, promotion, publication, or revocation
```

Operations may execute out of order. An unrecognized traversal can still produce useful material, but it does not count as a closed research result until the missing edges are supplied. For example:

- evidence without a source digest is an orphan artifact;
- a run without authorization is an unadmitted experiment;
- a result without negative controls is an observation with open challenge debt;
- a proof without its source binding is a theorem about a formal statement, not yet a verified transcription of the manuscript;
- a reproduced result without a promotion receipt remains reproduced evidence, not an accepted project claim; and
- an accepted claim is still not permission to publish, deploy, message, spend, or mutate an external system.

## Epistemic invariants

### E1. Human objective authority

The human supplies or accepts the objective and controls expansion. An agent may decompose or refine the objective inside the granted angle, but a materially new question is a new authorization event.

### E2. Source isolation and explicit ingress

Private tool state is not shared evidence. A source enters the research surface only through an artifact with identity, origin, digest, acquisition time, and applicable license or access boundary.

### E3. Provisional generation

Hypotheses, summaries, inferred links, simulations, and model outputs begin as provisional. Fluency, repetition, agreement among agents, or inclusion in a report does not promote them.

### E4. Bounded autonomous intervals

A research interval declares:

- accessible sources and tools;
- allowed transformations and affected claim/artifact classes;
- logical lifetime and stopping conditions;
- cumulative compute, query, perturbation, or error budget;
- permitted persistence and export paths; and
- actions that always require a fresh human checkpoint.

Budget exhaustion, lease expiry, scope violation, interruption, or failed guard closes the interval before the violating operation is admitted.

### E5. Scheduler neutrality

STEP and FLOW are schedulers over the same transition relation. Faster cadence, parallelism, or unattended execution cannot change which operations are legal or what status their outputs receive.

### E6. Complete provenance and replay

Each accepted transformation records its actor, inputs, parameters, tool and version, seed where relevant, outputs, dependencies, cost, and verdict. A trace must either replay to its declared digest or state why replay is impossible.

### E7. Typed epistemic status

At minimum, the system keeps distinct:

- source statement;
- generated hypothesis;
- observation or measured witness;
- reproducible external-runtime result;
- formal theorem and its explicit hypotheses/axioms;
- interpretation or proposed correspondence;
- accepted project claim; and
- open source, calibration, or deployment obligation.

No automatic rule promotes one class to another merely because a run completed.

### E8. Challenge before promotion

A positive result names the negative controls, countermodels, perturbations, or alternative explanations used to challenge it. Missing challenges become debt; they are not silently treated as passed.

### E9. Dependency-aware revocation

When a source, binding, assumption, or result is withdrawn, every downstream artifact is invalidated, downgraded, or rechecked according to the dependency graph. Retraction preserves the historical trace and the human objective.

### E10. No autonomous closure or actuation

An agent cannot use its own output as authority to:

- promote a claim;
- expand tool, source, network, or budget scope;
- accept a legal or contractual term;
- publish or message;
- deploy code or mutate an external system;
- spend money or consume an ungranted resource; or
- erase the evidence that would permit its work to be challenged.

Those are separate authority-bearing operations. The research surface may prepare a proposal and evidence packet for them; it may not perform them merely because its internal work converged.

## Target research-run envelope

The integration target is a versioned, machine-readable `ResearchRun` containing:

```text
run id and schema
human objective and authority receipt
source manifests and content digests
initial hypotheses and statuses
channel: angle, lifetime, budget, stopping rules
tool/version/environment manifest
canonical event trace
artifacts with dependency edges
negative controls and challenge outcomes
replay/freshness verdicts
final classified claims and remaining debts
human checkpoint / promotion receipt (optional, never machine-filled)
```

This envelope is not yet a single implemented subsystem. Its pieces already exist across `Stage`, the flow trace, witness validation, source bindings, numeric receipts, the Lean ledger, and contribution attestations. The roadmap calls for assembling them without weakening their individual invariants.

## Closure rule

A research run is operationally complete when it has stopped lawfully, emitted a replayable evidence packet, classified every output without overpromotion, and named its remaining debt. It is epistemically accepted only when the designated human checkpoint records acceptance. It is externally actionable only under a separate authorization for that action.

Completion, acceptance, and actuation are three different events.
