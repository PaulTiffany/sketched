/- Book5StrategyBalance.lean — drift/reflection capacity balance in strategy space. -/
import Mathlib

namespace ForcingAnalysis.Book5StrategyBalance

structure Strategy where
  reflectionCapacity : ℝ
  cooperation : ℝ

/-- Strict viability margin advertised by the source theorem. -/
def Balances (drift : ℝ) (strategy : Strategy) : Prop :=
  drift < strategy.reflectionCapacity * strategy.cooperation

theorem balance_iff_capacity_above_threshold {drift : ℝ} {strategy : Strategy}
    (hCooperation : 0 < strategy.cooperation) :
    Balances drift strategy ↔
      drift / strategy.cooperation < strategy.reflectionCapacity := by
  unfold Balances
  rw [div_lt_iff₀ hCooperation]

theorem isolated_strategy_cannot_balance_positive_drift
    {drift capacity : ℝ} (hDrift : 0 ≤ drift) :
    ¬ Balances drift ⟨capacity, 0⟩ := by
  simp [Balances, not_lt.mpr hDrift]

/-- The load-bearing availability premise: the strategy inventory actually
contains a cooperative reflection capacity above the required threshold. -/
structure AvailableBalance (available : Set Strategy) (drift : ℝ) where
  strategy : Strategy
  mem_available : strategy ∈ available
  cooperation_pos : 0 < strategy.cooperation
  capacity_above : drift / strategy.cooperation < strategy.reflectionCapacity

theorem exists_available_balancing_strategy {available : Set Strategy}
    {drift : ℝ} (witness : AvailableBalance available drift) :
    ∃ strategy ∈ available, Balances drift strategy := by
  refine ⟨witness.strategy, witness.mem_available, ?_⟩
  exact (balance_iff_capacity_above_threshold witness.cooperation_pos).2
    witness.capacity_above

/-- Merely bounding drift below a named maximum says nothing about whether
the available strategy inventory contains any reflection operator. -/
theorem submaximal_drift_alone_does_not_supply_available_strategy :
    let drift : ℝ := 0
    let driftMax : ℝ := 1
    drift < driftMax ∧
      ¬ ∃ strategy ∈ (∅ : Set Strategy), Balances drift strategy := by
  norm_num

/-- Exact cancellation has zero margin and therefore does not meet the
source's strict strategic viability criterion. -/
theorem local_cancellation_is_not_strict_balance :
    let drift : ℝ := 1
    let strategy : Strategy := ⟨1, 1⟩
    strategy.reflectionCapacity * strategy.cooperation = drift ∧
      ¬ Balances drift strategy := by
  norm_num [Balances]

end ForcingAnalysis.Book5StrategyBalance
