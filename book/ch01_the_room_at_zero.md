# Chapter 01 · The Room at Zero

## Aim

After this chapter you can say precisely what `127.0.0.1` *is* in this
system — not as networking trivia but as mathematics: the unique point two
observers can share, why sharing it buys the ability to say "we agree"
and nothing more, and why a contract (not a theorem) is what seats *you*
there. You will be able to predict what the witness layer accepts and
rejects before running it.

## Prerequisites

None. This is the front door.

## Definitions

**Condition** (`def:cond`, D). A finite partial epistemic state — in
Sketched terms, a stage: which layers exist, who owns them, what has been
consented to so far. You always know only finitely much; a condition is
the honest record of that.

**Refinement.** `q ⊑ p` means q keeps everything p committed to and
resolves more. Work descends: you never un-know by refining.

**The wedge** (`lem:void` setup). Take two observers A and B whose
surfaces share *no* condition except the empty one — zero commitments,
the state before anything has been said. Glue the two surfaces at that
single shared top. Call the shared point the **void**, written 𝟙. The
order on the glued object is: A's order on A's side, B's order on B's
side, 𝟙 above everything, and **no cross-branch relations**.

**Depth.** Count refinement steps from 𝟙. The void is the unique
condition at depth 0; everything else is depth ≥ 1.

## Claims

**The void is the unique shared point** (`lem:void`, **P** —
machine-verified setup; see `verification/FINDINGS.md`). Any condition of
A's at depth ≥ 1 is incompatible with any condition of B's at depth ≥ 1:
a common refinement would have to live in both branches, and nothing
does. Consequently any filter — any coherent course of joint commitments —
lies entirely inside one branch (plus 𝟙).

**The shared point is forced to zeroth order** (`prop:zeroth`, **P**).
Not a design choice: the *only* thing shareable between disjoint
observers is the depth-0 condition. If you want a shared anything, the
math hands you exactly one candidate, and it is empty.

**Factoring** (`thm:factor`, **D**). Since occupancy of another's surface
is impossible below the void, any transfer of contingent content must
route through a third object both can address — a *medium*. (Chapter 07
is about what survives that trip. Spoiler: residues, never identity.)

## Worked example: what A and B can actually share

A has drawn three layers; B has drawn two. Can B see A's stage? No — B
would need to occupy a depth-≥1 condition of A's branch (`lem:void` says
never). Can A and B agree on anything? Yes — exactly the statements
forced *from the void*, the branch-invariant, pre-observational kernel:
"a stage has an owner," "consent precedes mutation." That is
**commensurability**: a common 𝟙 to quantify over, hence the ability to
*state* "we agree." It is not communication. Nothing contingent — no
layer, no palette, no gesture — crosses at depth 0.

Operationally the void is **localhost**. `127.0.0.1` has the same form
for everyone and a different referent for each — the address whose
universality is exactly commensurability and whose locality is exactly
branch privacy. Sketched's dev server binds there and the witness layer
checks it: `isZeroOrderOrigin` (in `src/witness/witness.ts`) accepts
loopback and rejects the public internet, because *the void is not out
there*.

## And then the contract

Everything above is neutral. The void is a shared *point*, not a person;
the math seats nobody. Sketched makes one move that the theorems do not make
for it: the EULA places **you** at the origin. This is a **D**-status
act — constitutive, not derived — and the code treats it that way: an
anchor (`anchor` in `src/witness/witness.ts`) carries `eulaAccepted`, and
`validateTrace` (in `src/witness/validate.ts`) rejects every trace whose
anchor lacks the contract, with the reason string telling you exactly
this story: *without it the anchor is neutral, not authority-bearing.*

Before the contract: commensurability. After: authority-origin. The room
exists either way; the contract decides that it is *your* room.

## Lab

The chapter's lab is the witness test suite:

```bash
npx vitest run src/witness
```

Watch four tests in particular: loopback accepted, `example.com`
rejected, the missing-contract rejection, and the trace that fails
because a gate admitted what a certificate refused.

## Exercises

1. **Predict, then run.** What does `validateTrace` say about a trace
   anchored at `http://localhost:5173` with `eulaAccepted: false`? Write
   your predicted reason string; then run the lab and compare. (The
   answer key already lives in the lab: `witness.test.ts`, "rejects an
   anchor without the first contract.")
2. `[::1]` is in the zero-order set. Say why in one sentence about
   *form vs. referent*.
3. (Proof sketch.) Show from the wedge order that a filter containing a
   condition of A's and a condition of B's, both depth ≥ 1, is
   impossible. Where exactly does downward-directedness fail?
4. (Harder.) "Commensurability, not communication" — give one statement
   two disjoint observers can both *assert*, and one they cannot *share*,
   and say which property of the wedge each answer uses.

## Boundary note

This chapter does **not** claim that localhost is secure, that the void
"is" consciousness or presence (the paper's appendix firewall applies),
or that seating the human is mathematically forced — it is contractually
chosen, and the whole design is honest about which is which. That
honesty is the book's method.
