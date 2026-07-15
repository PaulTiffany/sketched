# selfcompile - Matt/Ellie, first vertical slice

The self-compiling educational medium, proven on one operator end to end.
Not the robot-voice citer: **the claim layer and the rendering layer are
split, and the render is verified against the claims instead of trusted.**

```
pedagogical query
  -> Ellie builds a lesson hypothesis, calls Matt operators
  -> Matt returns grounded claims (Part A: id/source/kind/tolerance, fresh live numbers)
  -> Ellie renders a segment (Part B: free prose, numbers drawn from the manifest)
  -> the transcript verifier gates it (the tamper test proves it bites)
  -> emit one semantic node -> self-compile to podcast / textbook / slides
```

Run: `python run.py` (exit 0 iff the clean line verifies **and** the tampered line FLAGs).

## Layers

- **`matt.py`** - analytical operator API over the verified stack.
  `construct_example` is *realized* (runs the feasibility-cliff geometry live).
  `fabricpc_profile` is *realized* as an external-source bridge: it grounds
  FabricPC as a predictive-coding substrate and reads the pinned local JAX run receipt without claiming the still-open implementation-to-guard correspondence.
  `lorentz_witness_report` is *realized*: it reads the deterministic
  equivariance witness (`verification/lorentz_witness.json`) and the Lean PS
  ledger, grounding the one-schema-two-instances lesson in fresh numbers.
  book5_coverage_report is realized: it reads the generated Book 5 Lean coverage packet, preserving proved, conditional, partial, and open claim classes for the Matt/Ellie semantic lesson and downstream renderers.
  The rest are *declared targets*, each with a real home already in the repo:
  `trace_dependency`/`identify_assumptions` -> atlas `depends_on` + ledger
  *Consumes*; `find_counterexample` -> finite model checker + `Margin.lean`;
  `explain_proof_step` -> atlas `latex_body` + Lean proof term;
  `locate_citation`/`evaluate_support` -> fuzzy matcher + `certificate_tier` + mu.
- **`ellie.py`** - control intelligence + judge. Composes the segment; her
  `PEDAGOGICAL_CHECKS` are the anti-hallucination invariants `/book/surface.json`
  already runs (no bare claims, anti-masking, certificate typing).
- **`verify.py`** - the gate. Numbers must round to a manifest value; status
  words must be licensed; boundary notes are honored. Matt lines verify clean;
  Ellie-marked lines may carry unmatched flow.
- **`manifest.py`** - Part A `Claim`/`Manifest`.
- **`fabricpc.py`** - local source capsule for the FabricPC bridge. See
  [`docs/17_FABRICPC_BRIDGE.md`](../docs/17_FABRICPC_BRIDGE.md).

## Next ops (widen Matt from the same stack)

`trace_dependency`, `identify_assumptions`, `find_counterexample` - each a thin
wrapper returning a grounded `Claim`, gated by the same verifier. Then extend
the semantic node into `book/projections.json` so the same program renders to
audio/video, not just the browser textbook.
