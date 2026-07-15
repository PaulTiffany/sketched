// residue.ts
// The interface layer: encode/decode across the medium, per the paper's
// Factoring Theorem and Non-identity Theorem (forcing_correspondence_v15,
// thm:factor, thm:nonid).
//
// The board carries residues, not ceilings. E_A exports a floor-stable
// residue of state (the channel projection T_A applied first); D_B returns
// a *Reconstruction*, a different type from any source state, so the
// type system itself enforces "reconstruction, not identity": no code path
// can treat a decoded mark as the author's private state, because no such
// coercion typechecks. The JSON manifold is the medium's inscription format
// (human-labelled zero-order principle: ".json is a good manifold").

import type { Actor, Provenance } from "../core/provenance";

/** What kind of floor-stable content a mark carries. Deliberately closed:
 * "ceiling-state" is not and must never be a member. */
export type ResidueKind = "layer-summary" | "trace" | "annotation" | "param-snapshot";

/**
 * An encoded residue on the medium: E_A(T_A x). JSON-serializable by
 * construction. Valid marks preserve provenance, permission, residue type,
 * and revision authority (prop:chalked) — see validate.ts.
 */
export interface Mark {
  id: string;
  /** Origin of the exporting surface (checked against zero-order). */
  boardOrigin: string;
  residueKind: ResidueKind;
  /** The floor payload. Plain data only; the ceiling never crosses. */
  payload: Record<string, unknown>;
  provenance: Provenance;
  /** Who may revise or erase this mark (the eraser is authority). */
  revisionAuthority: Actor;
  /** Consent state under which the mark was exported. */
  consented: boolean;
  /** Honest loss declaration: what the projection dropped, in words. */
  projectionNote: string;
}

/**
 * The channel projector T_A, operationally: an explicit whitelist of the
 * fields that survive export. Everything not listed is the lossy
 * complement — zero projection loss (thm:nonid condition (i)) would require
 * the whitelist to be exhaustive, which the caller must not assume.
 */
export function project(
  state: Record<string, unknown>,
  keepFields: string[],
): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const k of keepFields) {
    if (k in state) out[k] = state[k];
  }
  return out;
}

/** E_A: export a floor-stable residue of `state` as a mark on the medium. */
export function encodeResidue(args: {
  id: string;
  boardOrigin: string;
  residueKind: ResidueKind;
  state: Record<string, unknown>;
  keepFields: string[];
  provenance: Provenance;
  revisionAuthority: Actor;
  consented: boolean;
}): Mark {
  const kept = project(args.state, args.keepFields);
  const dropped = Object.keys(args.state).filter((k) => !args.keepFields.includes(k));
  return {
    id: args.id,
    boardOrigin: args.boardOrigin,
    residueKind: args.residueKind,
    payload: kept,
    provenance: args.provenance,
    revisionAuthority: args.revisionAuthority,
    consented: args.consented,
    projectionNote:
      dropped.length === 0
        ? "no fields dropped at export (encoding may still lose information)"
        : `projection dropped: ${dropped.join(", ")}`,
  };
}

declare const reconstructionBrand: unique symbol;

/**
 * D_B's output: what a reader holds after decoding a mark. Nominally
 * branded so it can never be passed where source state is expected —
 * `D_B(E_A(T_A x)) ≠ x` as a compile-time fact.
 */
export interface Reconstruction {
  readonly [reconstructionBrand]: true;
  readonly mark: Mark;
  readonly reconstructedBy: Actor;
  readonly at: number;
  /** Always true; carried in-band so serialized forms stay honest. */
  readonly isReconstruction: true;
}

/** D_B: read a mark into the reader's own surface, as a reconstruction. */
export function decodeResidue(mark: Mark, reader: Actor, at: number): Reconstruction {
  return {
    mark,
    reconstructedBy: reader,
    at,
    isReconstruction: true,
  } as Reconstruction;
}
