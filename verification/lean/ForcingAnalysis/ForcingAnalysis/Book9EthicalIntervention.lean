/- Book9EthicalIntervention.lean — typed intervention signals, conflicts, and authority. -/
import Mathlib

namespace ForcingAnalysis.Book9EthicalIntervention

/-- The six source-level observations remain separate facts.  In particular,
technical capacity and interface risk are not authorization predicates. -/
structure Assessment where
  imminentIrreversibleCollapse : Prop
  supportiveMAPCovenant : Prop
  explicitConsent : Prop
  highReflectiveCapacity : Prop
  activeSelfHealing : Prop
  highInterfaceRisk : Prop

def HasJustificationSignal (a : Assessment) : Prop :=
  a.imminentIrreversibleCollapse ∨ a.supportiveMAPCovenant ∨ a.explicitConsent

def HasRestraintSignal (a : Assessment) : Prop :=
  a.highReflectiveCapacity ∨ a.activeSelfHealing ∨ a.highInterfaceRisk

theorem justificationSignal_iff (a : Assessment) :
    HasJustificationSignal a ↔
      a.imminentIrreversibleCollapse ∨
      a.supportiveMAPCovenant ∨ a.explicitConsent :=
  Iff.rfl

theorem restraintSignal_iff (a : Assessment) :
    HasRestraintSignal a ↔
      a.highReflectiveCapacity ∨ a.activeSelfHealing ∨ a.highInterfaceRisk :=
  Iff.rfl

/-- The source's criteria become determinate recommendations only when the two
signal families do not conflict. -/
def RecommendIntervention (a : Assessment) : Prop :=
  HasJustificationSignal a ∧ ¬ HasRestraintSignal a

def RecommendNonIntervention (a : Assessment) : Prop :=
  HasRestraintSignal a ∧ ¬ HasJustificationSignal a

def RequiresReview (a : Assessment) : Prop :=
  HasJustificationSignal a ∧ HasRestraintSignal a

def NoDecisionSignal (a : Assessment) : Prop :=
  ¬ HasJustificationSignal a ∧ ¬ HasRestraintSignal a

theorem recommendation_cases (a : Assessment) :
    RecommendIntervention a ∨ RecommendNonIntervention a ∨
      RequiresReview a ∨ NoDecisionSignal a := by
  by_cases hj : HasJustificationSignal a <;>
    by_cases hr : HasRestraintSignal a <;>
    simp [RecommendIntervention, RecommendNonIntervention, RequiresReview,
      NoDecisionSignal, hj, hr]

theorem intervention_and_nonintervention_disjoint (a : Assessment) :
    ¬ (RecommendIntervention a ∧ RecommendNonIntervention a) := by
  rintro ⟨⟨_, noRestraint⟩, ⟨restraint, _⟩⟩
  exact noRestraint restraint

theorem consent_without_restraint_recommends_intervention
    (a : Assessment) (hconsent : a.explicitConsent)
    (hrestraint : ¬ HasRestraintSignal a) :
    RecommendIntervention a :=
  ⟨Or.inr (Or.inr hconsent), hrestraint⟩

theorem selfHealing_without_justification_recommends_nonintervention
    (a : Assessment) (hhealing : a.activeSelfHealing)
    (hjustification : ¬ HasJustificationSignal a) :
    RecommendNonIntervention a :=
  ⟨Or.inr (Or.inl hhealing), hjustification⟩

/-- Signals can genuinely conflict: imminent collapse and active self-healing may
both be observed.  The printed lists alone therefore do not decide an action. -/
theorem source_criteria_can_require_review :
    ∃ a : Assessment, RequiresReview a := by
  exact ⟨⟨True, False, False, False, True, False⟩,
    by simp [RequiresReview, HasJustificationSignal, HasRestraintSignal]⟩

/-- Human or otherwise legitimate authority is an additional execution gate,
not a consequence of risk classification. -/
def MayExecuteIntervention (a : Assessment) (hasAuthority : Prop) : Prop :=
  RecommendIntervention a ∧ hasAuthority

theorem execution_requires_authority
    (a : Assessment) (hasAuthority : Prop)
    (h : MayExecuteIntervention a hasAuthority) :
    hasAuthority :=
  h.2

theorem recommendation_alone_does_not_grant_authority :
    ∃ a : Assessment,
      RecommendIntervention a ∧ ¬ MayExecuteIntervention a False := by
  let a : Assessment := ⟨False, False, True, False, False, False⟩
  refine ⟨a, ?_, ?_⟩
  · simp [a, RecommendIntervention, HasJustificationSignal, HasRestraintSignal]
  · simp [MayExecuteIntervention]

end ForcingAnalysis.Book9EthicalIntervention
