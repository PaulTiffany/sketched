# 03 · Layer Model

A layer is a performed claim over the stage, through time. Layers differ mainly in
**who owns them** and **what may change or clear them**.

## Layer kinds

| Kind | Purpose | Default owner | Mutable by | Shakeable |
| --- | --- | --- | --- | --- |
| `human-video` | Embodied presence: the witnessed stream, or a blank stage | human/system | **human only** | **no** |
| `generated-background` | Provisional scene behind the human | agent | agent (or human) | yes |
| `generated-foreground` | Provisional scene atop the human | agent | agent (or human) | yes |
| `mask-chroma` | Negotiated boundary (bluescreen/chroma) | agent | agent (or human) | yes |
| `annotation` | Notes / callouts over the scene | agent or human | agent (or human) | yes |
| `control-knob` | The human's parameter-gesture surface | human | **human only** | yes |
| `audit-overlay` | Debug / legibility overlay | system | system | yes |

Defaults come from `defaultMutability(kind)` and `defaultShakeable(kind)` in
`core/layer.ts`, and can be overridden per layer at creation.

## Every layer has

- `id`, `kind`, `name`, `visible`
- `owner: Actor` — who created it (`human`, `agent:<id>`, or `system`)
- `params: Record<string, number | string | boolean>` — the current sampled values
- `provenance` — `{ createdBy, createdAt, dependsOn[], reason? }`
- `mutableBy` — the mutation rule, **enforced centrally by the Stage**
- `shakeable` — whether shake may clear it

## Ownership rule (the invariant)

`isHumanLayer(layer)` layers can be mutated **only** by an actor of kind `human`.
This is checked in `actorMayMutate` for _every_ path — direct calls throw
`MutationDeniedError`, and gated proposals become recorded rejections. There is no
call path by which an agent changes human presence.

Beyond that: `system` may mutate any non-human layer (used by shake); the human
may also adjust generated layers (the human is the authority); an agent may only
mutate layers whose `mutableBy` is `agent` or `any`.

## Mutability vs. provenance vs. clearing

- **Mutability** answers _may this actor change it now?_
- **Provenance** answers _where did it come from and what does it depend on?_
- **Clearing (shake)** answers _may this be revoked, and in what scope?_

These are separate on purpose. A generated layer may be freely mutable and freely
shakeable while still carrying full provenance so the run stays legible. See
[`05_SHAKE_AND_REVOCATION.md`](05_SHAKE_AND_REVOCATION.md) and
[`06_PROVENANCE_AND_AUDIT.md`](06_PROVENANCE_AND_AUDIT.md).
