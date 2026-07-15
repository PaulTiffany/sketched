"""Wiring auditor: cross-checks the registries a Lean theorem must join.

A new ForcingAnalysis theorem is wired into several places, each checking a
different property: the root module's `#print axioms` (kernel audit), the
gen_receipt STMT gloss (receipt), lean_receipt.json (the generated receipt
itself), the coverage maps, the ledger, and the bindings. gen_receipt.py
silently intersects STMT with the printed names, so a miss on either side
drops a verified theorem from the receipt without a sound. This tool makes
that drift loud and enumerates the exact missing rows — the machine
proposes, it never fills.

Fatal findings (exit 1):
  WIRE_PRINT_MISSING   name glossed in gen_receipt.STMT but never
                       `#print axioms`-ed in the root module: the receipt
                       will silently omit it
  WIRE_GLOSS_MISSING   name printed in the root module but absent from
                       gen_receipt.STMT: verified but invisible
  WIRE_RECEIPT_STALE   lean_receipt.json disagrees with STMT ∩ printed:
                       rerun selfcompile/gen_receipt.py

Informational (exit 0): theorems declared in the Lean sources that appear
in no registry at all (helper lemmas are legitimate; a MAIN result here is
a wiring gap).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FA = ROOT / "verification" / "lean" / "ForcingAnalysis"
FK = ROOT / "verification" / "lean" / "ForcingKernel"
RECEIPT = ROOT / "selfcompile" / "lean_receipt.json"

PRINT_RE = re.compile(r"^#print axioms\s+([\w.]+)", re.MULTILINE)
THEOREM_RE = re.compile(r"^(?:protected\s+)?theorem\s+([\w'.]+)", re.MULTILINE)


def load_stmt() -> dict:
    sys.path.insert(0, str(ROOT / "selfcompile"))
    import gen_receipt  # noqa: E402  (main is __main__-guarded)
    return gen_receipt.STMT


def main() -> int:
    findings: list[str] = []

    printed = set(PRINT_RE.findall(
        (FA / "ForcingAnalysis.lean").read_text(encoding="utf-8")))
    stmt = load_stmt()

    for name in sorted(set(stmt) - printed):
        findings.append(
            f"WIRE_PRINT_MISSING {name}: add `#print axioms {name}` to "
            "ForcingAnalysis.lean or the receipt will omit it")
    for name in sorted(printed - set(stmt)):
        findings.append(
            f"WIRE_GLOSS_MISSING {name}: printed in the root module but has "
            "no gen_receipt.STMT gloss — verified but invisible")

    expected = set(stmt) & printed
    if RECEIPT.is_file():
        receipt_names = {t["name"] for t in
                         json.loads(RECEIPT.read_text(encoding="utf-8"))["theorems"]}
        for name in sorted(expected - receipt_names):
            findings.append(
                f"WIRE_RECEIPT_STALE {name}: wired but absent from "
                "lean_receipt.json — rerun selfcompile/gen_receipt.py")
        for name in sorted(receipt_names - expected):
            findings.append(
                f"WIRE_RECEIPT_STALE {name}: in lean_receipt.json but no "
                "longer wired — rerun selfcompile/gen_receipt.py")
    else:
        findings.append("WIRE_RECEIPT_STALE lean_receipt.json missing — run "
                        "selfcompile/gen_receipt.py")

    # ---- informational orphan scan (bare last-component names) ----
    wired_bare = {n.split(".")[-1] for n in printed | set(stmt)}
    for reg, key in ((ROOT / "verification" / "leanps_ledger.json", "declares"),):
        doc = json.loads(reg.read_text(encoding="utf-8"))
        for e in doc["entries"]:
            wired_bare |= {n.split(".")[-1] for n in e.get(key) or []}
    for mp in sorted(ROOT.glob("verification/book*_lean_map.json")):
        doc = json.loads(mp.read_text(encoding="utf-8"))
        for e in doc.get("entries", []):
            wired_bare |= {n.split(".")[-1] for n in e.get("lean", [])}
    bdoc = json.loads((ROOT / "verification" / "bindings.json").read_text(encoding="utf-8"))
    wired_bare |= {b.get("declares", "").split(".")[-1] for b in bdoc["bindings"]}
    # ForcingKernel wires through its own root module's prints
    fk_root = FK / "ForcingKernel.lean"
    if fk_root.is_file():
        wired_bare |= {n.split(".")[-1]
                       for n in PRINT_RE.findall(fk_root.read_text(encoding="utf-8"))}

    orphans: dict[str, list[str]] = {}
    for src_dir, label in ((FA / "ForcingAnalysis", "ForcingAnalysis"),
                           (FK / "ForcingKernel", "ForcingKernel")):
        if not src_dir.is_dir():
            continue
        for f in sorted(src_dir.glob("*.lean")):
            names = [n for n in THEOREM_RE.findall(f.read_text(encoding="utf-8"))
                     if n.split(".")[-1] not in wired_bare]
            if names:
                orphans[f"{label}/{f.name}"] = names

    for finding in findings:
        print("[WIRE] " + finding)
    n_orph = sum(len(v) for v in orphans.values())
    if orphans:
        print(f"unwired theorems (informational, {n_orph} — helper lemmas "
              "are legitimate; main results here are wiring gaps):")
        for file, names in orphans.items():
            print(f"  {file}: {', '.join(names)}")
    print(f"{len(findings)} wiring findings; {len(printed)} printed, "
          f"{len(stmt)} glossed, {len(expected)} receipted, "
          f"{n_orph} unwired helpers")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
