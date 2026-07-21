/-
ScholiumA.lean - Principia Symbolica Scholium Symbolicum, first half, honest kernel.

This slice is meta-commentary: statements that restate or connect results
across Book I (bounded observers, drift/reflection operators, observer
interpretability, stage-composite emergence, symbolic contradiction and
curvature framing, linear-vs-quadratic symbolic coupling). Being
meta-commentary, the yield of genuinely formalizable content is low by
design. Most anchors are stated on categorical colimits over ordinal-indexed
diagrams (the stage tower `P_λ`, `Ob(catS)`), Riemannian/manifold curvature
(the symbolic Riemann tensor, Christoffel symbols, parallel transport and
holonomy), Hilbert/Lie-derivative machinery, or general asymptotic constructions. This module does NOT attempt
category-theoretic colimit, manifold/curvature, or Hilbert-space
formalizations; it now does model the specific summable-resolution/Cauchy
completion theorem used downstream by Book 4. For each anchor
it extracts the honest static/algebraic/finite kernel instead:

  * "bounded observer" / "kernel-based bounded symbolic approximation" /
    "boundedness from drift" / the "sufficient condition" proposition
    collapse to one scalar inequality chain: a drift magnitude bounded by
    `δ`, pushed through a norm-one kernel via a stated submultiplicativity
    hypothesis, stays bounded by `δ`;
  * "observer-relative interpretability" (the (I1)-(I3) sandwich) and the
    "bounded approximation implies interpretability" lemma become a genuine
    inequality derivation: factoring the observed change as `c * ε` with
    `c ∈ [c_min, 1]` and `c_min * ε ≥ ν` forces `ν ≤ c*ε ≤ ε`, and pairing
    that sandwich with an explicit (finite, `Finset`-indexed) traceability
    witness reconstructs the full interpretability conjunction;
  * the "stage-composite operator" and the interpretability half of the
    "observer-bounded emergence constraint" lemma become a two-step
    triangle-inequality bound (`2δ`) on a generic `PseudoMetricSpace`;
    the stage-chain theorem includes the finite telescoping bound, then uses
    summable resolution decay to prove the path Cauchy and convergent in a
    complete observer metric, with a tail-sum displacement estimate;
  * the "reflection operator"'s two typed components become concrete
    witnessed instances: an involutive, inner-product-preserving map on
    `Real × Real` that is neither the identity nor its negation (the
    "mirror" component), and an idempotent map that is not the identity
    (the "stabilization" component);
  * "spinor-like" double-rotation periodicity becomes an explicit witness
    on `ZMod 4` where four applications return to start but two do not;
  * "symbolic contradiction intensity" becomes a real algebraic identity
    in terms of the opposition ratio `λ`, with the `λ = 1` case forcing
    exact cancellation;
  * "contextual meaning is non-separable" becomes a finite-difference
    (not derivative) surrogate for the mixed partial: an explicit second
    difference that vanishes on every additively separable function, so a
    nonzero second difference certifies non-separability -- this is an
    honest substitute for the source's mixed *derivative* claim, not a
    formalization of it;
  * the linear-vs-quadratic coupling cluster becomes one explicit
    countermodel: `(x,y) ↦ x*y` is not expressible as any linear coupling
    `β₀x + β₁y`, the concrete instance of "quadratic coupling exceeds
    linear coupling" that the surrounding narrative theorems assert in
    general;
  * "reflexivity requires quadratic framing" keeps only its stated
    algebraic premise, `L(x+x) = 2*L(x)` for linear `L` -- the informal
    jump from this premise to "cannot support self-reference" is a
    narrative conclusion and is not modeled;
  * "fixed point inheritance" becomes the general (linearity-free)
    algebraic fact that conjugating any map by an invertible one carries
    fixed points along; the "linear" hypothesis in the source is dropped
    as unnecessary.

Anchors that are purely categorical (the category of structures and its
cocompleteness, the directed system of emergent stages, the proto-symbolic
colimit and its universal property, the constitutive-bootstrap extraction of
an observer from a reflective closure), that require Riemannian/manifold
curvature or parallel transport (the symbolic manifold, drift field,
observer horizon structure and its PDE, symbolic connection/Christoffel
symbols/Riemann tensor, local semantic independence, curvature-as-holonomy,
curvature/semantic-entanglement, the non-Euclidean-necessity chain, the
resolution-cost geodesic distance, the dual-horizon curvature-flux
signature and its necessity theorem), that require broader asymptotic/infinite-series machinery beyond the
completed summable-resolution stage theorem, or that are narrative/taxonomic with
no residual scalar content (the observer-gradient cross-field narrative, the
Newtonian/quantum "category error" definitions, the contradiction-resolution
dimensional-bound existence claim, the quadratic-structure-necessity Taylor
expansion, the bridge-to-geometry identification, semantic non-integrability)
are left unformalized and listed as open anchors in the accompanying
proposal, rather than forced into decorative theorems.
-/

import Mathlib

namespace ForcingAnalysis.ScholiumA

/- ================================================================
   definition:bk1_bounded_observer
   ================================================================ -/

/-- A bounded observer (definition:bk1_bounded_observer): a maximal
differentiation order `N`, a family of `n`-th order internal difference
operators `delta`, and a resolution threshold `eps` (kept here as a function
of the observed state, matching the source's `eps : M → Real`). Only the
typed data is modeled; the differentiation operators themselves are treated
as opaque real-valued functions rather than manifold operators. -/
structure BoundedObserver where
  N : Nat
  delta : Nat → Real → Real
  eps : Real → Real
  eps_pos : ∀ s, 0 < eps s

/- ================================================================
   definition:bk1_bounded_symbolic_approximation,
   definition:bk1_kernel_based_bounded_symbolic_approximation,
   proposition:bk1_boundedness_from_drift,
   proposition:bk1_sufficient_condition_for_kernel_boundedness_from_uniform_drift_bound
   ================================================================ -/

/-- The scalar law shared by all four anchors above: a drift magnitude
bounded by `δ`, pushed through a resolution kernel of `L¹`-norm `1` via a
stated submultiplicativity bound (`conv_submult`, standing in for
`‖K*D‖ ≤ ‖K‖₁ * ‖D‖` since convolution itself is not modeled), stays bounded
by `δ`. This is the honest arithmetic core of the source's convolution
proof, kept as a structure of hypotheses rather than a derivation from an
actual convolution operator. -/
structure KernelBoundedApprox where
  drift : Real
  kernelNorm1 : Real
  kernelNorm1_eq_one : kernelNorm1 = 1
  convBound : Real
  conv_submult : convBound ≤ kernelNorm1 * drift
  δ : Real
  drift_le : drift ≤ δ

theorem kernelBounded_le (k : KernelBoundedApprox) : k.convBound ≤ k.δ := by
  have h1 : k.convBound ≤ k.kernelNorm1 * k.drift := k.conv_submult
  rw [k.kernelNorm1_eq_one, one_mul] at h1
  linarith [h1, k.drift_le]

/- ================================================================
   definition:bk1_observer_relative_interpretability,
   lemma:bk1_bounded_approximation_and_interpretability,
   proposition:bk1_stage_composite_operators_are_interpretable
   ================================================================ -/

/-- Interpretability factorization data (lemma:bk1_bounded_approximation_and_interpretability):
the observed change is `c * ε` for some `c ∈ [c_min, 1]`, and the observer's
resolution satisfies `c_min * ε ≥ ν`. This is the honest scalar content from
which both the boundedness (I2) and distinguishability (I1) halves of
definition:bk1_observer_relative_interpretability are derived, rather than
assumed outright. -/
structure InterpretabilityFactor where
  eps : Real
  eps_pos : 0 < eps
  nu : Real
  c : Real
  cmin : Real
  cmin_pos : 0 < cmin
  cmin_le_c : cmin ≤ c
  c_le_one : c ≤ 1
  cmin_mul_eps_ge_nu : cmin * eps ≥ nu

/-- The observed change under the factorization. -/
def ifValue (f : InterpretabilityFactor) : Real := f.c * f.eps

/-- Boundedness (I2): the observed change never exceeds the resolution
threshold. -/
theorem ifValue_le_eps (f : InterpretabilityFactor) : ifValue f ≤ f.eps := by
  unfold ifValue
  have h : f.c * f.eps ≤ 1 * f.eps := mul_le_mul_of_nonneg_right f.c_le_one f.eps_pos.le
  linarith [h]

/-- Distinguishability (I1): the observed change is at least the
distinguishability floor. -/
theorem nu_le_ifValue (f : InterpretabilityFactor) : f.nu ≤ ifValue f := by
  unfold ifValue
  have h : f.cmin * f.eps ≤ f.c * f.eps := mul_le_mul_of_nonneg_right f.cmin_le_c f.eps_pos.le
  linarith [h, f.cmin_mul_eps_ge_nu]

/-- Differential traceability (I3), kept concrete and finite: some
difference operator among the observer's first `O.N` orders distinguishes
the pre- and post-states, matching definition:bk1_observer_relative_interpretability's
"there exists `n ∈ {1,...,N_O}`" clause via `Finset.range`. -/
def Traceable (O : BoundedObserver) (s s' : Real) : Prop :=
  ∃ n ∈ Finset.range O.N, O.delta n s' ≠ O.delta n s

/-- Global `O`-interpretability, as the conjunction of (I1), (I2), (I3). -/
def Interpretable (nu value eps : Real) (trace : Prop) : Prop :=
  nu ≤ value ∧ value ≤ eps ∧ trace

/-- proposition:bk1_stage_composite_operators_are_interpretable's punchline,
made precise: given the factorization sandwich and an explicit traceability
witness, the operator is globally `O`-interpretable. -/
theorem interpretable_of_factor_and_traceable (f : InterpretabilityFactor)
    (O : BoundedObserver) (s s' : Real) (htrace : Traceable O s s') :
    Interpretable f.nu (ifValue f) f.eps (Traceable O s s') :=
  ⟨nu_le_ifValue f, ifValue_le_eps f, htrace⟩

/- ================================================================
   definition:bk1_stage_composite_operator,
   lemma:bk1_observer_bounded_emergence_constraint (part (i))
   ================================================================ -/

/-- Stage-composite data (definition:bk1_stage_composite_operator): a drift
step and a stabilization step, each individually a bounded approximation of
the identity to within `δ`, on a generic pseudometric space standing in for
the observer metric `d_O`. -/
structure TwoStepBoundedApprox (X : Type) [PseudoMetricSpace X] where
  drift : X → X
  stabilize : X → X
  δ : Real
  drift_bound : ∀ s, dist (drift s) s ≤ δ
  stabilize_bound : ∀ t, dist (stabilize t) t ≤ δ

/-- lemma:bk1_observer_bounded_emergence_constraint (i): the stage-composite
operator `E = stabilize ∘ drift` is a bounded approximation of the identity
to within `2δ`, by the triangle inequality. -/
theorem twoStep_bound {X : Type} [PseudoMetricSpace X] (c : TwoStepBoundedApprox X) (s : X) :
    dist (c.stabilize (c.drift s)) s ≤ 2 * c.δ := by
  have h1 : dist (c.stabilize (c.drift s)) (c.drift s) ≤ c.δ := c.stabilize_bound (c.drift s)
  have h2 : dist (c.drift s) s ≤ c.δ := c.drift_bound s
  have h3 := dist_triangle (c.stabilize (c.drift s)) (c.drift s) s
  linarith

/- ================================================================
   lemma:bk1_observer_bounded_emergence_constraint (part (ii)),
   axiom:bk1_summable_resolution_decay
   ================================================================ -/

/-- A chain of stage transitions with summably decaying per-step
observer-metric bounds (axiom:bk1_summable_resolution_decay). -/
structure ChainedApprox (X : Type) [PseudoMetricSpace X] where
  path : Nat → X
  step : Nat → Real
  step_bound : ∀ n, dist (path (n + 1)) (path n) ≤ step n
  summable_step : Summable step

/-- lemma:bk1_observer_bounded_emergence_constraint (ii), the finite honest
kernel: the observer-metric distance across a stage range `[m, n)` is
bounded by the telescoped sum of per-step bounds. The following theorems
use the structure's summability field to derive its Cauchy and complete-space
limit consequences. -/
theorem chainedApprox_telescope {X : Type} [PseudoMetricSpace X] (c : ChainedApprox X)
    {m n : Nat} (hmn : m ≤ n) :
    dist (c.path n) (c.path m) ≤ ∑ j ∈ Finset.Ico m n, c.step j := by
  induction n, hmn using Nat.le_induction with
  | base => simp
  | succ n hmn ih =>
      rw [Finset.sum_Ico_succ_top hmn]
      have h1 := c.step_bound n
      have h2 := dist_triangle (c.path (n + 1)) (c.path n) (c.path m)
      linarith

/-- Summable resolution decay makes the stage path Cauchy. -/
theorem ChainedApprox.cauchySeq {X : Type} [PseudoMetricSpace X]
    (c : ChainedApprox X) : CauchySeq c.path := by
  apply cauchySeq_of_dist_le_of_summable c.step
  · intro n
    simpa [Nat.succ_eq_add_one, dist_comm] using c.step_bound n
  · exact c.summable_step

/-- In a complete observer metric, summable resolution decay produces a
limiting stage, with remaining displacement bounded by the tail budget. -/
theorem ChainedApprox.exists_limit_with_tail_bound
    {X : Type} [MetricSpace X] [CompleteSpace X] (c : ChainedApprox X) :
    ∃ limit : X,
      Filter.Tendsto c.path Filter.atTop (nhds limit) ∧
      ∀ n, dist (c.path n) limit ≤ ∑' m, c.step (n + m) := by
  obtain ⟨limit, hlimit⟩ := cauchySeq_tendsto_of_complete c.cauchySeq
  refine ⟨limit, hlimit, ?_⟩
  intro n
  apply dist_le_tsum_of_dist_le_of_tendsto c.step
  · intro k
    simpa [Nat.succ_eq_add_one, dist_comm] using c.step_bound k
  · exact c.summable_step
  · exact hlimit

/- ================================================================
   definition:bk1_reflection_operator,
   definition:bk1_pre_geometric_operators_and_stages (stabilization operator)
   ================================================================ -/

/-- definition:bk1_reflection_operator's mirror component, witnessed
concretely: an involution on `Real × Real` that preserves the standard
inner product, and is neither the identity nor pointwise negation (the
"`R ≠ ± Id`" clause). -/
theorem mirror_involution_ne_id_exists :
    ∃ R : Real × Real → Real × Real,
      (∀ p, R (R p) = p) ∧
      R ≠ id ∧
      R ≠ (fun p => (-p.1, -p.2)) ∧
      ∀ p q : Real × Real, (R p).1 * (R q).1 + (R p).2 * (R q).2 = p.1 * q.1 + p.2 * q.2 := by
  refine ⟨fun p => (p.1, -p.2), fun p => ?_, ?_, ?_, fun p q => ?_⟩
  · simp
  · intro h
    have hp := congrFun h (0, 1)
    simp only [Prod.ext_iff] at hp
    exact absurd hp.2 (by norm_num)
  · intro h
    have hp := congrFun h (1, 0)
    simp only [Prod.ext_iff] at hp
    exact absurd hp.1 (by norm_num)
  · show p.1 * q.1 + (-p.2) * (-q.2) = p.1 * q.1 + p.2 * q.2
    ring

/-- definition:bk1_pre_geometric_operators_and_stages's stabilization
component, witnessed concretely: an idempotent map on `Real × Real` that is
not the identity. -/
theorem projection_idempotent_ne_id_exists :
    ∃ P : Real × Real → Real × Real,
      (∀ p, P (P p) = P p) ∧ P ≠ id := by
  refine ⟨fun p => (p.1, 0), fun _ => rfl, ?_⟩
  intro h
  have hp := congrFun h (0, 1)
  simp only [Prod.ext_iff] at hp
  exact absurd hp.2 (by norm_num)

/- ================================================================
   definition:bk1_spinor_like_structure
   ================================================================ -/

/-- A co-emergent operational pair on one embodied carrier. The fields are
supplied together; neither drift nor reflection is constructed from the other.
Their composite `step` records operational order only. -/
structure CoemergentPhaseProcess (X : Type*) where
  drift : X -> X
  reflect : X -> X

namespace CoemergentPhaseProcess

/-- One recursive operational step: differentiate, then reflect/stabilize.
The ordering is compositional, not an assertion of ontological precedence. -/
def step {X : Type*} (P : CoemergentPhaseProcess X) : X -> X :=
  fun x => P.reflect (P.drift x)

/-- The observer-relative, partial spinor certificate justified by the source
without importing full spin geometry. The process is inert data until the
explicit `reader` supplies an `operate` action. `operate_realizes_process`
certifies that this enactment faithfully realizes the co-emergent pair. At the
half-cycle the observer detects an orientation change; at the double cycle the
embodied phase returns. -/
structure ObserverPhaseCertificate (X Signal Reader : Type*) where
  process : CoemergentPhaseProcess X
  reader : Reader
  operate : Reader -> X -> X
  operate_realizes_process : operate reader = process.step
  psi : X
  halfPeriod : Nat
  halfPeriod_pos : 0 < halfPeriod
  observe : X -> Signal
  half_distinguished :
    Not (observe (((operate reader)^[halfPeriod]) psi) = observe psi)
  double_returns :
    ((operate reader)^[2 * halfPeriod]) psi = psi

/-- The certificate retains operation and both sides of the phase claim
together: a reader-enacted step, visible half-cycle difference, and full-cycle
restoration. -/
theorem ObserverPhaseCertificate.components {X Signal Reader : Type*}
    (P : ObserverPhaseCertificate X Signal Reader) :
    And
      (P.operate P.reader = P.process.step)
      (And
        (Not (P.observe (((P.operate P.reader)^[P.halfPeriod]) P.psi) =
          P.observe P.psi))
        (((P.operate P.reader)^[2 * P.halfPeriod]) P.psi = P.psi)) :=
  And.intro P.operate_realizes_process
    (And.intro P.half_distinguished P.double_returns)

/-- The concrete co-emergent pair used by the phase witness. -/
def zmod4PhaseProcess : CoemergentPhaseProcess (ZMod 4) where
  drift := fun x => x + 2
  reflect := fun x => x + 3

/-- A concrete reader-operated witness on `ZMod 4`. Drift adds two and
reflection adds three, so both are nonidentity while their enacted composite
adds one. Two operations are observer-distinguishable from the start; four
restore it. This witnesses recursive phase behavior, not curvature coupling
or a spinor bundle. -/
def zmod4ObserverPhaseCertificate :
    ObserverPhaseCertificate (ZMod 4) (ZMod 4) PUnit where
  process := zmod4PhaseProcess
  reader := PUnit.unit
  operate := fun _ => zmod4PhaseProcess.step
  operate_realizes_process := rfl
  psi := 0
  halfPeriod := 2
  halfPeriod_pos := by decide
  observe := id
  half_distinguished := by decide
  double_returns := by decide
/-- Both operations in the concrete phase witness are genuinely nonidentity;
the recurrence is not obtained by padding a one-operator process with `id`. -/
theorem zmod4_pair_nontrivial :
    And
      (Not (zmod4ObserverPhaseCertificate.process.drift = id))
      (Not (zmod4ObserverPhaseCertificate.process.reflect = id)) := by
  constructor
  · intro h
    have hx := congrFun h 0
    norm_num [zmod4ObserverPhaseCertificate] at hx
    exact (by decide : Not ((2 : ZMod 4) = 0)) hx
  · intro h
    have hx := congrFun h 0
    norm_num [zmod4ObserverPhaseCertificate] at hx
    exact (by decide : Not ((3 : ZMod 4) = 0)) hx

end CoemergentPhaseProcess
/-- The successor map on `ZMod 4`, standing in for the recursive reflection
operator `reflect_n` in definition:bk1_spinor_like_structure. -/
def stepZMod4 (x : ZMod 4) : ZMod 4 := x + 1

/-- "Double Rotation Symmetry" witnessed: four applications of the step
return every point to itself (`reflect_{2n_0}(ψ) = ψ` with `n_0 = 2`). -/
theorem stepZMod4_four_returns :
    ∀ x : ZMod 4, stepZMod4 (stepZMod4 (stepZMod4 (stepZMod4 x))) = x := by
  decide

/-- ...but two applications do not (`reflect_{n_0}(ψ) ≠ ψ`), witnessing that
the "double rotation, not single rotation" clause of
definition:bk1_spinor_like_structure is non-vacuous. -/
theorem stepZMod4_two_no_return : ∃ x : ZMod 4, stepZMod4 (stepZMod4 x) ≠ x := by
  decide

/- ================================================================
   definition:bk1_symbolic_contradiction
   ================================================================ -/

/-- Contradiction data (definition:bk1_symbolic_contradiction): drift values
on the two overlapping regions in "oppositional dynamics", `D|_U = -λ D|_V`
for some `λ > 0`. -/
structure ContradictionData where
  DU : Real
  DV : Real
  lam : Real
  lam_pos : 0 < lam
  opposition : DU = -lam * DV

/-- The contradiction intensity `‖D|_U(s) + D|_V(s)‖`. -/
def contradictionIntensity (c : ContradictionData) : Real := |c.DU + c.DV|

/-- The intensity formula in terms of the opposition ratio `λ`. -/
theorem contradictionIntensity_eq (c : ContradictionData) :
    contradictionIntensity c = |1 - c.lam| * |c.DV| := by
  unfold contradictionIntensity
  rw [c.opposition]
  have h : -c.lam * c.DV + c.DV = (1 - c.lam) * c.DV := by ring
  rw [h, abs_mul]

/-- When the opposition is exact (`λ = 1`), the two drifts cancel and the
contradiction intensity vanishes. -/
theorem contradictionIntensity_zero_of_lam_one (c : ContradictionData) (h : c.lam = 1) :
    contradictionIntensity c = 0 := by
  rw [contradictionIntensity_eq, h]
  simp

/- ================================================================
   lemma:bk1_contextual_nonseparability
   ================================================================ -/

/-- A finite second difference of `U`, the discrete surrogate used here for
the source's mixed partial derivative `D_ξ D_χ U`; this substitutes finite
differences for derivatives and is an honest analogue, not a formalization,
of the source's calculus claim. -/
def mixedDiff (U : Real → Real → Real) (x y h k : Real) : Real :=
  U (x + h) (y + k) - U (x + h) y - U x (y + k) + U x y

/-- Every additively separable ("context-free") update has vanishing second
difference. -/
theorem separable_mixedDiff_zero (A B : Real → Real) (x y h k : Real) :
    mixedDiff (fun ξ χ => A ξ + B χ) x y h k = 0 := by
  simp only [mixedDiff]
  ring

/-- lemma:bk1_contextual_nonseparability's contrapositive: a nonzero second
difference certifies that `U` is not additively separable, i.e. the update
is genuinely contextual at that point. -/
theorem nonseparable_of_mixedDiff_ne_zero (U : Real → Real → Real) (x y h k : Real)
    (hne : mixedDiff U x y h k ≠ 0) :
    ¬ ∃ A B : Real → Real, U = fun ξ χ => A ξ + B χ := by
  rintro ⟨A, B, rfl⟩
  exact hne (separable_mixedDiff_zero A B x y h k)

/- ================================================================
   definition:bk1_symbolic_coupling_basis, definition:bk1_symbolic_coupling,
   lemma:bk1_linear_context_independence,
   theorem:bk1_minimal_quadratic_sufficiency (partial)
   ================================================================ -/

/-- The concrete instance behind the whole linear-vs-quadratic coupling
cluster: the quadratic coupling `(x,y) ↦ x*y` cannot be written as any
linear coupling `β₀x + β₁y`. This is the explicit countermodel witnessing
that quadratic symbolic coupling (definition:bk1_symbolic_coupling_basis,
definition:bk1_symbolic_coupling) is not subsumed by linear coupling
(lemma:bk1_linear_context_independence), and the concrete case of the
general "linear is insufficient" claim in
theorem:bk1_minimal_quadratic_sufficiency. -/
theorem quadratic_not_linear :
    ¬ ∃ β0 β1 : Real, ∀ x y : Real, x * y = β0 * x + β1 * y := by
  rintro ⟨β0, β1, h⟩
  have h10 := h 1 0
  have h01 := h 0 1
  have h11 := h 1 1
  norm_num at h10 h01 h11
  linarith

/- ================================================================
   theorem:bk1_reflexivity_quadratic
   ================================================================ -/

/-- Bilinearity/superposition, as stated in the source's proof sketch. -/
def IsLinearSelf (L : Real → Real) : Prop :=
  ∀ a b x y : Real, L (a * x + b * y) = a * L x + b * L y

/-- theorem:bk1_reflexivity_quadratic's stated algebraic premise: a linear
map cannot distinguish `x` repeated from `x` alone, since linearity forces
`L(x+x) = 2*L(x)`. The source's further jump from this premise to "cannot
support self-reference" is a narrative conclusion and is not modeled here. -/
theorem linear_double {L : Real → Real} (hL : IsLinearSelf L) (x : Real) :
    L (x + x) = 2 * L x := by
  have h := hL 1 1 x x
  simp only [one_mul] at h
  linarith [h]

/- ================================================================
   lemma:bk1_fixed_point_inheritance
   ================================================================ -/

/-- lemma:bk1_fixed_point_inheritance, generalized: conjugating any map `g`
fixing `x` by an invertible map `f` (given by its left inverse `finv`) gives
a map fixing `f x`. The source's "linear" hypothesis on `f` is dropped as
unnecessary -- only invertibility is used. -/
theorem fixedPointInheritance {X : Type} (f g finv : X → X)
    (hleft : ∀ y, finv (f y) = y) {x : X} (hfix : g x = x) :
    f (g (finv (f x))) = f x := by
  rw [hleft x, hfix]

end ForcingAnalysis.ScholiumA
