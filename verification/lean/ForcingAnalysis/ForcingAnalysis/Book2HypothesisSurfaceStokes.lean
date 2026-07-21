/-
Book2HypothesisSurfaceStokes.lean — differential-form and Stokes bridge for
the thermodynamic consistency of observer-relative hypothesis surfaces.
-/
import Mathlib
import ForcingAnalysis.Book2CycleConsistency

namespace ForcingAnalysis.Book2HypothesisSurfaceStokes

/-- Degree-correct integration data for an oriented hypothesis surface.
`BoundaryOne` and `InteriorTwo` are kept distinct so Stokes transport cannot
silently identify boundary one-forms with interior two-forms. -/
structure OrientedSurfaceCalculus (BoundaryOne InteriorTwo : Type*)
    [AddCommGroup BoundaryOne] [Module ℝ BoundaryOne]
    [AddCommGroup InteriorTwo] [Module ℝ InteriorTwo] where
  oriented : Prop
  closedBoundary : Prop
  oriented_certified : oriented
  closedBoundary_certified : closedBoundary
  boundaryIntegral : BoundaryOne →ₗ[ℝ] ℝ
  interiorIntegral : InteriorTwo →ₗ[ℝ] ℝ
  exteriorDerivative : BoundaryOne →ₗ[ℝ] InteriorTwo
  stokes : ∀ omega,
    interiorIntegral (exteriorDerivative omega) = boundaryIntegral omega

/-- Pulled-back thermodynamic one-forms on the hypothesis boundary. The first
variation is a form identity; curvature is recorded only as regularity data. -/
structure HypothesisSurfaceThermodynamics
    {BoundaryOne InteriorTwo : Type*}
    [AddCommGroup BoundaryOne] [Module ℝ BoundaryOne]
    [AddCommGroup InteriorTwo] [Module ℝ InteriorTwo]
    (C : OrientedSurfaceCalculus BoundaryOne InteriorTwo) where
  dFreeEnergy : BoundaryOne
  dObserverEnergy : BoundaryOne
  temperatureEntropy : BoundaryOne
  entropyTemperature : BoundaryOne
  firstVariation :
    dFreeEnergy = dObserverEnergy - temperatureEntropy - entropyTemperature
  curvature : ℝ
  observerCurvatureBound : ℝ
  curvature_bounded : curvature < observerCurvatureBound

namespace HypothesisSurfaceThermodynamics

variable {BoundaryOne InteriorTwo : Type*}
  [AddCommGroup BoundaryOne] [Module ℝ BoundaryOne]
  [AddCommGroup InteriorTwo] [Module ℝ InteriorTwo]
  {C : OrientedSurfaceCalculus BoundaryOne InteriorTwo}
  (H : HypothesisSurfaceThermodynamics C)

/-- The unreconciled observer-energy/temperature-entropy circulation. -/
def accountingResidue : ℝ :=
  C.boundaryIntegral (H.dObserverEnergy - H.temperatureEntropy)

/-- The first-variation identity exposes the residue before consistency is
assumed: free-energy circulation equals residue minus exchange. -/
theorem boundary_balance_with_residue :
    C.boundaryIntegral H.dFreeEnergy =
      H.accountingResidue - C.boundaryIntegral H.entropyTemperature := by
  rw [H.firstVariation]
  simp [accountingResidue, sub_eq_add_neg, add_assoc]

/-- Thermodynamic consistency is exactly closure of observer accounting. -/
theorem boundary_consistency_iff_residue_zero :
    C.boundaryIntegral H.dFreeEnergy =
      -C.boundaryIntegral H.entropyTemperature ↔
    H.accountingResidue = 0 := by
  rw [H.boundary_balance_with_residue]
  constructor <;> intro h <;> linarith

/-- The canonical source conclusion follows when the closed-surface balance is
supplied. -/
theorem boundary_thermodynamic_consistency
    (hclosed : H.accountingResidue = 0) :
    C.boundaryIntegral H.dFreeEnergy =
      -C.boundaryIntegral H.entropyTemperature :=
  (H.boundary_consistency_iff_residue_zero).2 hclosed

/-- A separately supplied, oriented, degree-correct Stokes law transports the
boundary identity into the hypothesis interior. -/
theorem interior_thermodynamic_consistency
    (hclosed : H.accountingResidue = 0) :
    C.interiorIntegral (C.exteriorDerivative H.dFreeEnergy) =
      -C.interiorIntegral (C.exteriorDerivative H.entropyTemperature) := by
  rw [C.stokes, C.stokes]
  exact H.boundary_thermodynamic_consistency hclosed

/-- The interior identity is still equivalent to accounting closure because
Stokes relates each interior derivative to its boundary circulation. -/
theorem interior_consistency_iff_residue_zero :
    C.interiorIntegral (C.exteriorDerivative H.dFreeEnergy) =
      -C.interiorIntegral (C.exteriorDerivative H.entropyTemperature) ↔
    H.accountingResidue = 0 := by
  rw [C.stokes, C.stokes]
  exact H.boundary_consistency_iff_residue_zero

end HypothesisSurfaceThermodynamics

/-- Positive control: exact observer accounting produces both boundary and
interior consistency in the scalar identity calculus. -/
theorem scalar_closed_surface_consistent :
    let C : OrientedSurfaceCalculus ℝ ℝ := {
      oriented := True
      closedBoundary := True
      oriented_certified := trivial
      closedBoundary_certified := trivial
      boundaryIntegral := LinearMap.id
      interiorIntegral := LinearMap.id
      exteriorDerivative := LinearMap.id
      stokes := by intro omega; rfl }
    let H : HypothesisSurfaceThermodynamics C := {
      dFreeEnergy := -2
      dObserverEnergy := 3
      temperatureEntropy := 3
      entropyTemperature := 2
      firstVariation := by norm_num
      curvature := 0
      observerCurvatureBound := 1
      curvature_bounded := by norm_num }
    C.interiorIntegral (C.exteriorDerivative H.dFreeEnergy) =
      -C.interiorIntegral (C.exteriorDerivative H.entropyTemperature) := by
  norm_num [HypothesisSurfaceThermodynamics.accountingResidue,
    HypothesisSurfaceThermodynamics.interior_thermodynamic_consistency]

/-- Bounded curvature is not closed accounting: a smooth-looking scalar
surface may retain nonzero residue and violate thermodynamic consistency. -/
theorem bounded_curvature_does_not_zero_residue :
    ∃ (C : OrientedSurfaceCalculus ℝ ℝ)
      (H : HypothesisSurfaceThermodynamics C),
      H.curvature < H.observerCurvatureBound ∧
      H.accountingResidue ≠ 0 ∧
      C.boundaryIntegral H.dFreeEnergy ≠
        -C.boundaryIntegral H.entropyTemperature := by
  let C : OrientedSurfaceCalculus ℝ ℝ := {
    oriented := True
    closedBoundary := True
    oriented_certified := trivial
    closedBoundary_certified := trivial
    boundaryIntegral := LinearMap.id
    interiorIntegral := LinearMap.id
    exteriorDerivative := LinearMap.id
    stokes := by intro omega; rfl }
  let H : HypothesisSurfaceThermodynamics C := {
    dFreeEnergy := 1
    dObserverEnergy := 1
    temperatureEntropy := 0
    entropyTemperature := 0
    firstVariation := by norm_num
    curvature := 0
    observerCurvatureBound := 1
    curvature_bounded := by norm_num }
  refine ⟨C, H, by norm_num, ?_, by norm_num [C, H]⟩
  norm_num [HypothesisSurfaceThermodynamics.accountingResidue, C, H]

end ForcingAnalysis.Book2HypothesisSurfaceStokes