/- Book5ReflectiveAccuracy.lean — metabolic reflective-fidelity kernel. -/
import Mathlib

namespace ForcingAnalysis.Book5ReflectiveAccuracy

/-- The logarithmic reflective-fidelity envelope printed in Book 5. -/
noncomputable def fidelityEnvelope (beta metabolicCapacity : ℝ) : ℝ :=
  beta * Real.log (1 + metabolicCapacity)

/-- A bounded fidelity gain per reflective level, composed with a logarithmic
metabolic depth bound, yields the claimed logarithmic fidelity bound. -/
theorem fidelity_le_log_of_depth_bound {fidelity beta metabolicCapacity : ℝ}
    {depth : ℕ} (hbeta : 0 ≤ beta)
    (hfidelity : fidelity ≤ beta * depth)
    (hdepth : (depth : ℝ) ≤ Real.log (1 + metabolicCapacity)) :
    fidelity ≤ fidelityEnvelope beta metabolicCapacity := by
  exact hfidelity.trans
    (mul_le_mul_of_nonneg_left hdepth hbeta)

/-- The logarithmic envelope is nonnegative for nonnegative metabolic capacity
and nonnegative fidelity gain. -/
theorem fidelityEnvelope_nonneg {beta metabolicCapacity : ℝ}
    (hbeta : 0 ≤ beta) (hcapacity : 0 ≤ metabolicCapacity) :
    0 ≤ fidelityEnvelope beta metabolicCapacity := by
  apply mul_nonneg hbeta
  exact Real.log_nonneg (by linarith)

/-- Metabolic capacity alone cannot constrain an otherwise unrestricted
reflective-fidelity value: one may always choose a value above the proposed
envelope. -/
theorem capacity_alone_does_not_bound_unconstrained_fidelity
    (beta metabolicCapacity : ℝ) :
    ¬ (beta * Real.log (1 + metabolicCapacity) + 1 ≤
      fidelityEnvelope beta metabolicCapacity) := by
  simp [fidelityEnvelope]

end ForcingAnalysis.Book5ReflectiveAccuracy
