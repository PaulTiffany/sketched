/- AppendixCoherenceAxioms.lean — noncontextuality and resolution axioms. -/
import Mathlib

namespace ForcingAnalysis.AppendixCoherenceAxioms

/-- Observer budget values for asking the same question in different frames. -/
structure FrameBudget (Frame Question : Type*) where
  value : Frame → Question → ℝ
  bounded : ∀ frame question, 0 ≤ value frame question ∧ value frame question ≤ 1

def NoncontextualAt {Frame Question : Type*}
    (budget : FrameBudget Frame Question) (question : Question) : Prop :=
  ∀ first second : Frame,
    budget.value first question = budget.value second question

theorem noncontextual_budget_frame_independent {Frame Question : Type*}
    (budget : FrameBudget Frame Question) {question : Question}
    (hnoncontextual : NoncontextualAt budget question)
    (first second : Frame) :
    budget.value first question = budget.value second question :=
  hnoncontextual first second

/-- Bounded, normalized-looking values inside each frame do not imply
cross-frame noncontextuality. -/
theorem bounded_budget_does_not_force_noncontextuality :
    ∃ budget : FrameBudget Bool Unit,
      ¬ NoncontextualAt budget () := by
  let budget : FrameBudget Bool Unit :=
    { value := fun frame _ => if frame then 1 else 0
      bounded := by
        intro frame question
        cases frame <;> simp }
  refine ⟨budget, ?_⟩
  intro h
  have := h false true
  simp [budget] at this

/-- PS-C5 as a typed condition: sufficiently separated orthogonal questions
cannot both receive maximal coherence for the same pure-state representation. -/
def ResolutionLimitedDistinguishability {Question : Type*}
    (coherence : Question → ℝ)
    (orthogonal separated : Question → Question → Prop) : Prop :=
  ∀ first second,
    orthogonal first second → separated first second →
      ¬ (coherence first = 1 ∧ coherence second = 1)

theorem separated_orthogonal_questions_not_both_maximal {Question : Type*}
    {coherence : Question → ℝ} {orthogonal separated : Question → Question → Prop}
    (hresolution :
      ResolutionLimitedDistinguishability coherence orthogonal separated)
    {first second : Question} (horthogonal : orthogonal first second)
    (hseparated : separated first second) :
    ¬ (coherence first = 1 ∧ coherence second = 1) :=
  hresolution first second horthogonal hseparated

/-- Coherence bounded in [0,1] does not derive PS-C5. -/
theorem boundedness_does_not_force_resolution_distinguishability :
    ∃ coherence : Bool → ℝ,
      (∀ question, 0 ≤ coherence question ∧ coherence question ≤ 1) ∧
      ¬ ResolutionLimitedDistinguishability coherence
        (fun first second => first ≠ second)
        (fun first second => first ≠ second) := by
  refine ⟨fun _ => 1, by simp, ?_⟩
  intro h
  exact h false true (by decide) (by decide) ⟨rfl, rfl⟩

end ForcingAnalysis.AppendixCoherenceAxioms
