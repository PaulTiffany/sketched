/- Book9CollapseEscape.lean — operational escape and mechanism uniqueness. -/
import Mathlib

namespace ForcingAnalysis.Book9CollapseEscape

structure CollapseEscapeSystem (State Mechanism : Type*) where
  collapsed : State
  seed : State
  apply : Mechanism → State → State
  internalRepair : Mechanism
  boundaryIntervention : Mechanism
  inversion : Mechanism
  collapsed_ne_seed : collapsed ≠ seed
  internalRepair_fails : apply internalRepair collapsed = collapsed
  boundary_only : apply boundaryIntervention collapsed = collapsed
  inversion_resets : apply inversion collapsed = seed

def Escapes {State Mechanism : Type*}
    (system : CollapseEscapeSystem State Mechanism) (mechanism : Mechanism) : Prop :=
  system.apply mechanism system.collapsed ≠ system.collapsed

theorem internalRepair_does_not_escape {State Mechanism : Type*}
    (system : CollapseEscapeSystem State Mechanism) :
    ¬ Escapes system system.internalRepair := by
  simp [Escapes, system.internalRepair_fails]

theorem boundaryIntervention_does_not_escape {State Mechanism : Type*}
    (system : CollapseEscapeSystem State Mechanism) :
    ¬ Escapes system system.boundaryIntervention := by
  simp [Escapes, system.boundary_only]

/-- Collapse inversion reaches the distinct generative seed and therefore
escapes the represented collapsed state. -/
theorem inversion_escapes {State Mechanism : Type*}
    (system : CollapseEscapeSystem State Mechanism) :
    Escapes system system.inversion := by
  rw [Escapes, system.inversion_resets]
  exact system.collapsed_ne_seed.symm

/-- “Inversion is the only escape” is valid when the mechanism inventory is
explicitly exhaustive with respect to escaping transformations. -/
theorem inversion_is_unique_escape {State Mechanism : Type*}
    (system : CollapseEscapeSystem State Mechanism)
    (exhaustive : ∀ mechanism, Escapes system mechanism →
      mechanism = system.inversion) :
    ∀ mechanism, Escapes system mechanism ↔ mechanism = system.inversion := by
  intro mechanism
  constructor
  · exact exhaustive mechanism
  · intro h
    simpa [h] using inversion_escapes system

private def nonuniqueEscapeSystem : CollapseEscapeSystem Bool (Fin 4) where
  collapsed := true
  seed := false
  apply mechanism _ := if mechanism.val < 2 then false else true
  internalRepair := 2
  boundaryIntervention := 3
  inversion := 0
  collapsed_ne_seed := by decide
  internalRepair_fails := by decide
  boundary_only := by decide
  inversion_resets := by decide

/-- The reset law plus failure of the named internal and boundary mechanisms
does not exclude an additional escaping mechanism. -/
theorem base_laws_do_not_force_inversion_unique :
    Escapes nonuniqueEscapeSystem (0 : Fin 4) ∧
      Escapes nonuniqueEscapeSystem (1 : Fin 4) ∧
        (1 : Fin 4) ≠ nonuniqueEscapeSystem.inversion := by
  norm_num [Escapes, nonuniqueEscapeSystem]

end ForcingAnalysis.Book9CollapseEscape
