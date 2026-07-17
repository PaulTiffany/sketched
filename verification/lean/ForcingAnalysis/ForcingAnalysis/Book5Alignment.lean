/-
Book5Alignment.lean — finite scalar kernel and premise audit for reflective
drift alignment in Principia Symbolica Book 5.
-/
import Mathlib
import ForcingAnalysis.Book5Thermodynamics

namespace ForcingAnalysis.Book5

/-- Net free-energy contribution in the scalar worst-case alignment model:
restorative covenant strength minus the two maximal drift burdens. -/
def driftReflectionContribution (c : CovenantSnapshot) : ℝ :=
  c.stability * c.minCoupling - (c.driftA + c.driftB)

/-- The positive-contribution reading of reflective alignment is exactly the
previously defined covenant-stability margin. -/
theorem driftReflectionContribution_pos_iff (c : CovenantSnapshot) :
    0 < driftReflectionContribution c ↔ CovenantStable c := by
  unfold driftReflectionContribution CovenantStable
  constructor <;> intro h <;> linarith

/-- Conditional kernel of
`proposition:bk5_reflective_drift_alignment_in_map`: when restorative
strength exceeds the drift burden, mutual reflection makes a strictly
positive contribution in the scalar alignment model. -/
theorem reflective_drift_alignment_positive (c : CovenantSnapshot)
    (h : CovenantStable c) : 0 < driftReflectionContribution c :=
  (driftReflectionContribution_pos_iff c).2 h

/-- Positive polarity and coupling above an unrelated critical constant do
not suffice: without a drift bound, the net contribution may be negative. -/
theorem positive_coupling_above_critical_insufficient :
    ∃ (c : CovenantSnapshot) (κcrit : ℝ),
      0 < c.stability ∧ κcrit < c.minCoupling ∧
        ¬ 0 < driftReflectionContribution c := by
  refine ⟨{ stability := 1, driftA := 2, driftB := 2, minCoupling := 2 },
    1, by norm_num, by norm_num, ?_⟩
  norm_num [driftReflectionContribution]

end ForcingAnalysis.Book5