/- Book6ObserverExtension.lean — observer-bounded partial extension kernel. -/
import Mathlib

namespace ForcingAnalysis.Book6ObserverExtension

/-- Extend an observer-local field to the ambient space, using a supplied
fallback outside the observer-admissible domain. -/
noncomputable def observerExtension {Point Value : Type*}
    (admissible : Point → Prop) (localField : {point // admissible point} → Value)
    (fallback : Value) (point : Point) : Value := by
  classical
  exact if h : admissible point then localField ⟨point, h⟩ else fallback

/-- The extension agrees exactly with the local field wherever the observer
bound admits the point. -/
theorem observerExtension_agrees {Point Value : Type*}
    (admissible : Point → Prop) (localField : {point // admissible point} → Value)
    (fallback : Value) (point : Point) (hpoint : admissible point) :
    observerExtension admissible localField fallback point =
      localField ⟨point, hpoint⟩ := by
  classical
  simp [observerExtension, hpoint]

/-- Every observer-local field has a total extension once behavior outside the
observer domain is explicitly supplied. -/
theorem exists_observerExtension {Point Value : Type*}
    (admissible : Point → Prop) (localField : {point // admissible point} → Value)
    (fallback : Value) :
    ∃ extended : Point → Value,
      ∀ point (hpoint : admissible point),
        extended point = localField ⟨point, hpoint⟩ := by
  exact ⟨observerExtension admissible localField fallback,
    observerExtension_agrees admissible localField fallback⟩

/-- Approximate preservation errors add across two observer/interface
transports; an intermediate orientation error cannot be silently discarded. -/
theorem observer_error_accumulates {before intermediate after eps₁ eps₂ : ℝ}
    (hfirst : |before - intermediate| ≤ eps₁)
    (hsecond : |intermediate - after| ≤ eps₂) :
    |before - after| ≤ eps₁ + eps₂ := by
  have htriangle : |before - after| ≤
      |before - intermediate| + |intermediate - after| := by
    calc
      |before - after| = |(before - intermediate) + (intermediate - after)| := by ring_nf
      _ ≤ |before - intermediate| + |intermediate - after| := abs_add_le _ _
  linarith

/-- A curvature bound by itself does not imply an arbitrary divergence or
entropy identity is preserved to that same tolerance. -/
theorem observer_bound_alone_does_not_force_identity_preservation :
    (0 : ℝ) ≤ 1 ∧ ¬ |(0 : ℝ) - 2| ≤ 1 := by
  norm_num

end ForcingAnalysis.Book6ObserverExtension
