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


/-! ### Normalized coarse-graining and full quadratic positivity -/

def metricQuadratic {Macro : Type*} [Fintype Macro]
    (g : Macro → Macro → ℝ) (v : Macro → ℝ) : ℝ :=
  ∑ i, ∑ j, v i * g i j * v j

structure ThermalCoarseGraining (Micro Macro : Type*)
    [Fintype Micro] [Fintype Macro] where
  weight : Micro → ℝ
  weight_nonneg : ∀ x, 0 ≤ weight x
  weight_normalized : ∑ x, weight x = 1
  microscopicMetric : Micro → Macro → Macro → ℝ
  microscopic_symmetric : ∀ x i j,
    microscopicMetric x i j = microscopicMetric x j i
  microscopic_psd : ∀ x v, 0 ≤ metricQuadratic (microscopicMetric x) v
  entropyHessian : Macro → Macro → ℝ
  entropyHessian_symmetric : ∀ i j,
    entropyHessian i j = entropyHessian j i
  entropyHessian_psd : ∀ v, 0 ≤ metricQuadratic entropyHessian v
  beta : ℝ
  beta_pos : 0 < beta

noncomputable def coarseObserverMetric {Micro Macro : Type*}
    [Fintype Micro] [Fintype Macro]
    (C : ThermalCoarseGraining Micro Macro) : Macro → Macro → ℝ :=
  thermalMetric C.beta
    (ensembleMetric C.weight C.microscopicMetric) C.entropyHessian

theorem coarseObserverMetric_symmetric {Micro Macro : Type*}
    [Fintype Micro] [Fintype Macro]
    (C : ThermalCoarseGraining Micro Macro) (i j : Macro) :
    coarseObserverMetric C i j = coarseObserverMetric C j i := by
  apply thermalMetric_symmetric
  · exact ensembleMetric_symmetric C.weight C.microscopicMetric
      C.microscopic_symmetric
  · exact C.entropyHessian_symmetric

theorem metricQuadratic_ensembleMetric {Micro Macro : Type*}
    [Fintype Micro] [Fintype Macro]
    (weight : Micro → ℝ) (g : Micro → Macro → Macro → ℝ)
    (v : Macro → ℝ) :
    metricQuadratic (ensembleMetric weight g) v =
      ∑ x, weight x * metricQuadratic (g x) v := by
  classical
  unfold metricQuadratic ensembleMetric
  simp only [Finset.mul_sum, Finset.sum_mul]
  calc
    (∑ i, ∑ j, ∑ x, v i * (weight x * g x i j) * v j) =
        ∑ i, ∑ x, ∑ j, v i * (weight x * g x i j) * v j := by
          apply Finset.sum_congr rfl
          intro i _
          rw [Finset.sum_comm]
    _ = ∑ x, ∑ i, ∑ j, v i * (weight x * g x i j) * v j := by
          rw [Finset.sum_comm]
    _ = ∑ x, ∑ i, ∑ j, weight x * (v i * g x i j * v j) := by
          apply Finset.sum_congr rfl
          intro x _
          apply Finset.sum_congr rfl
          intro i _
          apply Finset.sum_congr rfl
          intro j _
          ring

theorem metricQuadratic_thermalMetric {Macro : Type*} [Fintype Macro]
    (beta : ℝ) (ensemble entropyHessian : Macro → Macro → ℝ)
    (v : Macro → ℝ) :
    metricQuadratic (thermalMetric beta ensemble entropyHessian) v =
      metricQuadratic ensemble v +
        beta⁻¹ * metricQuadratic entropyHessian v := by
  classical
  unfold metricQuadratic thermalMetric
  simp_rw [mul_add, add_mul, Finset.sum_add_distrib]
  simp only [Finset.mul_sum]
  apply congrArg₂ (· + ·)
  · rfl
  · apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring

theorem coarseObserverMetric_psd {Micro Macro : Type*}
    [Fintype Micro] [Fintype Macro]
    (C : ThermalCoarseGraining Micro Macro) (v : Macro → ℝ) :
    0 ≤ metricQuadratic (coarseObserverMetric C) v := by
  unfold coarseObserverMetric
  rw [metricQuadratic_thermalMetric]
  apply add_nonneg
  · rw [metricQuadratic_ensembleMetric]
    exact Finset.sum_nonneg fun x _ =>
      mul_nonneg (C.weight_nonneg x) (C.microscopic_psd x v)
  · exact mul_nonneg (inv_nonneg.mpr C.beta_pos.le)
      (C.entropyHessian_psd v)

theorem ensembleMetric_of_constant {Micro Macro : Type*}
    [Fintype Micro] (weight : Micro → ℝ)
    (hNorm : ∑ x, weight x = 1) (g : Macro → Macro → ℝ) (i j : Macro) :
    ensembleMetric weight (fun _ => g) i j = g i j := by
  simp [ensembleMetric, ← Finset.sum_mul, hNorm]

end ForcingAnalysis.Book4StatisticalMechanics
