/-
Book5EquilibriumConservation.lean — premise audit and corrected residual bound
for reflective equilibrium conservation in Principia Symbolica Book 5.
-/
import Mathlib

namespace ForcingAnalysis.Book5EquilibriumConservation

/-- In the scalar residual model, total energy-rate defect is the sum of the
two uncompensated drift/reflection residuals. -/
def energyRateDefect (residualA residualB : ℝ) : ℝ := residualA + residualB

/-- The two source residual estimates imply a linear spectral-radius bound. -/
theorem energy_rate_linear_spectral_bound
    {residualA residualB rho normA normB : ℝ}
    (hA : |residualA| ≤ rho * normA)
    (hB : |residualB| ≤ rho * normB) :
    |energyRateDefect residualA residualB| ≤ rho * (normA + normB) := by
  calc
    |energyRateDefect residualA residualB| = |residualA + residualB| := rfl
    _ ≤ |residualA| + |residualB| := abs_add_le _ _
    _ ≤ rho * normA + rho * normB := add_le_add hA hB
    _ = rho * (normA + normB) := by ring

/-- The displayed quadratic conclusion does not follow from the displayed
linear residual hypotheses, even when epsilon is the maximum squared norm. -/
theorem linear_residual_bounds_do_not_imply_quadratic_bound :
    let rho : ℝ := 1 / 2
    let normA : ℝ := 1
    let normB : ℝ := 1
    let residualA : ℝ := 1 / 2
    let residualB : ℝ := 1 / 2
    |residualA| ≤ rho * normA ∧
      |residualB| ≤ rho * normB ∧
      ¬ |energyRateDefect residualA residualB| ≤
        max (normA ^ 2) (normB ^ 2) * rho ^ 2 := by
  norm_num [energyRateDefect]

/-- A quadratic bound is valid once each residual is itself controlled at
quadratic order. This is the missing strengthening needed by the source. -/
theorem energy_rate_quadratic_spectral_bound
    {residualA residualB rho epsilonA epsilonB : ℝ}
    (hA : |residualA| ≤ epsilonA * rho ^ 2)
    (hB : |residualB| ≤ epsilonB * rho ^ 2) :
    |energyRateDefect residualA residualB| ≤
      (epsilonA + epsilonB) * rho ^ 2 := by
  calc
    |energyRateDefect residualA residualB| = |residualA + residualB| := rfl
    _ ≤ |residualA| + |residualB| := abs_add_le _ _
    _ ≤ epsilonA * rho ^ 2 + epsilonB * rho ^ 2 := add_le_add hA hB
    _ = (epsilonA + epsilonB) * rho ^ 2 := by ring

end ForcingAnalysis.Book5EquilibriumConservation
