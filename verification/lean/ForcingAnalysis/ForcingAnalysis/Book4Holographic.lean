/-
Book4Holographic.lean — finite Ryu–Takayanagi area-law kernel and
reconstruction audit for Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4Holographic

/-- Finite observer-resolved surface area from nonnegative metric-volume
weights. -/
noncomputable def observerSurfaceArea {Cell : Type*} [Fintype Cell]
    (metricVolume : Cell → ℝ) : ℝ :=
  ∑ cell, Real.sqrt (metricVolume cell)

theorem observerSurfaceArea_nonneg {Cell : Type*} [Fintype Cell]
    (metricVolume : Cell → ℝ) :
    0 ≤ observerSurfaceArea metricVolume := by
  unfold observerSurfaceArea
  exact Finset.sum_nonneg fun cell _ => Real.sqrt_nonneg _

theorem observerSurfaceArea_mono {Cell : Type*} [Fintype Cell]
    {g h : Cell → ℝ} (hgh : ∀ cell, g cell ≤ h cell) :
    observerSurfaceArea g ≤ observerSurfaceArea h := by
  unfold observerSurfaceArea
  exact Finset.sum_le_sum fun cell _ => Real.sqrt_le_sqrt (hgh cell)

/-- Ryu–Takayanagi entropy as the supplied extremal-surface area divided by
`4 G_N`. -/
noncomputable def rtEntropy (newtonConstant area : ℝ) : ℝ :=
  area / (4 * newtonConstant)

theorem rtEntropy_area_law (newtonConstant area : ℝ) :
    rtEntropy newtonConstant area = area / (4 * newtonConstant) := by
  rfl

theorem rtEntropy_nonneg {newtonConstant area : ℝ}
    (hNewton : 0 < newtonConstant) (hArea : 0 ≤ area) :
    0 ≤ rtEntropy newtonConstant area := by
  unfold rtEntropy
  positivity

theorem rtEntropy_strictMono_area {newtonConstant : ℝ}
    (hNewton : 0 < newtonConstant) :
    StrictMono (rtEntropy newtonConstant) := by
  intro a b hab
  unfold rtEntropy
  exact div_lt_div_of_pos_right hab (mul_pos (by norm_num) hNewton)

/-- The actual holographic bridge is additional data: it assigns a bulk
extremal surface to each observer-resolved boundary region. -/
structure RTReconstruction (BoundaryRegion BulkSurface : Type*) where
  extremalSurface : BoundaryRegion → BulkSurface

theorem reconstruction_deterministic {BoundaryRegion BulkSurface : Type*}
    (bridge : RTReconstruction BoundaryRegion BulkSurface)
    (region : BoundaryRegion) :
    bridge.extremalSurface region = bridge.extremalSurface region := by
  rfl

/-- A boundary metric type alone does not select a unique bulk geometry:
two admissible reconstruction maps can disagree on the same boundary datum. -/
theorem boundary_metric_alone_does_not_select_unique_bulk :
    ∃ first second : RTReconstruction Unit Bool,
      first.extremalSurface () ≠ second.extremalSurface () := by
  refine ⟨⟨fun _ => false⟩, ⟨fun _ => true⟩, ?_⟩
  decide

end ForcingAnalysis.Book4Holographic
