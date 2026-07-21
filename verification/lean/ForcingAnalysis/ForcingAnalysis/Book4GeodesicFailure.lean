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

/-! ### Typed common-fibre Jacobi certificate -/

/-- Observer and covariant accelerations together with the oriented curvature
action in one common normed fibre. The Jacobi equation is explicit data; it
is not inferred from the norm diagnostic. -/
structure JacobiCertificate (V : Type*) [NormedAddCommGroup V] where
  observerSecondDerivative : V
  covariantAcceleration : V
  curvatureAction : V
  jacobi : covariantAcceleration + curvatureAction = 0

/-- The sign of the curvature action comes from the chosen Jacobi convention. -/
theorem JacobiCertificate.acceleration_eq_neg_curvature
    {V : Type*} [NormedAddCommGroup V] (J : JacobiCertificate V) :
    J.covariantAcceleration = -J.curvatureAction := by
  exact eq_neg_of_add_eq_zero_left J.jacobi

/-- General common-fibre version of the observer diagnostic estimate. -/
theorem norm_sq_error_bound
    {V : Type*} [NormedAddCommGroup V]
    {observerD covariantD : V} {epsilon : ℝ}
    (hApprox : ‖observerD - covariantD‖ ≤ epsilon) :
    |‖observerD‖ ^ 2 - ‖covariantD‖ ^ 2| ≤
      epsilon * (‖observerD‖ + ‖covariantD‖) := by
  calc
    |‖observerD‖ ^ 2 - ‖covariantD‖ ^ 2| =
        |‖observerD‖ - ‖covariantD‖| *
          (‖observerD‖ + ‖covariantD‖) := by
            rw [sq_sub_sq, abs_mul]
            rw [abs_of_nonneg
              (add_nonneg (norm_nonneg observerD) (norm_nonneg covariantD))]
            exact mul_comm _ _
    _ ≤ ‖observerD - covariantD‖ *
          (‖observerD‖ + ‖covariantD‖) := by
            exact mul_le_mul_of_nonneg_right
              (abs_norm_sub_norm_le observerD covariantD)
              (add_nonneg (norm_nonneg _) (norm_nonneg _))
    _ ≤ epsilon * (‖observerD‖ + ‖covariantD‖) := by
            exact mul_le_mul_of_nonneg_right hApprox
              (add_nonneg (norm_nonneg _) (norm_nonneg _))

/-- Uniform derivative bounds turn the magnitude-sensitive estimate into the
source's explicit `2 B epsilon` corollary. -/
theorem norm_sq_error_bound_of_uniform
    {V : Type*} [NormedAddCommGroup V]
    {observerD covariantD : V} {epsilon B : ℝ}
    (hApprox : ‖observerD - covariantD‖ ≤ epsilon)
    (hObserver : ‖observerD‖ ≤ B) (hCovariant : ‖covariantD‖ ≤ B) :
    |‖observerD‖ ^ 2 - ‖covariantD‖ ^ 2| ≤ 2 * B * epsilon := by
  have hε : 0 ≤ epsilon := le_trans (norm_nonneg _) hApprox
  calc
    |‖observerD‖ ^ 2 - ‖covariantD‖ ^ 2| ≤
        epsilon * (‖observerD‖ + ‖covariantD‖) :=
      norm_sq_error_bound hApprox
    _ ≤ epsilon * (B + B) := by
      exact mul_le_mul_of_nonneg_left (add_le_add hObserver hCovariant) hε
    _ = 2 * B * epsilon := by ring
/-- Complete realization of the repaired conditional Jacobi diagnostic: the
chosen orientation fixes acceleration as negative curvature action, the
observer approximation controls the squared diagnostic, and uniform magnitude
bounds yield the stated `2 * B * epsilon` estimate. -/
theorem JacobiCertificate.observer_diagnostic_certificate
    {V : Type*} [NormedAddCommGroup V] (J : JacobiCertificate V)
    {epsilon B : ℝ}
    (hApprox : ‖J.observerSecondDerivative - J.covariantAcceleration‖ ≤ epsilon)
    (hObserver : ‖J.observerSecondDerivative‖ ≤ B)
    (hCovariant : ‖J.covariantAcceleration‖ ≤ B) :
    J.covariantAcceleration = -J.curvatureAction ∧
      |‖J.observerSecondDerivative‖ ^ 2 -
        ‖J.covariantAcceleration‖ ^ 2| ≤
          epsilon * (‖J.observerSecondDerivative‖ +
            ‖J.covariantAcceleration‖) ∧
      |‖J.observerSecondDerivative‖ ^ 2 -
        ‖J.covariantAcceleration‖ ^ 2| ≤ 2 * B * epsilon := by
  exact ⟨J.acceleration_eq_neg_curvature,
    norm_sq_error_bound hApprox,
    norm_sq_error_bound_of_uniform hApprox hObserver hCovariant⟩
end ForcingAnalysis.Book4GeodesicFailure
