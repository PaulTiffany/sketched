// layer.ts
// A layer is a performed claim over the stage, through time.
//
// Layers differ in who owns them and what may mutate them. The human/video
// layer is embodied presence: it is never agent-owned and never shaken by
// default. Generated layers are provisional hypotheses: owned by whoever
// generated them, and freely shakeable.

import type { Actor, Provenance } from "./provenance";

export type LayerKind =
  | "human-video" // embodied presence: the witnessed stream or blank stage
  | "generated-background" // provisional scene behind the human
  | "generated-foreground" // provisional scene atop the human
  | "mask-chroma" // negotiated boundary (bluescreen/chroma placeholder)
  | "annotation" // notes / callouts over the scene
  | "control-knob" // parameter gesture surface
  | "audit-overlay"; // debug / legibility overlay

/** Who is permitted to mutate a layer's params or remove it. */
export type Mutability = "human" | "agent" | "system" | "any";

/** Parameter values are kept simple and serializable on purpose. */
export type ParamValue = number | string | boolean;

export interface Layer {
  id: string;
  kind: LayerKind;
  name: string;
  owner: Actor;
  visible: boolean;
  /** Current sampled parameters. The timeline is the source of truth over time. */
  params: Record<string, ParamValue>;
  provenance: Provenance;
  /** Who may mutate this layer. Enforced centrally by the Stage. */
  mutableBy: Mutability;
  /** Whether shake may clear this layer. Human presence defaults to false. */
  shakeable: boolean;
}

const HUMAN_KINDS: ReadonlySet<LayerKind> = new Set(["human-video"]);

const GENERATED_KINDS: ReadonlySet<LayerKind> = new Set([
  "generated-background",
  "generated-foreground",
  "mask-chroma",
]);

export function isHumanLayer(layer: Layer): boolean {
  return HUMAN_KINDS.has(layer.kind);
}

export function isGeneratedLayer(layer: Layer): boolean {
  return GENERATED_KINDS.has(layer.kind);
}

/** Default mutability for a kind, before any explicit override. */
export function defaultMutability(kind: LayerKind): Mutability {
  switch (kind) {
    case "human-video":
      return "human"; // only the human touches embodied presence
    case "control-knob":
      return "human"; // knobs are the human's parameter gestures
    case "audit-overlay":
      return "system";
    default:
      return "agent"; // generated + annotation layers are agent-mutable
  }
}

/** Default shakeability: human presence is preserved, everything else clears. */
export function defaultShakeable(kind: LayerKind): boolean {
  return !HUMAN_KINDS.has(kind);
}
