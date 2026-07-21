/- Book9Stewardship.lean — responsible inheritance of constituted systems. -/
import Mathlib

namespace ForcingAnalysis.Book9Stewardship

/-- A stewardship policy names the safeguards that make a system admissible
and the evidence required before a derivative may be released. The predicates
are deliberately abstract: this kernel does not publish an implementation or
claim that one particular assessment procedure is complete. -/
structure Policy (System Evidence : Type*) where
  safeguarded : System → Prop
  evidenceSupports : Evidence → System → Prop

/-- A derivative relation records both the technical transformation and the
steward's explicit claim that the load-bearing safeguards were preserved. -/
structure Derivation {System Evidence : Type*}
    (P : Policy System Evidence) (parent child : System) where
  transforms : Prop
  preservesSafeguards : P.safeguarded parent → P.safeguarded child

/-- Authorization remains distinct from technical evidence and safeguard
preservation. This is the Book 9 authority boundary applied to release. -/
structure ReleaseCertificate {System Evidence Authority : Type*}
    (P : Policy System Evidence) (child : System) where
  evidence : Evidence
  evidence_supports : P.evidenceSupports evidence child
  authority : Authority
  authorityValid : Authority → Prop
  authorized : authorityValid authority

/-- A safeguarded parent yields a safeguarded child only through an explicit
preservation witness. -/
theorem safeguarded_child_of_preserving_derivation
    {System Evidence : Type*} {P : Policy System Evidence}
    {parent child : System}
    (d : Derivation P parent child) (hp : P.safeguarded parent) :
    P.safeguarded child :=
  d.preservesSafeguards hp

/-- Technical evidence in a release certificate says exactly what the policy
permits it to say: that the evidence supports this child. -/
theorem release_evidence_supports_child
    {System Evidence Authority : Type*} {P : Policy System Evidence}
    {child : System} (r : ReleaseCertificate (Authority := Authority) P child) :
    P.evidenceSupports r.evidence child :=
  r.evidence_supports

/-- Release authorization cannot be inferred from the technical evidence
field: it is carried by a separate, explicitly validated witness. -/
theorem release_requires_valid_authority
    {System Evidence Authority : Type*} {P : Policy System Evidence}
    {child : System} (r : ReleaseCertificate (Authority := Authority) P child) :
    r.authorityValid r.authority :=
  r.authorized

/-- Countermodel: even a safeguarded parent may have an unsafe derivative.
Therefore safety is not inherited merely because a child was derived from a
safe constituted system. -/
theorem safeguarded_parent_does_not_force_safeguarded_child :
    ∃ (P : Policy Bool Unit) (parent child : Bool),
      P.safeguarded parent ∧ ¬ P.safeguarded child := by
  refine ⟨
    { safeguarded := fun s => s = true
      evidenceSupports := fun _ s => s = true },
    true, false, rfl, ?_⟩
  simp

/-- Countermodel: preservation and supporting evidence still do not manufacture
release authority. Governance is an additional premise, not a technical
corollary of a successful assessment. -/
theorem preservation_and_evidence_do_not_force_authority :
    ∃ (P : Policy Unit Unit) (parent child : Unit) (e : Unit),
      P.safeguarded parent ∧ P.safeguarded child ∧
      P.evidenceSupports e child ∧ ¬ Nonempty Empty := by
  refine ⟨
    { safeguarded := fun _ => True
      evidenceSupports := fun _ _ => True },
    (), (), (), trivial, trivial, trivial, ?_⟩
  simp

end ForcingAnalysis.Book9Stewardship