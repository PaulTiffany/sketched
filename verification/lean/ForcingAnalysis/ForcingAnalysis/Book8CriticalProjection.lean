/- Book8CriticalProjection.lean — metric degeneracy at a projection transition. -/
import Mathlib

namespace ForcingAnalysis.Book8CriticalProjection

open Matrix

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The source's operational criterion: a projection transition is metric
degeneracy of the observer's hypothesis geometry. -/
def IsProjectionTransition (g : Matrix n n ℝ) : Prop :=
  g.det = 0

/-- With the source criterion made explicit, the critical locus is exactly the
zero-determinant locus. -/
theorem projectionTransition_iff_det_eq_zero (g : Matrix n n ℝ) :
    IsProjectionTransition g ↔ g.det = 0 :=
  Iff.rfl

/-- When symbolic Fisher information is identified with the hypothesis metric,
the projection transition makes the Fisher tensor singular. -/
theorem fisher_singular_of_projection_transition
    {g fisher : Matrix n n ℝ} (hfisher : fisher = g)
    (hcritical : IsProjectionTransition g) :
    fisher.det = 0 := by
  simpa [hfisher, IsProjectionTransition] using hcritical

/-- RG-invariant preservation is not a consequence of determinant degeneracy;
it is a distinct transport condition consumed by the complete certificate. -/
theorem criticalProjection_certificate
    {g fisher : Matrix n n ℝ} {RGInvariantPreserved : Prop}
    (hfisher : fisher = g) (hcritical : IsProjectionTransition g)
    (hRG : RGInvariantPreserved) :
    fisher.det = 0 ∧ RGInvariantPreserved :=
  ⟨fisher_singular_of_projection_transition hfisher hcritical, hRG⟩

/-- A singular metric supplies a flat/degenerate direction criterion, but by
itself cannot force an unrelated structural-emergence predicate. -/
theorem singularity_alone_does_not_force_structural_emergence :
    ∃ (g : Matrix (Fin 1) (Fin 1) ℝ)
      (StructuralEmergence : Matrix (Fin 1) (Fin 1) ℝ → Prop),
      g.det = 0 ∧ ¬ StructuralEmergence g := by
  exact ⟨0, fun _ => False, by simp, by simp⟩

/-- The source's enabling conclusion is valid once the projective-drift bridge
from Fisher singularity to structural emergence is supplied explicitly. -/
theorem structuralEmergence_of_fisher_singular
    {g fisher : Matrix n n ℝ}
    {StructuralEmergence : Matrix n n ℝ → Prop}
    (hfisher : fisher = g) (hcritical : IsProjectionTransition g)
    (projectiveDriftBridge : fisher.det = 0 → StructuralEmergence fisher) :
    StructuralEmergence fisher :=
  projectiveDriftBridge
    (fisher_singular_of_projection_transition hfisher hcritical)

end ForcingAnalysis.Book8CriticalProjection
