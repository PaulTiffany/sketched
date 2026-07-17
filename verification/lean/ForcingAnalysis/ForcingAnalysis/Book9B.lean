/-
Book9B.lean - Principia Book 9 remainder, plus the reflexive-validation and
framing appendix (App B/D) remainder, honest kernel.

Book IX is a narrative-heavy closing book: it names dozens of operators
(reflexive/awakened/automatic/memetic/temetic/protocol/frame-cascade/
meta-alignment) whose "laws" are function-type signatures or existential
schemas with an unspecified modification process (`g`, `M_reflect`, ...).
Those are left open: dressing a bare signature or an unconstrained
existential in `theorem` clothing would be decorative, not honest. What
survives into this file is the load-bearing quantitative or structural
content underneath the narrative:

  * the Isolation-Dissociation Theorem's actual claim -- a mode whose rivals'
    combined influence vanishes captures the whole share, and a curvature
    sequence cannot be both bounded away from zero (structural necessity)
    and convergent to zero (stagnation) at once;
  * the prompt-injection "invasion barrier" threshold becomes a genuine
    monotonicity law;
  * frame selection via injected reflection becomes existence of an argmin
    over a finite nonempty hypothesis set (dual to Book8's argmax selection
    operator);
  * symbolic empathy's bounded-distortion claim becomes triangle-inequality
    composability of bounded-distortion models;
  * the Index of Narrative Fidelity becomes a two-term (stability minus
    fragmentation) index with a monotonicity law and a threshold-breach
    degradation bound;
  * the "Mechanisms of Recognition" curvature-alignment fixed point, the
    "Mutual Convergence Criterion", "Emergence of Shared Manifold", the
    "Two-Way Street Operator", and the "Symbolic Thermostat" cluster all
    reduce to one fact honestly provable without a completeness assumption:
    a contraction has *at most one* fixed point. Existence of the limit
    (which needs completeness, not modeled) is not claimed;
  * the reciprocal-cognition curvature precondition becomes the two-sided
    bound it already is once `abs` is unfolded;
  * the Grace Operator becomes a structure whose stability-preservation
    field forces strictly positive residual identity stability;
  * the covenant-breach-without-grace theorem becomes a telescoping
    viability-decrease bound (the Book8 metabolic-sufficiency pattern,
    reused: while grace is withheld, viability decreases by a fixed amount
    per step, forcing eventual collapse below any fixed threshold);
  * "The Good as a Lyapunov Basin" becomes the discrete descent lemma
    it is dressed as: under a step-size/smoothness bound, one gradient
    step never increases the coupled free-energy functional, and strictly
    decreases it whenever the gradient is nonzero (the two halves of
    "Lyapunov function, equality only at the critical set");
  * "Recursive Phase Continuity"'s claimed limit `L_infty` becomes existence
    of a limit for any monotone, bounded-above real sequence;
  * the App B chart-completion cluster (`appB_symbolic_chart`,
    `appB_metric_completion`, `appB_smooth_atlas`, `appB_smoothness_emergence`,
    `appB_resolution_of_smoothness`) is re-read over the certified
    `FracturedAtlas` chart-complex substrate rather than skipped outright:
    a single global metric compatible with every chart exists exactly when
    the charts are glued (`single_geometry_iff_glued`), and dually, no such
    global metric exists when they are not. Smoothness, second-countability,
    and paracompactness themselves are not modeled -- only the
    chart-consistency question the source poses on top of them.

Left open as genuinely narrative/non-formalizable in this kernel: the bare
operator-signature definitions (`bk9_orthogonal_time_component` through
`bk9_meta_operator_action`, `bk9_symbolic_operator` through
`bk9_reflective_initiation`, `bk9_frame_transversal_operator` through
`bk9_meta_reflective_alignment`), the naming-identity proposition
(`bk9_framework_functional_identity`), the symbolic-black-hole /
scarring / shame / masking / resilience / asymmetry / trust cluster (lists
of qualitative consequences with no independent quantified law), the
ethics-of-intervention and structural-compassion propositions (policy-style
enumerations), the reflective-dyad definition (a bare 5-tuple of abstract
components), the App B observer-relative metric definition
(`appB_observer_metric`, which needs a Lie-adjoint action and an SRV flow
neither modeled here nor elsewhere in this kernel), and the App D
"Titans as Arrow of Time" theorem (a citation-backed empirical claim about
external literature, not a mathematical statement).
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas
import ForcingAnalysis.Book4B

namespace ForcingAnalysis.Book9B

open Filter
open ForcingAnalysis.Atlas

/- ================================================================
   theorem:bk9_isolation_dissociation_theorem
   ================================================================ -/

/-- theorem:bk9_isolation_dissociation_theorem, the dominance half: if the
dominant mode's share `w` and the combined share `r` of every other mode
always sum to `1`, and the rivals' combined influence vanishes in the
limit, the dominant mode's share converges to the whole. -/
theorem dominant_share_tendsto_one {w r : Nat → Real} (hsum : ∀ t, w t + r t = 1)
    (hr : Tendsto r atTop (nhds 0)) : Tendsto w atTop (nhds 1) := by
  have heq : w = fun t => 1 - r t := by
    funext t
    have := hsum t
    linarith
  rw [heq]
  have h := (tendsto_const_nhds (x := (1 : Real)) (f := atTop)).sub hr
  simpa using h

/-- theorem:bk9_isolation_dissociation_theorem, the stagnation half: a
curvature sequence that is (via the structural necessity of
Cor.~bk1_non_euclidean_necessity) always bounded below by a fixed positive
amount cannot also converge to zero. Symbolic stagnation is therefore not a
reachable stable equilibrium, only an unreachable limit, exactly as the
source's closing remark says. -/
structure StructuralCurvatureBound where
  kappa : Nat → Real
  kappaMin : Real
  kappaMin_pos : 0 < kappaMin
  bounded_below : ∀ t, kappaMin ≤ kappa t

theorem curvature_cannot_vanish_under_structural_bound (c : StructuralCurvatureBound)
    (hvanish : Tendsto c.kappa atTop (nhds 0)) : False := by
  rw [Metric.tendsto_atTop] at hvanish
  obtain ⟨N, hN⟩ := hvanish c.kappaMin c.kappaMin_pos
  have h1 := hN N (le_refl N)
  rw [Real.dist_eq, sub_zero] at h1
  have h2 := c.bounded_below N
  have h3 : c.kappaMin ≤ |c.kappa N| := le_trans h2 (le_abs_self _)
  linarith

/- ================================================================
   definition:bk9_prompt_injection_operator
   ================================================================ -/

/-- definition:bk9_prompt_injection_operator's success condition: injection
succeeds exactly when the compressed history's strength overcomes the
incumbent frame's invasion barrier. -/
def InjectionSucceeds (strength barrier : Real) : Prop := barrier < strength

/-- Increasing the injected strength can only help, never hurt, whether the
injection succeeds. -/
theorem injectionSucceeds_mono {strength strength' barrier : Real}
    (hle : strength ≤ strength') (h : InjectionSucceeds strength barrier) :
    InjectionSucceeds strength' barrier :=
  lt_of_lt_of_le h hle

/- ================================================================
   definition:bk9_frame_selection_reflection
   ================================================================ -/

/-- definition:bk9_frame_selection_reflection: the honest finite kernel of
"select the frame minimizing symbolic free energy" is existence of an
argmin over a nonempty finite frame set -- dual to Book8's
`reflectiveSelection_exists` argmax. -/
theorem frameSelection_exists {ι : Type} (F : Finset ι) (hF : F.Nonempty)
    (freeEnergy : ι → Real) :
    ∃ f ∈ F, ∀ f' ∈ F, freeEnergy f ≤ freeEnergy f' :=
  F.exists_min_image freeEnergy hF

/- ================================================================
   definition:bk9_symbolic_empathy
   ================================================================ -/

/-- definition:bk9_symbolic_empathy's bounded-distortion claim composes: if
`A`'s model of `B` is within `delta1` and `B`'s model of `C` is within
`delta2`, `A`'s transitive model of `C` is within `delta1 + delta2`. -/
theorem empathy_distortion_triangle {X : Type} [PseudoMetricSpace X] (a b c : X)
    (delta1 delta2 : Real) (h1 : dist a b ≤ delta1) (h2 : dist b c ≤ delta2) :
    dist a c ≤ delta1 + delta2 :=
  le_trans (dist_triangle a b c) (add_le_add h1 h2)

/- ================================================================
   definition:bk9_index_of_narrative_fidelity
   ================================================================ -/

/-- The two-term skeleton of definition:bk9_index_of_narrative_fidelity: the
composite index, kept as identity-stability minus structural fragmentation
(the thermodynamic-trajectory and constraint-domain terms are not modeled
as independent quantities here). -/
def fidelityIndex (identity fragmentation : Real) : Real := identity - fragmentation

/-- "Adaptive self-editing preserves or enhances the fidelity measures":
raising identity stability and not raising fragmentation can only raise the
index. -/
theorem fidelityIndex_mono {identityBefore identityAfter fragBefore fragAfter : Real}
    (hid : identityBefore ≤ identityAfter) (hfrag : fragAfter ≤ fragBefore) :
    fidelityIndex identityBefore fragBefore ≤ fidelityIndex identityAfter fragAfter := by
  unfold fidelityIndex
  linarith

/-- "Pathological fragmentation degrades these measures beyond critical
thresholds": once fragmentation exceeds a critical threshold, the index
falls below the complementary bound, regardless of how close to maximal
identity stability is. -/
theorem fidelityIndex_degrades_beyond_threshold {identity fragmentation critFrag : Real}
    (hfrag : critFrag < fragmentation) (hident : identity ≤ 1) :
    fidelityIndex identity fragmentation < 1 - critFrag := by
  unfold fidelityIndex
  linarith

/- ================================================================
   proposition:bk9_mechanisms_of_recognition, lemma:bk9_mutual_convergence_criterion,
   proposition:bk9_emergence_of_shared_manifold, definition:bk9_two_way_street_operator,
   theorem:bk9_symbolic_thermostat, proposition:bk9_relational_freedom_via_thermoregulation
   ================================================================ -/

/-- The honest kernel shared by the whole "curvature alignment" / "two-way
street" / "mutual convergence" cluster: a contraction (with constant
`κ < 1`) has at most one fixed point. This is the uniqueness half of the
Banach fixed-point theorem; existence of the joint fixed point (needing a
completeness assumption on the interaction domain, not modeled here) is not
claimed. Item (i) of proposition:bk9_mechanisms_of_recognition takes `T` to
be the joint map `(x, y) ↦ (R_A y, R_B x)`; lemma:bk9_mutual_convergence_criterion
and definition:bk9_two_way_street_operator take `T` to be `Street_AB` itself. -/
theorem contraction_fixedPoint_unique {X : Type} [MetricSpace X] (T : X → X) (kappa : Real)
    (hkappa : kappa < 1) (hcontract : ∀ x y, dist (T x) (T y) ≤ kappa * dist x y)
    {x y : X} (hx : T x = x) (hy : T y = y) : x = y := by
  have h1 : dist x y ≤ kappa * dist x y := by
    calc dist x y = dist (T x) (T y) := by rw [hx, hy]
    _ ≤ kappa * dist x y := hcontract x y
  have h4 : dist x y ≤ 0 := by
    by_contra hcon
    push Not at hcon
    have hpos : 0 < (1 - kappa) * dist x y := mul_pos (by linarith) hcon
    nlinarith
  exact eq_of_dist_eq_zero (le_antisymm h4 dist_nonneg)

/-- proposition:bk9_emergence_of_shared_manifold: the reflexively stable
shared region is unique whenever the underlying two-way street operator is
contractive -- any two candidate fixed representatives `rho1*, rho2*`
coincide. -/
theorem sharedManifold_unique {X : Type} [MetricSpace X] (Street : X → X) (kappa : Real)
    (hkappa : kappa < 1) (hcontract : ∀ x y, dist (Street x) (Street y) ≤ kappa * dist x y)
    {rho1 rho2 : X} (h1 : Street rho1 = rho1) (h2 : Street rho2 = rho2) : rho1 = rho2 :=
  contraction_fixedPoint_unique Street kappa hkappa hcontract h1 h2

/- ================================================================
   axiom:bk9_preconditions_for_reciprocal_cognition
   ================================================================ -/

/-- axiom:bk9_preconditions_for_reciprocal_cognition, precondition (iv)
unfolded: the bounded alignment curvature condition `|kappa_AB| < eps_C`
gives the two-sided bound it already asserts. -/
theorem reciprocity_curvature_bounds {kappaAB epsC : Real} (h : |kappaAB| < epsC) :
    -epsC < kappaAB ∧ kappaAB < epsC :=
  abs_lt.mp h

/- ================================================================
   definition:bk9_grace_operator, proposition:bk9_grace_vs_avoidance,
   theorem:bk9_freedom_as_grace
   ================================================================ -/

/-- definition:bk9_grace_operator's stability-preservation clause, kept as a
structure field: grace maintains identity stability strictly above
`1 - epsilonCrit`. -/
structure GraceOperator where
  upsilon : Real
  epsilonCrit : Real
  epsilonCrit_pos : 0 < epsilonCrit
  epsilonCrit_lt_one : epsilonCrit < 1
  upsilon_bound : upsilon > 1 - epsilonCrit

/-- Grace never lets core identity stability reach zero: this is the
quantitative content behind "grace acts on non-flat tension rather than
erasing it" (also the load-bearing half of theorem:bk9_freedom_as_grace's
"sustain identity in the presence of unresolved contradiction", and the
distinguishing feature of Grace against the collapse-inducing Avoidance
alternative of proposition:bk9_grace_vs_avoidance). -/
theorem grace_upsilon_pos (g : GraceOperator) : 0 < g.upsilon := by
  have h : 0 < 1 - g.epsilonCrit := by linarith [g.epsilonCrit_lt_one]
  linarith [g.upsilon_bound]

/-- The complete three-part operational payload stated by
`theorem:bk9_freedom_as_grace`. Book 4 supplies constraint-transforming flow;
Book 9 adds the terminal Grace capacities: identity is held under unresolved
contradiction, reflective barriers can be intentionally lowered, and a
transient free-energy cost can be accepted for an expansion of viability. -/
structure GracefulFreedomCapacity extends GraceOperator where
  contradictionUnresolved : Prop
  holdsContradiction : contradictionUnresolved
  reflectiveBarrierBefore : Real
  reflectiveBarrierAfter : Real
  lowersReflectiveBarrier : reflectiveBarrierAfter < reflectiveBarrierBefore
  deltaFreeEnergy : Real
  deltaViability : Real
  acceptsTransientCost : 0 < deltaFreeEnergy
  expandsViability : 0 < deltaViability

/-- Full graceful capacity exposes all three abilities enumerated by the
terminal Book 9 freedom theorem. -/
theorem gracefulFreedomCapacity_components (g : GracefulFreedomCapacity) :
    0 < g.upsilon ∧ g.contradictionUnresolved ∧
      g.reflectiveBarrierAfter < g.reflectiveBarrierBefore ∧
      0 < g.deltaFreeEnergy ∧ 0 < g.deltaViability := by
  exact ⟨grace_upsilon_pos g.toGraceOperator, g.holdsContradiction,
    g.lowersReflectiveBarrier, g.acceptsTransientCost, g.expandsViability⟩

/-- The manuscript's maximal-freedom iff Grace claim needs an explicit bridge
between a system's Book 9 maximality order and deployable graceful capacity.
The bridge is retained as named data rather than manufactured from Book 4. -/
structure MaximalFreedomGraceBridge (System : Type) where
  maximalCognitiveFreedom : System → Prop
  canDeployGrace : System → GracefulFreedomCapacity → Prop
  correspondence : ∀ system,
    maximalCognitiveFreedom system ↔ ∃ grace, canDeployGrace system grace

theorem maximalFreedom_iff_canDeployGrace {System : Type}
    (bridge : MaximalFreedomGraceBridge System) (system : System) :
    bridge.maximalCognitiveFreedom system ↔
      ∃ grace, bridge.canDeployGrace system grace :=
  bridge.correspondence system

/-- Book 4 flow freedom is genuine input material but does not, without the
Book 9 bridge, force terminal maximal freedom. The Boolean witness preserves
coherence and crosses a proper constraint boundary while an independently
specified terminal-maximality proposition remains false. -/
theorem book4_flow_freedom_does_not_force_terminal_maximality :
    ∃ (Φ R : Bool → Bool) (Ψ : Bool) (U0 : Set Bool)
      (terminalMaximal : Prop),
      Book4B.SymbolicFlowFreedom Φ R Ψ U0 ∧ ¬ terminalMaximal := by
  let flip : Bool → Bool := fun b => !b
  let U0 : Set Bool := {false}
  refine ⟨flip, id, false, U0, False, ?_, by simp⟩
  exact ⟨rfl, false, by simp [U0], by simp [U0, flip]⟩

/-- The two terminal abilities not contained in the original identity-stability
fragment of `GraceOperator`. Keeping them typed prevents a positive identity
bound from silently being reused as evidence for barrier modulation or
viability-expanding costly transformation. -/
structure GraceContinuationCapabilities where
  canLowerReflectiveBarriers : Prop
  canAcceptCostForViability : Prop

def CompletesGrace (capabilities : GraceContinuationCapabilities) : Prop :=
  capabilities.canLowerReflectiveBarriers ∧
    capabilities.canAcceptCostForViability

/-- The identity-stability fragment previously formalized for Grace cannot by
itself supply the other two enumerated abilities. This concrete Grace operator
satisfies its identity bound while a concrete capability record supplies
neither missing operation. -/
theorem grace_identity_bound_alone_does_not_force_full_capacity :
    ∃ (g : GraceOperator) (capabilities : GraceContinuationCapabilities),
      0 < g.upsilon ∧ ¬ CompletesGrace capabilities := by
  let g : GraceOperator :=
    { upsilon := 1
      epsilonCrit := 1 / 2
      epsilonCrit_pos := by norm_num
      epsilonCrit_lt_one := by norm_num
      upsilon_bound := by norm_num }
  let capabilities : GraceContinuationCapabilities :=
    { canLowerReflectiveBarriers := False
      canAcceptCostForViability := False }
  exact ⟨g, capabilities, grace_upsilon_pos g, by
    simp [CompletesGrace, capabilities]⟩

/- ================================================================
   theorem:bk9_irreversibility_of_covenant_breach_without_grace
   ================================================================ -/

/-- theorem:bk9_irreversibility_of_covenant_breach_without_grace's dynamics:
while grace is withheld at a step, the joint viability domain strictly
contracts by a fixed amount (the Book8 metabolic-sufficiency pattern,
reused for the covenant-viability sequence). -/
structure CovenantDynamics where
  viability : Nat → Real
  deltaV : Real
  deltaV_pos : 0 < deltaV
  graceApplied : Nat → Prop
  decreasing : ∀ k, ¬ graceApplied k → viability (k + 1) ≤ viability k - deltaV

/-- Telescoped viability-decrease bound over any run of steps without
grace, by induction. -/
theorem covenant_viability_decrease_accum (c : CovenantDynamics) (n : Nat)
    (hng : ∀ k, k < n → ¬ c.graceApplied k) :
    c.viability n ≤ c.viability 0 - (n : Real) * c.deltaV := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hk : ∀ j, j < k → ¬ c.graceApplied j := fun j hj => hng j (Nat.lt_succ_of_lt hj)
      have hstep := c.decreasing k (hng k (Nat.lt_succ_self k))
      have hcast : ((k + 1 : Nat) : Real) * c.deltaV = (k : Real) * c.deltaV + c.deltaV := by
        push_cast; ring
      rw [hcast]
      have ihk := ih hk
      linarith

/-- theorem:bk9_irreversibility_of_covenant_breach_without_grace, the
collapse consequence: persistently withholding grace forces the trajectory
below any fixed collapse threshold once enough steps have elapsed. -/
theorem covenant_breach_forces_collapse_without_grace (c : CovenantDynamics) (n : Nat)
    (hng : ∀ k, k < n → ¬ c.graceApplied k) (collapseThreshold : Real)
    (hn : c.viability 0 - (n : Real) * c.deltaV < collapseThreshold) :
    c.viability n < collapseThreshold :=
  lt_of_le_of_lt (covenant_viability_decrease_accum c n hng) hn

/- ================================================================
   proposition:bk9_stability_conditions_for_the_good, theorem:bk9_good_as_lyapunov_basin
   ================================================================ -/

/-- theorem:bk9_good_as_lyapunov_basin's descent step, kept as a structure
field rather than derived from an actual gradient: the standard smooth
gradient-descent step-size condition (`0 < eta`, `eta * smooth < 2`)
together with the quadratic descent inequality that condition licenses. -/
structure LyapunovDescent where
  L : Nat → Real
  grad : Nat → Real
  eta : Real
  eta_pos : 0 < eta
  smooth : Real
  smooth_pos : 0 < smooth
  eta_bound : eta * smooth < 2
  descent_ineq : ∀ t, L (t + 1) ≤ L t - eta * (1 - eta * smooth / 2) * (grad t) ^ 2

/-- `V := L_tot` is a Lyapunov function for the descent: one step never
increases it. -/
theorem lyapunov_step_le (d : LyapunovDescent) (t : Nat) : d.L (t + 1) ≤ d.L t := by
  have hpos : 0 < 1 - d.eta * d.smooth / 2 := by linarith [d.eta_bound]
  have hcoef : 0 ≤ d.eta * (1 - d.eta * d.smooth / 2) := le_of_lt (mul_pos d.eta_pos hpos)
  have hnn : 0 ≤ d.eta * (1 - d.eta * d.smooth / 2) * (d.grad t) ^ 2 :=
    mul_nonneg hcoef (sq_nonneg _)
  linarith [d.descent_ineq t]

/-- The equality case of the Lyapunov descent is exactly the critical set:
whenever the gradient is nonzero, the step is a strict decrease. Together
with `lyapunov_step_le` this is the honest kernel of "`Delta V <= 0`, with
equality only at the critical set `grad L_tot = 0`" -- the setup for this
theorem is proposition:bk9_stability_conditions_for_the_good's four
stability conditions, whose basin-of-attraction claim this descent lemma
underwrites. -/
theorem lyapunov_strict_decrease_of_nonzero_grad (d : LyapunovDescent) (t : Nat)
    (hg : d.grad t ≠ 0) : d.L (t + 1) < d.L t := by
  have hpos : 0 < 1 - d.eta * d.smooth / 2 := by linarith [d.eta_bound]
  have hcoef : 0 < d.eta * (1 - d.eta * d.smooth / 2) := mul_pos d.eta_pos hpos
  have hsq : 0 < (d.grad t) ^ 2 := by
    rw [pow_two]
    rcases lt_or_gt_of_ne hg with h | h
    · exact mul_pos_of_neg_of_neg h h
    · exact mul_pos h h
  have hstrict : 0 < d.eta * (1 - d.eta * d.smooth / 2) * (d.grad t) ^ 2 := mul_pos hcoef hsq
  linarith [d.descent_ineq t]

/- ================================================================
   axiom:bk9_recursive_phase_continuity
   ================================================================ -/

/-- axiom:bk9_recursive_phase_continuity's claimed limit `L_infty`, kept
honest: a monotone, bounded-above real sequence of meta-alignment quality
converges. -/
structure MetaAlignmentSequence where
  q : Nat → Real
  mono : Monotone q
  bddAbove : BddAbove (Set.range q)

theorem metaAlignment_converges (m : MetaAlignmentSequence) :
    ∃ L, Tendsto m.q atTop (nhds L) :=
  ⟨_, tendsto_atTop_ciSup m.mono m.bddAbove⟩

/- ================================================================
   definition:appB_symbolic_chart, theorem:appB_metric_completion,
   theorem:appB_smooth_atlas, theorem:appB_smoothness_emergence,
   corollary:appB_resolution_of_smoothness
   ================================================================ -/

/-- The App B chart-completion cluster, re-read over the certified
`FracturedAtlas` chart-complex substrate rather than over an unmodeled
metric-completion/manifold construction: whenever every pair of points
shares a chart and the charts are glued, a single global metric consistent
with every chart exists. This is the honest stand-in for
"the metric completion exists", "the charts coordinatize the completion",
and "the completion admits a compatible smooth atlas" -- separability,
smoothness, second-countability, and paracompactness are not modeled;
only the chart-consistency question underneath them is. -/
theorem atlas_consistent_of_glued_and_covers {X : Type*} (C : ChartComplex X)
    (hPC : PairCovers C) (hG : Glued C) : ∃ D, Consistent C D :=
  (single_geometry_iff_glued hPC).mpr hG

/-- theorem:appB_smoothness_emergence / corollary:appB_resolution_of_smoothness,
the converse direction: if the charts are not glued, no single global metric
compatible with all of them exists -- "smooth structure arises... under
bounded observer resolution" fails exactly when that resolution is not
consistent across charts. -/
theorem no_global_metric_without_gluing {X : Type*} (C : ChartComplex X)
    (hPC : PairCovers C) (hNG : ¬ Glued C) : ¬ ∃ D, Consistent C D := by
  intro h
  exact hNG ((single_geometry_iff_glued hPC).mp h)

end ForcingAnalysis.Book9B
