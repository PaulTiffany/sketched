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

/-! ### An explicit covenant evolution law

The parameter classifier does not manufacture dynamics. The following
contractive law is therefore supplied as separate structure: `target` is the
regime's oriented free-energy level and `gain` transports the current error
toward it. This retains the intermediate orientation instead of flattening
MAP and MAD into unrelated sign assertions. -/

/-- A discrete covenant trajectory with target `target`, initial value
`initial`, and feedback gain `gain`. -/
def covenantTrajectory (target initial gain : ℝ) (n : ℕ) : ℝ :=
  target + gain ^ n * (initial - target)

/-- Contractive covenant feedback realizes its supplied target. -/
theorem covenantTrajectory_tendsto_target
    {target initial gain : ℝ} (hgain : |gain| < 1) :
    Filter.Tendsto (covenantTrajectory target initial gain)
      Filter.atTop (nhds target) := by
  have hpow : Filter.Tendsto (fun n : ℕ => gain ^ n)
      Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hgain
  change Filter.Tendsto
    (fun n : ℕ => target + gain ^ n * (initial - target))
    Filter.atTop (nhds target)
  simpa using Filter.Tendsto.const_add target
    (hpow.mul_const (initial - target))

/-- A positive MAP target is eventually realized as positive free energy. -/
theorem map_target_eventually_viable
    {target initial gain : ℝ} (htarget : 0 < target) (hgain : |gain| < 1) :
    ForcingAnalysis.Book5.EventuallyViable
      (covenantTrajectory target initial gain) := by
  have hlim := covenantTrajectory_tendsto_target
    (target := target) (initial := initial) hgain
  rw [Metric.tendsto_atTop] at hlim
  obtain ⟨N, hN⟩ := hlim (target / 2) (half_pos htarget)
  refine ⟨N, fun n hn => ?_⟩
  have hdist := hN n (Nat.le_of_lt hn)
  rw [Real.dist_eq] at hdist
  have hleft := (abs_lt.mp hdist).1
  have hlower : target - target / 2 <
      covenantTrajectory target initial gain n := by
    linarith
  linarith

/-- MAD is not a second unrelated dynamics: reversing target and initial
orientation reflects the entire covenant trajectory. -/
theorem covenantTrajectory_orientation_dual
    (target initial gain : ℝ) (n : ℕ) :
    covenantTrajectory (-target) (-initial) gain n =
      -covenantTrajectory target initial gain n := by
  simp [covenantTrajectory]
  ring

/-- A negative MAD target is eventually realized as negative free energy. -/
theorem mad_target_eventually_collapsed
    {target initial gain : ℝ} (htarget : target < 0) (hgain : |gain| < 1) :
    ForcingAnalysis.Book5.EventuallyCollapsed
      (covenantTrajectory target initial gain) := by
  have hpos : 0 < -target := neg_pos.mpr htarget
  obtain ⟨N, hN⟩ := map_target_eventually_viable
    (target := -target) (initial := -initial) hpos hgain
  refine ⟨N, fun n hn => ?_⟩
  have h := hN n hn
  rw [covenantTrajectory_orientation_dual target initial gain n] at h
  linarith

/-- Under the same contractive transport law, the interaction residue left
after `n` decoupling steps vanishes. -/
theorem geometric_decoupling_vanishes
    {initial gain : ℝ} (hgain : |gain| < 1) :
    InteractionVanishes (fun n => gain ^ n * initial) := by
  have hpow : Filter.Tendsto (fun n : ℕ => gain ^ n)
      Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hgain
  simpa [InteractionVanishes] using hpow.mul_const initial

/-- Contractivity is genuine machinery: unit gain preserves every nonzero
interaction residue forever. -/
theorem decoupling_without_contraction_can_persist :
    ¬ InteractionVanishes (fun _n : ℕ => (1 : ℝ)) := by
  intro hzero
  have hone : Filter.Tendsto (fun _n : ℕ => (1 : ℝ))
      Filter.atTop (nhds (1 : ℝ)) := tendsto_const_nhds
  exact one_ne_zero (tendsto_nhds_unique hone hzero)

/-! ### Bundled realization of the three classified regimes -/

/-- All premises needed to realize the enhanced MAP--MAD classification.
Parameter classification and temporal laws remain distinct fields so neither
can silently manufacture the other. -/
structure EnhancedDualityRealizationCertificate where
  mapCoupling : ℝ
  mapCritical : ℝ
  mapPolarity : ℝ
  mapStrong : mapCritical < mapCoupling
  mapPositive : 0 < mapPolarity
  mapReflectiveProduction : ℝ
  mapThermalEntropyCost : ℝ
  mapDominance : mapThermalEntropyCost < mapReflectiveProduction
  mapTarget : ℝ
  mapInitial : ℝ
  mapGain : ℝ
  mapTarget_pos : 0 < mapTarget
  mapGain_contracts : |mapGain| < 1
  madCoupling : ℝ
  madCritical : ℝ
  madPolarity : ℝ
  madStrong : madCritical < madCoupling
  madNegative : madPolarity < 0
  madReflectiveProduction : ℝ
  madThermalEntropyCost : ℝ
  madDominance : madReflectiveProduction < madThermalEntropyCost
  madInitial : ℝ
  madGain : ℝ
  madGain_contracts : |madGain| < 1
  decCoupling : ℝ
  decCritical : ℝ
  decPolarity : ℝ
  decWeak : decCoupling < decCritical
  decInitialResidue : ℝ
  decGain : ℝ
  decGain_contracts : |decGain| < 1

namespace EnhancedDualityRealizationCertificate

/-- The MAP parameters classify as MAP, have positive local free-energy rate,
and their separately supplied contractive law converges to a positive target
and becomes eventually viable. -/
theorem map_realization (C : EnhancedDualityRealizationCertificate) :
    Book5EnhancedDuality.classify C.mapCoupling C.mapCritical C.mapPolarity =
        .map ∧
      0 < freeEnergyRate C.mapReflectiveProduction C.mapThermalEntropyCost ∧
      Filter.Tendsto
        (covenantTrajectory C.mapTarget C.mapInitial C.mapGain)
        Filter.atTop (nhds C.mapTarget) ∧
      ForcingAnalysis.Book5.EventuallyViable
        (covenantTrajectory C.mapTarget C.mapInitial C.mapGain) := by
  exact ⟨Book5EnhancedDuality.classify_map C.mapStrong C.mapPositive,
    map_rate_positive C.mapDominance,
    covenantTrajectory_tendsto_target C.mapGain_contracts,
    map_target_eventually_viable C.mapTarget_pos C.mapGain_contracts⟩

/-- The MAD parameters classify as MAD, have negative local free-energy rate,
and their separately supplied zero-target contraction converges to zero. -/
theorem mad_realization (C : EnhancedDualityRealizationCertificate) :
    Book5EnhancedDuality.classify C.madCoupling C.madCritical C.madPolarity =
        .mad ∧
      freeEnergyRate C.madReflectiveProduction C.madThermalEntropyCost < 0 ∧
      Filter.Tendsto (fun n => C.madGain ^ n * C.madInitial)
        Filter.atTop (nhds 0) := by
  exact ⟨Book5EnhancedDuality.classify_mad C.madStrong C.madNegative,
    mad_rate_negative C.madDominance,
    geometric_decoupling_vanishes C.madGain_contracts⟩

/-- The weak-coupling parameters classify as decoupled and their separately
supplied residue contraction vanishes. -/
theorem decoupling_realization (C : EnhancedDualityRealizationCertificate) :
    Book5EnhancedDuality.classify C.decCoupling C.decCritical C.decPolarity =
        .decoupled ∧
      InteractionVanishes
        (fun n => C.decGain ^ n * C.decInitialResidue) := by
  exact ⟨Book5EnhancedDuality.classify_decoupled C.decWeak,
    geometric_decoupling_vanishes C.decGain_contracts⟩

/-- One certificate realizes all three clauses of the repaired enhanced
MAP--MAD theorem while retaining classification/dynamics separation. -/
theorem enhanced_map_mad_dynamical_realization
    (C : EnhancedDualityRealizationCertificate) :
    (Book5EnhancedDuality.classify C.mapCoupling C.mapCritical C.mapPolarity =
        .map ∧
      0 < freeEnergyRate C.mapReflectiveProduction C.mapThermalEntropyCost ∧
      Filter.Tendsto
        (covenantTrajectory C.mapTarget C.mapInitial C.mapGain)
        Filter.atTop (nhds C.mapTarget) ∧
      ForcingAnalysis.Book5.EventuallyViable
        (covenantTrajectory C.mapTarget C.mapInitial C.mapGain)) ∧
    (Book5EnhancedDuality.classify C.madCoupling C.madCritical C.madPolarity =
        .mad ∧
      freeEnergyRate C.madReflectiveProduction C.madThermalEntropyCost < 0 ∧
      Filter.Tendsto (fun n => C.madGain ^ n * C.madInitial)
        Filter.atTop (nhds 0)) ∧
    (Book5EnhancedDuality.classify C.decCoupling C.decCritical C.decPolarity =
        .decoupled ∧
      InteractionVanishes
        (fun n => C.decGain ^ n * C.decInitialResidue)) := by
  exact ⟨C.map_realization, C.mad_realization, C.decoupling_realization⟩

end EnhancedDualityRealizationCertificate
end ForcingAnalysis.Book5DualityProof
