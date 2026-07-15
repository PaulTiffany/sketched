// validate.ts
// Executable form of the Chalked correctness invariant (prop:chalked,
// forcing_correspondence_v15): "a valid mark carries residue, not ceiling;
// reconstruction, not possession" — plus the J_wit trace conditions.
//
// Validators return reasons, not booleans alone, so a rejection is itself
// auditable. They never mutate anything.

import type { Mark } from "./residue";
import type { WitnessTrace } from "./witness";
import { isZeroOrderOrigin } from "./witness";

export interface Verdict {
  valid: boolean;
  reasons: string[];
}

const ok: Verdict = { valid: true, reasons: [] };

function fail(reasons: string[]): Verdict {
  return { valid: false, reasons };
}

/**
 * prop:chalked, clause by clause: a mark is valid only if it preserves
 * provenance, permission, residue type, and revision authority, while
 * refusing identity with the originating observer-state.
 */
export function validateMark(mark: Mark): Verdict {
  const reasons: string[] = [];

  if (!mark.provenance || !mark.provenance.createdBy) {
    reasons.push("provenance missing: a mark must say who made it and from what");
  }
  if (!mark.consented) {
    reasons.push("permission missing: the mark was exported without consent state");
  }
  const kinds = ["layer-summary", "trace", "annotation", "param-snapshot"];
  if (!kinds.includes(mark.residueKind)) {
    reasons.push(`residue type '${String(mark.residueKind)}' is not a floor type`);
  }
  if (!mark.revisionAuthority) {
    reasons.push("revision authority missing: someone must hold the eraser");
  }
  // Refusing identity: a mark that claims to BE the author's state is not a
  // residue. The payload must not smuggle a ceiling claim.
  if ("ceilingState" in mark.payload || "identity" in mark.payload) {
    reasons.push("identity refusal: payload claims ceiling-state; a mark is E_A(T_A x), never x");
  }
  if (!mark.projectionNote) {
    reasons.push("projection note missing: the loss must be declared, not hidden");
  }

  return reasons.length === 0 ? ok : fail(reasons);
}

/**
 * J_wit trace validity (Def. wit): finite prefix; every step carries a
 * certificate, admissibility verdict, and provenance; steps that touch
 * consent-requiring actions are human-gated where the certificate says so;
 * and the trace is seated at the zero-order anchor under contract.
 */
export function validateTrace(trace: WitnessTrace): Verdict {
  const reasons: string[] = [];

  if (!isZeroOrderOrigin(trace.anchor.origin)) {
    reasons.push(
      `anchor origin '${trace.anchor.origin}' is not zero-order: ` +
        "the trace must be seated at the shared depth-0 condition (localhost)",
    );
  }
  if (!trace.anchor.eulaAccepted) {
    reasons.push(
      "no contract at the origin: the EULA is the constitutive act that seats " +
        "the human; without it the anchor is neutral, not authority-bearing",
    );
  }

  trace.steps.forEach((s, i) => {
    if (!s.certificate) {
      reasons.push(`step ${i} (${s.proposalId}): no certificate`);
      return;
    }
    if (s.certificate.required && !s.certificate.granted && s.admissible) {
      reasons.push(
        `step ${i} (${s.proposalId}): admitted without granted consent — ` +
          "the gate accepted what the certificate refused",
      );
    }
    if (!s.actor || !s.actor.id) {
      reasons.push(`step ${i} (${s.proposalId}): no actor provenance`);
    }
  });

  return reasons.length === 0 ? ok : fail(reasons);
}
