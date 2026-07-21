"""Audit the typed correspondence between Lean, the Principia Atlas, and prose."""
from __future__ import annotations

import json
import os
import re
from pathlib import Path

from atlas_extract import statement_sha

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "verification" / "ps_alignment.json"
RECEIPT = ROOT / "selfcompile" / "lean_receipt.json"
REVIEW = ROOT / "verification" / "ps_alignment_review.json"
PROJECTION = ROOT / "verification" / "ps_alignment_atlas_projection.json"
STATUSES = {
    "exact", "constructed", "conditional", "countermodel", "refuted",
    "open_bridge", "interpretive", "poetic",
}
FORMAL = {"exact", "constructed", "conditional", "countermodel", "refuted"}
NONFORMAL = {"open_bridge", "interpretive", "poetic"}
STALE = re.compile(
    r"(?:quantumresolutioncertificate.{0,80}(?:needs|missing).{0,40}hermitian|"
    r"adding only.{0,40}ishermitian|open gleason reconstruction|"
    r"conditional hermitian reconstruction.{0,80}full quantum gleason|"
    r"observer lowering.{0,100}(?:bidirectional|reversible equivalence)|"
    r"(?:decoherence|noise).{0,100}kernel[- ](?:proved|certified).{0,80}(?:time|monotonic)|"
    r"(?:temporal becoming|temporal direction).{0,80}(?:merely |only )?interpretive|"
    r"lake (?:lacks|does not contain).{0,80}(?:formal )?temporal)",
    re.IGNORECASE | re.DOTALL,
)


def atlas_path() -> Path:
    configured = os.environ.get("PRINCIPIA_ATLAS")
    candidates = [
        Path(configured) if configured else None,
        ROOT.parent / "principia" / "bib" / "principia_atlas.json",
        ROOT / "verification" / "principia_atlas.json",
        PROJECTION,
    ]
    found = next((p for p in candidates if p and p.is_file()), None)
    if found is None:
        raise FileNotFoundError("Principia atlas not found")
    return found


def audit(registry: dict, atlas: dict, receipt: dict, coverage: dict[str, str] | None = None) -> list[str]:
    coverage = coverage or {}
    findings: list[str] = []
    if registry.get("schema") != "sketched.ps-alignment.v1":
        findings.append("SCHEMA: expected sketched.ps-alignment.v1")
    nodes = {n.get("label") or n.get("id"): n for n in atlas.get("nodes", [])}
    theorems = {t["name"] for t in receipt.get("theorems", [])}
    entries = registry.get("entries")
    if not isinstance(entries, list):
        return findings + ["SCHEMA: entries must be a list"]
    ids = [e.get("id") for e in entries]
    if len(ids) != len(set(ids)):
        findings.append("SCHEMA: alignment ids must be unique")
    known_ids = set(ids)

    for e in entries:
        eid = e.get("id", "<missing-id>")
        status = e.get("status")
        if status not in STATUSES:
            findings.append(f"{eid}: unknown status {status!r}")
            continue
        anchor = e.get("atlas_id")
        node = nodes.get(anchor)
        if node is None:
            findings.append(f"{eid}: atlas anchor {anchor!r} does not resolve")
            continue
        current_sha = node.get("statement_sha") or statement_sha(node.get("latex_body", ""))
        if e.get("source_statement_sha") != current_sha:
            findings.append(f"{eid}: source statement hash is stale")
        if e.get("source_file") != node.get("file"):
            findings.append(f"{eid}: source_file disagrees with Atlas")
        if e.get("source_line") != node.get("line"):
            findings.append(f"{eid}: source_line disagrees with Atlas")

        witnesses = e.get("lean_witnesses") or []
        countermodels = e.get("countermodels") or []
        for decl in witnesses + countermodels:
            if decl not in theorems:
                findings.append(f"{eid}: Lean declaration {decl!r} absent from receipt")
        certified = e.get("kernel_certified")
        if status in FORMAL and certified is not True:
            findings.append(f"{eid}: formal status requires kernel_certified=true")
        if status in NONFORMAL and certified is not False:
            findings.append(f"{eid}: {status} must not claim kernel certification")
        if status in FORMAL and not witnesses:
            findings.append(f"{eid}: formal claim has no Lean witness")
        if status == "exact" and (e.get("premises") or []):
            findings.append(f"{eid}: exact claim cannot carry unconsumed premises")
        if status == "conditional" and not (e.get("premises") or []):
            findings.append(f"{eid}: conditional claim must expose its premise")
        if status in {"countermodel", "refuted"} and not countermodels:
            findings.append(f"{eid}: negative boundary has no connected countermodel")
        if status == "open_bridge" and not e.get("open_implication"):
            findings.append(f"{eid}: open bridge must name the unconstructed implication")
        for bounded in e.get("bounds", []):
            if bounded not in known_ids:
                findings.append(f"{eid}: bounded claim {bounded!r} does not resolve")
        expected_coverage = e.get("coverage")
        if expected_coverage and coverage.get(anchor) != expected_coverage:
            findings.append(f"{eid}: coverage status disagrees with active map")
        if STALE.search((e.get("claim") or "") + " " + (e.get("atlas_note") or "")):
            findings.append(f"{eid}: stale reverse-lift/Gleason wording")
    return findings


def audit_review(review: dict, atlas: dict) -> list[str]:
    findings: list[str] = []
    if review.get("schema") != "sketched.ps-alignment-review.v1":
        findings.append("REVIEW SCHEMA: expected sketched.ps-alignment-review.v1")
    nodes = {n.get("label") or n.get("id"): n for n in atlas.get("nodes", [])}
    for item in review.get("items", []):
        anchor = item.get("atlas_id")
        node = nodes.get(anchor)
        if node is None:
            findings.append(f"REVIEW {anchor!r}: anchor does not resolve")
            continue
        if item.get("source_file") != node.get("file") or item.get("source_line") != node.get("line"):
            findings.append(f"REVIEW {anchor}: source location is stale")
        current_sha = node.get("statement_sha") or statement_sha(node.get("latex_body", ""))
        if item.get("source_statement_sha") != current_sha:
            findings.append(f"REVIEW {anchor}: statement hash is stale")
        if item.get("current_classification") not in STATUSES:
            findings.append(f"REVIEW {anchor}: unknown classification")
        if not item.get("reason"):
            findings.append(f"REVIEW {anchor}: reason is required")
    return findings

def audit_projection(projection: dict, atlas: dict) -> list[str]:
    findings: list[str] = []
    if projection.get("schema") != "sketched.ps-alignment-atlas-projection.v1":
        findings.append("PROJECTION SCHEMA: unexpected schema")
    actual = {n.get("label") or n.get("id"): n for n in atlas.get("nodes", [])}
    for node in projection.get("nodes", []):
        label = node.get("label")
        source = actual.get(label)
        if source is None:
            findings.append(f"PROJECTION {label!r}: anchor absent from authoritative Atlas")
            continue
        source_sha = source.get("statement_sha") or statement_sha(source.get("latex_body", ""))
        for field in ("file", "line", "name"):
            if node.get(field) != source.get(field):
                findings.append(f"PROJECTION {label}: {field} is stale")
        if node.get("statement_sha") != source_sha:
            findings.append(f"PROJECTION {label}: statement hash is stale")
    return findings

def main() -> int:
    try:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
        atlas = json.loads(atlas_path().read_text(encoding="utf-8"))
        receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
        review = json.loads(REVIEW.read_text(encoding="utf-8"))
        projection = json.loads(PROJECTION.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"[ALIGNMENT] {exc}")
        return 1
    coverage = {}
    for path in sorted((ROOT / "verification").glob("*_lean_map.json")):
        doc = json.loads(path.read_text(encoding="utf-8"))
        for entry in doc.get("entries", []):
            coverage.setdefault(entry["atlas_id"], entry.get("coverage", "mapped"))
    findings = audit(registry, atlas, receipt, coverage)
    findings += audit_projection(projection, atlas)
    findings += audit_review(review, atlas)
    for finding in findings:
        print(f"[ALIGNMENT] {finding}")
    print(f"{len(findings)} alignment findings; {len(registry.get('entries', []))} typed correspondences")
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())