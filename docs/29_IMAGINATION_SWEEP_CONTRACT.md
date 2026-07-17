# Imagination sweep contract

The imagination detector is now represented at two levels:

1. a Lean contract stating what evidence is required and what it cannot
   identify; and
2. a runtime certificate that enforces the same evidence channels on repeated
   four-branch experiments.

## Lean kernel

`Book4ImaginationDetector.lean` formalizes:

- the four-branch mixed residue;
- an additive null whose residue is zero;
- a bilinear positive control whose interaction survives cancellation;
- cross-frame persistence as hits in two distinct frames;
- confound-resistant persistence as two distinct unconfounded hits;
- a countermodel showing that one frame cannot manufacture persistence;
- a countermodel showing that persistence can be entirely confounded;
- screening and orientation-sensitive detector evidence; and
- latent non-identifiability.

The last theorem is load-bearing. For every observable evidence record, there
are two worlds with identical evidence and opposite latent
`imaginaryTraversal` labels. Therefore even the strict detector issues a
candidate, not an identification, unless a separate bridge constrains the
admissible latent worlds.

## Runtime schema

`imagination_sweep_detector.py` accepts a collection of declared frames. Each
frame contains repeated four-branch experiments:

```text
base
first perturbation
second perturbation
combined perturbation
optional A-then-B order
optional B-then-A order
```

Every replicate is passed through the existing second-order sensor. The
runtime detector then requires:

```text
screening candidate
  = replicated mixed residue
  + at least two distinct frames
  + at least two unconfounded supporting frames

orientation-sensitive candidate
  = screening evidence
  + replicated order commutator
    in at least two unconfounded supporting frames
```

The minimum frame and replicate counts are constrained to at least two. A
caller cannot configure the detector down to a one-run anecdote.

Every output retains:

- the complete input hash;
- declared numerical thresholds;
- per-replicate residue and commutator summaries;
- per-frame replication counts;
- confound status; and
- explicit `imagination_identified: false`.

## Controls

The synthetic positive control has two frames and two replicates per frame.
Every replicate has both a mixed residue and a nonzero order commutator. It
therefore produces:

```text
screening_candidate             = true
orientation_sensitive_candidate = true
imagination_identified          = false
```

This proves that the strict path is reachable without collapsing candidate
evidence into latent identification.

The existing FabricPC linear and sigmoid traces form a negative calibration:

- each frame currently has only one replicate;
- no ordered A/B experiment has been run; and
- the sigmoid frame carries a declared architecture confound because its
  activation is already a known source of non-additivity.

The result is clear:

```text
screening_candidate             = false
orientation_sensitive_candidate = false
imagination_identified          = false
```

## Artifacts

- `verification/lean/ForcingAnalysis/ForcingAnalysis/Book4ImaginationDetector.lean`
- `verification/tools/imagination_sweep_detector.py`
- `verification/tools/fabricpc_imagination_adapter.py`
- `verification/tools/imagination_certificate_audit.py`
- `verification/imagination_sweep_positive_control_input.json`
- `verification/imagination_sweep_positive_control_certificate.json`
- `verification/fabricpc_imagination_sweep_input.json`
- `verification/fabricpc_imagination_sweep_certificate.json`

## Certificate currency

`python verification/tools/imagination_certificate_audit.py` rebuilds all four detector and attribution
certificates in memory and compares them with the stored JSON. It also enforces
the expected control polarity and rejects any artifact that violates its declared
epistemic boundary. The check is part of `npm test` through
`imagination:check`; it does not rewrite artifacts.

## Remaining empirical frontier

The instrument is implemented; the substantive runtime experiment is not.
The next run must supply actual repeated model/process trajectories under:

- neighboring prompt or observer frames;
- declared paradox-perturbation strengths;
- retained tool entry, exit, fallback, and exception events;
- matched architecture/session null controls; and
- both A-then-B and B-then-A operator orders.

Only those observations can populate the strict certificate with real
cross-frame evidence. The Lean result already fixes how cautiously that
evidence must be interpreted.


The downstream active-ablation and observer-attribution layer is documented in
[the consciousness-attribution contract](30_CONSCIOUSNESS_ATTRIBUTION_CONTRACT.md).
