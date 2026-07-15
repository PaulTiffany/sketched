import { describe, it, expect } from "vitest";
import { createBlankStage } from "../core/stage";
import { AutoConsentPolicy, ManualConsentPolicy } from "../core/consent";
import { isHumanLayer } from "../core/layer";
import { agentActor } from "../core/provenance";
import { Gatekeeper } from "./gatekeeper";
import { MockAgent } from "./mockAgent";
import type { Proposal } from "./agentProtocol";

const painter = agentActor("scene-painter");

function proposal(stage: ReturnType<typeof createBlankStage>, action: Proposal["action"]): Proposal {
  return { id: stage.newId("proposal"), from: painter, at: 0, action };
}

describe("gatekeeper", () => {
  it("turns an accepted proposal into a mutation (and audits it)", () => {
    const stage = createBlankStage();
    const gate = new Gatekeeper(stage, new AutoConsentPolicy());

    const result = gate.submit(
      proposal(stage, { type: "create-layer", kind: "generated-background", name: "Dawn" }),
    );

    expect(result.outcome).toBe("accepted");
    expect(result.layerId).toBeDefined();
    expect(stage.getLayer(result.layerId!)).toBeDefined();
    expect(stage.audit.byType("proposal.accepted").length).toBe(1);
    expect(stage.audit.byType("consent.granted").length).toBe(1);
  });

  it("rejects a proposal that targets the human layer", () => {
    const stage = createBlankStage();
    const gate = new Gatekeeper(stage, new AutoConsentPolicy());
    const humanId = stage.listLayers().find(isHumanLayer)!.id;

    const result = gate.submit(
      proposal(stage, { type: "update-params", layerId: humanId, params: { opacity: 0 } }),
    );

    expect(result.outcome).toBe("rejected");
    expect(stage.audit.byType("consent.denied").length).toBe(1);
    // human layer untouched
    expect(stage.getLayer(humanId)!.params["opacity"]).toBe(1);
  });

  it("manual consent gates until explicitly granted", () => {
    const stage = createBlankStage();
    const policy = new ManualConsentPolicy();
    const gate = new Gatekeeper(stage, policy);

    const p = proposal(stage, { type: "create-layer", kind: "generated-foreground", name: "fg" });
    const denied = gate.submit(p);
    expect(denied.outcome).toBe("rejected");

    policy.grant(p.id);
    const p2 = { ...p, id: stage.newId("proposal") };
    policy.grant(p2.id);
    const granted = gate.submit(p2);
    expect(granted.outcome).toBe("accepted");
  });

  it("a mock agent's proposals flow through the gate and get owned layers", () => {
    const stage = createBlankStage();
    const gate = new Gatekeeper(stage, new AutoConsentPolicy());
    const agent = new MockAgent();

    const props = agent.propose({ t: 0, ownedLayerIds: [], nextId: () => stage.newId("proposal") });
    gate.submitAll(props);

    const owned = stage.layersBy(agent.actor.id);
    expect(owned.length).toBeGreaterThan(0);
    expect(owned[0]!.provenance.createdBy.kind).toBe("agent");
  });
});
