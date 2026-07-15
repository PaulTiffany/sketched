/-
Forcing.lean — propositional Kripke–Joyal forcing over a topology on the
refinement preorder, per Def. force / Def. clauses of
forcing_correspondence_v15.

Key design choices, mapped to the paper's ledger:

* `Stab` is an abstract assignment on ATOMS only (Def. stab: "Stab is not
  defined for compound formulas").
* M-Pers is the typeclass `Persistent V`. It is consumed exactly where the
  paper says: to make the stability sets A_φ sieves (well-formedness) —
  see `stabPP`.
* `Forces` returns a bundled `PersistentPred`, so persistence (lem:pers)
  is carried by construction through the recursion; the atomic persistence
  step is the pullback-stability argument (`coverPred`).
* Consistency and deciding-set density (lem:dec) are proved below;
  deciding density is classical (uses `Classical.byContradiction`).
-/

import ForcingKernel.Site

namespace ForcingKernel

open Refines

variable {P : Type u} [Refines P] {α : Type v}

/-- Propositional formulas over an atomic vocabulary. -/
inductive Formula (α : Type v) where
  | atom : α → Formula α
  | and : Formula α → Formula α → Formula α
  | or : Formula α → Formula α → Formula α
  | not : Formula α → Formula α

/-- A predicate on conditions that persists under refinement. -/
structure PersistentPred (P : Type u) [Refines P] where
  holds : P → Prop
  persist : ∀ {p q}, holds p → q ⊑ p → holds q

/-- The restriction of a persistent predicate below `p` is a sieve. -/
def PersistentPred.sieve (f : PersistentPred P) (p : P) : Sieve P p where
  mem q := q ⊑ p ∧ f.holds q
  le_of_mem h := h.1
  down h hr := ⟨Refines.trans hr h.1, f.persist h.2 hr⟩

/-- Atomic stability assignment (Def. stab, atoms only). -/
structure StabAssignment (P : Type u) (α : Type v) [Refines P] where
  Stab : P → α → Prop

/-- (M-Pers): stability persists under admissible refinement. The
highest-leverage postulate of the paper, as a typeclass so every
consumer names it. -/
class Persistent (V : StabAssignment P α) : Prop where
  persist : ∀ {p q : P} {a : α}, V.Stab p a → q ⊑ p → V.Stab q a

/-- The stability predicate of an atom, persistent by (M-Pers). This is
where M-Pers is consumed for well-formedness: without it A_φ is not a
sieve (v15 ledger, lem:pers row). -/
def stabPP (V : StabAssignment P α) [Persistent V] (a : α) : PersistentPred P where
  holds p := V.Stab p a
  persist h hq := Persistent.persist h hq

/-- "The sieve of f below p is a J-cover" — persistent in p, by pullback
stability plus supersieve monotonicity. This single lemma is the atomic
persistence step of lem:pers. -/
def coverPred (J : Topology P) (f : PersistentPred P) : PersistentPred P where
  holds p := J.covers p (f.sieve p)
  persist {p q} hp hq :=
    J.mono (J.pull hq (f.sieve p) hp)
      (fun r hr => ⟨hr.1, hr.2.2⟩)

def andPP (f g : PersistentPred P) : PersistentPred P where
  holds p := f.holds p ∧ g.holds p
  persist h hq := ⟨f.persist h.1 hq, g.persist h.2 hq⟩

def orPP (f g : PersistentPred P) : PersistentPred P where
  holds p := f.holds p ∨ g.holds p
  persist h hq := h.elim (fun h1 => Or.inl (f.persist h1 hq))
    (fun h2 => Or.inr (g.persist h2 hq))

/-- The universal-refinement negation clause. -/
def notPP (f : PersistentPred P) : PersistentPred P where
  holds p := ∀ q, q ⊑ p → ¬ f.holds q
  persist h hq := fun r hr => h r (Refines.trans hr hq)

/-- **Kripke–Joyal forcing** (Def. force + Def. clauses):
  * `p ⊩ atom a` iff the stability sieve A_a(p) is a J-cover;
  * `∧` componentwise; `∨` via the cover of the disjunction sieve;
  * `¬` is the universal-refinement clause.
Persistence (lem:pers, first half) holds by construction. -/
def Forces (J : Topology P) (V : StabAssignment P α) [Persistent V] :
    Formula α → PersistentPred P
  | .atom a => coverPred J (stabPP V a)
  | .and φ ψ => andPP (Forces J V φ) (Forces J V ψ)
  | .or φ ψ => coverPred J (orPP (Forces J V φ) (Forces J V ψ))
  | .not φ => notPP (Forces J V φ)

variable (J : Topology P) (V : StabAssignment P α) [Persistent V]

/-- lem:pers, first half: forcing is persistent (monotone down the order). -/
theorem forces_persist {φ : Formula α} {p q : P}
    (h : (Forces J V φ).holds p) (hq : q ⊑ p) : (Forces J V φ).holds q :=
  (Forces J V φ).persist h hq

/-- lem:pers, second half: no condition forces both φ and ¬φ. -/
theorem forces_consistent {φ : Formula α} {p : P} :
    ¬ ((Forces J V φ).holds p ∧ (Forces J V (.not φ)).holds p) :=
  fun ⟨h, hn⟩ => hn p (refl p) h

/-- A condition decides φ when it forces φ or forces ¬φ. -/
def decides (φ : Formula α) (q : P) : Prop :=
  (Forces J V φ).holds q ∨ (Forces J V (.not φ)).holds q

/-- lem:dec: deciding sets are order-dense (classical; uniform in φ —
the ¬-clause read contrapositively). -/
theorem deciding_dense (φ : Formula α) :
    ∀ p : P, ∃ q, q ⊑ p ∧ decides J V φ q := by
  intro p
  by_cases h : ∃ q, q ⊑ p ∧ (Forces J V φ).holds q
  · match h with
    | ⟨q, hq, hf⟩ => exact ⟨q, hq, Or.inl hf⟩
  · refine ⟨p, refl p, Or.inr ?_⟩
    intro q hq hf
    exact h ⟨q, hq, hf⟩

/-- A stabilized condition forces its atom: by (M-Pers) the stability set
below it is the maximal sieve, which lies in every topology. This is the
repaired (⇒) step of lem:atomic (v15: "density does not imply
Jadm-covering — the maximal sieve does"). -/
theorem stab_forces_atom {a : α} {q : P} (h : V.Stab q a) :
    (Forces J V (.atom a)).holds q := by
  show J.covers q ((stabPP V a).sieve q)
  have hEq : (stabPP V a).sieve q = Sieve.max q :=
    Sieve.ext fun r =>
      ⟨fun hr => hr.1, fun hr => ⟨hr, Persistent.persist h hr⟩⟩
  rw [hEq]
  exact J.max_mem q

end ForcingKernel
