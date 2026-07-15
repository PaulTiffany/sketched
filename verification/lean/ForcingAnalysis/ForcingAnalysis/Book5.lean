/-
Book5.lean — hardening the constants core of Principia Symbolica Book 5
(Fundamenta Symbolicae Vitae).

Scope, stated honestly: this file machine-checks the ARITHMETIC/SPECTRAL
kernel of the Book 5 constants claims — the parts that are theorems about
ℝ, matrices, and limits. The symbolic-manifold semantics wrapped around
them (that the drift–reflection commutator opens a memory channel; that
observer normalization is the right reading of the balance condition)
remains modeling/interpretive material and is NOT certified here; the
ledger keeps that boundary explicit.

Sources (Principia atlas, transcribed 2026-07-11; bindings in
verification/bindings.json):

  definition:bk5_balanced_two_step_memory_closure — the closure matrix
    A = [[1,1],[1,0]] of balanced two-step memory (`closureMatrix`).
  theorem:bk5_golden_ratio_spectral_invariant — the dominant eigenvalue
    of the balanced closure satisfies λ² − λ − 1 = 0 and the unique
    positive root is φ: `closureMatrix_eigen_gold` (eigen relation, with
    eigenvector (φ, 1)) + `gold_unique_positive_root` (uniqueness).
  definition:bk5_symbolic_regime_detection — the prediction M_n → φ for
    balanced two-step memory ratios: `balanced_memory_tendsto_gold`
    (mathlib's fib-ratio limit, re-exposed as the checked prediction).
  theorem:bk5_sqrt2_maximal_fracture — every primitive lattice transition
    with ≥ 2 nonzero integer coordinates has Euclidean length ≥ √2
    (`sqrt2_first_fracture`), and the elementary diagonal's
    representability ratio is 2/√2 = √2 (`diag_fracture_ratio`).
  proposition:bk5_complementary_constants /
  theorem:bk5_fundamental_dichotomy — the algebraic separation kernel:
    φ and √2 satisfy DIFFERENT minimal equations and neither satisfies
    the other's (`constants_complementary`). The dichotomy's mechanism
    reading (resonance-from-recursion vs fracture-from-orthogonality) is
    carried by which theorem each constant falls out of, above.
-/

import Mathlib
import ForcingKernel.Schema

namespace ForcingAnalysis

open scoped goldenRatio
open Filter

/-- The balanced two-step memory closure matrix
(definition:bk5_balanced_two_step_memory_closure). -/
def closureMatrix : Matrix (Fin 2) (Fin 2) ℝ := !![1, 1; 1, 0]

/-- **Eigen relation of the balanced closure**
(theorem:bk5_golden_ratio_spectral_invariant, existence half): (φ, 1) is
an eigenvector of A with eigenvalue φ — the memory ratio reproduces
itself under one closure step. -/
theorem closureMatrix_eigen_gold :
    closureMatrix.mulVec ![φ, 1] = φ • ![φ, 1] := by
  funext i
  fin_cases i
  · -- row 0: φ + 1 = φ·φ, i.e. the characteristic equation itself
    simp [closureMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_two]
    nlinarith [Real.goldenRatio_sq, sq_nonneg φ]
  · -- row 1: φ + 0 = φ·1
    simp [closureMatrix, Matrix.mulVec, dotProduct, Fin.sum_univ_two]

/-- **Uniqueness half**: φ is the ONLY positive solution of the balanced
characteristic equation λ² = λ + 1 (the other root ψ is negative). -/
theorem gold_unique_positive_root {x : ℝ} (hx : 0 < x) (h : x ^ 2 = x + 1) :
    x = φ := by
  have hfact : (x - φ) * (x - ψ) = 0 := by
    have expand : (x - φ) * (x - ψ) = x ^ 2 - (φ + ψ) * x + φ * ψ := by ring
    rw [expand, Real.goldenRatio_add_goldenConj, Real.goldenRatio_mul_goldenConj, h]
    ring
  rcases mul_eq_zero.mp hfact with h' | h'
  · linarith [sub_eq_zero.mp h']
  · exfalso
    have hxψ := sub_eq_zero.mp h'
    have := Real.goldenConj_neg
    linarith

/-- **The Regime Detection prediction, checked**
(definition:bk5_symbolic_regime_detection): balanced two-step memory
ratios M_n = a_{n+1}/a_n converge to φ. This is mathlib's Fibonacci
ratio limit re-exposed as the Book 5 prediction it instantiates. -/
theorem balanced_memory_tendsto_gold :
    Tendsto (fun n => (Nat.fib (n + 1) : ℝ) / Nat.fib n) atTop (nhds φ) :=
  tendsto_fib_succ_div_fib_atTop

/-- **First orthogonal fracture** (theorem:bk5_sqrt2_maximal_fracture,
quantitative kernel): every lattice transition with at least two nonzero
integer coordinates has Euclidean length ≥ √2. -/
theorem sqrt2_first_fracture {d : ℕ} (v : Fin d → ℤ) {i j : Fin d}
    (hij : i ≠ j) (hi : v i ≠ 0) (hj : v j ≠ 0) :
    Real.sqrt 2 ≤ Real.sqrt (∑ k, ((v k : ℝ)) ^ 2) := by
  apply Real.sqrt_le_sqrt
  have hone : ∀ n : ℤ, n ≠ 0 → (1 : ℝ) ≤ ((n : ℝ)) ^ 2 := by
    intro n hn
    have habs := Int.one_le_abs hn
    have : (1 : ℝ) ≤ |(n : ℝ)| := by exact_mod_cast habs
    nlinarith [abs_nonneg (n : ℝ), sq_abs (n : ℝ)]
  have hpair : (2 : ℝ) ≤ ((v i : ℝ)) ^ 2 + ((v j : ℝ)) ^ 2 := by
    have := hone _ hi
    have := hone _ hj
    linarith
  have hsubset :
      (∑ k ∈ ({i, j} : Finset (Fin d)), ((v k : ℝ)) ^ 2) ≤
        ∑ k, ((v k : ℝ)) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      (fun k _ _ => sq_nonneg _)
  rw [Finset.sum_pair hij] at hsubset
  exact hpair.trans hsubset

/-- The elementary diagonal's representability ratio: two axis steps
against geometric length √2 — the ratio is √2 itself. -/
theorem diag_fracture_ratio : (2 : ℝ) / Real.sqrt 2 = Real.sqrt 2 := by
  rw [eq_comm, eq_div_iff (by positivity : Real.sqrt 2 ≠ 0)]
  exact Real.mul_self_sqrt (by norm_num)

/-- **Complementary constants, algebraic separation kernel**
(proposition:bk5_complementary_constants /
theorem:bk5_fundamental_dichotomy): φ and √2 satisfy different minimal
equations, neither satisfies the other's, and they are distinct. The
resonance/fracture MECHANISM reading is carried by the theorems each
constant falls out of (`closureMatrix_eigen_gold` — recursion;
`sqrt2_first_fracture` — orthogonal geometry), not by this arithmetic. -/
theorem constants_complementary :
    φ ^ 2 = φ + 1 ∧ Real.sqrt 2 ^ 2 = 2 ∧
    φ ^ 2 ≠ 2 ∧ Real.sqrt 2 ^ 2 ≠ Real.sqrt 2 + 1 ∧ φ ≠ Real.sqrt 2 := by
  have hs : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h1 : (1 : ℝ) < Real.sqrt 2 := by
    nlinarith [hs, Real.sqrt_nonneg 2]
  refine ⟨Real.goldenRatio_sq, hs, ?_, ?_, ?_⟩
  · rw [Real.goldenRatio_sq]
    intro h
    have := Real.one_lt_goldenRatio
    linarith
  · rw [hs]
    intro h
    linarith
  · intro h
    have hg := Real.goldenRatio_sq
    rw [h, hs] at hg
    linarith

end ForcingAnalysis
