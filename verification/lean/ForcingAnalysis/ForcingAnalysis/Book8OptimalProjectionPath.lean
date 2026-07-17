/- Book8OptimalProjectionPath.lean — constrained finite path optimization. -/
import Mathlib

namespace ForcingAnalysis.Book8OptimalProjectionPath

/-- Candidate paths satisfying both the coupled SR dynamics and observer
curvature bound. -/
noncomputable def admissiblePaths {Path : Type*}
    (candidates : Finset Path) (dynamicsFeasible curvatureFeasible : Path → Prop) :
    Finset Path := by
  classical
  exact candidates.filter fun path => dynamicsFeasible path ∧ curvatureFeasible path

def IsUtilityMaximizer {Path : Type*}
    (paths : Finset Path) (utility : Path → ℝ) (path : Path) : Prop :=
  path ∈ paths ∧ ∀ alternative ∈ paths, utility alternative ≤ utility path

/-- Every nonempty finite constrained path inventory has a utility maximizer. -/
theorem exists_optimal_projection_path {Path : Type*}
    (candidates : Finset Path) (dynamicsFeasible curvatureFeasible : Path → Prop)
    (utility : Path → ℝ)
    (hnonempty :
      (admissiblePaths candidates dynamicsFeasible curvatureFeasible).Nonempty) :
    ∃ path, IsUtilityMaximizer
      (admissiblePaths candidates dynamicsFeasible curvatureFeasible) utility path := by
  obtain ⟨path, hpath, hmax⟩ :=
    (admissiblePaths candidates dynamicsFeasible curvatureFeasible).exists_max_image
      utility hnonempty
  exact ⟨path, hpath, hmax⟩

/-- A selected constrained maximizer satisfies both source constraints. -/
theorem optimal_path_satisfies_constraints {Path : Type*}
    {candidates : Finset Path} {dynamicsFeasible curvatureFeasible : Path → Prop}
    {utility : Path → ℝ} {path : Path}
    (hoptimal : IsUtilityMaximizer
      (admissiblePaths candidates dynamicsFeasible curvatureFeasible) utility path) :
    dynamicsFeasible path ∧ curvatureFeasible path := by
  classical
  exact (Finset.mem_filter.mp hoptimal.1).2

/-- Constraints do not guarantee that any admissible path exists. -/
theorem constraints_can_leave_no_admissible_path :
    admissiblePaths ({true} : Finset Bool) (fun _ => False) (fun _ => True) = ∅ := by
  classical
  simp [admissiblePaths]

/-- Maximization of an arbitrary utility does not force an unrelated geodesic
predicate. The metric/action bridge is logically necessary. -/
theorem utility_maximizer_need_not_be_geodesic :
    ∃ utility : Bool → ℝ, ∃ path : Bool,
      IsUtilityMaximizer ({true} : Finset Bool) utility path ∧
        ¬ (path = false) := by
  refine ⟨fun _ => 0, true, ?_, by decide⟩
  constructor
  · simp
  · simp

/-- Once the variational bridge is supplied, maximality transports to the
geodesic conclusion without silently identifying the two notions. -/
theorem maximizer_is_geodesic_of_variational_bridge {Path : Type*}
    {paths : Finset Path} {utility : Path → ℝ} {geodesic : Path → Prop}
    {path : Path} (hmax : IsUtilityMaximizer paths utility path)
    (bridge : ∀ candidate, IsUtilityMaximizer paths utility candidate →
      geodesic candidate) :
    geodesic path :=
  bridge path hmax

end ForcingAnalysis.Book8OptimalProjectionPath
