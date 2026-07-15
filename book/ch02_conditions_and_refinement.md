# Chapter 02 · Conditions and Refinement

## Aim

After this chapter you can read the order everything else in this book
computes over: what a condition is, what refinement preserves, why two
commitments can be *incompatible* forever, and what a coherent course of
commitments (a filter) looks like. You will build the **spine model** —
the seven-condition bench the labs of chapters 03–05 run on — and verify
its structure by brute force. You will also learn to hear two words,
*channel* and *forcing*, that mean different things in the paper and in
Sketched, before the collision can hurt you.

## Prerequisites

Chapter 01 (the void, depth, the wedge). No topology yet; that is
chapter 03.

## Definitions

**Condition** (`def:cond`, D). A finite partial epistemic state. In the
paper: a claim complex with fibers and an exit cone. In Sketched: a
stage — which layers exist, who owns them, what has been consented to so
far. You always know only finitely much; a condition records exactly
that much and no more.

**Refinement and the arena** (`def:refine`, D). `q ⊑ p` iff q is
reachable from p by an admissible move that *retains p's commitments*.
Two consequences, both load-bearing:

- **Work descends.** More knowledge = lower in the order. The root is
  the condition that commits to nothing.
- **The arena is bounded.** All forcing in the paper happens in the
  *channel-margin subposet*: the conditions reachable from the anchor
  within the displacement budget of the smoothness contract
  (`asm:smooth`, C — measured, not assumed). The definition consumes
  only the budget; that the margin actually survives throughout is
  *proved*, not stipulated — chapter 06 is the anatomy of exactly that
  proof.

**Filter** (book-local; the paper uses it from chapter 05 on). A
nonempty set of conditions that is upward closed (whatever you commit
to, you had committed to its weakenings) and downward directed (any two
of its members have a common refinement *inside it*). A filter is a
coherent course of commitments: no member ever contradicts another.

**The spine model.** Conditions `r > {0,1} > {00,01,10,11}` — a depth-2
binary tree. `r` is the root; each address extends the one above it.
This is the smallest model where everything interesting in chapters
03–05 already happens, and the lab builds it from
`verification/kernel/spine.py`.

## Two words that collide (read this box twice)

The paper and Sketched share vocabulary but not referents. The book
always means the paper's sense unless it says otherwise.

- **Channel.** Paper: the *channel-margin subposet* — the region where
  the interaction matrix keeps a positive spectral margin; "the channel
  is open" is a statement about an eigenvalue. Sketched: a *consent
  lease* — a bounded authority a human grants a knob by press-and-hold.
  The two are related by design (the lease is the operational shadow of
  the margin) but they are *not the same object*, and the operator map
  (`docs/13_OPERATOR_MAP.md`) tracks the correspondence explicitly.
- **Forcing.** Paper, two senses it itself separates: a *forced
  transition* (control: the dynamics push a state) versus *p forces φ*
  (logic: the relation this book teaches). Sketched adds a third
  colloquial sense — nobody "forces" a mark onto the shared surface —
  which is precisely what the coordination model forbids. When this
  book says *forces*, it means the logical relation, always.

This box covers the two worst offenders only. The full, machine-checked
account — every double-booked term the book uses, all its senses, and a
verified anchor for each — lives in `book/glossary_collisions.md`
(browser: `/book/glossary`); by the time you reach chapter 08 it also
covers *void* and *surface*, which this book comes to use in more than
one sense of its own.

## Claims

This chapter's claims are structural facts about the spine model, every
one verified by brute force in the lab — status **obs**, the honest tag
for "a machine checked all 128 subsets; nobody wrote a proof."

- Refinement on the spine is a partial order: reflexive, antisymmetric,
  transitive (**obs**).
- `00` and `1` have no common refinement (**obs**). Incompatibility is
  a *permanent* geometric fact — remember it when torsion appears in
  chapter 04.
- The spine has **exactly 7 filters**, one per condition: every filter
  is a principal up-set `up(x)` (**obs**). Coherent histories in a tree
  are just "descend, stopping wherever honesty requires."
- The **4 maximal filters are exactly the branches** — the upward
  closures of the leaves (**obs**). Chapter 05 will call these the
  finite stand-ins for generics.
- No filter contains both `0` and `1` (**obs**): incompatible
  commitments never cohere, which is chapter 01's wedge lemma in
  miniature.

## Worked example: you never un-know

Stabilize atom `a` on the left subtree `{0, 00, 01}` — this is the
valuation chapters 04 and 05 use. It is *refinement-closed*: every
refinement of a condition where a holds is again a condition where a
holds. The kernel's `persistent()` check accepts it.

Now mutate it: let a hold at `0` but *not* at `00` or `01`. The kernel
rejects the valuation, and `Stab(0, a)` flips from true to false — a
condition below which a can be forgotten never stabilized a in the
first place. Persistence is not decoration; it is what makes the
stability set a sieve (chapter 03) and what the ledger tracks as the
paper's highest-leverage modeling postulate (M-Pers). The lab asserts
both directions.

## Lab

```bash
python book/labs/lab02_conditions.py
```

It prints the down-sets, counts the filters by checking all 2⁷
subsets, and asserts every fact quoted above. If the kernel and this
chapter ever disagree, the build fails.

## Exercises

1. **Predict, then run.** How many filters does the depth-3 binary tree
   have? How many are maximal? Write both numbers down; then change
   `binary_tree(2)` to `binary_tree(3)` in a copy of the lab's filter
   count and check.
2. Show by hand that `{r, 0, 1}` is upward closed but not a filter.
   Which pair breaks downward directedness, and why is that the same
   fact as "the wedge has no cross-branch relations"?
3. In a poset that is *not* a tree (draw one with a diamond), exhibit a
   filter that is not principal-along-a-chain. What does Sketched's
   stage graph look like when two consented edits merge?
4. The mutated valuation ("a holds at 0 only") describes a system that
   *revokes* a claim under refinement. Sketched has a legitimate
   operation that looks like forgetting — shake. Say precisely why
   shake is not a counterexample to persistence. (Hint: chapter 01's
   depth-0; a fresh context window is a new descent, not a move within
   the old one.)

## Boundary note

This chapter does **not** claim that real Sketched sessions satisfy the
displacement budget — the smoothness contract (`asm:smooth`, C) is
measured per substrate, and chapter 06 shows exactly what you are owed
when it holds and how the guarantee dies when it does not. It also does
not claim the spine model *is* the paper's condition poset; it is the
smallest honest bench, and every brute-force **obs** fact above is a
fact about the bench. The general statements live in the paper and, for
the load-bearing ones, in Lean.
