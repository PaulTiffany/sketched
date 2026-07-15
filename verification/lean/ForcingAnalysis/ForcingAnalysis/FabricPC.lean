/-
FabricPC.lean — the predictive-coding contract (ledger LPS-O6,
closure condition 1).

The FabricPC bridge (docs/17) grounds a predictive-coding substrate as an
external source. Its promotion to a verified interface was opened as
LPS-O6, whose first closure condition reads: "a typed contract between
FabricPC state/update dynamics and a Lean-specified structure — the
contract is that FabricPC's update decreases a quantity the Lean layer
names." This file states and proves that contract against the finite
Gibbs kernel of Book2.lean.

The update is the discrete predictive-coding relaxation: mix the current
density toward the target (Gibbs/equilibrium) state,

    relaxStep ε σ ρ = (1−ε)·ρ + ε·σ.

The contract, proved:

  * `relax_kl_le` — relative entropy against the target contracts by the
    factor (1−ε): KL(relaxStep ε σ ρ ‖ σ) ≤ (1−ε)·KL(ρ ‖ σ). The finite
    two-term log-sum inequality (proved here from log x ≤ x − 1, the
    same raw-form move as Book2's Gibbs inequality — no measure-theoretic
    normalization) is the whole engine.
  * `relax_freeEnergy_le` — THE CONTRACT: one relaxation step toward the
    Gibbs state never increases Book 2's symbolic free energy.
  * `relax_freeEnergy_lt` — descent is STRICT off equilibrium for any
    genuinely mixing step (0 < ε ≤ 1, ρ ≠ gibbs): the predictive-coding
    claim, not just non-increase.

Together with Book2H.lean's H-theorem (detailed-balance steps), the Lean
layer now certifies free-energy descent for BOTH canonical update
families a predictive-coding substrate implements: stochastic relaxation
(H-theorem) and deterministic mixing toward equilibrium (this file).

Scope honesty: this is the finite contract, not a claim that the
external FabricPC codebase satisfies it — conditions 2–4 of LPS-O6
(local reproduction, measured witness comparing FabricPC trajectories
against this contract on a declared regime, Matt-op upgrade) remain
open and are exactly where that correspondence gets tested.
-/

import Mathlib
import ForcingAnalysis.Book2

namespace ForcingAnalysis.FabricPC

open ForcingAnalysis.Book2

noncomputable section

variable {n : ℕ} [NeZero n]

/-- One predictive-coding relaxation step: mix the current density
toward the target state with rate ε. -/
def relaxStep (ε : ℝ) (σ ρ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => (1 - ε) * ρ i + ε * σ i

omit [NeZero n] in
/-- Relaxation preserves density-hood for ε ∈ [0,1]. -/
theorem relaxStep_isDensity {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1)
    {σ ρ : Fin n → ℝ} (hσ : IsDensity σ) (hρ : IsDensity ρ) :
    IsDensity (relaxStep ε σ ρ) where
  nonneg i := add_nonneg
    (mul_nonneg (by linarith) (hρ.nonneg i))
    (mul_nonneg h0 (hσ.nonneg i))
  sum_one := by
    unfold relaxStep
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
        hρ.sum_one, hσ.sum_one]
    ring

omit [NeZero n] in
/-- Per-term tangent bound: x·log(x/y) ≥ x − y for x ≥ 0 < y, with the
x = 0 boundary under the log 0 = 0 convention — the same raw-form move
as Book2's `term_le`, kept un-normalized on purpose. -/
private theorem tangent_bound {x y : ℝ} (hx : 0 ≤ x) (hy : 0 < y) :
    x - y ≤ x * Real.log (x / y) := by
  rcases eq_or_lt_of_le hx with h0 | hpos
  · simp [← h0]
    linarith
  · have hlog := Real.log_le_sub_one_of_pos (div_pos hy hpos)
    rw [Real.log_div hy.ne' hpos.ne'] at hlog
    have h := mul_le_mul_of_nonneg_left hlog hpos.le
    have hdiv : x * (y / x - 1) = y - x := by field_simp
    have hsplit : x * (Real.log y - Real.log x) ≤ y - x := by
      calc x * (Real.log y - Real.log x) ≤ x * (y / x - 1) := h
        _ = y - x := hdiv
    have hxy : x * Real.log (x / y) = x * Real.log x - x * Real.log y := by
      rw [Real.log_div hpos.ne' hy.ne']; ring
    nlinarith [hsplit, hxy]

omit [NeZero n] in
/-- **Two-term log-sum inequality**, from the tangent bound alone:
(a+b)·log((a+b)/(A+B)) ≤ a·log(a/A) + b·log(b/B) for a,b ≥ 0 < A,B. -/
theorem two_term_logsum {a b A B : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hA : 0 < A) (hB : 0 < B) :
    (a + b) * Real.log ((a + b) / (A + B)) ≤
      a * Real.log (a / A) + b * Real.log (b / B) := by
  have hAB : 0 < A + B := by linarith
  set t := (a + b) / (A + B) with ht
  have htnn : 0 ≤ t := div_nonneg (by linarith) hAB.le
  rcases eq_or_lt_of_le htnn with ht0 | htpos
  · -- a + b = 0, so a = b = 0: both sides vanish
    have hab : a + b = 0 := by
      by_contra hne
      have : 0 < a + b := lt_of_le_of_ne (by linarith) (Ne.symm hne)
      have := div_pos this hAB
      rw [← ht] at this
      linarith
    have ha0 : a = 0 := by linarith
    have hb0 : b = 0 := by linarith
    simp [ha0, hb0]
  · -- key: x·log(x/y) ≥ x·log(t) + (x − t·y) for each pair, sum, telescope
    have key : ∀ x y : ℝ, 0 ≤ x → 0 < y →
        x * Real.log t + (x - t * y) ≤ x * Real.log (x / y) := by
      intro x y hx hy
      have hty : 0 < t * y := mul_pos htpos hy
      have htan := tangent_bound hx hty
      rcases eq_or_lt_of_le hx with h0 | hxpos
      · simp only [← h0, zero_mul, zero_add, zero_sub]
        linarith [hty]
      · have hlogsplit : Real.log (x / (t * y)) =
            Real.log (x / y) - Real.log t := by
          rw [Real.log_div hxpos.ne' hty.ne', Real.log_div hxpos.ne' hy.ne',
              Real.log_mul htpos.ne' hy.ne']
          ring
        have hexp : x * Real.log (x / (t * y)) =
            x * Real.log (x / y) - x * Real.log t := by
          rw [hlogsplit]; ring
        linarith [htan, hexp]
    have k1 := key a A ha hA
    have k2 := key b B hb hB
    have hmulout : t * (A + B) = a + b := by
      rw [ht]
      exact div_mul_cancel₀ _ hAB.ne'
    have hcancel : t * A + t * B = a + b := by
      rw [← hmulout]; ring
    have hsplit : (a + b) * Real.log t = a * Real.log t + b * Real.log t := by
      ring
    linarith [k1, k2, hcancel, hsplit]

omit [NeZero n] in
/-- **KL contraction under relaxation**: mixing toward the reference
contracts relative entropy by the factor (1 − ε). -/
theorem relax_kl_le {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1)
    {σ ρ : Fin n → ℝ} (hσ : ∀ i, 0 < σ i) (hρ : ∀ i, 0 ≤ ρ i) :
    ∑ i, relaxStep ε σ ρ i * Real.log (relaxStep ε σ ρ i / σ i) ≤
      (1 - ε) * ∑ i, ρ i * Real.log (ρ i / σ i) := by
  rcases eq_or_lt_of_le h0 with hε0 | hεpos
  · simp [relaxStep, ← hε0]
  rcases eq_or_lt_of_le h1 with hε1 | hεlt
  · -- ε = 1: the step lands exactly on σ, KL = 0 = RHS
    subst hε1
    have hone : ∀ i, σ i / σ i = 1 := fun i => div_self (hσ i).ne'
    simp [relaxStep, hone]
  · -- 0 < ε < 1: per-index two-term log-sum with the σ-block collapsing
    have hterm : ∀ i, relaxStep ε σ ρ i * Real.log (relaxStep ε σ ρ i / σ i) ≤
        (1 - ε) * (ρ i * Real.log (ρ i / σ i)) := by
      intro i
      have h := two_term_logsum
        (a := (1 - ε) * ρ i) (b := ε * σ i)
        (A := (1 - ε) * σ i) (B := ε * σ i)
        (mul_nonneg (by linarith) (hρ i)) (mul_nonneg hεpos.le (hσ i).le)
        (mul_pos (by linarith : (0:ℝ) < 1 - ε) (hσ i))
        (mul_pos hεpos (hσ i))
      have hden : (1 - ε) * σ i + ε * σ i = σ i := by ring
      rw [hden] at h
      have hratio1 : (1 - ε) * ρ i / ((1 - ε) * σ i) = ρ i / σ i := by
        rw [mul_div_mul_left _ _ (by linarith : (1:ℝ) - ε ≠ 0)]
      have hratio2 : ε * σ i / (ε * σ i) = 1 :=
        div_self (mul_pos hεpos (hσ i)).ne'
      rw [hratio1, hratio2, Real.log_one, mul_zero, add_zero] at h
      calc relaxStep ε σ ρ i * Real.log (relaxStep ε σ ρ i / σ i)
          = ((1 - ε) * ρ i + ε * σ i) *
              Real.log (((1 - ε) * ρ i + ε * σ i) / σ i) := rfl
        _ ≤ (1 - ε) * ρ i * Real.log (ρ i / σ i) := h
        _ = (1 - ε) * (ρ i * Real.log (ρ i / σ i)) := by ring
    calc ∑ i, relaxStep ε σ ρ i * Real.log (relaxStep ε σ ρ i / σ i)
        ≤ ∑ i, (1 - ε) * (ρ i * Real.log (ρ i / σ i)) :=
          Finset.sum_le_sum fun i _ => hterm i
      _ = (1 - ε) * ∑ i, ρ i * Real.log (ρ i / σ i) := by
          rw [Finset.mul_sum]

omit [NeZero n] in
/-- Ratio-form of the KL bracket used by Book2's freeEnergy_eq_kl. -/
private theorem log_ratio_split {ρ σ : Fin n → ℝ}
    (hρ : ∀ i, 0 ≤ ρ i) (hσ : ∀ i, 0 < σ i) :
    ∑ i, ρ i * Real.log (ρ i / σ i) =
      (∑ i, ρ i * Real.log (ρ i)) - ∑ i, ρ i * Real.log (σ i) := by
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rcases eq_or_lt_of_le (hρ i) with h0 | hpos
  · simp [← h0]
  · rw [Real.log_div hpos.ne' (hσ i).ne']
    ring

/-- **THE FABRICPC CONTRACT** (LPS-O6, condition 1): one
predictive-coding relaxation step toward the Gibbs state never increases
the symbolic free energy, for any rate ε ∈ [0,1], any density, β > 0. -/
theorem relax_freeEnergy_le {β : ℝ} (hβ : 0 < β) (H : Fin n → ℝ)
    {ε : ℝ} (h0 : 0 ≤ ε) (h1 : ε ≤ 1) {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    freeEnergy β H (relaxStep ε (gibbs β H) ρ) ≤ freeEnergy β H ρ := by
  set g := gibbs β H with hg
  have hgd : IsDensity g := gibbs_isDensity β H
  have hgp : ∀ i, 0 < g i := gibbs_pos β H
  have hmix : IsDensity (relaxStep ε g ρ) := relaxStep_isDensity h0 h1 hgd hρ
  have hkl := relax_kl_le h0 h1 hgp hρ.nonneg
  -- KL(ρ‖g) ≥ 0 from Book2's Gibbs inequality
  have hklnn : 0 ≤ ∑ i, ρ i * Real.log (ρ i / g i) := by
    have := gibbs_inequality hρ hgp hgd.sum_one
    rw [log_ratio_split hρ.nonneg hgp]
    linarith
  have hmono : ∑ i, relaxStep ε g ρ i * Real.log (relaxStep ε g ρ i / g i) ≤
      ∑ i, ρ i * Real.log (ρ i / g i) := by
    have hε : (1 - ε) * (∑ i, ρ i * Real.log (ρ i / g i)) ≤
        ∑ i, ρ i * Real.log (ρ i / g i) := by nlinarith
    linarith
  rw [freeEnergy_eq_kl hβ.ne' H hmix, freeEnergy_eq_kl hβ.ne' H hρ]
  have hsplit1 := log_ratio_split hmix.nonneg hgp
  have hsplit2 := log_ratio_split hρ.nonneg hgp
  have hβinv : (0:ℝ) ≤ β⁻¹ := (inv_pos.mpr hβ).le
  have := mul_le_mul_of_nonneg_left
    (by linarith [hmono, hsplit1, hsplit2] :
      (∑ i, relaxStep ε g ρ i * Real.log (relaxStep ε g ρ i)) -
        ∑ i, relaxStep ε g ρ i * Real.log (g i) ≤
      (∑ i, ρ i * Real.log (ρ i)) - ∑ i, ρ i * Real.log (g i)) hβinv
  linarith

end

end ForcingAnalysis.FabricPC
