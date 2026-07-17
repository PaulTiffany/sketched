/- Book8FramingEquivalence.lean — observer framing, product spans, and curvature residue. -/
import Mathlib

namespace ForcingAnalysis.Book8FramingEquivalence

variable {C A B V : Type*}

/-- A projected coherence structure is separable when some locally admissible
subsystem pair places its observed difference in the corresponding product span. -/
def Separable
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop) (c : C) : Prop :=
  ∃ a b, locallyDefines a b c ∧ observedDifference c ∈ productSpan a b

def PerceivedEntangled
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop) (c : C) : Prop :=
  ¬ Separable observedDifference productSpan locallyDefines c

/-- The displayed Framing Equivalence, with its quantifiers made explicit:
nonseparability means exclusion from every locally admissible product span. -/
theorem framing_equivalence
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop) (c : C) :
    PerceivedEntangled observedDifference productSpan locallyDefines c ↔
      ∀ a b, locallyDefines a b c →
        observedDifference c ∉ productSpan a b := by
  simp [PerceivedEntangled, Separable]

/-- The two constitutive bridges used by the prose proof: symbolic curvature
vanishes exactly when projection residue vanishes, and residue vanishes exactly
when the observer admits a local product-span decomposition. -/
structure CurvatureProjectionBridge
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop) where
  curvature : C → ℝ
  projectionResidual : C → ℝ
  curvature_zero_iff_residual_zero : ∀ c,
    curvature c = 0 ↔ projectionResidual c = 0
  residual_zero_iff_separable : ∀ c,
    projectionResidual c = 0 ↔
      Separable observedDifference productSpan locallyDefines c

theorem curvature_zero_iff_separable
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop)
    (bridge : CurvatureProjectionBridge observedDifference productSpan locallyDefines)
    (c : C) :
    bridge.curvature c = 0 ↔
      Separable observedDifference productSpan locallyDefines c := by
  exact (bridge.curvature_zero_iff_residual_zero c).trans
    (bridge.residual_zero_iff_separable c)

/-- Under the explicit Book-1-to-Book-8 projection bridges, nonzero symbolic
curvature is exactly entanglement perceived by the bounded linear frame. -/
theorem curvature_nonzero_iff_perceivedEntangled
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop)
    (bridge : CurvatureProjectionBridge observedDifference productSpan locallyDefines)
    (c : C) :
    bridge.curvature c ≠ 0 ↔
      PerceivedEntangled observedDifference productSpan locallyDefines c := by
  rw [PerceivedEntangled, ← not_congr
    (curvature_zero_iff_separable observedDifference productSpan locallyDefines bridge c)]

theorem curvature_nonzero_iff_all_productSpans_excluded
    (observedDifference : C → V) (productSpan : A → B → Set V)
    (locallyDefines : A → B → C → Prop)
    (bridge : CurvatureProjectionBridge observedDifference productSpan locallyDefines)
    (c : C) :
    bridge.curvature c ≠ 0 ↔
      ∀ a b, locallyDefines a b c →
        observedDifference c ∉ productSpan a b := by
  exact (curvature_nonzero_iff_perceivedEntangled
    observedDifference productSpan locallyDefines bridge c).trans
      (framing_equivalence observedDifference productSpan locallyDefines c)

/-- Negative control: a scalar called curvature carries no factorization content
until a curvature/projection/separability bridge is supplied. -/
theorem curvature_alone_does_not_force_entanglement :
    ∃ curvature : Bool → ℝ, ∃ entangled : Bool → Prop,
      curvature true ≠ 0 ∧ ¬ entangled true := by
  exact ⟨fun b => if b then 1 else 0, fun _ => False, by norm_num⟩

end ForcingAnalysis.Book8FramingEquivalence
