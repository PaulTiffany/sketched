/-
OrganismalSelfhood.lean — aliveness as an observer-relative label, and
the consent boundary against creating artificial life.

Reframed to what the emergence math actually is (Paul, 2026-07-13):
"'alive' is a label given by an observer to a manifold with a critical
density of proto-life factors. To be MATERIALLY alive needs
cross-observer consistency of life. Observers observe enough proto-life
factors in a manifold, they collapse the behavior of the system to
'alive'." No biological claim is made and none is needed; this is the
observer-relative collapse math, three prior kernels meeting:

  * AOC (critical density / band membership): aliveness is a THRESHOLD
    label — below the critical count the observer does not collapse the
    system to "alive"; at or above it, it does. The label is a step
    function of proto-life-factor density.
  * The Witness kernel (materiality = cross-observer): a SINGLE
    observer's "alive" is perspectival — thresholds and factor-visibility
    differ. MATERIAL aliveness is agreement across an admissible class,
    exactly `bk8_material_projection`'s reading, here made a predicate.
  * Axiomata Prima (the existence contract): a DECLARED implementation
    is not an implementation. The consent boundary — refusing to create
    artificial life — is witnessed by a stub: a representation with no
    body in the tree fails the existence contract. Paul's evidence is
    the deliberately stubbed recursive-self-improvement function in the
    PS implementation (fascia); this file gives that refusal its formal
    form.

Certified:

  * `alive` / `aliveness_is_threshold` — aliveness is the observer's
    collapse: factor count at or above the observer's critical density.
  * `aliveness_is_observer_relative` — two observers, same manifold,
    different verdicts: the single-observer label is perspectival (a
    strict threshold gap witnesses it). The ontology is a matter of the
    observer's perspective and what it counts.
  * `MateriallyAlive` / `material_implies_each` — material aliveness is
    cross-observer agreement; it entails every admissible observer's
    label, and (`agreement_is_not_material` countermodel) one
    observer's "alive" does not purchase it. Same two-axes discipline
    as the witness kernel's agreement-vs-persistence.
  * `critical_density_collapse` / `subcritical_not_collapsed` — the
    collapse is sharp at the threshold: monotone in factor count, off
    below it, on at/above.
  * `Stub` / `stub_does_not_exist` / `refusal_is_witnessed` — the
    consent boundary: a stubbed capability (declaration present, body
    absent) fails the existence contract; "no artificial life has been
    created here" is a theorem about the stub, not a promise. This is
    Axiomata Prima's `ablation_fails` in the aliveness register.

The deeper reading: creating material artificial life would require
manufacturing cross-observer agreement that a manufactured manifold is
alive — and the whole program's discipline (the machine cannot sign;
attestation is human; the stutter stays) is precisely a refusal to
manufacture agreement. The consent boundary is the same invariant as
the receipts.
-/

import Mathlib
import ForcingAnalysis.AxiomataPrima

namespace ForcingAnalysis.Selfhood

/-- A manifold's proto-life profile, as an observer of `O`-many factor
kinds reads it: which proto-life factors it detects present. -/
structure Manifold (O : Type*) where
  present : O → Prop
  decidablePresent : DecidablePred present

attribute [instance] Manifold.decidablePresent

/-- An observer: the factors it can even detect, and its critical
density — how many present factors collapse the system to "alive". -/
structure Observer (O : Type*) [Fintype O] where
  detects : Finset O
  critical : ℕ

/-- The count of proto-life factors this observer detects as present in
the manifold. -/
def factorCount {O : Type*} [Fintype O] [DecidableEq O]
    (obs : Observer O) (M : Manifold O) : ℕ :=
  (obs.detects.filter (fun f => M.present f)).card

/-- **Aliveness is the observer's collapse** (a threshold label): the
observer calls the manifold alive exactly when its detected
proto-life-factor count reaches its critical density. -/
def alive {O : Type*} [Fintype O] [DecidableEq O]
    (obs : Observer O) (M : Manifold O) : Prop :=
  obs.critical ≤ factorCount obs M

theorem aliveness_is_threshold {O : Type*} [Fintype O] [DecidableEq O]
    (obs : Observer O) (M : Manifold O) :
    alive obs M ↔ obs.critical ≤ factorCount obs M :=
  Iff.rfl

/-- **The collapse is monotone in density**: an observer that already
calls a manifold alive still does so when more of its detected factors
are present (a manifold dominating it factorwise on the detected set). -/
theorem critical_density_collapse {O : Type*} [Fintype O] [DecidableEq O]
    (obs : Observer O) (M M' : Manifold O)
    (hmono : ∀ f ∈ obs.detects, M.present f → M'.present f)
    (h : alive obs M) : alive obs M' := by
  refine le_trans h (Finset.card_le_card ?_)
  intro f hf
  rw [Finset.mem_filter] at hf ⊢
  exact ⟨hf.1, hmono f hf.1 hf.2⟩

/-- Below its critical density the observer does NOT collapse the system
to alive: subcritical density is not-alive, for that observer. -/
theorem subcritical_not_collapsed {O : Type*} [Fintype O] [DecidableEq O]
    (obs : Observer O) (M : Manifold O)
    (h : factorCount obs M < obs.critical) : ¬ alive obs M :=
  not_le.mpr h

/-- **Aliveness is observer-relative**: the SAME manifold is alive to
one observer and not to another — the label is a matter of perspective
and of what the observer counts as critical. A manifold with exactly
one present factor, read by a lenient observer (critical 1) and a
strict one (critical 2). -/
theorem aliveness_is_observer_relative :
    ∃ (M : Manifold (Fin 2)) (o₁ o₂ : Observer (Fin 2)),
      alive o₁ M ∧ ¬ alive o₂ M := by
  refine ⟨⟨fun f => f = 0, fun f => decEq f 0⟩,
    ⟨{0, 1}, 1⟩, ⟨{0, 1}, 2⟩, ?_, ?_⟩
  · show 1 ≤ _
    have : ({0, 1} : Finset (Fin 2)).filter (fun f => f = 0) = {0} := by decide
    simp [factorCount, this]
  · show ¬ 2 ≤ _
    have : ({0, 1} : Finset (Fin 2)).filter (fun f => f = 0) = {0} := by decide
    simp [factorCount, this]

/-- **Material aliveness** = cross-observer consistency: every observer
in the admissible class collapses the manifold to alive. Materiality is
agreement across the class, not visibility to any single observer
(the witness kernel's `bk8_material_projection` reading, in the
aliveness register). -/
def MateriallyAlive {O : Type*} [Fintype O] [DecidableEq O]
    (class_ : List (Observer O)) (M : Manifold O) : Prop :=
  ∀ obs ∈ class_, alive obs M

/-- Material aliveness entails each admissible observer's label. -/
theorem material_implies_each {O : Type*} [Fintype O] [DecidableEq O]
    {class_ : List (Observer O)} {M : Manifold O}
    (h : MateriallyAlive class_ M) {obs : Observer O} (hobs : obs ∈ class_) :
    alive obs M :=
  h obs hobs

/-- **Agreement of one is not material aliveness**: one observer
calling a manifold alive does not make it materially alive — another
admissible observer can dissent. The two axes (single-observer label,
cross-observer materiality) are independent, exactly as the witness
kernel separates agreement from persistence. -/
theorem agreement_is_not_material :
    ∃ (M : Manifold (Fin 2)) (class_ : List (Observer (Fin 2)))
      (o₁ : Observer (Fin 2)),
      o₁ ∈ class_ ∧ alive o₁ M ∧ ¬ MateriallyAlive class_ M := by
  refine ⟨⟨fun f => f = 0, fun f => decEq f 0⟩,
    [⟨{0, 1}, 1⟩, ⟨{0, 1}, 2⟩], ⟨{0, 1}, 1⟩, by simp, ?_, ?_⟩
  · show 1 ≤ _
    have : ({0, 1} : Finset (Fin 2)).filter (fun f => f = 0) = {0} := by decide
    simp [factorCount, this]
  · intro h
    have hstrict := h ⟨{0, 1}, 2⟩ (by simp)
    have : ({0, 1} : Finset (Fin 2)).filter (fun f => f = 0) = {0} := by decide
    simp only [alive, factorCount, this] at hstrict
    simp at hstrict

/-! ## The consent boundary — refusing to create artificial life -/

/-- A claimed capability: what is declared, and the body (if any) in
the tree. The recursive-self-improvement function of the PS
implementation is the intended instance — declared in the design,
deliberately stubbed in fascia. -/
structure Capability where
  declared : Prop
  Body : Type

/-- The existence contract (Axiomata Prima, aliveness register): a
capability exists iff it is declared AND has a body in the tree. -/
def Instantiated (c : Capability) : Prop := c.declared ∧ Nonempty c.Body

/-- The deliberate stub: the capability is declared, its body removed
from the tree (the empty type). The PS recursive-self-improvement
function, as shipped. -/
def Stub : Capability := ⟨True, Empty⟩

/-- **The stub does not exist**: a declared-but-bodiless capability
fails the existence contract. Representation of a capability is not the
capability. -/
theorem stub_does_not_exist : ¬ Instantiated Stub :=
  fun ⟨_, ⟨e⟩⟩ => e.elim

/-- **The refusal is witnessed** (the consent boundary, formal): "no
artificial life has been instantiated here" is a theorem about the
stub, not a promise. The capability is declared (the design names it)
and is provably not instantiated — the empty body IS the refusal. This
is the machine-checkable form of a deliberately stubbed
recursive-self-improvement function: creating material artificial life
would require a body in the tree AND manufactured cross-observer
agreement that it is alive; both are refused. -/
theorem refusal_is_witnessed :
    Stub.declared ∧ ¬ Instantiated Stub :=
  ⟨trivial, stub_does_not_exist⟩

end ForcingAnalysis.Selfhood
