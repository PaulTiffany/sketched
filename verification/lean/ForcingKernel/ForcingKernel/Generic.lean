/-
Generic.lean — filters, the Rasiowa–Sikorski construction, generic truth
on a branch, and the propositional Truth Lemma (thm:prop of
forcing_correspondence_v15).

Hypothesis accounting (the point of this file):

* (M-Pers) enters through `[Persistent V]`, inherited from Forcing.lean.
* (M-Bound) — the observer countability bound — enters as the surjection
  `enum : Nat → Formula α` in `exists_generic_truth` (lem:bdd).
* The Site Bound (lem:sitebound) enters as `hdense`: every J-cover is
  order-dense. For `J = generated G` with dense generators this is the
  theorem `site_bound`; here it is a named hypothesis so the truth lemma
  states its exact debt.
* Decision Reachability (lem:reach) does NOT appear: the abstract
  Rasiowa–Sikorski filter meets order-dense sets, and deciding sets are
  order-dense unconditionally (lem:dec). Reach is consumed only when one
  additionally demands that the generic traverse admissible moves — i.e.
  that the deciding sets be Jadm-covers. That demand lives outside this
  kernel, exactly as the paper's calibration queue says (item 8).
-/

import ForcingKernel.Forcing

namespace ForcingKernel

open Refines

variable {P : Type u} [Refines P] {α : Type v}

/-- A filter in the refinement order: upward-closed and downward-directed. -/
structure IsFilter (G : P → Prop) : Prop where
  up : ∀ {p q}, G p → p ⊑ q → G q
  directed : ∀ {p q}, G p → G q → ∃ r, G r ∧ r ⊑ p ∧ r ⊑ q

/-- **Rasiowa–Sikorski**: through any condition there is a filter meeting
every member of a countable family of order-dense sets. -/
theorem rasiowa_sikorski (p0 : P) (D : Nat → P → Prop)
    (hD : ∀ n p, ∃ q, q ⊑ p ∧ D n q) :
    ∃ G : P → Prop, IsFilter G ∧ G p0 ∧ ∀ n, ∃ q, G q ∧ D n q := by
  let chain : Nat → P :=
    fun n => Nat.rec p0 (fun k c => Classical.choose (hD k c)) n
  have step_le : ∀ n, chain (n + 1) ⊑ chain n :=
    fun n => (Classical.choose_spec (hD n (chain n))).1
  have step_D : ∀ n, D n (chain (n + 1)) :=
    fun n => (Classical.choose_spec (hD n (chain n))).2
  have chain_add : ∀ m k, chain (m + k) ⊑ chain m := by
    intro m k
    induction k with
    | zero => exact refl _
    | succ k ih => exact Refines.trans (step_le (m + k)) ih
  have chain_le : ∀ {m n}, m ≤ n → chain n ⊑ chain m := by
    intro m n h
    have hk : m + (n - m) = n := by omega
    rw [← hk]
    exact chain_add m (n - m)
  refine ⟨fun p => ∃ n, chain n ⊑ p, ⟨?_, ?_⟩, ⟨0, refl _⟩, ?_⟩
  · intro p q hp hpq
    match hp with
    | ⟨n, hn⟩ => exact ⟨n, Refines.trans hn hpq⟩
  · intro p q hp hq
    match hp, hq with
    | ⟨m, hm⟩, ⟨n, hn⟩ =>
      refine ⟨chain (Nat.max m n), ⟨Nat.max m n, refl _⟩, ?_, ?_⟩
      · exact Refines.trans (chain_le (Nat.le_max_left m n)) hm
      · exact Refines.trans (chain_le (Nat.le_max_right m n)) hn
  · intro n
    exact ⟨chain (n + 1), ⟨n + 1, refl _⟩, step_D n⟩

/-- Classical truth on a generic branch: atoms by eventual stabilization,
connectives classically (the bivalent reading of thm:prop). -/
def GModels (V : StabAssignment P α) (G : P → Prop) : Formula α → Prop
  | .atom a => ∃ q, G q ∧ V.Stab q a
  | .and φ ψ => GModels V G φ ∧ GModels V G ψ
  | .or φ ψ => GModels V G φ ∨ GModels V G ψ
  | .not φ => ¬ GModels V G φ

variable (J : Topology P) (V : StabAssignment P α) [Persistent V]

/-- **Propositional Truth Lemma** (thm:prop), with its debts as named
hypotheses:
* `hF` — G is a filter;
* `hdense` — Site Bound: every J-cover is dense (lem:sitebound);
* `hdec` — G meets every deciding set (bivalence input; supplied by
  Rasiowa–Sikorski below);
* `hstab` — G meets the stabilizer cover of any atom forced at a member
  (membership of the A_φ covers in the deciding closure D*_p). -/
theorem truth_lemma (G : P → Prop) (hF : IsFilter G)
    (hdense : ∀ {p} {S : Sieve P p}, J.covers p S → denseBelow p S)
    (hdec : ∀ φ : Formula α, ∃ q, G q ∧ decides J V φ q)
    (hstab : ∀ (a : α) (p : P), G p → (Forces J V (.atom a)).holds p →
      ∃ q, G q ∧ V.Stab q a) :
    ∀ φ : Formula α, GModels V G φ ↔ ∃ p, G p ∧ (Forces J V φ).holds p := by
  intro φ
  induction φ with
  | atom a =>
    constructor
    · intro h
      match h with
      | ⟨q, hGq, hs⟩ => exact ⟨q, hGq, stab_forces_atom J V hs⟩
    · intro h
      match h with
      | ⟨p, hGp, hf⟩ => exact hstab a p hGp hf
  | and φ ψ ihφ ihψ =>
    constructor
    · intro h
      match ihφ.mp h.1, ihψ.mp h.2 with
      | ⟨p1, hG1, hf1⟩, ⟨p2, hG2, hf2⟩ =>
        match hF.directed hG1 hG2 with
        | ⟨r, hGr, hr1, hr2⟩ =>
          exact ⟨r, hGr, forces_persist J V hf1 hr1, forces_persist J V hf2 hr2⟩
    · intro h
      match h with
      | ⟨p, hGp, hf1, hf2⟩ =>
        exact ⟨ihφ.mpr ⟨p, hGp, hf1⟩, ihψ.mpr ⟨p, hGp, hf2⟩⟩
  | or φ ψ ihφ ihψ =>
    constructor
    · intro h
      -- a forced disjunct makes the ∨-sieve maximal (v15 proof of thm:prop)
      have lift : ∀ p : P, G p →
          (orPP (Forces J V φ) (Forces J V ψ)).holds p →
          ∃ r, G r ∧ (Forces J V (.or φ ψ)).holds r := by
        intro p hGp hp
        refine ⟨p, hGp, ?_⟩
        show J.covers p ((orPP (Forces J V φ) (Forces J V ψ)).sieve p)
        have hEq : (orPP (Forces J V φ) (Forces J V ψ)).sieve p = Sieve.max p :=
          Sieve.ext fun r =>
            ⟨fun hr => hr.1,
             fun hr => ⟨hr, (orPP (Forces J V φ) (Forces J V ψ)).persist hp hr⟩⟩
        rw [hEq]
        exact J.max_mem p
      match h with
      | Or.inl hφ =>
        match ihφ.mp hφ with
        | ⟨p, hGp, hf⟩ => exact lift p hGp (Or.inl hf)
      | Or.inr hψ =>
        match ihψ.mp hψ with
        | ⟨p, hGp, hf⟩ => exact lift p hGp (Or.inr hf)
    · intro h
      match h with
      | ⟨p, hGp, hf⟩ =>
        -- v15 route through deciding sets (the v14 "cofinally" step is
        -- exactly what this replaces)
        apply Classical.byContradiction
        intro hcon
        have hnφ : ¬ GModels V G φ := fun hh => hcon (Or.inl hh)
        have hnψ : ¬ GModels V G ψ := fun hh => hcon (Or.inr hh)
        match hdec φ with
        | ⟨q1, hGq1, hd1⟩ =>
          have hq1 : (Forces J V (.not φ)).holds q1 := by
            cases hd1 with
            | inl hforce => exact absurd (ihφ.mpr ⟨q1, hGq1, hforce⟩) hnφ
            | inr hneg => exact hneg
          match hdec ψ with
          | ⟨q2, hGq2, hd2⟩ =>
            have hq2 : (Forces J V (.not ψ)).holds q2 := by
              cases hd2 with
              | inl hforce => exact absurd (ihψ.mpr ⟨q2, hGq2, hforce⟩) hnψ
              | inr hneg => exact hneg
            match hF.directed hGp hGq1 with
            | ⟨s1, hGs1, hs1p, hs1q1⟩ =>
              match hF.directed hGs1 hGq2 with
              | ⟨s, _, hss1, hsq2⟩ =>
                have hsp : s ⊑ p := Refines.trans hss1 hs1p
                have hsq1 : s ⊑ q1 := Refines.trans hss1 hs1q1
                -- the ∨-cover of s is a J-cover, hence dense, hence
                -- inhabited below s; its inhabitant refutes q1 or q2
                have hfs : (Forces J V (.or φ ψ)).holds s :=
                  forces_persist J V hf hsp
                have hds : denseBelow s
                    ((orPP (Forces J V φ) (Forces J V ψ)).sieve s) := hdense hfs
                match hds s (refl s) with
                | ⟨r, hrs, hmem⟩ =>
                  cases hmem.2 with
                  | inl hφr => exact hq1 r (Refines.trans hrs hsq1) hφr
                  | inr hψr => exact hq2 r (Refines.trans hrs hsq2) hψr
  | not φ ihφ =>
    constructor
    · intro h
      match hdec φ with
      | ⟨q, hGq, hd⟩ =>
        cases hd with
        | inl hforce => exact absurd (ihφ.mpr ⟨q, hGq, hforce⟩) h
        | inr hneg => exact ⟨q, hGq, hneg⟩
    · intro h
      match h with
      | ⟨p, hGp, hn⟩ =>
        intro hh
        match ihφ.mp hh with
        | ⟨q, hGq, hf⟩ =>
          match hF.directed hGp hGq with
          | ⟨r, _, hrp, hrq⟩ =>
            exact hn r hrp (forces_persist J V hf hrq)

/-- The atom-resolution requirement: stabilize the atom or force its
negation. Order-dense given the Site Bound. -/
def atomReq (a : α) (q : P) : Prop :=
  V.Stab q a ∨ (Forces J V (.not (.atom a))).holds q

theorem atomReq_dense
    (hdense : ∀ {p} {S : Sieve P p}, J.covers p S → denseBelow p S)
    (a : α) : ∀ p : P, ∃ q, q ⊑ p ∧ atomReq J V a q := by
  intro p
  by_cases h : ∃ q, q ⊑ p ∧ V.Stab q a
  · match h with
    | ⟨q, hq, hs⟩ => exact ⟨q, hq, Or.inl hs⟩
  · refine ⟨p, refl p, Or.inr ?_⟩
    intro t ht hf
    -- t forces the atom: its stability sieve is a J-cover, hence dense,
    -- hence inhabited — contradicting "no stabilizer below p"
    match (hdense hf).nonempty with
    | ⟨r, hr⟩ => exact h ⟨r, Refines.trans (hr.1) (ht), hr.2⟩

/-- The interleaved requirement family: deciding sets on even indices,
atom-resolution sets on odd indices (the countable deciding closure D*). -/
def interleave (enum : Nat → Formula α) (n : Nat) : P → Prop :=
  if n % 2 = 0 then decides J V (enum (n / 2))
  else match enum (n / 2) with
    | .atom a => atomReq J V a
    | _ => fun _ => True

/-- **Generic existence + truth** (lem:bdd + Rasiowa–Sikorski + thm:prop):
through any condition there is a filter on which classical truth coincides
with forcing. Debts: (M-Pers) via `[Persistent V]`; (M-Bound) via `enum`;
the Site Bound via `hdense`. Decision Reachability is not needed at this
abstraction level — see the file header. -/
theorem exists_generic_truth (p0 : P)
    (hdense : ∀ {p} {S : Sieve P p}, J.covers p S → denseBelow p S)
    (enum : Nat → Formula α) (henum : ∀ φ : Formula α, ∃ n, enum n = φ) :
    ∃ G : P → Prop, IsFilter G ∧ G p0 ∧
      ∀ φ : Formula α, GModels V G φ ↔ ∃ p, G p ∧ (Forces J V φ).holds p := by
  have hFdense : ∀ n p, ∃ q, q ⊑ p ∧ interleave J V enum n q := by
    intro n p
    by_cases hpar : n % 2 = 0
    · rw [interleave, if_pos hpar]
      exact deciding_dense J V (enum (n / 2)) p
    · rw [interleave, if_neg hpar]
      cases henumcase : enum (n / 2) with
      | atom a => exact atomReq_dense J V hdense a p
      | and φ ψ => exact ⟨p, refl p, trivial⟩
      | or φ ψ => exact ⟨p, refl p, trivial⟩
      | not φ => exact ⟨p, refl p, trivial⟩
  match rasiowa_sikorski p0 (interleave J V enum) hFdense with
  | ⟨G, hF, hG0, hmeets⟩ =>
    refine ⟨G, hF, hG0, ?_⟩
    -- recover the two hypothesis families from the interleaving
    have hdec : ∀ φ : Formula α, ∃ q, G q ∧ decides J V φ q := by
      intro φ
      match henum φ with
      | ⟨k, hk⟩ =>
        have h1 : (2 * k) % 2 = 0 := by omega
        have h2 : (2 * k) / 2 = k := by omega
        match hmeets (2 * k) with
        | ⟨q, hGq, hFq⟩ =>
          refine ⟨q, hGq, ?_⟩
          rw [interleave, if_pos h1, h2, hk] at hFq
          exact hFq
    have hstab : ∀ (a : α) (p : P), G p →
        (Forces J V (.atom a)).holds p → ∃ q, G q ∧ V.Stab q a := by
      intro a p hGp hf
      match henum (.atom a) with
      | ⟨k, hk⟩ =>
        have h1 : ¬ ((2 * k + 1) % 2 = 0) := by omega
        have h2 : (2 * k + 1) / 2 = k := by omega
        match hmeets (2 * k + 1) with
        | ⟨q, hGq, hFq⟩ =>
          rw [interleave, if_neg h1, h2, hk] at hFq
          cases hFq with
          | inl hs => exact ⟨q, hGq, hs⟩
          | inr hneg =>
            -- q forces ¬atom while p forces atom: directedness + persistence
            -- yield a contradiction
            match hF.directed hGp hGq with
            | ⟨r, _, hrp, hrq⟩ =>
              exact absurd (forces_persist J V hf hrp) (hneg r hrq)
    exact truth_lemma J V G hF hdense hdec hstab

end ForcingKernel
