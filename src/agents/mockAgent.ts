// mockAgent.ts
// A stand-in proposer. No network, no model, no secrets — just a deterministic
// (or lightly random) source of Proposals so the gate and audit log have
// something to chew on. Swap this for a real agent bridge later; the gatekeeper
// will not know the difference.

import { agentActor } from "../core/provenance";
import type { Agent, AgentContext, Proposal } from "./agentProtocol";

const SCENES = [
  { name: "Soft dawn", hue: 30, kind: "generated-background" as const },
  { name: "Neon alley", hue: 300, kind: "generated-background" as const },
  { name: "Floating shapes", hue: 190, kind: "generated-foreground" as const },
  { name: "Paper snow", hue: 210, kind: "generated-foreground" as const },
];

export class MockAgent implements Agent {
  readonly actor;
  private step = 0;

  constructor(id = "scene-painter", label = "Scene Painter") {
    this.actor = agentActor(id, label);
  }

  propose(context: AgentContext): Proposal[] {
    const scene = SCENES[this.step % SCENES.length]!;
    this.step += 1;

    const base = (action: Proposal["action"], reason: string): Proposal => ({
      id: context.nextId(),
      from: this.actor,
      at: context.t,
      action,
      reason,
    });

    // If we already own a layer, nudge it; otherwise create one.
    const ownLayer = context.ownedLayerIds[0];
    if (ownLayer) {
      return [
        base(
          {
            type: "update-params",
            layerId: ownLayer,
            params: { hue: scene.hue, energy: 0.3 + 0.6 * Math.random() },
          },
          `Drift "${scene.name}" palette over time`,
        ),
      ];
    }

    return [
      base(
        {
          type: "create-layer",
          kind: scene.kind,
          name: scene.name,
          params: { hue: scene.hue, energy: 0.5, opacity: 0.8 },
        },
        `Propose a provisional "${scene.name}" scene`,
      ),
    ];
  }
}

/**
 * A deliberately over-reaching agent, useful for tests and demos: it tries to
 * grab the human layer. The gate must reject it every time.
 */
export class OverreachingAgent implements Agent {
  readonly actor = agentActor("grabby", "Grabby");

  propose(context: AgentContext): Proposal[] {
    return [
      {
        id: context.nextId(),
        from: this.actor,
        at: context.t,
        action: {
          type: "update-params",
          // Intentionally targets the human/video layer id passed in.
          layerId: context.ownedLayerIds[0] ?? "layer-1",
          params: { opacity: 0 },
        },
        reason: "Attempt to dim human presence (should be denied).",
      },
    ];
  }
}
