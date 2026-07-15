/-
FracturedAtlas.lean — the pre-manifold: chart complexes with fracture
as first-class data (the manifold-track keystone; LPS-P45's named
next, unblocking the ~158 manifold-family anchors).

Design, per the repo's non-normalized rule taken to geometry:

  * The CARRIER is bare — no intrinsic metric, no topology
    (axiom:bk1_pre_geometric_nature, enacted in the type). Geometry is
    what charts impose.
  * A CHART is a local pseudometric on its domain (the geometry a
    coordinate map induces; `ofCoords` builds one from an actual
    coordinate map into ℝ^d). Which charts an observer holds is the
    content; nothing is completed to a maximal atlas.
  * The TRANSITION DEFECT between two charts is their pointwise metric
    disagreement on the shared overlap — measured directly, never
    through an inverted transition map (no inverses anywhere).
  * GLUEDNESS is a Prop, not a type requirement: all pairwise defects
    vanish. Classical manifolds live in the defect-zero case; appB's
    assumption:appB_chart_compatibility ("the symbolic charts form a
    compatible atlas") becomes a predicate this file CONSUMES, not an
    assumption it makes.

The kernel theorems:

  * the atlas has its own geometry (`defect_self`, `defect_symm`,
    `defect_triangle`): pointwise defect is a pseudometric ON CHARTS
    over shared overlaps — fracture is distance in chart-space;
  * `glued_of_consistent` / `consistent_of_glued` /
    `single_geometry_iff_glued` — THE theorem: a single geometry
    agreeing with every chart exists iff the atlas is glued (given
    pair-covering). "The" metric of the symbolic manifold is the
    quotient that gluedness licenses; its forgets-theorem is
    `fracture_obstructs` — one positive defect anywhere and no global
    geometry exists at all;
  * `fracture_persists` (the composer shape, atlas register): adding
    charts never heals a fracture — a sub-atlas fracture is a
    full-atlas fracture, so fractures found by any tested sub-inventory
    are final;
  * `dual_horizon_fractured` + `no_single_geometry_for_dual_horizon` —
    the wicked/AOC instance: the inner chart (identity coordinates)
    and the outer chart (resolution-quotient coordinates, AOC's
    q_ε = max(·, ε)) fracture at every sub-band pair, hence the dual
    horizon admits NO single reconciling geometry — the wicked thesis
    at atlas level, with the observer quotient as the fracturing
    chart: truncate (wicked), quotient (AOC), and the outer horizon
    (dual-horizon) unified as one family of kernel-bearing charts;
  * `glued_singleton` — any single-chart inventory is glued: fracture
    is intrinsically a MULTI-observer phenomenon; one chart alone can
    never witness it (which is why bounded observers mistake their
    chart for the world — no defect is visible from inside one chart).

What this unblocks: the manifold-family anchors get re-read against
chart complexes — "on the symbolic manifold (M, g)" becomes "on a
chart complex, with gluedness a NAMED hypothesis exactly where the
source's proof consumes it, and fracture-aware where the source's
content IS the failure." Nothing classical is lost (defect-zero
recovers the ordinary picture via `consistent_of_glued`); everything
observer-relative becomes stateable. Curvature-as-loop-defect
(discrete holonomy) and the appB resolution tower (P_λ as a graded
complex with defects vanishing up the grading — the emergent-smoothness
arc) are the named next layers, deliberately not forced into this
keystone file.
-/

import Mathlib

namespace ForcingAnalysis.Atlas

/-- A chart complex over a bare carrier: an inventory of charts, each
imposing a local pseudometric on its domain. The carrier itself has no
geometry — pre-geometric by construction. -/
structure ChartComplex (X : Type*) where
  ι : Type*
  dom : ι → Set X
  d : ι → X → X → ℝ
  d_nonneg : ∀ i x y, 0 ≤ d i x y
  d_self : ∀ i x, d i x x = 0
  d_symm : ∀ i x y, d i x y = d i y x
  d_triangle : ∀ i x y z, d i x z ≤ d i x y + d i y z

variable {X : Type*}

/-- Build a chart complex from actual coordinate maps into model
spaces: each chart's geometry is the pullback of the model distance. -/
noncomputable def ofCoords (ι : Type*) (dom : ι → Set X) (m : ι → ℕ)
    (coords : (i : ι) → X → EuclideanSpace ℝ (Fin (m i))) :
    ChartComplex X where
  ι := ι
  dom := dom
  d i x y := dist (coords i x) (coords i y)
  d_nonneg _ _ _ := dist_nonneg
  d_self _ _ := dist_self _
  d_symm _ _ _ := dist_comm _ _
  d_triangle _ _ _ _ := dist_triangle _ _ _

/-- The pointwise transition defect of two charts at a pair of points:
their metric disagreement, measured directly — no inverted transition
map anywhere. -/
def defect (C : ChartComplex X) (i j : C.ι) (x y : X) : ℝ :=
  |C.d i x y - C.d j x y|

/-- Defect vanishes on the diagonal of charts. -/
theorem defect_self (C : ChartComplex X) (i : C.ι) (x y : X) :
    defect C i i x y = 0 := by
  simp [defect]

/-- Defect is symmetric in the charts. -/
theorem defect_symm (C : ChartComplex X) (i j : C.ι) (x y : X) :
    defect C i j x y = defect C j i x y :=
  abs_sub_comm _ _

/-- **The atlas has its own geometry**: defect satisfies the triangle
inequality across a middle chart — charts form a pseudometric space
among themselves at every pair of points, and fracture is distance in
chart-space. -/
theorem defect_triangle (C : ChartComplex X) (i j k : C.ι) (x y : X) :
    defect C i k x y ≤ defect C i j x y + defect C j k x y :=
  abs_sub_le _ _ _

/-- Gluedness: every pair of charts agrees on its shared overlap. The
classical compatible-atlas condition (assumption:appB_chart_compatibility),
as a PREDICATE this theory consumes rather than an assumption the type
makes. -/
def Glued (C : ChartComplex X) : Prop :=
  ∀ i j : C.ι, ∀ x ∈ C.dom i ∩ C.dom j, ∀ y ∈ C.dom i ∩ C.dom j,
    C.d i x y = C.d j x y

/-- Gluedness of a sub-inventory: the observer holding charts S. -/
def GluedOn (C : ChartComplex X) (S : Set C.ι) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, ∀ x ∈ C.dom i ∩ C.dom j, ∀ y ∈ C.dom i ∩ C.dom j,
    C.d i x y = C.d j x y

/-- A single geometry consistent with every chart: THE metric of the
symbolic manifold, when it exists. -/
def Consistent (C : ChartComplex X) (D : X → X → ℝ) : Prop :=
  ∀ i : C.ι, ∀ x ∈ C.dom i, ∀ y ∈ C.dom i, D x y = C.d i x y

/-- Every pair of points shares some chart (the covering hypothesis
under which "the" geometry can even be assembled). -/
def PairCovers (C : ChartComplex X) : Prop :=
  ∀ x y : X, ∃ i : C.ι, x ∈ C.dom i ∧ y ∈ C.dom i

/-- A consistent global geometry forces gluedness. -/
theorem glued_of_consistent {C : ChartComplex X} {D : X → X → ℝ}
    (hD : Consistent C D) : Glued C := by
  intro i j x hx y hy
  rw [← hD i x hx.1 y hy.1, ← hD j x hx.2 y hy.2]

/-- **Fracture obstructs geometry** (the forgets-theorem of "the"
metric): one positive defect at one overlapping pair, and NO global
geometry consistent with the atlas exists at all. -/
theorem fracture_obstructs {C : ChartComplex X} {i j : C.ι} {x y : X}
    (hx : x ∈ C.dom i ∩ C.dom j) (hy : y ∈ C.dom i ∩ C.dom j)
    (hfrac : 0 < defect C i j x y) :
    ¬ ∃ D : X → X → ℝ, Consistent C D := by
  rintro ⟨D, hD⟩
  have h := glued_of_consistent hD i j x hx y hy
  rw [defect, h, sub_self, abs_zero] at hfrac
  exact lt_irrefl 0 hfrac

/-- **Gluedness assembles geometry**: a glued, pair-covering atlas
admits a single consistent global metric — the classical manifold
picture, recovered exactly at defect zero. -/
theorem consistent_of_glued {C : ChartComplex X} (hG : Glued C)
    (hCov : PairCovers C) : ∃ D : X → X → ℝ, Consistent C D := by
  refine ⟨fun x y => C.d (hCov x y).choose x y, ?_⟩
  intro i x hx y hy
  obtain ⟨hxc, hyc⟩ := (hCov x y).choose_spec
  exact hG _ i x ⟨hxc, hx⟩ y ⟨hyc, hy⟩

/-- **THE theorem: a single geometry exists iff the atlas is glued**
(given pair-covering). "The symbolic manifold (M, g)" is the quotient
that gluedness licenses; where the atlas fractures, there is no g to
speak of — only the charts and their defects. -/
theorem single_geometry_iff_glued {C : ChartComplex X}
    (hCov : PairCovers C) :
    (∃ D : X → X → ℝ, Consistent C D) ↔ Glued C :=
  ⟨fun ⟨_, hD⟩ => glued_of_consistent hD,
   fun hG => consistent_of_glued hG hCov⟩

/-- **Fracture persists** (the composer theorem, atlas register):
adding charts never heals a fracture — a defect witnessed inside any
sub-inventory is a defect of the whole atlas. Dually: gluedness of the
whole restricts to every sub-inventory. -/
theorem fracture_persists {C : ChartComplex X} {S T : Set C.ι}
    (hST : S ⊆ T) (hfrac : ¬ GluedOn C S) : ¬ GluedOn C T :=
  fun hT => hfrac fun i hi j hj x hx y hy =>
    hT i (hST hi) j (hST hj) x hx y hy

/-- A single-chart inventory is always glued: fracture is intrinsically
a MULTI-observer phenomenon — no defect is visible from inside one
chart, which is why a bounded observer mistakes its chart for the
world. -/
theorem glued_singleton (C : ChartComplex X) (i : C.ι) :
    GluedOn C {i} := by
  intro a ha b hb x hx y hy
  rcases ha with rfl
  rcases hb with rfl
  rfl

/-! ## The dual-horizon instance

The inner chart carries identity coordinates on the depth line; the
outer chart carries the resolution-quotient coordinates q_ε = max(·, ε)
(AOC's observer quotient; wicked geometry's truncation — one family of
kernel-bearing charts). Both are total. The fracture is where the
horizons disagree: every sub-band pair. -/

/-- The two-horizon complex over the depth line. -/
def dualHorizon (ε : ℝ) : ChartComplex ℝ where
  ι := Bool
  dom _ := Set.univ
  d b x y := if b then |x - y| else |max x ε - max y ε|
  d_nonneg b x y := by cases b <;> simp [abs_nonneg]
  d_self b x := by cases b <;> simp
  d_symm b x y := by cases b <;> simp [abs_sub_comm]
  d_triangle b x y z := by
    cases b
    · simpa using abs_sub_le (max x ε) (max y ε) (max z ε)
    · simpa using abs_sub_le x y z

/-- **The dual horizon fractures at every sub-band pair**: distinct
depths below the resolution floor are separated by the inner chart and
identified by the outer one — the defect is their full inner
separation. -/
theorem dual_horizon_fractured {ε x y : ℝ} (hx : x ≤ ε) (hy : y ≤ ε)
    (hxy : x ≠ y) :
    defect (dualHorizon ε) true false x y = |x - y| ∧
      0 < defect (dualHorizon ε) true false x y := by
  have houter : max x ε = max y ε := by
    rw [max_eq_right hx, max_eq_right hy]
  constructor
  · simp [defect, dualHorizon, houter]
  · have hpos : 0 < |x - y| := abs_pos.mpr (sub_ne_zero.mpr hxy)
    simpa [defect, dualHorizon, houter] using hpos

/-- **No single geometry reconciles the dual horizon** (the wicked
thesis, atlas level): for any positive resolution floor, the inner and
outer horizons admit no common consistent metric — g_in and g_out are
not two views of one geometry; below the floor there is no one
geometry to view. -/
theorem no_single_geometry_for_dual_horizon {ε : ℝ} (hε : 0 < ε) :
    ¬ ∃ D : ℝ → ℝ → ℝ, Consistent (dualHorizon ε) D := by
  refine fracture_obstructs (i := true) (j := false)
    (x := 0) (y := ε / 2) ⟨trivial, trivial⟩ ⟨trivial, trivial⟩ ?_
  exact (dual_horizon_fractured (by linarith) (by linarith) (by
    intro h
    have : ε / 2 = 0 := h.symm
    linarith)).2

end ForcingAnalysis.Atlas
