# 15 · Human Floor MVP0

## Claim

> Discrete refinements below the human floor; visible, budgeted flow above it;
> human authority at every interval boundary.

This is the executable bridge between Chalked's object-level eraser and
Sketched's live temporal surface. It is available at `/flow`.

## The demonstration

1. Open a channel at a human checkpoint.
2. Advance the deterministic agent one STEP at a time, or switch to FLOW.
3. Observe both clocks produce the same event transition and replay state.
4. Watch cumulative budget and the margin lower bound move with the trace.
5. Probe outside the angle: the mutation is refused and the channel closes.
6. Interrupt/shake: the channel closes, the root rewinds, its dependent layer is
   removed, the human signal remains, and a new context number is issued.
7. Export the trace; the in-app verifier replays it and checks its digest.

## Engine contract

`src/flow/engine.ts` is event-sourced. The event list is canonical; rendered
state is produced by `replay(events)`. STEP and FLOW are interface schedulers over
the same `advanceOne(events)` function. Clock mode is deliberately absent from
the canonical state because cadence must not change meaning.

An open channel carries:

- a finite logical lifetime;
- an angle naming affected layers and parameter bounds;
- a cumulative budget;
- an anchor margin equal to twice that budget;
- a monotone spent amount derived only from accepted mutation events.

Before accepting a mutation, the engine checks the active channel, lifetime,
angle, parameter bounds, and next cumulative expenditure. It closes rather than
admitting the event that would exceed budget.

## Mathematical correspondence

The budget meter instantiates the arithmetic shape of `margin_path_form`:

```text
margin lower bound = anchor margin - cumulative expenditure
margin floor       = interval budget
anchor margin      = 2 × interval budget
```

The Lean theorem proves that shape for an abstract drift sequence. The interface
does not claim its event cost is a discovered physical or cognitive quantity.
Cost assignment is operational calibration. The distinction is recorded in
`docs/14_EULA_MATH_BRIEF.md`.

## Honest boundary

This MVP0 does not implement continuous mathematics, camera capture, a real model,
source-process isolation, coupled-knob authorization of novel space, or external
identity. It proves the interaction contract with deterministic logical ticks:
an agent may flow without per-frame consent only inside a visible interval that
the human can interrupt and whose cumulative expenditure is replayable.

## Acceptance checks

- STEP and FLOW produce identical traces for the same number of advances.
- No accepted mutation can target the human layer.
- No accepted mutation can exceed angle, lease, or cumulative budget.
- Interrupt preserves the human layer and follows the dependency closure.
- Exported traces replay to their recorded final digest.
- Tampered traces fail verification.

