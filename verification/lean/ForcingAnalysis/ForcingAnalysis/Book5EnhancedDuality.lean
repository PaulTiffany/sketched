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

/-! ## Exact four-way classification -/

def RegimeCondition (coupling critical polarity : ℝ) : Regime → Prop
  | .map => critical < coupling ∧ 0 < polarity
  | .mad => critical < coupling ∧ polarity < 0
  | .decoupled => coupling < critical
  | .critical => coupling = critical ∨ (critical < coupling ∧ polarity = 0)

theorem classify_eq_map_iff {coupling critical polarity : ℝ} :
    classify coupling critical polarity = .map ↔
      RegimeCondition coupling critical polarity .map := by
  simp only [RegimeCondition]
  unfold classify
  split_ifs <;> simp_all [le_of_lt]

theorem classify_eq_mad_iff {coupling critical polarity : ℝ} :
    classify coupling critical polarity = .mad ↔
      RegimeCondition coupling critical polarity .mad := by
  simp only [RegimeCondition]
  unfold classify
  split_ifs <;> simp_all [le_of_lt]

theorem classify_eq_decoupled_iff {coupling critical polarity : ℝ} :
    classify coupling critical polarity = .decoupled ↔
      RegimeCondition coupling critical polarity .decoupled := by
  simp only [RegimeCondition]
  unfold classify
  split_ifs <;> simp_all [le_of_lt]

theorem classify_eq_critical_iff {coupling critical polarity : ℝ} :
    classify coupling critical polarity = .critical ↔
      RegimeCondition coupling critical polarity .critical := by
  unfold classify RegimeCondition
  by_cases hs : critical < coupling
  · by_cases hp : 0 < polarity
    · simp [hs, hp, ne_of_gt hs, ne_of_gt hp]
    · by_cases hn : polarity < 0
      · simp [hs, hp, hn, ne_of_gt hs, ne_of_lt hn]
      · have hz : polarity = 0 := le_antisymm (not_lt.mp hp) (not_lt.mp hn)
        simp [hs, hz, ne_of_gt hs]
  · have hle : coupling ≤ critical := not_lt.mp hs
    by_cases hw : coupling < critical
    · simp [hs, hw, ne_of_lt hw]
    · have heq : coupling = critical := le_antisymm hle (not_lt.mp hw)
      simp [heq]

theorem regimeCondition_iff_classify_eq
    {coupling critical polarity : ℝ} (r : Regime) :
    RegimeCondition coupling critical polarity r ↔
      classify coupling critical polarity = r := by
  cases r with
  | map => exact classify_eq_map_iff.symm
  | mad => exact classify_eq_mad_iff.symm
  | decoupled => exact classify_eq_decoupled_iff.symm
  | critical => exact classify_eq_critical_iff.symm

/-- For every parameter triple, exactly one of MAP, MAD, decoupled, or the
critical boundary obtains. Equality and zero polarity are retained in the
critical case rather than silently assigned to a neighboring regime. -/
theorem existsUnique_regimeCondition (coupling critical polarity : ℝ) :
    ∃! r : Regime, RegimeCondition coupling critical polarity r := by
  refine ⟨classify coupling critical polarity, ?_, ?_⟩
  · exact (regimeCondition_iff_classify_eq _).2 rfl
  · intro r hr
    exact ((regimeCondition_iff_classify_eq r).1 hr).symm
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
