// chromaPlaceholder.ts
// A mask is a negotiated boundary. This is the placeholder for the chroma /
// bluescreen pipeline: it describes the intended stages and provides a
// no-op/parameter-only implementation. No real pixel keying happens in MVP-0.
//
// Pipeline (documented in docs/02_ARCHITECTURE.md):
//   frame -> sample key color -> build mask -> composite generated layers -> out

export type ChromaKey = "blue" | "green" | "custom";

export interface ChromaConfig {
  enabled: boolean;
  key: ChromaKey;
  /** 0..1 tolerance for how close a pixel must be to the key color. */
  tolerance: number;
  /** Custom key color as CSS hex, used when key === "custom". */
  customColor?: string;
}

export const DEFAULT_CHROMA: ChromaConfig = {
  enabled: false,
  key: "blue",
  tolerance: 0.25,
};

/** What the pipeline WOULD do, described for the audit overlay and docs. */
export interface ChromaPlan {
  steps: string[];
  config: ChromaConfig;
  implemented: boolean;
}

export function planChroma(config: ChromaConfig): ChromaPlan {
  return {
    implemented: false,
    config,
    steps: config.enabled
      ? [
          `sample ${config.key} key`,
          `build mask @ tolerance ${config.tolerance}`,
          "composite generated layers through mask",
        ]
      : ["chroma disabled — pass frame through untouched"],
  };
}

/**
 * No-op keyer. Returns the frame unchanged and reports what it would have done.
 * Kept side-effect free so it is safe to call from render without surprises.
 */
export function applyChroma<T>(frame: T, config: ChromaConfig): { frame: T; plan: ChromaPlan } {
  return { frame, plan: planChroma(config) };
}
