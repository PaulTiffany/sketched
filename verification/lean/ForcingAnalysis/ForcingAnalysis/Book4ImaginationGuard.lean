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


/-- Signed phase displacement may cancel even though the traversal retained
nonzero exposure. The signed projection and the exposure budget therefore
serve different purposes. -/
def signedPhase {Observable : Type*} (traversal : Traversal Observable) : ℝ :=
  traversal.phaseSegments.sum

theorem opposite_phases_cancel_projection_not_exposure (observable : Unit) (a : ℝ)
    (ha : a ≠ 0) :
    let traversal : Traversal Unit := ⟨observable, [a, -a], 0, 0⟩
    signedPhase traversal = 0 ∧ 0 < phaseBudget traversal := by
  dsimp [signedPhase, phaseBudget]
  constructor
  · ring
  · rw [abs_neg]
    have hpos : 0 < |a| := abs_pos.mpr ha
    linarith

/-- A calibrated phase-to-rate response. Unlike `effectiveRate`, the response
need not be linear. Its supplied affine envelope is the certificate that makes
it usable by the contraction guard. -/
structure PhaseRateLaw where
  rate : ℝ → ℝ
  baseRate : ℝ
  sensitivityBound : ℝ
  sensitivity_nonneg : 0 ≤ sensitivityBound
  rate_zero : rate 0 = baseRate
  rate_le_envelope : ∀ exposure, 0 ≤ exposure →
    rate exposure ≤ baseRate + sensitivityBound * exposure

/-- Evaluate the constructed response on the retained traversal exposure. -/
def certifiedRate {Observable : Type*} (law : PhaseRateLaw)
    (traversal : Traversal Observable) : ℝ :=
  law.rate (phaseBudget traversal)

theorem phaseBudget_nonneg {Observable : Type*} (traversal : Traversal Observable) :
    0 ≤ phaseBudget traversal := by
  unfold phaseBudget
  apply List.sum_nonneg
  intro x hx
  rcases List.mem_map.mp hx with ⟨a, ha, rfl⟩
  exact abs_nonneg a

/-- The calibrated response remains contractive whenever its certified
exposure envelope fits inside the unused contraction margin. -/
theorem certifiedRate_lt_one_of_penalty_below_margin
    {Observable : Type*} (law : PhaseRateLaw) (traversal : Traversal Observable)
    (hmargin : law.sensitivityBound * phaseBudget traversal < 1 - law.baseRate) :
    certifiedRate law traversal < 1 := by
  have hbound := law.rate_le_envelope (phaseBudget traversal)
    (phaseBudget_nonneg traversal)
  unfold certifiedRate
  linarith

/-- The earlier linear guard is recovered as one particular calibrated law,
not assumed to be the unique phase response. -/
def linearPhaseRateLaw (base sensitivity : ℝ) (hsensitivity : 0 ≤ sensitivity) :
    PhaseRateLaw where
  rate exposure := base + sensitivity * exposure
  baseRate := base
  sensitivityBound := sensitivity
  sensitivity_nonneg := hsensitivity
  rate_zero := by ring
  rate_le_envelope := by intro exposure hexposure; rfl

theorem linearPhaseRateLaw_recovers_effectiveRate
    {Observable : Type*} (traversal : Traversal Observable)
    (hsensitivity : 0 ≤ traversal.phaseSensitivity) :
    certifiedRate
        (linearPhaseRateLaw traversal.baseRate traversal.phaseSensitivity hsensitivity)
        traversal = effectiveRate traversal := by
  rfl

/-- Even a perfectly calibrated zero-exposure value does not determine the
response away from zero. This prevents the base contraction rate from being
mistaken for a phase-sensitivity law. -/
theorem zero_calibration_alone_does_not_determine_rate :
    ∃ first second : PhaseRateLaw,
      first.baseRate = second.baseRate ∧
      first.rate 0 = second.rate 0 ∧
      first.rate 1 ≠ second.rate 1 := by
  let first := linearPhaseRateLaw 0 0 (by norm_num)
  let second := linearPhaseRateLaw 0 1 (by norm_num)
  refine ⟨first, second, rfl, ?_, ?_⟩
  · norm_num [first, second, linearPhaseRateLaw]
  · norm_num [first, second, linearPhaseRateLaw]

end ForcingAnalysis.Book4ImaginationGuard
