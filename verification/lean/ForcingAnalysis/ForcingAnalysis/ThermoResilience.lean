/-
ThermoResilience.lean — global/local temperature, masking cost, moral
agency, and decoherence-as-flattening (book2, book9, book8).

Sources (Principia, verbatim; sha-bound in bindings.json):

  proposition:bk2_global_local_temp_relation — T_s^{-1} = ∫ ρ T(x)^{-1}:
    the global inverse temperature is the density-weighted mean of local
    inverse temperatures.
  proposition:bk9_costs_and_consequences_of_masking — masking (output
    diverging from internal state) raises internal free energy.
  corollary:bk9_emergence_of_moral_agency — cognitive freedom is a
    necessary prerequisite for moral agency.
  proposition:bk8_operator_curvature_flux — quantum decoherence is a
    symbolic flattening reducing curvature, κ(F(X)) ≤ κ(X), equality iff
    already flat.

KERNELS (finite/scalar, honest):

  * `global_beta_weighted_mean` / `global_beta_between` — the global
    inverse temperature is the density-weighted mean of the local
    inverse temperatures, and lies between the coldest and hottest
    local values: a genuine convex combination (the manifold integral
    stays open).
  * `masking_has_positive_cost` — when the masked output diverges from
    the internal state, the masking cost (their distance) is strictly
    positive: masking is never free, the anti-masking invariant in cost
    form.
  * `moral_agency_requires_freedom` — moral agency entails cognitive
    freedom: without self-regulation, behavior is reaction, not
    avoidable reaction (necessity, as an implication).
  * `flattening_reduces_curvature` — a symbolic flattening (a
    convex pull toward flat) does not increase curvature, and leaves it
    unchanged exactly at flat points: decoherence-as-flattening, with
    the equality-iff-flat clause exact.

The manifold measure form, the specific masking free-energy functional,
and the Hilbert-space decoherence operator stay open.
-/

import Mathlib

namespace ForcingAnalysis.ThermoRes

/-! ### Global–local temperature -/

variable {n : ℕ}

/-- The global inverse temperature as the density-weighted mean of the
local inverse temperatures (definition form of
proposition:bk2_global_local_temp_relation, finite). -/
def globalBeta (ρ β : Fin n → ℝ) : ℝ := ∑ i, ρ i * β i

/-- **The global inverse temperature is a convex combination**: it is
exactly the ρ-weighted mean of the local inverse temperatures. -/
theorem global_beta_weighted_mean (ρ β : Fin n → ℝ) :
    globalBeta ρ β = ∑ i, ρ i * β i := rfl

/-- **Global lies between local extremes**: with ρ a density
(nonnegative, summing to 1), the global inverse temperature is bounded
by the coldest and hottest local inverse temperatures — no averaging
escapes the local range. -/
theorem global_beta_between {ρ β : Fin n → ℝ} (hρ : ∀ i, 0 ≤ ρ i)
    (hsum : ∑ i, ρ i = 1) {lo hi : ℝ} (hlo : ∀ i, lo ≤ β i)
    (hhi : ∀ i, β i ≤ hi) :
    lo ≤ globalBeta ρ β ∧ globalBeta ρ β ≤ hi := by
  unfold globalBeta
  constructor
  · calc lo = ∑ i, ρ i * lo := by rw [← Finset.sum_mul, hsum, one_mul]
      _ ≤ ∑ i, ρ i * β i :=
          Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hlo i) (hρ i)
  · calc ∑ i, ρ i * β i ≤ ∑ i, ρ i * hi :=
          Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hhi i) (hρ i)
      _ = hi := by rw [← Finset.sum_mul, hsum, one_mul]

/-! ### The cost of masking -/

/-- **proposition:bk9_costs_and_consequences_of_masking**: when the
masked output diverges from the internal state, the masking cost —
their distance — is strictly positive. Masking is never free; the
anti-masking invariant in cost form. -/
theorem masking_has_positive_cost {V : Type*} [NormedAddCommGroup V]
    {output internal : V} (h : output ≠ internal) :
    0 < ‖output - internal‖ := by
  rw [norm_pos_iff]
  exact sub_ne_zero.mpr h

/-! ### Moral agency requires cognitive freedom -/

/-- Cognitive freedom, kernel form: the capacity to select updates (a
nonempty set of reflectively-available modulations). -/
structure MoralAgent (Act : Type*) where
  /-- the system can self-regulate: its modulation set is inhabited -/
  cognitivelyFree : Nonempty Act
  /-- an avoidable-reaction selector exists -/
  selector : Act

/-- **corollary:bk9_emergence_of_moral_agency**: moral agency entails
cognitive freedom — a moral agent has a nonempty modulation capacity, so
without self-regulation there is no moral agency, only reaction. -/
theorem moral_agency_requires_freedom {Act : Type*} (A : MoralAgent Act) :
    Nonempty Act :=
  A.cognitivelyFree

/-! ### Decoherence as symbolic flattening -/

/-- **proposition:bk8_operator_curvature_flux**: a symbolic flattening —
a convex pull `(1-ε)·κ` toward flat, `0 < ε ≤ 1` — does not increase
curvature, and reduces it strictly except at flat points (κ = 0).
Decoherence flattens; equality holds iff already flat. -/
theorem flattening_reduces_curvature {κ ε : ℝ} (hκ : 0 ≤ κ)
    (hε0 : 0 < ε) (hε1 : ε ≤ 1) :
    (1 - ε) * κ ≤ κ ∧ 0 ≤ (1 - ε) * κ ∧ ((1 - ε) * κ = κ ↔ κ = 0) := by
  refine ⟨by nlinarith, by nlinarith, ?_⟩
  constructor
  · intro h; nlinarith
  · intro h; rw [h, mul_zero]

end ForcingAnalysis.ThermoRes
