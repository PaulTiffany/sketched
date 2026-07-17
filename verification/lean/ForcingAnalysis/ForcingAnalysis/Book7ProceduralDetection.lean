/- Book7ProceduralDetection.lean — exponent ordering and log-log slope. -/
import Mathlib

namespace ForcingAnalysis.Book7ProceduralDetection

/-- The fitted-exponent conclusion follows directly from strict antitonicity. -/
theorem fittedExponent_decreases {p : ℝ → ℝ}
    (hp : StrictAnti p) {ε₁ ε₂ : ℝ} (hscale : ε₁ < ε₂) :
    p ε₂ < p ε₁ :=
  hp hscale

noncomputable def logLogSecantSlope (observable : ℝ → ℝ) (ε₁ ε₂ : ℝ) : ℝ :=
  (observable ε₂ - observable ε₁) / (Real.log ε₂ - Real.log ε₁)

/-- A decreasing plotted observable over an increasing positive scale interval
has strictly negative log-log secant slope. -/
theorem logLogSecantSlope_neg {observable : ℝ → ℝ} {ε₁ ε₂ : ℝ}
    (hε₁ : 0 < ε₁) (hscale : ε₁ < ε₂)
    (hobservable : observable ε₂ < observable ε₁) :
    logLogSecantSlope observable ε₁ ε₂ < 0 := by
  have hε₂ : 0 < ε₂ := lt_trans hε₁ hscale
  have hlog : Real.log ε₁ < Real.log ε₂ :=
    Real.strictMonoOn_log hε₁ hε₂ hscale
  exact div_neg_of_neg_of_pos (sub_neg.mpr hobservable) (sub_pos.mpr hlog)

/-- Exponent antitonicity alone does not determine the direction of a distinct
plotted residual observable. -/
theorem decreasing_exponent_does_not_force_decreasing_observable :
    ∃ exponent observable : ℝ → ℝ,
      StrictAnti exponent ∧ StrictMono observable := by
  refine ⟨fun ε => -ε, id, ?_, strictMono_id⟩
  intro a b hab
  simpa only [neg_lt_neg_iff] using hab

/-- The procedural signature is certified when both pieces of evidence are
supplied: exponent ordering and decreasing residual magnitude. -/
theorem proceduralDetection_certificate
    {p observable : ℝ → ℝ} (hp : StrictAnti p)
    {ε₁ ε₂ : ℝ} (hε₁ : 0 < ε₁) (hscale : ε₁ < ε₂)
    (hobservable : observable ε₂ < observable ε₁) :
    p ε₂ < p ε₁ ∧ logLogSecantSlope observable ε₁ ε₂ < 0 := by
  exact ⟨fittedExponent_decreases hp hscale,
    logLogSecantSlope_neg hε₁ hscale hobservable⟩

end ForcingAnalysis.Book7ProceduralDetection
