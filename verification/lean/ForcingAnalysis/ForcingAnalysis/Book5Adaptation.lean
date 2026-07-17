/-
Book5Adaptation.lean — explicit adaptation contract for Principia Symbolica
Book 5.  Adaptation is represented as supplied structure, never as a global
Lean axiom.
-/
import Mathlib

namespace ForcingAnalysis.Book5Adaptation

/-- The three modulation channels named by `axiom:bk5_adaptation`. -/
inductive AdaptationChannel
  | transfer
  | reflection
  | drift
  deriving DecidableEq, Fintype

/-- A system equipped with channel-indexed updates and a condition-relative
viability predicate. -/
structure AdaptiveSystem (Condition State : Type*) where
  update : AdaptationChannel → Condition → State → State
  Viable : Condition → State → Prop

/-- The Book 5 adaptation axiom as explicit data: for each environmental
change and currently viable state, select a named modulation channel whose
update preserves viability under the new condition. -/
structure AdaptationLaw {Condition State : Type*}
    (sys : AdaptiveSystem Condition State) where
  select : Condition → Condition → State → AdaptationChannel
  preserves : ∀ oldCondition newCondition state,
    sys.Viable oldCondition state →
      sys.Viable newCondition
        (sys.update (select oldCondition newCondition state) newCondition state)

/-- Consuming an adaptation law yields a concrete viable successor under the
changed condition. -/
theorem adapted_state_viable {Condition State : Type*}
    (sys : AdaptiveSystem Condition State) (law : AdaptationLaw sys)
    {oldCondition newCondition : Condition} {state : State}
    (h : sys.Viable oldCondition state) :
    sys.Viable newCondition
      (sys.update (law.select oldCondition newCondition state) newCondition state) :=
  law.preserves oldCondition newCondition state h

/-- Having transfer, reflection, and drift updates does not by itself imply
adaptation.  This system is viable in the old condition, but every available
update fails viability after the condition changes. -/
theorem operators_do_not_supply_adaptation :
    ∃ (sys : AdaptiveSystem Bool Unit),
      sys.Viable false () ∧
      ¬ ∃ channel, sys.Viable true (sys.update channel true ()) := by
  let sys : AdaptiveSystem Bool Unit := {
    update := fun _ _ _ => ()
    Viable := fun condition _ => condition = false
  }
  refine ⟨sys, rfl, ?_⟩
  simp [sys]

end ForcingAnalysis.Book5Adaptation