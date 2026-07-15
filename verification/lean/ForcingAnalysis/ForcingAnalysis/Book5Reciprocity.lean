/- 
Book5Reciprocity.lean - balanced and weighted two-step reciprocity.

Theorems here cover the arithmetic/spectral content of
definition:bk5_two_way_street_tensor and
theorem:bk5_golden_rule_reciprocity. Interpretations about agents,
decency, or cognitive horizons remain outside the theorem.
-/

import Mathlib
import ForcingAnalysis.Book5

namespace ForcingAnalysis.Book5

noncomputable section

open scoped goldenRatio
open Filter

def reciprocityRate (w : Real) : Real :=
  (1 + Real.sqrt (1 + 4 * w)) / 2

def reciprocityMatrix (w : Real) : Matrix (Fin 2) (Fin 2) Real :=
  !![1, w; 1, 0]

theorem reciprocityRate_positive {w : Real} (hw : 0 <= w) :
    0 < reciprocityRate w := by
  unfold reciprocityRate
  positivity

theorem reciprocityRate_characteristic {w : Real} (hw : 0 <= w) :
    reciprocityRate w ^ 2 = reciprocityRate w + w := by
  have hr : 0 <= 1 + 4 * w := by linarith
  have hs : Real.sqrt (1 + 4 * w) ^ 2 = 1 + 4 * w :=
    Real.sq_sqrt hr
  unfold reciprocityRate
  nlinarith

theorem reciprocityMatrix_eigen {w : Real} (hw : 0 <= w) :
    (reciprocityMatrix w).mulVec ![reciprocityRate w, 1] =
      reciprocityRate w • ![reciprocityRate w, 1] := by
  have hchar := reciprocityRate_characteristic hw
  funext i
  fin_cases i
  · -- row 0: r + w = r·r, the characteristic equation
    simp [reciprocityMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
    nlinarith
  · -- row 1: r + 0 = r·1
    simp [reciprocityMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_two]

theorem reciprocityRate_zero : reciprocityRate 0 = 1 := by
  norm_num [reciprocityRate]

theorem reciprocityRate_one : reciprocityRate 1 = φ := by
  apply gold_unique_positive_root
  · exact reciprocityRate_positive (by norm_num)
  · exact reciprocityRate_characteristic (by norm_num)

theorem one_lt_reciprocityRate {w : Real} (hw : 0 < w) :
    1 < reciprocityRate w := by
  have hp := reciprocityRate_positive hw.le
  have hc := reciprocityRate_characteristic hw.le
  by_contra h
  have hle : reciprocityRate w <= 1 := le_of_not_gt h
  nlinarith

theorem reciprocityRate_strictMono_on_positive
    {w1 w2 : Real} (h1 : 0 < w1) (h12 : w1 < w2) :
    reciprocityRate w1 < reciprocityRate w2 := by
  have hp1 := one_lt_reciprocityRate h1
  have hp2 := one_lt_reciprocityRate (lt_trans h1 h12)
  have hc1 := reciprocityRate_characteristic h1.le
  have hc2 := reciprocityRate_characteristic (lt_trans h1 h12).le
  by_contra h
  have hle : reciprocityRate w2 <= reciprocityRate w1 := le_of_not_gt h
  nlinarith

theorem reciprocityRate_subgolden {w : Real} (hw0 : 0 < w) (hw1 : w < 1) :
    1 < reciprocityRate w ∧ reciprocityRate w < φ := by
  constructor
  · exact one_lt_reciprocityRate hw0
  · rw [← reciprocityRate_one]
    exact reciprocityRate_strictMono_on_positive hw0 hw1

theorem reciprocityRate_supergolden {w : Real} (hw : 1 < w) :
    φ < reciprocityRate w := by
  rw [← reciprocityRate_one]
  exact reciprocityRate_strictMono_on_positive (by norm_num) hw

theorem balanced_reciprocity_matrix :
    reciprocityMatrix 1 = closureMatrix := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [reciprocityMatrix, closureMatrix]

/-- Observer normalization and equal memory calibration select w = 1.
The conclusion is conditional on the two named calibration facts. -/
structure ObserverNormalizedWeights where
  presentWeight : Real
  memoryWeight : Real
  present_normalized : presentWeight = 1
  memory_balanced : memoryWeight = presentWeight

theorem balanced_observer_weights_unique (w : ObserverNormalizedWeights) :
    w.presentWeight = 1 ∧ w.memoryWeight = 1 := by
  constructor
  · exact w.present_normalized
  · rw [w.memory_balanced, w.present_normalized]

end

end ForcingAnalysis.Book5
