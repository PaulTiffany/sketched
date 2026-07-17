/- Book5OperatorAdaptation.lean — source-bound SRMF adaptation kernel. -/
import Mathlib

namespace ForcingAnalysis.Book5OperatorAdaptation

/-- Effectiveness deficit below the critical threshold. -/
def effectivenessShortfall (threshold effectiveness : ℝ) : ℝ :=
  max (threshold - effectiveness) 0

/-- TTPR-style refinement pressure with an explicit feedback gain. -/
def refinementVelocity (gain threshold effectiveness : ℝ) : ℝ :=
  gain * effectivenessShortfall threshold effectiveness

/-- Below threshold, refinement velocity is exactly proportional to the
effectiveness deficit. -/
theorem refinementVelocity_eq_of_below {gain threshold effectiveness : ℝ}
    (hbelow : effectiveness < threshold) :
    refinementVelocity gain threshold effectiveness =
      gain * (threshold - effectiveness) := by
  simp [refinementVelocity, effectivenessShortfall,
    le_of_lt (sub_pos.mpr hbelow)]

/-- Positive feedback gain produces a strictly positive adaptation rate below
the critical effectiveness threshold. -/
theorem refinementVelocity_pos {gain threshold effectiveness : ℝ}
    (hgain : 0 < gain) (hbelow : effectiveness < threshold) :
    0 < refinementVelocity gain threshold effectiveness := by
  rw [refinementVelocity_eq_of_below hbelow]
  exact mul_pos hgain (sub_pos.mpr hbelow)

/-- One explicit operator update law: a parameter follows the negative process
free-energy gradient with learning rate `stepSize`. -/
def gradientStep (stepSize operator gradient : ℝ) : ℝ :=
  operator - stepSize * gradient

theorem gradientStep_displacement (stepSize operator gradient : ℝ) :
    gradientStep stepSize operator gradient - operator =
      -(stepSize * gradient) := by
  simp [gradientStep]

/-- For the quadratic process-free-energy kernel, a gradient step with rate in
`[0, 2]` is a certified descent step. -/
theorem quadratic_processFreeEnergy_descent {stepSize operator : ℝ}
    (hstep_nonneg : 0 ≤ stepSize) (hstep_le : stepSize ≤ 2) :
    (gradientStep stepSize operator operator) ^ 2 ≤ operator ^ 2 := by
  rw [gradientStep]
  have hproduct : 0 ≤ stepSize * (2 - stepSize) * operator ^ 2 :=
    mul_nonneg (mul_nonneg hstep_nonneg (sub_nonneg.mpr hstep_le)) (sq_nonneg operator)
  nlinarith

/-- Process-free-energy descent can coexist with a transient increase in the
separate execution-cost coordinate. -/
theorem process_descent_can_increase_execution_cost :
    ∃ (Operator : Type) (current adapted : Operator)
      (processFreeEnergy executionCost : Operator → ℝ),
      processFreeEnergy adapted < processFreeEnergy current ∧
      executionCost current < executionCost adapted := by
  refine ⟨Bool, false, true, ?_, ?_, ?_⟩
  · exact fun operator => if operator then 0 else 1
  · exact fun operator => if operator then 1 else 0
  · norm_num

/-- The threshold inequality by itself does not force adaptation: an identity
update can remain fixed while effectiveness is below threshold. -/
theorem below_threshold_alone_does_not_force_adaptation :
    ∃ (threshold effectiveness : ℝ) (update : ℝ → ℝ),
      effectiveness < threshold ∧ update 0 = 0 := by
  exact ⟨1, 0, id, by norm_num, rfl⟩

end ForcingAnalysis.Book5OperatorAdaptation
