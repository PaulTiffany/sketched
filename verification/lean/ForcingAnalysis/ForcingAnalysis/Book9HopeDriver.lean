/- Book9HopeDriver.lean — hope as directed change under bounded capacity. -/
import Mathlib.Data.Real.Basic

namespace ForcingAnalysis.Book9HopeDriver

/-- A substrate-neutral system with observer-accessible capacity and drive.
The carrier may later be interpreted physically, cognitively, or socially;
the structure itself makes no claim that those interpretations coincide. -/
structure BoundedDriveSystem (State : Type*) where
  capacity : State → ℝ
  drive : State → ℝ

/-- Capacity has one global finite ceiling. -/
def CapacityBounded {State : Type*} (sys : BoundedDriveSystem State) : Prop :=
  ∃ ceiling : ℝ, ∀ s, sys.capacity s ≤ ceiling

/-- Drive is not bounded above on the represented state space. -/
def DriveUnbounded {State : Type*} (sys : BoundedDriveSystem State) : Prop :=
  ∀ bound : ℝ, ∃ s, bound < sys.drive s

/-- The visible excess of drive over capacity. -/
def residual {State : Type*} (sys : BoundedDriveSystem State) (s : State) : ℝ :=
  max 0 (sys.drive s - sys.capacity s)

/-- Residual is positive exactly when drive exceeds capacity. -/
theorem residual_pos_iff {State : Type*} (sys : BoundedDriveSystem State)
    (s : State) :
    0 < residual sys s ↔ sys.capacity s < sys.drive s := by
  simp [residual]

/-- Bounded capacity in the presence of unbounded drive guarantees a breach
somewhere. This is substrate-neutral; it does not identify the mechanism or
consequence of the breach. -/
theorem bounded_capacity_unbounded_drive_produces_breach
    {State : Type*} (sys : BoundedDriveSystem State)
    (hcapacity : CapacityBounded sys) (hdrive : DriveUnbounded sys) :
    ∃ s, 0 < residual sys s := by
  rcases hcapacity with ⟨ceiling, hceiling⟩
  rcases hdrive ceiling with ⟨s, hs⟩
  refine ⟨s, (residual_pos_iff sys s).2 ?_⟩
  exact lt_of_le_of_lt (hceiling s) hs

/-- Hope is an operational witness of a viable next state with strictly less
unresolved residual. It is not merely optimism and it does not yet specify a
collective objective. -/
def Hope {State : Type*} (sys : BoundedDriveSystem State)
    (transition : State → State → Prop) (viable : State → Prop)
    (present : State) : Prop :=
  ∃ next, transition present next ∧ viable next ∧
    residual sys next < residual sys present

/-- Hope supplies a direction for change: a viable residual-reducing route. -/
theorem hope_drives_change {State : Type*} (sys : BoundedDriveSystem State)
    (transition : State → State → Prop) (viable : State → Prop)
    (present : State) (hhope : Hope sys transition viable present) :
    ∃ next, transition present next ∧ viable next ∧
      residual sys next < residual sys present :=
  hhope

/-- The Moloch boundary: even a genuine viable, residual-reducing transition
does not logically determine whose good is served. Shared-good evaluation is
an additional observer/authority bridge. -/
theorem hope_alone_does_not_force_shared_good :
    ∃ (sys : BoundedDriveSystem Bool)
      (transition : Bool → Bool → Prop) (viable sharedGood : Bool → Prop),
      Hope sys transition viable true ∧ ¬ sharedGood false := by
  let sys : BoundedDriveSystem Bool := {
    capacity := fun _ => 1
    drive := fun s => if s then 2 else 0
  }
  let transition : Bool → Bool → Prop := fun source target => source = true ∧ target = false
  let viable : Bool → Prop := fun _ => True
  let sharedGood : Bool → Prop := fun _ => False
  refine ⟨sys, transition, viable, sharedGood, ?_, by simp [sharedGood]⟩
  refine ⟨false, by simp [transition], by simp [viable], ?_⟩
  norm_num [sys, residual]

end ForcingAnalysis.Book9HopeDriver
