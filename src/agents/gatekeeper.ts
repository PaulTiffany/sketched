// gatekeeper.ts
// observe -> translate -> gate -> consent -> act -> audit
//
// The gatekeeper is the single point where a proposal becomes (or fails to
// become) a mutation. It never lets an agent reach the stage directly: it
// consults the consent policy, records the decision, and only then acts. Any
// mutation the stage still refuses (e.g. touching human presence) is caught
// and turned into a recorded rejection rather than a thrown error.

import { Stage, MutationDeniedError } from "../core/stage";
import { type ConsentPolicy, type ConsentRequest } from "../core/consent";
import { type Layer } from "../core/layer";
import { shake } from "../core/shake";
import type { Proposal, ProposalAction, ProposalResult } from "./agentProtocol";

export class Gatekeeper {
  constructor(
    private stage: Stage,
    private policy: ConsentPolicy,
  ) {}

  /** Submit a single proposal through the full gate. */
  submit(proposal: Proposal): ProposalResult {
    this.stage.record({
      actor: proposal.from,
      type: "proposal.received",
      summary: `Proposal ${describe(proposal.action)}`,
      dependsOn: proposal.dependsOn,
      reversible: true,
      details: { action: proposal.action, reason: proposal.reason },
    });

    const req = this.toConsentRequest(proposal);
    const decision = this.policy.decide(req);

    this.stage.record({
      actor: proposal.from,
      type: decision.granted ? "consent.granted" : "consent.denied",
      summary: decision.reason,
      layerId: req.targetLayerId,
      consentRequired: decision.required,
      consentGranted: decision.granted,
      reversible: false,
    });

    if (!decision.granted) {
      return this.reject(proposal, decision.reason);
    }

    try {
      const layerId = this.apply(proposal);
      this.stage.record({
        actor: proposal.from,
        type: "proposal.accepted",
        summary: `Accepted ${describe(proposal.action)}`,
        layerId,
        consentRequired: decision.required,
        consentGranted: true,
        reversible: true,
      });
      return { proposal, outcome: "accepted", reason: decision.reason, layerId };
    } catch (err) {
      if (err instanceof MutationDeniedError) {
        return this.reject(proposal, err.message);
      }
      throw err;
    }
  }

  /** Convenience for driving a whole agent's output at once. */
  submitAll(proposals: Proposal[]): ProposalResult[] {
    return proposals.map((p) => this.submit(p));
  }

  private reject(proposal: Proposal, reason: string): ProposalResult {
    this.stage.record({
      actor: proposal.from,
      type: "proposal.rejected",
      summary: `Rejected ${describe(proposal.action)}: ${reason}`,
      reversible: false,
    });
    return { proposal, outcome: "rejected", reason };
  }

  /** Enact an accepted proposal. Returns an affected layer id when relevant. */
  private apply(proposal: Proposal): string | undefined {
    const { action, from } = proposal;
    switch (action.type) {
      case "create-layer": {
        const layer = this.stage.createLayer(
          {
            kind: action.kind,
            name: action.name,
            params: action.params,
            dependsOn: action.dependsOn ?? proposal.dependsOn,
            reason: proposal.reason,
          },
          from,
        );
        return layer.id;
      }
      case "update-params": {
        this.stage.updateParams(action.layerId, action.params, from, {
          atTime: proposal.at,
        });
        return action.layerId;
      }
      case "add-asset": {
        const assets = readAssetList(this.stage.getLayer(action.layerId));
        const asset = {
          ...action.asset,
          id: action.asset.id ?? this.stage.newId("asset"),
        };
        this.stage.updateParams(
          action.layerId,
          { assets: JSON.stringify([...assets, asset]) },
          from,
        );
        return action.layerId;
      }
      case "request-mask": {
        const layerId = action.layerId;
        if (!layerId) {
          const layer = this.stage.createLayer(
            {
              kind: "mask-chroma",
              name: "Chroma mask",
              params: { enabled: action.op === "enable", key: action.key ?? "blue" },
              reason: proposal.reason,
            },
            from,
          );
          return layer.id;
        }
        this.stage.updateParams(
          layerId,
          { enabled: action.op === "enable", ...(action.key ? { key: action.key } : {}) },
          from,
        );
        return layerId;
      }
      case "annotate": {
        const layer = this.stage.createLayer(
          {
            kind: "annotation",
            name: "Annotation",
            params: { text: action.text },
            dependsOn: action.layerId ? [action.layerId] : [],
            reason: proposal.reason,
          },
          from,
        );
        return layer.id;
      }
      case "shake": {
        // Agents may only request shakes; scope is honored but human presence
        // and non-shakeable layers are preserved inside shake() regardless.
        shake(this.stage, action.scope, from);
        return undefined;
      }
      case "advance-timeline": {
        this.stage.sampleAt(action.toTime);
        this.stage.record({
          actor: from,
          type: "param.keyframed",
          summary: `Advanced timeline to t=${action.toTime}`,
          reversible: true,
        });
        return undefined;
      }
    }
  }

  private toConsentRequest(proposal: Proposal): ConsentRequest {
    const { action, from } = proposal;
    let targetLayerId: string | undefined;
    let touchesHumanLayer = false;

    if ("layerId" in action && action.layerId) {
      targetLayerId = action.layerId;
      const target = this.stage.getLayer(action.layerId);
      touchesHumanLayer = !!target && target.kind === "human-video";
    }
    if (action.type === "create-layer" && action.kind === "human-video") {
      touchesHumanLayer = true;
    }

    return {
      actor: from,
      action: action.type,
      proposalId: proposal.id,
      targetLayerId,
      touchesHumanLayer,
    };
  }
}

function readAssetList(layer: Layer | undefined): unknown[] {
  const raw = layer?.params["assets"];
  if (typeof raw !== "string") return [];
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function describe(action: ProposalAction): string {
  switch (action.type) {
    case "create-layer":
      return `create ${action.kind} "${action.name}"`;
    case "update-params":
      return `update ${Object.keys(action.params).join(", ")} on ${action.layerId}`;
    case "add-asset":
      return `add ${action.asset.kind} asset "${action.asset.label}"`;
    case "request-mask":
      return `${action.op} mask${action.layerId ? ` on ${action.layerId}` : ""}`;
    case "annotate":
      return `annotate "${action.text}"`;
    case "shake":
      return `shake (${action.scope.kind})`;
    case "advance-timeline":
      return `advance timeline to ${action.toTime}`;
  }
}
