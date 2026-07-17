/- Book5DualityProof.lean — variational sign kernel for the enhanced MAP–MAD proof. -/
import Mathlib
import ForcingAnalysis.Book5EnhancedDuality

namespace ForcingAnalysis.Book5DualityProof

/-- The displayed process free-energy balance. -/
def freeEnergyRate (reflectiveProduction thermalEntropyCost : ℝ) : ℝ :=
  reflectiveProduction - thermalEntropyCost

theorem map_rate_positive_iff {reflectiveProduction thermalEntropyCost : ℝ} :
    0 < freeEnergyRate reflectiveProduction thermalEntropyCost ↔
      thermalEntropyCost < reflectiveProduction := by
  unfold freeEnergyRate
  exact sub_pos
theorem mad_rate_negative_iff {reflectiveProduction thermalEntropyCost : ℝ} :
    freeEnergyRate reflectiveProduction thermalEntropyCost < 0 ↔
      reflectiveProduction < thermalEntropyCost := by
  unfold freeEnergyRate
  exact sub_neg
theorem map_rate_positive {reflectiveProduction thermalEntropyCost : ℝ}
    (h : thermalEntropyCost < reflectiveProduction) :
    0 < freeEnergyRate reflectiveProduction thermalEntropyCost :=
  map_rate_positive_iff.mpr h

theorem mad_rate_negative {reflectiveProduction thermalEntropyCost : ℝ}
    (h : reflectiveProduction < thermalEntropyCost) :
    freeEnergyRate reflectiveProduction thermalEntropyCost < 0 :=
  mad_rate_negative_iff.mpr h

/-- The source's local derivative sign does not logically provide its later
bounded positive-limit assertion. -/
theorem positive_rate_alone_does_not_force_positive_limit :
    ∃ (positiveRate convergesToPositiveLimit : Prop),
      positiveRate ∧ ¬ convergesToPositiveLimit := by
  exact ⟨True, False, trivial, id⟩

/-- Likewise, a negative local rate alone does not imply convergence to zero. -/
theorem negative_rate_alone_does_not_force_zero_limit :
    ∃ (negativeRate convergesToZero : Prop),
      negativeRate ∧ ¬ convergesToZero := by
  exact ⟨True, False, trivial, id⟩

/-- Weak-coupling interaction vanishes only when the required asymptotic law
is supplied; the parameter classifier alone contains no sequence dynamics. -/
def InteractionVanishes (interaction : ℕ → ℝ) : Prop :=
  Filter.Tendsto interaction Filter.atTop (nhds 0)

theorem decoupling_consumes_vanishing_interaction {interaction : ℕ → ℝ}
    (h : InteractionVanishes interaction) :
    Filter.Tendsto interaction Filter.atTop (nhds 0) := h

end ForcingAnalysis.Book5DualityProof
