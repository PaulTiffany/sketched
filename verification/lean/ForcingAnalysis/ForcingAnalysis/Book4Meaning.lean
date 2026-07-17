/-
Book4Meaning.lean — the finite value-map kernel and dependency audit for
Principia Symbolica Book 4's "Emergence of Meaning" corollary.
-/
import ForcingAnalysis.Book4B

namespace ForcingAnalysis.Book4Meaning

/-- Meaning value as contrast from a supplied free-energy ceiling. -/
def meaningValue {U : Type*} (ceiling : ℝ) (freeEnergy : U → ℝ) (u : U) : ℝ :=
  ceiling - freeEnergy u

theorem meaningValue_nonneg {U : Type*} (ceiling : ℝ) (freeEnergy : U → ℝ)
    (hCeiling : ∀ u, freeEnergy u ≤ ceiling) (u : U) :
    0 ≤ meaningValue ceiling freeEnergy u := by
  unfold meaningValue
  linarith [hCeiling u]

theorem meaningValue_pos_iff {U : Type*} (ceiling : ℝ)
    (freeEnergy : U → ℝ) (u : U) :
    0 < meaningValue ceiling freeEnergy u ↔ freeEnergy u < ceiling := by
  constructor <;> intro h
  · unfold meaningValue at h
    linarith
  · unfold meaningValue
    linarith

/-- The value map is nontrivial exactly when some configuration lies below
the supplied energy ceiling. -/
theorem exists_positive_meaning_iff {U : Type*} (ceiling : ℝ)
    (freeEnergy : U → ℝ) :
    (∃ u, 0 < meaningValue ceiling freeEnergy u) ↔
      ∃ u, freeEnergy u < ceiling := by
  simp only [meaningValue_pos_iff]

/-- Meaning preference reverses free-energy order, as claimed by the source's
"preferential flows" interpretation. -/
theorem meaningValue_strict_preference_iff {U : Type*} (ceiling : ℝ)
    (freeEnergy : U → ℝ) (u v : U) :
    meaningValue ceiling freeEnergy u > meaningValue ceiling freeEnergy v ↔
      freeEnergy u < freeEnergy v := by
  constructor <;> intro h
  · unfold meaningValue at h
    linarith
  · unfold meaningValue
    linarith

/-- The prior freedom-life transition does not, by itself, make an unrelated
free-energy landscape nonconstant. This is the missing bridge in Step 1 of
the printed proof. -/
theorem freedomLifeTransition_does_not_force_nonconstant_energy :
    ∃ _t : Book4B.FreedomLifeTransition,
      ∃ freeEnergy : Bool → ℝ,
        (∀ u, freeEnergy u = 0) ∧ ¬ ∃ u v, freeEnergy u ≠ freeEnergy v := by
  let t : Book4B.FreedomLifeTransition :=
    { Ffree := fun n => (n : ℝ)
      deltaF := 1
      deltaF_pos := by norm_num
      increasing := by
        intro k
        norm_num
      Ffrag := 0
      epsMax := 1
      Ffrag_bounded := by norm_num }
  refine ⟨t, fun _ => 0, ?_, ?_⟩
  · intro u
    rfl
  · rintro ⟨u, v, h⟩
    exact h rfl

end ForcingAnalysis.Book4Meaning
