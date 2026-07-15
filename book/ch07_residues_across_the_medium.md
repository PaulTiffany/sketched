# Chapter 07 · Residues Across the Medium

## Aim

After this chapter you can say precisely what crosses between two
observers who share nothing but the void, why it is never their private
state, and how the type system — not just the prose — makes "you got a
reconstruction, not the original" a compile-time fact rather than a
promise. You will read the mark-validity invariant as code and predict
what it rejects before running the suite.

## Prerequisites

Chapter 01 (the wedge, the void, commensurability vs. communication).
Chapter 02's refinement order gives "depth ≥ 1" its meaning: contingent
content, the stuff two disjoint observers cannot occupy in common.

## Definitions

**Transfer** (`def:transfer`, D). A transfer of contingent content from
A to B is any correspondence between depth-≥1 content of A's surface and
depth-≥1 content of B's, realized either by shared occupancy of a
condition or by a composite of maps through a third object.

**Channel projector.** `T_A`, idempotent (`T_A² = T_A`): the operational
whitelist of what survives export. In the code, `project()` in
`src/witness/residue.ts` *is* `T_A`, spelled out as `keepFields`.
Whatever is not on the list is the lossy complement — and the whitelist
being incomplete is the default assumption, not an edge case.

## Claims

**Factoring, architectural** (`thm:factor`, **D** — the exclusion
content is P, carried by `lem:void`; the theorem itself is tagged D
because it is architecture, not a fresh derivation). Since A and B are
disjoint below the void (chapter 01), no transfer of contingent content
can be occupancy. What remains is exactly the composite
`T_A(X_A) —E_A→ M —D_B→ X_B` through a third object M both can address —
the medium. There is no other route; the theorem's content is the
exclusion of the alternative.

**Non-identity of transport, with equality condition** (`thm:nonid`,
**P**). If the channel projector loses anything (`ε_{T_A}(x_A) > 0`),
then `T_A x_A ≠ x_A` — identity already fails *before* the medium is
even reached, at the moment of projection. Consequently
`D_B(E_A(T_A x_A)) = x_A` can hold only under three named conditions
simultaneously: zero projection loss, faithful encoding, and calibrated
decoding (a genuine section/retraction pair). Absent any one, what B
holds is a reconstruction, not identity. **Non-identity is generic;
identity is a calibrated degeneracy** — the paper's phrase, and the
reason the code brands the return type rather than leaving it a
matching interface.

**Exportability identity, under orthogonality** (`prop:chi`, **P**). For
an orthogonal channel projector, `χ² + ε² = 1` exactly — what you export
and what you lose are Pythagorean complements. For a merely idempotent
(oblique) projector, only the triangle bound `χ + ε ≥ 1` survives; the
clean identity is not free, and orthogonality must not be smuggled in as
an assumption when the real projector is oblique.

**Chalked correctness invariant** (`prop:chalked`, **S** — implementation
conformance, not a fresh mathematical claim). A mark is valid only if it
preserves provenance, permission, residue type, and revision authority,
while *refusing identity* with the originating state: it is
`E_A(T_A x_A)`, never `x_A`. This is `thm:nonid`'s discipline, made
executable.

## Worked example: reading the invariant as code

`residue.ts` implements the whole architectural chain from the theorem.
`encodeResidue` is `E_A`: it runs `project()` (`T_A`), records exactly
which fields were dropped in `projectionNote` — the loss is *declared*,
never hidden, even when nothing was dropped ("encoding may still lose
information" is printed even at zero dropped fields, because the
whitelist itself may be incomplete). `decodeResidue` is `D_B`: it
returns a `Reconstruction`, a nominally branded type. That brand is not
decoration — `thm:nonid`'s "reconstruction, not identity" is enforced
so that no source-state type can be coerced into a `Reconstruction`
without an explicit, visible cast. The theorem lives in the type
checker, not only in the prose.

`validate.ts`'s `validateMark` is `prop:chalked` clause by clause:
missing provenance, missing consent, an unrecognized residue kind,
missing revision authority, and — the identity refusal — a payload that
smuggles a `ceilingState` or `identity` field fails validation outright.
A mark that claims to *be* the author's state is definitionally not a
residue, and the validator says so by name.

## Lab

The chapter's lab is the witness test suite's residue section:

```bash
npx vitest run src/witness -t "residues across the medium"
```

Watch: a well-formed mark validating true, a mark with a smuggled
identity field failing with the exact "identity refusal" reason, and
`decodeResidue`'s output reporting `isReconstruction: true` — never
claiming to equal the source.

## Exercises

1. **Predict, then run.** Construct a mark whose payload includes an
   `identity` key. Which `validateMark` reason fires? Write your
   prediction, then run the suite and compare the string exactly. (The
   answer key already lives in the lab: `witness.test.ts`, "a mark
   claiming ceiling-state is refused (identity refusal)" — the code
   checks `identity` and `ceilingState` identically.)
2. Sketch a `keepFields` whitelist for a hypothetical Sketched layer
   export that would satisfy `thm:nonid` condition (i), zero projection
   loss. What has to be true about the layer's entire state for that
   whitelist to exist?
3. `prop:chi`'s orthogonal identity `χ² + ε² = 1` assumes
   `T_A = T_A²= T_A*`. Is `project()` (a field whitelist) an orthogonal
   projection in the linear-algebra sense, or merely idempotent? Justify
   from the function's definition, not from analogy.
4. (Harder.) The `Reconstruction` brand prevents accidental coercion at
   compile time, but nothing stops a caller from reading
   `rec.mark.payload` and treating its contents as ground truth about
   the author. Which clause of `prop:chalked` is meant to catch that
   *social* failure, given that the type system provably cannot?

## Boundary note

This chapter does **not** claim the medium (the browser, the JSON
manifold) is where identity first breaks — `thm:nonid` is explicit that
bounded projection breaks it earlier, at export. It also does not claim
`project()`'s whitelist is complete for any real Sketched layer type;
that completeness is exactly the calibration debt chapter 08 names.
What is claimed: the non-identity theorem is machine-checked structure
(the brand typechecks), `prop:chalked`'s clauses are executed on every
mark, and the correspondence between paper and code is tracked,
operator by operator, in `docs/13_OPERATOR_MAP.md`.
