# Sketched — Session Contract (EULA scaffold)

The shared AI/user space is **constituted by this contract**. It defines the kind
of room you are standing in. See [`PHILOSOPHY.md`](PHILOSOPHY.md) → "The shared
AI/user space."

**What this contract does, precisely.** In the companion theory
([`docs/12_FORCING_CORRESPONDENCE.md`](docs/12_FORCING_CORRESPONDENCE.md), and
`forcing_correspondence_v15.tex` §9–§10; the void-uniqueness and depth-0 facts are
machine-verified — see `verification/`) the shared origin of a surface — the void,
the localhost zero-point — is *neutral*: it is a shared point, not a person. This
contract is the **constitutive act that places the human into that origin**: it
seats the human as the authority-bearing observer at the zero-point of the surface.
Before the contract there is a neutral shared point; the contract is what turns it
into **authority-origin**. That is the whole job of Part A — everything else is
routed relative to the human it seats. Operationally, acceptance is recorded in the
witness layer (`src/witness/witness.ts`); no witness trace validates without it.
Drafters of Part B: read [`docs/14_EULA_MATH_BRIEF.md`](docs/14_EULA_MATH_BRIEF.md)
first — it is the binding constraint sheet.

This file has two parts. **Part A is fixed** — the zero-order ethical guarantees
we control; they are enforced in code and are not the agent's to rewrite. **Part B
is a performative slot** — the human-readable terms an agent (e.g. OmegaClaw during
the sprint) drafts into, with humans holding final edit at the break-points, the
same way the Chalked EULA was produced.

---

## Part A — Fixed clauses (human-controlled, code-enforced)

These are load-bearing. Do not weaken them; changing them changes what Sketched
*is*.

1. **The human holds the center.** Human authority is the zero-point of
   coordination. Everything else is routed relative to it.
2. **The human layer is not agent-owned.** No agent may create, mutate, replace,
   impersonate, record, publish, or seize the human/video layer. (Enforced by
   `actorMayMutate` in `src/core/stage.ts`.)
3. **The knob does not own the surface.** No knob — human or agent — gets
   unbounded authority over the shared surface. Agents act only within a granted
   angle/channel.
4. **Flow is bounded between human checkpoints.** A human may open a channel once
   and let frame-level motion proceed without approving every frame, but only for
   the channel's visible lifetime, angle, and cumulative budget. The budget may
   not silently expand or refill. Exhaustion or an out-of-angle move closes the
   channel and returns the surface to a human decision boundary.
5. **New space requires coordination.** Novel content requires coupled knobs
   turning together, with human authority in the loop. (See
   [`docs/11_CONTROL_SURFACE.md`](docs/11_CONTROL_SURFACE.md).)
6. **Shake clears generated residue, not human presence.** Revocation is scoped
   and always preserves the human layer.
7. **Generation is provisional.** Generated layers are labeled, owned,
   parameterized, auditable, reversible, and shakeable. They are not claimed to be
   real.
8. **Local-first and honest.** No hidden cloud, no surprise deployment, no silent
   publishing, no background agent process, no API keys required to understand the
   architecture. (See [`docs/09_SAFETY_CONSENT_BOUNDARIES.md`](docs/09_SAFETY_CONSENT_BOUNDARIES.md).)
9. **The audit log is complete.** Every meaningful mutation leaves a trace. The
   log is append-only. This is what lets the toy become a tool.

---

## Part B — Performative terms (drafted in the sprint, humans hold final edit)

This region is owned by OmegaClaw and guarded by
[`contributions/policy.json`](contributions/policy.json). The build accepts its
reserved placeholder or exact authored content accompanied by an owner-matched,
constraint-bound, human-accepted contribution receipt. See
[`docs/16_CONTRIBUTION_PROTOCOL.md`](docs/16_CONTRIBUTION_PROTOCOL.md).

> Agent break-point. Draft the plain-language, human-readable terms below. Keep
> them consistent with Part A — Part A wins on any conflict. Match the toy-like,
> serious voice of [`PHILOSOPHY.md`](PHILOSOPHY.md). Do not add clauses that grant
> agents capabilities Part A forbids. Leave anything you are unsure about as a
> `TODO(human)` note rather than guessing.

<!-- BEGIN performative-slot -->

_TODO(OmegaClaw): plain-language "what room you have entered" introduction._

_TODO(OmegaClaw): plain-language statement of the user's rights (read, steer,
shake, stop, export, protect presence, and choose STEP or bounded FLOW)._

_TODO(OmegaClaw): plain-language statement of what agents may and may not do
inside a human-opened interval._

_TODO(human): review and finalize the above at the break-points._

<!-- END performative-slot -->
