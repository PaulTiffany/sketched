/- Book7FrameMeasure.lean — finite non-contextual frame gluing. -/
import ForcingAnalysis.Book7BornCollapse

namespace ForcingAnalysis.Book7FrameMeasure

open Book7BornCollapse

/-- Local finite measurement frames whose readouts agree whenever an outcome is
visible in two frames. Coverage and overlap agreement are the constructive
content of finite non-contextual gluing. -/
structure FrameReadoutSystem (Frame Outcome : Type*) [DecidableEq Outcome] where
  outcomes : Frame → Finset Outcome
  value : Frame → Outcome → ℝ
  covered : ∀ outcome, ∃ frame, outcome ∈ outcomes frame
  nonnegative : ∀ frame outcome, outcome ∈ outcomes frame → 0 ≤ value frame outcome
  normalized : ∀ frame, ∑ outcome ∈ outcomes frame, value frame outcome = 1
  noncontextual : ∀ first second outcome,
    outcome ∈ outcomes first → outcome ∈ outcomes second →
      value first outcome = value second outcome

noncomputable def FrameReadoutSystem.chosenFrame
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome) (outcome : Outcome) : Frame :=
  Classical.choose (system.covered outcome)

theorem FrameReadoutSystem.chosenFrame_mem
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome) (outcome : Outcome) :
    outcome ∈ system.outcomes (system.chosenFrame outcome) :=
  Classical.choose_spec (system.covered outcome)

/-- The global readout chooses any covering frame. Non-contextuality will prove
that the result is independent of this choice. -/
noncomputable def FrameReadoutSystem.globalValue
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome) (outcome : Outcome) : ℝ :=
  system.value (system.chosenFrame outcome) outcome

/-- Every local frame readout is the restriction of the constructed global
assignment. -/
theorem FrameReadoutSystem.globalValue_eq_local
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome)
    {frame : Frame} {outcome : Outcome}
    (hmember : outcome ∈ system.outcomes frame) :
    system.globalValue outcome = system.value frame outcome := by
  unfold FrameReadoutSystem.globalValue
  exact system.noncontextual _ _ outcome
    (system.chosenFrame_mem outcome) hmember

/-- The glued global assignment is nonnegative on every covered outcome. -/
theorem FrameReadoutSystem.globalValue_nonnegative
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome) (outcome : Outcome) :
    0 ≤ system.globalValue outcome := by
  rw [system.globalValue_eq_local (system.chosenFrame_mem outcome)]
  exact system.nonnegative _ outcome (system.chosenFrame_mem outcome)

/-- Each local frame remains normalized when read through the global
assignment. -/
theorem FrameReadoutSystem.globalValue_normalized_on_frame
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome) (frame : Frame) :
    ∑ outcome ∈ system.outcomes frame, system.globalValue outcome = 1 := by
  calc
    ∑ outcome ∈ system.outcomes frame, system.globalValue outcome =
        ∑ outcome ∈ system.outcomes frame, system.value frame outcome := by
          apply Finset.sum_congr rfl
          intro outcome hmember
          exact system.globalValue_eq_local hmember
    _ = 1 := system.normalized frame

/-- Uniqueness of finite non-contextual gluing: any other global assignment
with the same restrictions equals the constructed one. -/
theorem FrameReadoutSystem.globalValue_unique
    {Frame Outcome : Type*} [DecidableEq Outcome]
    (system : FrameReadoutSystem Frame Outcome)
    (candidate : Outcome → ℝ)
    (hrestrict : ∀ frame outcome, outcome ∈ system.outcomes frame →
      candidate outcome = system.value frame outcome) :
    candidate = system.globalValue := by
  funext outcome
  exact (hrestrict (system.chosenFrame outcome) outcome
    (system.chosenFrame_mem outcome)).trans
      (system.globalValue_eq_local (system.chosenFrame_mem outcome)).symm

/-- If every local restriction is calibrated by the same finite complex
amplitude vector, non-contextual gluing yields the global Born readout. -/
theorem FrameReadoutSystem.globalValue_eq_finiteBorn
    {n : ℕ} {Frame : Type*}
    (system : FrameReadoutSystem Frame (Fin n))
    (amplitude : Fin n → ℂ)
    (hcalibrated : ∀ frame outcome, outcome ∈ system.outcomes frame →
      system.value frame outcome = finiteBornValue amplitude outcome) :
    system.globalValue = finiteBornValue amplitude := by
  funext outcome
  rw [system.globalValue_eq_local (system.chosenFrame_mem outcome)]
  exact hcalibrated _ outcome (system.chosenFrame_mem outcome)

/-- Non-contextual gluing constructs a unique global measure, but without local
amplitude calibration it need not be the Born measure. -/
theorem noncontextual_gluing_alone_does_not_force_born :
    ∃ (system : FrameReadoutSystem Bool (Fin 2)) (amplitude : Fin 2 → ℂ),
      system.globalValue ≠ finiteBornValue amplitude := by
  let outcomes : Bool → Finset (Fin 2) := fun _ => Finset.univ
  let value : Bool → Fin 2 → ℝ := fun _ i => if i = 0 then 0 else 1
  let system : FrameReadoutSystem Bool (Fin 2) := {
    outcomes := outcomes
    value := value
    covered := by intro outcome; exact ⟨false, by simp [outcomes]⟩
    nonnegative := by
      intro frame outcome hmember
      by_cases hzero : outcome = 0 <;> simp [value, hzero]
    normalized := by intro frame; norm_num [outcomes, value, Fin.sum_univ_two]
    noncontextual := by intro first second outcome hfirst hsecond; rfl
  }
  let amplitude : Fin 2 → ℂ := fun i => if i = 0 then 1 else 0
  refine ⟨system, amplitude, ?_⟩
  intro h
  have h0 := congrFun h 0
  rw [system.globalValue_eq_local (frame := false) (outcome := 0)
    (by simp [system, outcomes])] at h0
  norm_num [system, value, finiteBornValue, amplitude] at h0

end ForcingAnalysis.Book7FrameMeasure