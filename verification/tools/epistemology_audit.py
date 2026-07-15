"""Audit the Surface-derived operational epistemology invariant register.

The register separates fully enforced invariants, tested subsystem slices, and
design targets. The audit prevents prose from promoting a target without real
references and tests, and prevents enforced slices from losing their named
closure obligation.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "verification" / "operational_epistemology.json"
ALLOWED = {"enforced", "enforced-slice", "target"}
EXPECTED_IDS = {f"E{i}" for i in range(1, 11)}


def check_ref(ref: dict, label: str, findings: list[tuple[str, str]]) -> None:
    file = ROOT / str(ref.get("file", ""))
    needle = str(ref.get("contains", ""))
    if not file.is_file():
        findings.append(("REF_MISSING", f"{label}: {ref.get('file')}"))
        return
    if not needle:
        findings.append(("NEEDLE_MISSING", f"{label}: empty contains marker"))
        return
    text = file.read_text(encoding="utf-8")
    if needle not in text:
        findings.append(("NEEDLE_NOT_FOUND", f"{label}: {needle!r} not in {ref['file']}"))


def main() -> int:
    data = json.loads(REGISTRY.read_text(encoding="utf-8"))
    findings: list[tuple[str, str]] = []
    if data.get("schema") != "sketched.operational-epistemology.v1":
        findings.append(("SCHEMA", str(data.get("schema"))))

    entries = data.get("invariants", [])
    ids = [e.get("id") for e in entries]
    if len(ids) != len(set(ids)):
        findings.append(("DUPLICATE_ID", repr(ids)))
    if set(ids) != EXPECTED_IDS:
        findings.append(("ID_SET", f"expected {sorted(EXPECTED_IDS)}, got {sorted(set(ids))}"))

    doc = ROOT / str(data.get("document", ""))
    if not doc.is_file():
        findings.append(("DOC_MISSING", str(data.get("document"))))
        doc_text = ""
    else:
        doc_text = doc.read_text(encoding="utf-8")

    for e in entries:
        eid = str(e.get("id", "?"))
        status = e.get("status")
        label = f"{eid} {e.get('title', '')}".strip()
        if status not in ALLOWED:
            findings.append(("STATUS_UNKNOWN", f"{label}: {status!r}"))
        if not str(e.get("description", "")).strip():
            findings.append(("DESCRIPTION_MISSING", label))
        refs = e.get("references", [])
        tests = e.get("tests", [])
        if not refs:
            findings.append(("REFERENCES_MISSING", label))
        for ref in refs:
            check_ref(ref, f"{label} reference", findings)
        for test in tests:
            check_ref(test, f"{label} test", findings)
        if status == "enforced" and not tests:
            findings.append(("ENFORCED_WITHOUT_TEST", label))
        if status == "enforced" and e.get("closure"):
            findings.append(("ENFORCED_HAS_CLOSURE", label))
        if status == "enforced-slice":
            if not tests and eid not in {"E7", "E8"}:
                findings.append(("SLICE_WITHOUT_TEST", label))
            if len(str(e.get("closure") or "").strip()) < 20:
                findings.append(("CLOSURE_MISSING", label))
        if status == "target":
            if tests:
                findings.append(("TARGET_CLAIMS_TEST", label))
            if len(str(e.get("closure") or "").strip()) < 20:
                findings.append(("CLOSURE_MISSING", label))
        if f"### {eid}." not in doc_text:
            findings.append(("DOC_SECTION_MISSING", label))

    for public_doc in ("README.md", "docs/10_ROADMAP.md"):
        text = (ROOT / public_doc).read_text(encoding="utf-8")
        if "25_OPERATIONAL_EPISTEMOLOGY.md" not in text:
            findings.append(("PUBLIC_LINK_MISSING", public_doc))

    for code, message in findings:
        print(f"[{code}] {message}")
    counts = {s: sum(e.get("status") == s for e in entries) for s in sorted(ALLOWED)}
    print(f"{len(findings)} findings; {len(entries)} epistemic invariants; "
          + ", ".join(f"{k}={v}" for k, v in counts.items()))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
