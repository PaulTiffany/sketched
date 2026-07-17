/- Book6ThermodynamicConsistency.lean — free-energy differential balance kernel. -/
import ForcingAnalysis.Book6

namespace ForcingAnalysis.Book6ThermodynamicConsistency

/-- Exact finite-increment identity for `F = E - T*S` at fixed temperature. -/
theorem fixed_temperature_freeEnergy_increment
    (energy temperature entropy dEnergy dEntropy : ℝ) :
    Book6.freeEnergyOf (energy + dEnergy) temperature (entropy + dEntropy) -
      Book6.freeEnergyOf energy temperature entropy =
        dEnergy - temperature * dEntropy := by
  unfold Book6.freeEnergyOf
  ring

/-- If the energy increment obeys the ordinary first-law balance, the entropy
term cancels from the fixed-temperature free-energy increment. -/
theorem fixed_temperature_firstLaw_reduction
    (energy temperature entropy dEnergy dEntropy pressure dVolume
      chemicalWork : ℝ)
    (henergy : dEnergy =
      temperature * dEntropy - pressure * dVolume + chemicalWork) :
    Book6.freeEnergyOf (energy + dEnergy) temperature (entropy + dEntropy) -
      Book6.freeEnergyOf energy temperature entropy =
        -pressure * dVolume + chemicalWork := by
  rw [fixed_temperature_freeEnergy_increment, henergy]
  ring

/-- When temperature changes as well, the exact finite increment contains the
additional temperature/entropy terms. -/
theorem varying_temperature_freeEnergy_increment
    (energy temperature entropy dEnergy dTemperature dEntropy : ℝ) :
    Book6.freeEnergyOf (energy + dEnergy) (temperature + dTemperature)
        (entropy + dEntropy) -
      Book6.freeEnergyOf energy temperature entropy =
        dEnergy - temperature * dEntropy - dTemperature * entropy -
          dTemperature * dEntropy := by
  unfold Book6.freeEnergyOf
  ring

/-- The printed positive `T*dS` free-energy law is not implied by the source's
own definition: increasing entropy at fixed energy and positive temperature
decreases, rather than increases, free energy. -/
theorem printed_firstLaw_not_implied_by_freeEnergy_definition :
    Book6.freeEnergyOf 0 1 1 - Book6.freeEnergyOf 0 1 0 ≠
      1 * (1 - 0) := by
  norm_num [Book6.freeEnergyOf]

/-- An orientation-parameterized thermodynamic potential. The entropy sign is
derived from the chosen potential orientation rather than selected by a
verifier. The source free energy is the specialization `orientation = -1`. -/
def orientedFreeEnergy (orientation energy temperature entropy : ℝ) : ℝ :=
  energy + orientation * temperature * entropy

theorem oriented_freeEnergy_fixed_temperature_increment
    (orientation energy temperature entropy dEnergy dEntropy : ℝ) :
    orientedFreeEnergy orientation (energy + dEnergy) temperature
        (entropy + dEntropy) -
      orientedFreeEnergy orientation energy temperature entropy =
        dEnergy + orientation * temperature * dEntropy := by
  unfold orientedFreeEnergy
  ring

/-- At nonzero temperature, the printed positive-entropy candidate and the
free-energy-derived fixed-temperature candidate agree only in the degenerate
zero-entropy-change case. -/
theorem printed_and_derived_laws_agree_iff_entropy_static
    {temperature dEntropy pressure dVolume chemicalWork : ℝ}
    (htemperature : temperature ≠ 0) :
    temperature * dEntropy - pressure * dVolume + chemicalWork =
        -pressure * dVolume + chemicalWork ↔
      dEntropy = 0 := by
  constructor
  · intro h
    have hproduct : temperature * dEntropy = 0 := by linarith
    exact (mul_eq_zero.mp hproduct).resolve_left htemperature
  · intro h
    rw [h]
    ring

/-- An interface contribution reconciles the derived and printed laws at fixed
temperature exactly when it supplies `T*dS`; the correction is unique. -/
theorem interface_term_reconciles_printed_law_iff
    (temperature dEntropy pressure dVolume chemicalWork interfaceTerm : ℝ) :
    (-pressure * dVolume + chemicalWork) + interfaceTerm =
        temperature * dEntropy - pressure * dVolume + chemicalWork ↔
      interfaceTerm = temperature * dEntropy := by
  constructor <;> intro h <;> linarith

end ForcingAnalysis.Book6ThermodynamicConsistency
