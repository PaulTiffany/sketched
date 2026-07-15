/-
Schema.lean — the common commuting/equivariance interface (the
"forcing-over-a-site schema" of forcing_correspondence_v16's abstract:
"Both instantiate a common forcing-over-a-site schema").

Provenance note: the paper asserts the common schema in the abstract but
carries no labeled definition for it, so these definitions are new
definitional architecture (status D), not a transcription of a paper
statement. The ledger records the missing paper-side label as an open
item; when v17 names the schema, bind these definitions to that node.

Three graded forms, from strongest to weakest:

* `Commutes`   — a strict commuting square: transport a state, apply the
                 frontier operation, and you get exactly the transported
                 field result. Functional, total, on-the-nose equality.
* `Equivariant`— the group-action form: transporting then acting equals
                 acting then transporting, for every symmetry g. This is
                 `Commutes` uniformly in g (`equivariant_iff_commutes`).
* `RelationallyCommutes` — the partial/nondeterministic form: every
                 field step is matched by a frontier step between the
                 transported endpoints. This is preservation only; it
                 does not claim the frontier reflects steps back.

The forcing instance lives at the bottom of this file: persistence of
Kripke–Joyal forcing (lem:pers, first half) is `RelationallyCommutes`
with transport = the forcing predicate of φ, field steps = admissible
refinement moves, frontier steps = implication. The Lorentz-force
instance (ForcingAnalysis/Lorentz.lean) consumes `Equivariant` from this
same file — the two domains share the interface without being identified.
-/

import ForcingKernel.Forcing

namespace ForcingKernel

universe u v w

section Schema

variable {A : Type u} {B : Type v} {G : Type w}

/-- A strict commuting square: performing the field operation before
transport agrees with performing the frontier operation after. -/
def Commutes (transport : A → B)
    (fieldOp : A → A) (frontierOp : B → B) : Prop :=
  ∀ x, transport (fieldOp x) = frontierOp (transport x)

/-- Relational (one-sided) commutation: every field step is carried to a
frontier step between the transported endpoints. This is a preservation
clause only — reflection (frontier steps forcing field steps) is a
separate, stronger property and is deliberately not bundled here. -/
def RelationallyCommutes (transport : A → B)
    (fieldStep : A → A → Prop) (frontierStep : B → B → Prop) : Prop :=
  ∀ ⦃x x'⦄, fieldStep x x' → frontierStep (transport x) (transport x')

/-- Equivariance for a pair of `G`-actions: transport intertwines them.
No group structure is demanded — only what the instances actually use. -/
def Equivariant (actA : G → A → A) (actB : G → B → B)
    (f : A → B) : Prop :=
  ∀ g x, f (actA g x) = actB g (f x)

/-- Equivariance is exactly a commuting square for every symmetry. -/
theorem equivariant_iff_commutes
    {actA : G → A → A} {actB : G → B → B} {f : A → B} :
    Equivariant actA actB f ↔ ∀ g, Commutes f (actA g) (actB g) :=
  ⟨fun h g x => h g x, fun h g x => h g x⟩

/-- A strict commuting square degrades to relational commutation over the
graphs of the two operations: the functional form is the deterministic
special case of the relational one, not a separate notion. -/
theorem Commutes.relationallyCommutes
    {transport : A → B} {fieldOp : A → A} {frontierOp : B → B}
    (h : Commutes transport fieldOp frontierOp) :
    RelationallyCommutes transport
      (fun x x' => fieldOp x = x')
      (fun y y' => frontierOp y = y') := by
  intro x x' hx
  rw [← hx, h x]

end Schema

/-! ## The forcing instance

Persistence of Kripke–Joyal forcing is relational commutation: transport
a condition to the proposition "p forces φ", take field steps to be
admissible refinement moves `q ⊑ p`, and frontier steps to be
implication. `lem:pers` (first half) says exactly that this square
commutes relationally. Nothing here is reproved — this is `forces_persist`
re-exposed through the shared interface, so that the forcing side and the
Lorentz side (ForcingAnalysis/Lorentz.lean) visibly consume the same
schema. Consumes (M-Pers) via `[Persistent V]`, exactly as `Forces` does. -/

section ForcingInstance

variable {P : Type u} [Refines P] {α : Type v}

open Refines

/-- **Forcing persistence as relational commutation** (lem:pers, first
half, schema form): the forcing predicate of any formula transports
refinement moves to implications. -/
theorem forces_relationallyCommutes
    (J : Topology P) (V : StabAssignment P α) [Persistent V]
    (φ : Formula α) :
    RelationallyCommutes (Forces J V φ).holds
      (fun p q => q ⊑ p)
      (fun a b : Prop => a → b) :=
  fun _p _q hpq hp => (Forces J V φ).persist hp hpq

end ForcingInstance

end ForcingKernel
