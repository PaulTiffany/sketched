/-
Book5EnhancedDuality.lean — regime-classification kernel and premise audit
for enhanced MAP–MAD duality in Principia Symbolica Book 5.
-/
import Mathlib
import ForcingAnalysis.Book5MAP

namespace ForcingAnalysis.Book5EnhancedDuality

/-- The parameter-level regimes, retaining the critical boundary instead of
silently assigning equality to either side. -/
inductive Regime where
  | map
  | mad
  | decoupled
  | critical
  deriving DecidableEq, Repr

/-- Strong coupling is classified by polarity; weak coupling decouples; all
threshold/polarity equalities remain explicitly critical. -/
noncomputable def classify (coupling critical polarity : ℝ) : Regime :=
  if critical < coupling then
    if 0 < polarity then .map else if polarity < 0 then .mad else .critical
  else if coupling < critical then .decoupled
  else .critical

theorem classify_map {coupling critical polarity : ℝ}
    (hCoupling : critical < coupling) (hPolarity : 0 < polarity) :
    classify coupling critical polarity = .map := by
  simp [classify, hCoupling, hPolarity]

theorem classify_mad {coupling critical polarity : ℝ}
    (hCoupling : critical < coupling) (hPolarity : polarity < 0) :
    classify coupling critical polarity = .mad := by
  simp [classify, hCoupling, hPolarity, hPolarity.le]

theorem classify_decoupled {coupling critical polarity : ℝ}
    (hCoupling : coupling < critical) :
    classify coupling critical polarity = .decoupled := by
  simp [classify, hCoupling, not_lt.mpr hCoupling.le]

/-- Polarity reversal exchanges the two strong-coupling regimes. -/
theorem classify_neg_of_strong {coupling critical polarity : ℝ}
    (hCoupling : critical < coupling) (hPolarity : polarity ≠ 0) :
    classify coupling critical (-polarity) =
      if classify coupling critical polarity = .map then .mad else .map := by
  rcases lt_or_gt_of_ne hPolarity with hNeg | hPos
  · rw [classify_mad hCoupling hNeg, classify_map hCoupling (neg_pos.mpr hNeg)]
    simp
  · rw [classify_map hCoupling hPos, classify_mad hCoupling (neg_neg_of_pos hPos)]
    simp

/-- The source's strong-coupling/positive-polarity conditions do not alone
force eventual viability: a dynamics law connecting parameters to the
free-energy trajectory is indispensable. -/
theorem positive_regime_parameters_do_not_force_viability :
    ∃ (coupling critical polarity : ℝ) (F : ℕ → ℝ),
      critical < coupling ∧ 0 < polarity ∧
        classify coupling critical polarity = .map ∧
        ¬ ForcingAnalysis.Book5.EventuallyViable F := by
  refine ⟨2, 1, 1, fun _ => -1, by norm_num, by norm_num, by norm_num [classify], ?_⟩
  rintro ⟨n₀, h⟩
  have := h (n₀ + 1) (by omega)
  norm_num at this

end ForcingAnalysis.Book5EnhancedDuality
