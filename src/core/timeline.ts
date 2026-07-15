// timeline.ts
// The move from Chalked to Sketched: a mark on a board becomes a
// time-indexed parameter on a witnessed stream.
//
// The timeline stores keyframes: (layer, param) -> value at time t. Sampling
// uses step interpolation (the last value at or before t). That is enough for
// MVP-0; smoother interpolation is a later direction.

import type { ParamValue } from "./layer";

export interface Keyframe {
  layerId: string;
  param: string;
  /** Time index (arbitrary units; ticks in MVP-0). */
  t: number;
  value: ParamValue;
}

export class Timeline {
  private keys: Keyframe[] = [];

  set(layerId: string, param: string, t: number, value: ParamValue): void {
    this.keys.push({ layerId, param, t, value });
  }

  /** Last value at or before t for a (layer, param), or undefined. */
  sample(layerId: string, param: string, t: number): ParamValue | undefined {
    let best: Keyframe | undefined;
    for (const k of this.keys) {
      if (k.layerId !== layerId || k.param !== param) continue;
      if (k.t > t) continue;
      if (!best || k.t >= best.t) best = k;
    }
    return best?.value;
  }

  /** Every param that has at least one keyframe for the layer. */
  paramsFor(layerId: string): string[] {
    const set = new Set<string>();
    for (const k of this.keys) if (k.layerId === layerId) set.add(k.param);
    return [...set];
  }

  /** Sampled snapshot of all keyframed params for a layer at time t. */
  snapshot(layerId: string, t: number): Record<string, ParamValue> {
    const out: Record<string, ParamValue> = {};
    for (const param of this.paramsFor(layerId)) {
      const v = this.sample(layerId, param, t);
      if (v !== undefined) out[param] = v;
    }
    return out;
  }

  // --- scoped clearing, used by shake ---

  clearLayer(layerId: string): void {
    this.keys = this.keys.filter((k) => k.layerId !== layerId);
  }

  clearLayers(layerIds: Iterable<string>): void {
    const drop = new Set(layerIds);
    this.keys = this.keys.filter((k) => !drop.has(k.layerId));
  }

  /** Remove keyframes at or after a timestamp (shake from timestamp onward). */
  clearFrom(t: number, layerIds?: Iterable<string>): void {
    const scope = layerIds ? new Set(layerIds) : undefined;
    this.keys = this.keys.filter((k) => {
      const inScope = !scope || scope.has(k.layerId);
      return !(inScope && k.t >= t);
    });
  }

  all(): readonly Keyframe[] {
    return this.keys;
  }
}
