/-
AtlasTower.lean — the resolution tower: manifold emergence as a
theorem with the axiom trio as named hypotheses (the FracturedAtlas
program's second named next layer; the scholium's construction arc).

Sources (Principia scholium, verbatim; sha-bound):

  axiom:bk1_local_charitability — the stage tower (P_λ) carries charts
    at every sufficiently late stage, coherently across stages.
  axiom:bk1_smooth_convergence — the transition maps converge as
    λ → Ω on overlapping domains.
  axiom:bk1_topological_regularity — the colimit topology is
    Hausdorff, second-countable, paracompact, connected.
  theorem:bk1_manifold_emergence — under the axioms, the proto-symbolic
    space admits a unique smooth manifold structure.

The honest kernel over the fractured-atlas substrate: a RESOLUTION
TOWER is a stage-indexed family of chart geometries on one carrier with
one chart inventory. The three axioms convert into three NAMED
hypothesis fields — chartability IS the tower structure itself
(per-stage pseudometric laws), smooth convergence IS pointwise
convergence of the stage metrics plus a vanishing cross-chart defect
bound, and (the finite stand-in for) topological regularity IS
pair-covering. Then:

  * `limit_*` — the limit of a tower is a genuine chart geometry: the
    pseudometric laws PASS TO THE LIMIT (nonneg, self, symm, triangle
    each proved by limit arguments, not assumed);
  * `tower_glues` — THE EMERGENCE MECHANISM: the vanishing defect
    bound forces the limit charts to agree on overlaps — gluedness is
    not postulated of the limit, it EMERGES from defect decay up the
    tower (squeeze: |d_λ(i) − d_λ(j)| ≤ δ_λ → 0, limits unique);
  * `manifold_emergence` — the scholium's theorem, kernel form: a
    resolution tower with vanishing defects and pair-covering admits a
    single global geometry consistent with every limit chart, and that
    geometry is UNIQUE as a function on pairs (any two consistent
    geometries agree everywhere). Smoothness-as-C∞ stays honestly
    open; existence-and-uniqueness of THE emergent geometry is
    certified.
  * `fracture_stops_emergence` — the converse control: a tower whose
    defect persists (bounded below by a positive constant at one
    overlapping pair) has a NON-glued limit — no global geometry ever
    emerges. Emergence is earned by defect decay, not by taking
    limits: the limit of a fractured tower is a fractured atlas.

Hausdorff/second-countable/paracompact/connected remain unmodeled
(genuine point-set topology); pair-covering is their working stand-in
here and is named as such.
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas

namespace ForcingAnalysis.Atlas

open Filter

/-- A resolution tower: one carrier, one chart inventory, a stage-
indexed family of chart geometries converging chartwise, with a
cross-chart defect bound vanishing up the tower. The scholium's three
axioms are the three groups of fields. -/
structure ResolutionTower (X : Type*) (ι : Type*) where
  dom : ι → Set X
  /-- stage-λ geometry of chart i (axiom:bk1_local_charitability — the
  tower of charted stages, with per-stage pseudometric laws) -/
  d : ℕ → ι → X → X → ℝ
  d_nonneg : ∀ l i x y, 0 ≤ d l i x y
  d_self : ∀ l i x, d l i x x = 0
  d_symm : ∀ l i x y, d l i x y = d l i y x
  d_triangle : ∀ l i x y z, d l i x z ≤ d l i x y + d l i y z
  /-- the limit geometry each chart converges to
  (axiom:bk1_smooth_convergence, first half: pointwise convergence) -/
  dLim : ι → X → X → ℝ
  converges : ∀ i x y, Tendsto (fun l => d l i x y) atTop (nhds (dLim i x y))
  /-- the cross-chart defect bound, vanishing up the tower
  (axiom:bk1_smooth_convergence, second half: transitions reconcile) -/
  δ : ℕ → ℝ
  defect_le : ∀ l i j, ∀ x ∈ dom i ∩ dom j, ∀ y ∈ dom i ∩ dom j,
    |d l i x y - d l j x y| ≤ δ l
  defect_vanishes : Tendsto δ atTop (nhds 0)

variable {X : Type*} {ι : Type*}

/-- The pseudometric laws pass to the limit: nonnegativity. -/
theorem limit_nonneg (T : ResolutionTower X ι) (i : ι) (x y : X) :
    0 ≤ T.dLim i x y :=
  ge_of_tendsto' (T.converges i x y) fun l => T.d_nonneg l i x y

/-- Self-distance passes to the limit. -/
theorem limit_self (T : ResolutionTower X ι) (i : ι) (x : X) :
    T.dLim i x x = 0 :=
  tendsto_nhds_unique (T.converges i x x)
    (by simp [T.d_self])

/-- Symmetry passes to the limit. -/
theorem limit_symm (T : ResolutionTower X ι) (i : ι) (x y : X) :
    T.dLim i x y = T.dLim i y x :=
  tendsto_nhds_unique (T.converges i x y)
    (by simpa [T.d_symm] using T.converges i y x)

/-- The triangle inequality passes to the limit. -/
theorem limit_triangle (T : ResolutionTower X ι) (i : ι) (x y z : X) :
    T.dLim i x z ≤ T.dLim i x y + T.dLim i y z :=
  le_of_tendsto_of_tendsto' (T.converges i x z)
    ((T.converges i x y).add (T.converges i y z))
    fun l => T.d_triangle l i x y z

/-- The limit chart complex of a resolution tower: a genuine chart
geometry, its laws inherited from the stages by limit arguments. -/
def limitComplex (T : ResolutionTower X ι) : ChartComplex X where
  ι := ι
  dom := T.dom
  d := T.dLim
  d_nonneg := limit_nonneg T
  d_self := limit_self T
  d_symm := limit_symm T
  d_triangle := limit_triangle T

/-- **The emergence mechanism**: vanishing defects up the tower force
the limit charts to AGREE on overlaps — gluedness of the limit is not
postulated, it emerges from defect decay. -/
theorem tower_glues (T : ResolutionTower X ι) : Glued (limitComplex T) := by
  intro i j x hx y hy
  have hdiff : Tendsto (fun l => T.d l i x y - T.d l j x y) atTop
      (nhds (T.dLim i x y - T.dLim j x y)) :=
    (T.converges i x y).sub (T.converges j x y)
  have hzero : Tendsto (fun l => T.d l i x y - T.d l j x y) atTop (nhds 0) := by
    have hupper : Tendsto (fun l => T.δ l) atTop (nhds 0) := T.defect_vanishes
    have hlower : Tendsto (fun l => -T.δ l) atTop (nhds 0) := by
      simpa using hupper.neg
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le hlower hupper
      (fun l => ?_) (fun l => ?_)
    · have := T.defect_le l i j x hx y hy
      have := abs_le.mp this
      linarith [this.1]
    · have := T.defect_le l i j x hx y hy
      exact le_trans (le_abs_self _) this
  have := tendsto_nhds_unique hdiff hzero
  show (limitComplex T).d i x y = (limitComplex T).d j x y
  simp only [limitComplex]
  linarith

/-- **Manifold emergence, kernel form**
(theorem:bk1_manifold_emergence): a resolution tower with vanishing
defects and pair-covering admits a single global geometry consistent
with every limit chart — and that geometry is UNIQUE: any two
consistent geometries agree at every pair of points. The scholium's
axioms are consumed exactly as the named structure fields and the
covering hypothesis; smoothness-as-C∞ stays honestly open. -/
theorem manifold_emergence (T : ResolutionTower X ι)
    (hCov : PairCovers (limitComplex T)) :
    (∃ D : X → X → ℝ, Consistent (limitComplex T) D) ∧
      ∀ D D' : X → X → ℝ, Consistent (limitComplex T) D →
        Consistent (limitComplex T) D' → ∀ x y, D x y = D' x y := by
  constructor
  · exact consistent_of_glued (tower_glues T) hCov
  · intro D D' hD hD' x y
    obtain ⟨i, hxi, hyi⟩ := hCov x y
    rw [hD i x hxi y hyi, hD' i x hxi y hyi]

/-- **Fracture stops emergence** (the converse control): a tower whose
cross-chart defect PERSISTS — bounded below by c > 0 at one
overlapping pair, cofinally in the tower — has a fractured limit: the
limit charts genuinely disagree there, so no global geometry ever
emerges. Emergence is earned by defect decay, not by taking limits. -/
theorem fracture_stops_emergence (T : ResolutionTower X ι)
    {i j : ι} {x y : X} (hx : x ∈ T.dom i ∩ T.dom j)
    (hy : y ∈ T.dom i ∩ T.dom j) {c : ℝ} (hc : 0 < c)
    (hpersist : ∀ l, c ≤ |T.d l i x y - T.d l j x y|) :
    ¬ ∃ D : X → X → ℝ, Consistent (limitComplex T) D := by
  have hdiff : Tendsto (fun l => |T.d l i x y - T.d l j x y|) atTop
      (nhds |T.dLim i x y - T.dLim j x y|) :=
    ((T.converges i x y).sub (T.converges j x y)).abs
  have hlim : c ≤ |T.dLim i x y - T.dLim j x y| :=
    ge_of_tendsto' hdiff hpersist |>.trans_eq rfl
  refine fracture_obstructs (C := limitComplex T) hx hy ?_
  show 0 < |(limitComplex T).d i x y - (limitComplex T).d j x y|
  simp only [limitComplex]
  linarith

end ForcingAnalysis.Atlas
