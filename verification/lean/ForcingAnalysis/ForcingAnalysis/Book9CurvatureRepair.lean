/- Book9CurvatureRepair.lean — viable repair can optimize rather than flatten curvature. -/
import Mathlib

namespace ForcingAnalysis.Book9CurvatureRepair

structure RepairProfile where
  curvature : ℝ
  tension : ℝ
  localFreeEnergy : ℝ
  resilience : ℝ

/-- A viable repair retains positive curvature while meeting explicit tension
and local-free-energy budgets. -/
def IsViableRepair (τmax Fmax : ℝ) (r : RepairProfile) : Prop :=
  0 < r.curvature ∧ r.tension ≤ τmax ∧ r.localFreeEnergy ≤ Fmax

/-- One transparent resilience-sensitive objective. The source does not specify
weights, so this is an admitted operational instance rather than a canonical
identification. -/
def repairValue (r : RepairProfile) : ℝ :=
  r.resilience - r.tension - r.localFreeEnergy

def IsOptimalViableRepair (candidates : Finset RepairProfile)
    (τmax Fmax : ℝ) (r : RepairProfile) : Prop :=
  r ∈ candidates ∧ IsViableRepair τmax Fmax r ∧
    ∀ alternative ∈ candidates,
      IsViableRepair τmax Fmax alternative →
        repairValue alternative ≤ repairValue r

/-- Every finite inventory with at least one viable repair has an optimal viable
repair for the stated operational objective. -/
theorem exists_optimal_viable_repair
    (candidates : Finset RepairProfile) (τmax Fmax : ℝ)
    (hnonempty : ∃ r ∈ candidates, IsViableRepair τmax Fmax r) :
    ∃ r, IsOptimalViableRepair candidates τmax Fmax r := by
  classical
  let viable := candidates.filter (IsViableRepair τmax Fmax)
  have hviable : viable.Nonempty := by
    obtain ⟨r, hr, hrepair⟩ := hnonempty
    exact ⟨r, Finset.mem_filter.mpr ⟨hr, hrepair⟩⟩
  obtain ⟨r, hr, hmax⟩ := viable.exists_max_image repairValue hviable
  refine ⟨r, (Finset.mem_filter.mp hr).1, (Finset.mem_filter.mp hr).2, ?_⟩
  intro alternative halternative hrepair
  exact hmax alternative (Finset.mem_filter.mpr ⟨halternative, hrepair⟩)

private def flatRepair : RepairProfile :=
  ⟨1, 0, 0, 0⟩

private def resilientRepair : RepairProfile :=
  ⟨2, 0, 0, 1⟩

private noncomputable def repairCandidates : Finset RepairProfile := by
  classical
  exact {flatRepair, resilientRepair}

/-- Concrete negative control for curvature minimization: both repairs are
viable, but the resilience-sensitive optimum deliberately retains more
curvature than the flatter alternative. -/
theorem optimal_repair_need_not_minimize_curvature :
    IsOptimalViableRepair repairCandidates 0 0 resilientRepair ∧
      flatRepair.curvature < resilientRepair.curvature := by
  constructor
  · refine ⟨by simp [repairCandidates], by norm_num [IsViableRepair, resilientRepair], ?_⟩
    intro alternative halternative _
    simp only [repairCandidates, Finset.mem_insert, Finset.mem_singleton] at halternative
    rcases halternative with rfl | rfl <;>
      norm_num [repairValue, flatRepair, resilientRepair]
  · norm_num [flatRepair, resilientRepair]

/-- Viability and positive retained curvature do not select a unique repair;
the optimization policy is additional structure. -/
theorem viability_alone_does_not_determine_repair :
    IsViableRepair 0 0 flatRepair ∧
      IsViableRepair 0 0 resilientRepair ∧ flatRepair ≠ resilientRepair := by
  norm_num [IsViableRepair, flatRepair, resilientRepair]

end ForcingAnalysis.Book9CurvatureRepair
