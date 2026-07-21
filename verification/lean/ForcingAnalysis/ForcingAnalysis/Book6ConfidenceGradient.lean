/- Book6ConfidenceGradient.lean — confidence-driven mutation velocity kernel. -/
import Mathlib

open scoped RealInnerProductSpace

namespace ForcingAnalysis.Book6ConfidenceGradient

/-- Scalar chart of the printed confidence-gradient mutation law. -/
def confidenceDrivenVelocity (drift diffusion confidenceGradient
    confidenceLaplacian fluctuation : ℝ) : ℝ :=
  -drift * confidenceGradient +
    diffusion * confidenceLaplacian + fluctuation

theorem confidenceDrivenVelocity_eq (drift diffusion confidenceGradient
    confidenceLaplacian fluctuation : ℝ) :
    confidenceDrivenVelocity drift diffusion confidenceGradient
      confidenceLaplacian fluctuation =
      -drift * confidenceGradient +
        diffusion * confidenceLaplacian + fluctuation :=
  rfl

/-- With diffusion and noise absent, positive drift coefficient makes the
velocity non-increasing along confidence. -/
theorem pure_confidence_drift_descends {drift confidenceGradient : ℝ}
    (hdrift : 0 ≤ drift) :
    confidenceDrivenVelocity drift 0 confidenceGradient 0 0 *
      confidenceGradient ≤ 0 := by
  simp only [confidenceDrivenVelocity, mul_zero, add_zero]
  nlinarith [mul_nonneg hdrift (sq_nonneg confidenceGradient)]

/-- The descent is strict away from confidence-critical points when the drift
coefficient is strictly positive. -/
theorem pure_confidence_drift_strict {drift confidenceGradient : ℝ}
    (hdrift : 0 < drift) (hgradient : confidenceGradient ≠ 0) :
    confidenceDrivenVelocity drift 0 confidenceGradient 0 0 *
      confidenceGradient < 0 := by
  simp only [confidenceDrivenVelocity, mul_zero, add_zero]
  have hsquare : 0 < confidenceGradient ^ 2 := sq_pos_of_ne_zero hgradient
  nlinarith [mul_pos hdrift hsquare]

/-- Diffusion may overcome the confidence-descent term, so the full equation
does not generally point toward lower confidence. -/
theorem diffusion_can_reverse_confidence_drift :
    confidenceDrivenVelocity 1 2 1 1 0 = 1 := by
  norm_num [confidenceDrivenVelocity]

/-- Smooth confidence data and a regular nonzero gradient do not manufacture
the printed mutation dynamics: a stationary path can violate its velocity law. -/
theorem regularity_alone_does_not_force_confidence_dynamics :
    (0 : ℝ) ≠ confidenceDrivenVelocity 1 0 1 0 0 := by
  norm_num [confidenceDrivenVelocity]


/-- Typed confidence-gradient velocity with all diffusion/noise effects retained
as a perturbation vector. -/
def confidenceVelocity {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    (drift : ℝ) (gradient perturbation : V) : V :=
  (-drift) • gradient + perturbation

/-- Directional confidence descent holds exactly under a quantitative bound on
the perturbation component along the gradient. -/
theorem confidenceVelocity_descends_of_perturbation_control
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    {drift : ℝ} {gradient perturbation : V}
    (hcontrol : inner ℝ perturbation gradient ≤ drift * ‖gradient‖ ^ 2) :
    inner ℝ (confidenceVelocity drift gradient perturbation) gradient ≤ 0 := by
  rw [confidenceVelocity, inner_add_left, real_inner_smul_left]
  rw [real_inner_self_eq_norm_sq]
  nlinarith

/-- If perturbation is strictly dominated in the gradient direction, descent
is strict without pretending diffusion or noise vanished. -/
theorem confidenceVelocity_strictly_descends_of_strict_control
    {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    {drift : ℝ} {gradient perturbation : V}
    (hcontrol : inner ℝ perturbation gradient < drift * ‖gradient‖ ^ 2) :
    inner ℝ (confidenceVelocity drift gradient perturbation) gradient < 0 := by
  rw [confidenceVelocity, inner_add_left, real_inner_smul_left]
  rw [real_inner_self_eq_norm_sq]
  nlinarith

end ForcingAnalysis.Book6ConfidenceGradient
