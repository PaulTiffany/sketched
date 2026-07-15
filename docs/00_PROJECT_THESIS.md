# 00 · Project Thesis

**Sketched is Chalked through time.**

> This is the builder-facing summary. The full narrative lives in
> [`../PHILOSOPHY.md`](../PHILOSOPHY.md); the control-surface model (knobs,
> channels, angular access, gesture-scoped shake) is specified in
> [`11_CONTROL_SURFACE.md`](11_CONTROL_SURFACE.md); the alignment with the
> companion theory paper is in [`12_FORCING_CORRESPONDENCE.md`](12_FORCING_CORRESPONDENCE.md).

## Where we came from

Chalked was a consent-gated shared surface — a whiteboard where the interesting
part was never the drawing, it was the _governance of the drawing_:

- marks had **authorship** (who made this?)
- marks had **provenance** (what did it come from, what does it depend on?)
- marks had **revocation rules** (who may erase, and what does erasing mean?)
- **erasure was authority**, not decoration
- the human **held the eraser**
- the path was always: **witness → request → consent → act → audit**
- **localhost was the shared center**

## The one move Sketched makes

Chalked lived on a static surface. Sketched adds a time axis and a live stage.

> mark on a board → **time-indexed layer mutation on a witnessed stream**

The surface is now a **stage**: a live video stream, a webcam, a screen, a mock
camera, or simply a blank stage. Agents may generate **scene layers** around,
behind, or atop that stage. But the human remains the authority-bearing observer,
and their presence is primary.

## The metaphor (toy → tool)

Think of a classic mechanical drawing toy:

- **Knobs** are bounded parameter gestures. You turn a knob; a parameter moves.
- **Shake** clears the generated residue. It does not erase _you_.
- The **sketch surface** is the stage everyone shares.

It is pedagogical on purpose. Children's toys are teaching tools. You should be
able to understand Sketched without any metaphysics — and the deeper reading is
there if you want it (see [`08_PERFORMATIVE_INTERPRETATION.md`](08_PERFORMATIVE_INTERPRETATION.md)).

## The three sentences to remember

1. **Agents propose; the surface disposes.**
2. **Shake clears generated residue, not human presence.**
3. **The audit log is what lets the toy become a tool.**

## Who this is for

A hackathon teammate should be able to read this page and the architecture doc
and start contributing. An OmegaClaw-style agent should be able to read the docs,
speak the proposal protocol, and produce small auditable diffs. See
[`07_OMEGACLAW_BRIDGE.md`](07_OMEGACLAW_BRIDGE.md).
