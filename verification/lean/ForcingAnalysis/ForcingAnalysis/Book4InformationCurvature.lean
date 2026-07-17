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

end ForcingAnalysis.Book4InformationCurvature
