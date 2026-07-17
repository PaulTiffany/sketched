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

end ForcingAnalysis.Book5Hysteresis
