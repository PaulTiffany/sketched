/-
Book5NormInfinity.lean - the finite-support Linfinity endpoint of Book 5.

The supremum cost is defined only for a named nonempty finite support. This
keeps the empty-support convention out of the mathematical statement.
-/

import ForcingAnalysis.Book5NormPhase
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib

namespace ForcingAnalysis.Book5

noncomputable section

variable {Idx : Type*}

def finSupportNonempty {n : Nat} (hn : 0 < n) :
    (Finset.univ : Finset (Fin n)).Nonempty :=
  ⟨⟨0, hn⟩, Finset.mem_univ _⟩

def supportCostOn (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) : Real :=
  s.sup' hs (fun i => |f i|)

theorem supportCostOn_nonneg
    (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) :
    0 <= supportCostOn s hs f := by
  exact (abs_nonneg (f hs.choose)).trans
    (Finset.le_sup' (fun i => |f i|) hs.choose_spec)

theorem supportCostOn_le_axisCostOn
    (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) :
    supportCostOn s hs f <= axisCostOn s f := by
  unfold supportCostOn axisCostOn
  apply Finset.sup'_le
  intro i hi
  exact Finset.single_le_sum (fun j _ => abs_nonneg (f j)) hi

theorem axisCostOn_le_card_mul_supportCostOn
    (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) :
    axisCostOn s f <= (s.card : Real) * supportCostOn s hs f := by
  unfold axisCostOn
  have h := Finset.sum_le_card_nsmul s (fun i => |f i|) (supportCostOn s hs f)
    (fun i hi => Finset.le_sup' (fun j => |f j|) hi)
  simpa [nsmul_eq_mul] using h

theorem supportCostOn_equalMagnitude
    {n : Nat} (hn : 0 < n) (a : Real) :
    supportCostOn Finset.univ (finSupportNonempty hn)
        (equalMagnitude n a) = |a| := by
  simp [supportCostOn, equalMagnitude, Finset.sup'_const]

theorem equalMagnitude_infinity_ratio
    {n : Nat} (hn : 0 < n) {a : Real} (ha : Not (a = 0)) :
    axisCostOn Finset.univ (equalMagnitude n a) /
        supportCostOn Finset.univ (finSupportNonempty hn)
          (equalMagnitude n a) = (n : Real) := by
  rw [axisCostOn_equalMagnitude, supportCostOn_equalMagnitude hn]
  field_simp [abs_ne_zero.mpr ha]

def symbolicTorsionInfinity (n : Nat) : Real := (n : Real) - 1

theorem symbolicTorsionInfinity_eq_ratio_sub_one
    {n : Nat} (hn : 0 < n) {a : Real} (ha : Not (a = 0)) :
    symbolicTorsionInfinity n =
      axisCostOn Finset.univ (equalMagnitude n a) /
          supportCostOn Finset.univ (finSupportNonempty hn)
            (equalMagnitude n a) - 1 := by
  rw [equalMagnitude_infinity_ratio hn ha]
  rfl

def effectiveSupportDimensionInfinity (n : Nat) : Real :=
  if n = 1 then 1 else 2

theorem effectiveSupportDimensionInfinity_eq_two
    {n : Nat} (hn : 2 <= n) : effectiveSupportDimensionInfinity n = 2 := by
  simp [effectiveSupportDimensionInfinity, show Not (n = 1) by omega]

theorem effectiveSupportDimensionInfinity_log_ratio
    {n : Nat} (hn : 2 <= n) :
    1 + Real.log (n : Real) / Real.log n =
      effectiveSupportDimensionInfinity n := by
  rw [effectiveSupportDimensionInfinity_eq_two hn]
  have hlog : Not (Real.log (n : Real) = 0) := by
    apply ne_of_gt
    exact Real.log_pos (by exact_mod_cast (show 1 < n by omega))
  field_simp
  norm_num


theorem infinity_ratio_bounds
    (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real)
    (hSupport : 0 < supportCostOn s hs f) :
    And (1 <= axisCostOn s f / supportCostOn s hs f)
      (axisCostOn s f / supportCostOn s hs f <= (s.card : Real)) := by
  constructor
  · rw [le_div_iff₀ hSupport]
    simpa using supportCostOn_le_axisCostOn s hs f
  · rw [div_le_iff₀ hSupport]
    simpa [mul_comm] using axisCostOn_le_card_mul_supportCostOn s hs f

theorem symbolicTorsionInfinity_tendsto_atTop :
    Filter.Tendsto symbolicTorsionInfinity Filter.atTop Filter.atTop := by
  rw [Filter.tendsto_atTop_atTop]
  intro b
  obtain ⟨N, hN⟩ := exists_nat_gt (b + 1)
  refine ⟨N, ?_⟩
  intro n hNn
  rw [symbolicTorsionInfinity]
  have hcast : (N : Real) <= (n : Real) := by exact_mod_cast hNn
  linarith

theorem infinity_sharp_iff_equal_magnitudes
    (s : Finset Idx) (hs : s.Nonempty) (f : Idx -> Real) :
    axisCostOn s f = (s.card : Real) * supportCostOn s hs f
      ↔ ∀ i ∈ s, |f i| = supportCostOn s hs f := by
  constructor
  · intro hSharp
    have hSum :
        Finset.sum s (fun i => |f i|) =
          Finset.sum s (fun _ => supportCostOn s hs f) := by
      simpa [axisCostOn, nsmul_eq_mul] using hSharp
    exact (Finset.sum_eq_sum_iff_of_le
      (fun i hi => Finset.le_sup' (fun j => |f j|) hi)).mp hSum
  · intro hEqual
    unfold axisCostOn
    calc
      Finset.sum s (fun i => |f i|) =
          Finset.sum s (fun _ => supportCostOn s hs f) :=
        Finset.sum_congr rfl hEqual
      _ = (s.card : Real) * supportCostOn s hs f := by
        simp [nsmul_eq_mul]
end

end ForcingAnalysis.Book5