// consent.ts
// Consent is what turns a possible mutation into an authorized mutation.
//
// The policy is deliberately dumb and legible. It never reaches into the
// stage to mutate anything; it only answers "required?" and "granted?". The
// gatekeeper does the acting. The one hard rule lives here: no non-human actor
// gets consent to touch human presence.

import type { Actor } from "./provenance";
import type { LayerKind } from "./layer";

export interface ConsentRequest {
  actor: Actor;
  /** Short verb, e.g. "create-layer", "update-params", "shake". */
  action: string;
  /** The proposal this request came from, if any (used by manual mode). */
  proposalId?: string;
  targetLayerId?: string;
  targetKind?: LayerKind;
  /** True if the request would affect the human/video (embodied) layer. */
  touchesHumanLayer: boolean;
}

export interface ConsentDecision {
  required: boolean;
  granted: boolean;
  reason: string;
}

export interface ConsentPolicy {
  decide(req: ConsentRequest): ConsentDecision;
}

/** The invariant every policy must honor before its own logic runs. */
function humanLayerGuard(req: ConsentRequest): ConsentDecision | undefined {
  if (req.touchesHumanLayer && req.actor.kind !== "human") {
    return {
      required: true,
      granted: false,
      reason: "Human presence is not agent-owned; consent cannot be granted.",
    };
  }
  return undefined;
}

/**
 * Trusting mode (good for the local demo): the human's own actions never need
 * consent; agent proposals on generated layers are auto-granted; nobody but
 * the human may touch the human layer.
 */
export class AutoConsentPolicy implements ConsentPolicy {
  decide(req: ConsentRequest): ConsentDecision {
    const guard = humanLayerGuard(req);
    if (guard) return guard;

    if (req.actor.kind === "human") {
      return { required: false, granted: true, reason: "Human is the authority." };
    }
    return {
      required: true,
      granted: true,
      reason: "Auto-consent: agent proposal on generated state.",
    };
  }
}

/**
 * Manual mode: agent proposals are denied until their id is explicitly granted.
 * Wire this to a UI prompt later; it already gates correctly today.
 */
export class ManualConsentPolicy implements ConsentPolicy {
  private granted = new Set<string>();

  /** Pre-approve a specific proposal id (e.g. from a UI click). */
  grant(proposalId: string): void {
    this.granted.add(proposalId);
  }

  decide(req: ConsentRequest): ConsentDecision {
    const guard = humanLayerGuard(req);
    if (guard) return guard;
    if (req.actor.kind === "human") {
      return { required: false, granted: true, reason: "Human is the authority." };
    }
    const ok = req.proposalId ? this.granted.has(req.proposalId) : false;
    return {
      required: true,
      granted: ok,
      reason: ok ? "Explicitly granted." : "Awaiting explicit consent.",
    };
  }
}
