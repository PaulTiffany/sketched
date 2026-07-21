"""Binding staleness audit + anchor attestation: sensors are mechanical,
anchors are reserved for judgment.

The Lean kernels, the finite model checker, the numeric witness, and the
witness/ TypeScript implement *statements* of the paper, transcribed by
hand. A green `lake build` proves the transcription, not its currency: if
the paper's statement changes, the artifact keeps verifying the previous
version in silence. This audit makes that staleness a loud finding â€” and
makes the cure a human act.

Reads verification/bindings.json. Each binding pins (artifact file,
declared name/marker, atlas node id, statement_sha at attestation time)
and is checked against the current atlas.json:

  BINDING_NODE_UNKNOWN  math_id resolves to no atlas node (renamed or
                        removed; run tools/atlas_diff.py for
                        RENAME_CANDIDATEs)
  BINDING_STALE         the node's statement changed since attestation â€”
                        re-read the artifact against the new statement,
                        then re-anchor via the attestation protocol below
  BINDING_UNSTAMPED     statement_sha is null (never attested)
  BINDING_FILE_MISSING  artifact file absent (its tree is present)
  BINDING_DECL_MISSING  declared name/marker absent from the artifact
  BINDING_NOTE_OVERSIZED generated note likely contains pasted source instead of a gloss
  ATLAS_UNHASHED        atlas.json carries no statement hashes (rerun
                        atlas_extract.py)
  ATTEST_MALFORMED      a receipt in verification/attestations/ violates
                        the schema
  ATTEST_INVALID        a binding's attested_in names a receipt that is
                        missing or not accepted

Attestation protocol (the anchor side of the drift contract):

  --stamp   refuses to move any anchor unless an *accepted* receipt in
            verification/attestations/ covers exactly the pending moves.
            Absent one, it writes a proposed receipt enumerating the moves
            and exits nonzero: detection is mechanical, discharge is not.
            A receipt is accepted only with human-supplied status,
            attested_by ("human"), and attested_at â€” the machine never
            fills those fields.
  --adopt ID  records an accepted receipt as the attestation of bindings
            whose current anchors it covers (used for the genesis receipt,
            whose anchors were bootstrap-stamped before the protocol).
  --refresh-reserved  mechanically refreshes hashes only for bindings that
            have no attested_in receipt. This records source currency without
            creating human authority. Accepted bindings remain receipt-gated.

Bindings without attested_in are reported as a [RESERVED] info line, not a
finding: the seat is held open for the human signature.

Dual-source statements: a binding may carry "source": "<name>", resolved
via the top-level "sources" map (name -> path of an external atlas whose
nodes carry label + latex_body, e.g. the Principia atlas). External
statements are hashed with the same normalization as the forcing paper's
(atlas_extract.statement_sha), so drift in EITHER corpus goes loud.
Bindings whose source file is absent on this machine/packet are skipped
with a note, like tree-not-shipped artifacts.

Packet mode: bindings whose artifact lives in a tree the packet does not
ship (verification/lean/, src/) are skipped with a note, mirroring
operator_audit.py. Exit 1 on any finding in audit mode.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from atlas_extract import statement_sha

ROOT = Path(__file__).resolve().parents[2]
BINDINGS = ROOT / "verification" / "bindings.json"
ATLAS = ROOT / "verification" / "atlas.json"
ATTEST_DIR = ROOT / "verification" / "attestations"

SCHEMA = "sketched.anchor-attestation.v1"
ATTESTOR = "human"
PROPOSED_NAME = "attest-PROPOSED.json"


def artifact_tree(rel: str) -> str:
    """The shippable tree an artifact belongs to, for packet-mode skips."""
    parts = rel.split("/")
    return "/".join(parts[:2]) if parts[0] == "verification" else parts[0]


def validate_receipt(r: dict) -> list[str]:
    errs = []
    if r.get("schema") != SCHEMA:
        errs.append(f"schema must be '{SCHEMA}'")
    for field in ("id", "paper", "moves", "status"):
        if not r.get(field):
            errs.append(f"missing '{field}'")
    if r.get("status") not in ("proposed", "accepted"):
        errs.append("status must be 'proposed' or 'accepted'")
    for m in r.get("moves") or []:
        if not isinstance(m, dict) or "math_id" not in m or "from" not in m or "to" not in m:
            errs.append("each move needs math_id/from/to")
            break
    if r.get("status") == "accepted":
        if r.get("attested_by") != ATTESTOR:
            errs.append(f"accepted receipts require attested_by == '{ATTESTOR}'")
        if not r.get("attested_at"):
            errs.append("accepted receipts require a human-supplied attested_at")
    return errs


def load_receipts() -> tuple[dict[str, dict], list[tuple[str, str]]]:
    receipts: dict[str, dict] = {}
    findings: list[tuple[str, str]] = []
    if ATTEST_DIR.is_dir():
        for f in sorted(ATTEST_DIR.glob("*.json")):
            try:
                r = json.loads(f.read_text(encoding="utf-8"))
            except json.JSONDecodeError as e:
                findings.append(("ATTEST_MALFORMED", f"{f.name}: {e}"))
                continue
            errs = validate_receipt(r)
            if errs:
                findings += [("ATTEST_MALFORMED", f"{f.name}: {e}") for e in errs]
            else:
                receipts[r["id"]] = r
    return receipts, findings


def load_external_shas(doc: dict) -> tuple[dict[str, str], set[str]]:
    """Hash the referenced statements of every external source declared in
    doc['sources']. Returns (label -> sha, unavailable source names)."""
    shas: dict[str, str] = {}
    unavailable: set[str] = set()
    needed: dict[str, set[str]] = {}
    for b in doc["bindings"]:
        if b.get("source"):
            needed.setdefault(b["source"], set()).add(b["math_id"])
    for src, labels in needed.items():
        path = Path((doc.get("sources") or {}).get(src, ""))
        if not path.is_file():
            unavailable.add(src)
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        for n in data.get("nodes", []):
            if n.get("label") in labels:
                shas[n["label"]] = statement_sha(n.get("latex_body", ""))
    return shas, unavailable


def audit(
    bindings: list[dict],
    atlas_shas: dict[str, str],
    root: Path,
    receipts: dict[str, dict] | None = None,
    unavailable: frozenset[str] | set[str] = frozenset(),
) -> tuple[list[tuple[str, str]], int, int]:
    """Check bindings against current atlas hashes and attestation records.

    Returns (findings, skipped, unattested)."""
    receipts = receipts or {}
    findings: list[tuple[str, str]] = []
    skipped = 0
    unattested = 0
    for b in bindings:
        label = f"{b['artifact']}::{b['declares']}"
        if b.get("source") in unavailable:
            skipped += 1  # external statement source absent here
            continue
        if not (root / artifact_tree(b["artifact"])).exists():
            skipped += 1  # tree not shipped in this packet
            continue
        file = root / b["artifact"]
        if not file.is_file():
            findings.append(("BINDING_FILE_MISSING", f"{label}: file absent"))
            continue
        if b["declares"] not in file.read_text(encoding="utf-8"):
            findings.append(("BINDING_DECL_MISSING", f"{label}: marker not found in artifact"))
        if len(b.get("note") or "") > 500:
            findings.append(("BINDING_NOTE_OVERSIZED",
                             f"{label}: note exceeds 500 characters"))
        att = b.get("attested_in")
        if att is None:
            unattested += 1
        else:
            r = receipts.get(att)
            if r is None or r.get("status") != "accepted":
                findings.append(("ATTEST_INVALID",
                                 f"{label}: attested_in '{att}' is missing or not accepted"))
        mid = b["math_id"]
        if mid not in atlas_shas:
            findings.append(("BINDING_NODE_UNKNOWN", f"{label}: '{mid}' not in atlas"))
            continue
        if b["statement_sha"] is None:
            findings.append(("BINDING_UNSTAMPED", f"{label}: never attested against '{mid}'"))
        elif b["statement_sha"] != atlas_shas[mid]:
            findings.append((
                "BINDING_STALE",
                f"{label}: '{mid}' statement is now {atlas_shas[mid]}, attested at "
                f"{b['statement_sha']} â€” re-read the artifact, then re-anchor (--stamp)",
            ))
    return findings, skipped, unattested


def pending_moves(bindings: list[dict], atlas_shas: dict[str, str]) -> list[tuple[str, str | None, str]]:
    """Distinct (math_id, from, to) anchor movements the atlas demands."""
    moves = {
        (b["math_id"], b["statement_sha"], atlas_shas[b["math_id"]])
        for b in bindings
        if b["math_id"] in atlas_shas and b["statement_sha"] != atlas_shas[b["math_id"]]
    }
    return sorted(moves, key=str)


def covering_receipt(
    moves: list[tuple[str, str | None, str]], receipts: dict[str, dict]
) -> dict | None:
    """The accepted receipt whose moves exactly cover the pending set.

    Exact coverage, no partial stamping: a receipt attests a review of one
    specific delta, nothing narrower or wider."""
    want = set(moves)
    for r in receipts.values():
        if r["status"] != "accepted":
            continue
        have = {(m["math_id"], m["from"], m["to"]) for m in r["moves"]}
        if have == want:
            return r
    return None


def apply_stamp(bindings: list[dict], receipt: dict, atlas_shas: dict[str, str]) -> list[str]:
    """Apply an accepted receipt's moves; record its id on each moved binding."""
    covered = {(m["math_id"], m["from"], m["to"]) for m in receipt["moves"]}
    log = []
    for b in bindings:
        mid = b["math_id"]
        if mid in atlas_shas and (mid, b["statement_sha"], atlas_shas[mid]) in covered:
            log.append(f"{mid}: {b['statement_sha']} -> {atlas_shas[mid]} ({b['artifact']})")
            b["statement_sha"] = atlas_shas[mid]
            b["attested_in"] = receipt["id"]
    return log


def adopt(bindings: list[dict], receipt: dict) -> int:
    """Record an accepted receipt on bindings whose current anchor it covers."""
    anchors = {(m["math_id"], m["to"]) for m in receipt["moves"]}
    n = 0
    for b in bindings:
        if (b["math_id"], b["statement_sha"]) in anchors and not b.get("attested_in"):
            b["attested_in"] = receipt["id"]
            n += 1
    return n


def refresh_reserved(bindings: list[dict], atlas_shas: dict[str, str]) -> list[str]:
    """Refresh current hashes only where no human attestation is claimed."""
    log = []
    for b in bindings:
        mid = b["math_id"]
        if (not b.get("attested_in") and mid in atlas_shas
                and b["statement_sha"] != atlas_shas[mid]):
            log.append(f"{mid}: {b['statement_sha']} -> {atlas_shas[mid]} ({b['artifact']})")
            b["statement_sha"] = atlas_shas[mid]
    return log


def proposed_receipt(moves: list[tuple[str, str | None, str]], paper: str) -> dict:
    return {
        "schema": SCHEMA,
        "id": "attest-PROPOSED",
        "paper": paper,
        "moves": [{"math_id": m, "from": f, "to": t} for m, f, t in moves],
        "note": "REVIEW REQUIRED: re-read every bound artifact against the changed "
                "statements before accepting. Rename this file, set a real id, and "
                "fill status/attested_by/attested_at by hand.",
        "status": "proposed",
        "attested_by": None,
        "attested_at": None,
    }


def load_atlas() -> tuple[dict[str, str] | None, str]:
    atlas = json.loads(ATLAS.read_text(encoding="utf-8"))
    shas = {n["id"]: n.get("statement_sha") for n in atlas["nodes"]}
    if any(v is None for v in shas.values()):
        return None, atlas.get("source", "?")
    return shas, atlas.get("source", "?")


def main() -> int:
    if not BINDINGS.is_file():
        print("bindings.json absent â€” packet mode; binding staleness audit skipped")
        return 0
    atlas_shas, paper = load_atlas()
    if atlas_shas is None:
        print("[ATLAS_UNHASHED] atlas.json carries no statement hashes; rerun atlas_extract.py")
        return 1
    doc = json.loads(BINDINGS.read_text(encoding="utf-8"))
    external_shas, unavailable = load_external_shas(doc)
    atlas_shas = {**atlas_shas, **external_shas}
    receipts, receipt_findings = load_receipts()

    if "--refresh-reserved" in sys.argv:
        log = refresh_reserved(doc["bindings"], atlas_shas)
        BINDINGS.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
        for line in log:
            print(f"  {line}")
        print(f"mechanically refreshed {len(log)} reserved bindings; "
              "no human attestation created")
        return 0

    if "--adopt" in sys.argv:
        idx = sys.argv.index("--adopt")
        if idx + 1 >= len(sys.argv):
            sys.exit("--adopt requires a receipt id")
        rid = sys.argv[idx + 1]
        r = receipts.get(rid)
        if r is None or r["status"] != "accepted":
            print(f"receipt '{rid}' is missing, malformed, or not accepted â€” "
                  "adoption is a judgment record and needs the human signature first")
            return 1
        n = adopt(doc["bindings"], r)
        BINDINGS.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
        print(f"adopted '{rid}' as the attestation of {n} bindings")
        return 0

    if "--stamp" in sys.argv:
        moves = pending_moves(doc["bindings"], atlas_shas)
        if not moves:
            print("anchors current; nothing to stamp")
            return 0
        r = covering_receipt(moves, receipts)
        if r is None:
            ATTEST_DIR.mkdir(parents=True, exist_ok=True)
            out = ATTEST_DIR / PROPOSED_NAME
            out.write_text(json.dumps(proposed_receipt(moves, paper), indent=2) + "\n",
                           encoding="utf-8")
            for m, f, t in moves:
                print(f"  pending: {m}: {f} -> {t}")
            print(f"\nanchors are reserved for judgment: no accepted receipt covers "
                  f"these {len(moves)} moves.\nwrote {out} â€” review the bound artifacts "
                  "against the new statements, then accept it by hand and rerun --stamp.")
            return 1
        log = apply_stamp(doc["bindings"], r, atlas_shas)
        BINDINGS.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
        for line in log:
            print(f"  {line}")
        print(f"re-anchored {len(log)} bindings under receipt '{r['id']}' "
              f"(attested by {r['attested_by']} at {r['attested_at']})")
        return 0

    findings, skipped, unattested = audit(doc["bindings"], atlas_shas, ROOT,
                                          receipts, unavailable)
    findings = receipt_findings + findings
    for code, msg in findings:
        print(f"[{code}] {msg}")
    if unattested:
        print(f"[RESERVED] {unattested} anchors await the human signature "
              f"(accept + --adopt a receipt in verification/attestations/)")
    skip_bits = []
    if skipped:
        skip_bits.append(f"{skipped} skipped: tree or statement source not present")
    if unavailable:
        skip_bits.append(f"absent sources: {', '.join(sorted(unavailable))}")
    note = f" ({'; '.join(skip_bits)})" if skip_bits else ""
    print(f"\n{len(findings)} binding findings; "
          f"{len(doc['bindings']) - skipped} bindings checked against "
          f"{len(atlas_shas)} hashed statements{note}.")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
