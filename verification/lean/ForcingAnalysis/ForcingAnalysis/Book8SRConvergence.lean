/- Book8SRConvergence.lean — Lyapunov control of distance to an SR invariant set. -/
import Mathlib

namespace ForcingAnalysis.Book8SRConvergence

variable {X : Type*}

/-- A discrete SRMF convergence certificate.  The energy-to-distance estimate is
the coercive/LaSalle bridge needed to turn free-energy decay into approach to the
invariant manifold. -/
structure SRConvergenceData (X : Type*) where
  step : X → X
  orbit : ℕ → X
  follows : ∀ n, orbit (n + 1) = step (orbit n)
  invariant : Set X
  invariant_nonempty : invariant.Nonempty
  invariant_step : ∀ x ∈ invariant, step x ∈ invariant
  freeEnergyGap : X → ℝ
  distanceToInvariant : X → ℝ
  gap_nonneg : ∀ x, 0 ≤ freeEnergyGap x
  distance_nonneg : ∀ x, 0 ≤ distanceToInvariant x
  freeEnergy_descent : ∀ x, freeEnergyGap (step x) ≤ freeEnergyGap x
  controlScale : ℝ
  controlScale_nonneg : 0 ≤ controlScale
  distance_le_gap : ∀ x,
    distanceToInvariant x ≤ controlScale * freeEnergyGap x
  gap_tendsto_zero : Filter.Tendsto (fun n => freeEnergyGap (orbit n))
    Filter.atTop (nhds 0)

theorem orbit_freeEnergy_nonincreasing (D : SRConvergenceData X) (n : ℕ) :
    D.freeEnergyGap (D.orbit (n + 1)) ≤ D.freeEnergyGap (D.orbit n) := by
  rw [D.follows n]
  exact D.freeEnergy_descent _

theorem invariant_freeEnergy_nonincreasing
    (D : SRConvergenceData X) {x : X} (hx : x ∈ D.invariant) :
    D.step x ∈ D.invariant ∧
      D.freeEnergyGap (D.step x) ≤ D.freeEnergyGap x :=
  ⟨D.invariant_step x hx, D.freeEnergy_descent x⟩

/-- SR convergence: coercive Lyapunov decay squeezes the orbit's distance to the
invariant manifold to zero. -/
theorem distanceToInvariant_tendsto_zero (D : SRConvergenceData X) :
    Filter.Tendsto (fun n => D.distanceToInvariant (D.orbit n))
      Filter.atTop (nhds 0) := by
  have hupper : Filter.Tendsto
      (fun n => D.controlScale * D.freeEnergyGap (D.orbit n))
      Filter.atTop (nhds 0) := by
    have hscale : Filter.Tendsto (fun _ : ℕ => D.controlScale)
        Filter.atTop (nhds D.controlScale) := tendsto_const_nhds
    simpa using hscale.mul D.gap_tendsto_zero
  exact squeeze_zero
    (fun n => D.distance_nonneg (D.orbit n))
    (fun n => D.distance_le_gap (D.orbit n)) hupper

/-- Negative control for the prose-level LaSalle invocation: bounded-below,
nonincreasing energy can remain constant while distance from the proposed
invariant set remains one forever. -/
theorem lyapunov_descent_alone_does_not_force_invariant_approach :
    ∃ energy distance : ℕ → ℝ,
      (∀ n, 0 ≤ energy n) ∧
      (∀ n, energy (n + 1) ≤ energy n) ∧
      (∀ n, distance n = 1) ∧
      ¬ Filter.Tendsto distance Filter.atTop (nhds 0) := by
  refine ⟨fun _ => 0, fun _ => 1, by simp, by simp, by simp, ?_⟩
  intro h
  have hone : Filter.Tendsto (fun _ : ℕ => (1 : ℝ))
      Filter.atTop (nhds 1) := tendsto_const_nhds
  have : (1 : ℝ) = 0 := tendsto_nhds_unique hone h
  norm_num at this

end ForcingAnalysis.Book8SRConvergence
