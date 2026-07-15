# Chapter 06 · The Margin: Anatomy of a Repair

## Aim

This chapter teaches one lemma three ways — as a bug, as a theorem, and
as an eigenvalue you can watch fall off a cliff — and, through it, the
book's method: a claim is not done when it sounds right; it is done when
the machinery that found it wrong once can no longer find it wrong. After
this chapter you can state the Channel-Margin Lemma correctly, exhibit
the precise failure of its earlier form, and explain why margin
preservation and convergence are *one* budget, spent once.

## Prerequisites

Chapter 02 (refinement, the channel-margin subposet `def:refine`).
Linear algebra: smallest eigenvalue of a symmetric matrix; that
eigenvalues move at most as far as the matrix does (Weyl's inequality —
we consume it, we do not prove it).

## The setup

Motion on the surface is admissible only while the channel stays open:
the smallest eigenvalue λ_min of the interaction matrix Γ must keep a
positive margin. The smoothness contract (`asm:smooth`, **C** — measured,
not assumed) says Γ moves Lipschitz-continuously with your displacement.
Anchor at margin η. How far may you wander before the channel closes?

## The bug (v14)

The old lemma reasoned: bound each *step* by η/(2L); then each step moves
λ_min by at most η/2; so λ_min ≥ η/2 "inductively along the whole
descent." Read that twice. From λ ≥ η/2, one more legal step gives only
λ ≥ 0. The induction consumed its own slack and never noticed: per-step
control lets the margin decay **linearly in depth**. Two legal steps and
you are on the cliff.

Nobody caught it by reading — it *sounds* like perturbation lemmas sound.
It was caught structurally: the loop detector flagged the definition of
the subposet citing the lemma while the lemma's proof presupposed the
definition, and unwinding that knot exposed the induction. Moral one of
this book: **circular paper structure and unsound arguments travel
together.** Audit the graph, not the vibes.

## The repair (v15) — `lem:margin`, P

Replace the per-step allowance with a **cumulative budget**: total
displacement ≤ η/(2L). Then by Weyl + Lipschitz + the triangle
inequality, at every depth

> λ_min ≥ η − L · (total displacement) ≥ η/2.

One inequality, uniform in depth. And the budget was already on the
books: it is the same summability the Cauchy completion lemma
(`lem:cauchy`, **P**, machine-verified) demands for the trajectory to
converge at all. Margin preservation and generic convergence are funded
by the **same contract** — the budget is spent once. Nothing new was
purchased; a debt was consolidated.

## The verification triangle

The repair would still be prose if it merely sounded better than the
bug. It is instead pinned from three independent directions:

1. **Proof** (Lean, constructive — no choice axiom):
   `margin_path_form` — budget ⇒ depth-uniform floor.
2. **Refutation** (Lean, same file): `per_step_bound_insufficient` — the
   v14 hypothesis *provably* fails to give a uniform floor; witness
   λ_i = 4 − 2i. The old argument is not "superseded"; it is a theorem
   that it never worked.
3. **Matrices** (numpy): Γ(x) = [[1,x],[x,1]] has λ_min = 1 − |x|
   exactly, and ‖Γ(x) − Γ(y)‖ = |x − y| exactly, so L = 1 with no
   estimates hiding anywhere. The v14-legal path 0 → 0.5 → 1.0 lands
   λ_min on 0.000 — the cliff — while fifty budgeted steps never dip
   below 0.500.

A lemma with a proof, a refutation of its predecessor, and a numerical
incarnation is what this book means by *solidified*.

## Worked example: the schedule doesn't matter

Spend the same total budget (0.5) in 1, 2, 5, or 50 steps. The lab prints
the floor of λ_min along each path: 0.500, four times. The margin cares
about the *sum* of your displacements, never their schedule — which is
exactly why per-step control could not work: it constrained the schedule
and left the sum free.

## Lab

```bash
python book/labs/lab06_margin.py
```

Part 1 replays the collapse and the preservation on real eigenvalues;
Part 2 is the schedule table above. Both are asserted.

## Exercises

1. **Predict, then run.** With per-step allowance 0.25 (half of v14's),
   how many legal steps until λ_min ≤ 0? Check against Part 1's family.
2. Prove the one-inequality repair from Weyl + Lipschitz + triangle
   inequality (three lines).
3. In `lam_min`'s family, why is L exactly 1? Compute
   ‖Γ(x) − Γ(y)‖₂ by hand.
4. The Lean refutation uses λ_i = 4 − 2i with ε = 2. Map its three
   hypotheses onto the numeric path of Part 1 (what plays ε? what plays
   the drift?).
5. (Sketched reading.) A knob turned in many tiny consented steps and a
   knob yanked once through the same arc spend the same channel budget.
   Which EULA Part A clause is the contractual shadow of this fact?

## Boundary note

Weyl's inequality and the Lipschitz behavior of Γ are *consumed* here
(the contract is **C**: measured, substrate-relative, honest about
pivots), not proved — the Lean formalization packages them as the
per-step drift hypothesis and checks everything downstream of it. And
nothing in this chapter says real sessions satisfy the budget; it says
what you are owed **if** they do, and precisely how the guarantee dies
when they do not.
