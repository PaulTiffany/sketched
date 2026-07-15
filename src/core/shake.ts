// shake.ts
// "Shake clears generated residue, not human presence."
//
// Shake is scoped revocation, not arbitrary deletion. It always preserves the
// human/video layer and any layer explicitly marked non-shakeable, no matter
// who asks. Everything else can be cleared within a chosen scope.

import { isHumanLayer, type Layer } from "./layer";
import { type Actor, HUMAN } from "./provenance";
import { Stage } from "./stage";

export type ShakeScope =
  | { kind: "all-generated" }
  | { kind: "agent"; agentId: string }
  | { kind: "layer"; layerId: string }
  | { kind: "from-timestamp"; t: number }
  | { kind: "unsafe" };

export interface ShakeResult {
  scope: ShakeScope;
  clearedLayerIds: string[];
  /** Layers that matched loosely but were preserved (human / non-shakeable). */
  preservedLayerIds: string[];
  /** True when the scope only revoked timeline keyframes, not whole layers. */
  keyframesOnly: boolean;
}

/** Whether a layer is protected from shake regardless of scope. */
export function isPreserved(layer: Layer): boolean {
  return isHumanLayer(layer) || !layer.shakeable;
}

function candidates(stage: Stage, scope: ShakeScope): Layer[] {
  const all = stage.listLayers();
  switch (scope.kind) {
    case "all-generated":
    case "from-timestamp":
      return all;
    case "agent":
      return all.filter((l) => l.owner.id === scope.agentId);
    case "layer":
      return all.filter((l) => l.id === scope.layerId);
    case "unsafe":
      return all.filter((l) => l.params["unsafe"] === true);
  }
}

/**
 * Perform a scoped shake. Preserved layers are never touched. Returns a report
 * suitable for the audit overlay.
 */
export function shake(
  stage: Stage,
  scope: ShakeScope,
  actor: Actor = HUMAN,
): ShakeResult {
  const matched = candidates(stage, scope);
  const preserved = matched.filter(isPreserved);
  const targets = matched.filter((l) => !isPreserved(l));
  const keyframesOnly = scope.kind === "from-timestamp";

  const clearedLayerIds: string[] = [];

  if (keyframesOnly && scope.kind === "from-timestamp") {
    // Revoke mutations after a point in time; keep the layers themselves.
    stage.timeline.clearFrom(
      scope.t,
      targets.map((l) => l.id),
    );
    clearedLayerIds.push(...targets.map((l) => l.id));
  } else {
    for (const layer of targets) {
      // Remove via the stage so each removal is independently audited.
      // shake() runs as the system so it may clear any non-human layer.
      stage.removeLayer(layer.id, { kind: "system", id: "system", label: "Shake" });
      clearedLayerIds.push(layer.id);
    }
  }

  stage.record({
    actor,
    type: "shake",
    summary: shakeSummary(scope, clearedLayerIds.length, preserved.length),
    reversible: false,
    consentRequired: false,
    consentGranted: true,
    details: {
      scope,
      clearedLayerIds,
      preservedLayerIds: preserved.map((l) => l.id),
      keyframesOnly,
    },
  });

  return {
    scope,
    clearedLayerIds,
    preservedLayerIds: preserved.map((l) => l.id),
    keyframesOnly,
  };
}

function shakeSummary(scope: ShakeScope, cleared: number, preserved: number): string {
  const tail = `(${cleared} cleared, ${preserved} preserved)`;
  switch (scope.kind) {
    case "all-generated":
      return `Shook all generated layers ${tail}`;
    case "agent":
      return `Shook ${scope.agentId}'s contributions ${tail}`;
    case "layer":
      return `Shook layer ${scope.layerId} ${tail}`;
    case "from-timestamp":
      return `Shook keyframes from t=${scope.t} onward ${tail}`;
    case "unsafe":
      return `Shook unsafe layers ${tail}`;
  }
}
