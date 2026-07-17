/-
Book4StatisticalMechanics.lean — finite coarse-grained metric and thermal
entropy-response kernel for Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4StatisticalMechanics

/-- Weighted finite ensemble average of microscopic metric components. -/
def ensembleMetric {Micro Macro : Type*} [Fintype Micro]
    (weight : Micro → ℝ) (microscopicMetric : Micro → Macro → Macro → ℝ)
    (i j : Macro) : ℝ :=
  ∑ micro, weight micro * microscopicMetric micro i j

/-- The printed statistical-mechanics closure, made into an explicit
definition with inverse temperature `beta⁻¹`. -/
noncomputable def thermalMetric {Macro : Type*} (beta : ℝ)
    (ensemble entropyHessian : Macro → Macro → ℝ) (i j : Macro) : ℝ :=
  ensemble i j + beta⁻¹ * entropyHessian i j

theorem thermalMetric_decomposition {Macro : Type*} (beta : ℝ)
    (ensemble entropyHessian : Macro → Macro → ℝ) (i j : Macro) :
    thermalMetric beta ensemble entropyHessian i j =
      ensemble i j + beta⁻¹ * entropyHessian i j := by
  rfl

theorem ensembleMetric_symmetric {Micro Macro : Type*} [Fintype Micro]
    (weight : Micro → ℝ) (microscopicMetric : Micro → Macro → Macro → ℝ)
    (hSymm : ∀ micro i j,
      microscopicMetric micro i j = microscopicMetric micro j i)
    (i j : Macro) :
    ensembleMetric weight microscopicMetric i j =
      ensembleMetric weight microscopicMetric j i := by
  unfold ensembleMetric
  apply Finset.sum_congr rfl
  intro micro _
  rw [hSymm micro i j]

theorem thermalMetric_symmetric {Macro : Type*} (beta : ℝ)
    (ensemble entropyHessian : Macro → Macro → ℝ)
    (hEnsemble : ∀ i j, ensemble i j = ensemble j i)
    (hHessian : ∀ i j, entropyHessian i j = entropyHessian j i)
    (i j : Macro) :
    thermalMetric beta ensemble entropyHessian i j =
      thermalMetric beta ensemble entropyHessian j i := by
  unfold thermalMetric
  rw [hEnsemble i j, hHessian i j]

/-- Positive temperature and nonnegative diagonal entropy response preserve
nonnegative metric diagonals. -/
theorem thermalMetric_diagonal_nonneg {Macro : Type*} (beta : ℝ)
    (ensemble entropyHessian : Macro → Macro → ℝ) (i : Macro)
    (hBeta : 0 < beta) (hEnsemble : 0 ≤ ensemble i i)
    (hHessian : 0 ≤ entropyHessian i i) :
    0 ≤ thermalMetric beta ensemble entropyHessian i i := by
  unfold thermalMetric
  exact add_nonneg hEnsemble
    (mul_nonneg (inv_nonneg.mpr (le_of_lt hBeta)) hHessian)

/-- Differentiability of an entropy function cannot by itself identify an
independently supplied observer metric with this thermal closure. At scalar
level the proposed right side can be one while the observer metric is zero. -/
theorem entropy_regularity_alone_does_not_force_metric_decomposition :
    let observedMetric : ℝ := 0
    let ensemble : ℝ := 0
    let beta : ℝ := 1
    let entropyHessian : ℝ := 1
    observedMetric ≠ ensemble + beta⁻¹ * entropyHessian := by
  norm_num

end ForcingAnalysis.Book4StatisticalMechanics
