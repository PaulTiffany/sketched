/-
Book5NormEquality.lean - finite-p equality case for the Book 5 norm bound.
-/

import ForcingAnalysis.Book5NormInfinity
import Mathlib.Analysis.Convex.Jensen
import Mathlib.Analysis.Convex.SpecificFunctions.Basic

namespace ForcingAnalysis.Book5

noncomputable section

variable {Idx : Type*}

/-- Equality in the powered cardinality bound forces all supported magnitudes
    to agree when p is strictly greater than one. -/
theorem powered_sharp_implies_equal_magnitudes
    {p : Real} (hp : 1 < p) (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real)
    (hSharp : axisCostOn s f ^ p =
      (s.card : Real) ^ (p - 1) * lpPowerOn p s f) :
    ∀ i ∈ s, ∀ j ∈ s, |f i| = |f j| := by
  let n : Real := s.card
  have hn : 0 < n := by
    dsimp [n]
    exact_mod_cast hs.card_pos
  have hn0 : Not (n = 0) := hn.ne'
  have hPowSub : n ^ (p - 1) = n ^ p / n := by
    simpa [Real.rpow_one] using Real.rpow_sub hn p 1
  have hJensen :
      ((1 / n) * axisCostOn s f) ^ p =
        (1 / n) * lpPowerOn p s f := by
    calc
      ((1 / n) * axisCostOn s f) ^ p =
          (1 / n) ^ p * axisCostOn s f ^ p :=
        Real.mul_rpow (by positivity) (axisCostOn_nonneg s f)
      _ = (1 / n) ^ p * (n ^ (p - 1) * lpPowerOn p s f) := by rw [hSharp]
      _ = (1 / n) * lpPowerOn p s f := by
        rw [Real.div_rpow zero_le_one hn.le, Real.one_rpow, hPowSub]
        field_simp
  have hWeights : Finset.sum s (fun _ => (1 / n : Real)) = 1 := by
    simp [n, hn0]
  have hJensen' :
      (fun x : Real => x ^ p)
          (Finset.sum s (fun i => (1 / n : Real) • |f i|)) =
        Finset.sum s (fun i => (1 / n : Real) • ((fun x : Real => x ^ p) |f i|)) := by
    simpa [smul_eq_mul, Finset.mul_sum, axisCostOn, lpPowerOn] using hJensen
  exact ((strictConvexOn_rpow hp).map_sum_eq_iff_of_pos
    (fun _ _ => by positivity) hWeights
    (fun i _ => abs_nonneg (f i))).mp hJensen'


theorem equal_magnitudes_imply_powered_sharp
    {p : Real} (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real)
    (hEqual : ∀ i ∈ s, |f i| = |f hs.choose|) :
    axisCostOn s f ^ p =
      (s.card : Real) ^ (p - 1) * lpPowerOn p s f := by
  let n : Real := s.card
  have hn : 0 < n := by
    dsimp [n]
    exact_mod_cast hs.card_pos
  have hAxis : axisCostOn s f = n * |f hs.choose| := by
    unfold axisCostOn
    calc
      Finset.sum s (fun i => |f i|) =
          Finset.sum s (fun _ => |f hs.choose|) :=
        Finset.sum_congr rfl hEqual
      _ = n * |f hs.choose| := by simp [n, nsmul_eq_mul]
  have hLp : lpPowerOn p s f = n * |f hs.choose| ^ p := by
    unfold lpPowerOn
    calc
      Finset.sum s (fun i => |f i| ^ p) =
          Finset.sum s (fun _ => |f hs.choose| ^ p) := by
        apply Finset.sum_congr rfl
        intro i hi
        rw [hEqual i hi]
      _ = n * |f hs.choose| ^ p := by simp [n, nsmul_eq_mul]
  have hPowSub : n ^ (p - 1) = n ^ p / n := by
    simpa [Real.rpow_one] using Real.rpow_sub hn p 1
  have hnSplit : n ^ p = n ^ (p - 1) * n := by
    rw [hPowSub]
    field_simp
  rw [hAxis, hLp, Real.mul_rpow hn.le (abs_nonneg _), hnSplit]
  ring

theorem powered_sharp_iff_equal_magnitudes
    {p : Real} (hp : 1 < p) (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) :
    axisCostOn s f ^ p =
        (s.card : Real) ^ (p - 1) * lpPowerOn p s f ↔
      ∀ i ∈ s, ∀ j ∈ s, |f i| = |f j| := by
  constructor
  · exact powered_sharp_implies_equal_magnitudes hp s hs f
  · intro hEqual
    apply equal_magnitudes_imply_powered_sharp s hs f
    intro i hi
    exact hEqual i hi hs.choose hs.choose_spec

theorem sharp_norm_bound_implies_equal_magnitudes
    {p : Real} (hp : 1 < p) (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real)
    (hSharp : axisCostOn s f =
      (s.card : Real) ^ (1 - 1 / p) * lpCostOn p s f) :
    ∀ i ∈ s, ∀ j ∈ s, |f i| = |f j| := by
  have hp0 : 0 < p := zero_lt_one.trans hp
  have hn : 0 <= (s.card : Real) := Nat.cast_nonneg _
  have hLpNonneg : 0 <= lpPowerOn p s f := lpPowerOn_nonneg p s f
  have hLpPow : lpCostOn p s f ^ p = lpPowerOn p s f := by
    unfold lpCostOn
    calc
      (lpPowerOn p s f ^ (1 / p)) ^ p =
          lpPowerOn p s f ^ ((1 / p) * p) :=
        (Real.rpow_mul hLpNonneg (1 / p) p).symm
      _ = lpPowerOn p s f := by
        rw [one_div, inv_mul_cancel₀ hp0.ne', Real.rpow_one]
  have hCardPow :
      ((s.card : Real) ^ (1 - 1 / p)) ^ p =
        (s.card : Real) ^ (p - 1) := by
    calc
      ((s.card : Real) ^ (1 - 1 / p)) ^ p =
          (s.card : Real) ^ ((1 - 1 / p) * p) :=
        (Real.rpow_mul hn (1 - 1 / p) p).symm
      _ = (s.card : Real) ^ (p - 1) := by
        congr 1
        field_simp
  have hLpCostNonneg : 0 <= lpCostOn p s f := Real.rpow_nonneg hLpNonneg _
  have hPowered := congrArg (fun x : Real => x ^ p) hSharp
  rw [Real.mul_rpow (Real.rpow_nonneg hn _) hLpCostNonneg,
    hCardPow, hLpPow] at hPowered
  exact powered_sharp_implies_equal_magnitudes hp s hs f hPowered

theorem sharp_norm_bound_iff_equal_magnitudes
    {p : Real} (hp : 1 < p) (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) :
    axisCostOn s f =
        (s.card : Real) ^ (1 - 1 / p) * lpCostOn p s f ↔
      ∀ i ∈ s, ∀ j ∈ s, |f i| = |f j| := by
  constructor
  · exact sharp_norm_bound_implies_equal_magnitudes hp s hs f
  · intro hEqual
    have hp0 : 0 < p := zero_lt_one.trans hp
    have hn : 0 <= (s.card : Real) := Nat.cast_nonneg _
    have hLpNonneg : 0 <= lpPowerOn p s f := lpPowerOn_nonneg p s f
    have hLpCostNonneg : 0 <= lpCostOn p s f := Real.rpow_nonneg hLpNonneg _
    have hRhsNonneg :
        0 <= (s.card : Real) ^ (1 - 1 / p) * lpCostOn p s f :=
      mul_nonneg (Real.rpow_nonneg hn _) hLpCostNonneg
    have hPowered : axisCostOn s f ^ p =
        (s.card : Real) ^ (p - 1) * lpPowerOn p s f :=
      (powered_sharp_iff_equal_magnitudes hp s hs f).mpr hEqual
    have hLpPow : lpCostOn p s f ^ p = lpPowerOn p s f := by
      unfold lpCostOn
      calc
        (lpPowerOn p s f ^ (1 / p)) ^ p =
            lpPowerOn p s f ^ ((1 / p) * p) :=
          (Real.rpow_mul hLpNonneg (1 / p) p).symm
        _ = lpPowerOn p s f := by
          rw [one_div, inv_mul_cancel₀ hp0.ne', Real.rpow_one]
    have hCardPow :
        ((s.card : Real) ^ (1 - 1 / p)) ^ p =
          (s.card : Real) ^ (p - 1) := by
      calc
        ((s.card : Real) ^ (1 - 1 / p)) ^ p =
            (s.card : Real) ^ ((1 - 1 / p) * p) :=
          (Real.rpow_mul hn (1 - 1 / p) p).symm
        _ = (s.card : Real) ^ (p - 1) := by
          congr 1
          field_simp
    have hRhsPow :
        ((s.card : Real) ^ (1 - 1 / p) * lpCostOn p s f) ^ p =
          (s.card : Real) ^ (p - 1) * lpPowerOn p s f := by
      rw [Real.mul_rpow (Real.rpow_nonneg hn _) hLpCostNonneg, hCardPow, hLpPow]
    apply le_antisymm
    · apply (Real.rpow_le_rpow_iff (axisCostOn_nonneg s f) hRhsNonneg hp0).mp
      rw [hPowered, hRhsPow]
    · apply (Real.rpow_le_rpow_iff hRhsNonneg (axisCostOn_nonneg s f) hp0).mp
      rw [hPowered, hRhsPow]
end

end ForcingAnalysis.Book5