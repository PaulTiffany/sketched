/- Book5ESSEquivalence.lean — finite ESS/MAP set-identification kernel. -/
import Mathlib

namespace ForcingAnalysis.Book5ESSEquivalence

/-- Discrete Hausdorff analogue for finite strategy sets. -/
def discreteSetDistance {Strategy : Type*} [DecidableEq Strategy]
    (first second : Finset Strategy) : ℝ :=
  if first = second then 0 else 1

theorem discreteSetDistance_eq_zero_iff {Strategy : Type*}
    [DecidableEq Strategy] (first second : Finset Strategy) :
    discreteSetDistance first second = 0 ↔ first = second := by
  by_cases h : first = second
  · simp [discreteSetDistance, h]
  · simp [discreteSetDistance, h]

/-- The two logically distinct directions needed by ESS–MAP equivalence. -/
structure CriticalIdentification {Strategy : Type*} [DecidableEq Strategy]
    (ess map : Finset Strategy) where
  ess_is_map : ∀ strategy ∈ ess, strategy ∈ map
  map_is_ess : ∀ strategy ∈ map, strategy ∈ ess

theorem CriticalIdentification.sets_eq {Strategy : Type*}
    [DecidableEq Strategy] {ess map : Finset Strategy}
    (identification : CriticalIdentification ess map) : ess = map := by
  apply Finset.Subset.antisymm
  · exact identification.ess_is_map
  · exact identification.map_is_ess

theorem CriticalIdentification.distance_zero {Strategy : Type*}
    [DecidableEq Strategy] {ess map : Finset Strategy}
    (identification : CriticalIdentification ess map) :
    discreteSetDistance ess map = 0 :=
  (discreteSetDistance_eq_zero_iff ess map).2 identification.sets_eq

/-- Eventual two-sided critical identification yields the printed zero-limit
conclusion in the finite discrete strategy geometry. -/
theorem distance_tendsto_zero_of_eventually_identified {Strategy : Type*}
    [DecidableEq Strategy] (ess : ℕ → Finset Strategy) (map : Finset Strategy)
    (h : ∀ᶠ n in Filter.atTop, CriticalIdentification (ess n) map) :
    Filter.Tendsto (fun n => discreteSetDistance (ess n) map)
      Filter.atTop (nhds 0) := by
  have heq : (fun n => discreteSetDistance (ess n) map) =ᶠ[Filter.atTop]
      (fun _ : ℕ => (0 : ℝ)) := by
    filter_upwards [h] with n hn
    exact hn.distance_zero
  exact tendsto_const_nhds.congr' heq.symm

/-- Population concentration on MAP does not itself prove that the abstract
ESS set equals the MAP set. -/
theorem population_concentration_alone_does_not_identify_strategy_sets :
    discreteSetDistance (∅ : Finset Bool) {true} = 1 := by
  simp [discreteSetDistance]

end ForcingAnalysis.Book5ESSEquivalence
