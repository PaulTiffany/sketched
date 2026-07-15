// stage.ts
// The stage is the shared medium and the single authority over state.
//
// Everything that changes the scene goes through the Stage, and the Stage
// records an audit event for every change. The Stage enforces the core
// invariant centrally: no matter who calls, an agent can never mutate the
// human/video layer. Direct denied mutations throw; gated flows (see the
// gatekeeper) turn a denial into a recorded rejection instead.

import {
  type Layer,
  type LayerKind,
  type Mutability,
  type ParamValue,
  defaultMutability,
  defaultShakeable,
  isHumanLayer,
} from "./layer";
import {
  type Actor,
  type AuditEvent,
  type AuditEventType,
  AuditLog,
  HUMAN,
  SYSTEM,
} from "./provenance";
import { Timeline } from "./timeline";

export class MutationDeniedError extends Error {
  constructor(
    public readonly actor: Actor,
    public readonly layer: Layer,
    reason: string,
  ) {
    super(reason);
    this.name = "MutationDeniedError";
  }
}

export interface CreateLayerInput {
  kind: LayerKind;
  name: string;
  params?: Record<string, ParamValue>;
  dependsOn?: string[];
  reason?: string;
  /** Override defaults if you must; otherwise derived from kind. */
  mutableBy?: Mutability;
  shakeable?: boolean;
  visible?: boolean;
}

export interface UpdateOptions {
  /** If set, also record keyframes at this time so the change lives on the timeline. */
  atTime?: number;
  reason?: string;
}

export interface StageOptions {
  /** Wall-ish clock for audit ordering. Injected in tests for determinism. */
  clock?: () => number;
  /** Id generator. Injected in tests for determinism. */
  nextId?: (prefix: string) => string;
}

/** Whether an actor may mutate a given layer. The human-layer rule is absolute. */
export function actorMayMutate(layer: Layer, actor: Actor): boolean {
  if (isHumanLayer(layer)) return actor.kind === "human";
  if (actor.kind === "system") return true;
  switch (layer.mutableBy) {
    case "any":
      return true;
    case "human":
      return actor.kind === "human";
    case "agent":
      // The human is the authority and may also adjust generated layers.
      return actor.kind === "agent" || actor.kind === "human";
    case "system":
      // Only system may mutate a system-owned layer; system already returned above.
      return false;
  }
}

export class Stage {
  readonly audit = new AuditLog();
  readonly timeline = new Timeline();

  private layers = new Map<string, Layer>();
  private order: string[] = [];
  private clock: () => number;
  private nextId: (prefix: string) => string;

  constructor(opts: StageOptions = {}) {
    this.clock = opts.clock ?? (() => Date.now());
    if (opts.nextId) {
      this.nextId = opts.nextId;
    } else {
      const counters: Record<string, number> = {};
      this.nextId = (prefix) => {
        counters[prefix] = (counters[prefix] ?? 0) + 1;
        return `${prefix}-${counters[prefix]}`;
      };
    }
  }

  // --- reads ---

  listLayers(): Layer[] {
    return this.order.map((id) => this.layers.get(id)!).filter(Boolean);
  }

  getLayer(id: string): Layer | undefined {
    return this.layers.get(id);
  }

  layersBy(actorId: string): Layer[] {
    return this.listLayers().filter((l) => l.owner.id === actorId);
  }

  // --- mutations (all audited) ---

  createLayer(input: CreateLayerInput, actor: Actor = HUMAN): Layer {
    // Only the human (or system) may introduce a human-video layer.
    if (input.kind === "human-video" && actor.kind === "agent") {
      const pseudo = { id: "(new)", kind: input.kind } as Layer;
      throw new MutationDeniedError(
        actor,
        pseudo,
        "Agents may not create the human/video layer.",
      );
    }

    const id = this.nextId("layer");
    const layer: Layer = {
      id,
      kind: input.kind,
      name: input.name,
      owner: actor,
      visible: input.visible ?? true,
      params: { ...(input.params ?? {}) },
      mutableBy: input.mutableBy ?? defaultMutability(input.kind),
      shakeable: input.shakeable ?? defaultShakeable(input.kind),
      provenance: {
        createdBy: actor,
        createdAt: this.clock(),
        dependsOn: input.dependsOn ?? [],
        reason: input.reason,
      },
    };
    this.layers.set(id, layer);
    this.order.push(id);

    this.record({
      actor,
      type: "layer.created",
      summary: `Created ${layer.kind} layer "${layer.name}"`,
      layerId: id,
      dependsOn: layer.provenance.dependsOn,
      reversible: layer.shakeable,
    });
    return layer;
  }

  updateParams(
    layerId: string,
    params: Record<string, ParamValue>,
    actor: Actor,
    opts: UpdateOptions = {},
  ): Layer {
    const layer = this.requireLayer(layerId);
    if (!actorMayMutate(layer, actor)) {
      throw new MutationDeniedError(
        actor,
        layer,
        `${actor.id} may not mutate ${layer.kind} layer "${layer.name}".`,
      );
    }

    layer.params = { ...layer.params, ...params };
    if (opts.atTime !== undefined) {
      for (const [k, v] of Object.entries(params)) {
        this.timeline.set(layerId, k, opts.atTime, v);
      }
    }

    this.record({
      actor,
      type: "layer.updated",
      summary: `Updated ${Object.keys(params).join(", ")} on "${layer.name}"`,
      layerId,
      reversible: layer.shakeable,
      details: { params },
    });
    return layer;
  }

  keyframe(
    layerId: string,
    param: string,
    t: number,
    value: ParamValue,
    actor: Actor,
  ): void {
    const layer = this.requireLayer(layerId);
    if (!actorMayMutate(layer, actor)) {
      throw new MutationDeniedError(
        actor,
        layer,
        `${actor.id} may not keyframe "${layer.name}".`,
      );
    }
    this.timeline.set(layerId, param, t, value);
    this.record({
      actor,
      type: "param.keyframed",
      summary: `Keyframed ${param}=${String(value)} @${t} on "${layer.name}"`,
      layerId,
      reversible: layer.shakeable,
    });
  }

  removeLayer(layerId: string, actor: Actor): boolean {
    const layer = this.requireLayer(layerId);
    if (!actorMayMutate(layer, actor)) {
      throw new MutationDeniedError(
        actor,
        layer,
        `${actor.id} may not remove ${layer.kind} layer "${layer.name}".`,
      );
    }
    this.layers.delete(layerId);
    this.order = this.order.filter((id) => id !== layerId);
    this.timeline.clearLayer(layerId);
    this.record({
      actor,
      type: "layer.removed",
      summary: `Removed layer "${layer.name}"`,
      layerId,
      reversible: false,
    });
    return true;
  }

  /** Sample all keyframed params at time t into each layer's live params. */
  sampleAt(t: number): void {
    for (const layer of this.listLayers()) {
      const snap = this.timeline.snapshot(layer.id, t);
      if (Object.keys(snap).length > 0) {
        layer.params = { ...layer.params, ...snap };
      }
    }
  }

  // --- audit plumbing ---

  /**
   * Append an audit event. Public so the gatekeeper and shake can record
   * proposals, rejections, and consent decisions on the same log.
   */
  record(
    input: Omit<AuditEvent, "id" | "at" | "consentRequired" | "consentGranted"> & {
      consentRequired?: boolean;
      consentGranted?: boolean;
    },
  ): AuditEvent {
    return this.audit.append({
      id: this.nextId("event"),
      at: this.clock(),
      consentRequired: input.consentRequired ?? false,
      consentGranted: input.consentGranted ?? input.actor.kind === "human",
      ...input,
    });
  }

  newId(prefix: string): string {
    return this.nextId(prefix);
  }

  now(): number {
    return this.clock();
  }

  private requireLayer(id: string): Layer {
    const layer = this.layers.get(id);
    if (!layer) throw new Error(`No such layer: ${id}`);
    return layer;
  }
}

/** Convenience: a stage that starts with a blank human/video stage layer. */
export function createBlankStage(opts?: StageOptions): Stage {
  const stage = new Stage(opts);
  stage.createLayer(
    {
      kind: "human-video",
      name: "Stage (blank)",
      reason: "Embodied presence surface. No camera until you turn one on.",
      params: { mode: "blank", opacity: 1 },
    },
    SYSTEM,
  );
  return stage;
}

// keep the type name in the module surface for downstream re-exports
export type { AuditEventType };
