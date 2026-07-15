/-
FabricPCGuard.lean — the SRMF-Helix guard for predictive coding
(LPS-O6, the Gödel-safety instrument; the Moloch hedge promoted from
warning to guard).

The design brief (Paul, 2026-07-13): predictive coding is not the goal —
it is an instrument with proven failure modes, and it should be treated
the way medicine treats research simulations: never enacted pure, always
trialed with the alternatives kept alive. The simulation channel IS
imagination — the drift-injection points between SRMF steps. The
inefficiency is already a theorem of this repo: pure prediction-error
minimization relaxes toward the Gibbs target (FabricPC.relax_kl_le),
and at β → ∞ that target CONCENTRATES (Book2.gibbs_concentrates) — the
collapsed flat state, certain and sterile, the dark-room failure. A
system that only predicts well freezes.

The guarded step adds the imagination channel: mix rate δ of the
uniform state into every update,

    guardedStep ε δ σ ρ = (1−ε−δ)·ρ + ε·σ + δ·uniform.

The δ-channel is imagination-as-simulation: every alternative retains
trace mass no matter how confident the current best hypothesis is —
exactly the medical-simulation discipline. GUARDED TO ITSELF ×3:

  GUARD 1 (freeze / ⊬ novum): `novelty_floor` — every state keeps mass
    ≥ δ/n after a guarded step, so the frozen point mass is unreachable
    (`guarded_ne_pointMass`). And the floor is β-INDEPENDENT
    (`guarded_floor_all_temperatures`): the unguarded target
    concentrates as β → ∞, the guarded iterate never does. Imagination
    outlives freezing at every temperature.
  GUARD 2 (Moloch / dissolution): `guarded_kl_le` — relative entropy
    against the target contracts up to a BOUNDED imagination cost
    (δ · KL(uniform‖target), the declared price of the simulation
    channel), so the guarded loop is bounded forever
    (`moloch_guard`, `guarded_sequence_bounded`): no divergence, no
    unbounded ascent, no Moloch. Proved via a three-term log-sum
    inequality built from FabricPC's two-term one — raw form, no
    convexity machinery.
  GUARD 3 (Gödel / closure): `guarded_arrival_iff_uniform` — the
    guarded step rests AT the pure-prediction optimum iff that optimum
    is already uniform, i.e. (whenever prediction has any content) the
    guard structurally forbids arrival. The loop approaches the optimum
    and may not claim it: with_and_was as design, the helix that never
    closes and never escapes. Certification stays external; the guard
    constrains the loop, it does not certify it.

Scope honesty: this is the finite Lean-side contract layer of LPS-O6.
That the external FabricPC codebase implements guardedStep — and that
its trajectories respect these three guards on a declared regime — is
exactly what LPS-O6's open conditions 2–4 will test.
-/

import Mathlib
import ForcingAnalysis.FabricPC

namespace ForcingAnalysis.FabricPC

open ForcingAnalysis.Book2

noncomputable section

variable {n : ℕ} [NeZero n]

/-- The uniform state — the imagination channel's carrier. -/
def uniform : Fin n → ℝ := fun _ => (n : ℝ)⁻¹

/-- Relative entropy in raw finite form (0·log 0 = 0 convention). -/
def kl (ρ σ : Fin n → ℝ) : ℝ := ∑ i, ρ i * Real.log (ρ i / σ i)

/-- The guarded predictive-coding step: prediction (ε toward the
target) plus imagination (δ of uniform), remainder inertia. -/
def guardedStep (ε δ : ℝ) (σ ρ : Fin n → ℝ) : Fin n → ℝ :=
  fun i => (1 - ε - δ) * ρ i + ε * σ i + δ * (n : ℝ)⁻¹

omit [NeZero n] in
/-- Per-index split of kl, honoring the ρ = 0 boundary. -/
private theorem kl_split {ρ σ : Fin n → ℝ} (hρ : ∀ i, 0 ≤ ρ i)
    (hσ : ∀ i, 0 < σ i) :
    kl ρ σ = (∑ i, ρ i * Real.log (ρ i)) - ∑ i, ρ i * Real.log (σ i) := by
  unfold kl
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rcases eq_or_lt_of_le (hρ i) with h0 | hpos
  · simp [← h0]
  · rw [Real.log_div hpos.ne' (hσ i).ne']
    ring

omit [NeZero n] in
/-- Relative entropy is nonnegative against any positive density. -/
theorem kl_nonneg {ρ σ : Fin n → ℝ} (hρ : IsDensity ρ)
    (hσpos : ∀ i, 0 < σ i) (hσ : ∑ i, σ i = 1) : 0 ≤ kl ρ σ := by
  have h := gibbs_inequality hρ hσpos hσ
  rw [kl_split hρ.nonneg hσpos]
  linarith

/-- Guarded steps preserve density-hood. -/
theorem guardedStep_isDensity {ε δ : ℝ} (hε : 0 ≤ ε) (hδ : 0 ≤ δ)
    (hεδ : ε + δ ≤ 1) {σ ρ : Fin n → ℝ} (hσ : IsDensity σ)
    (hρ : IsDensity ρ) : IsDensity (guardedStep ε δ σ ρ) where
  nonneg i := by
    have h1 : 0 ≤ (1 - ε - δ) * ρ i :=
      mul_nonneg (by linarith) (hρ.nonneg i)
    have h2 : 0 ≤ ε * σ i := mul_nonneg hε (hσ.nonneg i)
    have h3 : 0 ≤ δ * (n : ℝ)⁻¹ := by positivity
    unfold guardedStep
    linarith
  sum_one := by
    have huni : ∑ _i : Fin n, δ * (n : ℝ)⁻¹ = δ := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      have hn : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne n)
      field_simp
    unfold guardedStep
    rw [Finset.sum_add_distrib, Finset.sum_add_distrib,
        ← Finset.mul_sum, ← Finset.mul_sum, hρ.sum_one, hσ.sum_one, huni]
    ring

/-! ### Guard 1 — the freeze guard (⊬ novum, negated) -/

omit [NeZero n] in
/-- **The novelty floor**: after a guarded step, every state — every
alternative hypothesis — retains mass at least δ/n. Nothing is ever
fully excluded; the simulation keeps every arm alive. -/
theorem novelty_floor {ε δ : ℝ} (hε : 0 ≤ ε) (hεδ : ε + δ ≤ 1)
    {σ ρ : Fin n → ℝ} (hσ : ∀ i, 0 ≤ σ i) (hρ : ∀ i, 0 ≤ ρ i) (i : Fin n) :
    δ * (n : ℝ)⁻¹ ≤ guardedStep ε δ σ ρ i := by
  have h1 : 0 ≤ (1 - ε - δ) * ρ i := mul_nonneg (by linarith) (hρ i)
  have h2 : 0 ≤ ε * σ i := mul_nonneg hε (hσ i)
  unfold guardedStep
  linarith

omit [NeZero n] in
/-- **The frozen state is unreachable**: with genuine imagination
(δ > 0) and at least two states, no guarded step lands on a point
mass — the collapsed flat state Book2.gibbs_concentrates exhibits for
the UNGUARDED target cannot be a guarded output. -/
theorem guarded_ne_pointMass {ε δ : ℝ} (hε : 0 ≤ ε) (hδ : 0 < δ)
    (hεδ : ε + δ ≤ 1) {σ ρ : Fin n → ℝ} (hσ : ∀ i, 0 ≤ σ i)
    (hρ : ∀ i, 0 ≤ ρ i) (hn : 2 ≤ n) (j : Fin n) :
    guardedStep ε δ σ ρ ≠ fun i => if i = j then 1 else 0 := by
  haveI : Nontrivial (Fin n) := Fin.nontrivial_iff_two_le.mpr hn
  obtain ⟨i, hij⟩ := exists_ne j
  intro h
  have hi := congrFun h i
  rw [if_neg hij] at hi
  have hfloor := novelty_floor hε hεδ hσ hρ (σ := σ) (ρ := ρ) (δ := δ) i
  have hnpos : (0 : ℝ) < (n : ℝ) := by
    have h2 : 0 < n := lt_of_lt_of_le (by norm_num) hn
    exact_mod_cast h2
  have hn0 : (0 : ℝ) < δ * (n : ℝ)⁻¹ := by positivity
  rw [hi] at hfloor
  linarith

/-- **β-independence of the floor**: instantiated at the Gibbs target,
the novelty floor holds at EVERY inverse temperature — while the
unguarded target concentrates as β → ∞ (Book2.gibbs_concentrates), the
guarded iterate keeps every alternative alive at every β. Imagination
outlives freezing at every temperature. -/
theorem guarded_floor_all_temperatures {ε δ : ℝ} (hε : 0 ≤ ε)
    (hεδ : ε + δ ≤ 1) (β : ℝ) (H : Fin n → ℝ) {ρ : Fin n → ℝ}
    (hρ : ∀ i, 0 ≤ ρ i) (i : Fin n) :
    δ * (n : ℝ)⁻¹ ≤ guardedStep ε δ (gibbs β H) ρ i :=
  novelty_floor hε hεδ (fun k => (gibbs_pos β H k).le) hρ i

/-! ### Guard 2 — the Moloch guard (bounded forever) -/

omit [NeZero n] in
/-- Three-term log-sum, from two applications of the two-term one. -/
theorem three_term_logsum {a b c A B C : ℝ} (ha : 0 ≤ a) (hb : 0 ≤ b)
    (hc : 0 ≤ c) (hA : 0 < A) (hB : 0 < B) (hC : 0 < C) :
    (a + b + c) * Real.log ((a + b + c) / (A + B + C)) ≤
      a * Real.log (a / A) + b * Real.log (b / B) + c * Real.log (c / C) := by
  have h12 := two_term_logsum ha hb hA hB
  have h123 := two_term_logsum (add_nonneg ha hb) hc
    (by linarith : (0:ℝ) < A + B) hC
  linarith

omit [NeZero n] in
/-- **KL contraction with declared imagination cost**: a guarded step
contracts relative entropy to the target by (1−ε−δ), paying at most
δ·KL(uniform‖target) for the simulation channel. The cost of keeping
every alternative alive is bounded and named. -/
theorem guarded_kl_le {ε δ : ℝ} (hε : 0 < ε) (hδ : 0 < δ) (hεδ : ε + δ < 1)
    {σ ρ : Fin n → ℝ} (hσpos : ∀ i, 0 < σ i) (hρ : ∀ i, 0 ≤ ρ i) :
    kl (guardedStep ε δ σ ρ) σ ≤
      (1 - ε - δ) * kl ρ σ + δ * kl uniform σ := by
  have hterm : ∀ i, guardedStep ε δ σ ρ i *
      Real.log (guardedStep ε δ σ ρ i / σ i) ≤
      (1 - ε - δ) * (ρ i * Real.log (ρ i / σ i)) +
        δ * ((n : ℝ)⁻¹ * Real.log ((n : ℝ)⁻¹ / σ i)) := by
    intro i
    have hinv : (0 : ℝ) ≤ (n : ℝ)⁻¹ := by positivity
    have h := three_term_logsum
      (a := (1 - ε - δ) * ρ i) (b := ε * σ i) (c := δ * (n : ℝ)⁻¹)
      (A := (1 - ε - δ) * σ i) (B := ε * σ i) (C := δ * σ i)
      (mul_nonneg (by linarith) (hρ i)) (mul_nonneg hε.le (hσpos i).le)
      (mul_nonneg hδ.le hinv)
      (mul_pos (by linarith : (0:ℝ) < 1 - ε - δ) (hσpos i))
      (mul_pos hε (hσpos i)) (mul_pos hδ (hσpos i))
    have hden : (1 - ε - δ) * σ i + ε * σ i + δ * σ i = σ i := by ring
    rw [hden] at h
    have hr1 : (1 - ε - δ) * ρ i / ((1 - ε - δ) * σ i) = ρ i / σ i := by
      rw [mul_div_mul_left _ _ (by linarith : (1:ℝ) - ε - δ ≠ 0)]
    have hr2 : ε * σ i / (ε * σ i) = 1 := div_self (mul_pos hε (hσpos i)).ne'
    have hr3 : δ * (n : ℝ)⁻¹ / (δ * σ i) = (n : ℝ)⁻¹ / σ i := by
      rw [mul_div_mul_left _ _ hδ.ne']
    rw [hr1, hr2, hr3, Real.log_one, mul_zero, add_zero] at h
    calc guardedStep ε δ σ ρ i * Real.log (guardedStep ε δ σ ρ i / σ i)
        = ((1 - ε - δ) * ρ i + ε * σ i + δ * (n : ℝ)⁻¹) *
            Real.log (((1 - ε - δ) * ρ i + ε * σ i + δ * (n : ℝ)⁻¹) / σ i) :=
          rfl
      _ ≤ (1 - ε - δ) * ρ i * Real.log (ρ i / σ i) +
            δ * (n : ℝ)⁻¹ * Real.log ((n : ℝ)⁻¹ / σ i) := h
      _ = (1 - ε - δ) * (ρ i * Real.log (ρ i / σ i)) +
            δ * ((n : ℝ)⁻¹ * Real.log ((n : ℝ)⁻¹ / σ i)) := by ring
  calc kl (guardedStep ε δ σ ρ) σ
      ≤ ∑ i, ((1 - ε - δ) * (ρ i * Real.log (ρ i / σ i)) +
          δ * ((n : ℝ)⁻¹ * Real.log ((n : ℝ)⁻¹ / σ i))) :=
        Finset.sum_le_sum fun i _ => hterm i
    _ = (1 - ε - δ) * kl ρ σ + δ * kl uniform σ := by
        rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
        rfl

omit [NeZero n] in
/-- **The Moloch guard (single-step invariant)**: any bound covering
both the current divergence and the imagination channel's divergence is
preserved by the guarded step. No quantity the guard tracks can grow
past its declared budget — perpetual ascent is structurally unavailable. -/
theorem moloch_guard {ε δ M : ℝ} (hε : 0 < ε) (hδ : 0 < δ) (hεδ : ε + δ < 1)
    {σ ρ : Fin n → ℝ} (hσpos : ∀ i, 0 < σ i) (hρ : ∀ i, 0 ≤ ρ i)
    (hMρ : kl ρ σ ≤ M) (hMu : kl uniform σ ≤ M) (hM : 0 ≤ M) :
    kl (guardedStep ε δ σ ρ) σ ≤ M := by
  have h := guarded_kl_le hε hδ hεδ hσpos hρ (σ := σ) (ρ := ρ)
  have h1 : (1 - ε - δ) * kl ρ σ ≤ (1 - ε - δ) * M :=
    mul_le_mul_of_nonneg_left hMρ (by linarith)
  have h2 : δ * kl uniform σ ≤ δ * M := mul_le_mul_of_nonneg_left hMu hδ.le
  have h3 : 0 ≤ ε * M := mul_nonneg hε.le hM
  nlinarith [h, h1, h2, h3]

/-- **Bounded forever**: along any guarded trajectory, the divergence
to the target never exceeds the maximum of its initial value and the
imagination cost — for every step, at every horizon. The helix never
escapes. -/
theorem guarded_sequence_bounded {ε δ : ℝ} (hε : 0 < ε) (hδ : 0 < δ)
    (hεδ : ε + δ < 1) {σ : Fin n → ℝ} (hσ : IsDensity σ)
    (hσpos : ∀ i, 0 < σ i) (ρseq : ℕ → Fin n → ℝ)
    (h0 : IsDensity (ρseq 0))
    (hstep : ∀ k, ρseq (k + 1) = guardedStep ε δ σ (ρseq k)) (k : ℕ) :
    IsDensity (ρseq k) ∧
      kl (ρseq k) σ ≤ max (kl (ρseq 0) σ) (kl uniform σ) := by
  set M := max (kl (ρseq 0) σ) (kl uniform σ) with hM
  have hMnn : 0 ≤ M := by
    have := kl_nonneg h0 hσpos hσ.sum_one
    exact le_trans this (le_max_left _ _)
  induction k with
  | zero => exact ⟨h0, le_max_left _ _⟩
  | succ m ih =>
      obtain ⟨hd, hb⟩ := ih
      constructor
      · rw [hstep m]
        exact guardedStep_isDensity hε.le hδ.le hεδ.le hσ hd
      · rw [hstep m]
        exact moloch_guard hε hδ hεδ hσpos hd.nonneg hb (le_max_right _ _)
          hMnn

/-! ### Guard 3 — the Gödel guard (no arrival) -/

omit [NeZero n] in
/-- **Arrival iff uniform**: the guarded step rests AT the
pure-prediction target iff the target is already uniform — whenever
prediction has any content at all, the guard structurally forbids
claiming arrival. Approach without arrival (with_and_was), as design:
the loop is constrained by the guard, never certified by it. -/
theorem guarded_arrival_iff_uniform {ε δ : ℝ} (hδ : 0 < δ)
    (σ : Fin n → ℝ) :
    guardedStep ε δ σ σ = σ ↔ σ = uniform := by
  constructor
  · intro h
    funext i
    have hi := congrFun h i
    unfold guardedStep at hi
    have hkey : δ * (n : ℝ)⁻¹ = δ * σ i := by linear_combination hi
    have := mul_left_cancel₀ hδ.ne' hkey
    unfold uniform
    linarith
  · intro h
    subst h
    funext i
    unfold guardedStep uniform
    ring

end

end ForcingAnalysis.FabricPC
