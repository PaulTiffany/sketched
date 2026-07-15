/-
Book5NormPhase.lean - equal-magnitude sharpness, torsion, and support dimension.
-/

import ForcingAnalysis.Book5Norm

namespace ForcingAnalysis.Book5

noncomputable section

abbrev EqualSupport (n : Nat) := Fin n

def equalMagnitude (n : Nat) (a : Real) : EqualSupport n -> Real :=
  fun _ => a

theorem axisCostOn_equalMagnitude (n : Nat) (a : Real) :
    axisCostOn Finset.univ (equalMagnitude n a) = (n : Real) * |a| := by
  simp [axisCostOn, equalMagnitude]

theorem lpPowerOn_equalMagnitude (p : Real) (n : Nat) (a : Real) :
    lpPowerOn p Finset.univ (equalMagnitude n a) = (n : Real) * |a| ^ p := by
  simp [lpPowerOn, equalMagnitude]

theorem lpCostOn_equalMagnitude
    {p : Real} (hp : 0 < p) (n : Nat) (a : Real) :
    lpCostOn p Finset.univ (equalMagnitude n a) =
      (n : Real) ^ (1 / p) * |a| := by
  rw [lpCostOn, lpPowerOn_equalMagnitude]
  rw [Real.mul_rpow (Nat.cast_nonneg n) (Real.rpow_nonneg (abs_nonneg a) p)]
  have hpow : (|a| ^ p) ^ (1 / p) = |a| := by
    calc
      (|a| ^ p) ^ (1 / p) = |a| ^ (p * (1 / p)) :=
        (Real.rpow_mul (abs_nonneg a) p (1 / p)).symm
      _ = |a| := by rw [one_div, mul_inv_cancel₀ hp.ne', Real.rpow_one]
  rw [hpow]

theorem equalMagnitude_ratio
    {p : Real} (hp : 0 < p) {n : Nat} (hn : 0 < n) {a : Real} (ha : Not (a = 0)) :
    axisCostOn Finset.univ (equalMagnitude n a) /
        lpCostOn p Finset.univ (equalMagnitude n a) =
      (n : Real) ^ (1 - 1 / p) := by
  rw [axisCostOn_equalMagnitude, lpCostOn_equalMagnitude hp]
  have hnR : 0 < (n : Real) := by exact_mod_cast hn
  have haAbs : Not (|a| = 0) := abs_ne_zero.mpr ha
  rw [mul_div_mul_right _ _ haAbs]
  rw [Real.rpow_sub hnR]
  simp [Real.rpow_one]

def symbolicTorsion (p : Real) (n : Nat) : Real :=
  (n : Real) ^ (1 - 1 / p) - 1

theorem symbolicTorsion_eq_equalMagnitude_ratio_sub_one
    {p : Real} (hp : 0 < p) {n : Nat} (hn : 0 < n) {a : Real} (ha : Not (a = 0)) :
    symbolicTorsion p n =
      axisCostOn Finset.univ (equalMagnitude n a) /
          lpCostOn p Finset.univ (equalMagnitude n a) - 1 := by
  rw [equalMagnitude_ratio hp hn ha]
  rfl

theorem symbolicTorsion_one (n : Nat) : symbolicTorsion 1 n = 0 := by
  simp [symbolicTorsion]

def effectiveSupportDimension (p : Real) (n : Nat) : Real :=
  if n = 1 then 1 else 1 + Real.log ((n : Real) ^ (1 - 1 / p)) / Real.log n

theorem effectiveSupportDimension_eq
    {p : Real} {n : Nat} (hn : 2 <= n) :
    effectiveSupportDimension p n = 2 - 1 / p := by
  have hn1 : Not (n = 1) := by omega
  have hnR : 0 < (n : Real) := by positivity
  have hlog : Not (Real.log (n : Real) = 0) := by
    apply ne_of_gt
    exact Real.log_pos (by exact_mod_cast (show 1 < n by omega))
  rw [effectiveSupportDimension, if_neg hn1, Real.log_rpow hnR]
  field_simp
  ring

theorem effectiveSupportDimension_one (n : Nat) :
    effectiveSupportDimension 1 n = 1 := by
  by_cases hn : n = 1
  · simp [effectiveSupportDimension, hn]
  · by_cases hn0 : n = 0
    · simp [effectiveSupportDimension, hn0]
    · have hn2 : 2 <= n := by omega
      rw [effectiveSupportDimension_eq hn2]
      norm_num


theorem symbolicTorsion_two_two :
    symbolicTorsion 2 2 = Real.sqrt 2 - 1 := by
  rw [symbolicTorsion]
  norm_num
  rw [show (2 : Real) ^ (1 / 2 : Real) = Real.sqrt 2 by
    exact (Real.sqrt_eq_rpow 2).symm]

theorem symbolicTorsion_mono_exponent
    {p q : Real} (hp : 0 < p) (hpq : p <= q) (n : Nat) (hn : 1 <= n) :
    symbolicTorsion p n <= symbolicTorsion q n := by
  unfold symbolicTorsion
  apply sub_le_sub_right
  apply Real.rpow_le_rpow_of_exponent_le
  · exact_mod_cast hn
  · have hInv : 1 / q <= 1 / p := by
      exact one_div_le_one_div_of_le hp hpq
    linarith

theorem effectiveSupportDimension_two {n : Nat} (hn : 2 <= n) :
    effectiveSupportDimension 2 n = 3 / 2 := by
  rw [effectiveSupportDimension_eq hn]
  norm_num
end

end ForcingAnalysis.Book5