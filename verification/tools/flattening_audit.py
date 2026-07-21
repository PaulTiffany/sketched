"""Forensic anti-flattening audit for the Principia-to-Lean repair program.

Compares each source obligation against the untouched Git baseline in the live
Principia mirror. It does not mutate either Principia tree.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTER = ROOT / "verification" / "source_obligations.json"
OUT = ROOT / "verification" / "flattening_audit.json"
DOC = ROOT / "docs" / "33_PS_ANTI_FLATTENING_AUDIT.md"
AUTHOR_ATLAS = Path(r"C:\src\principia\bib\principia_atlas.json")
MIRROR = Path(r"C:\Users\paulc\projects\Principia-Symbolica")
BASELINE_REF = "HEAD"

CONSTRUCTED_KERNEL = {"PS-SRC-001", "PS-SRC-002", "PS-SRC-003", "PS-SRC-004", "PS-SRC-007", "PS-SRC-008", "PS-SRC-009", "PS-SRC-020", "PS-SRC-021", "PS-SRC-022", "PS-SRC-025", "PS-SRC-027", "PS-SRC-029", "PS-SRC-030", "PS-SRC-031", "PS-SRC-034", "PS-SRC-035", "PS-SRC-039", "PS-SRC-043", "PS-SRC-051", "PS-SRC-055", "PS-SRC-064", "PS-SRC-065", "PS-SRC-067"}
CONDITIONAL_DERIVATION = {"PS-SRC-040", "PS-SRC-033", "PS-SRC-032", "PS-SRC-017", "PS-SRC-016", "PS-SRC-005", "PS-SRC-014", "PS-SRC-015", "PS-SRC-018", "PS-SRC-019", "PS-SRC-023", "PS-SRC-024", "PS-SRC-026", "PS-SRC-036", "PS-SRC-037", "PS-SRC-038", "PS-SRC-042", "PS-SRC-048", "PS-SRC-054", "PS-SRC-057", "PS-SRC-062", "PS-SRC-063", "PS-SRC-066", "PS-SRC-044", "PS-SRC-052"}
PACKAGED_CERTIFICATE = {"PS-SRC-006", "PS-SRC-010", "PS-SRC-011", "PS-SRC-012", "PS-SRC-013", "PS-SRC-028", "PS-SRC-041", "PS-SRC-045", "PS-SRC-047", "PS-SRC-053", "PS-SRC-056", "PS-SRC-059"}
OPEN_BRIDGE = {"PS-SRC-046", "PS-SRC-049", "PS-SRC-050", "PS-SRC-058", "PS-SRC-060", "PS-SRC-061"}

FINITE_WORDS = ("finite", "scalar", "boolean", "constant-field", "discrete", "toy", "one-dimensional")
MISSING_OBJECT_WORDS = (
    "does not specify", "does not define", "does not supply", "does not construct",
    "must be supplied", "requires an explicit", "missing machinery",
)


def digest(text: str | None) -> str | None:
    if text is None:
        return None
    normalized = " ".join(text.split())
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:12]


def load_baseline_atlas() -> dict:
    result = subprocess.run(
        ["git", "show", f"{BASELINE_REF}:principia_atlas.json"],
        cwd=MIRROR, check=True, capture_output=True, text=True, encoding="utf-8",
    )
    return json.loads(result.stdout)


def node_map(atlas: dict) -> dict[str, dict]:
    nodes = {node["id"]: dict(node) for node in atlas["nodes"]}
    for node in nodes.values():
        bodies = [node.get("latex_body", "")]
        bodies.extend(nodes[label].get("latex_body", "")
                      for label in node.get("proof_labels", []) if label in nodes)
        node["_support_body"] = "\n".join(bodies)
    return nodes


def classify(obligation: dict, baseline: dict | None, current: dict | None) -> dict:
    evidence = obligation.get("lean_evidence", [])
    kinds = [item.get("kind", "") for item in evidence]
    haystack = " ".join([
        obligation.get("summary", ""), obligation.get("required_latex_repair", ""),
        " ".join(kinds),
    ]).lower()
    signals: list[str] = []
    if obligation.get("lean_status") in {"conditional_kernel_proved", "countermodel_proved", "bridge_partially_proved"}:
        signals.append("conditional_or_partial_kernel")
    if any("countermodel" in kind or "counterexample" in kind for kind in kinds):
        if not any(any(tag in kind for tag in ("positive", "construction", "assembly", "gluing", "typed_bridge")) for kind in kinds):
            signals.append("countermodel_dominant")
    if any(word in haystack for word in FINITE_WORDS):
        signals.append("finite_or_scalar_shadow")
    if obligation.get("failure_mode") == "missing_machinery" or any(word in haystack for word in MISSING_OBJECT_WORDS):
        signals.append("missing_constructed_object")
    baseline_body = baseline.get("latex_body") if baseline else None
    current_body = current.get("latex_body") if current else None
    changed = digest(baseline_body) != digest(current_body)
    if changed:
        signals.append("source_rewritten_since_pristine_git")
    layer_match = re.fullmatch(r"book(\d+)", obligation.get("source_layer", ""))
    baseline_support = baseline.get("_support_body", baseline_body) if baseline else baseline_body
    if layer_match and baseline_support:
        layer_number = int(layer_match.group(1))
        referenced_books = {int(n) for n in re.findall(r"(?:bk|book)(\d+)[_:]", baseline_support, re.IGNORECASE)}
        if any(n > layer_number for n in referenced_books):
            signals.append("baseline_forward_layer_dependency")
    oid = obligation["id"]
    if oid in CONSTRUCTED_KERNEL:
        review = "constructed_kernel"
    elif oid in CONDITIONAL_DERIVATION:
        review = "conditional_derivation"
    elif oid in PACKAGED_CERTIFICATE:
        review = "packaged_certificate"
    elif oid in OPEN_BRIDGE:
        review = "open_bridge"
    elif obligation.get("latex_status") == "repaired":
        review = "reinspect_repaired_source"
    else:
        review = "untouched_open"
    # Priority is forensic, not a proxy for mathematical difficulty. A high
    # item is one whose authoritative local source diverged from the pristine
    # Git baseline during the repair sprint. Unchanged claims can still have
    # construction debt, but they were not exposed to that rewrite pass.
    priority = "high" if changed else "normal"
    return {
        "id": oid,
        "source_anchor": obligation["source_anchor"],
        "source_layer": obligation["source_layer"],
        "failure_mode": obligation["failure_mode"],
        "lean_status": obligation["lean_status"],
        "latex_status": obligation["latex_status"],
        "downstream_status": obligation["downstream_status"],
        "baseline_statement_sha": digest(baseline_body),
        "current_statement_sha": digest(current_body),
        "source_changed": changed,
        "baseline_name": baseline.get("name") if baseline else None,
        "current_name": current.get("name") if current else None,
        "flattening_signals": signals,
        "review_status": review,
        "priority": priority,
        "summary": obligation.get("summary", ""),
    }


def render_doc(packet: dict) -> str:
    rows = packet["items"]
    counts = packet["counts"]
    lines = [
        "# Principia Symbolica Anti-Flattening Audit",
        "",
        "Generated by `verification/tools/flattening_audit.py` from the 66-item",
        "source-obligation register, the untouched live-mirror Git `HEAD`, and the",
        "current authoritative atlas. No source or Git state is mutated.",
        "",
        f"- Baseline: `{packet['baseline']['repo']}` at `{packet['baseline']['commit']}`",
        f"- Obligations: **{counts['total']}**",
        f"- Statements changed since baseline: **{counts['source_changed']}**",
        f"- High-priority anti-flattening reviews: **{counts['high_priority']}**",
        f"- Constructed kernels: **{counts['constructed_kernel']}**",
        f"- Conditional derivations: **{counts['conditional_derivation']}**",
        f"- Packaged certificates: **{counts['packaged_certificate']}**",
        f"- Explicit open bridges: **{counts['open_bridge']}**",
        "",
        "| ID | Anchor | Layer | Changed | Priority | Review | Signals |",
        "|---|---|---|---:|---|---|---|",
    ]
    for item in rows:
        signals = ", ".join(item["flattening_signals"]) or "—"
        lines.append(
            f"| {item['id']} | `{item['source_anchor']}` | {item['source_layer']} | "
            f"{'yes' if item['source_changed'] else 'no'} | {item['priority']} | "
            f"{item['review_status']} | {signals} |"
        )
    lines += [
        "",
        "## Classification rule",
        "",
        "- `constructed_kernel`: Lean constructs or derives the advertised finite/typed kernel; this does not silently generalize to the full analytic prose.",
        "- `conditional_derivation`: Lean proves a nontrivial consequence, but an important representation, regularity, constitutive, or empirical premise is supplied.",
        "- `packaged_certificate`: the central bridge is chiefly stored as a structure field or premise and then projected; packaging is useful typing, not derivation.",
        "- `open_bridge`: the countermodel or partial kernel is proved, while the source's load-bearing bridge remains unconstructed.",
        "- `untouched_open`: the obligation has not yet entered this construction audit.",
        "",        "## Interpretation rule",
        "",
        "A countermodel is retained as a boundary witness, but it does not complete a",
        "repair when the source claim requires a connection, dynamics, representation,",
        "transport, optimizer, or other constructed object. Such entries remain in the",
        "queue until Lean contains the object and its composition laws, or the register",
        "names the precise analytic or empirical bridge still outside the kernel.",
        "",
    ]
    return "\n".join(lines)


def build() -> tuple[dict, str]:
    obligations = json.loads(REGISTER.read_text(encoding="utf-8"))["obligations"]
    baseline_atlas = load_baseline_atlas()
    current_atlas = json.loads(AUTHOR_ATLAS.read_text(encoding="utf-8"))
    baseline_nodes, current_nodes = node_map(baseline_atlas), node_map(current_atlas)
    items = [classify(o, baseline_nodes.get(o["source_anchor"]), current_nodes.get(o["source_anchor"]))
             for o in obligations]
    commit = subprocess.run(["git", "rev-parse", BASELINE_REF], cwd=MIRROR,
                            check=True, capture_output=True, text=True).stdout.strip()
    counts = {
        "total": len(items),
        "source_changed": sum(i["source_changed"] for i in items),
        "high_priority": sum(i["priority"] == "high" for i in items),
        "constructed_kernel": sum(i["review_status"] == "constructed_kernel" for i in items),
        "conditional_derivation": sum(i["review_status"] == "conditional_derivation" for i in items),
        "packaged_certificate": sum(i["review_status"] == "packaged_certificate" for i in items),
        "open_bridge": sum(i["review_status"] == "open_bridge" for i in items),
        "untouched_open": sum(i["review_status"] == "untouched_open" for i in items),
    }
    packet = {
        "schema_version": 1,
        "baseline": {"repo": str(MIRROR), "ref": BASELINE_REF, "commit": commit},
        "authoritative_atlas": str(AUTHOR_ATLAS),
        "counts": counts,
        "items": items,
    }
    return packet, render_doc(packet)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    packet, doc = build()
    encoded = json.dumps(packet, indent=2, ensure_ascii=False) + "\n"
    if args.check:
        findings = []
        if not OUT.exists() or OUT.read_text(encoding="utf-8") != encoded:
            findings.append("flattening_audit.json is stale")
        if not DOC.exists() or DOC.read_text(encoding="utf-8") != doc:
            findings.append("anti-flattening audit document is stale")
        for finding in findings:
            print(f"[STALE] {finding}")
        if findings:
            return 1
    else:
        OUT.write_text(encoded, encoding="utf-8")
        DOC.write_text(doc, encoding="utf-8")
    c = packet["counts"]
    print(f"0 findings; {c['total']} obligations; changed={c['source_changed']}; "
          f"high_priority={c['high_priority']}; constructed={c['constructed_kernel']}; "
          f"conditional={c['conditional_derivation']}; packaged={c['packaged_certificate']}; "
          f"open_bridge={c['open_bridge']}; untouched_open={c['untouched_open']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())