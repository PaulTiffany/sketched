/-
Book4GeodesicFailure.lean — scalar norm-square stability kernel and premise
audit for the geodesic interpretation of symbolic curvature in Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4GeodesicFailure

/-- Scalar shadow of the observer curvature diagnostic ‖δ²J‖². -/
def observerCurvature (observerSecondDerivative : ℝ) : ℝ :=
  observerSecondDerivative ^ 2

/-- Scalar shadow of the connection-relative acceleration diagnostic ‖∇²J‖². -/
def connectionCurvature (covariantSecondDerivative : ℝ) : ℝ :=
  covariantSecondDerivative ^ 2

theorem observerCurvature_nonneg (d : ℝ) : 0 ≤ observerCurvature d := by
  exact sq_nonneg d

theorem observerCurvature_eq_zero_iff (d : ℝ) :
    observerCurvature d = 0 ↔ d = 0 := by
  simp [observerCurvature]

/-- Error propagation through the squared-norm curvature diagnostic. The
observer error is amplified by the combined derivative magnitude. -/
theorem curvature_error_bound {observerD covariantD epsilon : ℝ}
    (hApprox : |observerD - covariantD| ≤ epsilon) :
    |observerCurvature observerD - connectionCurvature covariantD| ≤
      epsilon * (|observerD| + |covariantD|) := by
  calc
    |observerCurvature observerD - connectionCurvature covariantD| =
        |observerD - covariantD| * |observerD + covariantD| := by
          rw [observerCurvature, connectionCurvature]
          rw [sq_sub_sq, abs_mul]
          ring
    _ ≤ epsilon * |observerD + covariantD| := by
          exact mul_le_mul_of_nonneg_right hApprox (abs_nonneg _)
    _ ≤ epsilon * (|observerD| + |covariantD|) := by
          have hEpsilon : 0 ≤ epsilon := le_trans (abs_nonneg _) hApprox
          exact mul_le_mul_of_nonneg_left (abs_add_le _ _) hEpsilon

/-- A bound on δ²J-∇²J alone does not establish the Jacobi equation or identify
∇²J with a Riemann-curvature term. The data can agree perfectly while an
independently supplied curvature term disagrees. -/
theorem derivative_agreement_does_not_force_jacobi_curvature :
    ∃ (observerD covariantD riemannTerm : ℝ),
      |observerD - covariantD| = 0 ∧ covariantD + riemannTerm ≠ 0 := by
  exact ⟨1, 1, 0, by norm_num, by norm_num⟩

end ForcingAnalysis.Book4GeodesicFailure
