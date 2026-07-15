/-
Book5Decoherence.lean - finite admissible-path kernel for symbolic decoherence.

A path family is local data. Symbolically representable paths form a named
subset of the geometric candidates; no universal path ontology is assumed.
-/

import ForcingAnalysis.Book5NormEquality
import Mathlib.Data.Finset.Lattice.Fold

namespace ForcingAnalysis.Book5

noncomputable section

structure FinitePathProblem (Path : Type*) where
  geometric : Finset Path
  symbolic : Finset Path
  geometric_nonempty : geometric.Nonempty
  symbolic_nonempty : symbolic.Nonempty
  symbolic_subset : symbolic ⊆ geometric
  cost : Path -> Real

variable {Path : Type*}

def shortestGeometric (P : FinitePathProblem Path) : Real :=
  P.geometric.inf' P.geometric_nonempty P.cost

def shortestSymbolic (P : FinitePathProblem Path) : Real :=
  P.symbolic.inf' P.symbolic_nonempty P.cost

def symbolicDecoherence (P : FinitePathProblem Path) : Real :=
  shortestSymbolic P - shortestGeometric P

theorem shortestGeometric_le_shortestSymbolic (P : FinitePathProblem Path) :
    shortestGeometric P <= shortestSymbolic P := by
  unfold shortestGeometric shortestSymbolic
  apply Finset.le_inf'
  intro q hq
  exact Finset.inf'_le_of_le P.cost (P.symbolic_subset hq) le_rfl

theorem symbolicDecoherence_nonneg (P : FinitePathProblem Path) :
    0 <= symbolicDecoherence P := by
  unfold symbolicDecoherence
  exact sub_nonneg.mpr (shortestGeometric_le_shortestSymbolic P)

theorem symbolicDecoherence_eq_zero_iff (P : FinitePathProblem Path) :
    symbolicDecoherence P = 0 ↔
      shortestSymbolic P = shortestGeometric P := by
  unfold symbolicDecoherence
  exact sub_eq_zero

theorem symbolicDecoherence_pos_iff (P : FinitePathProblem Path) :
    0 < symbolicDecoherence P ↔
      shortestGeometric P < shortestSymbolic P := by
  unfold symbolicDecoherence
  exact sub_pos

theorem symbolicDecoherence_eq_zero_iff_has_symbolic_geodesic
    (P : FinitePathProblem Path) :
    symbolicDecoherence P = 0 ↔
      ∃ q ∈ P.symbolic, P.cost q = shortestGeometric P := by
  constructor
  · intro hZero
    have hMin : shortestSymbolic P = shortestGeometric P :=
      (symbolicDecoherence_eq_zero_iff P).mp hZero
    obtain ⟨q, hq, hqMin⟩ :=
      Finset.exists_mem_eq_inf' P.symbolic_nonempty P.cost
    exact ⟨q, hq, hqMin.symm.trans hMin⟩
  · rintro ⟨q, hq, hqMin⟩
    apply (symbolicDecoherence_eq_zero_iff P).mpr
    apply le_antisymm
    · unfold shortestSymbolic
      exact Finset.inf'_le_of_le P.cost hq hqMin.le
    · exact shortestGeometric_le_shortestSymbolic P

def diagonalAxisLength (n : Nat) : Real := 2 * n

def diagonalEuclideanLength (n : Nat) : Real := n * Real.sqrt 2

def diagonalDecoherence (n : Nat) : Real :=
  diagonalAxisLength n - diagonalEuclideanLength n

theorem diagonalDecoherence_formula (n : Nat) :
    diagonalDecoherence n = n * (2 - Real.sqrt 2) := by
  simp [diagonalDecoherence, diagonalAxisLength, diagonalEuclideanLength]
  ring

theorem diagonalDecoherence_pos {n : Nat} (hn : 0 < n) :
    0 < diagonalDecoherence n := by
  rw [diagonalDecoherence_formula]
  apply mul_pos
  · exact_mod_cast hn
  · have hsqrt : Real.sqrt 2 < 2 :=
      Real.sqrt_two_lt_three_halves.trans (by norm_num)
    linarith

theorem diagonal_symbolic_longer {n : Nat} (hn : 0 < n) :
    diagonalEuclideanLength n < diagonalAxisLength n := by
  have := diagonalDecoherence_pos hn
  unfold diagonalDecoherence at this
  linarith

end

end ForcingAnalysis.Book5