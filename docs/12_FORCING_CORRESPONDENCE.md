# 12 · Alignment with the Forcing Correspondence

Sketched has an academic companion:
[`../forcing_correspondence_v15.tex`](../forcing_correspondence_v15.tex) —
*"Forcing Correspondence: Calibrated Structural Transduction Between Set-Theoretic
Forcing and the Hypothesis Surface"* (P. Tiffany). This doc aligns Sketched's
vocabulary and architecture to that paper's formal terms, so the artifact and the
theory read as one deliverable. As of v15 the paper carries a mechanical
verification suite ([`../verification/`](../verification/README.md)) — dependency
atlas, loop detector, ledger auditor, finite model checker, Lean kernels — and the
math↔engineering trace itself is machine-checked: see
[`13_OPERATOR_MAP.md`](13_OPERATOR_MAP.md) (generated from
`verification/operators.json`) and the witness layer in `src/witness/`. Where earlier Sketched drafts used loose language
that *collided* with the paper's terms, this doc is the correction.

## What Sketched is, relative to the paper

Sketched is an **executable witness layer** in the PyLantern family (paper §11) —
for realtime media instead of symbolic proof. It obeys the same single invariant:

> **Witness and request access only; no autonomous loop closure.** (paper §11)

It does **not** claim to prove the paper's theorems or discharge its calibration
hypothesis (C). It is one candidate *realization* of the witness discipline, kept
inside the paper's **non-actuation boundary** (§12): shadow execution, bounded
witnesses, reproducible traces, human-gated transitions. Sketched's "MVP-0 today"
boxes are its local version of the paper's **status ledger** — the honest record of
what is built vs. owed.

Motto alignment: **"Lantern, not throne"** (paper) ≡ **"the knob does not own the
surface"** (Sketched).

## Correspondence table

| Sketched | Paper | Note |
|---|---|---|
| Localhost / the shared center | Void; shared depth-0 condition; `127.0.0.1` loopback icon (§6, §7) | The unique shared point; commensurability, not communication |
| Human authority at the zero-point | The origin, **occupied by contract** | See "the EULA places the human in the surface" below |
| Source view (private, sovereign) | An observer surface disjoint below the top; a generic lies in one branch (§6) | You cannot occupy another observer's surface |
| Host interface / handles (jacks) | Interface medium `M`, encode/decode `E_A`, `D_B` (§7) | Only **encoded residues** cross, never occupancy |
| Proposal (carries provenance, uncertainty, consent) | Exported residue constrained by PyLantern (§11) | `D_B(E_A(T_A x_A)) ≠ x_A`: a reconstruction, not identity |
| Audit log | Witness / certificate ledger | Memory under constraint |
| Consent gate | Human-gated decision; requirement met only when witnessed | Turns a possible mutation into an authorized one |
| Shake (scoped revocation) | Not a paper primitive; a witness-layer control | Preserves human presence; resets residue |
| Precedence / conflict arbitration (docs/11) | "conflict scoring," a KJ-realizing connective (§Calibration) | Candidate realization only — see (C) below |

## Two term collisions, resolved

Earlier drafts overloaded two words. Fix them thus:

### "Channel"
- **Paper:** the *channel-margin subposet* `P_H^η` — the coherent admissible
  subspace where the descent keeps a positive margin `λ_min(Γ̃) ≥ η/2`.
- **Sketched:** a `Channel` (docs/11 §3) = a **grant to operate inside a bounded
  admissible region**. These are the *same object* once aligned: a Sketched channel
  is the delegated permission to refine within a channel-margin region — i.e. within
  an **angle** (§5) — and the channel stays open only while motion stays in-margin.
  "Exit means return to zero-point" is the operational reading of leaving `P_H^η`.
  So: **channel = the admissible region + the authority to move in it.** Not a
  rename; a reconciliation. Keep using "channel," meaning both together.

### "Forcing"
Sketched must **not** use "forcing" loosely. The paper reserves two senses; keep
them, cite them, and do not invent a third:
- **Control forcing** (forced transition): joint progress on many claims costs
  more until, at the conflict threshold, a bounded observer is *forced to integrate*
  rather than keep differentiating. This is the honest reading of Sketched's
  **coordination / two-knob "diagonal"** rule — new space cannot be made by one
  knob differentiating alone; the cost of joint progress forces integration
  (coupled co-motion). Say "coordination," and note it *interprets* control forcing.
- **Logical forcing** (`⊩`): `p ⊩ φ` iff the refinements that *stabilize* φ are
  dense below `p`. Sketched's analog is that a contribution "holds" only when its
  stabilizers are witnessed and consented. This is interpretation, **not** a proof
  that Sketched instantiates `⊩`.

Everywhere else, prefer **coordination**, **consent**, **stabilization**,
**witness** over the word "forcing."

## The EULA places the human in the surface

The paper's void is a **neutral** commensurability point — it is not anyone. The
paper proves the *order* fact (the void is the unique shared condition) but keeps
the identification of that stratum normative-free.

Sketched makes the normative move the paper declines to: **it places the human
into that origin.** The instrument of that placement is the **contract** — see
[`../EULA.md`](../EULA.md). The EULA is not terms-of-use bolted on afterward; it is
the *constitutive act* that seats the human as the authority-bearing observer at
the zero-point of the surface. Before the contract, there is a neutral void; the
contract is what turns commensurability-origin into **authority-origin**.

This is the one place Sketched adds a commitment the theorem does not hand you for
free, and it should always be stated as such: the math gives the shared origin; the
EULA seats the human there.

## Collaboration follows the interface model, not shared occupancy

The paper's sharpest gift to Sketched's roadmap (§6–§7): localhost/the void gives
**commensurability, not communication.** Multi-observer work therefore cannot be a
shared canvas. It must be **encoded residues crossing a public medium** (`E_A`/`D_B`)
and **reconstructed** under each observer's own projection — never occupancy of
another's surface. This is exactly why an agent gets a channel/angle, never the
room, and it is the specification for Sketched's future "collaborative mode"
(see [`10_ROADMAP.md`](10_ROADMAP.md)).

## Discipline to carry from the paper

- **Non-actuation:** no proof/feature may require the system to close the loop it
  claims to make safe. Sketched stays witness + request + human gate.
- **Ledger honesty:** mark what is built (P), what is postulated (M), what is
  conjectured/measurable (C), what is open (O). Sketched's docs should not present
  target design as shipped fact — the "MVP-0 today" boxes exist for this.
- **Calibration (C) is open.** That Sketched's operations *realize* the
  Kripke–Joyal clauses is an implementation check the paper explicitly does not
  discharge (§Calibration, Thm. Propositional Truth Lemma). Sketched inherits that
  debt; it does not settle it.
