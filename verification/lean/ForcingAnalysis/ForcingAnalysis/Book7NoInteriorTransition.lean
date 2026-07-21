/- Book7NoInteriorTransition.lean — continuous sweep versus discrete transition. -/
import Mathlib

namespace ForcingAnalysis.Book7NoInteriorTransition

/-- A discrete phase transition within a sweep domain is represented by failure
of continuity relative to that domain. -/
def HasDiscretePhaseTransitionWithinAt
    (geometry : ℝ → ℝ) (domain : Set ℝ) (point : ℝ) : Prop :=
  ¬ ContinuousWithinAt geometry domain point

/-- The topological kernel of the Book 7 corollary: a continuous effective
geometry has no discrete phase transition at any point of the sub-sweep. -/
theorem continuousOn_no_discrete_phase_transition
    {geometry : ℝ → ℝ} {domain : Set ℝ}
    (hgeometry : ContinuousOn geometry domain) {point : ℝ}
    (hpoint : point ∈ domain) :
    ¬ HasDiscretePhaseTransitionWithinAt geometry domain point := by
  simp [HasDiscretePhaseTransitionWithinAt, hgeometry point hpoint]

/-- Specialized to the closed observer sweep used by the source. -/
theorem continuous_closed_sweep_has_no_interior_transition
    {geometry : ℝ → ℝ} {ξ₀ ξ₁ point : ℝ}
    (hgeometry : ContinuousOn geometry (Set.Icc ξ₀ ξ₁))
    (hpoint : point ∈ Set.Icc ξ₀ ξ₁) :
    ¬ HasDiscretePhaseTransitionWithinAt geometry (Set.Icc ξ₀ ξ₁) point :=
  continuousOn_no_discrete_phase_transition hgeometry hpoint

/-- A continuous reparameterization preserves the no-transition certificate. -/
theorem continuous_reparameterization_preserves_no_transition
    {geometry parameter : ℝ → ℝ} {source target : Set ℝ}
    (hparameter : ContinuousOn parameter source)
    (himage : Set.MapsTo parameter source target)
    (hgeometry : ContinuousOn geometry target) :
    ContinuousOn (geometry ∘ parameter) source := by
  exact hgeometry.comp hparameter himage

/-- The numerical threshold can yield continuity only through an explicit
curvature-to-regularity bridge; the inequality is passed to that bridge. -/
theorem continuity_from_threshold_bridge
    {curvature threshold : ℝ} {geometry : ℝ → ℝ} {domain : Set ℝ}
    (hcurvature : curvature < threshold)
    (bridge : curvature < threshold → ContinuousOn geometry domain) :
    ContinuousOn geometry domain :=
  bridge hcurvature

/-- A concrete subcritical effective geometry: the observed signal is amplified
by the reciprocal curvature margin. The denominator records why approaching
the critical threshold can destroy regularity. -/
noncomputable def regularizedGeometry
    (curvature signal : ℝ → ℝ) (threshold : ℝ) (ξ : ℝ) : ℝ :=
  signal ξ / (threshold - curvature ξ)

/-- For the explicit resolvent-style geometry, a continuous curvature path and
signal path plus a pointwise subcritical margin construct the missing
curvature-to-regularity bridge. This is an analytic instance, not a claim that
every effective geometry has this representation. -/
theorem regularizedGeometry_continuousOn
    {curvature signal : ℝ → ℝ} {threshold : ℝ} {domain : Set ℝ}
    (hcurvature : ContinuousOn curvature domain)
    (hsignal : ContinuousOn signal domain)
    (hsubcritical : ∀ ξ ∈ domain, curvature ξ < threshold) :
    ContinuousOn (regularizedGeometry curvature signal threshold) domain := by
  unfold regularizedGeometry
  apply hsignal.div (continuousOn_const.sub hcurvature)
  intro ξ hξ
  exact ne_of_gt (sub_pos.mpr (hsubcritical ξ hξ))

/-- The constructed regularity bridge excludes every discrete transition in
the certified subcritical sweep. -/
theorem regularizedGeometry_has_no_interior_transition
    {curvature signal : ℝ → ℝ} {threshold ξ₀ ξ₁ point : ℝ}
    (hcurvature : ContinuousOn curvature (Set.Icc ξ₀ ξ₁))
    (hsignal : ContinuousOn signal (Set.Icc ξ₀ ξ₁))
    (hsubcritical : ∀ ξ ∈ Set.Icc ξ₀ ξ₁, curvature ξ < threshold)
    (hpoint : point ∈ Set.Icc ξ₀ ξ₁) :
    ¬ HasDiscretePhaseTransitionWithinAt
      (regularizedGeometry curvature signal threshold)
      (Set.Icc ξ₀ ξ₁) point := by
  exact continuous_closed_sweep_has_no_interior_transition
    (regularizedGeometry_continuousOn hcurvature hsignal hsubcritical) hpoint

/-- A constructive scalar coordinate for the subcritical `L^p` geometry. It is
Hilbertian at zero curvature and becomes singular when the curvature margin
closes. This represents the `p`-coordinate, not every datum of the ambient
geometry object. -/
noncomputable def subcriticalLpExponent
    (curvature : ℝ → ℝ) (threshold : ℝ) (ξ : ℝ) : ℝ :=
  2 + curvature ξ / (threshold - curvature ξ)

theorem subcriticalLpExponent_zero_curvature
    {curvature : ℝ → ℝ} {threshold ξ : ℝ}
    (hzero : curvature ξ = 0) :
    subcriticalLpExponent curvature threshold ξ = 2 := by
  simp [subcriticalLpExponent, hzero]

/-- The curvature path itself now constructs the continuous `p`-sweep; no
separate signal or opaque representation function is required. -/
theorem subcriticalLpExponent_continuousOn
    {curvature : ℝ → ℝ} {threshold : ℝ} {domain : Set ℝ}
    (hcurvature : ContinuousOn curvature domain)
    (hsubcritical : ∀ ξ ∈ domain, curvature ξ < threshold) :
    ContinuousOn (subcriticalLpExponent curvature threshold) domain := by
  unfold subcriticalLpExponent
  apply continuousOn_const.add
  apply hcurvature.div (continuousOn_const.sub hcurvature)
  intro ξ hξ
  exact ne_of_gt (sub_pos.mpr (hsubcritical ξ hξ))

/-- With positive critical curvature, the constructed coordinate preserves
strict curvature order throughout the subcritical regime. -/
theorem subcriticalLpExponent_strict_order
    {curvature : ℝ → ℝ} {threshold ξ η : ℝ}
    (hthreshold : 0 < threshold)
    (hξη : curvature ξ < curvature η)
    (hη : curvature η < threshold) :
    subcriticalLpExponent curvature threshold ξ <
      subcriticalLpExponent curvature threshold η := by
  have hξ : curvature ξ < threshold := lt_trans hξη hη
  unfold subcriticalLpExponent
  simp only [add_lt_add_iff_left]
  rw [div_lt_div_iff₀ (sub_pos.mpr hξ) (sub_pos.mpr hη)]
  nlinarith

/-- The constructed curvature-indexed `p`-representation has no interior
transition anywhere that the curvature path remains continuous and uniformly
subcritical. -/
theorem subcriticalLpExponent_has_no_interior_transition
    {curvature : ℝ → ℝ} {threshold ξ₀ ξ₁ point : ℝ}
    (hcurvature : ContinuousOn curvature (Set.Icc ξ₀ ξ₁))
    (hsubcritical : ∀ ξ ∈ Set.Icc ξ₀ ξ₁, curvature ξ < threshold)
    (hpoint : point ∈ Set.Icc ξ₀ ξ₁) :
    ¬ HasDiscretePhaseTransitionWithinAt
      (subcriticalLpExponent curvature threshold)
      (Set.Icc ξ₀ ξ₁) point := by
  exact continuous_closed_sweep_has_no_interior_transition
    (subcriticalLpExponent_continuousOn hcurvature hsubcritical) hpoint
end ForcingAnalysis.Book7NoInteriorTransition
