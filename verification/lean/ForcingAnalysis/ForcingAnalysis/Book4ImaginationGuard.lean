/- Book4ImaginationGuard.lean — phase-aware reintegration and contraction guard. -/
import Mathlib

namespace ForcingAnalysis.Book4ImaginationGuard

/-- A traversal retains its observable projection and the complete list of
phase-bearing intermediate steps. -/
structure Traversal (Observable : Type*) where
  observable : Observable
  phaseSegments : List ℝ
  baseRate : ℝ
  phaseSensitivity : ℝ

def observableProjection {Observable : Type*} (traversal : Traversal Observable) :
    Observable :=
  traversal.observable

/-- Total phase exposure retains cancellations instead of flattening them
before reintegration. -/
def phaseBudget {Observable : Type*} (traversal : Traversal Observable) : ℝ :=
  (traversal.phaseSegments.map (fun phase => |phase|)).sum

/-- Phase/interface exposure consumes contraction margin. -/
def effectiveRate {Observable : Type*} (traversal : Traversal Observable) : ℝ :=
  traversal.baseRate + traversal.phaseSensitivity * phaseBudget traversal

/-- Reintegration is admitted only when both the phase budget and the effective
rate remain inside their strict safety margins. -/
def ReintegrationGuard {Observable : Type*} (phaseTolerance : ℝ)
    (traversal : Traversal Observable) : Prop :=
  phaseBudget traversal < phaseTolerance ∧ effectiveRate traversal < 1

/-- Concatenating traversal witnesses adds their phase budgets; intermediate
opposite phases are not erased before their exposure is counted. -/
theorem phaseBudget_append {Observable : Type*} (observable : Observable)
    (first second : List ℝ) (base sensitivity : ℝ) :
    phaseBudget (Traversal.mk observable (first ++ second) base sensitivity) =
      phaseBudget (Traversal.mk observable first base sensitivity) +
        phaseBudget (Traversal.mk observable second base sensitivity) := by
  simp [phaseBudget]

/-- The phase-bearing traversal remains contractive exactly while its phase
penalty stays below the unused base contraction margin. -/
theorem effectiveRate_lt_one_iff_phase_penalty_below_margin
    {Observable : Type*} (traversal : Traversal Observable) :
    effectiveRate traversal < 1 ↔
      traversal.phaseSensitivity * phaseBudget traversal <
        1 - traversal.baseRate := by
  unfold effectiveRate
  constructor <;> intro h <;> linarith

/-- An eleven-percent phase exposure ends strict contraction when the base
rate has already consumed eighty-nine percent of the margin. -/
theorem eleven_percent_phase_ends_near_boundary_contraction
    {baseRate : ℝ} (hbase : 89 / 100 ≤ baseRate) :
    let traversal : Traversal Unit :=
      ⟨(), [11 / 100], baseRate, 1⟩
    ¬ effectiveRate traversal < 1 := by
  dsimp [effectiveRate, phaseBudget]
  norm_num at hbase ⊢
  linarith

/-- Observable equality alone cannot certify imaginative reintegration: two
traversals may project to the same token while only one remains contractive. -/
theorem projection_equality_can_hide_unsafe_phase :
    ∃ safe unsafeTraversal : Traversal Bool,
      observableProjection safe = observableProjection unsafeTraversal ∧
      ReintegrationGuard 1 safe ∧ ¬ ReintegrationGuard 1 unsafeTraversal := by
  refine ⟨⟨true, [], 89 / 100, 1⟩,
    ⟨true, [11 / 100], 89 / 100, 1⟩, ?_⟩
  norm_num [observableProjection, ReintegrationGuard, phaseBudget, effectiveRate]

end ForcingAnalysis.Book4ImaginationGuard
