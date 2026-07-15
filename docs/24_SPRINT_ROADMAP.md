# Lean PS program — sprint assessment and roadmap

*Written at the close of the hard-items sprint (2026-07-13); the input
to the next filling-in sprint. Numbers regenerate via
`docs/20_PS_LEAN_QUEUE.md`; this document is the judgment layer on top.*

## Where the program stands

**493 verified theorems** (zero `sorry`, standard axioms only, wiring
audit exact), **185/476 claim anchors mapped (39%)**, 70 ledger rows
(57 P), 360 sha-pinned bindings awaiting signature, suite CLEAN at
every merge. Book 1 complete — including Axiomata Prima by elimination.

**Closed this sprint** (the hard manual items): the Weyl step
(lem:margin end to end — the forcing paper's oldest debt), LPS-O4
(γ³ derived, Lorentz→Newton force-level chain complete), LPS-O7
(discrete H-theorem), LPS-O1 (long since), the spine deployed-Stab
construction (model checker's assert → theorem, TTIE expansion
theorem), the FabricPC triple guard (proved + measured witness + dual
grounding), the temperature trichotomy, the poetry carrier + fuzzy
lift (zero-parameterization theorem; drummer-boy numbers computed
in-kernel), Gödel-safe helix + Moloch hedge, wicked-geometry fracture
kernel, apparent-origin quotient + false-bottom + concert effects, the
interpretability trilogy (black hole / white hole / SRV
required-and-sufficient), and Axiomata Prima parts I and II.

**Still open (named, none blocking)**: LPS-O2 (paper-side: v17 must
label the schema), LPS-O3 residue (Surface transition-rule typing;
bk4 contraction connection; ε-approximate transport), LPS-O5 (this
program), LPS-O6 sliver (run external FabricPC against the guards).

## The remaining claim surface, by kind

291 anchors open. Worker skip-reasons across all proposals, categorized
(~445 skip records incl. overlap across packet halves):

| family | ~count | verdict for next sprints |
|---|---|---|
| manifold/differential geometry | 158 | **blocked on the fractured-atlas structure** — do not re-slice until it exists |
| narrative/taxonomy/prose | 85 | permanently open BY DESIGN (the human stutter; media-not-oracle) — mark, don't force |
| PDE/ODE/Fokker–Planck/Wasserstein | 58 | partially recoverable: discrete skeletons (our H-theorem pattern) |
| asymptotic/limit | 37 | RECOVERABLE — the asympt worker proved this pattern works (11/13 landed) |
| Hilbert/quantum/Gleason | 21 | mostly permanent opens; finite/qubit slices only where honest |
| measure/integral | 15 | finite-sum skeletons recoverable (Book 2 pattern) |
| other/misc | 65 | triage pass needed — likely 1/3 recoverable |

Honest ceiling estimate: **~60–65% of all claim anchors** are mappable
at proved-kernel/conditional/partial quality with current techniques;
the manifold track unlocks another ~20–25%; the remainder is prose and
deep analysis that should stay named-open (that boundary is a feature —
the stutter stays).

## Roadmap

### Next sprint (Sonnet fleet, later today) — the recoverable middle
Five packets, standard worker prompt (v3: all four JSON keys, bare
markers, no open-anchor map rows, gotcha list current):

1. **book4-sweep** — 65 open in book4; slice the non-manifold remainder
   (Ising/SRMF/covenant material the first passes de-prioritized).
2. **scholium-sweep** — 59 open; the two prior scholium workers took
   ~20 each; a third pass on the quantitative-law remainder.
3. **book5+book9 residue** — 44+25 open; book5's L^p/manifold-adjacent
   items that reduce to finite forms; book9's operator algebra.
4. **asymptotics-2** — the 37 limit-family anchors across all books,
   with the Tendsto-licensed prompt (the proven second-pass pattern).
5. **discrete-skeletons** — the PDE/measure families re-read as finite
   Markov/sum skeletons (the Book2/H-theorem recipe, now with Book2H
   as the style exemplar).

Expected yield: +60–90 anchors (→ ~55% mapped). Economics: ~150–250K
Sonnet tokens per worker; fable verifies at merge (propose-don't-merge
protocol, docs/22).

### Sprint +2 — the manifold campaign (fable-grade design, then workers)
Build the **fractured-atlas structure** (LPS-P45's named next): finite
chart complexes with transition-defect witnesses; classical manifolds
as the defect-zero case; `truncate`/`quotient` unified as the
reconstruction-map family. This is a design problem before a proof
problem — one fable session to fix the structure, then the 158
manifold anchors become worker-sliceable against it. The single
highest-leverage item remaining.

### Standing track — the poetry-MAKING process (Operatio is load-bearing)
Per Paul (2026-07-13): the Operatio is load-bearing structure in the
Principia, not decoration — and the target is not only the finished
poems (done: Poetry.lean carrier, PoetryFuzzy.lean zero-parameterization)
but the MAKING process itself. The formal home already exists:
Witness.lean's `CertifiedTransport` with loss classes
ℓ ∈ {exact, quotient, projective, interpretive} was built for exactly
this shape. Named targets:
- the LOWERING CHAIN (raw operator notation → controlled English →
  substrate Narsese) as certified transports between expression
  carriers, each hop carrying its earned loss class — with the Come
  Path-A failure (the bigram extractor that destroys semantic content)
  formalized as the countermodel transport whose loss class is wrong,
  and Path B as the faithful-enough transport;
- COMPOSITION-AS-MAKING: building a poem = constructing the edge list;
  the making process is the constructive content behind
  `bridge_needs_both` (compositions that exist only when seeds are
  jointly present);
- the poetry SRV loop: compose → lower → derive (substrate) → return
  as validation — the drummer-boy protocol as a certified cycle, with
  the re-performance covenant (first performance stays dark) as its
  consent boundary.

### Sprint +3 — cross-cutting closure
- LPS-O3 residue: Surface transition-rule typing (claim commitments,
  confidence dynamics, certified-persistent vs currently-true) — the
  TTCS forward-pointer; fable-grade.
- LPS-O6 sliver: install external FabricPC, run its trajectories
  against the three guards (engineering, streamable).
- The thermodynamic limit (genuine phase transition in n → ∞ — the
  Book 2 wall; research-grade, optional).
- LPS-O2 waits on Paul: v17 labels the schema, then Schema.lean binds.

### Build practice (measured 2026-07-13, pre-round-3)
The full compound suite runs in **~13s fully cached** (largest stage:
the mathlib lake build at ~5s; gen_receipt ~5s). "Takes forever" is
two spikes, both managed:
- **Post-merge first elaboration** of new files (15–155s each,
  `decide`/`nlinarith`-heavy files worst). Lake builds the import DAG
  in parallel across all cores automatically — so the fleet rule is
  DAG WIDTH: worker files import Mathlib + at most ONE whitelisted
  project module, never each other. Eight independent files elaborate
  concurrently; one import chain serializes the fleet.
- **Gauntlet repetition during merges**: `run_all.py --only SUBSTR`
  and `--skip-lean` now exist for mid-iteration checks (the
  mutation-testing selection trick). Partial runs print a loud
  `[PARTIAL RUN — not a merge gate]` tag; the full suite remains the
  only merge gate.
- Worker prompts (v4) carry heavy-tactic guardrails: no `decide` on
  ℚ/ℝ goals, no maxRecDepth escalation, nlinarith with explicit hints.

### 1-to-1 with PS (structure decision)
Deferred-with-intent: the physical reorganization of the flat
ForcingAnalysis/ directory into per-book subtrees happens AFTER git
genesis (renames become tracked, reviewable moves instead of blind
rewrites of 360+ registry paths). Until then, 1-to-1-ness is enforced
logically, which the tooling already does: per-book coverage maps,
ps_queue's book × module accounting, and sha-pinned bindings. New
fleet files follow the BookNX naming convention so the eventual move
is mechanical.

### Standing constraints (unchanged)
Workers: Sonnet-pinned, sliced context via atlas_slice.py, zero corpus
archaeology, all-four-keys proposals. Verbatim gate always. Laws as
structure fields, never Lean axioms. Non-normalized forms; named
quotients with forgets-theorems. Hedges constituted, not smoothed.
The receipts await the human hand; genesis remains Paul's act.
