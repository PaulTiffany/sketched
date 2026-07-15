/-
Book8.lean - observer-relative artifacts / material projection, honest kernel.

Principia Book 8 is about observers, symbolic projections between frames,
artifact/materiality status, and the metabolic and debugging dynamics of
symbolic systems. Most anchors are stated on Banach/Riemannian symbolic
manifolds, Hilbert-space "quantum entanglement" analogies, C^1 ODE systems
(the SR-triplet), or as diagrammatic/narrative process accounts (the
observe/project/reflect/update loop, the digest/repair/synthesize/validate
cycle's internal description). This module does NOT attempt manifold,
Hilbert-space, or ODE formalizations. For each anchor it extracts the honest
static/algebraic/finite kernel instead:

  * "observer-relative artifact" / "materiality" become a genuine
    finite-observer visibility-vs-universality distinction, with an
    explicit countermodel showing visibility to one observer does not
    entail materiality across a class of observers;
  * "frame relativity of meaning" becomes a fixed-point-preservation
    conditional plus an explicit no-fixed-point countermodel (the swap on
    `Bool`) showing the "unless" clause is non-vacuous;
  * "identity stability", "translation loss", "no free projection", and the
    "bound on universal embedding" become one connected real-number
    threshold algebra: stability lives in `[0,1]`, loss is bounded below by
    `(1/2)*(1-stability)*freeEnergy`, and perfect translation
    (`epsilon = 0`) is shown to force maximal stability;
  * the three "Symbolic Reidemeister" propositions (Type I/II/III) become,
    respectively: a metric-proximity collapse bound, a four-fold
    composition-cancellation identity from two exact one-sided inverses,
    and (exact, unconditional) associativity of function composition --
    strictly stronger than the "up to an observer-bounded transformation"
    qualifier in the text, an honesty gap noted rather than hidden;
  * the "Metabolic Sufficiency Criterion" / "Threshold of Autonomy" pair
    (stated twice in the source, under two different anchors) becomes a
    finite-iteration termination bound: a free-energy sequence that is
    bounded below and strictly decreases by a fixed amount per step cannot
    continue past a computable step count;
  * "Thermodynamic Necessity" and the timing clause shared by both
    metabolic-cycle definitions become a cycle-time viability ratio;
  * the "Free-Will Corollary" becomes the direct algebraic consequence of
    its own stated expected-loss formula;
  * "Thermodynamics of Reflexive Debugging" becomes an explicit
    cost-vs-reduction net-gain inequality;
  * the "Reflective Selection Operator" becomes the existence of an argmax
    over any nonempty finite hypothesis set.

Anchors that are purely narrative/taxonomic (the observe-project-reflect-
update loop, "symbolic agents as projections", the Reflexive Debugging
Operator's own four-step definition, recursive self-tuning, the emergent
cognitive scaffold), that require Hilbert-space tensor-product entanglement
or manifold curvature (the "Quantum Decoherence"/"Entanglement" cluster),
that require C^1 ODE systems or Lyapunov/RG convergence (the SR-triplet
dynamics, SR convergence, the RG fixed point, the hypothesis-manifold PDE),
or that require differential-geometric rank/dimension equalities with no
underlying linear-algebra model (the Freedom Emergence Criterion and its
meta-metabolic variant) are left unformalized and listed as open anchors in
the accompanying proposal, rather than forced into decorative theorems.
-/

import Mathlib
import ForcingAnalysis.Book2
import ForcingAnalysis.Book5Thermodynamics

namespace ForcingAnalysis.Book8

/- ================================================================
   definition:bk8_observer_relative_artifact,
   definition:bk8_material_projection
   ================================================================ -/

/-- An artifact's claimed invariant relative to a class of observers/frames
`O` (definition:bk8_observer_relative_artifact): `invariant o` records
whether the artifact is observed to hold for observer/frame `o`. The
projection map itself and "bounded symbolic interval" persistence are not
modeled; only the observer-indexed invariant claim is. Materiality
(definition:bk8_material_projection) is exactly universal quantification
over the admissible observer class: the invariant holds for *every*
admissible observer/frame, not merely some. -/
abbrev Material {O : Type} (invariant : O → Prop) : Prop :=
  ∀ o, invariant o

theorem material_specialize {O : Type} {invariant : O → Prop}
    (h : Material invariant) (o : O) : invariant o :=
  h o

/-- The invariant `i = 0` on the two-observer class `Fin 2` is visible to
observer `0`. -/
theorem visible_to_observer_zero : (fun i : Fin 2 => i = 0) (0 : Fin 2) :=
  rfl

/-- But that same invariant is not material over `Fin 2`: visibility to one
observer does not entail cross-observer stability
(definition:bk8_material_projection: "materiality is cross-observer
artifact stability, not visibility to all possible observers"). -/
theorem not_material_visible_example :
    ¬ Material (fun i : Fin 2 => i = 0) := by
  decide

/- ================================================================
   definition:bk8_transform_group, axiom:bk8_binding_curvature_limit
   ================================================================ -/

/-- `x` is a fixed point of the frame transform `g`
(definition:bk8_transform_group). -/
abbrev IsFixedPoint {X : Type} (g : X → X) (x : X) : Prop := g x = x

/-- Meaning is preserved at fixed points of the transform group
(axiom:bk8_binding_curvature_limit, the "unless" clause). -/
theorem meaning_preserved_at_fixed_point {X M : Type} (g : X → X) (meaning : X → M)
    {x : X} (hfix : IsFixedPoint g x) : meaning (g x) = meaning x := by
  unfold IsFixedPoint at hfix
  rw [hfix]

/-- The swap on `Bool` has no fixed points, so its "frame transform" moves
every point away from itself: an explicit witness that the generic case of
axiom:bk8_binding_curvature_limit (meaning genuinely differs off the
fixed-point set) is non-vacuous rather than empty. -/
theorem bool_swap_no_fixed_points : ∀ b : Bool, ¬ IsFixedPoint (fun x => !x) b := by
  decide

/- ================================================================
   corollary:bk8_projective_drift
   ================================================================ -/

/-- corollary:bk8_projective_drift's punchline: if `r` genuinely inverts
`d` pointwise, `r` cannot also be a constant map on a domain with at least
two distinct points. This is the honest algebraic content of "the inverse
of the expanded drift is not stasis but contextual reexpression": a true
inverse is forced to vary with its input. -/
theorem inverse_of_drift_not_stasis {X : Type} {x1 x2 : X} (hne : x1 ≠ x2)
    (d r : X → X) (hinv : ∀ x, r (d x) = x) (c : X) :
    ¬ ∀ x, r (d x) = c := by
  intro h
  have h1 : c = x1 := (h x1).symm.trans (hinv x1)
  have h2 : c = x2 := (h x2).symm.trans (hinv x2)
  exact hne (h1.symm.trans h2)

/- ================================================================
   definition:bk8_identitystability, definition:bk8_translation_loss,
   theorem:bk8_no_free_projection, corollary:bk8_translation_limit,
   corollary:bk8_bound_on_universal_embedding,
   corollary:bk8_universality_condition
   ================================================================ -/

/-- The scalar law underlying theorem:bk8_no_free_projection: identity
stability lives in `[0,1]` (definition:bk8_identitystability), and
translation loss (definition:bk8_translation_loss) under any nontrivial
projection is bounded below by `(1/2)*(1-stability)` times the free energy
of the symbolic object being projected. The "dense subset" qualifier of the
source theorem is dropped: the bound is kept as a law required to hold for
every `phi`, the honest static content once the manifold/topology is
erased. -/
structure ProjectionLossLaw where
  freeEnergy : Real → Real
  loss : Real → Real
  stability : Real
  stability_nonneg : 0 ≤ stability
  stability_le_one : stability ≤ 1
  loss_bound : ∀ phi, loss phi ≥ (1 / 2) * (1 - stability) * freeEnergy phi

/-- corollary:bk8_translation_limit: whenever stability is not maximal, any
symbolic object with positive free energy incurs strictly positive
translation loss under projection ("all projection implies symbolic loss,
unless a shared reflective operator exists"). -/
theorem loss_positive_of_imperfect_stability (L : ProjectionLossLaw)
    (hstab : L.stability < 1) {phi : Real} (hF : 0 < L.freeEnergy phi) :
    0 < L.loss phi := by
  have hbound := L.loss_bound phi
  have h1 : 0 < 1 - L.stability := by linarith
  have h2 : 0 < (1 - L.stability) * L.freeEnergy phi := mul_pos h1 hF
  nlinarith [hbound, h2]

/-- The `epsilon`-bound of corollary:bk8_bound_on_universal_embedding, kept
as a structure field rather than derived from a `sup`/`inf` over projections
(no topology on the space of projections is modeled): any claimed universal
embedding distortion `epsilon` (corollary:bk8_universality_condition) must
dominate `(1/2)*(1-stability)`. -/
structure UniversalEmbeddingBound where
  epsilon : Real
  stability : Real
  stability_nonneg : 0 ≤ stability
  stability_le_one : stability ≤ 1
  epsilon_bound : epsilon ≥ (1 / 2) * (1 - stability)

/-- corollary:bk8_universality_condition's consequence: the embedding
distortion is always nonnegative. (Only this consequence is modeled; the
embedding-existence claim itself, `forall S_i, exists Pi_i : ...`, is not.) -/
theorem universal_embedding_epsilon_nonneg (u : UniversalEmbeddingBound) :
    0 ≤ u.epsilon := by
  linarith [u.epsilon_bound, u.stability_le_one]

/-- corollary:bk8_bound_on_universal_embedding's punchline: perfect
translation (`epsilon = 0`) is impossible unless identity stability is
maximal. -/
theorem perfect_translation_forces_maximal_stability (u : UniversalEmbeddingBound)
    (heps : u.epsilon = 0) : u.stability = 1 := by
  have h := u.epsilon_bound
  rw [heps] at h
  have hge : 1 ≤ u.stability := by linarith
  exact le_antisymm u.stability_le_one hge

/- ================================================================
   theorem:bk8_holographic_surface_entropy
   ================================================================ -/

/-- The residual of theorem:bk8_holographic_surface_entropy, defined
directly from the stated equation. The "identical symbolic expressivity"
characterization of when the residual vanishes is not modeled; only the
algebraic rearrangement is. -/
def frameResidual {X : Type} (Pi1 Pi2 : X → Real) (T : Real → Real) (x : X) : Real :=
  Pi2 x - T (Pi1 x)

theorem frameResidual_eq_zero_iff {X : Type} (Pi1 Pi2 : X → Real) (T : Real → Real) (x : X) :
    frameResidual Pi1 Pi2 T x = 0 ↔ Pi2 x = T (Pi1 x) := by
  unfold frameResidual
  constructor
  · intro h; linarith
  · intro h; linarith

/- ================================================================
   axiom:bk8_symbolic_reidemeister_algebra (the Type I/II/III propositions
   below are worked instances of the general finite-rule-set claim; the
   general "any entangled structure with bounded recursion depth reduces
   via finite applications of {U_i}" existence claim itself is not proved,
   only these three concrete rules are)
   ================================================================ -/

/- ================================================================
   proposition:bk8_membrane_identity_collapse (Type I)
   ================================================================ -/

/-- Type I collapse data (proposition:bk8_membrane_identity_collapse): the
composite `R ∘ D` is within `eps` of the identity at every point, and `eps`
is strictly below the observer's local collapse threshold at every point. -/
structure LocalReflectionCollapse (X : Type) [PseudoMetricSpace X] where
  drift : X → X
  reflect : X → X
  eps : Real
  approx : ∀ x, dist (reflect (drift x)) x ≤ eps
  threshold : X → Real
  eps_lt_threshold : ∀ x, eps < threshold x

/-- The collapsed loop stays strictly within the observer's threshold of
the identity. -/
theorem collapse_within_threshold {X : Type} [PseudoMetricSpace X]
    (c : LocalReflectionCollapse X) (x : X) :
    dist (c.reflect (c.drift x)) x < c.threshold x :=
  lt_of_le_of_lt (c.approx x) (c.eps_lt_threshold x)

/- ================================================================
   proposition:bk8_observer_frame_invariance (Type II)
   ================================================================ -/

/-- Type II drift cancellation (proposition:bk8_observer_frame_invariance):
if `R_mu` exactly undoes `D_mu` and `D_lam` exactly undoes `R_lam` (the
honest kernel of "opposite reflective directions form a stable braid"), the
four-fold composite collapses to the identity. -/
theorem drift_cancellation {X : Type} (D_lam D_mu R_lam R_mu : X → X)
    (hmu : ∀ x, R_mu (D_mu x) = x) (hlam : ∀ x, D_lam (R_lam x) = x) (x : X) :
    D_lam (R_mu (D_mu (R_lam x))) = x := by
  rw [hmu (R_lam x), hlam x]

/- ================================================================
   proposition:bk8_membrane_operator_symmetry (Type III)
   ================================================================ -/

/-- Type III reflective permutation (proposition:bk8_membrane_operator_symmetry):
composition of the three drift-reflection fields is exactly associative,
unconditionally -- strictly stronger than the source's "up to an
observer-bounded transformation `T_epsilon`" qualifier, which is dropped
here as an honesty gap rather than modeled. -/
theorem reflective_permutation_assoc {X : Type} (Da Db Dg : X → X) :
    (Da ∘ Db) ∘ Dg = Da ∘ (Db ∘ Dg) :=
  rfl

/- ================================================================
   definition:bk8_symbolic_adjacency, axiom:bk8_mutation_phase_shift,
   theorem:bk8_biological_phase_transition,
   theorem:bk8_threshold_of_metabolic_autonomy
   ================================================================ -/

/-- Metabolic sufficiency data (axiom:bk8_mutation_phase_shift): a knot's
free energy sequence (definition:bk8_symbolic_adjacency models only the
"high symbolic free energy" framing of a knot via nonnegativity of `F`; the
`Xi`-threshold and the "unstable recursive structure" narrative are not
modeled) is nonnegative and strictly decreases by a fixed positive amount
at every repair step. -/
structure MetabolicSufficiency where
  freeEnergy : Nat → Real
  freeEnergy_nonneg : ∀ k, 0 ≤ freeEnergy k
  deltaF : Real
  deltaF_pos : 0 < deltaF
  decreasing : ∀ k, freeEnergy (k + 1) ≤ freeEnergy k - deltaF

/-- Telescoped decrease bound, by induction on the number of repair steps. -/
theorem metabolicSufficiency_decrease_accum (m : MetabolicSufficiency) (n : Nat) :
    m.freeEnergy n ≤ m.freeEnergy 0 - (n : Real) * m.deltaF := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep := m.decreasing k
      have hcast : ((k + 1 : Nat) : Real) * m.deltaF = (k : Real) * m.deltaF + m.deltaF := by
        push_cast; ring
      rw [hcast]
      linarith

/-- theorem:bk8_biological_phase_transition / theorem:bk8_threshold_of_metabolic_autonomy
(the same claim, stated twice in the source under two different anchors):
metabolic sufficiency forces termination within a computable number of
steps -- a nonnegative free-energy sequence cannot keep decreasing by a
fixed positive amount forever. This is the finite/discrete honest kernel of
the source's `limsup`/exponential-convergence claim, which is not modeled. -/
theorem metabolicSufficiency_terminates (m : MetabolicSufficiency) (n : Nat)
    (hn : m.freeEnergy 0 < (n : Real) * m.deltaF) : False := by
  have hacc := metabolicSufficiency_decrease_accum m n
  have hnn := m.freeEnergy_nonneg n
  linarith

/- ================================================================
   theorem:bk8_thermodynamic_necessity_of_symbolic_metabolism,
   definition:bk8_metabolic_programming_cycle,
   definition:bk8_recursive_symbolic_metaboloic_cycle
   ================================================================ -/

/-- The timing-viability clause shared by definition:bk8_metabolic_programming_cycle,
definition:bk8_recursive_symbolic_metaboloic_cycle, and
theorem:bk8_thermodynamic_necessity_of_symbolic_metabolism: the cycle
completion time is strictly less than the destabilization time. Only this
scalar inequality is modeled; the four-step digest/repair/synthesize/validate
internal structure of the cycle is not. -/
structure CycleViability where
  tauOmega : Real
  tauDrift : Real
  tauDrift_pos : 0 < tauDrift
  viable : tauOmega < tauDrift

theorem cycleViability_ratio_lt_one (c : CycleViability) :
    c.tauOmega / c.tauDrift < 1 := by
  rw [div_lt_one c.tauDrift_pos]
  exact c.viable

/- ================================================================
   corollary:bk8_symbolic_free_will
   ================================================================ -/

/-- The expected-loss law of corollary:bk8_symbolic_free_will, kept as a
structure field. The volitional projection operator itself
(definition:bk8_volitional_projection_operator) and the rank/dimension
"Freedom Emergence Criterion" it depends on are not modeled; only the
stated arithmetic consequence of the expected-loss formula is. -/
structure FreeWillLoss where
  stability : Real
  stability_nonneg : 0 ≤ stability
  stability_le_one : stability ≤ 1
  lossId : Real
  lossId_nonneg : 0 ≤ lossId
  lossVol : Real
  loss_eq : lossVol = (1 - stability) * lossId

/-- Volitional projection never loses more than passive (identity)
projection. -/
theorem freeWillLoss_le (f : FreeWillLoss) : f.lossVol ≤ f.lossId := by
  have hprod : 0 ≤ f.stability * f.lossId := mul_nonneg f.stability_nonneg f.lossId_nonneg
  rw [f.loss_eq]
  nlinarith [hprod]

theorem freeWillLoss_nonneg (f : FreeWillLoss) : 0 ≤ f.lossVol := by
  have h1 : 0 ≤ 1 - f.stability := by linarith [f.stability_le_one]
  rw [f.loss_eq]
  exact mul_nonneg h1 f.lossId_nonneg

/- ================================================================
   theorem:bk8_observer_projection_tensor
   ================================================================ -/

/-- The cost/benefit ledger of theorem:bk8_observer_projection_tensor: the
Reflexive Debugging Operator's own free-energy cost, and the free-energy
reduction obtained from resolving the knot. -/
structure DebuggingThermodynamics where
  costOp : Real
  costOp_nonneg : 0 ≤ costOp
  reduction : Real
  reduction_nonneg : 0 ≤ reduction

/-- Debugging is thermodynamically favored exactly when the reduction
offsets the operator's own cost. -/
def DebuggingFavored (d : DebuggingThermodynamics) : Prop :=
  d.costOp ≤ d.reduction

theorem debuggingFavored_net_gain (d : DebuggingThermodynamics)
    (h : DebuggingFavored d) : 0 ≤ d.reduction - d.costOp := by
  unfold DebuggingFavored at h
  linarith

/-- Regard Book 2's finite ensemble as the Book 5 thermodynamic snapshot
with coherent energy `⟨H⟩ρ`, temperature `β⁻¹`, and Book 2 entropy. -/
noncomputable def finiteThermodynamicSnapshot {n : Nat} (β : Real)
    (H ρ : Fin n → Real) : Book5.ThermodynamicSnapshot where
  coherentEnergy := ∑ i, ρ i * H i
  temperature := β⁻¹
  entropy := Book2.entropy ρ

/-- The Book 2 and Book 5 free-energy expressions agree definitionally at
this interface. -/
theorem finiteThermodynamicSnapshot_freeEnergy {n : Nat} (β : Real)
    (H ρ : Fin n → Real) :
    Book5.freeEnergy (finiteThermodynamicSnapshot β H ρ) =
      Book2.freeEnergy β H ρ := rfl

/-- Apply a Book 8 debugging ledger to the coherent-energy component of the
Book 2/5 snapshot: reduction is recovered energy and `costOp` is its cost. -/
noncomputable def debuggedFiniteSnapshot {n : Nat} (β : Real) (H ρ : Fin n → Real)
    (d : DebuggingThermodynamics) : Book5.ThermodynamicSnapshot :=
  { finiteThermodynamicSnapshot β H ρ with
    coherentEnergy := (∑ i, ρ i * H i) + d.reduction - d.costOp }

/-- Book 2 → Book 5 → Book 8: positive finite free energy gives Book 5
viability, and any Book 8 debugging step with nonnegative net gain preserves
that viability in the adjusted snapshot. -/
theorem debugging_preserves_finite_viability {n : Nat} (β : Real)
    (H ρ : Fin n → Real) (d : DebuggingThermodynamics)
    (hfree : 0 < Book2.freeEnergy β H ρ) (hfavored : DebuggingFavored d) :
    Book5.Viable (debuggedFiniteSnapshot β H ρ d) := by
  have hgain := debuggingFavored_net_gain d hfavored
  unfold Book5.Viable Book5.freeEnergy debuggedFiniteSnapshot
    finiteThermodynamicSnapshot
  unfold Book2.freeEnergy at hfree
  dsimp
  linarith
/- ================================================================
   definition:bk8_reflective_selection_operator
   ================================================================ -/

/-- The reflective selection operator (definition:bk8_reflective_selection_operator)
picks an argmax of `confidence - loss` over the hypothesis set. The honest
finite kernel is that such an argmax exists whenever the hypothesis set is
a nonempty finite set; the "Bayesian update rule" reading of iterating this
choice over time is not modeled. -/
theorem reflectiveSelection_exists {ι : Type} (H : Finset ι)
    (hH : H.Nonempty) (confidence loss : ι → Real) :
    ∃ h ∈ H, ∀ h' ∈ H, confidence h' - loss h' ≤ confidence h - loss h :=
  H.exists_max_image (fun i => confidence i - loss i) hH

end ForcingAnalysis.Book8
