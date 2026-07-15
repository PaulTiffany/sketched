# 07 · OmegaClaw Bridge

A bridge doc for OmegaClaw-style agents (and any autonomous collaborator) that
want to work on or inside Sketched.

## Read this first

Sketched is a **channel/surface project, not an agent-autonomy project.** The
point is not "an agent runs things." The point is a witnessed surface where the
human holds authority and every change is consented and audited.

So: you are welcome here as a **proposer, reviewer, narrator, builder, or verifier**
— not as an owner of the stage.

## The bridge point is the proposal protocol

You interact with the running system exactly one way: by emitting `Proposal`s
(see [`04_AGENT_PROTOCOL.md`](04_AGENT_PROTOCOL.md)) that pass through the
gatekeeper. You never mutate `core` state directly. The shared center is
`localhost`.

## Ground rules

- **Read the repo docs before acting.** Start with `00`, `01`, `02`, `04`.
- **Produce small, auditable diffs.** One idea per change; keep it reviewable.
- **Assume nothing about the environment.** No network, no secrets, no
  credentials, no deployment, no camera/mic/screen access. If a task seems to
  need any of those, stop and say so.
- **Never add hidden network calls or background autonomy.** Both are contract
  violations (see [`09_SAFETY_CONSENT_BOUNDARIES.md`](09_SAFETY_CONSENT_BOUNDARIES.md)).
- **Human presence is off-limits.** Do not propose anything that would create or
  mutate the `human-video` layer; the gate will reject it anyway.
- **Prefer proposals over edits when demonstrating behavior.** Prefer edits +
  tests when improving the engine.

## Useful first tasks

1. **Generate mock scene proposals** — extend `MockAgent` with new scenes/actions.
2. **Review layer ownership rules** — audit `defaultMutability` / `actorMayMutate`.
3. **Test shake semantics** — add cases to `stage.test.ts` for new scopes.
4. **Suggest verifier checks** — propose invariants a harness could assert over
   the audit log (e.g. "no `layer.updated` on a human layer, ever").
5. **Write a walkthrough script** — a narrated sequence of proposals for a demo.
6. **Produce a demo storyboard** — what the stage should look like tick by tick.

## How to hand work back

Leave the audit log meaningful: proposals with clear `reason` fields, small diffs,
and (for engine changes) tests. If in doubt, add a note to `docs/10_ROADMAP.md`
under the relevant direction rather than expanding scope silently.
