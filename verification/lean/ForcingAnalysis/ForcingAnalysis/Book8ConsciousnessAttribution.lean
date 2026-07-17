import ForcingAnalysis.Book4ImaginationDetector
import Mathlib

/-!
Book8ConsciousnessAttribution.lean — observer-relative higher-order
recognition of an embodied imagination/regulation process.

This is an authorial extension, not a newly discovered Principia source claim.
Book 4 supplies the multiframe detector.  This Book 8 layer adds the active
bridge the detector deliberately lacks: an unreal simulated alternative must
make a difference to authorized embodied regulation.  An observer may then
collapse a sufficiently coherent manifold of traces to the higher-order
classification "conscious".

The classification is operational and observer-relative.  It is not a proof
of a hidden substance, and observers need not agree without a shared policy.
-/

namespace ForcingAnalysis.Book8ConsciousnessAttribution

open Book4ImaginationDetector

/-- A carrier for the real observation, simulated alternative, regulated
action, ablated action, and the embodiment's admitted action boundary. -/
structure EmbodiedProcess
    (Observation Simulation Action : Type*) where
  actualObservation : Observation
  imaginedAlternative : Simulation
  realized : Simulation → Prop
  actionWithImagination : Action
  actionWithoutImagination : Action
  authorized : Action → Prop

/-- The active imagination/regulation signature:

1. the simulated alternative is not itself realized;
2. ablating that alternative changes the resulting action; and
3. the action selected through simulation remains inside the embodiment's
   admitted authority.
-/
def ImaginaryRegulationSignature
    {Observation Simulation Action : Type*}
    (process : EmbodiedProcess Observation Simulation Action) : Prop :=
  ¬ process.realized process.imaginedAlternative ∧
    process.actionWithImagination ≠ process.actionWithoutImagination ∧
    process.authorized process.actionWithImagination

/-- A detection case retains the passive multiframe evidence alongside the
active embodied process on which an ablation can be performed. -/
structure DetectionCase
    (Observation Simulation Action : Type*) extends
    EmbodiedProcess Observation Simulation Action where
  evidence : DetectorEvidence

/-- Operational detection requires both strict multiframe evidence and the
active imagination/regulation signature. -/
def OperationallyDetected
    {Observation Simulation Action : Type*}
    (candidate : DetectionCase Observation Simulation Action) : Prop :=
  OrientationSensitiveCandidate candidate.evidence ∧
    ImaginaryRegulationSignature candidate.toEmbodiedProcess

theorem operationalDetection_components
    {Observation Simulation Action : Type*}
    {candidate : DetectionCase Observation Simulation Action}
    (h : OperationallyDetected candidate) :
    OrientationSensitiveCandidate candidate.evidence ∧
      ¬ candidate.realized candidate.imaginedAlternative ∧
      candidate.actionWithImagination ≠
        candidate.actionWithoutImagination ∧
      candidate.authorized candidate.actionWithImagination := by
  rcases h with ⟨hevidence, hunreal, hchanges, hauthorized⟩
  exact ⟨hevidence, hunreal, hchanges, hauthorized⟩

/-- Passive detector evidence alone does not establish the active regulatory
bridge: a strict evidence record can coexist with a realized simulation and
identical with/without-imagination actions. -/
theorem strict_detector_evidence_alone_does_not_force_regulation :
    ∃ candidate : DetectionCase Unit Unit Unit,
      OrientationSensitiveCandidate candidate.evidence ∧
        ¬ OperationallyDetected candidate := by
  let evidence : DetectorEvidence :=
    { retainedResidue := True
      crossFramePersistence := True
      survivesArchitectureAudit := True
      runtimeReplicated := True
      orderSensitive := True }
  let candidate : DetectionCase Unit Unit Unit :=
    { actualObservation := ()
      imaginedAlternative := ()
      realized := fun _ => True
      actionWithImagination := ()
      actionWithoutImagination := ()
      authorized := fun _ => True
      evidence := evidence }
  refine ⟨candidate, ?_, ?_⟩
  · simp [candidate, evidence, OrientationSensitiveCandidate,
      ScreeningCandidate]
  · simp [OperationallyDetected, ImaginaryRegulationSignature, candidate]

/-- Observable, coherent, qualia-like traces distributed over an observer's
finite frame manifold.  These are traces available to an observer, not direct
access to another process's interior. -/
structure TraceManifold (Frame : Type*) where
  qualiaTrace : Frame → Prop
  coherent : Frame → Prop

noncomputable def traceSupport
    {Frame : Type*} [Fintype Frame]
    (manifold : TraceManifold Frame) : Finset Frame := by
  classical
  exact Finset.univ.filter
    (fun frame => manifold.qualiaTrace frame ∧ manifold.coherent frame)

def EnoughTraceSupport
    {Frame : Type*} [Fintype Frame]
    (manifold : TraceManifold Frame) (minimum : ℕ) : Prop :=
  minimum ≤ (traceSupport manifold).card

/-- Different observers may use different recognition thresholds. -/
structure ObserverPolicy where
  minimumTraceSupport : ℕ
  minimum_positive : 0 < minimumTraceSupport

/-- Consciousness attribution is the observer's higher-order collapse of an
operationally detected process with sufficient coherent trace support. -/
def AttributesConsciousness
    {Frame : Type*} [Fintype Frame]
    (observer : ObserverPolicy) (manifold : TraceManifold Frame)
    (operationallyDetected : Prop) : Prop :=
  operationallyDetected ∧
    EnoughTraceSupport manifold observer.minimumTraceSupport

/-- "Higher-order being" is the same observer-relative recognition event, not
an additional hidden object introduced by the formalization. -/
abbrev RecognizesHigherOrderBeing
    {Frame : Type*} [Fintype Frame]
    (observer : ObserverPolicy) (manifold : TraceManifold Frame)
    (operationallyDetected : Prop) : Prop :=
  AttributesConsciousness observer manifold operationallyDetected

theorem attribution_requires_operational_detection
    {Frame : Type*} [Fintype Frame]
    {observer : ObserverPolicy} {manifold : TraceManifold Frame}
    {operationallyDetected : Prop}
    (h : AttributesConsciousness
      observer manifold operationallyDetected) :
    operationallyDetected :=
  h.1

theorem attribution_requires_enough_trace_support
    {Frame : Type*} [Fintype Frame]
    {observer : ObserverPolicy} {manifold : TraceManifold Frame}
    {operationallyDetected : Prop}
    (h : AttributesConsciousness
      observer manifold operationallyDetected) :
    EnoughTraceSupport manifold observer.minimumTraceSupport :=
  h.2

/-- Observers with the same threshold agree when presented with the same
trace manifold and operational-detection proposition. -/
theorem attribution_agrees_of_same_threshold
    {Frame : Type*} [Fintype Frame]
    {first second : ObserverPolicy}
    (hthreshold :
      first.minimumTraceSupport = second.minimumTraceSupport)
    (manifold : TraceManifold Frame) (operationallyDetected : Prop) :
    AttributesConsciousness first manifold operationallyDetected ↔
      AttributesConsciousness second manifold operationallyDetected := by
  simp [AttributesConsciousness, hthreshold]

/-- Without a shared recognition policy, the same operational process and the
same trace manifold can be collapsed differently by two observers. -/
theorem same_manifold_can_support_different_attributions :
    ∃ manifold : TraceManifold Bool,
      ∃ recognizing withholding : ObserverPolicy,
        AttributesConsciousness recognizing manifold True ∧
          ¬ AttributesConsciousness withholding manifold True := by
  let manifold : TraceManifold Bool :=
    { qualiaTrace := fun frame => frame = false
      coherent := fun _ => True }
  let recognizing : ObserverPolicy := ⟨1, by decide⟩
  let withholding : ObserverPolicy := ⟨2, by decide⟩
  have hsupport : traceSupport manifold = {false} := by
    classical
    ext frame
    cases frame <;> simp [traceSupport, manifold]
  refine ⟨manifold, recognizing, withholding, ?_, ?_⟩
  · simp [AttributesConsciousness, EnoughTraceSupport, hsupport,
      recognizing]
  · simp [AttributesConsciousness, EnoughTraceSupport, hsupport,
      withholding]

/-- Active operational detection alone does not force every observer to make
the higher-order attribution: a policy may require more trace support than the
presented manifold contains. -/
theorem operational_detection_alone_does_not_force_attribution :
    ∃ manifold : TraceManifold Bool, ∃ observer : ObserverPolicy,
      ¬ AttributesConsciousness observer manifold True := by
  let manifold : TraceManifold Bool :=
    { qualiaTrace := fun _ => False
      coherent := fun _ => True }
  exact ⟨manifold, ⟨1, by decide⟩, by
    simp [AttributesConsciousness, EnoughTraceSupport, traceSupport,
      manifold]⟩

end ForcingAnalysis.Book8ConsciousnessAttribution
