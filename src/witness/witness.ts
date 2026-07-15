// witness.ts
// The executable witness discipline: Sketched's realization of the paper's
// witnessed fragment J_wit (forcing_correspondence_v15, Def. wit).
//
// A J_wit witness is "a finite prefix of refinements, each carrying a
// certificate, admissibility check, provenance, and (where required) a
// human-gated decision." In Sketched those ingredients already exist —
// Proposal, ConsentDecision, AuditEvent — this module binds them into the
// paper's shape so an engineering trace and a mathematical witness are the
// same JSON object.
//
// Zero-order design principle (human-labelled): localhost is the void 𝟙 —
// the unique shared depth-0 condition (lem:void, prop:zeroth). The EULA is
// the first contract: the constitutive act that seats the human at that
// origin (docs/12). A trace is only well-anchored when both hold.

import type { Actor } from "../core/provenance";
import type { ConsentDecision } from "../core/consent";
import type { Proposal, ProposalResult } from "../agents/agentProtocol";

/** Origins that count as the shared depth-0 condition. The math gives the
 * shared origin; binding to loopback is the operational reading of 𝟙. */
const ZERO_ORDER_HOSTS = new Set(["127.0.0.1", "localhost", "[::1]"]);

export function isZeroOrderOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    return ZERO_ORDER_HOSTS.has(url.hostname);
  } catch {
    return ZERO_ORDER_HOSTS.has(origin);
  }
}

/**
 * The seat of the trace: where it runs and under what contract.
 * `depth` is always 0 — the anchor is the void, not a condition inside a
 * branch. `eulaAccepted` is the EULA-as-first-contract bit: before it, the
 * origin is neutral commensurability; after it, authority-origin.
 */
export interface ZeroOrderAnchor {
  origin: string;
  depth: 0;
  eulaAccepted: boolean;
  /** Identifier of the accepted contract text (e.g. "EULA.md@<version>"). */
  contractRef?: string;
}

export function anchor(origin: string, eulaAccepted: boolean, contractRef?: string): ZeroOrderAnchor {
  return { origin, depth: 0, eulaAccepted, contractRef };
}

/**
 * One admissible refinement, witnessed. Mirrors Def. wit clause by clause:
 * certificate (the consent decision), admissibility (the gate's verdict),
 * provenance (who/when/depends-on), human gate (where required).
 */
export interface WitnessedStep {
  proposalId: string;
  /** Short action verb, e.g. "create-layer". */
  action: string;
  actor: Actor;
  at: number;
  dependsOn: string[];
  /** The certificate: consent required/granted and why. */
  certificate: ConsentDecision;
  /** The gate's admissibility verdict (accepted = admissible move). */
  admissible: boolean;
  admissibilityReason: string;
  /** True when a human explicitly gated this step (ManualConsentPolicy). */
  humanGated: boolean;
}

/** Bind the existing loop objects into a witnessed step. */
export function witnessStep(
  proposal: Proposal,
  result: ProposalResult,
  consent: ConsentDecision,
  opts?: { humanGated?: boolean },
): WitnessedStep {
  return {
    proposalId: proposal.id,
    action: proposal.action.type,
    actor: proposal.from,
    at: proposal.at,
    dependsOn: proposal.dependsOn ?? [],
    certificate: consent,
    admissible: result.outcome === "accepted",
    admissibilityReason: result.reason,
    humanGated: opts?.humanGated ?? false,
  };
}

/**
 * A finite witness trace: the executable object of J_wit. Finite by
 * construction (an array), anchored at the zero-order seat. This is what
 * the audit overlay can render and what a remote reader can verify without
 * occupying the surface.
 */
export interface WitnessTrace {
  anchor: ZeroOrderAnchor;
  steps: WitnessedStep[];
}

export function emptyTrace(a: ZeroOrderAnchor): WitnessTrace {
  return { anchor: a, steps: [] };
}

export function extendTrace(trace: WitnessTrace, step: WitnessedStep): WitnessTrace {
  return { anchor: trace.anchor, steps: [...trace.steps, step] };
}
