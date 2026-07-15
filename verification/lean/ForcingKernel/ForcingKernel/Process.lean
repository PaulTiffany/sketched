/- 
Process.lean - plural process schemas and explicit jurisdiction.

The architecture deliberately keeps five coordinates independent:
domain, active process schema, adjudication mode, observer scope, and
transport loss. SRMF, OODA, OIOA, seasonal descriptions, and the
operational cycle are temporary schemas. None is an agent identity or a
total account of agency. Composition is an explicit relation, never an
inferred global choreography.
-/

import ForcingKernel.Witness

namespace ForcingKernel

universe u v

inductive Domain where
  | strategic
  | operational
  deriving DecidableEq, Repr

/-- A process is only a local step relation in a domain. -/
structure ProcessSchema (State : Type u) where
  domain : Domain
  Step : State -> State -> Prop

inductive ProcessKind where
  | srmf
  | ooda
  | oioa
  | seasonal
  | operationalCycle
  deriving DecidableEq, Repr

/-- Evidence that a schema is used on a bounded interval. Entry and exit
are explicit; no field identifies the schema with an agent. -/
structure ProcessUse (State : Type u) (Interval : Type v) where
  kind : ProcessKind
  schema : ProcessSchema State
  interval : Interval
  entered : State
  exited : Option State

inductive CorrespondenceScope where
  | selectedRoles
  | selectedSteps
  | boundedInterval
  | observerLocal
  deriving DecidableEq, Repr

/-- A scoped, lossy correspondence. In particular this does not state
A = B, totality, or phase exhaustiveness. -/
structure ProcessCorrespondence {State : Type u}
    (A B : ProcessSchema State) where
  relates : forall {a a' b b' : State}, A.Step a a' -> B.Step b b' -> Prop
  preservationScope : CorrespondenceScope
  lossClass : TransportLoss
  unmatchedA : State -> Prop
  unmatchedB : State -> Prop

inductive OperationalPhase where
  | operate
  | instrument
  | orchestrate
  | analyze
  deriving DecidableEq, Repr

/-- The autonomous operational loop. Its state type contains no strategic
phase, so it supplies no hidden SRMF/OODA handoff. -/
def OperationalNext : OperationalPhase -> OperationalPhase -> Prop
  | .operate, .instrument => True
  | .instrument, .orchestrate => True
  | .orchestrate, .analyze => True
  | .analyze, .operate => True
  | _, _ => False

def operationalSchema : ProcessSchema OperationalPhase :=
  { domain := .operational, Step := OperationalNext }

structure StrategicArtifact
    (Commitment ConstraintSet Provenance : Type) where
  commitment : Commitment
  constraints : ConstraintSet
  provenance : Provenance

structure OperationalArtifact
    (TraceSet MeasurementSet FailureSet Provenance : Type) where
  traces : TraceSet
  measurements : MeasurementSet
  failures : FailureSet
  provenance : Provenance

/-- An interface is an admitted relation between typed artifacts. It does
not manufacture intermediate phases or assert that transport succeeds. -/
structure ArtifactInterface (S O : Type) where
  admits : S -> O -> Prop
  lossClass : TransportLoss
  failure : S -> O -> SquareDefect -> Prop

inductive Season where
  | spring
  | summer
  | autumn
  | winter
  deriving DecidableEq, Repr

/-- Seasons classify trajectories relative to observers and intervals.
The relation may overlap, disagree, or be empty. -/
structure SeasonClassifier
    (Observer Trajectory Interval : Type) where
  SeasonHolds : Observer -> Season -> Trajectory -> Interval -> Prop

theorem seasons_may_overlap :
    exists C : SeasonClassifier Unit Unit Unit,
      C.SeasonHolds () .spring () () /\ C.SeasonHolds () .winter () () := by
  refine Exists.intro { SeasonHolds := fun _ _ _ _ => True } ?_
  exact And.intro trivial trivial

theorem no_season_may_apply :
    exists C : SeasonClassifier Unit Unit Unit,
      forall s, Not (C.SeasonHolds () s () ()) := by
  refine Exists.intro { SeasonHolds := fun _ _ _ _ => False } ?_
  exact fun _ h => h

inductive AdjudicationMode where
  | deterministic
  | llmJudge
  | human
  | composite
  | none
  deriving DecidableEq, Repr

structure ValidationRequirement where
  admissibleModes : AdjudicationMode -> Prop
  provenanceRequired : Bool
  abstentionPermitted : Bool
  repeatabilityRequired : Bool
  accountabilityRequired : Bool

/-- Human judgment is one competence region, not a mandatory endpoint. -/
def deterministicOnly : ValidationRequirement where
  admissibleModes m := m = .deterministic
  provenanceRequired := true
  abstentionPermitted := false
  repeatabilityRequired := true
  accountabilityRequired := false

theorem deterministicOnly_excludes_human :
    Not (deterministicOnly.admissibleModes .human) := by
  intro h
  exact AdjudicationMode.noConfusion h

inductive HumanAuthority where
  | interpret
  | consent
  | refuse
  | amend
  | account
  | handleException
  | terminate
  | setPurpose
  deriving DecidableEq, Repr

/-- Every theorem-bearing or operational result declares its jurisdiction.
All requested coordinates are separate fields. -/
structure Jurisdiction
    (Evidence ObserverScope FailureSemantics : Type) where
  domain : Domain
  activeProcess : Option ProcessKind
  evidenceConsumed : Evidence
  adjudicationMode : AdjudicationMode
  transportLoss : TransportLoss
  observerScope : ObserverScope
  reversible : Bool
  externalAuthorizationRequired : Bool
  failureSemantics : FailureSemantics

inductive ClaimProperty where
  | deterministicallyVerified
  | meaningful
  | llmApproved
  | trueClaim
  | humanApproved
  | consistent
  | internallyValid
  | normativelyAuthorized
  | strategicSuccess
  | operationalSuccess
  | strategicWisdom
  | processCompleted
  | processShouldContinue
  | crossObserverAgreement
  | refinementPersistence
  deriving DecidableEq, Repr

/-- Generic negative control: any two distinct validation properties can
be separated. Bridges between them require an additional theorem. -/
theorem properties_independent {a b : ClaimProperty} (h : Not (a = b)) :
    exists Holds : ClaimProperty -> Prop, Holds a /\ Not (Holds b) := by
  refine Exists.intro (fun x => x = a) (And.intro rfl ?_)
  intro hba
  exact h hba.symm

end ForcingKernel
