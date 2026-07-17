/- Book8CognitiveScaffold.lean — operational cognitive-scaffold certification. -/
import Mathlib

namespace ForcingAnalysis.Book8CognitiveScaffold

/-- A metabolic/debugging pair with an admitted operational domain. -/
structure ComposablePair (State : Type*) where
  metabolic : State → State
  debug : State → State
  admissible : State → Prop
  metabolic_closed : ∀ state, admissible state → admissible (metabolic state)
  debug_closed : ∀ state, admissible state → admissible (debug state)

/-- Source order: first metabolize, then debug. -/
def ComposablePair.step {State : Type*} (pair : ComposablePair State) : State → State :=
  pair.debug ∘ pair.metabolic

/-- The reversed order is deliberately a separate operation. -/
def ComposablePair.reverseStep {State : Type*}
    (pair : ComposablePair State) : State → State :=
  pair.metabolic ∘ pair.debug

theorem ComposablePair.step_closed {State : Type*}
    (pair : ComposablePair State) {state : State}
    (hstate : pair.admissible state) :
    pair.admissible (pair.step state) := by
  exact pair.debug_closed _ (pair.metabolic_closed _ hstate)

theorem ComposablePair.iterate_closed {State : Type*}
    (pair : ComposablePair State) {state : State}
    (hstate : pair.admissible state) (steps : ℕ) :
    pair.admissible (pair.step^[steps] state) := by
  induction steps generalizing state with
  | zero => simpa using hstate
  | succ steps ih =>
      rw [Function.iterate_succ_apply]
      exact ih (pair.step_closed hstate)

/-- The extra certificates required to turn a composable loop into the
operational scaffold asserted by the source. -/
structure CertifiedScaffold (State : Type*) extends ComposablePair State where
  freeEnergy : State → ℝ
  identityStable : State → Prop
  trajectoryMagnitude : State → ℝ
  temperatureBound : ℝ
  freeEnergy_nonincrease : ∀ state, freeEnergy (toComposablePair.step state) ≤ freeEnergy state
  identity_preserved : ∀ state, identityStable state → identityStable (toComposablePair.step state)
  trajectory_bounded : ∀ state, admissible state → trajectoryMagnitude state ≤ temperatureBound

theorem CertifiedScaffold.one_step_freeEnergy_nonincrease {State : Type*}
    (scaffold : CertifiedScaffold State) (state : State) :
    scaffold.freeEnergy (scaffold.toComposablePair.step state) ≤
      scaffold.freeEnergy state :=
  scaffold.freeEnergy_nonincrease state

theorem CertifiedScaffold.iterate_identity_preserved {State : Type*}
    (scaffold : CertifiedScaffold State) {state : State}
    (hidentity : scaffold.identityStable state) (steps : ℕ) :
    scaffold.identityStable (scaffold.toComposablePair.step^[steps] state) := by
  induction steps generalizing state with
  | zero => simpa using hidentity
  | succ steps ih =>
      rw [Function.iterate_succ_apply]
      exact ih (scaffold.identity_preserved _ hidentity)

theorem CertifiedScaffold.iterate_trajectory_bounded {State : Type*}
    (scaffold : CertifiedScaffold State) {state : State}
    (hstate : scaffold.admissible state) (steps : ℕ) :
    scaffold.trajectoryMagnitude
        (scaffold.toComposablePair.step^[steps] state) ≤
      scaffold.temperatureBound := by
  exact scaffold.trajectory_bounded _
    (scaffold.toComposablePair.iterate_closed hstate steps)

/-- Concrete order countermodel: metabolize-then-debug and debug-then-metabolize
need not agree even when both operators preserve the admitted domain. -/
theorem composable_operator_order_need_not_commute :
    ∃ pair : ComposablePair ℕ,
      pair.step 1 ≠ pair.reverseStep 1 := by
  let pair : ComposablePair ℕ :=
    { metabolic := fun n => n + 1
      debug := fun n => 2 * n
      admissible := fun _ => True
      metabolic_closed := by simp
      debug_closed := by simp }
  refine ⟨pair, ?_⟩
  norm_num [pair, ComposablePair.step, ComposablePair.reverseStep, Function.comp_def]

/-- Composability alone does not imply a proposed temperature bound. -/
theorem composability_alone_does_not_bound_trajectory :
    ∃ pair : ComposablePair ℕ, ∃ magnitude : ℕ → ℝ, ∃ bound : ℝ,
      pair.admissible 1 ∧ ¬ magnitude 1 ≤ bound := by
  let pair : ComposablePair ℕ :=
    { metabolic := id
      debug := id
      admissible := fun _ => True
      metabolic_closed := by simp
      debug_closed := by simp }
  exact ⟨pair, fun n => n, 0, by simp [pair]⟩

end ForcingAnalysis.Book8CognitiveScaffold
