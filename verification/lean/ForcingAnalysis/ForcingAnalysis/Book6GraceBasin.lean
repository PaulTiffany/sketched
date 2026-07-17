/- Book6GraceBasin.lean — grace preserves covered regulatory basins. -/
import Mathlib

namespace ForcingAnalysis.Book6GraceBasin

variable {State Center : Type*}

def RegulatoryUnion (centers : Set Center) (basin : Center → Set State) : Set State :=
  ⋃ q ∈ centers, basin q

/-- The source conclusion follows from two operational premises: every
subcritical state is covered by some regulatory basin, and grace maps each
admitted basin into itself. -/
theorem grace_mem_regulatoryUnion
    (centers : Set Center) (basin : Center → Set State)
    (grace : State → State) (incoherence : State → ℝ) (critical : ℝ)
    (subcriticalCovered : ∀ p, incoherence p < critical →
      ∃ q ∈ centers, p ∈ basin q)
    (graceInvariant : ∀ q ∈ centers, Set.MapsTo grace (basin q) (basin q))
    {p : State} (hsubcritical : incoherence p < critical) :
    grace p ∈ RegulatoryUnion centers basin := by
  obtain ⟨q, hq, hp⟩ := subcriticalCovered p hsubcritical
  exact Set.mem_iUnion₂.mpr ⟨q, hq, graceInvariant q hq hp⟩

/-- Basin membership is preserved for a named regulatory center. -/
theorem grace_stays_in_basin
    {basin : Center → Set State} {grace : State → State}
    {q : Center} (graceInvariant : Set.MapsTo grace (basin q) (basin q))
    {p : State} (hp : p ∈ basin q) :
    grace p ∈ basin q :=
  graceInvariant hp

/-- A threshold inequality alone cannot create the missing basin-coverage
witness: take every regulatory basin to be empty. -/
theorem subcriticality_alone_does_not_force_basin_membership :
    ∃ (centers : Set Unit) (basin : Unit → Set Bool)
      (grace : Bool → Bool) (incoherence : Bool → ℝ) (critical : ℝ) (p : Bool),
      incoherence p < critical ∧
        grace p ∉ RegulatoryUnion centers basin := by
  refine ⟨Set.univ, fun _ => ∅, id, fun _ => 0, 1, false, by norm_num, ?_⟩
  simp [RegulatoryUnion]

/-- If coverage is known only for the pre-grace state but basin invariance is
not supplied, grace can leave every regulatory basin. -/
theorem coverage_without_invariance_does_not_force_grace_membership :
    ∃ (centers : Set Unit) (basin : Unit → Set Bool) (grace : Bool → Bool)
      (p : Bool),
      p ∈ RegulatoryUnion centers basin ∧
        grace p ∉ RegulatoryUnion centers basin := by
  refine ⟨Set.univ, fun _ => {false}, not, false, ?_⟩
  simp [RegulatoryUnion]

end ForcingAnalysis.Book6GraceBasin
