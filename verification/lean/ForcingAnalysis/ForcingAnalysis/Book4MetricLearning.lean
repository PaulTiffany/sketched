/-
Book4MetricLearning.lean — gradient-step kernel and premise audit for machine
learning of the observer metric in Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4MetricLearning

/-- Scalar parameter shadow of a metric-learning gradient step. -/
def gradientStep (theta eta gradient : ℝ) : ℝ :=
  theta - eta * gradient

/-- With nonzero learning rate, a gradient step is stationary exactly at a
critical point. -/
theorem gradientStep_eq_self_iff {theta eta gradient : ℝ} (hEta : eta ≠ 0) :
    gradientStep theta eta gradient = theta ↔ gradient = 0 := by
  unfold gradientStep
  constructor
  · intro h
    apply (mul_eq_zero.mp (by linarith : eta * gradient = 0)).resolve_left hEta
  · rintro rfl
    ring

/-- For the quadratic local loss L(theta)=theta², a step size strictly between
zero and one gives strict descent away from the optimum. -/
theorem quadratic_gradient_step_decreases
    {theta eta : ℝ} (hTheta : theta ≠ 0) (hEtaPos : 0 < eta) (hEtaLt : eta < 1) :
    (gradientStep theta eta (2 * theta)) ^ 2 < theta ^ 2 := by
  unfold gradientStep
  have hThetaSq : 0 < theta ^ 2 := sq_pos_of_ne_zero hTheta
  have hFactor : (1 - 2 * eta) ^ 2 < 1 := by nlinarith [mul_pos hEtaPos (sub_pos.mpr hEtaLt)]
  nlinarith [mul_lt_mul_of_pos_right hFactor hThetaSq]

/-- Differentiability alone does not make an arbitrary positive learning rate
a descent method: an oversized quadratic step increases loss. -/
theorem differentiability_alone_does_not_guarantee_descent :
    let theta : ℝ := 1
    let eta : ℝ := 2
    (gradientStep theta eta (2 * theta)) ^ 2 > theta ^ 2 := by
  norm_num [gradientStep]

end ForcingAnalysis.Book4MetricLearning
