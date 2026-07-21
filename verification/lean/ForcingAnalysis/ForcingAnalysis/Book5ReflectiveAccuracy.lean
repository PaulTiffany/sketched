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


/-! ## Depth-indexed fidelity reconstruction -/

/-- Reflective fidelity as an actual recursion-depth process. The zero-depth
normalization and uniform marginal bound are separate load-bearing laws. -/
structure ReflectiveFidelityProcess where
  fidelity : ℕ → ℝ
  gainPerLevel : ℝ
  gain_nonneg : 0 ≤ gainPerLevel
  fidelity_zero : fidelity 0 = 0
  marginal_gain_le : ∀ n, fidelity (n + 1) - fidelity n ≤ gainPerLevel

namespace ReflectiveFidelityProcess

/-- Uniform marginal control telescopes over every finite reflective depth. -/
theorem fidelity_le_linear (P : ReflectiveFidelityProcess) (n : ℕ) :
    P.fidelity n ≤ P.gainPerLevel * n := by
  induction n with
  | zero => simpa using le_of_eq P.fidelity_zero
  | succ n ih =>
      rw [Nat.cast_succ]
      have hstep := P.marginal_gain_le n
      nlinarith

end ReflectiveFidelityProcess

/-- A geometric metabolic recursion budget. `cost_le_capacity` is the physical
admissibility statement; positivity prevents free or reversed recursion cost. -/
structure GeometricRecursionBudget where
  baseCost : ℝ
  growth : ℝ
  capacity : ℝ
  depth : ℕ
  baseCost_pos : 0 < baseCost
  growth_pos : 0 < growth
  capacity_nonneg : 0 ≤ capacity
  cost_le_capacity : baseCost * (growth ^ depth - 1) ≤ capacity

namespace GeometricRecursionBudget

/-- The geometric cost law yields the dimensionless power budget before any
logarithm or change-of-base normalization is applied. -/
theorem power_le_capacity_ratio_add_one (B : GeometricRecursionBudget) :
    B.growth ^ B.depth ≤ B.capacity / B.baseCost + 1 := by
  have hcost : (B.growth ^ B.depth - 1) * B.baseCost ≤ B.capacity := by
    nlinarith [B.cost_le_capacity]
  have h := (le_div_iff₀ B.baseCost_pos).2 hcost
  linarith

end GeometricRecursionBudget

/-- Explicit analytic calibration from an admissible integer depth to the
source's normalized logarithmic capacity coordinate. This certificate keeps the
choice of log base, cost units, and final scale visible. -/
structure LogDepthCalibration (B : GeometricRecursionBudget) where
  normalizedScale : ℝ
  scale_nonneg : 0 ≤ normalizedScale
  depth_le_logCapacity :
    (B.depth : ℝ) ≤ normalizedScale * Real.log (1 + B.capacity)

/-- Complete rebuilt accuracy certificate: the fidelity process, geometric
metabolic admissibility, and log-coordinate calibration compose without
identifying any of those three layers. -/
structure ReflectiveAccuracyCertificate where
  process : ReflectiveFidelityProcess
  budget : GeometricRecursionBudget
  calibration : LogDepthCalibration budget

namespace ReflectiveAccuracyCertificate

/-- The source coefficient is constructed from marginal fidelity gain and the
explicit log-depth calibration. -/
noncomputable def beta (C : ReflectiveAccuracyCertificate) : ℝ :=
  C.process.gainPerLevel * C.calibration.normalizedScale

theorem beta_nonneg (C : ReflectiveAccuracyCertificate) : 0 ≤ C.beta := by
  exact mul_nonneg C.process.gain_nonneg C.calibration.scale_nonneg

/-- The full metabolic reflective-accuracy envelope. -/
theorem fidelity_le_log_capacity (C : ReflectiveAccuracyCertificate) :
    C.process.fidelity C.budget.depth ≤
      C.beta * Real.log (1 + C.budget.capacity) := by
  calc
    C.process.fidelity C.budget.depth ≤
        C.process.gainPerLevel * C.budget.depth :=
      C.process.fidelity_le_linear C.budget.depth
    _ ≤ C.process.gainPerLevel *
        (C.calibration.normalizedScale * Real.log (1 + C.budget.capacity)) :=
      mul_le_mul_of_nonneg_left C.calibration.depth_le_logCapacity
        C.process.gain_nonneg
    _ = C.beta * Real.log (1 + C.budget.capacity) := by
      unfold beta
      ring

end ReflectiveAccuracyCertificate

/-- A depth budget without marginal-gain control cannot bound fidelity: the
same admissible depth and capacity can support arbitrarily assigned values. -/
theorem depth_budget_without_marginal_control_countermodel :
    let budget : GeometricRecursionBudget :=
      { baseCost := 1, growth := 2, capacity := 1, depth := 1
        baseCost_pos := by norm_num
        growth_pos := by norm_num
        capacity_nonneg := by norm_num
        cost_le_capacity := by norm_num }
    budget.baseCost * (budget.growth ^ budget.depth - 1) ≤ budget.capacity ∧
      ∀ proposedBound : ℝ, ∃ fidelity : ℕ → ℝ,
        proposedBound < fidelity budget.depth := by
  dsimp
  constructor
  · norm_num
  · intro proposedBound
    exact ⟨fun _ => proposedBound + 1, by norm_num⟩

end ForcingAnalysis.Book5ReflectiveAccuracy
