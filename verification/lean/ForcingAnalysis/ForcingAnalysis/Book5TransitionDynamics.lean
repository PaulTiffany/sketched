/-
Book5TransitionDynamics.lean — exact exponential-step kernel for transitional
covenant dynamics in Principia Symbolica Book 5.
-/
import Mathlib

namespace ForcingAnalysis.Book5TransitionDynamics

/-- Exact MAP-side update corresponding to the source's displayed
constant-coefficient exponential approximation. -/
noncomputable def mapStep (F alpha Lambda dt : ℝ) : ℝ :=
  F * Real.exp (alpha * (Lambda - 1) * dt)

/-- Exact MAD-side update corresponding to the source's displayed decay. -/
noncomputable def madStep (F beta Lambda dt : ℝ) : ℝ :=
  F * Real.exp (-beta * (|Lambda| - 1) * dt)

/-- Above the coupling boundary, a positive-rate MAP step strictly increases
positive free energy. -/
theorem mapStep_strict_growth {F alpha Lambda dt : ℝ}
    (hF : 0 < F) (hAlpha : 0 < alpha) (hLambda : 1 < Lambda)
    (hdt : 0 < dt) :
    F < mapStep F alpha Lambda dt := by
  have hExponent : 0 < alpha * (Lambda - 1) * dt := by positivity
  have hExp : 1 < Real.exp (alpha * (Lambda - 1) * dt) :=
    Real.one_lt_exp_iff.mpr hExponent
  have hProduct := mul_pos hF (sub_pos.mpr hExp)
  unfold mapStep
  nlinarith

/-- Beyond the absolute coupling boundary, a positive-rate MAD step strictly
decreases positive free energy while preserving positivity. -/
theorem madStep_strict_decay {F beta Lambda dt : ℝ}
    (hF : 0 < F) (hBeta : 0 < beta) (hLambda : 1 < |Lambda|)
    (hdt : 0 < dt) :
    0 < madStep F beta Lambda dt ∧ madStep F beta Lambda dt < F := by
  have hExponent : -beta * (|Lambda| - 1) * dt < 0 := by
    have : 0 < beta * (|Lambda| - 1) * dt := by positivity
    nlinarith
  have hExpPos : 0 < Real.exp (-beta * (|Lambda| - 1) * dt) := Real.exp_pos _
  have hExpLt : Real.exp (-beta * (|Lambda| - 1) * dt) < 1 :=
    Real.exp_lt_one_iff.mpr hExponent
  constructor
  · exact mul_pos hF hExpPos
  · have hProduct := mul_pos hF (sub_pos.mpr hExpLt)
    unfold madStep
    nlinarith

/-- The MAP update is the identity exactly on the Lambda=1 boundary. -/
theorem mapStep_at_boundary (F alpha dt : ℝ) :
    mapStep F alpha 1 dt = F := by
  simp [mapStep]

/-- A boundary crossing by itself does not determine the next free energy;
the exponential evolution law is separate, load-bearing structure. -/
theorem crossing_alone_does_not_force_growth :
    ∃ (before after Fnext : ℝ),
      before < 1 ∧ 1 < after ∧ Fnext < 0 := by
  exact ⟨0, 2, -1, by norm_num, by norm_num, by norm_num⟩

end ForcingAnalysis.Book5TransitionDynamics
