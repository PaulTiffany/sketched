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


/-! ## Metric two-sided reconstruction

The finite discrete kernel above detects exact equality. The source limit is
stronger and subtler: ESS and MAP strategies may remain distinct at every
finite stage while becoming mutually approximable in an actual strategy-space
metric. -/

/-- Quantitative two-sided approximation of a varying ESS set by the MAP set.
Each direction is retained because population concentration or non-invasion can
supply at most one of them. -/
structure TwoSidedStrategyApproximation {Strategy : Type*} [PseudoMetricSpace Strategy]
    (ess : ℕ → Set Strategy) (map : Set Strategy) (tolerance : ℕ → ℝ) where
  tolerance_nonneg : ∀ n, 0 ≤ tolerance n
  ess_to_map : ∀ n strategy, strategy ∈ ess n →
    ∃ target ∈ map, dist strategy target ≤ tolerance n
  map_to_ess : ∀ n strategy, strategy ∈ map →
    ∃ source ∈ ess n, dist strategy source ≤ tolerance n

namespace TwoSidedStrategyApproximation

variable {Strategy : Type*} [PseudoMetricSpace Strategy]
  {ess : ℕ → Set Strategy} {map : Set Strategy} {tolerance : ℕ → ℝ}

/-- The two directed witness laws bound the genuine Hausdorff distance. -/
theorem hausdorffDist_le
    (A : TwoSidedStrategyApproximation ess map tolerance) (n : ℕ) :
    Metric.hausdorffDist (ess n) map ≤ tolerance n := by
  apply Metric.hausdorffDist_le_of_mem_dist (A.tolerance_nonneg n)
  · exact A.ess_to_map n
  · intro strategy hmap
    obtain ⟨source, hsource, hdist⟩ := A.map_to_ess n strategy hmap
    exact ⟨source, hsource, by simpa [dist_comm] using hdist⟩

/-- Shrinking two-sided approximation forces ESS--MAP Hausdorff convergence
without asserting that the predicates or sets are literally equal at any
finite stage. -/
theorem hausdorffDist_tendsto_zero
    (A : TwoSidedStrategyApproximation ess map tolerance)
    (hTolerance : Filter.Tendsto tolerance Filter.atTop (nhds 0)) :
    Filter.Tendsto (fun n => Metric.hausdorffDist (ess n) map)
      Filter.atTop (nhds 0) := by
  exact squeeze_zero
    (fun n => Metric.hausdorffDist_nonneg)
    (fun n => A.hausdorffDist_le n)
    hTolerance

/-- Equality is a sufficient zero-tolerance boundary, but it is not built into
the convergence theorem. -/
theorem of_eventual_equality
    (h : ∀ n, ess n = map) :
    TwoSidedStrategyApproximation ess map (fun _ => 0) where
  tolerance_nonneg := by intro n; norm_num
  ess_to_map := by
    intro n strategy hess
    exact ⟨strategy, h n ▸ hess, by simp⟩
  map_to_ess := by
    intro n strategy hmap
    exact ⟨strategy, (h n).symm ▸ hmap, by simp⟩

end TwoSidedStrategyApproximation

/-- One directed inclusion is not Hausdorff equivalence. The ESS set may omit a
MAP strategy even when every ESS strategy is already MAP. -/
theorem one_sided_ess_to_map_does_not_identify_sets :
    let ess : Set ℝ := {0}
    let map : Set ℝ := {0, 1}
    (∀ strategy ∈ ess, ∃ target ∈ map, dist strategy target = 0) ∧
      ess ≠ map := by
  dsimp
  constructor
  · intro strategy hstrategy
    have hzero : strategy = 0 := by simpa using hstrategy
    subst strategy
    exact ⟨0, by simp, by simp⟩
  · intro h
    have hOne : (1 : ℝ) ∈ ({0} : Set ℝ) := by
      rw [h]
      simp
    norm_num at hOne

/-- Convergence of occupied population mass does not supply either directed
set-approximation witness for the abstract strategy predicates. -/
theorem population_limit_does_not_supply_two_sided_approximation :
    let map : Set ℝ := {0}
    let ess : ℕ → Set ℝ := fun _ => {1}
    Filter.Tendsto (fun _ : ℕ => (1 : ℝ)) Filter.atTop (nhds 1) ∧
      ¬ (∀ n strategy, strategy ∈ map →
        ∃ source ∈ ess n, dist strategy source ≤ 0) := by
  dsimp
  constructor
  · exact tendsto_const_nhds
  · intro h
    obtain ⟨source, hsource, hdist⟩ := h 0 0 (by simp)
    have : source = 1 := by simpa using hsource
    subst source
    norm_num at hdist

end ForcingAnalysis.Book5ESSEquivalence
