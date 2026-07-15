/-
Book5Norm.lean - finite-support Lp norm-fracture bounds for Book 5.

The book's hierarchy is formalized on an explicitly supplied finite support.
No claim is made here that an arbitrary symbolic geometry has a canonical norm.
-/

import Mathlib.Analysis.MeanInequalities
import Mathlib.Analysis.MeanInequalitiesPow

namespace ForcingAnalysis.Book5

noncomputable section

variable {Idx : Type*}

def axisCostOn (s : Finset Idx) (f : Idx -> Real) : Real :=
  Finset.sum s (fun i => |f i|)

def lpPowerOn (p : Real) (s : Finset Idx) (f : Idx -> Real) : Real :=
  Finset.sum s (fun i => |f i| ^ p)

def lpCostOn (p : Real) (s : Finset Idx) (f : Idx -> Real) : Real :=
  (lpPowerOn p s f) ^ (1 / p)

theorem lpPowerOn_nonneg (p : Real) (s : Finset Idx) (f : Idx -> Real) :
    0 <= lpPowerOn p s f := by
  unfold lpPowerOn
  exact Finset.sum_nonneg fun i _ => Real.rpow_nonneg (abs_nonneg (f i)) _

theorem axisCostOn_nonneg (s : Finset Idx) (f : Idx -> Real) :
    0 <= axisCostOn s f := by
  unfold axisCostOn
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem lpPowerOn_le_axisCostOn_rpow
    {p : Real} (hp : 1 <= p) (s : Finset Idx) (f : Idx -> Real) :
    lpPowerOn p s f <= axisCostOn s f ^ p := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [lpPowerOn, axisCostOn, Real.zero_rpow (ne_of_gt (lt_of_lt_of_le zero_lt_one hp))]
  | @insert a s ha ih =>
      rw [lpPowerOn, Finset.sum_insert ha, axisCostOn, Finset.sum_insert ha]
      rw [lpPowerOn, axisCostOn] at ih
      calc
        |f a| ^ p + Finset.sum s (fun i => |f i| ^ p)
            <= |f a| ^ p + (Finset.sum s fun i => |f i|) ^ p := add_le_add_right ih _
        _ <= (|f a| + Finset.sum s fun i => |f i|) ^ p :=
          Real.add_rpow_le_rpow_add (abs_nonneg _) (Finset.sum_nonneg fun _ _ => abs_nonneg _) hp

theorem axisCostOn_rpow_le_card_mul_lpPowerOn
    {p : Real} (hp : 1 <= p) (s : Finset Idx) (f : Idx -> Real) :
    axisCostOn s f ^ p <= (s.card : Real) ^ (p - 1) * lpPowerOn p s f := by
  simpa [axisCostOn, lpPowerOn] using
    (Real.rpow_sum_le_const_mul_sum_rpow (s := s) (f := f) hp)

/-- The lower half of the finite-support Lp hierarchy: ||f||_p <= ||f||_1. -/
theorem lpCostOn_le_axisCostOn
    {p : Real} (hp : 1 <= p) (s : Finset Idx) (f : Idx -> Real) :
    lpCostOn p s f <= axisCostOn s f := by
  have hp0 : 0 < p := lt_of_lt_of_le zero_lt_one hp
  have h := Real.rpow_le_rpow (lpPowerOn_nonneg p s f)
    (lpPowerOn_le_axisCostOn_rpow hp s f) (by positivity : 0 <= 1 / p)
  rw [lpCostOn]
  calc
    lpPowerOn p s f ^ (1 / p) <= (axisCostOn s f ^ p) ^ (1 / p) := h
    _ = axisCostOn s f := by
      rw [← Real.rpow_mul (axisCostOn_nonneg s f)]
      simpa [Real.rpow_one] using congrArg (fun q : Real => axisCostOn s f ^ q)
        (mul_inv_cancel₀ hp0.ne')


/-- The sharp finite-support upper estimate. -/
theorem axisCostOn_le_card_rpow_mul_lpCostOn
    {p : Real} (hp : 1 <= p) (s : Finset Idx) (f : Idx -> Real) :
    axisCostOn s f <= (s.card : Real) ^ (1 - 1 / p) * lpCostOn p s f := by
  have hp0 : 0 < p := lt_of_lt_of_le zero_lt_one hp
  have hroot := Real.rpow_le_rpow (Real.rpow_nonneg (axisCostOn_nonneg s f) p)
    (axisCostOn_rpow_le_card_mul_lpPowerOn hp s f) (by positivity : 0 <= 1 / p)
  calc
    axisCostOn s f = (axisCostOn s f ^ p) ^ (1 / p) := by
      rw [← Real.rpow_mul (axisCostOn_nonneg s f)]
      simpa [Real.rpow_one] using congrArg (fun q : Real => axisCostOn s f ^ q)
        (mul_inv_cancel₀ hp0.ne').symm
    _ <= ((s.card : Real) ^ (p - 1) * lpPowerOn p s f) ^ (1 / p) := hroot
    _ = (s.card : Real) ^ (1 - 1 / p) * lpCostOn p s f := by
      rw [Real.mul_rpow (Real.rpow_nonneg (Nat.cast_nonneg _) _) (lpPowerOn_nonneg p s f)]
      rw [← Real.rpow_mul ((Nat.cast_nonneg s.card : 0 <= (s.card : Real)))]
      unfold lpCostOn
      congr 1
      field_simp
end

end ForcingAnalysis.Book5