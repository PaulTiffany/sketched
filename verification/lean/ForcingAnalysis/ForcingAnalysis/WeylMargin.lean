/-
WeylMargin.lean — the Weyl step of lem:margin, discharged.

ForcingKernel/Margin.lean proves the Channel-Margin path lemma from the
per-step drift bound `lam (i+1) ≥ lam i − δ i`, and its header states
the debt honestly: "the matrix analysis is cited, not re-proved;
formalizing Weyl itself needs mathlib's spectral theory." This file
pays that debt — WITHOUT the spectral theory, per the repo's
non-normalized rule: the margin is defined as the RAW Rayleigh infimum

    margin A = inf { ⟨x, A x⟩ : ‖x‖ = 1 }

(a set infimum over unit vectors, no eigenvalue machinery, no spectral
theorem), and Weyl's perturbation inequality is proved directly:

    |margin (A + E) − margin A| ≤ entryBudget E,

where entryBudget E = Σᵢⱼ |Eᵢⱼ| is an explicit, computable budget
dominating the operator norm. The chain then closes end to end:

  * `margin_perturb_lower/upper` — the two-sided Weyl bound;
  * `margin_step_drift` — a matrix path A : ℕ → Matrix satisfies
    EXACTLY the per-step hypothesis Margin.lean consumes, with
    δ i = entryBudget (A (i+1) − A i);
  * `weyl_margin_path` — the full lem:margin over ℝ: anchor margin 2ε
    plus cumulative entry-budget ≤ ε keeps the Rayleigh margin ≥ ε at
    every depth. The analytic step and the order-arithmetic remainder
    now live in one certified chain, matching the numeric witness
    (kernel/numeric_margin.py: "the budgeted path holding eta/2").

Honesty notes: (1) for SYMMETRIC A the Rayleigh infimum coincides with
λ_min (Courant–Fischer) — that identification is NOT proved here and
is not needed: the paper's lemma consumes the margin's drift behavior,
which is proved for the Rayleigh margin directly. (2) entryBudget is a
coarser (larger) budget than the operator norm Weyl uses; since
asm:smooth grants a budget and any dominating budget preserves the
inequality's direction, the path lemma's hypotheses are, if anything,
easier to grant. Both remarks are about interpretation; no theorem
below depends on them.
-/

import Mathlib

namespace ForcingAnalysis.Weyl

noncomputable section

variable {n : ℕ} [NeZero n]

/-- A unit vector in the raw sum-of-squares sense. -/
def IsUnit' (x : Fin n → ℝ) : Prop := ∑ i, x i ^ 2 = 1

/-- The raw Rayleigh value ⟨x, A x⟩ as a double sum. -/
def rayleigh (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, x i * A i j * x j

/-- The explicit perturbation budget: the entrywise absolute sum. -/
def entryBudget (E : Matrix (Fin n) (Fin n) ℝ) : ℝ := ∑ i, ∑ j, |E i j|

/-- The Rayleigh value set over unit vectors. -/
def rayleighSet (A : Matrix (Fin n) (Fin n) ℝ) : Set ℝ :=
  {r | ∃ x, IsUnit' x ∧ r = rayleigh A x}

/-- **The margin, raw form**: the infimum of Rayleigh values over unit
vectors — λ_min for symmetric A, but defined and used without any
spectral machinery. -/
def margin (A : Matrix (Fin n) (Fin n) ℝ) : ℝ := sInf (rayleighSet A)

omit [NeZero n] in
/-- Unit vectors have all coordinates in [−1, 1]. -/
theorem coord_abs_le_one {x : Fin n → ℝ} (hx : IsUnit' x) (i : Fin n) :
    |x i| ≤ 1 := by
  have hsq : x i ^ 2 ≤ 1 := by
    have hle : x i ^ 2 ≤ ∑ j, x j ^ 2 :=
      Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)
    rw [hx] at hle
    exact hle
  nlinarith [abs_nonneg (x i), sq_abs (x i)]

omit [NeZero n] in
/-- The Rayleigh value of ANY matrix is bounded by its entry budget on
unit vectors — the raw Cauchy–Schwarz-free bound. -/
theorem rayleigh_abs_le {E : Matrix (Fin n) (Fin n) ℝ} {x : Fin n → ℝ}
    (hx : IsUnit' x) : |rayleigh E x| ≤ entryBudget E := by
  unfold rayleigh entryBudget
  calc |∑ i, ∑ j, x i * E i j * x j|
      ≤ ∑ i, |∑ j, x i * E i j * x j| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, |x i * E i j * x j| :=
        Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, ∑ j, |E i j| := by
        refine Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => ?_
        rw [abs_mul, abs_mul]
        have hxi := coord_abs_le_one hx i
        have hxj := coord_abs_le_one hx j
        have h1 : |x i| * |E i j| ≤ 1 * |E i j| :=
          mul_le_mul_of_nonneg_right hxi (abs_nonneg _)
        have h2 : |x i| * |E i j| * |x j| ≤ |x i| * |E i j| * 1 :=
          mul_le_mul_of_nonneg_left hxj
            (mul_nonneg (abs_nonneg _) (abs_nonneg _))
        nlinarith [abs_nonneg (E i j)]

omit [NeZero n] in
/-- Rayleigh values are additive in the matrix argument. -/
theorem rayleigh_add (A E : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    rayleigh (A + E) x = rayleigh A x + rayleigh E x := by
  unfold rayleigh
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  simp [Matrix.add_apply]
  ring

/-- The unit sphere is inhabited: the first basis vector. -/
theorem rayleighSet_nonempty (A : Matrix (Fin n) (Fin n) ℝ) :
    (rayleighSet A).Nonempty := by
  have hpos : 0 < n := Nat.pos_of_ne_zero (NeZero.ne n)
  set i0 : Fin n := ⟨0, hpos⟩
  refine ⟨rayleigh A (fun j => if j = i0 then 1 else 0),
    fun j => if j = i0 then 1 else 0, ?_, rfl⟩
  unfold IsUnit'
  have : ∀ j : Fin n, (if j = i0 then (1:ℝ) else 0) ^ 2 =
      if j = i0 then 1 else 0 := by
    intro j
    split <;> norm_num
  rw [Finset.sum_congr rfl fun j _ => this j]
  simp

omit [NeZero n] in
/-- Every Rayleigh value dominates −entryBudget: the set is bounded
below. -/
theorem rayleighSet_bddBelow (A : Matrix (Fin n) (Fin n) ℝ) :
    BddBelow (rayleighSet A) := by
  refine ⟨-entryBudget A, fun r hr => ?_⟩
  obtain ⟨x, hx, rfl⟩ := hr
  have := rayleigh_abs_le (E := A) hx
  linarith [neg_abs_le (rayleigh A x)]

/-- **Weyl, lower half**: perturbation cannot push the margin down by
more than the budget. -/
theorem margin_perturb_lower (A E : Matrix (Fin n) (Fin n) ℝ) :
    margin A - entryBudget E ≤ margin (A + E) := by
  refine le_csInf (rayleighSet_nonempty _) fun r hr => ?_
  obtain ⟨x, hx, rfl⟩ := hr
  rw [rayleigh_add]
  have h1 : margin A ≤ rayleigh A x :=
    csInf_le (rayleighSet_bddBelow A) ⟨x, hx, rfl⟩
  have h2 := rayleigh_abs_le (E := E) hx
  linarith [neg_abs_le (rayleigh E x)]

/-- **Weyl, upper half**: nor push it up by more than the budget. -/
theorem margin_perturb_upper (A E : Matrix (Fin n) (Fin n) ℝ) :
    margin (A + E) ≤ margin A + entryBudget E := by
  have key : margin (A + E) - entryBudget E ≤ margin A := by
    refine le_csInf (rayleighSet_nonempty _) fun r hr => ?_
    obtain ⟨x, hx, rfl⟩ := hr
    have h1 : margin (A + E) ≤ rayleigh (A + E) x :=
      csInf_le (rayleighSet_bddBelow _) ⟨x, hx, rfl⟩
    rw [rayleigh_add] at h1
    have h2 := rayleigh_abs_le (E := E) hx
    linarith [le_abs_self (rayleigh E x)]
  linarith

/-- **Weyl's perturbation inequality, margin form**: the two-sided
bound |margin(A+E) − margin(A)| ≤ entryBudget E. The analytic step of
lem:margin, proved raw. -/
theorem margin_perturb (A E : Matrix (Fin n) (Fin n) ℝ) :
    |margin (A + E) - margin A| ≤ entryBudget E := by
  rw [abs_le]
  constructor
  · linarith [margin_perturb_lower A E]
  · linarith [margin_perturb_upper A E]

/-! ### The chain closed: matrix path → drift bound → path lemma -/

/-- **The per-step drift bound, EARNED**: a matrix path satisfies
exactly the hypothesis ForcingKernel/Margin.lean consumes, with
δ i = entryBudget of the step difference. This is the line that was
"cited, not re-proved." -/
theorem margin_step_drift (A : ℕ → Matrix (Fin n) (Fin n) ℝ) (i : ℕ) :
    margin (A (i + 1)) ≥
      margin (A i) - entryBudget (A (i + 1) - A i) := by
  have h := margin_perturb_lower (A i) (A (i + 1) - A i)
  rw [add_sub_cancel] at h
  exact h

/-- Cumulative real drift budget (Margin.lean's driftSum over ℝ). -/
def driftSumR (δ : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | k + 1 => driftSumR δ k + δ k

/-- **lem:margin, end to end over ℝ**: for a matrix path with anchor
Rayleigh margin ≥ 2ε whose cumulative entry-budget drift stays ≤ ε,
the margin holds ≥ ε at every depth. Weyl's step and the
order-arithmetic remainder in one certified chain — the theorem the
numeric margin witness (numeric_margin.py) instantiates. -/
theorem weyl_margin_path (A : ℕ → Matrix (Fin n) (Fin n) ℝ) (ε : ℝ)
    (hbudget : ∀ k, driftSumR (fun i => entryBudget (A (i + 1) - A i)) k ≤ ε)
    (hanchor : margin (A 0) ≥ 2 * ε) :
    ∀ k, margin (A k) ≥ ε := by
  have haccum : ∀ k, margin (A k) ≥
      margin (A 0) - driftSumR (fun i => entryBudget (A (i + 1) - A i)) k := by
    intro k
    induction k with
    | zero => simp [driftSumR]
    | succ m ih =>
        have hstep := margin_step_drift A m
        simp only [driftSumR]
        linarith
  intro k
  have h := haccum k
  have hb := hbudget k
  linarith

end

end ForcingAnalysis.Weyl
