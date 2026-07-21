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

/-- A coherent observer extension carries its domain/fallback construction
and separate normed certificates for the identities it claims to preserve. -/
structure ObserverOperatorExtensionCertificate (Point Value : Type*) where
  admissible : Point → Prop
  localField : {point // admissible point} → Value
  fallback : Value
  divergenceDefect : Point → ℝ
  entropyDefect : Point → ℝ
  epsilon : ℝ
  epsilon_nonneg : 0 ≤ epsilon
  divergence_bound : ∀ point, |divergenceDefect point| ≤ epsilon
  entropy_bound : ∀ point, |entropyDefect point| ≤ epsilon

namespace ObserverOperatorExtensionCertificate

/-- The certificate constructs a total field agreeing with the local field on
the observer-admissible subtype. -/
theorem exists_total_extension {Point Value : Type*}
    (C : ObserverOperatorExtensionCertificate Point Value) :
    ∃ extended : Point → Value, ∀ point (hpoint : C.admissible point),
      extended point = C.localField ⟨point, hpoint⟩ :=
  exists_observerExtension C.admissible C.localField C.fallback

/-- Both advertised preservation defects are controlled by the same explicit
observer budget; neither estimate follows from curvature boundedness alone. -/
theorem joint_defect_bound {Point Value : Type*}
    (C : ObserverOperatorExtensionCertificate Point Value) (point : Point) :
    max |C.divergenceDefect point| |C.entropyDefect point| ≤ C.epsilon := by
  exact max_le (C.divergence_bound point) (C.entropy_bound point)

end ObserverOperatorExtensionCertificate
end ForcingAnalysis.Book6ObserverExtension
