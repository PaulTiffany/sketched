/-
Book4FieldRegularization.lean — an explicit observer-cutoff kernel for the
field-theory regularization claim in Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4FieldRegularization

/-- A hard observer cutoff: momentum modes above `cutoff` are unavailable. -/
def cutoffMode (cutoff momentum : ℕ) (amplitude : ℝ) : ℝ :=
  if momentum ≤ cutoff then amplitude else 0

theorem cutoffMode_eq_self {cutoff momentum : ℕ} {amplitude : ℝ}
    (h : momentum ≤ cutoff) :
    cutoffMode cutoff momentum amplitude = amplitude := by
  simp [cutoffMode, h]

theorem cutoffMode_eq_zero {cutoff momentum : ℕ} {amplitude : ℝ}
    (h : cutoff < momentum) :
    cutoffMode cutoff momentum amplitude = 0 := by
  simp [cutoffMode, Nat.not_le_of_gt h]

theorem cutoffMode_abs_le (cutoff momentum : ℕ) (amplitude : ℝ) :
    |cutoffMode cutoff momentum amplitude| ≤ |amplitude| := by
  by_cases h : momentum ≤ cutoff
  · simp [cutoffMode, h]
  · simp [cutoffMode, h]

/-- A finite perturbative insertion is a product of its cutoff modes. -/
def perturbativeInsertion {order : ℕ} (cutoff : ℕ)
    (momentum : Fin order → ℕ) (amplitude : Fin order → ℝ) : ℝ :=
  ∏ i, cutoffMode cutoff (momentum i) (amplitude i)

/-- Any unresolved internal momentum kills the corresponding finite-order
insertion exactly. -/
theorem perturbativeInsertion_eq_zero_of_high_mode {order cutoff : ℕ}
    (momentum : Fin order → ℕ) (amplitude : Fin order → ℝ)
    (i : Fin order) (hi : cutoff < momentum i) :
    perturbativeInsertion cutoff momentum amplitude = 0 := by
  unfold perturbativeInsertion
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  exact cutoffMode_eq_zero hi

/-- The observer-accessible band has exactly `cutoff + 1` natural momentum
labels, hence every sum explicitly restricted to it is finite. -/
theorem accessibleBand_card (cutoff : ℕ) :
    (Finset.range (cutoff + 1)).card = cutoff + 1 := by
  simp

/-- Merely naming a positive resolution scale supplies no cutoff law: the
constant multiplier leaves every momentum mode unsuppressed. -/
theorem resolution_scale_alone_does_not_force_suppression :
    ∃ (kernel : ℕ → ℝ), ∀ momentum, kernel momentum ≠ 0 := by
  refine ⟨fun _ => 1, ?_⟩
  intro momentum
  norm_num

end ForcingAnalysis.Book4FieldRegularization
