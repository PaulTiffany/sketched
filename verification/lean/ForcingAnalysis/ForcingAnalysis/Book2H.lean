/-
Book2H.lean — the discrete H-theorem for the finite Gibbs kernel
(ledger item LPS-O7, closing the dynamical-monotonicity gap left open
in Book2.lean).

Book2.lean certifies the finite Gibbs kernel's variational endpoint
(the Gibbs state uniquely minimizes the free energy) but explicitly
leaves open the monotone-decrease claim along an evolution
(theorem:bk2_h_theorem_for_symbolic_evol, dynamical half). This file
closes that gap by the standard discrete route: the free energy
decomposes as F(ρ) = KL(ρ ‖ gibbs)/β − β⁻¹ log Z
(`Book2.freeEnergy_eq_kl`), so monotone decrease of F along one
evolution step reduces to the data-processing inequality for relative
entropy under a kernel that fixes the reference (Gibbs) measure. The
data-processing inequality itself is proved from the log-sum
inequality, which is proved from the elementary tangent-line bound for
x ↦ x log x (the same convexity fact underlying `Book2.term_le`).

Tiers (all four stand; no `sorry`, no axioms):
  1. `logSum_term_le` — the per-term convexity bound underlying the
     log-sum inequality, for weighted totals A, B rather than
     normalized densities (the "two-term" case).
  2. `logSum` — the finite log-sum inequality, summing tier 1 over the
     whole alphabet (handles the zero-mass boundary explicitly).
  3. `dataProcessing_kl` — the data-processing inequality for relative
     entropy under any row-stochastic kernel, applying tier 2 column
     by column.
  4. `h_theorem` — the discrete H-theorem: one evolution step under a
     detailed-balance kernel does not increase the free energy
     (theorem:bk2_h_theorem_for_symbolic_evol, the dynamical half).
-/

import Mathlib
import ForcingAnalysis.Book2

namespace ForcingAnalysis.Book2H

noncomputable section

open Finset ForcingAnalysis.Book2

/-! ### Generic real-number lemmas (no finite alphabet needed yet) -/

/-- Tangent line for x ↦ x log x at t0, evaluated at t: the elementary
convexity bound underlying the log-sum inequality. -/
private theorem logTangent {t t0 : ℝ} (ht : 0 < t) (ht0 : 0 < t0) :
    t - t0 + t * Real.log t0 ≤ t * Real.log t := by
  have hx : 0 < t0 / t := div_pos ht0 ht
  have hlog := Real.log_le_sub_one_of_pos hx
  have hlogeq : Real.log (t0 / t) = Real.log t0 - Real.log t := Real.log_div ht0.ne' ht.ne'
  rw [hlogeq] at hlog
  have hmul := mul_le_mul_of_nonneg_left hlog ht.le
  have heq : t * (t0 / t - 1) = t0 - t := by field_simp
  rw [heq] at hmul
  have hdist : t * (Real.log t0 - Real.log t) = t * Real.log t0 - t * Real.log t := by ring
  linarith [hmul, hdist]

/-- **Tier 1**: per-term log-sum bound. For nonnegative weighted
totals A, B > 0 and a term a ≥ 0, b ≥ 0 with a = 0 whenever b = 0 (the
finite-kernel support condition), this is the termwise inequality that
sums to the log-sum inequality. -/
private theorem logSum_term_le {a b A B : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hA : 0 < A) (hB : 0 < B) (hab : a = 0 ∨ 0 < b) :
    a - A / B * b ≤ a * Real.log (a / b) - a * Real.log (A / B) := by
  rcases eq_or_lt_of_le ha with ha0 | hapos
  · rw [← ha0]
    have hab_nonneg : 0 ≤ A / B * b := mul_nonneg (div_pos hA hB).le hb
    simp only [zero_mul, zero_div, Real.log_zero, sub_zero]
    linarith
  · have hbpos : 0 < b := hab.resolve_left hapos.ne'
    have ht : 0 < a / b := div_pos hapos hbpos
    have ht0 : 0 < A / B := div_pos hA hB
    have htan := logTangent ht ht0
    have hmul := mul_le_mul_of_nonneg_left htan hbpos.le
    have hlhs : b * (a / b - A / B + a / b * Real.log (A / B))
        = a - A / B * b + a * Real.log (A / B) := by
      field_simp
    have hrhs : b * (a / b * Real.log (a / b)) = a * Real.log (a / b) := by
      field_simp
    rw [hlhs, hrhs] at hmul
    linarith [hmul]

/-- x * log(x/y) splits into x log x − x log y, valid whenever the
denominator y is positive (x itself may be zero, matching Lean's
log 0 = 0 convention). -/
private theorem mul_log_div_eq {x y : ℝ} (hx : 0 ≤ x) (hy : 0 < y) :
    x * Real.log (x / y) = x * Real.log x - x * Real.log y := by
  rcases eq_or_lt_of_le hx with hx0 | hxpos
  · simp [← hx0]
  · rw [Real.log_div hxpos.ne' hy.ne']
    ring

/-- Rescaling a log-sum term by a shared nonnegative factor Pij
(interpreted as a transition weight): the Pij cancels inside the log
whenever it is nonzero, and the whole term vanishes when it is zero. -/
private theorem term_split {ρi σi Pij : ℝ} (hρi : 0 ≤ ρi) (hσi : 0 < σi) (hPij : 0 ≤ Pij) :
    ρi * Pij * Real.log (ρi * Pij / (σi * Pij))
      = (ρi * Real.log ρi - ρi * Real.log σi) * Pij := by
  rcases eq_or_lt_of_le hPij with hPij0 | hPijpos
  · rw [← hPij0]; simp
  · rcases eq_or_lt_of_le hρi with hρi0 | hρipos
    · rw [← hρi0]; simp
    · have hcancel : ρi * Pij / (σi * Pij) = ρi / σi := by
        field_simp
      rw [hcancel, Real.log_div hρipos.ne' hσi.ne']
      ring

variable {n : ℕ} [NeZero n]

/-! ### Tier 2: the finite log-sum inequality -/

omit [NeZero n] in
/-- **Tier 2 — the log-sum inequality**: for nonnegative a, b on a
finite index set with total mass B = ∑ b > 0 and support(a) ⊆
support(b), the total mass of a times the log of the mass ratio is
bounded by the sum of termwise log ratios. -/
private theorem logSum {a b : Fin n → ℝ} (ha : ∀ i, 0 ≤ a i) (hb : ∀ i, 0 ≤ b i)
    (hB : 0 < ∑ i, b i) (hab : ∀ i, a i = 0 ∨ 0 < b i) :
    (∑ i, a i) * Real.log ((∑ i, a i) / (∑ i, b i)) ≤ ∑ i, a i * Real.log (a i / b i) := by
  rcases eq_or_lt_of_le (Finset.sum_nonneg fun i _ => ha i) with hA0 | hApos
  · have hai0 : ∀ i, a i = 0 := by
      intro i
      have hle : a i ≤ ∑ k, a k := Finset.single_le_sum (fun k _ => ha k) (Finset.mem_univ i)
      linarith [ha i]
    have hzero : ∑ i, a i * Real.log (a i / b i) = 0 := by
      apply Finset.sum_eq_zero
      intro i _
      rw [hai0 i]; simp
    rw [← hA0]
    simp only [zero_div, Real.log_zero, zero_mul]
    linarith [hzero]
  · have hterm : ∀ i ∈ (Finset.univ : Finset (Fin n)),
        a i - (∑ i, a i) / (∑ i, b i) * b i
          ≤ a i * Real.log (a i / b i) - a i * Real.log ((∑ i, a i) / (∑ i, b i)) :=
      fun i _ => logSum_term_le (ha i) (hb i) hApos hB (hab i)
    have hsum := Finset.sum_le_sum hterm
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.sum_mul] at hsum
    have hBne : (∑ i, b i) ≠ 0 := hB.ne'
    have hcancel : (∑ i, a i) / (∑ i, b i) * (∑ i, b i) = ∑ i, a i := by
      field_simp
    rw [hcancel] at hsum
    linarith

/-! ### Tier 3: data-processing inequality -/

omit [NeZero n] in
/-- **Tier 3 — data-processing inequality**: relative entropy cannot
increase under a row-stochastic kernel, provided the reference
measure's image stays strictly positive columnwise. -/
theorem dataProcessing_kl {P : Matrix (Fin n) (Fin n) ℝ} (hP : IsStochastic P)
    {ρ σ : Fin n → ℝ} (hρ : IsDensity ρ) (hσpos : ∀ i, 0 < σ i)
    (hEvolveσPos : ∀ j, 0 < evolve P σ j) :
    (∑ j, evolve P ρ j * Real.log (evolve P ρ j))
        - ∑ j, evolve P ρ j * Real.log (evolve P σ j)
      ≤ (∑ i, ρ i * Real.log (ρ i)) - ∑ i, ρ i * Real.log (σ i) := by
  show (∑ j, (∑ i, ρ i * P i j) * Real.log (∑ i, ρ i * P i j))
      - ∑ j, (∑ i, ρ i * P i j) * Real.log (∑ i, σ i * P i j)
    ≤ (∑ i, ρ i * Real.log (ρ i)) - ∑ i, ρ i * Real.log (σ i)
  have hcol : ∀ j, (∑ i, ρ i * P i j) * Real.log (∑ i, ρ i * P i j)
        - (∑ i, ρ i * P i j) * Real.log (∑ i, σ i * P i j)
      ≤ ∑ i, (ρ i * Real.log (ρ i) - ρ i * Real.log (σ i)) * P i j := by
    intro j
    have hratio := logSum (a := fun i => ρ i * P i j) (b := fun i => σ i * P i j)
      (fun i => mul_nonneg (hρ.nonneg i) (hP.1 i j))
      (fun i => mul_nonneg (hσpos i).le (hP.1 i j))
      (hEvolveσPos j)
      (fun i => by
        rcases eq_or_lt_of_le (hP.1 i j) with hPij0 | hPijpos
        · left; rw [← hPij0]; ring
        · right; exact mul_pos (hσpos i) hPijpos)
    have hLHSeq := mul_log_div_eq
      (Finset.sum_nonneg fun i (_ : i ∈ Finset.univ) => mul_nonneg (hρ.nonneg i) (hP.1 i j))
      (show (0:ℝ) < ∑ i, σ i * P i j from hEvolveσPos j)
    have hRHSeq : (∑ i, ρ i * P i j * Real.log (ρ i * P i j / (σ i * P i j)))
        = ∑ i, (ρ i * Real.log (ρ i) - ρ i * Real.log (σ i)) * P i j :=
      Finset.sum_congr rfl fun i _ => term_split (hρ.nonneg i) (hσpos i) (hP.1 i j)
    rw [hLHSeq, hRHSeq] at hratio
    exact hratio
  have hcolsum := Finset.sum_le_sum (fun j (_ : j ∈ (Finset.univ : Finset (Fin n))) => hcol j)
  rw [Finset.sum_sub_distrib, Finset.sum_comm] at hcolsum
  have hRHS2 : ∀ i, (∑ j, (ρ i * Real.log (ρ i) - ρ i * Real.log (σ i)) * P i j)
      = ρ i * Real.log (ρ i) - ρ i * Real.log (σ i) := by
    intro i
    rw [← Finset.mul_sum, hP.2 i, mul_one]
  simp only [hRHS2] at hcolsum
  rw [Finset.sum_sub_distrib] at hcolsum
  linarith [hcolsum]

/-! ### Tier 4: the discrete H-theorem -/

/-- **Tier 4 — the discrete H-theorem**
(theorem:bk2_h_theorem_for_symbolic_evol, dynamical half): one
evolution step under a kernel in detailed balance with the Gibbs state
does not increase the free energy. Combined with the endpoint
characterization already certified in Book2.lean
(`Book2.gibbs_unique_minimizer`), this makes the finite free energy a
genuine Lyapunov functional for detailed-balance dynamics. -/
theorem h_theorem {P : Matrix (Fin n) (Fin n) ℝ} (hP : IsStochastic P) {β : ℝ} (hβ : 0 < β)
    {H : Fin n → ℝ} (hdb : DetailedBalance P (gibbs β H)) {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    freeEnergy β H (evolve P ρ) ≤ freeEnergy β H ρ := by
  have hstat : evolve P (gibbs β H) = gibbs β H := detailedBalance_stationary hP hdb
  have hEvolveσPos : ∀ j, 0 < evolve P (gibbs β H) j := by
    intro j; rw [hstat]; exact gibbs_pos β H j
  have hDP := dataProcessing_kl hP hρ (gibbs_pos β H) hEvolveσPos
  rw [hstat] at hDP
  have hρ' : IsDensity (evolve P ρ) := evolve_isDensity hP hρ
  rw [freeEnergy_eq_kl hβ.ne' H hρ', freeEnergy_eq_kl hβ.ne' H hρ]
  have hβinv : (0:ℝ) ≤ β⁻¹ := (inv_pos.mpr hβ).le
  linarith [mul_le_mul_of_nonneg_left hDP hβinv]

end

open ForcingAnalysis.Book2

/-! ### Discrete free-energy flow -/

/-- The finite trajectory generated by repeated application of a stochastic
kernel. This is the discrete object used as the honest finite shadow of the
Book 2 Wasserstein-gradient-flow claim. -/
def trajectory (P : Matrix (Fin n) (Fin n) ℝ) (ρ : Fin n → ℝ) : ℕ → Fin n → ℝ
  | 0 => ρ
  | k + 1 => evolve P (trajectory P ρ k)

/-- Every point of a stochastic trajectory remains a probability density. -/
theorem trajectory_isDensity {P : Matrix (Fin n) (Fin n) ℝ} (hP : IsStochastic P)
    {ρ : Fin n → ℝ} (hρ : IsDensity ρ) : ∀ k, IsDensity (trajectory P ρ k) := by
  intro k
  induction k with
  | zero => exact hρ
  | succ k ih => exact evolve_isDensity hP ih

/-- **Finite gradient-flow kernel**
(`theorem:bk2_wasserstein_gradient_flow`): along every repeated
detailed-balance step, symbolic free energy is nonincreasing. This certifies
the discrete Lyapunov/descent content only; it does not assert a Wasserstein
metric or identify the continuum Fokker--Planck PDE with its metric gradient. -/
theorem freeEnergy_trajectory_antitone {n : ℕ} [NeZero n]
    {P : Matrix (Fin n) (Fin n) ℝ} (hP : IsStochastic P)
    {β : ℝ} (hβ : 0 < β) {H : Fin n → ℝ}
    (hdb : DetailedBalance P (gibbs β H)) {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    Antitone (fun k => freeEnergy β H (trajectory P ρ k)) := by
  refine antitone_nat_of_succ_le fun k => ?_
  simpa [trajectory] using
    (h_theorem hP hβ hdb (trajectory_isDensity hP hρ k))

end ForcingAnalysis.Book2H
