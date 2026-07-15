# Chapter 08 · The Contract and the Debt

## Aim

After this chapter you can explain what the EULA does that no theorem
does, why it is split into two parts with different authorship rules,
and what the calibration queue actually is: not a vague disclaimer, but
a named, counted, machine-tracked list of exactly which operator
correspondences are shipped and which are still owed. This is the last
chapter, and its job is to close the loop between the math you have
learned and the honest accounting of how much of it Sketched actually
runs on.

## Prerequisites

Chapters 01 (the void is neutral; the contract seats the human),
06 (the smoothness contract, a C-status measured hypothesis), and 07
(residues, reconstruction, the type-level enforcement of `thm:nonid`).

## Definitions

**The calibration queue** (`asm:calibration`, no ledger claim in the
atlas for the definition itself — status lives on the assumption: **O**,
open overall). The conjunction of ten realization items: that the
deployed pipeline's concrete operations actually instantiate the
Kripke–Joyal clauses the paper claims they instantiate. Some items are
discharged, some reduced; the assumption is exactly the remainder still
owed. It is consumed, explicitly, everywhere a result is claimed *about
Sketched* rather than about the abstract site.

**Realized vs. target.** `verification/operators.json` maps each of the
ten calibration items to one or more concrete operator entries, each
tagged `realized` (a real file, a real export, checked every build) or
`target` (a design commitment with no code yet — and `operator_audit.py`
actively forbids a target entry from claiming a code reference, so
"target" can never quietly become "shipped" by accident).

## Claims

**All ten calibration items are covered** (**obs** — a fact about the
current JSON, re-checked every build, not a theorem). The lab runs the
real auditor and confirms every item 1–10 has at least one operator
entry. Coverage is not completion: an item can be "covered" by a
`target` entry that documents *what would need to be true*, without a
line of code existing yet.

**The map currently has 18 realized and 7 target operators** (**obs**,
same caveat). Both numbers are load-bearing for honesty in opposite
directions: zero `target` rows would mean either the calibration queue
had actually closed (worth celebrating, and provable only by the paper
and Lean saying so) or, more likely, that open debt was being hidden by
overclaiming a status. The lab asserts `target > 0` for exactly this
reason — right now, at least one honest gap is required to pass.

## The two-part contract, and why authorship is split

`EULA.md` has **Part A**, fixed clauses that are human-controlled and
code-enforced (the human holds the center; no agent owns the human
layer; new space needs coordination; shake is scoped; generation is
provisional; local-first; the audit log is complete) — and **Part B**, a
performative slot where an agent drafts the plain-language,
human-readable terms, with humans holding final edit.

This is not an accident of process; it is the same math you already
know, applied to authorship. Part A encodes the invariants a theorem
*can* certify are load-bearing — the human-at-the-origin act (chapter
01), the reconstruction-not-identity discipline (chapter 07), the
witnessed-fragment gate. Those are not negotiable by a drafting agent
because they are not really "terms" — they are the constitutive facts
the rest of the contract routes relative to. But notice what Part A
cannot do: nobody reads a validator at the moment of consent. Part A is
necessary and mute. Part B is the layer a person actually reads before
accepting — and so how its author frames the invariants, which clause
gets an example and which gets a single dry sentence, what the words
make vivid and what they leave technical, is, in every sense that
matters to the human seated at the origin, the contract as experienced.
The mathematics governs the EULA; the framing *becomes* it.

That is why the slot is reserved, and why the reservation runs in both
directions. `docs/14_EULA_MATH_BRIEF.md` binds the drafting agent —
every clause it must cover has a paper anchor, a code anchor, and a
mechanization status, with a fixed MUST-NOT list (no identity transport,
no autonomous closure, no occupancy language, no discharging the
calibration queue by assertion, no weakening Part A, no new ontology).
And the projection compiler binds *everyone else*: it hard-fails when
this book's own tooling, or any other author, tries to fill or
paraphrase the slot. The brief stands to Part B exactly as the status
ledger stands to this book's chapters — not a cage but the thing that
makes the authorship count. A performance under no constraint certifies
nothing; a performance under these constraints is the contract's voice.

This chapter does not draft Part B — not as a precaution against the
drafting agent, but because the words are not ours to write. The seat
is real, its occupant is a genuine contributor to this system, and
humans hold final edit at the break-points as they do for every
contributor. What this chapter teaches is the shape of the obligation
and how to check, mechanically, that nobody — human or agent — has
quietly promised more than the ledger backs.

## Worked example: reading the debt instead of trusting it

Open `docs/13_OPERATOR_MAP.md` after running the lab: it is
*regenerated*, not hand-maintained, directly from `operators.json` by
`operator_audit.py`, so the human-readable table can never drift from
the checked source of truth. If you wanted to know, right now, whether
Sketched actually implements Decision Reachability (`lem:reach`,
chapter 05) or merely aspires to, the answer is not in this book's
prose — it is whichever status that operator's row carries the moment
you run the audit. That is the entire point of building a textbook this
way: a claim about the system is only as good as the command that
re-checks it.

## Lab

```bash
python book/labs/lab08_contract.py
```

Runs the real `operator_audit.py` (not a simplified stand-in), confirms
it exits clean, and asserts the two honesty properties above: full
calibration-item coverage, and a nonzero target count.

## Exercises

1. **Predict, then run.** Before running the lab, guess how many
   calibration items you think a from-scratch witness-layer project
   *should* have fully realized vs. left as targets at this stage.
   Compare your guess to the actual 18/7 split and say what surprised
   you.
2. Read one `target` entry in `verification/operators.json`. What
   concrete file and export would have to exist, and what would
   `operator_audit.py` then check about it, for that entry to become
   `realized`?
3. `docs/14_EULA_MATH_BRIEF.md`'s MUST-NOT list item 4 forbids claiming
   Sketched "implements" the paper's forcing semantics. Using chapters
   03–05's vocabulary, explain in one paragraph what the honest claim is
   instead (hint: witness discipline vs. calibrated forcing).
4. (Harder.) Part A clause 3 ("the knob does not own the surface") and
   the calibration queue are related but distinct kinds of "not yet."
   Part A is enforced today, unconditionally, in code you can point to.
   The calibration queue is an *open mathematical assumption* about
   whether that code's guarantees match the paper's semantics. Give an
   example of a change that would violate Part A immediately versus one
   that would only widen the calibration debt without violating any
   fixed clause.

## Boundary note

This chapter does **not** draft, quote in full, or anticipate the
content of Part B — that is reserved authorship, and this book's
discipline (prose bound to checked evidence) does not extend to writing
someone else's contractual language for them. It also does not claim
the calibration queue will close on any particular schedule, or that
18/7 is a target ratio to defend — those numbers are a snapshot, re-read
every build, and the lab is written to fail loudly if the honest-debt
property (`target > 0`, full coverage) is ever silently lost.
