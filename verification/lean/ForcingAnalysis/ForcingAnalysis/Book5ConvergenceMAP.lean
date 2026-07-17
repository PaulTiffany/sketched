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

end ForcingAnalysis.Book5ConvergenceMAP
