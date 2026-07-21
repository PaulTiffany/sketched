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


/-! ## Operator inventory reconstruction

The source speaks about drift and reflection *operators* available to a strategy.
The scalar kernel above checks the final inequality; this layer retains the typed
operators and constructs the viable MAP subset from an explicit availability
law. -/

/-- A typed strategy space with observer-assigned operator intensities and a
strategy-indexed inventory of available reflection operators. -/
structure OperatorStrategySpace (StrategyT DriftT ReflectionT : Type*) where
  isMAP : Set StrategyT
  driftIntensity : DriftT → ℝ
  reflectionCapacity : ReflectionT → ℝ
  cooperation : StrategyT → ℝ
  available : StrategyT → ReflectionT → Prop

namespace OperatorStrategySpace

variable {StrategyT DriftT ReflectionT : Type*} (S : OperatorStrategySpace StrategyT DriftT ReflectionT)

/-- A particular available reflection operator strictly overcomes a drift for a
particular strategy. -/
def OperatorBalances (drift : DriftT) (strategy : StrategyT) (reflection : ReflectionT) : Prop :=
  S.available strategy reflection ∧
    S.driftIntensity drift <
      S.reflectionCapacity reflection * S.cooperation strategy

/-- The source's drift-indexed MAP subset, now defined by MAP membership plus an
actual available balancing reflection witness. -/
def viableMAP (drift : DriftT) : Set StrategyT :=
  {strategy | strategy ∈ S.isMAP ∧
    ∃ reflection, S.OperatorBalances drift strategy reflection}

/-- Availability is load-bearing. Cofinality says that for every requested
finite capacity, the strategy inventory contains a stronger reflection
operator. -/
def ReflectionCofinalAt (strategy : StrategyT) : Prop :=
  ∀ threshold : ℝ, ∃ reflection : ReflectionT,
    S.available strategy reflection ∧
      threshold < S.reflectionCapacity reflection

/-- Richness is asserted only for at least one cooperative MAP strategy. This is
exactly enough for the nonemptiness conclusion printed in the source. -/
structure MAPReflectionRichness where
  strategy : StrategyT
  map_mem : strategy ∈ S.isMAP
  cooperation_pos : 0 < S.cooperation strategy
  reflection_cofinal : S.ReflectionCofinalAt strategy

/-- Cofinal availability supplies a reflection operator beyond the exact
cooperation-adjusted threshold. -/
theorem exists_operator_balance_of_cofinal
    {drift : DriftT} {strategy : StrategyT}
    (hCooperation : 0 < S.cooperation strategy)
    (hCofinal : S.ReflectionCofinalAt strategy) :
    ∃ reflection, S.OperatorBalances drift strategy reflection := by
  obtain ⟨reflection, hAvailable, hCapacity⟩ :=
    hCofinal (S.driftIntensity drift / S.cooperation strategy)
  refine ⟨reflection, hAvailable, ?_⟩
  exact (div_lt_iff₀ hCooperation).mp hCapacity

/-- The rebuilt existence theorem: a rich operator inventory constructs a
nonempty drift-indexed MAP subset. A named upper drift bound is not used because
cofinality already answers every finite observed drift intensity. -/
theorem viableMAP_nonempty_of_richness
    (richness : MAPReflectionRichness S) (drift : DriftT) :
    (S.viableMAP drift).Nonempty := by
  refine ⟨richness.strategy, richness.map_mem, ?_⟩
  exact S.exists_operator_balance_of_cofinal
    richness.cooperation_pos richness.reflection_cofinal

/-- Every member of the constructed subset carries the advertised operator
witness; this is an elimination theorem, not a second existence assumption. -/
theorem mem_viableMAP_iff (drift : DriftT) (strategy : StrategyT) :
    strategy ∈ S.viableMAP drift ↔
      strategy ∈ S.isMAP ∧
        ∃ reflection, S.available strategy reflection ∧
          S.driftIntensity drift <
            S.reflectionCapacity reflection * S.cooperation strategy := by
  rfl

/-- A uniform richness law upgrades the result from nonemptiness to equality:
every MAP strategy is viable against the observed drift. -/
theorem viableMAP_eq_isMAP_of_uniform_richness
    (hCooperation : ∀ strategy ∈ S.isMAP, 0 < S.cooperation strategy)
    (hCofinal : ∀ strategy ∈ S.isMAP, S.ReflectionCofinalAt strategy)
    (drift : DriftT) :
    S.viableMAP drift = S.isMAP := by
  ext strategy
  constructor
  · exact fun h => h.1
  · intro hMAP
    exact ⟨hMAP, S.exists_operator_balance_of_cofinal
      (hCooperation strategy hMAP) (hCofinal strategy hMAP)⟩

/-- Positive cooperation and a sub-maximal drift label still do not manufacture
an available reflection operator in the typed setting. -/
theorem submaximal_drift_without_inventory_countermodel :
    let S : OperatorStrategySpace Unit Unit Empty :=
      { isMAP := Set.univ
        driftIntensity := fun _ => 0
        reflectionCapacity := Empty.elim
        cooperation := fun _ => 1
        available := fun _ r => Empty.elim r }
    S.driftIntensity () < 1 ∧
      0 < S.cooperation () ∧
      (S.viableMAP ()).Nonempty = False := by
  norm_num [viableMAP, OperatorBalances]

end OperatorStrategySpace
end ForcingAnalysis.Book5StrategyBalance
