/- 
Book5Spectrum.lean - elementary fracture and independent product axes.

This proves the exact two-coordinate special cases used throughout Book 5.
It does not claim that every symbolic manifold carries one privileged norm.
-/

import Mathlib
import ForcingAnalysis.Book5

namespace ForcingAnalysis.Book5

noncomputable section

open scoped goldenRatio

abbrev Plane := Fin 2 -> Real

def diagonal (a : Real) : Plane := ![a, a]

def axisCost (v : Plane) : Real :=
  |v 0| + |v 1|

def euclideanCost (v : Plane) : Real :=
  Real.sqrt (v 0 ^ 2 + v 1 ^ 2)

def supportCost (v : Plane) : Real :=
  max |v 0| |v 1|

theorem axisCost_diagonal (a : Real) :
    axisCost (diagonal a) = 2 * |a| := by
  simp [axisCost, diagonal]
  ring

theorem euclideanCost_diagonal (a : Real) :
    euclideanCost (diagonal a) = Real.sqrt 2 * |a| := by
  rw [euclideanCost]
  simp only [diagonal, Matrix.cons_val_zero, Matrix.cons_val_one]
  rw [show a ^ 2 + a ^ 2 = 2 * a ^ 2 by ring]
  rw [Real.sqrt_mul (by norm_num : 0 <= (2 : Real))]
  rw [Real.sqrt_sq_eq_abs]

theorem supportCost_diagonal (a : Real) :
    supportCost (diagonal a) = |a| := by
  simp [supportCost, diagonal]

theorem diagonal_l1_l2_ratio {a : Real} (ha : Not (a = 0)) :
    axisCost (diagonal a) / euclideanCost (diagonal a) = Real.sqrt 2 := by
  rw [axisCost_diagonal, euclideanCost_diagonal]
  have habs : Not (|a| = 0) := abs_ne_zero.mpr ha
  field_simp
  nlinarith [Real.sq_sqrt (by norm_num : (0 : Real) <= 2)]

theorem diagonal_l1_linf_ratio {a : Real} (ha : Not (a = 0)) :
    axisCost (diagonal a) / supportCost (diagonal a) = 2 := by
  rw [axisCost_diagonal, supportCost_diagonal]
  field_simp [abs_ne_zero.mpr ha]

inductive NormRegime where
  | axisIntegrable
  | euclideanFracture
  | supportCollapsed
  deriving DecidableEq, Repr

inductive MemoryRegime where
  | absent
  | balanced
  | weighted (w : Real)


/-- The product spectrum uses separate coordinates by construction. -/
structure ProductSpectrum where
  norm : NormRegime
  memory : MemoryRegime

theorem same_memory_does_not_fix_norm :
    exists x y : ProductSpectrum,
      x.memory = y.memory ∧ Not (x.norm = y.norm) := by
  refine ⟨⟨.axisIntegrable, .balanced⟩,
    ⟨.euclideanFracture, .balanced⟩, rfl, ?_⟩
  intro h
  exact NormRegime.noConfusion h

theorem same_norm_does_not_fix_memory :
    exists x y : ProductSpectrum,
      x.norm = y.norm ∧ Not (x.memory = y.memory) := by
  refine ⟨⟨.axisIntegrable, .absent⟩,
    ⟨.axisIntegrable, .balanced⟩, rfl, ?_⟩
  intro h
  exact MemoryRegime.noConfusion h

def balancedProduct (norm : NormRegime) : ProductSpectrum :=
  ⟨norm, .balanced⟩

theorem balanced_product_memory (norm : NormRegime) :
    (balancedProduct norm).memory = .balanced :=
  rfl

end

end ForcingAnalysis.Book5
