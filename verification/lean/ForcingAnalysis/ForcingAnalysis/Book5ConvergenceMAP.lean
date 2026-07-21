/- Book5ConvergenceMAP.lean — explicit population-share convergence kernel. -/
import Mathlib

namespace ForcingAnalysis.Book5ConvergenceMAP

/-- A two-strategy replicator contraction: each step retains a fraction `q`
of the remaining non-MAP population. -/
noncomputable def mapShare (q initial : ℝ) (n : ℕ) : ℝ :=
  1 - q ^ n * (1 - initial)

theorem mapShare_zero (q initial : ℝ) : mapShare q initial 0 = initial := by
  simp [mapShare]

theorem mapShare_succ (q initial : ℝ) (n : ℕ) :
    1 - mapShare q initial (n + 1) =
      q * (1 - mapShare q initial n) := by
  simp [mapShare, pow_succ]
  ring

theorem mapShare_tendsto_one {q initial : ℝ}
    (hq0 : 0 ≤ q) (hq1 : q < 1) :
    Filter.Tendsto (mapShare q initial) Filter.atTop (nhds 1) := by
  have hqabs : |q| < 1 := by simpa [abs_of_nonneg hq0] using hq1
  have hpow : Filter.Tendsto (fun n : ℕ => q ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hqabs
  have hscaled := hpow.mul_const (1 - initial)
  change Filter.Tendsto (fun n : ℕ => 1 - q ^ n * (1 - initial))
    Filter.atTop (nhds 1)
  convert tendsto_const_nhds.sub hscaled using 1
  norm_num

/-- Increasing drift, without a persistent fitness/contraction bridge, can
coexist with a population share permanently stuck at one half. -/
theorem increasing_drift_alone_does_not_force_map_convergence :
    let drift : ℕ → ℝ := fun n => n
    let share : ℕ → ℝ := fun _ => 1 / 2
    StrictMono drift ∧ ¬ Filter.Tendsto share Filter.atTop (nhds 1) := by
  dsimp
  constructor
  · intro a b hab
    change (a : ℝ) < (b : ℝ)
    exact_mod_cast hab
  · intro h
    have hEq : (1 / 2 : ℝ) = 1 :=
      tendsto_nhds_unique tendsto_const_nhds h
    norm_num at hEq


/-! ## Fitness-to-population reconstruction -/

/-- A persistent quantitative selection advantage. Positivity makes the
non-MAP/MAP retention ratio meaningful; strict advantage makes it contractive. -/
structure PersistentMAPAdvantage where
  mapFitness : ℝ
  nonMAPFitness : ℝ
  mapFitness_pos : 0 < mapFitness
  nonMAPFitness_nonneg : 0 ≤ nonMAPFitness
  strict_gap : nonMAPFitness < mapFitness

namespace PersistentMAPAdvantage

/-- Residual non-MAP mass retained by one mutation-free selection step. -/
noncomputable def contraction (A : PersistentMAPAdvantage) : ℝ :=
  A.nonMAPFitness / A.mapFitness

theorem contraction_nonneg (A : PersistentMAPAdvantage) :
    0 ≤ A.contraction := by
  exact div_nonneg A.nonMAPFitness_nonneg (le_of_lt A.mapFitness_pos)

theorem contraction_lt_one (A : PersistentMAPAdvantage) :
    A.contraction < 1 := by
  exact (div_lt_one A.mapFitness_pos).2 A.strict_gap

end PersistentMAPAdvantage

/-- A mutation-free aggregate population orbit. The exact residual recurrence
excludes hidden non-MAP inflow; the initial bounds place the orbit on the
probability simplex. -/
structure MAPPopulationOrbit (A : PersistentMAPAdvantage) where
  share : ℕ → ℝ
  initial_nonneg : 0 ≤ share 0
  initial_le_one : share 0 ≤ 1
  residual_step : ∀ n,
    1 - share (n + 1) = A.contraction * (1 - share n)

namespace MAPPopulationOrbit

/-- The orbit law determines every residual from its initial value. -/
theorem residual_eq_pow {A : PersistentMAPAdvantage}
    (P : MAPPopulationOrbit A) (n : ℕ) :
    1 - P.share n = A.contraction ^ n * (1 - P.share 0) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [P.residual_step n, ih, pow_succ]
      ring

/-- Mutation-free quantitative selection preserves the upper simplex face. -/
theorem share_le_one {A : PersistentMAPAdvantage}
    (P : MAPPopulationOrbit A) (n : ℕ) : P.share n ≤ 1 := by
  have hres : 0 ≤ 1 - P.share n := by
    rw [P.residual_eq_pow n]
    exact mul_nonneg (pow_nonneg A.contraction_nonneg n)
      (sub_nonneg.mpr P.initial_le_one)
  linarith

/-- It also preserves nonnegativity, so the orbit remains a probability share. -/
theorem share_nonneg {A : PersistentMAPAdvantage}
    (P : MAPPopulationOrbit A) (n : ℕ) : 0 ≤ P.share n := by
  rw [show P.share n = 1 - A.contraction ^ n * (1 - P.share 0) by
    linarith [P.residual_eq_pow n]]
  have hqle : A.contraction ≤ 1 := le_of_lt A.contraction_lt_one
  have hpowle : A.contraction ^ n ≤ 1 := pow_le_one₀ A.contraction_nonneg hqle
  have hresle : 1 - P.share 0 ≤ 1 := by linarith [P.initial_nonneg]
  have hmul : A.contraction ^ n * (1 - P.share 0) ≤ 1 := by
    calc
      A.contraction ^ n * (1 - P.share 0) ≤ 1 * 1 :=
        mul_le_mul hpowle hresle
          (sub_nonneg.mpr P.initial_le_one) (by norm_num)
      _ = 1 := by norm_num
  linarith

/-- The exact population orbit is the geometric contraction already analyzed by
the scalar kernel; this theorem supplies the bridge rather than identifying the
two by prose. -/
theorem share_eq_mapShare {A : PersistentMAPAdvantage}
    (P : MAPPopulationOrbit A) (n : ℕ) :
    P.share n = mapShare A.contraction (P.share 0) n := by
  unfold mapShare
  linarith [P.residual_eq_pow n]

/-- Persistent quantitative advantage plus a simplex-preserving, mutation-free
orbit forces convergence of MAP population mass to one. -/
theorem share_tendsto_one {A : PersistentMAPAdvantage}
    (P : MAPPopulationOrbit A) :
    Filter.Tendsto P.share Filter.atTop (nhds 1) := by
  have hmodel := mapShare_tendsto_one A.contraction_nonneg A.contraction_lt_one
    (initial := P.share 0)
  exact hmodel.congr' (Filter.Eventually.of_forall fun n => (P.share_eq_mapShare n).symm)

/-- A persistent advantage without exclusion of inflow does not force
convergence: replenishing non-MAP mass can hold the MAP share fixed. -/
theorem fitness_gap_with_inflow_does_not_force_convergence :
    let A : PersistentMAPAdvantage :=
      { mapFitness := 2, nonMAPFitness := 1
        mapFitness_pos := by norm_num
        nonMAPFitness_nonneg := by norm_num
        strict_gap := by norm_num }
    let share : ℕ → ℝ := fun _ => 1 / 2
    A.nonMAPFitness < A.mapFitness ∧
      (∀ n, 0 ≤ share n ∧ share n ≤ 1) ∧
      ¬ Filter.Tendsto share Filter.atTop (nhds 1) := by
  dsimp
  constructor
  · norm_num
  constructor
  · intro n
    norm_num
  · intro h
    have hEq : (1 / 2 : ℝ) = 1 :=
      tendsto_nhds_unique tendsto_const_nhds h
    norm_num at hEq

end MAPPopulationOrbit
end ForcingAnalysis.Book5ConvergenceMAP
