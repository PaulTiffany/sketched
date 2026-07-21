/- Book5StatefulOperatorLearning.lean — stateful SRMF operator learning. -/
import ForcingAnalysis.Book5OperatorSelection
import ForcingAnalysis.Book5OperatorAdaptation

namespace ForcingAnalysis.Book5StatefulOperatorLearning

open Book5OperatorSelection

/-- The persistent selector state: an available inventory, its incumbent, and
provider-independent operator history. -/
structure LearningState (Operator : Type*) [DecidableEq Operator] where
  inventory : Finset Operator
  current : Operator
  current_mem : current ∈ inventory
  history : List Operator

/-- Feedback determines both the next admissible inventory and the objective
used to select from it. The minimizer certificate is data of the law, not a
consequence of viability. -/
structure LearningLaw (Operator Feedback : Type*) [DecidableEq Operator] where
  processFreeEnergy : Feedback → Operator → ℝ
  nextInventory : Feedback → LearningState Operator → Finset Operator
  next_nonempty : ∀ feedback state, (nextInventory feedback state).Nonempty
  select : Feedback → LearningState Operator → Operator
  selects : ∀ feedback state,
    SelectsProcessMinimizer
      (nextInventory feedback state)
      (processFreeEnergy feedback)
      (select feedback state)

/-- Execute one certified feedback-sensitive learning step and retain the old
incumbent in history. -/
def step {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (feedback : Feedback)
    (state : LearningState Operator) : LearningState Operator where
  inventory := law.nextInventory feedback state
  current := law.select feedback state
  current_mem := (law.selects feedback state).selected_mem
  history := state.current :: state.history

theorem step_current {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (feedback : Feedback)
    (state : LearningState Operator) :
    (step law feedback state).current = law.select feedback state := rfl

theorem step_records_incumbent {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (feedback : Feedback)
    (state : LearningState Operator) :
    (step law feedback state).history = state.current :: state.history := rfl

/-- Regret relative to any available comparator after the update. -/
def comparatorRegret {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (feedback : Feedback)
    (state : LearningState Operator) (candidate : Operator) : ℝ :=
  law.processFreeEnergy feedback (step law feedback state).current -
    law.processFreeEnergy feedback candidate

/-- A certified learning step has nonpositive regret against every operator in
its updated inventory. -/
theorem step_comparatorRegret_nonpos
    {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (feedback : Feedback)
    (state : LearningState Operator) {candidate : Operator}
    (hcandidate : candidate ∈ law.nextInventory feedback state) :
    comparatorRegret law feedback state candidate ≤ 0 := by
  have hmin := (law.selects feedback state).minimal candidate hcandidate
  unfold comparatorRegret
  simp only [step_current]
  linarith

/-- The update need not preserve the inventory: admission and selection are
separate parts of the learning law. -/
def InventoryChanges {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (feedback : Feedback)
    (state : LearningState Operator) : Prop :=
  law.nextInventory feedback state ≠ state.inventory

/-- Genuine feedback sensitivity means distinct evidence can select distinct
future operators from the same persistent state. -/
def RespondsToFeedback {Operator Feedback : Type*} [DecidableEq Operator]
    (law : LearningLaw Operator Feedback) (state : LearningState Operator) : Prop :=
  ∃ first second, law.select first state ≠ law.select second state

/-- A concrete two-operator learner: the feedback bit declares which operator
has zero process free energy. -/
def boolFeedbackLaw : LearningLaw Bool Bool where
  processFreeEnergy feedback operator := if operator = feedback then 0 else 1
  nextInventory _ _ := Finset.univ
  next_nonempty := by intro feedback state; simp
  select feedback _ := feedback
  selects := by
    intro feedback state
    constructor
    · simp
    · intro candidate hcandidate
      cases candidate <;> cases feedback <;> norm_num

/-- One persistent state is routed to different operators by different
feedback; this is selection embedded in an actual state transition. -/
theorem boolFeedbackLaw_responds (state : LearningState Bool) :
    RespondsToFeedback boolFeedbackLaw state := by
  refine ⟨false, true, ?_⟩
  exact Bool.false_ne_true

/-- History distinguishes adaptation from a stateless repeated argmin: after
two steps both prior incumbents are retained in order. -/
theorem two_steps_retain_ordered_history (state : LearningState Bool) :
    (step boolFeedbackLaw true (step boolFeedbackLaw false state)).history =
      false :: state.current :: state.history := by
  rfl

/-- Availability is not derived from feedback or viability. The concrete law
keeps a universal inventory fixed even while its selected operator changes. -/
theorem feedback_response_does_not_force_inventory_change
    (state : LearningState Bool) (hinventory : state.inventory = Finset.univ) :
    RespondsToFeedback boolFeedbackLaw state ∧
      ¬ InventoryChanges boolFeedbackLaw false state := by
  constructor
  · exact boolFeedbackLaw_responds state
  · unfold InventoryChanges
    change ¬ (Finset.univ ≠ state.inventory)
    rw [hinventory]
    exact fun h => h rfl

end ForcingAnalysis.Book5StatefulOperatorLearning