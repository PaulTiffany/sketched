import Mathlib

/-!
Book4ImaginationDetector.lean — a finite contract for multiframe detection.

The detector is an instrument, not an oracle.  It retains five distinct
witnesses:

* a mixed finite-difference residue;
* persistence under at least two distinct frames;
* survival of an architecture/confound audit;
* runtime replication; and
* an optional order-sensitive commutator witness.

Even all five do not identify an unobserved imaginative traversal without an
additional bridge.  The final countermodel makes that non-identifiability
kernel explicit.
-/

namespace ForcingAnalysis.Book4ImaginationDetector

/-- The observable four-branch mixed finite difference. -/
def mixedResidue (base first second combined : ℝ) : ℝ :=
  combined - first - second + base

/-- An additive/separable response has zero mixed residue. -/
theorem mixedResidue_eq_zero_of_additive
    {base first second combined : ℝ}
    (hcombined : combined = first + second - base) :
    mixedResidue base first second combined = 0 := by
  rw [hcombined]
  unfold mixedResidue
  ring

/-- A bilinear interaction survives the four-branch cancellation exactly. -/
theorem mixedResidue_bilinear_positive_control (d₁ d₂ : ℝ) :
    mixedResidue 0 d₁ d₂ (d₁ + d₂ + d₁ * d₂) = d₁ * d₂ := by
  unfold mixedResidue
  ring

/-- A signal persists across frames when two distinct frames both exhibit it. -/
def CrossFramePersistent {Frame : Type*} (hit : Frame → Prop) : Prop :=
  ∃ first second, first ≠ second ∧ hit first ∧ hit second

/-- Confound-resistant persistence requires two distinct, unconfounded hits. -/
def UnconfoundedPersistence {Frame : Type*}
    (hit confounded : Frame → Prop) : Prop :=
  ∃ first second,
    first ≠ second ∧
      hit first ∧ hit second ∧
      ¬ confounded first ∧ ¬ confounded second

/-- Surviving the confound audit implies ordinary cross-frame persistence. -/
theorem unconfoundedPersistence_implies_crossFramePersistent
    {Frame : Type*} {hit confounded : Frame → Prop}
    (h : UnconfoundedPersistence hit confounded) :
    CrossFramePersistent hit := by
  rcases h with ⟨first, second, hne, hfirst, hsecond, _, _⟩
  exact ⟨first, second, hne, hfirst, hsecond⟩

/-- One observed frame cannot manufacture cross-frame persistence. -/
theorem one_frame_hit_not_persistent :
    ¬ CrossFramePersistent (fun frame : Bool => frame = false) := by
  intro h
  rcases h with ⟨first, second, hne, hfirst, hsecond⟩
  rw [hfirst, hsecond] at hne
  exact hne rfl

/-- Persistence alone can be entirely explained by a declared confound. -/
theorem persistent_signal_can_be_fully_confounded :
    ∃ hit confounded : Bool → Prop,
      CrossFramePersistent hit ∧
        ¬ UnconfoundedPersistence hit confounded := by
  refine ⟨(fun _ => True), (fun _ => True), ?_, ?_⟩
  · exact ⟨false, true, by decide, trivial, trivial⟩
  · intro h
    rcases h with ⟨first, second, _, _, _, hfirst, _⟩
    exact hfirst trivial

/-- The evidence channels retained by the operational detector. -/
structure DetectorEvidence where
  retainedResidue : Prop
  crossFramePersistence : Prop
  survivesArchitectureAudit : Prop
  runtimeReplicated : Prop
  orderSensitive : Prop

/-- The screening detector does not require an order experiment. -/
def ScreeningCandidate (evidence : DetectorEvidence) : Prop :=
  evidence.retainedResidue ∧
    evidence.crossFramePersistence ∧
    evidence.survivesArchitectureAudit ∧
    evidence.runtimeReplicated

/-- The strict detector additionally requires an order-sensitive witness. -/
def OrientationSensitiveCandidate (evidence : DetectorEvidence) : Prop :=
  ScreeningCandidate evidence ∧ evidence.orderSensitive

/-- A strict candidate exposes every screening premise separately. -/
theorem orientationSensitiveCandidate_components
    {evidence : DetectorEvidence}
    (h : OrientationSensitiveCandidate evidence) :
    evidence.retainedResidue ∧
      evidence.crossFramePersistence ∧
      evidence.survivesArchitectureAudit ∧
      evidence.runtimeReplicated ∧
      evidence.orderSensitive := by
  rcases h with ⟨⟨hresidue, hpersistent, haudit, hreplicated⟩, horder⟩
  exact ⟨hresidue, hpersistent, haudit, hreplicated, horder⟩

/-- A deliverable package binds detector evidence to reproducibility and
provenance controls. Package readiness is deliberately independent of a
positive candidate result: a well-controlled negative experiment is useful. -/
structure DetectorPackage where
  evidence : DetectorEvidence
  sourcePinned : Prop
  inputHashVerified : Prop
  thresholdsDeclared : Prop
  negativeControlPassed : Prop
  claimsImagination : Prop

/-- The operational package is ready when its source, input, thresholds, and
negative control are certified and it refuses the oracle claim. -/
def ReproduciblePackage (package : DetectorPackage) : Prop :=
  package.sourcePinned ∧
    package.inputHashVerified ∧
    package.thresholdsDeclared ∧
    package.negativeControlPassed ∧
    ¬ package.claimsImagination

theorem reproduciblePackage_components {package : DetectorPackage}
    (h : ReproduciblePackage package) :
    package.sourcePinned ∧
      package.inputHashVerified ∧
      package.thresholdsDeclared ∧
      package.negativeControlPassed ∧
      ¬ package.claimsImagination :=
  h

/-- Reproducibility does not require a positive detector event. This concrete
package is ready while every observational evidence channel remains false. -/
theorem reproducible_negative_result_is_deliverable :
    ∃ package : DetectorPackage,
      ReproduciblePackage package ∧
        ¬ ScreeningCandidate package.evidence := by
  let evidence : DetectorEvidence :=
    { retainedResidue := False
      crossFramePersistence := False
      survivesArchitectureAudit := True
      runtimeReplicated := True
      orderSensitive := False }
  let package : DetectorPackage :=
    { evidence := evidence
      sourcePinned := True
      inputHashVerified := True
      thresholdsDeclared := True
      negativeControlPassed := True
      claimsImagination := False }
  exact ⟨package, by simp [ReproduciblePackage, package], by
    simp [ScreeningCandidate, package, evidence]⟩

/-- An observational world carries evidence plus an unobserved latent label. -/
structure LatentWorld where
  evidence : DetectorEvidence
  imaginaryTraversal : Prop

/-- Observation deliberately forgets the latent label. -/
def observe (world : LatentWorld) : DetectorEvidence :=
  world.evidence

/--
No evidence record, even one satisfying the strict detector, identifies the
latent label by itself: two worlds can expose identical evidence and disagree
about whether an imaginative traversal occurred.
-/
theorem evidence_does_not_identify_imagination (evidence : DetectorEvidence) :
    ∃ withTraversal withoutTraversal : LatentWorld,
      observe withTraversal = evidence ∧
        observe withoutTraversal = evidence ∧
        withTraversal.imaginaryTraversal ∧
        ¬ withoutTraversal.imaginaryTraversal := by
  refine ⟨⟨evidence, True⟩, ⟨evidence, False⟩, rfl, rfl, trivial, ?_⟩
  simp

end ForcingAnalysis.Book4ImaginationDetector
