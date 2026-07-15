// inputModes.ts
// The human/video layer can be fed by several inputs. In MVP-0 only "blank"
// and "mock" actually produce anything. Real camera/screen access is defined
// here as intent, but never initiated without an explicit user action — see
// docs/09_SAFETY_CONSENT_BOUNDARIES.md.

export type InputModeId =
  | "blank" // a still stage, no capture at all (default)
  | "mock" // a synthetic animated pattern; no camera
  | "webcam" // future: front camera (requires explicit user grant)
  | "screen" // future: screen share (requires explicit user grant)
  | "rear" // future: rear camera
  | "environment360"; // future: immersive / 360 capture

export interface InputMode {
  id: InputModeId;
  label: string;
  /** Whether this mode is actually implemented in MVP-0. */
  available: boolean;
  /** Whether turning it on requires an explicit OS/browser permission grant. */
  requiresGrant: boolean;
  description: string;
}

export const INPUT_MODES: InputMode[] = [
  {
    id: "blank",
    label: "Blank stage",
    available: true,
    requiresGrant: false,
    description: "No capture. A quiet surface for agents to sketch around.",
  },
  {
    id: "mock",
    label: "Mock stream",
    available: true,
    requiresGrant: false,
    description: "A synthetic animated pattern standing in for a live feed.",
  },
  {
    id: "webcam",
    label: "Webcam (future)",
    available: false,
    requiresGrant: true,
    description: "Front camera. Off until you explicitly turn it on.",
  },
  {
    id: "screen",
    label: "Screen (future)",
    available: false,
    requiresGrant: true,
    description: "Screen share as the stage. Off by default.",
  },
  {
    id: "rear",
    label: "Rear camera (future)",
    available: false,
    requiresGrant: true,
    description: "Rear-facing capture on supported devices.",
  },
  {
    id: "environment360",
    label: "360 environment (future)",
    available: false,
    requiresGrant: true,
    description: "Immersive/360 capture. A direction, not a promise.",
  },
];

/** A frame the StageView can paint, independent of where it came from. */
export interface MockFrame {
  /** 0..1 phase used to animate the synthetic pattern. */
  phase: number;
  hue: number;
}

/** Produce a synthetic frame for the "mock" mode. Pure; no side effects. */
export function mockFrameAt(t: number): MockFrame {
  const phase = (t % 120) / 120;
  return { phase, hue: Math.round((t * 3) % 360) };
}

/**
 * Intent-only helper for the future webcam/screen modes. It does NOT call
 * getUserMedia. It exists so the call site is a single, obvious, auditable
 * place to wire real capture later, behind an explicit user gesture.
 */
export function describeGrantRequirement(mode: InputModeId): string {
  const m = INPUT_MODES.find((x) => x.id === mode);
  if (!m) return "Unknown mode.";
  if (!m.requiresGrant) return "No permission needed.";
  return `Requires explicit user grant. Not requested automatically in MVP-0.`;
}
