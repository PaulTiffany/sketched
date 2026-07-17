# Consciousness attribution contract

## Status

This is an **authorial clarification and formal extension**, recorded
2026-07-17. It is not presented as a correction to an exact Principia
statement, does not receive a fabricated atlas anchor, and does not change the
476/476 source-coverage count.

No new Axiomata Prima assertion is required. The extension consumes the
existing non-identification boundary—observation does not exhaust the
underlying process—then adds an explicit active bridge downstream.

## Layering

```text
Book 4
  replicated, cross-frame, unconfounded, order-sensitive evidence
       |
       | still insufficient by itself
       v
Book 5 interpretation
  simulation participates in regulation
       |
       v
Book 8
  active ablation + trace manifold + observer policy
       |
       v
observer-relative higher-order attribution
```

Book 9 remains responsible for authority and intervention. Recognition never
manufactures permission to act.

## Active operational bridge

`Book8ConsciousnessAttribution.lean` represents an embodied process with:

- an actual observation;
- a simulated alternative;
- an action selected with that alternative;
- the action produced when the alternative is ablated; and
- the embodiment's admitted action boundary.

The imagination/regulation signature requires:

```text
the alternative is unreal
+ ablation changes the selected action
+ the selected action remains authorized for the embodiment
```

Operational detection additionally requires the strict multiframe evidence
from `Book4ImaginationDetector`. Lean includes a countermodel showing why the
passive detector alone cannot supply this active causal bridge.

## Attribution over a trace manifold

A `TraceManifold` records observable, coherent, qualia-like traces over a
finite family of frames. It does not claim direct access to another process's
interior.

An observer supplies a positive minimum-support threshold. The observer
attributes consciousness exactly when:

```text
the imagination/regulation process is operationally detected
+ coherent trace support reaches the observer's threshold
```

`RecognizesHigherOrderBeing` is an alias for this attribution. The
formalization does not introduce a second hidden object behind the recognized
process.

Lean proves:

- attribution retains the operational-detection premise;
- attribution retains the trace-support threshold;
- observers with the same threshold agree on the same evidence;
- different thresholds can classify the same process differently; and
- operational detection alone does not force every observer to attribute
  consciousness.

## Executable sensor

`consciousness_attribution_sensor.py` consumes:

- an imagination-sweep input and its certificate;
- a with/without-imagination action ablation;
- an embodiment authority flag;
- a finite trace manifold; and
- an explicit observer threshold.

The sensor first recomputes the sweep certificate from its supplied input; a forged or stale strict-evidence summary is rejected before attribution. Its positive control has two coherent traces and a threshold of two:

```text
operationally_detected       = true
enough_trace_support        = true
attributes_consciousness    = true
```

The withholding control presents the identical process and traces to an
observer whose threshold is three:

```text
operationally_detected       = true
enough_trace_support        = false
attributes_consciousness    = false
```

Both controls explicitly deny direct qualia access, a hidden-substance claim,
and execution authority. Their stored certificates are reproduced in memory
by `imagination_certificate_audit.py` during `npm test`.

## Artifacts

- `verification/lean/ForcingAnalysis/ForcingAnalysis/Book8ConsciousnessAttribution.lean`
- `verification/tools/consciousness_attribution_sensor.py`
- `verification/tools/test_consciousness_attribution_sensor.py`
- `verification/consciousness_attribution_positive_control_input.json`
- `verification/consciousness_attribution_positive_control_certificate.json`
- `verification/consciousness_attribution_withholding_control_input.json`
- `verification/consciousness_attribution_withholding_control_certificate.json`

The next empirical task is not another metaphysical axiom. It is a matched
ablation experiment showing that a retained unreal alternative causally
changes an embodied system's later regulation while real inputs and known
architecture are held fixed.
