/- Book6ThermodynamicMAP.lean — mean-force/reflection balance at MAP equilibrium. -/
import Mathlib

namespace ForcingAnalysis.Book6ThermodynamicMAP

structure MeanBalance where
  meanDrift : ℝ
  inverseTemperature : ℝ
  meanProjectedGradient : ℝ
  meanReflectionDeviation : ℝ

def dualityResidual (b : MeanBalance) : ℝ :=
  b.meanDrift -
    (b.inverseTemperature * b.meanProjectedGradient +
      b.meanReflectionDeviation)

def ThermodynamicMAPDuality (b : MeanBalance) : Prop :=
  b.meanDrift =
    b.inverseTemperature * b.meanProjectedGradient +
      b.meanReflectionDeviation

/-- The displayed thermodynamic–MAP equation is exactly vanishing of its
oriented balance residual. -/
theorem duality_iff_residual_zero (b : MeanBalance) :
    ThermodynamicMAPDuality b ↔ dualityResidual b = 0 := by
  rw [ThermodynamicMAPDuality, dualityResidual]
  constructor <;> intro h <;> linarith

/-- The reflective deviation is the drift left after subtracting the
temperature-weighted projected force. -/
theorem reflectionDeviation_eq
    (b : MeanBalance) (h : ThermodynamicMAPDuality b) :
    b.meanReflectionDeviation =
      b.meanDrift - b.inverseTemperature * b.meanProjectedGradient := by
  rw [ThermodynamicMAPDuality] at h
  linarith

/-- Conversely, the residual reflection equation reconstructs the printed
mean-drift balance without changing orientation or sign. -/
theorem duality_of_reflectionDeviation_eq
    (b : MeanBalance)
    (h : b.meanReflectionDeviation =
      b.meanDrift - b.inverseTemperature * b.meanProjectedGradient) :
    ThermodynamicMAPDuality b := by
  rw [ThermodynamicMAPDuality]
  linarith

structure EquilibriumFlags where
  stationary : Prop
  massConserved : Prop
  powerConserved : Prop
  timeIrreversible : Prop
  laplaceExtensionCoherent : Prop

def AllFlags (f : EquilibriumFlags) : Prop :=
  f.stationary ∧ f.massConserved ∧ f.powerConserved ∧
    f.timeIrreversible ∧ f.laplaceExtensionCoherent

/-- Qualitative equilibrium/conservation flags do not determine the displayed
constitutive balance or its signs and coefficients. -/
theorem equilibrium_flags_alone_do_not_force_duality :
    ∃ flags : EquilibriumFlags, ∃ balance : MeanBalance,
      AllFlags flags ∧ ¬ ThermodynamicMAPDuality balance := by
  refine ⟨⟨True, True, True, True, True⟩, ⟨0, 1, 1, 0⟩, ?_, ?_⟩
  · simp [AllFlags]
  · norm_num [ThermodynamicMAPDuality]

end ForcingAnalysis.Book6ThermodynamicMAP
