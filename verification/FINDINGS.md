# Mechanical findings — forcing_correspondence (suite runs 2026-07-02)

Everything below was produced by `python verification/run_all.py`, not by
reading. Codes refer to the detectors' error taxonomies.

## 0. v15 resolution status

`forcing_correspondence_v15.tex` was drafted against the repair queue below
and re-verified. Suite result: **CLEAN** (fatal codes all zero). What changed:

- **Cycles/forward refs (§1, §2): all three cycles and all forward
  definition references eliminated.** The step bound became Assumption 1
  (smoothness contract, with the *cumulative* displacement budget); the
  Channel-Margin Lemma was restated in path form with a sound one-shot Weyl
  argument, and a remark records why the v14 per-step induction was unsound.
  The propositional clauses, persistence, and deciding-set lemmas moved to §5
  (before all consumers); D_p^* is now defined from Def-level objects only.
- **Two forcing relations (R2):** `\forcesH` (J_adm) and `\forcesnn` (J_nn)
  are notationally separate; lem:nonatom is stated for the dense reading
  where its unpacking is valid; lem:atomic's (⇒) routes through the maximal
  sieve instead of the false dense⇒cover bridge.
- **Stab is atomic-only (R3):** stability sets A_φ are defined once;
  the torsion remark is discharged for atomic φ only, citing the finite
  countermodel; calibration item 6's compound case is tagged O.
- **Ledger:** legend extended to {P, D, S, M, C, O}; def:site/def:wit/
  thm:factor retagged D; prop:chalked S; rows added for lem:pers, the
  smoothness contract, the calibration-queue assumption, and atomic torsion;
  Consumes cells now carry transitive debts (verified by the auditor with an
  explicitly declared *ambient* debt: everything on P_H^eta consumes the
  smoothness contract through Def refine).
- **Other repairs:** prop:chi's truncated bound replaced by the provable
  triangle bound; E_A retyped onto the residue subspace of the state space;
  Def transfer added and thm:factor demoted to architectural; lem:cauchy
  gains hypothesis (c); thm:prop's ∨(⇐) rerouted through deciding sets;
  lem:void/lem:bdd/lem:reach/lem:bivalence/prop:dich/lem:bw all have proof
  environments; Adm(·) removed.
- **Remaining informational findings (accepted):** theorem targets survey
  later lemmas (by design), and 8 M/C/O ledger rows live in prose — which
  is now policy: P/D/S rows must join the atlas (all do), M/C/O rows are
  named debts and may stay prose. The formerly unanchored P/D rows were
  promoted in-place: `prop:zeroth` (forced-to-zeroth-order),
  `prop:skeleton` (Eureka skeleton), `def:rio` (RIO schema, retagged D),
  the torsion row joins `rem:torsion`, and both conjectures now use the
  previously unused `conjecture` environment.
- **Visualization:** `tools/atlas_viz.py` renders the atlas as
  `atlas.html` — an interactive SVG dependency graph (section swimlanes,
  status colors, solid \\ref edges vs dashed symbol edges, red borders on
  proofless provables, hover-highlighted neighborhoods).

## 0b. Lean kernel status (2026-07-02)

`verification/lean/ForcingKernel/` builds successfully on Lean 4.31.0
(core only, no mathlib). Formally verified, with kernel-checked axiom
dependencies:

| theorem | paper claim | axioms used |
|---|---|---|
| `site_bound` | lem:sitebound | **none** (fully constructive) |
| `forces_consistent` | lem:pers (consistency) | propext, Quot.sound |
| `deciding_dense` | lem:dec | + Classical.choice |
| `rasiowa_sikorski` | lem:bdd / R–S | + Classical.choice |
| `truth_lemma` | thm:prop | + Classical.choice |
| `exists_generic_truth` | generic existence + truth | + Classical.choice |
| `margin_path_form` | lem:margin (v15 path form) | propext, Quot.sound |
| `per_step_bound_insufficient` | v14 induction REFUTED | propext, Quot.sound |

And in the mathlib-backed `ForcingAnalysis` project (Lean 4.31.0 +
mathlib v4.31.0, prebuilt cache; all rows propext + Classical.choice +
Quot.sound):

| theorem | paper claim |
|---|---|
| `cauchy_forcing_completion` | lem:cauchy (Lyapunov ⇒ summable ⇒ Cauchy ⇒ limit) |
| `order_metric_compatibility` | lem:ordmet (closed stabilized region traps the limit) |
| `transport_identity_iff_residue` | thm:nonid (identity ⟺ residue subobject) |
| `projection_loss_zero_iff_residue` | thm:nonid, metric form (ε_T = 0 ⟺ residue) |
| `exportability_identity` | prop:chi, orthogonal case (χ² + ε² = 1) |

The numeric witness `kernel/numeric_margin.py` (numpy) realizes the
margin countermodel in actual interaction matrices: Γ(x) = [[1,x],[x,1]],
per-step-legal v14 path collapses λ_min to 0 at depth 2; the v15 budgeted
path holds λ_min ≥ η/2 across 50 steps. The margin lemma thus has three
independent verifications: Lean proof, Lean refutation, and numerical
eigenvalue computation.

`Margin.lean` packages Weyl + Lipschitz as the per-step drift hypothesis
(the matrix analysis is cited, not re-proved) and then checks the pure
order-arithmetic remainder over `Int`: the cumulative budget gives a
depth-uniform margin, and — the session's headline bug, now a theorem —
per-step control alone provably does not (countermodel λ_i = 4−2i).

Persistence (lem:pers, first half) is carried by construction: `Forces`
returns a bundled persistent predicate. The ledger's debts appear as the
theorem hypotheses: (M-Pers) = `[Persistent V]`, (M-Bound) = the `enum`
surjection, Site Bound = `hdense`. Decision Reachability does not appear:
at this abstraction level R–S needs only order-density (lem:dec), and
reach is consumed only when the generic must traverse admissible moves —
documented in Generic.lean's header, matching calibration item 8.

Build: `lake build` in `verification/lean/ForcingKernel` (elan toolchain
`leanprover/lean4:v4.31.0`); also wired into `run_all.py` as a final
stage, skipped when no toolchain is present.

Not formalized (modeling-layer or deeper analysis): lem:margin's Weyl step
(matrix spectral perturbation — its order-arithmetic remainder is checked
in Margin.lean and its matrix content witnessed numerically), lem:bw
(chain-complete fixpoints), and everything touching the Hypothesis
Surface apparatus. lem:cauchy, lem:ordmet, thm:nonid, and prop:chi ARE now
formalized — see the ForcingAnalysis table above.

## 0c. Hypothesis-mutation sweep (2026-07-05)

`kernel/sweep.py` re-checks the kernel claims on a family of 9 finite
posets (chains, forks, trees, diamond, diamond-tail, N, crown) x 3
generator schemes x sampled valuations — 159 baseline models — then drops
each hypothesis in turn, including the two Grothendieck axioms themselves
(pullback stability; transitivity), extending "the ledger's debts are the
theorem hypotheses" to the site axioms. All paper-asserted claims hold on
every baseline model.

New results (machine-found, hand-verified):

- **lem:pers consumes exactly pullback stability.** Countermodel: tree2
  with the dense-but-restriction-unstable "skew" generator
  {00,01,1,10,11} on r, valuation a={00}: r forces `(a&a) | ~a` but its
  refinement 0 does not, because the pullback {00,01} is dense below 0
  yet uncovered without the pullback axiom; restoring the axiom repairs
  it (7/159 mutated models break). Conversely persistence survived
  dropping M-Pers (213 models), generator density (105), and
  transitivity (159): the E7a "sharper than the ledger" note, now swept —
  persistence is a topology fact carried by one axiom.
- **Minimal-carrier lemma (finite).** With a persistent valuation, every
  minimal element forces exactly its classical truth under any topology
  containing maximal sieves, and a maximal filter agrees with its minimal
  element; hence the finite branch truth lemma cannot be broken by
  shrinking J (only by non-persistent valuations, 168/213 breaks, or by
  topology-inflating non-dense generators, 105/105). This sharpens the
  E6 "finite trees trivialize genericity" note to all finite posets and
  localizes it: the minimal element alone carries the lemma.
- **lem:dec is finitely unfalsifiable** for the same reason (minimals
  decide every formula), so its sweep cell is marked vacuous rather than
  reported as evidence.
- **pos-transfer is valuation-free** (213 models, incl. non-persistent):
  the positive-fragment adm=>nn transfer never consulted M-Pers.
- Separation census: J_adm strictly below J_nn and bivalence gaps track
  the generator scheme (leaf: never strict; skew/void: mostly strict),
  quantifying how calibration coarseness, not poset shape, drives the
  paper's expected separations.

Scope honesty: conj:exportability-correlates-with-regime and
conj:residue-contract-break consume the interface/empirical layer and are
not attackable in this vocabulary; a finite interface model is the
missing instrument.

## 0d. Finite interface model (2026-07-05)

`kernel/interface_model.py` builds the missing instrument against the
VERBATIM statements of Principia Symbolica Book 7 (read from
`C:/src/principia/bib/principia_atlas.json`, all bound nodes
proof_status=proven) and the forcing paper's interface layer. First
cross-repo anchors: bindings.json now carries dual-source statement
hashes (forcing atlas + principia atlas, same normalization), so drift in
either corpus is a loud `BINDING_STALE`.

Results (all proven-statement realizations PASS):

- **I1** budget-limited minimizer unique for p>1, with an explicit
  non-uniqueness witness at p=1 (median tie): the theorem's open interval
  (1,∞) is load-bearing at its edge.
- **I2** Lyapunov interpolation + norm-continuity along the sweep — bridge
  part (i) in miniature.
- **I3** the double-site family F_κ(r) = |r−1|^p + |r+1|^p − κr² has
  exact κ*(p) = p(p−1); swept along p(ξ): κ below threshold → NO interior
  transition (41 points); κ = 4 crossing → minimizer ceases to be unique
  at ξ = 0.633 vs predicted ξ_c = 0.640 (one grid step), single flip.
  Bridge part (iii) + the no-interior-transition corollary, realized and
  threshold-located.
- **I4** contextuality defect Φ_nc(2) ≈ 4e−16 (Parseval), strictly
  positive off the cross-section (0.13–0.36 at p ∈ {1, 1.5, 2.5, 3}) —
  non-contextuality forces Hilbert, finitely.
- **I5** exportability × regime (DATA — the conjecture is status C):
  corr(smooth, χ) = 0.43 over 152 trajectories with the canonical
  floor-stable channel, and BOTH conjecture directions carry a
  displacement-scale caveat: short paths are smooth in any direction
  (smooth ⇏ high χ, 14 witnesses), and long aligned paths still cross the
  break (high χ ⇏ smooth, 40 witnesses, e.g. d=2.0 θ=75° χ=0.966).
  **Refinement suggested by the model: state the conjecture per unit
  displacement (rate form)** — in the miniature the rate correspondence
  χ = sin θ, margin burn = d·cos θ is exact.
- **I6** frame-temperature composite realized consistently (ξ strictly
  increasing, p strictly decreasing, limits ∞/1, unique ξ* = 1 with
  p = 2). Consistency realization only: p(ξ) is posited, not derived —
  the derivation is the manuscript's.

Correction to secondhand summaries recorded: the sweep variable is ξ (not
p), p(ξ) is strictly decreasing with full range (1,∞) — the [1,2] segment
is only the hot side; and the emergent exponent arises from a
‖DR‖_g ≤ B budget — a Lipschitz-budget contract, the same form as
lem:margin's path budget.

---

The v14 findings below are retained as the historical record the repairs
answer to.

---

# v14 findings (historical)

## 1. Dependency cycles (loop detector, fatal)

- **`defi:refinement ↔ lem:margin`** — the definition of the channel-margin
  subposet P_H^eta cites Lemma margin's step bound and margin guarantee;
  the lemma's proof concludes closure of P_H^eta. Combined with the broken
  induction inside lem:margin (single-step Weyl bound does not iterate:
  from lambda >= eta/2 the next step only gives lambda >= 0), this is the
  paper's most serious defect. *Repair:* define the step bound standalone;
  state margin as a one-step lemma; derive descent-uniform margin from the
  Lyapunov budget of lem:cauchy (total displacement <= eta/(2 L_Gamma)).
- **`def:closure ↔ lem:atomic`** — D_p^* is defined via "the atomic
  stability sets of Lemma atomic" while lem:atomic's statement quantifies
  over D_p^*. Not viciously circular (the definition needs only the *sets*,
  not the lemma's truth) but a formalization must reorder: define atomic
  stability sets first, then D_p^*, then the lemma.
- **`lem:dec ↔ lem:reach`** — mutual statement references. The dec→reach
  direction is a parenthetical; move it to a remark and the cycle breaks.

## 2. Forward definition references (fatal)

- `defi:refinement` (lines 92–97) → `lem:margin` (line 316)
- `def:closure` (lines 399–405) → `lem:atomic` (449) and `lem:dec` (500)
- `lem:reach` (380–388) → `lem:dec` (500)

## 3. Smuggled / unanchored assumptions

- **`C-smooth-ii`** ("contract (ii)"): consumed by lem:reach and, transitively,
  by lem:atomic, lem:bivalence, thm:prop; first occurs in unanchored prose
  (line 268), with its semantic content in the remark after lem:margin.
  *Repair:* promote to a numbered Assumption environment.
- `C-calibration-queue` and `M-observer-bound` likewise live only in prose.

## 4. Status-ledger violations

- **Legend:** `P/design` (def:wit) and `P cond. on C` (lem:reach,
  lem:bivalence) are not in the declared {P, M, C, O} legend, violating the
  ledger's own "exactly one status" rule. *Repair:* extend legend to
  {P, D, S, M, C, O}.
- **NO_PROOF_MARKED_P (10 rows):** def:site, def:wit, lem:bdd, lem:reach,
  lem:bivalence, lem:void, thm:factor, prop:chi, lem:bw, prop:dich are
  P-family with no proof environment. Some are honest (lem:bw cites
  Bourbaki–Witt; lem:void's argument is embedded in its statement) but the
  ledger cannot distinguish these mechanically until proofs are housed in
  proof environments or statuses downgraded (def:site/def:wit → D;
  thm:factor → D pending a definition of "transfer"; lem:bdd → M with a
  P corollary).
- **UNDERCOUNTED_CONSUMES (6 rows):** transitive closure adds assumptions
  the Consumes column omits — most importantly **thm:prop and lem:bivalence
  silently consume M-Pers and C-smooth-ii**, and lem:atomic consumes
  C-smooth-ii through def:closure → lem:reach. The ledger's footnote about
  M-Pers's blast radius is correct but the per-row cells do not reflect it.
- **UNLEDGERED:** `lem:pers` (Persistence and consistency — load-bearing for
  thm:prop) and `prop:chalked` have no ledger rows at all.

## 5. Finite model checker results (7-condition spine model, 5,552 formulas)

Model: full binary tree of depth 2; atoms a = left subtree, b = leaves;
J_adm generated by the single dense requirement "everything below the root".

**Verified (the paper's unconditional claims hold on the model):**
- lem:sitebound (J_adm ⊆ J_nn) — PASS, with a strictness witness: the
  leaf sieve on the root is J_nn-dense but not a J_adm-cover.
- lem:pers (persistence) — PASS for both relations, all formulas.
- Positive-fragment transfer ||-_adm ⇒ ||-_nn — PASS (100%).
- lem:dec (deciding sets order-dense) — PASS for all 5,552 formulas.
- thm:prop truth lemma on every generic branch — PASS for J_nn.

**Separations (quantifying what the calibrated site does NOT give you):**
- **Torsion-¬ vs clause-¬ are inequivalent: 1,264 divergences; minimal
  countermodel φ = ¬b at the root** (no condition forces ¬b, so the
  clause-negation holds, but Stab(·,¬¬b) fails at every non-leaf). The
  claim in the torsion remark that discharges calibration item 6 equates
  these two semantics; they agree on atoms but not on compounds. Item 6
  is *not* discharged as stated.
- **Decision Reachability fails concretely:** D_b (the deciding set for
  atom b) is not a J_adm-cover of the root, and the root forces neither a
  nor ¬a under ||-_adm — a bivalence failure at an interior node. This
  confirms the paper's own conditionality claim and gives it a 7-element
  witness.
- Reverse transfer ||-_nn ⇒ ||-_adm fails on 22% of positive-formula
  instances; only 183/5,552 formulas are hereditarily calibrated on this
  model. "Calibration" is a strong property, not a formality.

**Mutations (blast radius, executed):**
- Dropping M-Pers (non-refinement-closed valuation): clause-level
  persistence **survives** (it follows from pullback stability of the
  topology alone) while the truth lemma breaks. Sharper than the paper's
  ledger note: **M-Pers's true blast radius is lem:atomic's (⇒) direction,
  not lem:pers.** lem:pers's "atomic from Adm(q) ⊆ Adm(p)" step is both
  unnecessary and cites an undefined symbol.
- Injecting a non-dense generator: J ⊆ J_nn fails and formulas become
  forced without dense stabilization — admissible density of generators is
  load-bearing for lem:sitebound exactly as claimed.

**Caveat:** finite trees trivialize genericity (every leaf decides every
formula), so E6 validates the truth-lemma induction, not Rasiowa–Sikorski
content. The truth lemma also passes for J_adm on this model *for that
reason alone* — the reachability obstruction shows up at interior nodes
(E5), which is where an infinite/leafless model would break bivalence on
actual generics.

## 6. Not yet mechanized (from the audit report, still open)

- Truncated formula in prop:chi (the oblique-projection bound ends in
  literal `\ldots`) — needs a real inequality or deletion.
- Type errors: E_A declared on the condition poset but applied to metric
  states; Adm(·) undefined; D_φ vs the "(certificate transitions and
  voids)" typing of admissible dense requirements.
- thm:prop's ∨(⇐) step appeals to covers not in the countable generic
  family; route through deciding sets instead.
- Lean kernel (Site → Forcing → Generic → Transport/Descent/Deparam) —
  blocked on the v15 repairs above.
