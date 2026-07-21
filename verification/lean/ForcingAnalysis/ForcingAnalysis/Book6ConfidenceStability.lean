/- Book6ConfidenceStability.lean — confidence/stability quotient-response kernel. -/
import Mathlib

namespace ForcingAnalysis.Book6ConfidenceStability

/-- Algebraic derivative of `H(Υ) / Υ`, given the value and derivative of the
confidence Hamiltonian at a nonzero stability coordinate. -/
noncomputable def quotientSlope (hamiltonian hamiltonianDerivative stability : ℝ) : ℝ :=
  (hamiltonianDerivative * stability - hamiltonian) / stability ^ 2

/-- Scalar chart of the printed confidence-stability coupling. -/
noncomputable def stabilityVelocity (coupling hamiltonian hamiltonianDerivative
    stability : ℝ) : ℝ :=
  -coupling * quotientSlope hamiltonian hamiltonianDerivative stability

theorem stabilityVelocity_eq (coupling hamiltonian hamiltonianDerivative
    stability : ℝ) :
    stabilityVelocity coupling hamiltonian hamiltonianDerivative stability =
      -coupling *
        ((hamiltonianDerivative * stability - hamiltonian) / stability ^ 2) :=
  rfl

/-- Positive coupling makes stability non-increasing when the Hamiltonian
quotient has nonnegative slope. -/
theorem stabilityVelocity_nonpos_of_quotientSlope_nonneg
    {coupling hamiltonian hamiltonianDerivative stability : ℝ}
    (hcoupling : 0 ≤ coupling)
    (hslope : 0 ≤ quotientSlope hamiltonian hamiltonianDerivative stability) :
    stabilityVelocity coupling hamiltonian hamiltonianDerivative stability ≤ 0 := by
  unfold stabilityVelocity
  calc
    -coupling * quotientSlope hamiltonian hamiltonianDerivative stability =
        -(coupling * quotientSlope hamiltonian hamiltonianDerivative stability) := by ring
    _ ≤ 0 := neg_nonpos.mpr (mul_nonneg hcoupling hslope)

/-- With a positive constant confidence Hamiltonian, the reciprocal quotient
has negative slope, so the printed outer minus sign gives positive stability
velocity rather than decay. -/
theorem constant_hamiltonian_gives_positive_stabilityVelocity
    {coupling hamiltonian stability : ℝ}
    (hcoupling : 0 < coupling) (hhamiltonian : 0 < hamiltonian)
    (hstability : stability ≠ 0) :
    0 < stabilityVelocity coupling hamiltonian 0 stability := by
  unfold stabilityVelocity quotientSlope
  have hsquare : 0 < stability ^ 2 := sq_pos_of_ne_zero hstability
  have hquotient : 0 < hamiltonian / stability ^ 2 :=
    div_pos hhamiltonian hsquare
  have hrearrange :
      -coupling * ((0 * stability - hamiltonian) / stability ^ 2) =
        coupling * (hamiltonian / stability ^ 2) := by ring
  rw [hrearrange]
  exact mul_pos hcoupling hquotient

/-- Confidence and stability values do not determine their dynamics without an
explicit coupling/update law. -/
theorem values_alone_do_not_force_confidence_stability_coupling :
    (0 : ℝ) ≠ stabilityVelocity 1 1 0 1 := by
  norm_num [stabilityVelocity, quotientSlope]

/-- A confidence--stability law must supply the nonzero coordinate, coupling
orientation, quotient response, and actual velocity equation. -/
structure ConfidenceStabilityCertificate where
  coupling : ℝ
  hamiltonian : ℝ
  hamiltonianDerivative : ℝ
  stability : ℝ
  velocity : ℝ
  stability_ne_zero : stability ≠ 0
  coupling_nonneg : 0 ≤ coupling
  constitutive : velocity =
    stabilityVelocity coupling hamiltonian hamiltonianDerivative stability

namespace ConfidenceStabilityCertificate

/-- A certified nonnegative quotient slope forces nonpositive stability
velocity under the displayed outer-minus orientation. -/
theorem velocity_nonpos (C : ConfidenceStabilityCertificate)
    (hslope : 0 ≤ quotientSlope C.hamiltonian C.hamiltonianDerivative C.stability) :
    C.velocity ≤ 0 := by
  rw [C.constitutive]
  exact stabilityVelocity_nonpos_of_quotientSlope_nonneg C.coupling_nonneg hslope

end ConfidenceStabilityCertificate
end ForcingAnalysis.Book6ConfidenceStability
