/- Book9CurvatureScarring.lean — betrayal displacement, repair resources, and revised reciprocity. -/
import Mathlib

namespace ForcingAnalysis.Book9CurvatureScarring

/-- An oriented curvature scar.  The betrayal drift is retained as a witness
rather than collapsed prematurely to an unsigned magnitude. -/
structure CurvatureScar where
  baselineCurvature : ℝ
  scarredCurvature : ℝ
  betrayalDrift : ℝ
  betrayalDrift_nonneg : 0 ≤ betrayalDrift
  scar_law : scarredCurvature = baselineCurvature + betrayalDrift

def scarMagnitude (s : CurvatureScar) : ℝ :=
  |s.scarredCurvature - s.baselineCurvature|

theorem oriented_displacement_eq_betrayalDrift (s : CurvatureScar) :
    s.scarredCurvature - s.baselineCurvature = s.betrayalDrift := by
  rw [s.scar_law]
  ring

theorem scarMagnitude_eq_betrayalDrift (s : CurvatureScar) :
    scarMagnitude s = s.betrayalDrift := by
  rw [scarMagnitude, oriented_displacement_eq_betrayalDrift, abs_of_nonneg]
  exact s.betrayalDrift_nonneg

/-- The explicit capacity/free-energy threshold narrated by the source. -/
structure RepairResources where
  reflectiveCapacity : ℝ
  availableFreeEnergy : ℝ
  repairCost : ℝ
  capacity_nonneg : 0 ≤ reflectiveCapacity
  energy_nonneg : 0 ≤ availableFreeEnergy
  cost_nonneg : 0 ≤ repairCost

def ResourceAdmissible (s : CurvatureScar) (r : RepairResources) : Prop :=
  s.betrayalDrift ≤ r.reflectiveCapacity ∧
    r.repairCost ≤ r.availableFreeEnergy

/-- The missing operational bridge: grace plus adequate resources is exactly
what enables establishment of a revised reciprocity domain. -/
structure RecoveryLaw (s : CurvatureScar) (r : RepairResources) where
  graceApplied : Prop
  revisedReciprocity : Prop
  reestablishes_iff : revisedReciprocity ↔
    graceApplied ∧ ResourceAdmissible s r

theorem revisedReciprocity_iff_grace_and_resources
    (s : CurvatureScar) (r : RepairResources) (law : RecoveryLaw s r) :
    law.revisedReciprocity ↔
      law.graceApplied ∧
        s.betrayalDrift ≤ r.reflectiveCapacity ∧
        r.repairCost ≤ r.availableFreeEnergy := by
  simpa [ResourceAdmissible, and_assoc] using law.reestablishes_iff

theorem recovery_of_grace_capacity_and_energy
    (s : CurvatureScar) (r : RepairResources) (law : RecoveryLaw s r)
    (hgrace : law.graceApplied)
    (hcapacity : s.betrayalDrift ≤ r.reflectiveCapacity)
    (henergy : r.repairCost ≤ r.availableFreeEnergy) :
    law.revisedReciprocity := by
  exact law.reestablishes_iff.mpr ⟨hgrace, hcapacity, henergy⟩

/-- Recovery creates a new viable relation; it need not erase structural memory.
This concrete recovered state retains a strictly positive curvature scar. -/
theorem recovery_can_retain_permanent_scar :
    ∃ s : CurvatureScar, ∃ r : RepairResources, ∃ law : RecoveryLaw s r,
      law.revisedReciprocity ∧ 0 < scarMagnitude s := by
  let s : CurvatureScar := ⟨0, 2, 2, by norm_num, by norm_num⟩
  let r : RepairResources := ⟨2, 1, 1, by norm_num, by norm_num, by norm_num⟩
  let law : RecoveryLaw s r :=
    ⟨True, True, by norm_num [ResourceAdmissible, s, r]⟩
  refine ⟨s, r, law, by simp [law], ?_⟩
  norm_num [scarMagnitude, s]

/-- Negative control: sufficient numerical resources do not themselves apply
grace or construct a new reciprocity domain. -/
theorem resources_alone_do_not_force_recovery :
    ∃ s : CurvatureScar, ∃ r : RepairResources,
      ResourceAdmissible s r ∧
      ∃ graceApplied revisedReciprocity : Prop,
        ¬ graceApplied ∧ ¬ revisedReciprocity := by
  let s : CurvatureScar := ⟨0, 1, 1, by norm_num, by norm_num⟩
  let r : RepairResources := ⟨1, 1, 1, by norm_num, by norm_num, by norm_num⟩
  exact ⟨s, r, by norm_num [ResourceAdmissible, s, r], False, False,
    by simp⟩

end ForcingAnalysis.Book9CurvatureScarring
