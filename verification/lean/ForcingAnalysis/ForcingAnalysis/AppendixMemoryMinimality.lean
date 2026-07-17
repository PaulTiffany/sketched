/- AppendixMemoryMinimality.lean — conditional minimality of one-step memory. -/
import Mathlib

namespace ForcingAnalysis.AppendixMemoryMinimality

/-- A one-coordinate Markov update can inspect only the current scalar. -/
def currentOnlyStep (update : ℝ → ℝ) (current : ℝ) : ℝ :=
  update current

/-- Consequently, changing an unrepresented memory value cannot affect its
output. -/
theorem current_only_update_forgets_memory
    (update : ℝ → ℝ) (current firstMemory secondMemory : ℝ) :
    (fun _ : ℝ => currentOnlyStep update current) firstMemory =
      (fun _ : ℝ => currentOnlyStep update current) secondMemory := by
  rfl

/-- The memory-sensitive rule `next = previous` cannot be represented by any
current-only scalar update. -/
theorem memory_projection_not_representable_by_current_only :
    ¬ ∃ update : ℝ → ℝ,
      ∀ current previous : ℝ, currentOnlyStep update current = previous := by
  rintro ⟨update, hupdate⟩
  have hzero := hupdate 0 0
  have hone := hupdate 0 1
  norm_num [currentOnlyStep] at hzero hone
  linarith

/-- Two coordinates retain current state and one memory state. -/
def memoryStep (recurrence : ℝ → ℝ → ℝ) (state : ℝ × ℝ) : ℝ × ℝ :=
  (recurrence state.1 state.2, state.1)

theorem memoryStep_encodes_recurrence
    (recurrence : ℝ → ℝ → ℝ) (current previous : ℝ) :
    memoryStep recurrence (current, previous) =
      (recurrence current previous, current) := by
  rfl

/-- The retained coordinate is exactly the prior current state after a step. -/
theorem memoryStep_retains_current
    (recurrence : ℝ → ℝ → ℝ) (state : ℝ × ℝ) :
    (memoryStep recurrence state).2 = state.1 := by
  rfl

/-- Conditional minimality kernel: dimension one fails for at least one genuine
one-step-memory rule, while the two-coordinate form represents every such rule. -/
theorem two_coordinate_form_conditionally_minimal :
    (¬ ∃ update : ℝ → ℝ,
      ∀ current previous : ℝ, currentOnlyStep update current = previous) ∧
    (∀ recurrence : ℝ → ℝ → ℝ, ∃ step : (ℝ × ℝ) → (ℝ × ℝ),
      ∀ current previous,
        step (current, previous) = (recurrence current previous, current)) := by
  constructor
  · exact memory_projection_not_representable_by_current_only
  · intro recurrence
    exact ⟨memoryStep recurrence, memoryStep_encodes_recurrence recurrence⟩

end ForcingAnalysis.AppendixMemoryMinimality
