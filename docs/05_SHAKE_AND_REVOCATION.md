# 05 · Shake and Revocation

**Shake clears generated residue, not human presence.**

Shake is scoped revocation, not arbitrary deletion. It is the descendant of
Chalked's eraser: erasure is authority. In Sketched, shaking is how the human (or
an agent, over its own contributions) revokes provisional state.

## Scopes

`shake(stage, scope, actor)` in `core/shake.ts` supports:

| Scope | Effect |
| --- | --- |
| `{ kind: "all-generated" }` | Clear every shakeable generated layer. |
| `{ kind: "agent", agentId }` | Clear one agent's contributions only. |
| `{ kind: "layer", layerId }` | Clear a single layer. |
| `{ kind: "from-timestamp", t }` | Revoke keyframes at/after `t`; keep the layers. |
| `{ kind: "unsafe" }` | Clear layers flagged `params.unsafe === true`. |

## What is always preserved

`isPreserved(layer)` is true when the layer is the human/video layer **or** is
explicitly marked non-shakeable. Preserved layers are filtered out **before** any
clearing happens, regardless of scope and regardless of who calls shake. There is
no scope that removes human presence.

## How it clears

- For most scopes, shake removes layers through `Stage.removeLayer` (running as the
  `system` actor), so **each removal is independently audited**.
- For `from-timestamp`, shake only calls `Timeline.clearFrom` on the in-scope
  shakeable layers — the layers survive, only their later keyframes are revoked.

Finally, shake records one summary `shake` audit event with the cleared and
preserved layer ids and the scope.

## Result

```ts
interface ShakeResult {
  scope: ShakeScope;
  clearedLayerIds: string[];
  preservedLayerIds: string[];
  keyframesOnly: boolean; // true only for from-timestamp
}
```

## Rejected/unsafe proposals

Rejected proposals never mutated state, so there is nothing to shake. The
`unsafe` scope exists for the case where a mutation _was_ applied and later judged
unsafe: flag the layer (`params.unsafe = true`) and shake the unsafe scope. A
future verifier harness (see [`10_ROADMAP.md`](10_ROADMAP.md)) can automate that.
