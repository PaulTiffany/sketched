/-
Book2CycleConsistency.lean — closed-cycle and holonomy reconstruction for
Principia Symbolica Book 2 hypothesis-surface thermodynamics.
-/
import Mathlib

namespace ForcingAnalysis.Book2CycleConsistency

/-- Work of a scalar state function around a finite closed cycle represented by
an index permutation. -/
def cycleWork {n : ℕ} (σ : Equiv.Perm (Fin n)) (f : Fin n → ℝ) : ℝ :=
  ∑ i, (f (σ i) - f i)

/-- Every genuine state function has zero work around a closed finite cycle. -/
theorem cycleWork_eq_zero {n : ℕ} (σ : Equiv.Perm (Fin n)) (f : Fin n → ℝ) :
    cycleWork σ f = 0 := by
  unfold cycleWork
  rw [Finset.sum_sub_distrib, Equiv.sum_comp]
  exact sub_self _

/-- Discrete holonomy of the entropy-weighted temperature exchange. Unlike the
work of a state function, this one-form need not be exact. -/
def entropyTemperatureHolonomy {n : ℕ} (σ : Equiv.Perm (Fin n))
    (S T : Fin n → ℝ) : ℝ :=
  ∑ i, S i * (T (σ i) - T i)

/-- Integrability means the entropy-temperature increment is the difference of
a globally defined potential along every edge of the cycle. -/
structure IntegrableEntropyTemperature {n : ℕ} (σ : Equiv.Perm (Fin n))
    (S T : Fin n → ℝ) where
  potential : Fin n → ℝ
  exact_increment :
    ∀ i, S i * (T (σ i) - T i) = potential (σ i) - potential i

theorem entropyTemperatureHolonomy_eq_zero_of_integrable
    {n : ℕ} {σ : Equiv.Perm (Fin n)} {S T : Fin n → ℝ}
    (h : IntegrableEntropyTemperature σ S T) :
    entropyTemperatureHolonomy σ S T = 0 := by
  unfold entropyTemperatureHolonomy
  calc
    (∑ i, S i * (T (σ i) - T i)) =
        ∑ i, (h.potential (σ i) - h.potential i) := by
          apply Finset.sum_congr rfl
          intro i hi
          exact h.exact_increment i
    _ = cycleWork σ h.potential := rfl
    _ = 0 := cycleWork_eq_zero σ h.potential

/-- The consistency equation follows from closed-cycle state-function exactness
and integrability of entropy-temperature exchange. -/
theorem thermodynamic_consistency_of_closed_integrable_cycle
    {n : ℕ} (σ : Equiv.Perm (Fin n)) (F S T : Fin n → ℝ)
    (h : IntegrableEntropyTemperature σ S T) :
    cycleWork σ F = -entropyTemperatureHolonomy σ S T := by
  rw [cycleWork_eq_zero, entropyTemperatureHolonomy_eq_zero_of_integrable h, neg_zero]

/-- Exactness is the precise missing premise: since closed free-energy work is
zero, consistency is equivalent to zero entropy-temperature holonomy. -/
theorem consistency_iff_zero_entropyTemperatureHolonomy
    {n : ℕ} (σ : Equiv.Perm (Fin n)) (F S T : Fin n → ℝ) :
    cycleWork σ F = -entropyTemperatureHolonomy σ S T ↔
      entropyTemperatureHolonomy σ S T = 0 := by
  rw [cycleWork_eq_zero]
  constructor <;> intro h
  · linarith
  · rw [h, neg_zero]

/-- Continuous boundary-trace lift of the finite cycle law. Along a
parameterized boundary, the first-variation decomposition and vanishing
observer-energy/temperature-entropy balance leave exactly the negative
entropy-temperature exchange. This is an interval-integral kernel; the
arbitrary-manifold differential-form and Stokes lift remains separate. -/
theorem path_thermodynamic_consistency
    {a b : ℝ} (dF dE dS dT S T : ℝ → ℝ)
    (hvariation : ∀ t ∈ Set.uIcc a b,
      dF t = (dE t - T t * dS t) - S t * dT t)
    (hbalanceInt : IntervalIntegrable (fun t => dE t - T t * dS t)
      MeasureTheory.volume a b)
    (hexchangeInt : IntervalIntegrable (fun t => S t * dT t)
      MeasureTheory.volume a b)
    (hbalance : (∫ t in a..b, dE t - T t * dS t) = 0) :
    (∫ t in a..b, dF t) = -(∫ t in a..b, S t * dT t) := by
  calc
    (∫ t in a..b, dF t) =
        ∫ t in a..b, (dE t - T t * dS t) - S t * dT t := by
          apply intervalIntegral.integral_congr
          intro t ht
          exact hvariation t ht
    _ = (∫ t in a..b, dE t - T t * dS t) -
        (∫ t in a..b, S t * dT t) :=
          intervalIntegral.integral_sub hbalanceInt hexchangeInt
    _ = -(∫ t in a..b, S t * dT t) := by rw [hbalance, zero_sub]
/-- Closedness alone does not erase exchange holonomy. -/
theorem closed_cycle_can_have_nonzero_entropyTemperatureHolonomy :
    ∃ (σ : Equiv.Perm (Fin 2)) (S T : Fin 2 → ℝ),
      entropyTemperatureHolonomy σ S T ≠ 0 := by
  let σ : Equiv.Perm (Fin 2) := Equiv.swap 0 1
  let S : Fin 2 → ℝ := fun i => if i = 0 then 0 else 1
  let T : Fin 2 → ℝ := fun i => if i = 0 then 0 else 1
  refine ⟨σ, S, T, ?_⟩
  norm_num [entropyTemperatureHolonomy, σ, S, T, Fin.sum_univ_two]

end ForcingAnalysis.Book2CycleConsistency