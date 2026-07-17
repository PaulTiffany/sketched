/- Book6DriftMutation.lean — finite drift/curvature mutation-rate kernel. -/
import Mathlib

namespace ForcingAnalysis.Book6DriftMutation

/-- Finite analogue of the source integral: mutation rate is the density-
weighted magnitude of curvature change along drift. -/
def mutationRate {Point Tangent : Type*} [Fintype Point]
    [Norm Tangent] (density : Point → ℝ)
    (curvatureChangeAlongDrift : Point → Tangent) : ℝ :=
  ∑ point, density point * ‖curvatureChangeAlongDrift point‖

theorem mutationRate_eq_weighted_curvature_change
    {Point Tangent : Type*} [Fintype Point] [Norm Tangent]
    (density : Point → ℝ) (curvatureChangeAlongDrift : Point → Tangent) :
    mutationRate density curvatureChangeAlongDrift =
      ∑ point, density point * ‖curvatureChangeAlongDrift point‖ :=
  rfl

/-- Nonnegative symbolic density gives a nonnegative mutation rate. -/
theorem mutationRate_nonneg {Point Tangent : Type*} [Fintype Point]
    [SeminormedAddCommGroup Tangent] {density : Point → ℝ}
    (hdensity : ∀ point, 0 ≤ density point)
    (curvatureChangeAlongDrift : Point → Tangent) :
    0 ≤ mutationRate density curvatureChangeAlongDrift := by
  apply Finset.sum_nonneg
  intro point _
  exact mul_nonneg (hdensity point) (norm_nonneg _)

/-- For a normalized density, a uniform bound on directional curvature change
is inherited by the global mutation rate. -/
theorem mutationRate_le_uniform_curvature_bound
    {Point Tangent : Type*} [Fintype Point]
    [SeminormedAddCommGroup Tangent] {density : Point → ℝ}
    {curvatureChangeAlongDrift : Point → Tangent} {bound : ℝ}
    (hdensity : ∀ point, 0 ≤ density point)
    (hnormalized : ∑ point, density point = 1)
    (hbound : ∀ point, ‖curvatureChangeAlongDrift point‖ ≤ bound) :
    mutationRate density curvatureChangeAlongDrift ≤ bound := by
  unfold mutationRate
  calc
    ∑ point, density point * ‖curvatureChangeAlongDrift point‖ ≤
        ∑ point, density point * bound := by
      apply Finset.sum_le_sum
      intro point _
      exact mul_le_mul_of_nonneg_left (hbound point) (hdensity point)
    _ = bound := by rw [← Finset.sum_mul, hnormalized, one_mul]

/-- A drift label alone does not determine mutation rate: with the same density
and drift, different curvature responses yield different rates. -/
theorem drift_alone_does_not_determine_mutation_rate :
    let density : Fin 1 → ℝ := fun _ => 1
    let zeroResponse : Fin 1 → ℝ := fun _ => 0
    let unitResponse : Fin 1 → ℝ := fun _ => 1
    mutationRate density zeroResponse = 0 ∧
      mutationRate density unitResponse = 1 := by
  simp [mutationRate]

end ForcingAnalysis.Book6DriftMutation
