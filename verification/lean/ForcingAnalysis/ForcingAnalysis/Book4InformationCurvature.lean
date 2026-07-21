/-
Book4InformationCurvature.lean — finite Fisher-information kernel and tensor
symmetry audit for Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4InformationCurvature

/-- Finite scalar Fisher-information analogue: expected squared score. -/
def fisherInformation {n : ℕ} (weight score : Fin n → ℝ) : ℝ :=
  ∑ i, weight i * score i ^ 2

theorem fisherInformation_nonneg {n : ℕ} (weight score : Fin n → ℝ)
    (hWeight : ∀ i, 0 ≤ weight i) :
    0 ≤ fisherInformation weight score := by
  unfold fisherInformation
  exact Finset.sum_nonneg fun i _ => mul_nonneg (hWeight i) (sq_nonneg _)

/-- Only the first antisymmetry needed for the present audit of a Riemann
curvature tensor. -/
structure CurvatureLike (V : Type*) where
  value : V → V → V → V → ℝ
  antisymm_first : ∀ x y z w, value x y z w = -value y x z w

/-- Every genuine curvature-like tensor vanishes when its first two arguments
coincide. -/
theorem curvature_diagonal_zero {V : Type*} (R : CurvatureLike V)
    (x z w : V) : R.value x x z w = 0 := by
  have h := R.antisymm_first x x z w
  linarith

/-- The source's displayed product of identical log-likelihood Hessian
components can be positive on the full diagonal, contradicting the mandatory
curvature antisymmetry. -/
theorem unit_hessian_moment_cannot_be_riemann_diagonal :
    ¬ ∃ R : CurvatureLike Unit, R.value () () () () = 1 := by
  rintro ⟨R, hOne⟩
  have hZero := curvature_diagonal_zero R () () ()
  linarith

/-- The finite one-sample second-Hessian moment appearing on the right side of
the source formula is indeed one for a unit Hessian, making the mismatch
concrete rather than merely dimensional. -/
theorem unit_second_hessian_moment :
    (∑ _i : Fin 1, (1 : ℝ) * (1 : ℝ) * (1 : ℝ)) = 1 := by
  norm_num

/-- Finite Fisher metric matrix: expected outer product of score vectors. -/
def fisherMetric {samples n : ℕ} (weight : Fin samples → ℝ)
    (score : Fin samples → Fin n → ℝ) (i j : Fin n) : ℝ :=
  ∑ s, weight s * score s i * score s j

theorem fisherMetric_symm {samples n : ℕ} (weight : Fin samples → ℝ)
    (score : Fin samples → Fin n → ℝ) (i j : Fin n) :
    fisherMetric weight score i j = fisherMetric weight score j i := by
  unfold fisherMetric
  apply Finset.sum_congr rfl
  intro s _
  ring

theorem fisherMetric_diagonal_nonneg {samples n : ℕ}
    (weight : Fin samples → ℝ) (score : Fin samples → Fin n → ℝ)
    (hWeight : ∀ s, 0 ≤ weight s) (i : Fin n) :
    0 ≤ fisherMetric weight score i i := by
  unfold fisherMetric
  exact Finset.sum_nonneg fun s _ => by
    simpa [pow_two, mul_assoc] using
      mul_nonneg (hWeight s) (sq_nonneg (score s i))
/- ================================================================
   Coordinate Levi-Civita realization
   ================================================================ -/

/-- Finite-coordinate second-order metric data. `dMetric a i j` represents
`∂ₐ gᵢⱼ`, and `ddMetric a b i j` represents `∂ₐ∂ᵦ gᵢⱼ`. The inverse and its
first derivative are explicit data so no matrix inversion is hidden. -/
structure MetricTwoJet (n : ℕ) where
  metric : Fin n → Fin n → ℝ
  inverse : Fin n → Fin n → ℝ
  dMetric : Fin n → Fin n → Fin n → ℝ
  dInverse : Fin n → Fin n → Fin n → ℝ
  ddMetric : Fin n → Fin n → Fin n → Fin n → ℝ

/-- Regularity witnesses needed to interpret a raw two-jet as metric data.
Positive-definiteness is separated from the algebraic curvature construction. -/
structure RegularMetricTwoJet (n : ℕ) extends MetricTwoJet n where
  metric_symm : ∀ i j, metric i j = metric j i
  inverse_symm : ∀ i j, inverse i j = inverse j i
  inverse_law : ∀ i j, (∑ k, inverse i k * metric k j) = if i = j then 1 else 0
  positive : ∀ v : Fin n → ℝ, v ≠ 0 → 0 < ∑ i, ∑ j, metric i j * v i * v j

/-- Christoffel symbols of the second kind constructed from the metric and its
first derivatives in a fixed coordinate chart. -/
noncomputable def christoffel {n : ℕ} (J : MetricTwoJet n)
    (upper lower₁ lower₂ : Fin n) : ℝ :=
  (1 / 2 : ℝ) * ∑ m,
    J.inverse upper m *
      (J.dMetric lower₁ lower₂ m + J.dMetric lower₂ lower₁ m -
        J.dMetric m lower₁ lower₂)

/-- Coordinate derivative `∂ₐ Γᵘ_{bc}`, obtained by the product rule. This is
why curvature needs a metric two-jet rather than merely a pointwise metric. -/
noncomputable def christoffelDerivative {n : ℕ} (J : MetricTwoJet n)
    (deriv upper lower₁ lower₂ : Fin n) : ℝ :=
  (1 / 2 : ℝ) * ∑ m,
    (J.dInverse deriv upper m *
      (J.dMetric lower₁ lower₂ m + J.dMetric lower₂ lower₁ m -
        J.dMetric m lower₁ lower₂) +
    J.inverse upper m *
      (J.ddMetric deriv lower₁ lower₂ m +
        J.ddMetric deriv lower₂ lower₁ m -
        J.ddMetric deriv m lower₁ lower₂))

/-- Coordinate Riemann curvature `Rᵘ_{vab}` for the declared convention. It is
built from derivatives of Christoffel symbols and the quadratic `ΓΓ` terms,
not from a Hessian-product expectation. -/
noncomputable def riemannCurvature {n : ℕ} (J : MetricTwoJet n)
    (upper vector first second : Fin n) : ℝ :=
  christoffelDerivative J first upper vector second -
    christoffelDerivative J second upper vector first +
    ∑ m, (christoffel J upper first m * christoffel J m vector second -
      christoffel J upper second m * christoffel J m vector first)

/-- The constructed curvature has the mandatory antisymmetry in its curvature
coordinate pair. -/
theorem riemannCurvature_swap {n : ℕ} (J : MetricTwoJet n)
    (upper vector first second : Fin n) :
    riemannCurvature J upper vector first second =
      -riemannCurvature J upper vector second first := by
  simp only [riemannCurvature, Finset.sum_sub_distrib]
  ring

/-- Consequently, every diagonal component in the curvature-coordinate pair
vanishes. -/
theorem riemannCurvature_diagonal_zero {n : ℕ} (J : MetricTwoJet n)
    (upper vector first : Fin n) :
    riemannCurvature J upper vector first first = 0 := by
  have h := riemannCurvature_swap J upper vector first first
  linarith

/-- Constant metric jets have zero Christoffel symbols. -/
theorem christoffel_eq_zero_of_dMetric_zero {n : ℕ} (J : MetricTwoJet n)
    (hD : ∀ a i j, J.dMetric a i j = 0)
    (upper lower₁ lower₂ : Fin n) :
    christoffel J upper lower₁ lower₂ = 0 := by
  simp [christoffel, hD]

/-- If the first metric derivatives, inverse derivatives, and second metric
derivatives vanish, the resulting coordinate curvature vanishes. -/
theorem riemannCurvature_eq_zero_of_constant_jet {n : ℕ} (J : MetricTwoJet n)
    (hD : ∀ a i j, J.dMetric a i j = 0)
    (hInv : ∀ a i j, J.dInverse a i j = 0)
    (hDD : ∀ a b i j, J.ddMetric a b i j = 0)
    (upper vector first second : Fin n) :
    riemannCurvature J upper vector first second = 0 := by
  simp [riemannCurvature, christoffelDerivative, christoffel, hD, hInv, hDD]

/-- The fourth-order Hessian moment from the original display is retained as a
distinct statistical tensor. No curvature symmetries are asserted for it. -/
def hessianMoment {samples n : ℕ} (weight : Fin samples → ℝ)
    (hessian : Fin samples → Fin n → Fin n → ℝ)
    (i j k l : Fin n) : ℝ :=
  ∑ s, weight s * hessian s i j * hessian s k l

/-- A one-sample unit Hessian moment is nonzero on the full diagonal. -/
theorem unit_hessianMoment_diagonal :
    hessianMoment (n := 1) (fun _ : Fin 1 => 1)
      (fun _ _ _ => 1) 0 0 0 0 = 1 := by
  simp [hessianMoment]

/-- The Christoffel curvature and Hessian moment cannot be identified in
general: a constant one-dimensional metric jet is flat while the unit Hessian
moment is one. -/
theorem hessianMoment_is_not_riemannCurvature :
    let J : MetricTwoJet 1 :=
      { metric := fun _ _ => 1
        inverse := fun _ _ => 1
        dMetric := fun _ _ _ => 0
        dInverse := fun _ _ _ => 0
        ddMetric := fun _ _ _ _ => 0 }
    riemannCurvature J 0 0 0 0 = 0 ∧
      hessianMoment (n := 1) (fun _ : Fin 1 => 1)
        (fun _ _ _ => 1) 0 0 0 0 = 1 := by
  dsimp
  constructor
  · simp [riemannCurvature, christoffelDerivative, christoffel]
  · simp [hessianMoment]
end ForcingAnalysis.Book4InformationCurvature
