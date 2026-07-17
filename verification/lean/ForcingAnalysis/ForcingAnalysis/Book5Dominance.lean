/-
Book5Dominance.lean — scalar sustainable-drift kernel for MAP dominance in
Principia Symbolica Book 5.
-/
import Mathlib

namespace ForcingAnalysis.Book5Dominance

/-- Remaining viability margin for an isolated membrane. -/
def isolatedMargin (internalCapacity drift : ℝ) : ℝ := internalCapacity - drift

/-- Remaining viability margin after adding external MAP reflection. -/
def mapMargin (internalCapacity externalSupport drift : ℝ) : ℝ :=
  internalCapacity + externalSupport - drift

/-- External reflective support strictly raises the maximum sustainable drift. -/
theorem map_capacity_strictly_exceeds_isolated
    (internalCapacity externalSupport : ℝ) (hSupport : 0 < externalSupport) :
    internalCapacity < internalCapacity + externalSupport := by
  linarith

/-- At the isolated critical drift, isolation has no positive margin while a
MAP covenant with positive external support retains a positive margin. -/
theorem map_viable_at_isolated_critical_drift
    (internalCapacity externalSupport : ℝ) (hSupport : 0 < externalSupport) :
    isolatedMargin internalCapacity internalCapacity = 0 ∧
      0 < mapMargin internalCapacity externalSupport internalCapacity := by
  constructor <;> simp [isolatedMargin, mapMargin, hSupport]

/-- Throughout the extra support interval beyond isolated capacity, the MAP
system remains viable although the isolated system does not. -/
theorem map_dominates_beyond_isolated_capacity
    (internalCapacity externalSupport drift : ℝ)
    (hIsolated : internalCapacity ≤ drift)
    (hMap : drift < internalCapacity + externalSupport) :
    isolatedMargin internalCapacity drift ≤ 0 ∧
      0 < mapMargin internalCapacity externalSupport drift := by
  constructor
  · unfold isolatedMargin
    linarith
  · unfold mapMargin
    linarith

end ForcingAnalysis.Book5Dominance
