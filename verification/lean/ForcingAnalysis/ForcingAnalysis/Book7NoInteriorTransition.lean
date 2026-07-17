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

end ForcingAnalysis.Book7NoInteriorTransition
