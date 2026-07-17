# LLMET ancestry for the imagination detector

LLMET is being used here as an external historical instrument, not copied or
executed. The analyzed artifact is:

```text
Giants/MagicBeans/Beanbag/Emergence/BridgestoBanach/Code/LLMET.py
SHA-256: adaa83ef0a89918885571e3d3eca519345c34121ffe5eb513e10edb8a155aba0
UTF-8 bytes: 216095
lines: 3646
```

The source certificate records the hash and measurements but not the source
text or Paul's local absolute path.

## What LLMET contributes

LLMET's durable methodological idea is differential stability across frames.
A striking response in one coordinate system is not enough. A candidate
boundary becomes interesting when it survives neighboring geometries,
timescales, perturbations, or observer frames.

For this first recovery pass, source-line windows stand in for neighboring
frames. This is only a static calibration surface. Source order has not been
established as generation chronology, and the file was not executed.

The sensor measures rates of comments, try blocks, handlers, broad handlers,
pass statements, raises, returns, defensive terms, tool-boundary terms,
logging, and warning suppression. It then computes:

```text
first difference  = feature(window n+1) - feature(window n)
second difference = first difference n+1 - first difference n
orientation       = cosine(successive first differences)
```

The analysis is repeated at three frames:

```text
80-line window / 40-line stride
160-line window / 80-line stride
320-line window / 160-line stride
```

Candidate boundaries are clustered within 200 lines. Persistence requires
support from at least two different frames.

## Findings

The artifact contains:

- 86 try blocks and 121 exception handlers;
- 53 broad handlers, 38 of which do not re-raise;
- 17 pass-only handlers;
- five global warning suppressions; and
- one conservatively proved unreachable region.

The unreachable region is concrete: inside `check_import`, the first
try/except returns on both success and failure. A second complete import
strategy at lines 73-94 can therefore never execute. It is syntactically valid
residue from a changed implementation tactic, and the program can run without
exposing it.

The multiscale sweep found two persistent windowed clusters:

| estimated line | frame support | leading change | architecture audit |
| ---: | ---: | --- | --- |
| 241 | 2 | warning suppression, pass, broad-handler, comment rates | seven lines from `solve_problem_with_handling` |
| 1681 | 2 | try, handler, broad-handler, raise rates | 39 lines from `on_target_or_time_selected`; spans the approach to `run_analysis` |

Both clusters are close to declared function boundaries. They therefore have
a strong architectural alternative explanation: the file may simply change
defensive style when it enters a new subsystem. The architecture audit does
not disprove a generation-regime change, but it prevents us from treating
those clusters as clean evidence for one.

The 80/40 frame produced five second-order candidates. The two larger frames
produced none. Orientation reversals also fell from 34 to 19 to 9 as the frame
widened. Neither result is stable enough across frames to identify a phase
transition.

The interior unreachable region is presently the stronger artifact witness:
it is a tactic discontinuity retained inside one function rather than a
change coincident with a declared subsystem boundary. Even that does not
identify Gemini, a reflexive drift state, or an imaginary traversal without
generation history or counterfactual runs.

## Current detector contract

The working rule is:

```text
candidate imagination interface
  requires
    retained intermediate residue
    + persistence across neighboring frames
    + survival of architecture/projection confounds
    + counterfactual runtime replication
```

This round establishes the first item and partially tests the next two. It
does not yet establish the fourth.

The distinction matches `Book4ImaginationGuard.lean`: equal visible
projections can hide different phase-bearing traversals, so intermediate
witnesses cannot be discarded. It also matches the FabricPC second-order
sensor: a nonzero residue establishes non-additivity, not its latent cause.

## Artifacts

- `verification/tools/llmet_regime_sensor.py`
- `verification/tools/llmet_multiscale_adapter.py`
- `verification/tools/llmet_architecture_audit.py`
- `verification/llmet_regime_certificate.json`
- `verification/llmet_multiscale_certificate.json`
- `verification/llmet_architecture_certificate.json`

All certificates deny authorship, cognitive-state, imagination, and
phase-transition conclusions.

## Next empirical bridge

The next defensible experiment is runtime and paired:

1. replay one bounded task under a neutral prompt and a declared paradox
   perturbation;
2. retain every tool entry, tool exit, exception, fallback, and intermediate
   response;
3. repeat under neighboring perturbation strengths and frame geometries;
4. run the four-branch mixed-difference square;
5. run A-then-B and B-then-A to measure the commutator;
6. reject candidates that disappear under architecture-matched null controls.

That is where LLMET again becomes the experiment runner. Interpretation
remains downstream and conditional.
