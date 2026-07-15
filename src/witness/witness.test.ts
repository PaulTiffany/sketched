// witness.test.ts
// The witness layer's own conformance tests: J_wit trace validity,
// prop:chalked mark validity, and the non-identity discipline (thm:nonid)
// checked at both runtime and compile time.

import { describe, it, expect } from "vitest";

import { HUMAN, agentActor } from "../core/provenance";
import type { ConsentDecision } from "../core/consent";
import type { Proposal, ProposalResult } from "../agents/agentProtocol";
import { anchor, emptyTrace, extendTrace, isZeroOrderOrigin, witnessStep } from "./witness";
import { decodeResidue, encodeResidue } from "./residue";
import { validateMark, validateTrace } from "./validate";

const painter = agentActor("scene-painter");

function proposalFixture(): Proposal {
  return {
    id: "p-1",
    from: painter,
    at: 3,
    action: { type: "create-layer", kind: "generated-background", name: "clouds" },
  };
}

const granted: ConsentDecision = {
  required: true,
  granted: true,
  reason: "Explicitly granted.",
};

const accepted: ProposalResult = {
  proposal: proposalFixture(),
  outcome: "accepted",
  reason: "within channel",
};

describe("zero-order anchor (localhost = the void)", () => {
  it("recognizes loopback origins as depth-0", () => {
    expect(isZeroOrderOrigin("http://127.0.0.1:5173")).toBe(true);
    expect(isZeroOrderOrigin("http://localhost:5173")).toBe(true);
    expect(isZeroOrderOrigin("localhost")).toBe(true);
  });

  it("rejects public origins: the void is not out there", () => {
    expect(isZeroOrderOrigin("https://example.com")).toBe(false);
  });
});

describe("witness traces (J_wit)", () => {
  it("accepts a consented, admissible, contract-seated trace", () => {
    const trace = extendTrace(
      emptyTrace(anchor("http://127.0.0.1:5173", true, "EULA.md@v0")),
      witnessStep(proposalFixture(), accepted, granted, { humanGated: true }),
    );
    expect(validateTrace(trace).valid).toBe(true);
  });

  it("rejects a trace anchored off-localhost", () => {
    const trace = emptyTrace(anchor("https://example.com", true));
    const verdict = validateTrace(trace);
    expect(verdict.valid).toBe(false);
    expect(verdict.reasons.join(" ")).toMatch(/zero-order/);
  });

  it("rejects an anchor without the first contract", () => {
    const verdict = validateTrace(emptyTrace(anchor("http://127.0.0.1:5173", false)));
    expect(verdict.valid).toBe(false);
    expect(verdict.reasons.join(" ")).toMatch(/EULA|contract/);
  });

  it("rejects a step the gate admitted against a refused certificate", () => {
    const refused: ConsentDecision = { required: true, granted: false, reason: "denied" };
    const trace = extendTrace(
      emptyTrace(anchor("http://localhost:5173", true)),
      witnessStep(proposalFixture(), accepted, refused),
    );
    const verdict = validateTrace(trace);
    expect(verdict.valid).toBe(false);
    expect(verdict.reasons.join(" ")).toMatch(/without granted consent/);
  });
});

describe("residues across the medium (E_A / D_B)", () => {
  const state = { layers: 3, palette: "dusk", privateCeiling: "the whole feel of it" };

  const mark = encodeResidue({
    id: "m-1",
    boardOrigin: "http://127.0.0.1:5173",
    residueKind: "layer-summary",
    state,
    keepFields: ["layers", "palette"],
    provenance: { createdBy: HUMAN, createdAt: 5, dependsOn: [] },
    revisionAuthority: HUMAN,
    consented: true,
  });

  it("E_A exports only the projected floor and declares the loss", () => {
    expect(mark.payload).toEqual({ layers: 3, palette: "dusk" });
    expect(mark.projectionNote).toMatch(/privateCeiling/);
  });

  it("a well-formed mark satisfies prop:chalked", () => {
    expect(validateMark(mark).valid).toBe(true);
  });

  it("a mark claiming ceiling-state is refused (identity refusal)", () => {
    const bad = { ...mark, payload: { ...mark.payload, ceilingState: state } };
    const verdict = validateMark(bad);
    expect(verdict.valid).toBe(false);
    expect(verdict.reasons.join(" ")).toMatch(/never x/);
  });

  it("D_B yields a reconstruction, tagged as such at runtime", () => {
    const rec = decodeResidue(mark, painter, 9);
    expect(rec.isReconstruction).toBe(true);
    expect(rec.mark.id).toBe("m-1");
  });

  it("thm:nonid holds at compile time: a reconstruction is never source state", () => {
    const rec = decodeResidue(mark, painter, 9);
    function useSourceState(s: typeof state): number {
      return s.layers;
    }
    // @ts-expect-error — D_B(E_A(T_A x)) ≠ x is a type error, not a convention
    useSourceState(rec);
    expect(true).toBe(true);
  });
});
