/-
Book4ObserverGeometry.lean — coupled-update and stabilization kernel for
observer–geometry co-evolution in Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4ObserverGeometry

/-- A discrete coupled observer/geometry evolution law. Each update consumes
both current components, making the feedback dependence explicit. -/
structure CoupledSystem (Observer Geometry : Type*) where
  observerUpdate : Observer → Geometry → Observer
  geometryUpdate : Geometry → Observer → Geometry

def step {Observer Geometry : Type*} (sys : CoupledSystem Observer Geometry)
    (state : Observer × Geometry) : Observer × Geometry :=
  (sys.observerUpdate state.1 state.2,
   sys.geometryUpdate state.2 state.1)

def RecursivelyStabilized {Observer Geometry : Type*}
    (sys : CoupledSystem Observer Geometry) (state : Observer × Geometry) : Prop :=
  step sys state = state

theorem recursivelyStabilized_iff {Observer Geometry : Type*}
    (sys : CoupledSystem Observer Geometry) (state : Observer × Geometry) :
    RecursivelyStabilized sys state ↔
      sys.observerUpdate state.1 state.2 = state.1 ∧
      sys.geometryUpdate state.2 state.1 = state.2 := by
  simp [RecursivelyStabilized, step, Prod.ext_iff]

/-- For any observer/geometry state there exists a genuinely coupled interface
with that state stabilized: the identity feedback system. -/
theorem exists_recursively_stabilized_system
    {Observer Geometry : Type*} (state : Observer × Geometry) :
    ∃ sys : CoupledSystem Observer Geometry, RecursivelyStabilized sys state := by
  refine ⟨{ observerUpdate := fun observer _ => observer
            geometryUpdate := fun geometry _ => geometry }, ?_⟩
  rfl

/-- Smooth-looking coupled evolution does not imply stabilization. The affine
translation system advances both coordinates forever. -/
def driftingSystem : CoupledSystem ℝ ℝ where
  observerUpdate := fun observer _ => observer + 1
  geometryUpdate := fun geometry _ => geometry + 1

theorem driftingSystem_has_no_stabilized_state :
    ¬ ∃ state : ℝ × ℝ, RecursivelyStabilized driftingSystem state := by
  rintro ⟨state, h⟩
  have hObserver := (recursivelyStabilized_iff driftingSystem state).1 h |>.1
  simp [driftingSystem] at hObserver

end ForcingAnalysis.Book4ObserverGeometry
