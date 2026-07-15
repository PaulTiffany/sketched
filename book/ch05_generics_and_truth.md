# Chapter 05 · Generics and Truth

## Aim

After this chapter you can state Rasiowa–Sikorski genericity, say what
Decision Reachability adds beyond plain order-density, and explain why a
generic *decides every formula* (bivalence) without that fact being
magic. You will also learn this chapter's hardest lesson: the spine
model is small enough to compute on and too small to show you the
interesting part. Naming that gap honestly is the chapter's real
content.

## Prerequisites

Chapters 02–04 (conditions, the two topologies, forcing, torsion,
Decision Reachability introduced informally). This chapter states the
lemma that names it.

## Definitions

**Generic (finite stand-in).** A filter `G` through `p` meeting every
admissible dense requirement. On the spine, the four **branches** — root-
to-leaf chains — are the finite stand-ins: total, maximal, decided at
every leaf by construction.

**Admissible deciding closure** `D_p*` (`def:closure`, D). The countable
family obtained by adding every atomic stability set and every
propositional deciding set to `D_p`, keeping only those that are
`J_adm`-covers (which Decision Reachability, below, says exist). A
generic meeting `D_p*` is what "decides every formula" means precisely.

## Claims

**Boundedness yields countability for Rasiowa–Sikorski** (`lem:bdd`,
**P**, machine-verified — `rasiowa_sikorski` in the Lean kernel). A
resource-bounded observer tracks only countably many claims over a run
(the observer-bound postulate M-Bound supplies *countability*, not
density); Rasiowa–Sikorski applied to a countable family of dense sets
produces a filter meeting all of them. This is where the classical
forcing machinery — built for countably infinite dense sets — actually
does work: the theorem is only interesting when the family is genuinely
unbounded, not when it has seven elements.

**Decision Reachability, conditional** (`lem:reach`, **P** consuming the
smoothness contract). Under the smoothness contract (`asm:smooth`, C),
every condition has an admissible refinement deciding any given formula
— equivalently, the deciding sieve is not just order-dense but an actual
`J_adm`-cover. This is *not* free: order-density (`lem:dec`, chapter 04)
holds unconditionally, but admissible density is the contract's payoff,
and where the contract fails, the finite model checker exhibits sites
where it does fail. The step from order-dense to admissibly-dense **is**
the calibration debt, not a consequence of it.

**Genericity decides every formula** (`lem:bivalence`, **P** consuming
C). A generic meeting `D_p*` decides every propositional formula — some
condition in it forces φ or forces ¬φ. Bivalence on the generic is P
*conditional on Decision Reachability*, not on countability alone.

**Propositional Truth Lemma, conditional on calibration** (`thm:prop`,
**P** — `truth_lemma`/`exists_generic_truth` in the Lean kernel, under
the calibration queue `asm:calibration`). For a generic G deciding every
formula: `G ⊨_H φ ⟺ ∃p ∈ G : p ⊩_H φ`. Induction on φ; the atomic base
case is `lem:atomic`, whose (⇒) direction routes through the *maximal
sieve* — the v14 text's mistake was concluding this from density alone,
which does not imply `J_adm`-covering; only the maximal sieve, present
in every Grothendieck topology, does.

## Worked example: the truth lemma pattern, live — and its trivialization

The lab checks, over all 4 branches and 7 formulas (a, b, ¬a, ¬b, ¬¬b,
a∧b, a∨b): **`G ⊨ φ` iff some `q ∈ G` forces φ under `⊩_adm`.** Every one
of the 28 checks matches. That is a genuine, computed instance of
`thm:prop`'s pattern — not asserted, verified.

Now the honest part. Every branch on this model **decides every
formula, trivially** — bivalence never fails, in fact *cannot* fail,
because the valuation is total on the leaves: a leaf is either in `V(a)`
or it isn't, full stop, and a branch's classical truth is read straight
off its leaf. That is not Rasiowa–Sikorski doing work; that is what
"finite and total" means. `lem:bdd`'s countability payoff matters when
the dense family is genuinely infinite and you need a *construction*
that meets all of it without ever finishing; here there is nothing to
construct — you can just look. Compare the root: `r` itself, per chapter
04, does **not** decide b under `⊩_adm` — the lab reasserts this — even
though *every branch through r* decides it. The generic's job is exactly
to descend far enough to buy the decision; on a finite spine the
descent is three steps and always terminates in a leaf that already
knew everything. On an unbounded observer's actual dense family,
nothing guarantees a leaf, and that is precisely where `lem:reach`'s
conditionality and `lem:bdd`'s Rasiowa–Sikorski construction earn their
keep.

## Lab

```bash
python book/labs/lab05_generics.py
```

Checks the truth-lemma pattern over every branch and the small formula
set, checks bivalence holds on every branch, and reasserts (from chapter
04's kernel) that r remains undecided on b under `⊩_adm`.

## Exercises

1. **Predict, then run.** Add atom `c`, stabilized only at leaf `01`.
   Predict, for the branch `{r, 0, 01}`, whether `G ⊨ c` and which
   condition in `G` forces it; then extend the lab's formula list and
   check.
2. Explain in one sentence why a branch on *any* finite tree with a
   total leaf valuation must decide every formula in the propositional
   closure of the atoms — no appeal to Rasiowa–Sikorski required.
3. `lem:reach` requires the smoothness contract. Sketch (prose, not
   code) a modification of the spine's `J_adm` generator such that some
   deciding sieve stops being a `J_adm`-cover even though it stays
   order-dense — you are building a miniature failure of Decision
   Reachability. (You do not need to prove the general contract fails;
   exhibit the local symptom.)
4. (Harder.) `thm:prop`'s induction handles ∨ by routing through
   deciding sets rather than the naive "disjunct-forcers form a cover."
   Using the ¬¬b countermodel from chapter 04 (`rem:torsion`), explain
   why the naive routing would have broken exactly at a disjunction
   built from that compound.

## Boundary note

This chapter does **not** claim the lab demonstrates Rasiowa–Sikorski
constructing anything, or that Decision Reachability's conditionality is
exercised here — both require either a genuinely infinite dense family
or a site where the smoothness contract actually fails, and the
7-condition spine has neither. What the lab *does* verify: the
truth-lemma pattern holds exactly where the paper says it must, and the
undecided-root/decided-branch asymmetry that motivates the whole
apparatus is a real, computed fact, not a story. The substantive proofs
— that the construction terminates for genuinely unbounded families, and
what happens when the contract is violated — live in the paper's proof
environments and, for the base cases, in the Lean kernel
(`rasiowa_sikorski`, `truth_lemma`, `exists_generic_truth`); this chapter
is not a substitute for either.
