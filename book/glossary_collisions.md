# Glossary · Words That Collide

<!-- GENERATED FILE — do not edit by hand.
     Senses live in book/collisions.json; regenerate with
     python verification/tools/book_glossary.py.
     Verified current on every build by verification/tools/book_audit.py. -->

The paper and Sketched share vocabulary but not referents, and chapter 02
warns about the two worst offenders in a box the reader is told to read
twice (§"Two words that collide"). This glossary is that box,
industrialized: every double-booked term, each of its senses, and either
a verified anchor (a file that exists and still contains the quoted
phrase, re-checked on every build) or an explicit citation to outside
work, marked as unverified because a build inside this repository cannot
check a source that lives outside it. The *meanings* are hand-written (no
tool can decide what a word means); everything checkable around them is
machine-checked, including the occurrence counts below, so this page
cannot quietly outlive a renaming.

## channel

| Sense | Meaning | Anchor |
|---|---|---|
| **paper** | The channel-margin subposet: the region of conditions where the interaction matrix keeps a positive spectral margin. "The channel is open" is a statement about an eigenvalue. | `forcing_correspondence_v15.tex` |
| **sketched** | A consent lease: a bounded authority a human grants a knob by press-and-hold. The operational shadow of the margin, related by design but not the same object. | `src/witness/witness.test.ts`; `src/witness/residue.ts` |

**Rule.** The book always means the paper's sense unless it says otherwise (ch02's collision box).

**Where the reader meets it:** ch02 (5), ch06 (5), ch07 (3), appb (1).

## forcing

| Sense | Meaning | Anchor |
|---|---|---|
| **paper (logic)** | p forces phi: the Kripke-Joyal relation the book teaches. The paper reserves the bare word "forces" for this sense. | `forcing_correspondence_v15.tex` |
| **paper (control)** | A forced transition: dynamics push a state. The paper's other, explicitly separated sense. | `docs/12_FORCING_CORRESPONDENCE.md` |
| **forbidden** | The colloquial sense — "forcing" a mark onto the shared surface — which the coordination model forbids. Named only to be excluded. | `book/ch02_conditions_and_refinement.md` |

**Rule.** When the book says "forces" it means the logical relation, always.

**Where the reader meets it:** ch02 (3), ch03 (1), ch04 (3), ch05 (2), ch08 (2), appb (6).

## witness

| Sense | Meaning | Anchor |
|---|---|---|
| **mathematics** | A concrete object certifying an existential or refuting a universal: a strictness witness, a numeric witness, a countermodel. Executable evidence, not proof. | `verification/kernel/numeric_margin.py` |
| **sketched** | The witness layer (src/witness/): Sketched's realization of the paper's witnessed fragment J_wit — the code that validates marks and traces. | `src/witness/witness.ts` |

**Rule.** Context decides: lowercase mathematical usage vs. the named src/witness/ layer; the book flags the layer explicitly as "the witness layer".

**Where the reader meets it:** ch01 (10), ch03 (4), ch06 (1), ch07 (4), ch08 (3), appb (9).

## void

| Sense | Meaning | Anchor |
|---|---|---|
| **sketched (ch01)** | 𝟙: the unique depth-0 condition shared by two observers with no other condition in common — a specific element of the refinement poset, not a region. | `book/ch01_the_room_at_zero.md` |
| **book's hypothesis surface (/book/surface)** | A region of the book's own claim geography with no or low-confidence coverage — the calibration queue's target operators and the atlas nodes the book leaves untaught. Not a point; a shape of absence, structured rather than filled. | `verification/tools/book_projection.py` |
| **external source (forthcoming)** | Definition 6 (Void Region) of the source paper below: a region where adjacent claims exist but the region itself has none, or all fibers fall below a confidence threshold. The book's surface page borrows this sense directly, not chapter 1's. | _cited, not verified: Tiffany, P.C., III. "The Hypothesis Surface: An Operational Epistemology for Autonomous Research." AGI-26 (forthcoming)._ |

**Rule.** Chapter 1's void is a point in a specific poset; the surface's void is a region of unresolved claims in a different, external framework. Do not read one meaning into the other.

**Where the reader meets it:** ch01 (12), ch02 (2), ch03 (4), ch04 (1), ch07 (4), ch08 (1).

## surface

| Sense | Meaning | Anchor |
|---|---|---|
| **sketched (EULA Part A)** | The shared human/video layer no knob — human or agent — is granted unilateral ownership of. Part A clause 3. | `EULA.md` |
| **book interface (/book/surface)** | The book's own epistemic geography, in the sense of the source paper below: claims banded ground/frontier/open, a masking rate mu computed from chapter text against the atlas, and a void map of what remains owed. | `verification/tools/book_projection.py` |
| **external source (forthcoming)** | The Hypothesis Surface itself: a typed workspace separating every claim from its evidential fiber, governed by three integrability conditions (no bare claims, anti-masking, certificate classification). /book/surface is this book's own instance of that framework, applied reflexively to its own chapters. | _cited, not verified: Tiffany, P.C., III. "The Hypothesis Surface: An Operational Epistemology for Autonomous Research." AGI-26 (forthcoming)._ |

**Rule.** Three live senses as of this glossary. When the book says "the surface" unqualified in an EULA context it means the shared human/video layer Part A protects; "/book/surface" always means the book's own epistemic-geography page.

**Where the reader meets it:** ch01 (3), ch02 (2), ch06 (1), ch07 (1), ch08 (1).

## projection

| Sense | Meaning | Anchor |
|---|---|---|
| **witness layer** | The channel projection T_A applied to state before export: what a mark may carry is whitelisted, and the loss must be declared in a projection note. | `src/witness/validate.ts` |
| **book interface** | A bounded browser projection: a compiled JSON packet carrying a selected learning path over the canonical chapters, digest-checked against its sources. | `book/README.md` |

**Rule.** The witness-layer sense is about loss under transport; the browser sense is about bounded context selection. Both are lossy on purpose, but they lose different things.

**Where the reader meets it:** ch07 (6), ch08 (1), appb (1).
