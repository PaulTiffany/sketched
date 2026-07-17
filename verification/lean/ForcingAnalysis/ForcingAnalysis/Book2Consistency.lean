/-
Book2Consistency.lean — typed balance kernel and premise audit for the
hypothesis-manifold consistency lemma in Principia Symbolica Book 2.

The source proof introduces a closed-surface balance assumption not present in
the lemma statement.  We certify the balance implication when that assumption
is explicit and exhibit that a curvature bound alone cannot force it.
-/
import Mathlib

namespace ForcingAnalysis.Book2Consistency

/-- Integrated first-variation data for a closed hypothesis surface. -/
structure ClosedSurfaceBalance where
  freeEnergyWork : ℝ
  observerEnergyWork : ℝ
  temperatureEntropyWork : ℝ
  entropyTemperatureExchange : ℝ
  firstVariation : freeEnergyWork = observerEnergyWork -
    temperatureEntropyWork - entropyTemperatureExchange
  closedBalance : observerEnergyWork - temperatureEntropyWork = 0

/-- Conditional kernel of
`lemma:bk2_thermodynamic_consistency_hypothesis_manifolds`: after the source
proof's closed-surface balance is made explicit, the remaining free-energy
work is exactly minus the entropy-weighted temperature exchange. -/
theorem thermodynamic_consistency (b : ClosedSurfaceBalance) :
    b.freeEnergyWork = -b.entropyTemperatureExchange := by
  linarith [b.firstVariation, b.closedBalance]

/-- Bounded curvature alone cannot imply the advertised balance relation: the
curvature inequality and the thermodynamic work data are independent until a
bridge premise such as `ClosedSurfaceBalance.closedBalance` is supplied. -/
theorem boundedCurvature_alone_insufficient :
    ∃ (κ K freeEnergyWork entropyTemperatureExchange : ℝ),
      κ < K ∧ freeEnergyWork ≠ -entropyTemperatureExchange := by
  exact ⟨0, 1, 1, 0, by norm_num, by norm_num⟩

end ForcingAnalysis.Book2Consistency