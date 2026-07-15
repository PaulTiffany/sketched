// agentProtocol.ts
// "Agents propose; the surface disposes."
//
// This is the only doorway agents have into the stage. An agent never mutates
// core state directly; it emits a Proposal describing what it would like to
// happen. The gatekeeper decides. Keep this format small and serializable so a
// remote or file-based agent bridge can speak it later.

import type { Actor } from "../core/provenance";
import type { LayerKind, ParamValue } from "../core/layer";
import type { ShakeScope } from "../core/shake";

/** A placeholder generated asset. MVP-0 does not generate real media. */
export interface AssetPlaceholder {
  id?: string;
  kind: "image" | "video" | "audio" | "shape" | "text";
  label: string;
  /** Where the asset would come from later. Never fetched in MVP-0. */
  sourceHint?: string;
}

export type ProposalAction =
  | {
      type: "create-layer";
      kind: LayerKind;
      name: string;
      params?: Record<string, ParamValue>;
      dependsOn?: string[];
    }
  | { type: "update-params"; layerId: string; params: Record<string, ParamValue> }
  | { type: "add-asset"; layerId: string; asset: AssetPlaceholder }
  | { type: "request-mask"; layerId?: string; op: "enable" | "disable"; key?: string }
  | { type: "annotate"; text: string; layerId?: string }
  | { type: "shake"; scope: ShakeScope }
  | { type: "advance-timeline"; toTime: number };

export interface Proposal {
  id: string;
  from: Actor;
  at: number;
  action: ProposalAction;
  reason?: string;
  /** Ids this proposal relies on, for provenance/dependency tracking. */
  dependsOn?: string[];
}

export type ProposalOutcome = "accepted" | "rejected";

export interface ProposalResult {
  proposal: Proposal;
  outcome: ProposalOutcome;
  /** Why it was accepted or rejected. */
  reason: string;
  /** Layer created or affected, when applicable. */
  layerId?: string;
}

/** A source of proposals. Real, mock, remote — all look the same from here. */
export interface Agent {
  readonly actor: Actor;
  /** Produce zero or more proposals given the current tick. */
  propose(context: AgentContext): Proposal[];
}

export interface AgentContext {
  /** Current logical time / frame. */
  t: number;
  /** Ids of layers the agent already owns, for reference. */
  ownedLayerIds: string[];
  /** Mint a proposal id. */
  nextId: () => string;
}
