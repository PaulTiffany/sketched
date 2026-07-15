/-
Spine.lean — the deployed-Stab witness construction over the spine model
(LPS-O3's named closure action).

The spine model is the deployed apparatus of the finite model checker
(verification/kernel/model_checker.py): the depth-2 binary tree of 7
conditions with atoms a (the left subtree — the refinement-closure of
node 0) and b (the leaves), refinement-closed valuations, Kripke–Joyal
forcing over J_nn and J_adm. Its Python persistence check (E2) verifies
lem:pers for finitely many formulas by enumeration, with M-Pers ASSERTED
of the valuation (`assert M.persistent()`).

This file replaces that assertion with a derivation. Certificates are
GENERATOR ANCHORS — proof-relevant data, records first: a certificate
that condition p stabilizes atom t is an anchor condition c together
with p ⊑ c and the fact that c generates t's valuation (a is anchored at
node 0; b at each leaf). Restriction transports the anchor along
refinement. From that structure:

  * `WitnessSystem.persistent` DERIVES M-Pers for the deployed Stab —
    the model checker's asserted invariant becomes a theorem
    (`stableA_a_iff` / `stableA_b_iff` verify the derived Stab is
    EXACTLY the checker's valuation: a = {0, 00, 01}, b = the leaves,
    with the negative space checked too);
  * `spine_forces_persist` promotes E2 from a finite enumeration PASS
    to an all-formulas theorem, uniform in the topology — one statement
    covering J_nn, J_adm, and every other topology on the spine;
  * `spine_stab_forces_atom` instantiates the repaired lem:atomic step.

Two of LPS-O3's "also remaining" items are discharged on the deployed
system:

  * FUNCTORIALITY: `restrict_functorial` / `restrict_refl` — anchor
    transport composes and respects identity (the coherence laws the
    Witness.lean design note deferred);
  * THE TTIE EXPANSION THEOREM: observers A and B hold structurally
    distinct certificates; the expansion frame's certificate type is a
    proof-truncation, PROVABLY at most one certificate per site
    (`plus_certificate_unique`) — so jointly witnessed boundary facts
    receive one shared certificate (`ttie_boundary_agreement`), the
    bridge law holds definitionally, and the lifts carry
    `loss := .quotient` honestly (certificate identity is quotiented,
    the fact is not). Per theorem:bk1_shared_paradox_bridge_datum the
    expansion licenses no identification of A with B.

Still open on LPS-O3 after this file: the full Surface transition-rule
typing (claim commitments, confidence dynamics, certified-persistent vs
currently-true), the connection of `restrict` to
axiom:bk4_refinement_contraction, and ε-approximate transport
(axiom:bk9_preconditions_for_reciprocal_cognition).
-/

import ForcingKernel.Witness

namespace ForcingKernel

/-- The 7 conditions of the spine model: the depth-2 binary tree.
`r` is the root; names follow the checker's addresses. -/
inductive Spine where
  | r
  | n0
  | n1
  | n00
  | n01
  | n10
  | n11
  deriving DecidableEq, Repr

namespace Spine

/-- `leB q p` iff q is a descendant-or-self of p (q refines p). -/
def leB : Spine → Spine → Bool
  | _, .r => true
  | .n0, .n0 => true
  | .n00, .n0 => true
  | .n01, .n0 => true
  | .n1, .n1 => true
  | .n10, .n1 => true
  | .n11, .n1 => true
  | .n00, .n00 => true
  | .n01, .n01 => true
  | .n10, .n10 => true
  | .n11, .n11 => true
  | _, _ => false

instance : Refines Spine where
  le q p := leB q p = true
  refl p := by cases p <;> rfl
  trans {x y z} h1 h2 := by
    revert h1 h2
    cases x <;> cases y <;> cases z <;> decide

instance (p q : Spine) : Decidable (p ⊑ q) :=
  inferInstanceAs (Decidable (leB p q = true))

/-- The leaves — atom b's generators. -/
def isLeaf : Spine → Bool
  | .n00 => true
  | .n01 => true
  | .n10 => true
  | .n11 => true
  | _ => false

end Spine

/-- The spine model's atomic vocabulary. -/
inductive SpineAtom where
  | a
  | b
  deriving DecidableEq, Repr

/-- Valuation generators (the checker's `V`, presented by anchors):
a is the refinement-closure of node 0; b is generated leafwise. -/
def spineGen : SpineAtom → Spine → Prop
  | .a, c => c = .n0
  | .b, c => Spine.isLeaf c = true

instance (t : SpineAtom) (c : Spine) : Decidable (spineGen t c) :=
  match t with
  | .a => inferInstanceAs (Decidable (c = .n0))
  | .b => inferInstanceAs (Decidable (Spine.isLeaf c = true))

/-- A deployed certificate: an anchor condition, the refinement to it,
and the fact that it generates the atom's valuation. Proof-relevant
data — the anchor is carried, not truncated. -/
structure SpineCert (p : Spine) (t : SpineAtom) where
  anchor : Spine
  refines : p ⊑ anchor
  generates : spineGen t anchor

/-- The observers of the expansion square: A and B hold anchor
certificates; `plus` is the expansion frame. -/
inductive Obs where
  | A
  | B
  | plus
  deriving DecidableEq, Repr

/-- Certificate types per observer: A and B carry anchors; the
expansion frame carries the proof-truncation (one certificate per
fact, by construction). -/
def SpineW : Obs → Spine → SpineAtom → Type
  | .A, p, t => SpineCert p t
  | .B, p, t => SpineCert p t
  | .plus, p, t => PLift (Nonempty (SpineCert p t))

/-- Anchor transport along refinement. -/
def restrictCert {p q : Spine} {t : SpineAtom} (hq : q ⊑ p)
    (w : SpineCert p t) : SpineCert q t :=
  ⟨w.anchor, Refines.trans hq w.refines, w.generates⟩

/-- **The deployed witness system** (LPS-O3's closure action): the
spine model's Stab, realized by generator-anchor certificates with
restriction by anchor transport. -/
def spineWS : WitnessSystem.{0, 0, 0, 0} Obs Spine SpineAtom where
  W := SpineW
  restrict {o _ _ _} hq w :=
    match o, w with
    | .A, w => restrictCert hq w
    | .B, w => restrictCert hq w
    | .plus, w => ⟨w.down.elim fun c => ⟨restrictCert hq c⟩⟩

/-- **Functoriality of restriction** (coherence law, deferred by the
Witness.lean design note; now proved for the deployed system): anchor
transport composes. -/
theorem restrict_functorial {o : Obs} {p q s : Spine} {t : SpineAtom}
    (hqp : q ⊑ p) (hsq : s ⊑ q) (w : SpineW o p t) :
    spineWS.restrict hsq (spineWS.restrict hqp w) =
      spineWS.restrict (Refines.trans hsq hqp) w := by
  cases o <;> cases w <;> rfl

/-- Restriction along the identity refinement is the identity. -/
theorem restrict_refl {o : Obs} {p : Spine} {t : SpineAtom}
    (w : SpineW o p t) :
    spineWS.restrict (Refines.refl p) w = w := by
  cases o <;> cases w <;> rfl

/-! ## The derived Stab matches the deployed valuation -/

/-- Observer A's stability at atom a is EXACTLY the checker's valuation
V(a) = the left subtree {0, 00, 01}. -/
theorem stableA_a_iff (p : Spine) :
    spineWS.Stable .A p .a ↔ (p = .n0 ∨ p = .n00 ∨ p = .n01) := by
  constructor
  · rintro ⟨⟨c, hle, hg⟩⟩
    revert hle hg
    cases p <;> cases c <;> decide
  · have mk : ∀ p : Spine, p ⊑ .n0 → spineWS.Stable .A p .a :=
      fun p h => ⟨⟨.n0, h, rfl⟩⟩
    rintro (rfl | rfl | rfl) <;> exact mk _ (by decide)

/-- Observer A's stability at atom b is EXACTLY the checker's valuation
V(b) = the leaves. -/
theorem stableA_b_iff (p : Spine) :
    spineWS.Stable .A p .b ↔
      (p = .n00 ∨ p = .n01 ∨ p = .n10 ∨ p = .n11) := by
  constructor
  · rintro ⟨⟨c, hle, hg⟩⟩
    revert hle hg
    cases p <;> cases c <;> decide
  · have mk : ∀ p : Spine, Spine.isLeaf p = true → spineWS.Stable .A p .b :=
      fun p h => ⟨⟨p, Refines.refl p, h⟩⟩
    rintro (rfl | rfl | rfl | rfl) <;> exact mk _ (by decide)

/-- The negative space is real: the right inner node does not stabilize
atom a — the derived Stab is not trivially full. -/
theorem stableA_a_fails_right : ¬ spineWS.Stable .A .n1 .a := by
  intro h
  have := (stableA_a_iff .n1).mp h
  revert this
  decide

/-! ## The forcing capstones: M-Pers derived, not asserted -/

/-- The deployed stability assignment of observer A — the checker's
Stab, with `Persistent` DERIVED via the witness system rather than
asserted (`assert M.persistent()` becomes a theorem). -/
def deployedStab : StabAssignment Spine SpineAtom :=
  spineWS.stabAssignment .A

instance : Persistent deployedStab :=
  WitnessSystem.persistent spineWS .A

/-- **E2, promoted**: Kripke–Joyal forcing over the spine model is
persistent for ALL formulas and EVERY topology (in particular J_nn and
J_adm) — the model checker's finite enumeration, as one theorem, with
M-Pers earned by the certificate structure. -/
theorem spine_forces_persist (J : Topology Spine)
    {φ : Formula SpineAtom} {p q : Spine}
    (h : (Forces J deployedStab φ).holds p) (hq : q ⊑ p) :
    (Forces J deployedStab φ).holds q :=
  forces_persist J deployedStab h hq

/-- The repaired lem:atomic step, deployed: a stabilized spine condition
forces its atom in every topology. -/
theorem spine_stab_forces_atom (J : Topology Spine) {t : SpineAtom}
    {q : Spine} (h : deployedStab.Stab q t) :
    (Forces J deployedStab (.atom t)).holds q :=
  stab_forces_atom J deployedStab h

/-! ## The TTIE boundary-agreement expansion theorem (deployed) -/

/-- Lift of observer A into the expansion frame. Certificate identity
is quotiented — `loss := .quotient` is earned, the fact is preserved. -/
def liftAplus : CertifiedTransport spineWS .A .plus where
  transport w := ⟨⟨w⟩⟩
  loss := .quotient
  natural _ _ := rfl

/-- Lift of observer B into the expansion frame. -/
def liftBplus : CertifiedTransport spineWS .B .plus where
  transport w := ⟨⟨w⟩⟩
  loss := .quotient
  natural _ _ := rfl

/-- **The expansion frame exists**: both observers lift, and jointly
witnessed facts receive one shared certificate — the bridge law holds
definitionally because the frame's certificate type is proof-truncated. -/
def spineExpansion : FrameExpansion spineWS .A .B .plus where
  liftA := liftAplus
  liftB := liftBplus
  bridge _ _ := rfl

/-- The expansion frame holds AT MOST ONE certificate per site: "one
shared certificate" is a theorem about the frame, not a convention. -/
theorem plus_certificate_unique {p : Spine} {t : SpineAtom}
    (x y : SpineW .plus p t) : x = y := by
  cases x
  cases y
  rfl

/-- **TTIE C3 Boundary Agreement, deployed** (the expansion THEOREM of
LPS-O3's remaining list): a fact witnessed by BOTH observers is stable
in the expansion frame, every pair of lifted certificates coincides
(the co-reflexive bridge datum), and no identification of A with B is
made — only their boundary is retained. -/
theorem ttie_boundary_agreement {p : Spine} {t : SpineAtom}
    (hA : spineWS.Stable .A p t) (_hB : spineWS.Stable .B p t) :
    spineWS.Stable .plus p t ∧
      ∀ (wA : SpineW .A p t) (wB : SpineW .B p t),
        liftAplus.transport wA = liftBplus.transport wB :=
  ⟨spineExpansion.shared_stable hA, fun _ _ => rfl⟩

/-- Concrete instance at the deployed valuation: both observers witness
atom b at leaf 00, and the expansion frame resolves the co-detection
into a single certificate. -/
theorem shared_boundary_resolved_at_leaf :
    spineWS.Stable .plus .n00 .b := by
  have hA : spineWS.Stable .A .n00 .b := ⟨⟨.n00, Refines.refl _, by decide⟩⟩
  exact spineExpansion.shared_stable hA

end ForcingKernel
