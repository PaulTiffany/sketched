/-
ScholiumD.lean - honest kernel of the Book I "unmapped remainder" (second
half of the r3-scholiumb slice, 51 anchors, all under the bk1_* label).

This slice is almost entirely the deep-manifold apparatus of Book I: the
proto-symbolic stage tower and its colimit to a smooth manifold, the
emergent Riemannian metric and geodesic distance, the symbolic
Fokker-Planck/H-theorem/free-energy thermodynamic cluster, information
geometry (Fisher-Rao, Wasserstein gradient flow), fluctuation-dissipation,
the symbolic action functional and principle of least action, and a
cosmological symbolization functor. Most of this is genuinely
infinite-dimensional (PDE, path integrals, Riemannian curvature, ODE
linearization/spectra) or purely narrative/taxonomic (paradox-triggered
emergence, dual-horizon cosmogenesis, the certified-transport
bookkeeping's existence claims) and is left open, listed in the
accompanying proposal rather than forced into decorative theorems. For
each anchor with genuine static/algebraic/finite/real-analytic content,
this module extracts that content honestly:

  * the "Convergent Limit" and "Epistemic Emergence" clauses of the
    Symbolic Smoothness axiom become one real-sequence threshold law:
    a nonnegative sequence tending to 0 eventually falls below any fixed
    positive lower bound on the observer's resolution threshold;
  * the "commutator error -> 0" content of Coherence of Proto-Drift
    Fields becomes a squeeze-to-zero lemma for a nonnegative sequence
    dominated by a vanishing bound;
  * the "Compatibility and convergence" step of Existence of Metric --
    charts glue into a single metric -- is re-read over the certified
    chart-complex substrate (`ForcingAnalysis.FracturedAtlas`), with
    gluedness a named hypothesis exactly where the source's proof
    consumes it; the "Positive-definiteness" step is kept separately as
    a self-contained inner-product-free fact: a sum of a squared norm and
    a scaled squared norm is strictly positive whenever the underlying
    operators are not simultaneously annihilating, no manifold needed;
  * the denominator-regularization half of the Symbolic Hamiltonian's
    well-posedness (`kappa/(||D||+eps)` with `eps > 0`) becomes a genuine
    positivity theorem; the second (trace/linearization) term, whose sign
    is unconstrained by the source, is not modeled;
  * the H-theorem's "$dF/ds \le 0$, with equality iff equilibrium" becomes
    the discrete telescoping/rigidity skeleton already used for Book II's
    metabolic cycles: a free-energy sequence that never increases is
    antitone, bounded above by its initial value, and forced constant on
    any interval where it returns to that initial value;
  * the Emergence Operator's `min` over expanded membranes becomes the
    existence of a complexity-minimizing element of a nonempty finite
    candidate set (the enumeration and complexity functional themselves
    are not modeled, only the minimizer's existence);
  * the Conditional Genericity theorem's coupling-range-straddle
    hypothesis (H2), together with the phase-transition anchors it feeds,
    becomes a genuine intermediate-value theorem: a continuous coupling
    function straddling a critical value on an interval must cross it
    (monotonicity is dropped as an unneeded hypothesis, not modeled away);
  * the Certified Type-Preserving Symbolic Transport's four-level loss
    taxonomy (exact/quotient/projective/interpretive) becomes an explicit
    finite type together with the exact licensing rule the text states
    (every level but interpretive may support a theorem dependency) and
    an explicit distinctness witness for non-vacuity.

Anchors left open (paradox/emergence-operator narrative apart from the
minimizer fact, shared-boundary-paradox and its bridge/contrapositive
corollaries, symbolic curvature/Riemann-tensor content, dual-horizon
unification/crossing, local chartability/smooth-convergence/topological-
regularity axioms and the manifold-emergence theorem they support, the
symbolic flow and its existence/uniqueness, symbolic distance and its
Hopf-Rinow completeness, the symbol-space tuple, the probability-density
and entropy integrals, the Fokker-Planck PDE itself and its structural-
correspondence/fluctuation-dissipation/action-functional/least-action/
information-geometry/Wasserstein-gradient-flow cluster, the local-
stability-at-the-fixed-locus ODE linearization, and the cosmological
symbolization functor with its cosmogenesis/identity-field consequences)
are recorded with reasons in the accompanying proposal.
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas
import ForcingAnalysis.Newton
import ForcingAnalysis.ScholiumC

namespace ForcingAnalysis.ScholiumD

/- ================================================================
   axiom:bk1_symbolic_smoothness (Convergent Limit + Epistemic Emergence
   clauses)
   ================================================================ -/

/-- The real-sequence skeleton of axiom:bk1_symbolic_smoothness: `diff n`
is the symbolic-difference norm `||P_{n+1} - P_n||_S` at stage `n` (the
"Convergent Limit" clause, kept as a hypothesis that it tends to `0`), and
`eps` is the observer's resolution threshold at stage `n`
(the "Resolution Threshold" clause), which is bounded below by a fixed
positive constant `eps_lb`. Chart compatibility and the differentiation
operators `delta^n` themselves are not modeled; only the threshold
comparison of the "Epistemic Emergence" clause is. -/
structure DifferentiationThreshold where
  diff : ℕ → ℝ
  diff_nonneg : ∀ n, 0 ≤ diff n
  diff_tendsto_zero : Filter.Tendsto diff Filter.atTop (nhds 0)
  eps : ℕ → ℝ
  eps_lb : ℝ
  eps_lb_pos : 0 < eps_lb
  eps_ge_lb : ∀ n, eps_lb ≤ eps n

/-- Epistemic Emergence (axiom:bk1_symbolic_smoothness, clause 5): the
symbolic differences eventually fall below the observer's resolution
threshold -- smoothness is emergent from boundedness plus convergence,
not assumed outright. -/
theorem DifferentiationThreshold.eventually_below_threshold
    (t : DifferentiationThreshold) :
    ∃ N, ∀ n ≥ N, t.diff n < t.eps n := by
  have hmem : Set.Iio t.eps_lb ∈ nhds (0 : ℝ) :=
    isOpen_Iio.mem_nhds (Set.mem_Iio.mpr t.eps_lb_pos)
  have hev : ∀ᶠ n in Filter.atTop, t.diff n ∈ Set.Iio t.eps_lb :=
    t.diff_tendsto_zero.eventually hmem
  have hev' : ∀ᶠ n in Filter.atTop, t.diff n < t.eps_lb :=
    hev.mono fun n hn => Set.mem_Iio.mp hn
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp hev'
  exact ⟨N, fun n hn => lt_of_lt_of_le (hN n hn) (t.eps_ge_lb n)⟩

/- ================================================================
   definition:bk1_emergence_operator
   ================================================================ -/

/-- The honest finite kernel of definition:bk1_emergence_operator: given a
nonempty finite candidate set of admissible expanded membranes, a
complexity-minimizing one exists. The enumeration of candidate membranes
and the complexity functional itself are not modeled. -/
theorem emergenceOperator_exists {Frame : Type} (S : Finset Frame)
    (hS : S.Nonempty) (complexity : Frame → ℕ) :
    ∃ m ∈ S, ∀ m' ∈ S, complexity m ≤ complexity m' :=
  S.exists_min_image complexity hS

/- ================================================================
   lemma:bk1_coherence_of_proto_drift_fields
   ================================================================ -/

/-- The commutator-error skeleton of the coherence proof
(lemma:bk1_coherence_of_proto_drift_fields): `err` is the pushforward
commutator error at each stage, dominated pointwise by a bound that
itself vanishes -- the honest content of "convergence of transition maps
forces the commutator error to zero", with chart representations and the
transition maps themselves not modeled. -/
structure CommutatorErrorBound where
  err : ℕ → ℝ
  bound : ℕ → ℝ
  err_nonneg : ∀ n, 0 ≤ err n
  err_le_bound : ∀ n, err n ≤ bound n
  bound_tendsto_zero : Filter.Tendsto bound Filter.atTop (nhds 0)

/-- The commutator error itself tends to zero, by the squeeze theorem. -/
theorem CommutatorErrorBound.err_tendsto_zero (c : CommutatorErrorBound) :
    Filter.Tendsto c.err Filter.atTop (nhds 0) :=
  tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds
    c.bound_tendsto_zero c.err_nonneg c.err_le_bound

/- ================================================================
   lemma:bk1_existence_of_metric
   ================================================================ -/

/-- The "Positive-definiteness" step of lemma:bk1_existence_of_metric's
proof, stripped of the manifold: for any operators `R, D` on a normed
space and coupling `alpha > 0`, the combined form `||R x||^2 + alpha *
||D x||^2` is strictly positive whenever `R` and `D` do not both
annihilate `x` -- the honest algebraic content of "positivity follows
from proto-stage non-degeneracy: at least one of `R_lam(X)`, `D_lam(X)` is
nonzero". -/
theorem combinedForm_pos_of_nondegenerate {V : Type*} [NormedAddCommGroup V]
    (R D : V → V) (α : ℝ) (hα : 0 < α) (x : V) (hx : R x ≠ 0 ∨ D x ≠ 0) :
    0 < ‖R x‖ ^ 2 + α * ‖D x‖ ^ 2 := by
  rcases hx with h | h
  · have hpos : 0 < ‖R x‖ := norm_pos_iff.mpr h
    have h1 : 0 < ‖R x‖ ^ 2 := pow_pos hpos 2
    have h2 : 0 ≤ α * ‖D x‖ ^ 2 := mul_nonneg hα.le (sq_nonneg _)
    linarith
  · have hpos : 0 < ‖D x‖ := norm_pos_iff.mpr h
    have h1 : 0 ≤ ‖R x‖ ^ 2 := sq_nonneg _
    have h2 : 0 < α * ‖D x‖ ^ 2 := mul_pos hα (pow_pos hpos 2)
    linarith

/-- The combined form is always nonnegative (the "positive semi-definite"
half of the same proof step, with no non-degeneracy needed). -/
theorem combinedForm_nonneg {V : Type*} [NormedAddCommGroup V]
    (R D : V → V) (α : ℝ) (hα : 0 ≤ α) (x : V) :
    0 ≤ ‖R x‖ ^ 2 + α * ‖D x‖ ^ 2 := by
  have h1 : (0 : ℝ) ≤ ‖R x‖ ^ 2 := sq_nonneg _
  have h2 : (0 : ℝ) ≤ α * ‖D x‖ ^ 2 := mul_nonneg hα (sq_nonneg _)
  linarith

open ForcingAnalysis.Atlas in
/-- The "Compatibility and convergence" step of lemma:bk1_existence_of_metric's
proof, read over the certified chart-complex substrate
(`ForcingAnalysis.FracturedAtlas`): where the source's proto-stage charts
`g_lam` are glued (compatible on shared overlaps, up to the vanishing
coherence deviation) and every pair of points shares a chart, a single
global metric exists that agrees with every chart. -/
theorem existence_of_metric_from_gluing {X : Type*} (C : ChartComplex X)
    (hCov : PairCovers C) (hG : Glued C) :
    ∃ D : X → X → ℝ, Consistent C D :=
  (single_geometry_iff_glued hCov).mpr hG

/- ================================================================
   definition:bk1_symbolic_hamiltonian,
   lemma:bk1_well_posedness_of_symbolic_hamiltonian
   ================================================================ -/

/-- The regularized-denominator data of the Symbolic Hamiltonian's first
term (definition:bk1_symbolic_hamiltonian): `kappa > 0`, the drift norm is
nonnegative, and `eps > 0` is the regularization. The second
(linearization/trace) term is not modeled, since its sign is unconstrained
by the source. -/
structure SymbolicHamiltonianFirstTerm where
  kappa : ℝ
  kappa_pos : 0 < kappa
  driftNorm : ℝ
  driftNorm_nonneg : 0 ≤ driftNorm
  eps : ℝ
  eps_pos : 0 < eps

/-- The honest kernel of lemma:bk1_well_posedness_of_symbolic_hamiltonian's
first term: the regularized denominator is always strictly positive, so
the quotient is well-defined and positive -- smoothness itself (which
needs `D` and `g` to be `C^\infty`) is not modeled. -/
theorem SymbolicHamiltonianFirstTerm.pos (h : SymbolicHamiltonianFirstTerm) :
    0 < h.kappa / (h.driftNorm + h.eps) :=
  div_pos h.kappa_pos (by linarith [h.driftNorm_nonneg, h.eps_pos])

/- ================================================================
   theorem:bk1_h_theorem_for_symbolic_evolution
   ================================================================ -/

/-- The discrete telescoping skeleton of the H-theorem
(theorem:bk1_h_theorem_for_symbolic_evolution): a free-energy sequence
that never increases from one discretized symbolic time to the next. The
Fokker-Planck evolution and the integration-by-parts argument producing
this monotonicity are not modeled; only the resulting discrete inequality
is. -/
structure FreeEnergyDescent where
  F : ℕ → ℝ
  nonincreasing : ∀ n, F (n + 1) ≤ F n

/-- The free-energy sequence is antitone. -/
theorem FreeEnergyDescent.antitone (fe : FreeEnergyDescent) : Antitone fe.F :=
  antitone_nat_of_succ_le fe.nonincreasing

/-- Free energy never exceeds its initial value ($dF/ds \le 0$, integrated). -/
theorem FreeEnergyDescent.le_initial (fe : FreeEnergyDescent) (n : ℕ) :
    fe.F n ≤ fe.F 0 :=
  fe.antitone (Nat.zero_le n)

/-- The equality-case rigidity of the H-theorem's "$dF/ds \le 0$, with
equality iff $\rho = \rho_{\text{eq}}$": if free energy returns to its
initial value at some later step, it must have been constant all the way
there -- the discrete analogue of "descent stalls only at equilibrium". -/
theorem FreeEnergyDescent.const_of_eq (fe : FreeEnergyDescent) {m : ℕ}
    (heq : fe.F m = fe.F 0) {k : ℕ} (hk : k ≤ m) : fe.F k = fe.F 0 := by
  have h1 : fe.F m ≤ fe.F k := fe.antitone hk
  have h2 : fe.F k ≤ fe.F 0 := fe.le_initial k
  linarith

/- ================================================================
   definition:bk1_symbolic_phase_transitions,
   theorem:bk1_realization_of_symbolic_phase_transitions,
   theorem:bk1_conditional_genericity_of_symbolic_phase_transitions
   ================================================================ -/

/-- The honest real-analytic kernel of the Conditional Genericity
theorem's coupling-range-straddle hypothesis (H2), which is also the
existence content shared by definition:bk1_symbolic_phase_transitions'
critical value and theorem:bk1_realization_of_symbolic_phase_transitions'
"there exists a critical beta_c": a continuous coupling function that
straddles a target value on an interval must cross it somewhere on that
interval. Monotonicity of `lambda` (also assumed by the source) is
dropped as an unneeded hypothesis; non-analyticity of the free-energy
density at the crossing point is not modeled. -/
theorem exists_critical_coupling {a b lambdaC : ℝ} (hab : a ≤ b)
    (lambda : ℝ → ℝ) (hcont : ContinuousOn lambda (Set.Icc a b))
    (hlo : lambda a < lambdaC) (hhi : lambdaC < lambda b) :
    ∃ betaC ∈ Set.Icc a b, lambda betaC = lambdaC := by
  have hmem : lambdaC ∈ Set.Icc (lambda a) (lambda b) := ⟨hlo.le, hhi.le⟩
  obtain ⟨betaC, hmem', heq⟩ := intermediate_value_Icc hab hcont hmem
  exact ⟨betaC, hmem', heq⟩

/- ================================================================
   definition:bk1_certified_type_preserving_symbolic_transport,
   proposition:bk1_certified_transport_prevents_equivocation,
   proposition:bk1_nonvacuity_of_certified_transport
   ================================================================ -/

/-- The four declared loss levels of a certified type-preserving symbolic
transport (definition:bk1_certified_type_preserving_symbolic_transport,
field `ell`). The transported-occurrence map `T`, the signature `sigma`,
and the structural role `rho` are not modeled; only the loss taxonomy that
the licensing clause and non-vacuity proposition act on is. -/
inductive TransportLoss where
  | exact
  | quotient
  | projective
  | interpretive
  deriving DecidableEq

/-- Whether a transport at this loss level may be cited to support a
theorem dependency, directly or with the stated loss carried along
(definition:bk1_certified_type_preserving_symbolic_transport's licensing
clause: exact transports support dependencies directly, quotient/
projective transports support them only with the loss included, and
interpretive transports must not be cited as hidden proof support). -/
def TransportLoss.supportsDependency (l : TransportLoss) : Prop :=
  l ≠ TransportLoss.interpretive

theorem TransportLoss.exact_supportsDependency :
    TransportLoss.exact.supportsDependency := by
  unfold TransportLoss.supportsDependency; decide

theorem TransportLoss.quotient_supportsDependency :
    TransportLoss.quotient.supportsDependency := by
  unfold TransportLoss.supportsDependency; decide

theorem TransportLoss.projective_supportsDependency :
    TransportLoss.projective.supportsDependency := by
  unfold TransportLoss.supportsDependency; decide

/-- proposition:bk1_certified_transport_prevents_equivocation, the
licensing half: an interpretive transport can never be cited as hidden
proof support. -/
theorem TransportLoss.interpretive_not_supportsDependency :
    ¬ TransportLoss.interpretive.supportsDependency := by
  unfold TransportLoss.supportsDependency; decide

/-- proposition:bk1_nonvacuity_of_certified_transport: the loss taxonomy is
nonempty, and contains both an exact and a genuinely projective level,
distinct from one another. -/
theorem TransportLoss.nonempty : Nonempty TransportLoss :=
  ⟨TransportLoss.exact⟩

theorem TransportLoss.exact_ne_projective :
    TransportLoss.exact ≠ TransportLoss.projective := by decide

/- ================================================================
   corollary:bk1_contrapositive_search_principle
   ================================================================ -/

/-- The converse from a shared invariant back to shared paradox is not a
logical consequence of the forward implication alone. This two-proposition
countermodel is the negative-control core of the Contrapositive Search
Principle. -/
theorem shared_invariant_converse_not_derivable :
    ∃ paradox invariant : Prop,
      (paradox → invariant) ∧ ¬ (invariant → paradox) := by
  exact ⟨False, True, by simp⟩

/-- Joint refinement searches only candidates retained by both observers. -/
def jointRefinement {α : Type*} (A B : Set α) : Set α := A ∩ B

/-- Membership in a joint refinement is exactly simultaneous observer
acceptance; no completeness or uniqueness of the invariant is inferred. -/
theorem mem_jointRefinement_iff {α : Type*} {A B : Set α} {x : α} :
    x ∈ jointRefinement A B ↔ x ∈ A ∧ x ∈ B :=
  Iff.rfl

/-- Joint refinement cannot introduce candidates absent from either
observer's search space. -/
theorem jointRefinement_subset_left_right {α : Type*} (A B : Set α) :
    jointRefinement A B ⊆ A ∧ jointRefinement A B ⊆ B :=
  ⟨Set.inter_subset_left, Set.inter_subset_right⟩

/- ================================================================
   proposition:bk1_imagination_supplies_effective_dimension
   ================================================================ -/

/-- A faithful finite certificate for imaginative genericity. Imagination
supplies two distinct effective directions; coupling straddle and
transversality remain explicit hypotheses rather than consequences of the
word "imagination." -/
structure ImaginativeGenericityCertificate (X : Type*) where
  direction : Fin 2 → X
  direction_injective : Function.Injective direction
  a : ℝ
  b : ℝ
  criticalCoupling : ℝ
  coupling : ℝ → ℝ
  interval : a ≤ b
  coupling_continuous : ContinuousOn coupling (Set.Icc a b)
  below_at_left : coupling a < criticalCoupling
  above_at_right : criticalCoupling < coupling b
  discriminantSlope : ℝ
  transversal : discriminantSlope ≠ 0

/-- **proposition:bk1_imagination_supplies_effective_dimension**, honest
certificate form: two effective directions discharge H1, the continuous
straddle yields a critical coupling for H2, and H3 is retained as the
explicit nonzero discriminant slope supplied by the certificate. -/
theorem ImaginativeGenericityCertificate.supplies_genericity_hypotheses
    {X : Type*} (C : ImaginativeGenericityCertificate X) :
    C.direction 0 ≠ C.direction 1 ∧
      (∃ betaC ∈ Set.Icc C.a C.b,
        C.coupling betaC = C.criticalCoupling) ∧
      C.discriminantSlope ≠ 0 := by
  refine ⟨?_, exists_critical_coupling C.interval C.coupling
    C.coupling_continuous C.below_at_left C.above_at_right, C.transversal⟩
  intro h
  have : (0 : Fin 2) = 1 := C.direction_injective h
  omega

/- ================================================================
   theorem:bk1_symbolic_fluctuation_dissipation_relation
   ================================================================ -/

/-- Linear response as the time derivative of an equilibrium correlation
observable. -/
noncomputable def symbolicLinearResponse (correlation : ℝ → ℝ) (t : ℝ) : ℝ :=
  deriv correlation t

/-- **theorem:bk1_symbolic_fluctuation_dissipation_relation**, local
calculus kernel: a certified Kubo derivative identifies response with both
the correlation derivative and `-β` times the generator correlation. The
Fokker–Planck/Kubo derivation of the derivative certificate stays open. -/
theorem symbolic_fluctuation_dissipation
    (correlation : ℝ → ℝ) {t β generatorCorrelation : ℝ}
    (hKubo : HasDerivAt correlation (-β * generatorCorrelation) t) :
    symbolicLinearResponse correlation t =
        deriv correlation t ∧
      symbolicLinearResponse correlation t =
        -β * generatorCorrelation := by
  constructor
  · rfl
  · exact hKubo.deriv

/- ================================================================
   theorem:bk1_the_fokker_planck_equation_theorem
   ================================================================ -/

/-- The scalar JKO objective: squared transport cost from the previous
state plus free energy. -/
noncomputable def jkoObjective {X : Type*} [PseudoMetricSpace X]
    (τ : ℝ) (freeEnergy : X → ℝ) (previous candidate : X) : ℝ :=
  dist candidate previous ^ 2 / (2 * τ) + freeEnergy candidate

/-- **theorem:bk1_the_fokker_planck_equation_theorem**, discrete JKO
kernel: a JKO minimizer cannot increase free energy, since the previous
state is a zero-transport competitor. The Wasserstein manifold, PDE limit,
and convergence as `τ → 0` remain open. -/
theorem jko_step_freeEnergy_le {X : Type*} [PseudoMetricSpace X]
    {τ : ℝ} (hτ : 0 < τ) (freeEnergy : X → ℝ)
    (previous next : X)
    (hmin : jkoObjective τ freeEnergy previous next ≤
      jkoObjective τ freeEnergy previous previous) :
    freeEnergy next ≤ freeEnergy previous := by
  have hden : 0 < 2 * τ := by positivity
  have hpenalty : 0 ≤ dist next previous ^ 2 / (2 * τ) :=
    div_nonneg (sq_nonneg _) hden.le
  have hcompetitor :
      jkoObjective τ freeEnergy previous previous = freeEnergy previous := by
    simp [jkoObjective]
  rw [hcompetitor] at hmin
  unfold jkoObjective at hmin
  linarith

/-- **corollary:bk1_wasserstein_geometric_interpretation**, discrete
energy-dissipation kernel: the scaled squared transport displacement of a
JKO minimizer is paid for by its free-energy decrease. This is the finite
metric-gradient signature, without asserting a Wasserstein manifold. -/
theorem jko_step_transport_cost_le_energy_drop
    {X : Type*} [PseudoMetricSpace X] {τ : ℝ}
    (freeEnergy : X → ℝ) (previous next : X)
    (hmin : jkoObjective τ freeEnergy previous next ≤
      jkoObjective τ freeEnergy previous previous) :
    dist next previous ^ 2 / (2 * τ) ≤
      freeEnergy previous - freeEnergy next := by
  have h := hmin
  simp [jkoObjective] at h
  linarith

/- ================================================================
   theorem:bk1_dual_horizon_cosmogenesis
   ================================================================ -/

/-- **theorem:bk1_dual_horizon_cosmogenesis**, static geometric kernel:
opposite-signed horizon curvatures are necessarily distinct, while a
positive observer-resolution floor makes the corresponding inner/outer
chart complex impossible to reconcile with one global geometry. The
cosmological functor, causal evolution, and observer apparatus asserted by
the source remain open. -/
theorem dual_horizon_cosmogenesis_kernel
    {ε pastCurvature futureCurvature : ℝ}
    (hε : 0 < ε) (hpast : 0 < pastCurvature)
    (hfuture : futureCurvature < 0) :
    pastCurvature ≠ futureCurvature ∧
      ¬ ∃ D : ℝ → ℝ → ℝ,
        ForcingAnalysis.Atlas.Consistent
          (ForcingAnalysis.Atlas.dualHorizon ε) D := by
  constructor
  · linarith
  · exact ForcingAnalysis.Atlas.no_single_geometry_for_dual_horizon hε
/- ================================================================
   corollary:bk1_event_horizon_identity_field
   ================================================================ -/

/-- The scalar identity-field tension induced by two horizon curvatures. -/
def horizonIdentityTension (pastCurvature futureCurvature : ℝ) : ℝ :=
  pastCurvature - futureCurvature

/-- **corollary:bk1_event_horizon_identity_field**, static kernel:
oppositely curved horizons induce a strictly positive identity-field
tension. At positive observer resolution that nonzero contrast accompanies
the certified obstruction to a single reconciling geometry. This does not
construct the source's spacetime identity field or its dynamics. -/
theorem event_horizon_identity_field_kernel
    {ε pastCurvature futureCurvature : ℝ}
    (hε : 0 < ε) (hpast : 0 < pastCurvature)
    (hfuture : futureCurvature < 0) :
    0 < horizonIdentityTension pastCurvature futureCurvature ∧
      pastCurvature ≠ futureCurvature ∧
      ¬ ∃ D : ℝ → ℝ → ℝ,
        ForcingAnalysis.Atlas.Consistent
          (ForcingAnalysis.Atlas.dualHorizon ε) D := by
  have hcosmos := dual_horizon_cosmogenesis_kernel hε hpast hfuture
  exact ⟨by simp [horizonIdentityTension]; linarith, hcosmos⟩
/- ================================================================
   proposition:bk1_newtonian_incompleteness
   ================================================================ -/

/-- **proposition:bk1_newtonian_incompleteness**, covariance-boundary
kernel: Newton's force map is equivariant under every continuous linear
change of frame, yet a genuinely accelerated frame contributes the
nonzero acceleration defect `2 • w`. Thus extending the covariance class
requires an explicit correction rather than following from the Newtonian
law alone. -/
theorem newtonian_incompleteness_kernel
    (m : ℝ) {a w : ForcingAnalysis.NVec} (hw : w ≠ 0) :
    ForcingKernel.Equivariant
        (G := ForcingAnalysis.NVec →L[ℝ] ForcingAnalysis.NVec)
        (fun L x => L x) (fun L f => L f)
        (ForcingAnalysis.newtonForce m) ∧
      a + (2 : ℝ) • w ≠ a := by
  exact ⟨ForcingAnalysis.newtonForce_equivariant m,
    ForcingAnalysis.accelerated_frame_defect_ne hw⟩
/-- The source-level covariance boundary without the earlier three-coordinate
specialization: on every real normed vector space, scalar Newtonian force
commutes with every continuous linear frame map, while every nonzero uniform
frame acceleration produces a nonzero `2 • w` defect. -/
theorem newtonian_incompleteness_normedSpace
    {V : Type*} [NormedAddCommGroup V] [NormedSpace ℝ V]
    (m : ℝ) {a w : V} (hw : w ≠ 0) :
    (∀ L : V →L[ℝ] V, L (m • a) = m • L a) ∧
      a + (2 : ℝ) • w ≠ a := by
  constructor
  · intro L
    exact L.map_smul m a
  · intro h
    have h0 : (2 : ℝ) • w = 0 := by
      have := congrArg (fun z => z - a) h
      simpa [add_comm, add_sub_cancel_right] using this
    exact hw (by simpa [smul_eq_zero] using h0)
/- ================================================================
   lemma:bk1_symbolic_quantum_incompatibility
   ================================================================ -/

/-- Pointwise preservation of symbolic reflection by quantum evolution. -/
def ReflectionPreserving {S H : Type*} (φ : S → H)
    (reflect : S → S) (evolve : H → H) : Prop :=
  ∀ s, φ (reflect s) = evolve (φ s)

/-- Pointwise preservation of a binary symbolic update by a target tensor
operation. -/
def UpdatePreserving {S H : Type*} (φ : S → H)
    (update : S → S → S) (tensor : H → H → H) : Prop :=
  ∀ s s', φ (update s s') = tensor (φ s) (φ s')

/-- **lemma:bk1_symbolic_quantum_incompatibility**, faithful conditional
kernel: if jointly preserving reflection and reflexive update necessarily
induces a Hamiltonian-level meta-update, while the target quantum model
forbids that meta-update, no map can preserve both structures. The
requirement and prohibition are explicit premises because linear/unitary
evolution and tensor structure alone do not prove either one. -/
theorem symbolic_quantum_incompatibility_kernel
    {S H : Type*} (φ : S → H) (reflect : S → S) (evolve : H → H)
    (update : S → S → S) (tensor : H → H → H) (metaUpdate : Prop)
    (requiresMeta : ReflectionPreserving φ reflect evolve →
      UpdatePreserving φ update tensor → metaUpdate)
    (quantumForbidsMeta : ¬ metaUpdate) :
    ¬ (ReflectionPreserving φ reflect evolve ∧
      UpdatePreserving φ update tensor) := by
  rintro ⟨hreflect, hupdate⟩
  exact quantumForbidsMeta (requiresMeta hreflect hupdate)
/- ================================================================
   theorem:bk1_symbolic_emergence_theorem_thermodynamics
   ================================================================ -/

/-- The three premises stated by the symbolic-emergence theorem, together
with its designated curvature tensor but without an unspoken bridge law. -/
structure EmergencePremises (S : Type*) where
  access : Set S
  drift : S → S
  reflect : S → S
  baseDim : ℕ
  updatedDim : ℕ
  curvature : S → S → S → ℝ
  novelty : ∃ s, drift s ∉ access
  reflexiveIdentity : ∃ s, reflect s = s
  structuralGrowth : baseDim < updatedDim

/-- **theorem:bk1_symbolic_emergence_theorem_thermodynamics**, negative
control: the three displayed premises admit a concrete model whose designated
curvature is identically zero. Consequently novelty, a reflective fixed
point, and an abstract dimension inequality do not by themselves entail
nonzero curvature; a law connecting those data to a connection or quadratic
cross-term is a genuinely necessary additional hypothesis. -/
theorem emergence_premises_do_not_force_curvature :
    ∃ E : EmergencePremises Bool,
      ∀ s s' s'' : Bool, E.curvature s s' s'' = 0 := by
  let E : EmergencePremises Bool :=
    { access := ∅
      drift := id
      reflect := id
      baseDim := 0
      updatedDim := 1
      curvature := fun _ _ _ => 0
      novelty := ⟨false, by simp⟩
      reflexiveIdentity := ⟨false, rfl⟩
      structuralGrowth := by omega }
  exact ⟨E, fun _ _ _ => rfl⟩
/-- Contextual structural growth has a Scholium-local certificate: failure of
additive state/context separation exposes a nonzero mixed cross-error. This
result deliberately stops before Book 4 geometry; Book 4 consumes the
certificate to construct noncommuting transports. -/
theorem contextualGrowth_exposes_crossError
    (U : ℝ → ℝ → ℝ)
    (hgrowth : ¬ ∃ f : ℝ → ℝ, ∃ g : ℝ → ℝ,
      U = fun ξ χ => f ξ + g χ) :
    ∃ ξ χ, ForcingAnalysis.ScholiumC.crossTerm U ξ χ ≠ 0 := by
  by_contra hcross
  push Not at hcross
  apply hgrowth
  refine ⟨fun ξ => U ξ 0, fun χ => U 0 χ - U 0 0, ?_⟩
  funext ξ χ
  have hξχ := hcross ξ χ
  dsimp [ForcingAnalysis.ScholiumC.crossTerm] at hξχ ⊢
  rw [← sub_eq_zero]
  abel_nf at hξχ ⊢
  exact hξχ
end ForcingAnalysis.ScholiumD
