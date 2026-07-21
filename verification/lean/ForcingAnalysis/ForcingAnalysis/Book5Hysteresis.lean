/-
Book5Hysteresis.lean — stateful two-threshold switching kernel for
Principia Symbolica Book 5's reflective hysteresis corollary.
-/
import Mathlib

namespace ForcingAnalysis.Book5Hysteresis

inductive CovenantMode where
  | map
  | madOrDecoupled
  deriving DecidableEq, Repr

/-- Source-faithful placement of the lower and upper switching thresholds
around the coupling boundary one. -/
structure HysteresisThresholds where
  lower : ℝ
  upper : ℝ
  lower_lt_one : lower < 1
  one_lt_upper : 1 < upper

theorem HysteresisThresholds.lower_lt_upper (thresholds : HysteresisThresholds) :
    thresholds.lower < thresholds.upper := by
  linarith [thresholds.lower_lt_one, thresholds.one_lt_upper]

/-- Stateful Schmitt-style update: outside the band the coupling forces a
regime; inside the band the previous regime is retained. -/
noncomputable def hysteresisStep (thresholds : HysteresisThresholds)
    (coupling : ℝ) (current : CovenantMode) : CovenantMode :=
  if coupling < thresholds.lower then .madOrDecoupled
  else if thresholds.upper < coupling then .map
  else current

theorem below_lower_switches_from_map (thresholds : HysteresisThresholds)
    {coupling : ℝ} (h : coupling < thresholds.lower) :
    hysteresisStep thresholds coupling .map = .madOrDecoupled := by
  simp [hysteresisStep, h]

theorem above_upper_switches_to_map (thresholds : HysteresisThresholds)
    {coupling : ℝ} (h : thresholds.upper < coupling) :
    hysteresisStep thresholds coupling .madOrDecoupled = .map := by
  have hNotLow : ¬ coupling < thresholds.lower := by
    exact not_lt.mpr (le_trans (le_of_lt thresholds.lower_lt_upper) (le_of_lt h))
  simp [hysteresisStep, h, hNotLow]

theorem map_persists_in_band (thresholds : HysteresisThresholds)
    {coupling : ℝ} (hLow : thresholds.lower ≤ coupling)
    (hHigh : coupling ≤ thresholds.upper) :
    hysteresisStep thresholds coupling .map = .map := by
  simp [hysteresisStep, not_lt.mpr hLow, not_lt.mpr hHigh]

theorem mad_persists_in_band (thresholds : HysteresisThresholds)
    {coupling : ℝ} (hLow : thresholds.lower ≤ coupling)
    (hHigh : coupling ≤ thresholds.upper) :
    hysteresisStep thresholds coupling .madOrDecoupled = .madOrDecoupled := by
  simp [hysteresisStep, not_lt.mpr hLow, not_lt.mpr hHigh]

/-- The same coupling inside the band has different outcomes according to
the incoming regime: this is the operational history dependence. -/
theorem in_band_remembers_history (thresholds : HysteresisThresholds)
    {coupling : ℝ} (hLow : thresholds.lower ≤ coupling)
    (hHigh : coupling ≤ thresholds.upper) :
    hysteresisStep thresholds coupling .map ≠
      hysteresisStep thresholds coupling .madOrDecoupled := by
  rw [map_persists_in_band thresholds hLow hHigh,
      mad_persists_in_band thresholds hLow hHigh]
  decide

/-- A memoryless regime classifier cannot express two outcomes at the same
coupling. The prior-state argument in `hysteresisStep` is load-bearing. -/
theorem memoryless_classifier_cannot_remember_history :
    ¬ ∃ classify : ℝ → CovenantMode,
      classify 1 = .map ∧ classify 1 = .madOrDecoupled := by
  rintro ⟨classify, hMap, hMad⟩
  rw [hMap] at hMad
  contradiction


/-! ### Activation-barrier construction and path memory -/

/-- A positive half-width around the neutral coupling value constructs the two
switching thresholds rather than postulating their separation independently. -/
structure ActivationBarrier where
  halfWidth : ℝ
  halfWidth_pos : 0 < halfWidth
  density : ℝ
  density_pos : 0 < density

noncomputable def ActivationBarrier.thresholds (B : ActivationBarrier) :
    HysteresisThresholds where
  lower := 1 - B.halfWidth
  upper := 1 + B.halfWidth
  lower_lt_one := by linarith [B.halfWidth_pos]
  one_lt_upper := by linarith [B.halfWidth_pos]

noncomputable def ActivationBarrier.energy (B : ActivationBarrier) : ℝ :=
  B.density * (B.thresholds.upper - B.thresholds.lower)

theorem ActivationBarrier.threshold_gap (B : ActivationBarrier) :
    B.thresholds.upper - B.thresholds.lower = 2 * B.halfWidth := by
  unfold ActivationBarrier.thresholds
  ring

theorem ActivationBarrier.energy_eq (B : ActivationBarrier) :
    B.energy = 2 * B.density * B.halfWidth := by
  rw [ActivationBarrier.energy, B.threshold_gap]
  ring

theorem ActivationBarrier.energy_pos (B : ActivationBarrier) :
    0 < B.energy := by
  rw [B.energy_eq]
  exact mul_pos (mul_pos (by norm_num) B.density_pos) B.halfWidth_pos

/-- Execute a finite coupling history through the stateful transition law. -/
noncomputable def runHysteresis (thresholds : HysteresisThresholds)
    (initial : CovenantMode) (history : List ℝ) : CovenantMode :=
  history.foldl (fun mode coupling => hysteresisStep thresholds coupling mode) initial

theorem runHysteresis_in_band (thresholds : HysteresisThresholds)
    (initial : CovenantMode) (history : List ℝ)
    (hband : ∀ coupling ∈ history,
      thresholds.lower ≤ coupling ∧ coupling ≤ thresholds.upper) :
    runHysteresis thresholds initial history = initial := by
  induction history generalizing initial with
  | nil => rfl
  | cons coupling rest ih =>
      simp only [runHysteresis, List.foldl_cons]
      have hc := hband coupling (by simp)
      have hstep : hysteresisStep thresholds coupling initial = initial := by
        cases initial
        · exact map_persists_in_band thresholds hc.1 hc.2
        · exact mad_persists_in_band thresholds hc.1 hc.2
      rw [hstep]
      apply ih
      intro x hx
      exact hband x (by simp [hx])

/-- Two systems exposed to the same entirely in-band history retain distinct
incoming regimes. Hysteresis is therefore path-state memory, not a one-point
classifier artifact. -/
theorem same_in_band_path_retains_distinct_histories
    (thresholds : HysteresisThresholds) (history : List ℝ)
    (hband : ∀ coupling ∈ history,
      thresholds.lower ≤ coupling ∧ coupling ≤ thresholds.upper) :
    runHysteresis thresholds .map history ≠
      runHysteresis thresholds .madOrDecoupled history := by
  rw [runHysteresis_in_band thresholds .map history hband,
      runHysteresis_in_band thresholds .madOrDecoupled history hband]
  decide

end ForcingAnalysis.Book5Hysteresis
