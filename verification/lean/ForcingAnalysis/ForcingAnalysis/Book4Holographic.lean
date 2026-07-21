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


/-! ### Variational observer-relative RT reconstruction -/

/-- A source-faithful RT reconstruction carries the admissible anchored fiber,
an area functional, and an actual minimizing selection. -/
structure RTVariationalReconstruction (BoundaryRegion BulkSurface : Type*) where
  admissible : BoundaryRegion → BulkSurface → Prop
  selectedSurface : BoundaryRegion → BulkSurface
  selected_admissible : ∀ region, admissible region (selectedSurface region)
  area : BulkSurface → ℝ
  area_nonneg : ∀ surface, 0 ≤ area surface
  selected_minimal : ∀ region surface,
    admissible region surface → area (selectedSurface region) ≤ area surface
  newtonConstant : ℝ
  newtonConstant_pos : 0 < newtonConstant

noncomputable def reconstructedEntropy {BoundaryRegion BulkSurface : Type*}
    (R : RTVariationalReconstruction BoundaryRegion BulkSurface)
    (region : BoundaryRegion) : ℝ :=
  rtEntropy R.newtonConstant (R.area (R.selectedSurface region))

theorem reconstructedEntropy_nonneg {BoundaryRegion BulkSurface : Type*}
    (R : RTVariationalReconstruction BoundaryRegion BulkSurface)
    (region : BoundaryRegion) :
    0 ≤ reconstructedEntropy R region := by
  apply rtEntropy_nonneg R.newtonConstant_pos
  exact R.area_nonneg _

theorem selectedSurface_minimizes_entropy
    {BoundaryRegion BulkSurface : Type*}
    (R : RTVariationalReconstruction BoundaryRegion BulkSurface)
    (region : BoundaryRegion) (surface : BulkSurface)
    (hs : R.admissible region surface) :
    reconstructedEntropy R region ≤
      rtEntropy R.newtonConstant (R.area surface) := by
  exact (rtEntropy_strictMono_area R.newtonConstant_pos).monotone
    (R.selected_minimal region surface hs)

/-- A uniqueness witness is additional to existence and minimality. -/
def UniqueMinimizer {BoundaryRegion BulkSurface : Type*}
    (R : RTVariationalReconstruction BoundaryRegion BulkSurface)
    (region : BoundaryRegion) : Prop :=
  ∀ surface, R.admissible region surface →
    R.area surface = R.area (R.selectedSurface region) →
    surface = R.selectedSurface region

theorem selectedSurface_unique_of_uniqueMinimizer
    {BoundaryRegion BulkSurface : Type*}
    (R : RTVariationalReconstruction BoundaryRegion BulkSurface)
    (region : BoundaryRegion) (hUnique : UniqueMinimizer R region)
    (surface : BulkSurface) (hs : R.admissible region surface)
    (hmin : R.area surface = R.area (R.selectedSurface region)) :
    surface = R.selectedSurface region :=
  hUnique surface hs hmin

/-- Minimal area need not select a unique bulk surface: two distinct admissible
surfaces can have equal minimal area. -/
theorem minimal_area_does_not_force_unique_surface :
    ∃ R : RTVariationalReconstruction Unit Bool,
      ¬ UniqueMinimizer R () := by
  let R : RTVariationalReconstruction Unit Bool :=
    { admissible := fun _ _ => True
      selectedSurface := fun _ => false
      selected_admissible := by simp
      area := fun _ => 1
      area_nonneg := by intro; norm_num
      selected_minimal := by intro; norm_num
      newtonConstant := 1
      newtonConstant_pos := by norm_num }
  refine ⟨R, ?_⟩
  intro h
  have := h true trivial (by rfl)
  simp [R] at this

end ForcingAnalysis.Book4Holographic
