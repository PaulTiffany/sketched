/-
Book3WellPosedness.lean — constructive static kernel for symbolic-membrane
well-posedness in Principia Symbolica Book 3.
-/
import Mathlib
import ForcingAnalysis.Book3

namespace ForcingAnalysis.Book3

/-- A canonical static membrane at any positive perturbation budget. The
Hamiltonian-derived stability value follows the construction proposed in the
source proof. This does not manufacture the omitted submanifold geometry. -/
noncomputable def canonicalMembrane
    (delta alpha H : ℝ) (hDelta : 0 < delta) : Membrane where
  driftDeviation := 0
  driftBound := delta
  driftBound_pos := hDelta
  driftDeviation_le := hDelta.le
  permeability := 0
  permeability_nonneg := le_rfl
  permeability_le_one := by norm_num
  stability := Real.exp (-alpha * H)
  stability_nonneg := (Real.exp_pos _).le

/-- Static well-posedness kernel: every positive drift budget admits data
satisfying all numeric membrane invariants, with the source's exponential
stability construction. -/
theorem exists_static_membrane
    (delta alpha H : ℝ) (hDelta : 0 < delta) :
    ∃ m : Membrane,
      m.driftBound = delta ∧
      m.driftDeviation = 0 ∧
      m.permeability = 0 ∧
      m.stability = Real.exp (-alpha * H) := by
  exact ⟨canonicalMembrane delta alpha H hDelta, rfl, rfl, rfl, rfl⟩

/-- The constructed stability functional is strictly positive, a stronger
fact than the nonnegativity required by the static membrane interface. -/
theorem canonicalMembrane_stability_pos
    (delta alpha H : ℝ) (hDelta : 0 < delta) :
    0 < (canonicalMembrane delta alpha H hDelta).stability := by
  exact Real.exp_pos _

/-- Smallness is not needed for consistency of the numeric structure: any
smaller positive budget also has a canonical witness. -/
theorem exists_static_membrane_at_smaller_bound
    {delta small alpha H : ℝ} (hSmall : 0 < small) (hLe : small ≤ delta) :
    ∃ m : Membrane, m.driftBound = small ∧ m.driftBound ≤ delta := by
  refine ⟨canonicalMembrane small alpha H hSmall, rfl, ?_⟩
  change small ≤ delta
  exact hLe

end ForcingAnalysis.Book3
