# 04 · Agent Protocol

**Agents propose; the surface disposes.**

An agent never mutates core state. It emits a `Proposal`. The gatekeeper decides.
This is the entire contract between "agent land" and "stage land," and it is kept
small and serializable so a file-based or remote bridge can speak it later.

## Proposal shape

```ts
interface Proposal {
  id: string;
  from: Actor;          // { kind: "agent", id: "agent:<name>" }
  at: number;           // logical time / tick
  action: ProposalAction;
  reason?: string;      // human-readable "why"
  dependsOn?: string[]; // ids this relies on (provenance)
}
```

## Actions an agent may propose

| Action | Meaning |
| --- | --- |
| `create-layer` | Add a generated/annotation/mask layer (never `human-video`). |
| `update-params` | Change parameters on a layer it is allowed to mutate. |
| `add-asset` | Attach a placeholder generated asset (no real media fetched). |
| `request-mask` | Enable/disable a chroma/mask operation. |
| `annotate` | Add an annotation layer with text. |
| `shake` | **Request** a scoped shake of its own generated contributions. |
| `advance-timeline` | Ask the stage to sample the timeline at a time. |

Agents **cannot**: create or mutate the human/video layer, force a shake of human
presence (shake preserves it regardless), reach the network, read secrets, or take
control of camera/mic/files. Those are not expressible in the protocol, and the
gate would reject them if they were.

## The gate (observe → translate → gate → consent → act → audit)

`Gatekeeper.submit(proposal)`:

1. **records** `proposal.received`
2. **translates** the proposal into a `ConsentRequest`
3. **gates + consent**: asks the `ConsentPolicy` for a decision; records
   `consent.granted` / `consent.denied`
4. **acts** only if granted; if the stage still refuses (e.g. it touches human
   presence), the `MutationDeniedError` becomes a recorded rejection
5. **audits** the result as `proposal.accepted` / `proposal.rejected`

## Implementing an agent

Implement the `Agent` interface:

```ts
interface Agent {
  readonly actor: Actor;
  propose(context: AgentContext): Proposal[];
}
```

See `agents/mockAgent.ts` for `MockAgent` (a well-behaved proposer) and
`OverreachingAgent` (deliberately tries to grab the human layer, always rejected —
useful in demos and tests).
