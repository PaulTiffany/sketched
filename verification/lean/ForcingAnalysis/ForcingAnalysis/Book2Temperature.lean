/-
Book2Temperature.lean — the temperature trichotomy: freezing at β → ∞.

Book II's authorial conception (the genesis retrospective): temperature
is not imported thermodynamic vocabulary — it is the negotiation knob
between drift (dispersion into possibility) and reflection (what a
bounded system can coherently retain). The finite Gibbs kernel now
certifies all three regimes of that knob:

  * β = 0 (pure drift): the Gibbs state is exactly uniform —
    `Poetry.gibbs_zero_uniform` (temperatio: "unif ⊬ verum");
  * finite β (the negotiation): the Gibbs state uniquely minimizes
    F = ⟨H⟩ − S/β, balancing coherence against dispersion —
    `Book2.gibbs_minimizes` / `gibbs_unique_minimizer`;
  * β → ∞ (pure reflection): THIS FILE — the Gibbs state freezes onto
    the minimizers of H. `gibbs_freezes`: every strictly suboptimal
    state's mass tends to zero; `gibbs_concentrates`: a unique minimizer
    absorbs all mass in the limit. Temperatio's opening line
    (β → ∞ ⇒ ρ = δ_argmin H) and its negation (δ_argmin ⊬ novum: the
    frozen state yields no novelty, because everything off the minimum
    has vanishing weight) — the line LPS-P44 left open, now closed.

Method note: the bound is the raw ratio gibbs β H i ≤ e^{β(H j − H i)},
proved by bounding the partition function below by a single term — no
normalized large-deviations machinery, per the non-normalized-forms
rule. The Friston contrast from the genesis intent stays exact: descent
is DERIVED under stated dynamics (Book2H.h_theorem for the
detailed-balance shadow of the gradient condition, with
Book2.cycle_stationary_not_reversible as the outside-gradient
countermodel); nothing here axiomatizes minimization.
-/

import Mathlib
import ForcingAnalysis.Book2

namespace ForcingAnalysis.Book2

open Filter

variable {n : ℕ} [NeZero n]

/-- The raw ratio bound: each Gibbs weight is dominated by the
Boltzmann ratio against ANY reference state — the partition function is
bounded below by a single term. Holds for every real β. -/
theorem gibbs_le_exp (β : ℝ) (H : Fin n → ℝ) (i j : Fin n) :
    gibbs β H i ≤ Real.exp (β * (H j - H i)) := by
  have hZ : Real.exp (-β * H j) ≤ partition β H :=
    Finset.single_le_sum (fun k _ => (Real.exp_pos (-β * H k)).le)
      (Finset.mem_univ j)
  have hsplit : Real.exp (β * (H j - H i)) * Real.exp (-β * H j) =
      Real.exp (-β * H i) := by
    rw [← Real.exp_add]
    ring_nf
  rw [gibbs, div_le_iff₀ (partition_pos β H)]
  calc Real.exp (-β * H i)
      = Real.exp (β * (H j - H i)) * Real.exp (-β * H j) := hsplit.symm
    _ ≤ Real.exp (β * (H j - H i)) * partition β H :=
        mul_le_mul_of_nonneg_left hZ (Real.exp_pos _).le

/-- **Freezing** (temperatio: β → ∞ ⇒ ρ = δ_argmin H, suboptimal half):
any state strictly above some other state's energy loses all Gibbs mass
as β → ∞ — the frozen state yields no novelty. -/
theorem gibbs_freezes {H : Fin n → ℝ} {i j : Fin n} (hij : H j < H i) :
    Tendsto (fun β => gibbs β H i) atTop (nhds 0) := by
  have hc : H j - H i < 0 := by linarith
  have hlin : Tendsto (fun β : ℝ => β * (H j - H i)) atTop atBot := by
    have h1 : Tendsto (fun β : ℝ => β * (H i - H j)) atTop atTop :=
      Tendsto.atTop_mul_const (by linarith) tendsto_id
    have heq : (fun β : ℝ => β * (H j - H i)) =
        fun β : ℝ => -(β * (H i - H j)) := by
      funext β; ring
    rw [heq]
    exact tendsto_neg_atTop_atBot.comp h1
  have hupper : Tendsto (fun β => Real.exp (β * (H j - H i)))
      atTop (nhds 0) := Real.tendsto_exp_atBot.comp hlin
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds hupper
    (fun β => (gibbs_pos β H i).le) (fun β => gibbs_le_exp β H i j)

/-- **Concentration** (temperatio, minimizer half): a unique minimizer
absorbs all Gibbs mass as β → ∞ — the tempered measure collapses to
δ_argmin H, exactly as the poem's opening line states. -/
theorem gibbs_concentrates {H : Fin n → ℝ} {j : Fin n}
    (hmin : ∀ i, i ≠ j → H j < H i) :
    Tendsto (fun β => gibbs β H j) atTop (nhds 1) := by
  have hrest : Tendsto
      (fun β => ∑ i ∈ Finset.univ.erase j, gibbs β H i) atTop (nhds 0) := by
    have h0 : (0 : ℝ) = ∑ _i ∈ Finset.univ.erase j, (0 : ℝ) := by simp
    rw [h0]
    exact tendsto_finsetSum _ fun i hi =>
      gibbs_freezes (hmin i (Finset.ne_of_mem_erase hi))
  have heq : ∀ β : ℝ, gibbs β H j =
      1 - ∑ i ∈ Finset.univ.erase j, gibbs β H i := by
    intro β
    have hsum := (gibbs_isDensity β H).sum_one
    have hsplit : gibbs β H j + ∑ i ∈ Finset.univ.erase j, gibbs β H i =
        ∑ i, gibbs β H i :=
      Finset.add_sum_erase Finset.univ _ (Finset.mem_univ j)
    rw [hsum] at hsplit
    linarith
  have hlim : Tendsto
      (fun β => 1 - ∑ i ∈ Finset.univ.erase j, gibbs β H i)
      atTop (nhds (1 - 0)) := tendsto_const_nhds.sub hrest
  rw [show (1 : ℝ) - 0 = 1 by ring] at hlim
  exact hlim.congr fun β => (heq β).symm

end ForcingAnalysis.Book2
