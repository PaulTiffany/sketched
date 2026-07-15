/-
Witness.lean — the observer–refinement witness kernel (Lean PS Track B:
toward deriving M-Pers instead of postulating it).

Two independent axes, deliberately NOT identified:
  * refinement persistence — down the condition order (M-Pers's axis);
  * observer invariance    — across an admissible class (materiality's axis).
`agreement_not_persistent` machine-checks that agreement on the second axis
does not purchase the first; `no_witness_realization` shows such agreement
admits no witness-restriction structure at all.

Sources (Principia Symbolica atlas, transcribed 2026-07-11; dual-source
bindings in verification/bindings.json):

  definition:bk8_observer_relative_artifact — a witness is an
    observer-relative artifact: a certificate visible inside one
    observer-frame, stable there for a bounded interval.
  definition:bk8_material_projection — materiality is CROSS-OBSERVER
    artifact stability over an admissible class, not visibility to all
    possible observers. (`material_persistence` is relative to an
    `AdmissibleClass` for exactly this reason.)
  definition:bk1_certified_type_preserving_symbolic_transport — transport
    carries a map, a preserved type signature σ, a preserved role ρ, and a
    loss class ℓ ∈ {exact, quotient, projective, interpretive}. Here σ and
    ρ are carried by the (p, a)-indexed typing of `transport` itself; ℓ is
    the `loss` field; their violations are `SquareDefect.typeMismatch` /
    `.roleMismatch`.
  proposition:bk1_nonvacuity_of_certified_transport — the class contains an
    exact and a genuinely projective transport; mirrored by `idTransport`
    and `ProjectiveExample`.
  proof:bk4_persistence_reflection_noncommutativity — persistence-type and
    reflection-type operators do NOT commute in general. Hence `natural` is
    a named LAW on `CertifiedTransport`, not an ambient truth, and
    `naturality_gap` keeps a concrete non-natural pre-transport as the
    regression witness.
  axiom:bk4_refinement_contraction /
  theorem:bk4_topological_persistence_under_refinement — Principia's
    ground for persistence under refinement: features above observer
    resolution survive. The `restrict` field is that ground's abstract
    shadow; connecting it to the contraction metric is open (LPS-O3).
  definition:bk1_shared_boundary_paradox /
  theorem:bk1_shared_paradox_bridge_datum — a co-detected obstruction is a
    co-reflexive bridge datum: it determines a COMMON expansion problem and
    licenses no identification of the observers.
  definition:bk4_test_time_integrative_expansion (C3 Boundary Agreement) —
    an expansion frame must retain the jointly witnessed boundary
    (`FrameExpansion.bridge`).

Interpretive boundary, stated once: none of this is claimed to be quantum
collapse. Whether the naturality defect models the quantum/collapsed
distinction stays an interpretive candidate until the witness system,
defect classification, and expansion theorem are formal and calibrated
(ledger LPS-O3).

Design note (records first): no composition/functoriality laws are imposed
on `restrict` or on transports yet — the finite theorems below do not need
them. Adding the coherence laws is part of LPS-O3's closure.
-/

import ForcingKernel.Forcing

namespace ForcingKernel

universe u v w x

/-- Loss class ℓ of a certified transport
(definition:bk1_certified_type_preserving_symbolic_transport). -/
inductive TransportLoss where
  | exact
  | quotient
  | projective
  | interpretive
  deriving DecidableEq, Repr

/-- Failure semantics: when an observer–refinement square does not commute,
the defect is preserved and classified, not discarded. `sharedBoundary` is
interpreted per theorem:bk1_shared_paradox_bridge_datum — a co-detected
obstruction demanding frame expansion, never observer identification. -/
inductive SquareDefect where
  | invalidRestriction
  | typeMismatch
  | roleMismatch
  | projectiveLoss
  | nonNatural
  | sharedBoundary
  deriving DecidableEq, Repr

/-- Observer-indexed witness system: `W o p a` is the type of certificates
by which observer `o` witnesses atom `a` at condition `p`
(definition:bk8_observer_relative_artifact), together with restriction of
certificates along refinement. Restriction is the constituted form of
M-Pers: the postulate relocates into this structure and is then DERIVED
(`stable_persist`), no longer assumed. -/
structure WitnessSystem (O : Type w) (P : Type u) [Refines P] (α : Type v) where
  W : O → P → α → Type x
  restrict : ∀ {o : O} {p q : P} {a : α}, q ⊑ p → W o p a → W o q a

variable {O : Type w} {P : Type u} [Refines P] {α : Type v}

/-- Observer-relative stability: `o` holds SOME certificate for `a` at `p`.
Propositional truncation of the witness type — the certificate identity is
forgotten here and remembered by the naturality law. -/
def WitnessSystem.Stable (WS : WitnessSystem.{u, v, w, x} O P α)
    (o : O) (p : P) (a : α) : Prop :=
  Nonempty (WS.W o p a)

/-- **Local M-Pers, derived** (was modeling postulate M-Pers): witness
restriction makes observer-relative stability persistent under refinement.
The forcing paper's highest-leverage postulate becomes a one-line
consequence of the restriction structure. -/
theorem WitnessSystem.stable_persist (WS : WitnessSystem.{u, v, w, x} O P α)
    {o : O} {p q : P} {a : α}
    (h : WS.Stable o p a) (hq : q ⊑ p) : WS.Stable o q a :=
  match h with | ⟨w⟩ => ⟨WS.restrict hq w⟩

/-- The stability assignment of a single observer. -/
def WitnessSystem.stabAssignment (WS : WitnessSystem.{u, v, w, x} O P α)
    (o : O) : StabAssignment P α :=
  ⟨fun p a => WS.Stable o p a⟩

/-- Every witness-backed stability assignment is `Persistent`: Kripke–Joyal
forcing (`Forces`) applies to it with M-Pers DISCHARGED rather than
consumed — the debt relocates to the existence of the witness system for
the deployed apparatus (open: LPS-O3). -/
instance WitnessSystem.persistent (WS : WitnessSystem.{u, v, w, x} O P α)
    (o : O) : Persistent (WS.stabAssignment o) where
  persist h hq := WS.stable_persist h hq

/-- Certified transport of witnesses between observers
(definition:bk1_certified_type_preserving_symbolic_transport): the map, its
loss class ℓ, and the NATURALITY law — restricting a transported witness is
transporting the restricted witness, so certificate identity is
route-independent across the observer–refinement square. Naturality is a
law precisely because Principia proves persistence/reflection operators do
not commute generically (proof:bk4_persistence_reflection_noncommutativity);
a witness map without it is a `PreTransport` carrying
`SquareDefect.nonNatural`. -/
structure CertifiedTransport (WS : WitnessSystem.{u, v, w, x} O P α)
    (o o' : O) where
  transport : ∀ {p : P} {a : α}, WS.W o p a → WS.W o' p a
  loss : TransportLoss
  natural : ∀ {p q : P} {a : α} (hq : q ⊑ p) (w : WS.W o p a),
    WS.restrict hq (transport w) = transport (WS.restrict hq w)

/-- A raw witness map with no naturality law: what a transport is BEFORE
certification. The gap between this and `CertifiedTransport` is real —
see `naturality_gap`. -/
structure PreTransport (WS : WitnessSystem.{u, v, w, x} O P α) (o o' : O) where
  transport : ∀ {p : P} {a : α}, WS.W o p a → WS.W o' p a

/-- **Preservation under transport**: stability moves forward along any
certified transport (mere existence of the map suffices at Prop level). -/
theorem CertifiedTransport.stable_preserved
    {WS : WitnessSystem.{u, v, w, x} O P α} {o o' : O}
    (t : CertifiedTransport WS o o') {p : P} {a : α}
    (h : WS.Stable o p a) : WS.Stable o' p a :=
  match h with | ⟨w⟩ => ⟨t.transport w⟩

/-- **Reflection** is the CONVERSE direction and is not free: target
stability certifying source stability. `ProjectiveExample` separates it
from preservation. -/
def CertifiedTransport.Reflects {WS : WitnessSystem.{u, v, w, x} O P α}
    {o o' : O} (t : CertifiedTransport WS o o') : Prop :=
  ∀ {p : P} {a : α}, WS.Stable o' p a → WS.Stable o p a

/-- Reflection holds when a certified transport BACK exists (the exact /
jointly conservative situation, in its simplest one-observer-pair form). -/
theorem CertifiedTransport.reflects_of_inverse
    {WS : WitnessSystem.{u, v, w, x} O P α} {o o' : O}
    (t : CertifiedTransport WS o o') (s : CertifiedTransport WS o' o) :
    t.Reflects :=
  fun h => s.stable_preserved h

/-- An admissible class of observers with certified transports along its
admissibility relation (the 𝔒 of definition:bk8_material_projection). -/
structure AdmissibleClass (WS : WitnessSystem.{u, v, w, x} O P α) where
  adm : O → O → Prop
  cert : ∀ {o o' : O}, adm o o' → CertifiedTransport WS o o'

/-- **Material persistence** (definition:bk8_material_projection): a
witnessed stabilization is stable across the admissible class AND down
refinement. By naturality the two routes around the square carry the SAME
certificate, not merely co-inhabited types. Materiality is relative to the
class 𝔒 — no claim about all possible observers is made. -/
theorem AdmissibleClass.material_persistence
    {WS : WitnessSystem.{u, v, w, x} O P α} (A : AdmissibleClass WS)
    {o o' : O} (h : A.adm o o') {p q : P} {a : α} (hq : q ⊑ p)
    (hs : WS.Stable o p a) : WS.Stable o' q a :=
  (A.cert h).stable_preserved (WS.stable_persist hs hq)

/-- The identity transport: the exact member of the class
(proposition:bk1_nonvacuity_of_certified_transport, first half). -/
def WitnessSystem.idTransport (WS : WitnessSystem.{u, v, w, x} O P α)
    (o : O) : CertifiedTransport WS o o :=
  ⟨fun w => w, .exact, fun _ _ => rfl⟩

/-- Frame expansion (definition:bk4_test_time_integrative_expansion, C3
Boundary Agreement + theorem:bk1_shared_paradox_bridge_datum): a frame o⁺
receiving both observers' witnesses such that JOINTLY witnessed boundary
facts receive one shared certificate — the co-reflexive bridge datum. The
expansion retains the boundary; it does not identify oA with oB, and no
interior isomorphism is asserted. -/
structure FrameExpansion (WS : WitnessSystem.{u, v, w, x} O P α)
    (oA oB oPlus : O) where
  liftA : CertifiedTransport WS oA oPlus
  liftB : CertifiedTransport WS oB oPlus
  bridge : ∀ {p : P} {a : α} (wA : WS.W oA p a) (wB : WS.W oB p a),
    liftA.transport wA = liftB.transport wB

/-- An expansion frame retains everything either observer witnesses (the
boundary survives; the obstruction becomes a common problem there). -/
theorem FrameExpansion.shared_stable
    {WS : WitnessSystem.{u, v, w, x} O P α} {oA oB oPlus : O}
    (E : FrameExpansion WS oA oB oPlus) {p : P} {a : α}
    (hA : WS.Stable oA p a) : WS.Stable oPlus p a :=
  E.liftA.stable_preserved hA

/-! ## Finite countermodels and separations

The two-condition poset: one coarse anchor with one refinement below it.
Everything refines the coarse condition; nothing else is comparable. -/

/-- Two conditions: the coarse anchor and one strict refinement. -/
inductive Cond where
  | coarse
  | fine
  deriving DecidableEq, Repr

instance : Refines Cond where
  le q p := q = p ∨ p = Cond.coarse
  refl _ := Or.inl rfl
  trans {p q r} hpq hqr := by
    cases hqr with
    | inl h => cases h; exact hpq
    | inr h => exact Or.inr h

/-- **Countermodel (regression): agreement is not persistence.** A
stability assignment on which EVERY pair of observers agrees at EVERY
condition — in particular at the coarse anchor — while stability still
fails below it. Cross-observer agreement at a condition, absent
refinement-natural witness structure, does not imply M-Pers: the two axes
are independent. -/
theorem agreement_not_persistent :
    ∃ Stab : Bool → Cond → Unit → Prop,
      (∀ o o' c a, Stab o c a ↔ Stab o' c a) ∧
      (∀ o, Stab o Cond.coarse ()) ∧
      (Cond.fine ⊑ Cond.coarse) ∧
      (∀ o, ¬ Stab o Cond.fine ()) := by
  refine ⟨fun _ c _ => c = Cond.coarse, fun _ _ _ _ => Iff.rfl, fun _ => rfl,
    Or.inr rfl, fun _ h => ?_⟩
  exact Cond.noConfusion h

/-- Corollary: no witness system realizes that agreement pattern — its
stability is not persistent, and `stable_persist` says every
witness-backed stability is. The countermodel is therefore also a proof
that the witness-restriction structure is genuinely MORE than agreement. -/
theorem no_witness_realization :
    ¬ ∃ WS : WitnessSystem.{0, 0, 0, 0} Bool Cond Unit,
        ∀ o c a, WS.Stable o c a ↔ c = Cond.coarse := by
  rintro ⟨WS, hWS⟩
  have h1 : WS.Stable true Cond.coarse () := (hWS _ _ _).mpr rfl
  have h0 : WS.Stable true Cond.fine () :=
    WS.stable_persist h1 (Or.inr rfl)
  exact Cond.noConfusion ((hWS _ _ _).mp h0)

namespace ProjectiveExample

/-- A witness system in which observer `false` holds no certificates and
observer `true` holds a trivial one everywhere. -/
def WS : WitnessSystem.{0, 0, 0, 0} Bool Cond Unit where
  W o _ _ := cond o PUnit Empty
  restrict _ w := w

/-- The projective member of the class
(proposition:bk1_nonvacuity_of_certified_transport, second half): a
certified transport from the empty-certificate observer to the full one.
It is (vacuously) natural and preserves stability — and does NOT reflect:
`loss = .projective` is earned, not decorative. -/
def proj : CertifiedTransport WS false true where
  transport w := w.elim
  loss := .projective
  natural _ w := w.elim

/-- **Preservation without reflection**: the projective transport carries
stability forward, and reflection fails — Stable true holds everywhere
while Stable false holds nowhere. `SquareDefect.projectiveLoss` names this
situation when it is a defect rather than a design. -/
theorem preserves_not_reflects :
    (∀ p a, WS.Stable false p a → WS.Stable true p a) ∧ ¬ proj.Reflects := by
  constructor
  · intro p a h
    exact proj.stable_preserved h
  · intro hrefl
    obtain ⟨w⟩ := hrefl (p := Cond.coarse) (a := ()) ⟨PUnit.unit⟩
    exact w.elim

end ProjectiveExample

namespace NaturalityGap

/-- Certificates are booleans at every site; restriction to the fine
condition FORGETS the certificate (collapses it to `false`). -/
def WS : WitnessSystem.{0, 0, 0, 0} Bool Cond Unit where
  W _ _ _ := Bool
  restrict {_ _ q _} _ w := match q with
    | Cond.coarse => w
    | Cond.fine => false

/-- A pre-transport that flips the certificate. Stability is preserved at
every condition (Bool is inhabited), yet the square does not commute. -/
def flip : PreTransport WS false true := ⟨fun w => !w⟩

/-- **The naturality gap is real** (the non-natural regression witness):
restricting the transported certificate and transporting the restricted
one disagree. This pre-transport can never be upgraded to a
`CertifiedTransport`; its defect class is `SquareDefect.nonNatural`. The
defect is PRESERVED here as a machine-checked witness, per the discipline
that a failed square is information. -/
theorem naturality_defect :
    WS.restrict (o := true) (p := Cond.coarse) (q := Cond.fine) (a := ())
        (Or.inr rfl) (flip.transport (p := Cond.coarse) (a := ()) true)
      ≠ flip.transport (p := Cond.fine) (a := ())
          (WS.restrict (o := false) (p := Cond.coarse) (q := Cond.fine)
            (a := ()) (Or.inr rfl) true) := by
  intro h
  exact Bool.noConfusion h

end NaturalityGap

end ForcingKernel
