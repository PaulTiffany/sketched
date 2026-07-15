/-
Poetry.lean — the operator-poetry carrier (ledger LPS-O5, poetry
included).

The four Principia operator poems (operatio, integratio, temperatio,
executio) enter the Lean layer here as CARRIER STRUCTURE, never as truth
claims. Per the author's design note: the operator poetry is the fuzzy
calculus with the parameterization reduced to zero — "spinor proofing."
This module realizes exactly that reading:

  * the carrier is the CRISP (zero-parameter) skeleton: a finite concept
    vocabulary and the poems' lowered implication edges, transcribed
    verbatim from the Come lowering (C:/src/Come/examples/
    principia_poetry/*_narsese.txt, the same seeds the live ONA runs
    consumed);
  * composition is fuel-bounded reachability over the edge lists — the
    one law the carrier asserts. Definitional bindings in the raw
    notation (S := R(∂), M' := R(M ⊕ S_V)) are NOT edges, matching the
    lowering; the poems' graphs are deliberately disconnected at
    operator-application points;
  * ORIENTATION IS NEVER QUOTIENTED (the spinor discipline, and the
    repo's non-normalized-forms rule): forward composition
    (`Reaches`), converse traversal (`transpose`), and common-source
    abduction (`CommonSource`) are three DIFFERENT carrier relations. A
    symmetrized graph would collapse them — that collapse is precisely
    the flattening the design avoids;
  * the external semantic witness stays external: the Come/ONA
    derivations (cross-seed bridge at deduction confidence 0.81, the
    drift⇒freedom hypothesis at 0.45, priorities ~0.111) are substrate
    events recorded in dark local traces, NOT carrier content. What IS
    carried: the NAL truth-function arithmetic those numbers decompose
    under (`deduction_conf`, `abduction_conf`), as bare real arithmetic.

Machine-checked carrier facts (all by kernel evaluation over the
transcribed edge lists):

  * `bridge_needs_both` — the cross-seed composition
    emergence_of_structure ⇝ wave exists in operatio ∪ executio and in
    NEITHER seed alone: the composition ONA derived only in the combined
    run, now a carrier theorem;
  * `negations_respected` — the quartet's positive fragment never
    reaches what the poems explicitly negate (∂ ⊬ U_∅, frozen ⊬ novum,
    uniform ⊬ verum): the carrier is consistent with its own negative
    space;
  * `drift_freedom_not_forward` + `drift_freedom_commonSource` — the
    full poetic arc drift ⇒ freedom is NOT a forward path but IS a
    common-source abduction (through U_∅): the carrier distinguishes
    the hypothesis's epistemic type exactly as the substrate did;
  * `gibbs_zero_uniform` — the one genuine cross-link: temperatio's
    middle line ρ_β := Z⁻¹e^{−βH} is LITERALLY Book2.gibbs, and its
    β → 0 boundary claim (`unif`) is a theorem of the finite Gibbs
    kernel. The poem and the thermodynamics share an object. The β → ∞
    freezing line (δ_argmin) is a concentration limit and stays open.

Fuel note: `Reaches` is fuel-8 reachability. Every positive witness in
these graphs has length ≤ 4 and all four seed graphs are acyclic with
maximum simple path length 4, so fuel 8 is stable margin; the bound is
part of the carrier's definition, stated rather than hidden.
-/

import Mathlib
import ForcingAnalysis.Book2

namespace ForcingAnalysis.Poetry

/-- The poems' concept vocabulary — the vertices of the lowered graphs,
verbatim from the Come lowering. -/
inductive Concept where
  | emptyUniverse | drift | reflectionOfDrift | structura
  | emergenceOfStructure | operator
  | wave | resonance | freedom
  | generativeHorizon | pool | secondDiffPool | viable | excess
  | dissipativeHorizon | reflectionOfViable | revisedMemory
  | zeroTemperature | frozenState | novelty
  | infiniteTemperature | uniformState | verum
  | finiteTemperature | temperedMeasure
  deriving DecidableEq, BEq, Repr

open Concept

/-- An edge list: the crisp implication fragment of one seed. -/
abbrev Edges := List (Concept × Concept)

/-- operatio's lowered edges (operatio_narsese.txt): U_∅ ⊢ ∂;
S := R(∂) yields structure; O := E(S) — bindings are not edges. -/
def operatio : Edges :=
  [(emptyUniverse, drift),
   (reflectionOfDrift, structura),
   (emergenceOfStructure, operator)]

/-- executio's lowered edges: O ⇝ ψ ⇝ ∼ ⇝ F, plus the compressed arc
U_∅ → F as its own single edge. -/
def executio : Edges :=
  [(operator, wave),
   (wave, resonance),
   (resonance, freedom),
   (emptyUniverse, freedom)]

/-- integratio's lowered edges: H_G ⇀ P; δ²P ⊢ S; S = S_V ⊕ S_∖;
S_∖ ⇀ H_D; M' := R(M ⊕ S_V) — the binding again not an edge. -/
def integratio : Edges :=
  [(generativeHorizon, pool),
   (secondDiffPool, structura),
   (structura, viable),
   (structura, excess),
   (excess, dissipativeHorizon),
   (reflectionOfViable, revisedMemory)]

/-- temperatio's lowered edges: the Gibbs phase diagram as poetry —
β → ∞ freezes, β → 0 uniformizes, finite β tempers and liberates. -/
def temperatio : Edges :=
  [(zeroTemperature, frozenState),
   (infiniteTemperature, uniformState),
   (finiteTemperature, temperedMeasure),
   (temperedMeasure, freedom)]

/-- The poems' explicit negations: ∂ ⊬ U_∅ (operatio), frozen ⊬ novum
and uniform ⊬ verum (temperatio). -/
def negations : Edges :=
  [(drift, emptyUniverse),
   (frozenState, novelty),
   (uniformState, verum)]

/-- The full four-poem cycle. -/
def quartet : Edges := operatio ++ integratio ++ temperatio ++ executio

/-- Fuel-bounded forward reachability — the carrier's one composition
law. Fuel 8 exceeds every simple path in these acyclic seed graphs. -/
def reachB : Nat → Edges → Concept → Concept → Bool
  | 0, _, a, b => a == b
  | n + 1, E, a, b =>
      a == b || E.any fun e => e.1 == a && reachB n E e.2 b

/-- Forward composition (deduction-shaped). -/
def Reaches (E : Edges) (a b : Concept) : Prop := reachB 8 E a b = true

instance (E : Edges) (a b : Concept) : Decidable (Reaches E a b) := by
  unfold Reaches
  infer_instance

/-- Orientation reversal — kept as a separate operation, never
quotiented into the graph. -/
def transpose (E : Edges) : Edges := E.map fun e => (e.2, e.1)

/-- Common-source relation (abduction-shaped): some edge-source reaches
both. Distinct from `Reaches` and from converse traversal — the three
orientations the spinor discipline keeps apart. -/
def CommonSource (E : Edges) (a b : Concept) : Prop :=
  (E.any fun e => reachB 8 E e.1 a && reachB 8 E e.1 b) = true

instance (E : Edges) (a b : Concept) : Decidable (CommonSource E a b) := by
  unfold CommonSource
  infer_instance

/-! ### Carrier theorems -/

/-- The opening line: the empty universe yields drift. -/
theorem operatio_opening : Reaches operatio emptyUniverse drift := by decide

/-- **The cross-seed bridge** — the composition ONA derived only in the
combined run: emergence ⇝ wave exists in operatio ∪ executio and in
neither seed alone. -/
theorem bridge_needs_both :
    Reaches (operatio ++ executio) emergenceOfStructure wave ∧
      ¬ Reaches operatio emergenceOfStructure wave ∧
      ¬ Reaches executio emergenceOfStructure wave := by
  refine ⟨by decide, by decide, by decide⟩

/-- The compressed arc of executio's coda: U_∅ ⇝ F in the quartet. -/
theorem quartet_arc : Reaches quartet emptyUniverse freedom := by decide

/-- Temperatio's liberation path: finite temperature ⇝ freedom. -/
theorem tempered_freedom : Reaches quartet finiteTemperature freedom := by
  decide

/-- **Negative space respected**: the quartet's positive fragment never
reaches any explicitly negated conclusion. -/
theorem negations_respected :
    (negations.all fun p => !(reachB 8 quartet p.1 p.2)) = true := by decide

/-- The irreversibility line, singled out: drift does not restore the
void. -/
theorem no_return : ¬ Reaches quartet drift emptyUniverse := by decide

/-- The full poetic arc drift ⇒ freedom is NOT a forward composition… -/
theorem drift_freedom_not_forward : ¬ Reaches quartet drift freedom := by
  decide

/-- …but IS a common-source abduction (through the empty universe):
the carrier assigns ONA's 0.45-confidence hypothesis its exact
epistemic type. -/
theorem drift_freedom_commonSource : CommonSource quartet drift freedom := by
  decide

/-- Converse traversal is a genuinely different relation: resonance
reaches operator only in the transpose. -/
theorem converse_resonance_operator :
    Reaches (transpose executio) resonance operator ∧
      ¬ Reaches executio resonance operator := by
  refine ⟨by decide, by decide⟩

/-! ### The NAL truth-function arithmetic (substrate numbers, carried
as bare real arithmetic — the parameterization the crisp carrier sets
to zero, reintroduced only as documented constants) -/

/-- Deduction at input confidence 0.9 composes to 0.81. -/
theorem deduction_conf : (0.9 : ℝ) * 0.9 = 0.81 := by norm_num

/-- Abduction from evidence weight 0.81 lands at 81/181 (the substrate
prints 0.45). -/
theorem abduction_conf : (81 : ℝ) / 100 / ((81 : ℝ) / 100 + 1) = 81 / 181 := by
  norm_num

/-! ### The temperatio–thermodynamics identification -/

/-- **The poem's β → 0 boundary claim, machine-checked**: temperatio's
ρ_β := Z⁻¹e^{−βH} is Book2.gibbs, and at β = 0 it is exactly the
uniform state — `unif`, as the poem says. The β → ∞ freezing line
(δ_argmin) is a concentration limit and remains open. -/
theorem gibbs_zero_uniform {n : ℕ} [NeZero n] (H : Fin n → ℝ) (i : Fin n) :
    Book2.gibbs 0 H i = (n : ℝ)⁻¹ := by
  simp [Book2.gibbs, Book2.partition, Real.exp_zero, Finset.sum_const,
    Finset.card_univ]

end ForcingAnalysis.Poetry
