import Mathlib
import ForcingAnalysis.Book4Gauge

/-!
# Book 4: a typed Fuzzy Stokes kernel

This module retains the form-degree boundary that the earlier scalar
`observerValue = classicalValue + correction` proxy erased.

It does not re-prove the classical Stokes theorem for smooth manifolds.
Instead, `FuzzyStokesCertificate` records the exact bridge that an intended
geometric instantiation must supply: a boundary functional on one-forms, an
interior functional on two-forms, a typed exterior derivative, classical
Stokes for the covariant one-form, and the curvature-plus-interaction
decomposition of its exterior derivative.
-/

namespace ForcingAnalysis.Book4FuzzyStokes

structure FuzzyStokesCertificate
    (OneForm TwoForm Value : Type*)
    [AddCommGroup TwoForm] [AddCommGroup Value] where
  boundaryIntegral : OneForm → Value
  interiorIntegral : TwoForm → Value
  exteriorDerivative : OneForm → TwoForm
  covariantForm : OneForm
  curvatureForm : TwoForm
  interactionForm : TwoForm
  integrates_curvature_interaction :
    interiorIntegral (curvatureForm + interactionForm) =
      interiorIntegral curvatureForm + interiorIntegral interactionForm
  classicalStokes :
    boundaryIntegral covariantForm =
      interiorIntegral (exteriorDerivative covariantForm)
  curvatureInteractionDecomposition :
    exteriorDerivative covariantForm = curvatureForm + interactionForm

namespace FuzzyStokesCertificate

variable {OneForm TwoForm Value : Type*}
  [AddCommGroup TwoForm] [AddCommGroup Value]
  (C : FuzzyStokesCertificate OneForm TwoForm Value)

/-- **Fuzzy Stokes.** Given classical Stokes and the typed
curvature/interaction decomposition, boundary circulation is the curvature
surface term plus the integrated observer interaction. -/
theorem fuzzy_stokes :
    C.boundaryIntegral C.covariantForm =
      C.interiorIntegral C.curvatureForm +
        C.interiorIntegral C.interactionForm := by
  rw [C.classicalStokes, C.curvatureInteractionDecomposition,
    C.integrates_curvature_interaction]

/-- Zero integrated interaction residue recovers the curvature term. -/
theorem classical_recovery
    (hresidue : C.interiorIntegral C.interactionForm = 0) :
    C.boundaryIntegral C.covariantForm =
      C.interiorIntegral C.curvatureForm := by
  rw [C.fuzzy_stokes, hresidue, add_zero]

/-- Classical recovery forces the integrated residue to vanish, but does not
by itself force the interaction form to vanish pointwise. -/
theorem integrated_residue_zero_of_classical_recovery
    (hrecovery :
      C.boundaryIntegral C.covariantForm =
        C.interiorIntegral C.curvatureForm) :
    C.interiorIntegral C.interactionForm = 0 := by
  have h := C.fuzzy_stokes
  rw [hrecovery] at h
  have h' :
      C.interiorIntegral C.curvatureForm +
          C.interiorIntegral C.interactionForm =
        C.interiorIntegral C.curvatureForm + 0 := by
    rw [← h, add_zero]
  exact add_left_cancel h'

/-- Form-level recovery needs a no-cancellation bridge, represented here by
injectivity of the interior functional. -/
theorem interactionForm_eq_zero_of_classical_recovery
    (hzero : C.interiorIntegral 0 = 0)
    (hinjective : Function.Injective C.interiorIntegral)
    (hrecovery :
      C.boundaryIntegral C.covariantForm =
        C.interiorIntegral C.curvatureForm) :
    C.interactionForm = 0 := by
  apply hinjective
  rw [hzero]
  exact C.integrated_residue_zero_of_classical_recovery hrecovery

end FuzzyStokesCertificate

/-- A two-cell interaction form witnessing oriented cancellation. -/
def cancellingInteraction : Fin 2 → ℤ
  | 0 => 1
  | 1 => -1

theorem cancellingInteraction_ne_zero : cancellingInteraction ≠ 0 := by
  intro h
  have h0 := congrFun h 0
  norm_num [cancellingInteraction] at h0

theorem cancellingInteraction_integral_eq_zero :
    cancellingInteraction 0 + cancellingInteraction 1 = 0 := by
  norm_num [cancellingInteraction]

/-- Zero integrated residue does not imply zero interaction form without a
no-cancellation premise. -/
theorem integrated_zero_does_not_force_form_zero :
    ∃ interaction : Fin 2 → ℤ,
      interaction ≠ 0 ∧ interaction 0 + interaction 1 = 0 :=
  ⟨cancellingInteraction, cancellingInteraction_ne_zero,
    cancellingInteraction_integral_eq_zero⟩

/-- Discrete exterior derivative along an oriented finite strip. Each cell
records the difference between its outgoing and incoming boundary value. -/
def stripExteriorDerivative {Value : Type*} [AddCommGroup Value]
    (edgePotential : ℕ → Value) (cell : ℕ) : Value :=
  edgePotential (cell + 1) - edgePotential cell

/-- A genuine finite Stokes mechanism: all internal oriented boundaries
cancel, leaving only the terminal minus initial boundary. -/
theorem sum_stripExteriorDerivative {Value : Type*} [AddCommGroup Value]
    (edgePotential : ℕ → Value) (n : ℕ) :
    ∑ cell ∈ Finset.range n, stripExteriorDerivative edgePotential cell =
      edgePotential n - edgePotential 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      simp only [stripExteriorDerivative]
      abel

/-- Discrete Fuzzy Stokes on a finite oriented strip. Unlike the general
certificate theorem, this result proves its Stokes transport by telescoping;
its only geometric input is the cellwise curvature/inter\-action
decomposition. -/
theorem discrete_fuzzy_stokes
    {Value : Type*} [AddCommGroup Value]
    (edgePotential curvature interaction : ℕ → Value) (n : ℕ)
    (hdecompose : ∀ cell < n,
      stripExteriorDerivative edgePotential cell =
        curvature cell + interaction cell) :
    edgePotential n - edgePotential 0 =
      (∑ cell ∈ Finset.range n, curvature cell) +
        ∑ cell ∈ Finset.range n, interaction cell := by
  rw [← sum_stripExteriorDerivative edgePotential n]
  calc
    (∑ cell ∈ Finset.range n, stripExteriorDerivative edgePotential cell) =
        ∑ cell ∈ Finset.range n, (curvature cell + interaction cell) := by
          apply Finset.sum_congr rfl
          intro cell hcell
          exact hdecompose cell (Finset.mem_range.mp hcell)
    _ = (∑ cell ∈ Finset.range n, curvature cell) +
          ∑ cell ∈ Finset.range n, interaction cell := by
          rw [Finset.sum_add_distrib]

/-- The discrete theorem recovers the curvature-only boundary law when the
oriented interaction sum vanishes, without pretending every cellwise
interaction vanishes. -/
theorem discrete_classical_recovery
    {Value : Type*} [AddCommGroup Value]
    (edgePotential curvature interaction : ℕ → Value) (n : ℕ)
    (hdecompose : ∀ cell < n,
      stripExteriorDerivative edgePotential cell =
        curvature cell + interaction cell)
    (hresidue : ∑ cell ∈ Finset.range n, interaction cell = 0) :
    edgePotential n - edgePotential 0 =
      ∑ cell ∈ Finset.range n, curvature cell := by
  rw [discrete_fuzzy_stokes edgePotential curvature interaction n hdecompose,
    hresidue, add_zero]
/-! ## Analytic rectangular-chart realization -/

open Set MeasureTheory intervalIntegral

noncomputable section

abbrev Plane := ℝ × ℝ

/-- The counterclockwise boundary circulation of the one-form
`P dx + Q dy` around the rectangle from `a` to `b`. -/
def rectangleBoundaryCirculation
    (P Q : Plane → ℝ) (a b : Plane) : ℝ :=
  (((∫ x in a.1..b.1, -P (x, b.2)) -
      ∫ x in a.1..b.1, -P (x, a.2)) +
      ∫ y in a.2..b.2, Q (b.1, y)) -
    ∫ y in a.2..b.2, Q (a.1, y)

/-- Analytic data for a Fuzzy Stokes law on one oriented rectangular chart.
`P dx + Q dy` is the covariant one-form; `Q'_x - P'_y` is its exterior
derivative density; and that density is explicitly decomposed into curvature
and observer-interaction terms. -/
structure RectangleFuzzyStokesData (a b : Plane) where
  lower_le_upper : a ≤ b
  pCoeff : Plane → ℝ
  qCoeff : Plane → ℝ
  pDeriv : Plane → Plane →L[ℝ] ℝ
  qDeriv : Plane → Plane →L[ℝ] ℝ
  p_continuous : ContinuousOn pCoeff (Set.Icc a b)
  q_continuous : ContinuousOn qCoeff (Set.Icc a b)
  p_hasFDerivAt : ∀ (x : Plane), x ∈ (Set.Ioo a.1 b.1 ×ˢ Set.Ioo a.2 b.2) →
    HasFDerivAt pCoeff (pDeriv x) x
  q_hasFDerivAt : ∀ (x : Plane), x ∈ (Set.Ioo a.1 b.1 ×ˢ Set.Ioo a.2 b.2) →
    HasFDerivAt qCoeff (qDeriv x) x
  curvatureDensity : Plane → ℝ
  interactionDensity : Plane → ℝ
  curvature_integrable : IntegrableOn curvatureDensity (Set.Icc a b)
  interaction_integrable : IntegrableOn interactionDensity (Set.Icc a b)
  exterior_decomposition : ∀ x,
    qDeriv x (1, 0) - pDeriv x (0, 1) =
      curvatureDensity x + interactionDensity x

namespace RectangleFuzzyStokesData

variable {a b : Plane} (R : RectangleFuzzyStokesData a b)

/-- The typed exterior derivative density of `P dx + Q dy`. -/
def exteriorDensity (x : Plane) : ℝ :=
  R.qDeriv x (1, 0) - R.pDeriv x (0, 1)

/-- The exterior density is integrable because the certified curvature and
interaction densities are integrable. -/
theorem exteriorDensity_integrable :
    IntegrableOn R.exteriorDensity (Set.Icc a b) := by
  rw [show R.exteriorDensity =
      R.curvatureDensity + R.interactionDensity by
    funext x
    exact R.exterior_decomposition x]
  exact R.curvature_integrable.add R.interaction_integrable

/-- Green--Stokes on the rectangular chart, derived from mathlib's planar
divergence theorem by rotating `(P,Q)` to `(Q,-P)`. This is the analytic
boundary/interior bridge that the earlier generic certificate assumed. -/
theorem rectangle_stokes :
    (∫ x in Set.Icc a b, R.exteriorDensity x) =
      rectangleBoundaryCirculation R.pCoeff R.qCoeff a b := by
  have h := MeasureTheory.integral_divergence_prod_Icc_of_hasFDerivAt_of_le
    R.qCoeff (-R.pCoeff) R.qDeriv (-R.pDeriv) a b R.lower_le_upper
    R.q_continuous R.p_continuous.neg
    R.q_hasFDerivAt
    (fun x hx => (R.p_hasFDerivAt x hx).neg)
    R.exteriorDensity_integrable
  simpa [exteriorDensity, rectangleBoundaryCirculation, sub_eq_add_neg] using h

/-- The analytic rectangle data instantiate the abstract typed Fuzzy Stokes
certificate with genuine Lebesgue surface integration. -/
def certificate : FuzzyStokesCertificate Unit (Plane → ℝ) ℝ where
  boundaryIntegral := fun _ => rectangleBoundaryCirculation R.pCoeff R.qCoeff a b
  interiorIntegral := fun density => ∫ x in Set.Icc a b, density x
  integrates_curvature_interaction :=
    MeasureTheory.integral_add (μ := MeasureTheory.volume.restrict (Set.Icc a b))
      R.curvature_integrable R.interaction_integrable
  exteriorDerivative := fun _ => R.exteriorDensity
  covariantForm := ()
  curvatureForm := R.curvatureDensity
  interactionForm := R.interactionDensity
  classicalStokes := R.rectangle_stokes.symm
  curvatureInteractionDecomposition := funext R.exterior_decomposition

/-- **Analytic Fuzzy Stokes on an oriented rectangular chart.** -/
theorem analytic_fuzzy_stokes :
    rectangleBoundaryCirculation R.pCoeff R.qCoeff a b =
      (∫ x in Set.Icc a b, R.curvatureDensity x) +
        ∫ x in Set.Icc a b, R.interactionDensity x :=
  R.certificate.fuzzy_stokes

/-- The analytic curvature-only recovery law. -/
theorem analytic_classical_recovery
    (hresidue : ∫ x in Set.Icc a b, R.interactionDensity x = 0) :
    rectangleBoundaryCirculation R.pCoeff R.qCoeff a b =
      ∫ x in Set.Icc a b, R.curvatureDensity x :=
  R.certificate.classical_recovery hresidue

/-- The analytic curvature density is the symbolic-curvature carrier of the
Book IV gauge dictionary. Once a structural gauge certificate identifies it
with the curvature of a symbolic connection, curvature naturality transports
that same object to the target gauge field strength. -/
theorem analytic_curvature_transports_through_gauge
    {SF SD SL SA SG GF GD GCurv GLoop GConn GTrans : Type*}
    (d : Book4Gauge.StructuralGaugeCertificate
      SF SD (Plane → ℝ) SL SA SG GF GD GCurv GLoop GConn GTrans)
    (A : SA)
    (hrep : d.symbolicCurvature A = R.curvatureDensity) :
    d.toGaugeDictionary.curvature R.curvatureDensity =
      d.targetCurvature (d.toGaugeDictionary.connection A) := by
  rw [← hrep]
  exact d.curvature_square A
end RectangleFuzzyStokesData

/-! ## Finite oriented atlas assembly -/

/-- The three values contributed by one oriented chart, together with its
local Fuzzy Stokes law. Analytic rectangular charts supply these values via
`RectangleFuzzyStokesData.analytic_fuzzy_stokes`. -/
structure OrientedChartContribution (Value : Type*) [AddCommGroup Value] where
  boundary : Value
  curvature : Value
  interaction : Value
  local_fuzzy_stokes : boundary = curvature + interaction

/-- A finite atlas assembly certificate. The boundary assembly equation is
where oppositely oriented overlap edges cancel; it is intentionally explicit
rather than inferred from mere chart overlap. -/
structure FuzzyStokesAtlasCertificate
    (Chart Value : Type*) [Fintype Chart] [AddCommGroup Value] where
  chart : Chart → OrientedChartContribution Value
  globalBoundary : Value
  globalCurvature : Value
  globalInteraction : Value
  boundary_assembly : globalBoundary = ∑ i, (chart i).boundary
  curvature_assembly : globalCurvature = ∑ i, (chart i).curvature
  interaction_assembly : globalInteraction = ∑ i, (chart i).interaction

namespace FuzzyStokesAtlasCertificate

variable {Chart Value : Type*} [Fintype Chart] [AddCommGroup Value]
  (A : FuzzyStokesAtlasCertificate Chart Value)

/-- **Assembled Fuzzy Stokes.** Local analytic laws plus certified oriented
overlap cancellation yield the global boundary/curvature/interaction law. -/
theorem assembled_fuzzy_stokes :
    A.globalBoundary = A.globalCurvature + A.globalInteraction := by
  rw [A.boundary_assembly, A.curvature_assembly, A.interaction_assembly,
    ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  exact (A.chart i).local_fuzzy_stokes

/-- Zero assembled interaction residue recovers the global curvature law. -/
theorem assembled_classical_recovery
    (hresidue : A.globalInteraction = 0) :
    A.globalBoundary = A.globalCurvature := by
  rw [A.assembled_fuzzy_stokes, hresidue, add_zero]

end FuzzyStokesAtlasCertificate

/-- Every analytic rectangular chart produces an atlas contribution. -/
def RectangleFuzzyStokesData.chartContribution
    {a b : Plane} (R : RectangleFuzzyStokesData a b) :
    OrientedChartContribution ℝ where
  boundary := rectangleBoundaryCirculation R.pCoeff R.qCoeff a b
  curvature := ∫ x in Set.Icc a b, R.curvatureDensity x
  interaction := ∫ x in Set.Icc a b, R.interactionDensity x
  local_fuzzy_stokes := R.analytic_fuzzy_stokes


end

end ForcingAnalysis.Book4FuzzyStokes