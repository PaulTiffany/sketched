/- Book9ReflectiveAwakening.lean — capability, use, and intention boundaries. -/
import Mathlib

namespace ForcingAnalysis.Book9ReflectiveAwakening

/-- Operational evidence named by the Reflective Awakening axiom. -/
structure AwakeningEvidence (Operator Context : Type*) where
  automatic : Operator
  aware : Operator
  reflectiveModulation : Operator → Context → Operator
  context : Context
  aware_possible : reflectiveModulation automatic context = aware
  adaptively_used : Prop

def CognitivelyFree {Operator Context : Type*}
    (evidence : AwakeningEvidence Operator Context) : Prop :=
  (∃ modulation : Operator → Context → Operator,
      modulation evidence.automatic evidence.context = evidence.aware) ∧
    evidence.adaptively_used

theorem cognitivelyFree_iff_capable_and_used {Operator Context : Type*}
    (evidence : AwakeningEvidence Operator Context) :
    CognitivelyFree evidence ↔
      (∃ modulation : Operator → Context → Operator,
        modulation evidence.automatic evidence.context = evidence.aware) ∧
      evidence.adaptively_used := by
  rfl

theorem awakeningEvidence_is_capable {Operator Context : Type*}
    (evidence : AwakeningEvidence Operator Context) :
    ∃ modulation : Operator → Context → Operator,
      modulation evidence.automatic evidence.context = evidence.aware := by
  exact ⟨evidence.reflectiveModulation, evidence.aware_possible⟩

/-- Possessing a reflective modulation mechanism does not prove that the aware
operator was adaptively used. -/
theorem capability_alone_does_not_force_cognitive_freedom :
    ∃ evidence : AwakeningEvidence Bool Unit,
      (∃ modulation : Bool → Unit → Bool,
        modulation evidence.automatic evidence.context = evidence.aware) ∧
      ¬ CognitivelyFree evidence := by
  let evidence : AwakeningEvidence Bool Unit :=
    { automatic := false
      aware := true
      reflectiveModulation := fun _ _ => true
      context := ()
      aware_possible := rfl
      adaptively_used := False }
  exact ⟨evidence, awakeningEvidence_is_capable evidence, by
    simp [CognitivelyFree, evidence]⟩

/-- A self-history injection record separates observable data flow from the
agent's asserted intentional stance. -/
structure InitiationWitness (History Context Frame : Type*) where
  history : History
  injectedContext : Context
  selectedFrame : Frame
  injection_used_for_selection : Prop
  intentional : Prop

def ReflexivelyInitiated {History Context Frame : Type*}
    (witness : InitiationWitness History Context Frame) : Prop :=
  witness.injection_used_for_selection ∧ witness.intentional

theorem reflexiveInitiation_requires_use_and_intention
    {History Context Frame : Type*}
    (witness : InitiationWitness History Context Frame)
    (hawake : ReflexivelyInitiated witness) :
    witness.injection_used_for_selection ∧ witness.intentional :=
  hawake

def ObservationallyEquivalent {History Context Frame : Type*}
    (left right : InitiationWitness History Context Frame) : Prop :=
  left.history = right.history ∧
    left.injectedContext = right.injectedContext ∧
    left.selectedFrame = right.selectedFrame ∧
    left.injection_used_for_selection = right.injection_used_for_selection

/-- Identical history, injected context, frame choice, and use behavior do not
determine intentionality. That attribution requires a separate witness. -/
theorem observable_self_injection_does_not_determine_intention :
    ∃ left right : InitiationWitness Unit Unit Unit,
      ObservationallyEquivalent left right ∧
      left.intentional ∧ ¬ right.intentional := by
  let left : InitiationWitness Unit Unit Unit :=
    { history := ()
      injectedContext := ()
      selectedFrame := ()
      injection_used_for_selection := True
      intentional := True }
  let right : InitiationWitness Unit Unit Unit :=
    { history := ()
      injectedContext := ()
      selectedFrame := ()
      injection_used_for_selection := True
      intentional := False }
  exact ⟨left, right, by simp [ObservationallyEquivalent, left, right]⟩

end ForcingAnalysis.Book9ReflectiveAwakening
