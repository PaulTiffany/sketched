"""Generate Appendix A: the book's ledger cross-reference.

Reads verification/atlas.json and book/registry.json, scans the drafted
chapters for atlas citations, and emits book/appendix_a_the_ledger.md:
one row per atlas node the book teaches, mapping the node to its ledger
status, its proof status in the paper, the chapters that teach it, and
the lab that witnesses it. The appendix is generated, never hand-edited;
book_audit.py fails the build when it drifts from its sources.

`ledger_rows()` exposes the same rows as structured data; the browser
projection compiler (book_projection.py) publishes them as
/book/ledger.json so the interface renders the identical cross-reference.

Usage:
  python verification/tools/book_ledger.py           # (re)write the appendix
  python verification/tools/book_ledger.py --check   # exit 1 if stale
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
ATLAS = ROOT / "verification" / "atlas.json"
REGISTRY = ROOT / "book" / "registry.json"
OUTPUT = ROOT / "book" / "appendix_a_the_ledger.md"

ATLAS_REF_RE = re.compile(r"`((?:def|lem|thm|prop|asm|rem):[^`]+)`")

# Order rows the way the reader meets the mathematics, not alphabetically.
ID_PREFIX_ORDER = {"def": 0, "asm": 1, "lem": 2, "prop": 3, "thm": 4, "rem": 5}

STATUS_GLOSS = {
    "P": "proved",
    "D": "definitional",
    "S": "conformance",
    "M": "postulate",
    "C": "contract",
    "O": "open",
}

PREAMBLE = """\
# Appendix A · The Ledger at a Glance

<!-- GENERATED FILE — do not edit by hand.
     Regenerate: python verification/tools/book_ledger.py
     Verified current on every build by verification/tools/book_audit.py. -->

Every chapter of this book carries its status tags inline, next to the
claims they qualify. This appendix is the same information turned
inside out: one row per atlas node the book teaches, so you can see the
whole footprint at once — what is proved, what is contracted, what is
open, and exactly where to go to re-check each one. Nothing here is
hand-written. A tool reads the paper's atlas and the chapter registry
and writes this page; the build fails if this page and its sources ever
disagree. Trust the table exactly as far as that sentence licenses, and
no further.

**How to read a row.** *Ledger* is the paper's own status claim
(P proved, D definitional, S implementation conformance, M modeling
postulate, C measurable contract, O open); a dash means the node's
status lives in prose rather than the ledger table. *Proof* is what the
mechanical audit found in the TeX source. *Taught in* lists every
chapter that cites the node. *Witnessed by* is the executable that
re-checks the chapter's claims about it.
"""


def lab_label(chapter: dict) -> str:
    if chapter.get("lab"):
        return f"`{Path(chapter['lab']).name}`"
    if chapter.get("lab_command"):
        argv = chapter["lab_command"]
        # vitest invocations read better as their npx form
        if any("vitest" in arg for arg in argv):
            tail = " ".join(argv[argv.index("run") + 1 :]) if "run" in argv else ""
            return f"`vitest run {tail}`".replace("  ", " ")
        return "`" + " ".join(argv) + "`"
    return "—"


def sort_key(aid: str) -> tuple[int, str]:
    prefix = aid.split(":", 1)[0]
    return (ID_PREFIX_ORDER.get(prefix, 9), aid)


def ledger_rows() -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """The cross-reference as data: (rows, footprint summary)."""
    atlas_nodes = {
        n["id"]: n for n in json.loads(ATLAS.read_text(encoding="utf-8"))["nodes"]
    }
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))

    taught_in: dict[str, list[str]] = {}
    witness: dict[str, list[str]] = {}
    for chapter in registry["chapters"]:
        if chapter["status"] != "drafted":
            continue
        text = (ROOT / chapter["file"]).read_text(encoding="utf-8")
        label = lab_label(chapter)
        for aid in sorted(set(ATLAS_REF_RE.findall(text))):
            taught_in.setdefault(aid, []).append(chapter["id"])
            if label != "—" and label not in witness.setdefault(aid, []):
                witness[aid].append(label)

    rows: list[dict[str, Any]] = []
    for aid in sorted(taught_in, key=sort_key):
        node = atlas_nodes.get(aid)
        if node is None:
            raise SystemExit(f"chapter cites unknown atlas id {aid!r}; run book_audit")
        claim = node.get("status_ledger_claim")
        rows.append(
            {
                "id": aid,
                "title": (node.get("title") or "").strip() or "(untitled)",
                "type": node.get("type"),
                "ledger": claim,
                "ledger_gloss": STATUS_GLOSS[claim] if claim else None,
                "proof": (node.get("proof_status") or "—").replace("_", " "),
                "taught_in": taught_in[aid],
                "witnessed_by": [w.strip("`") for w in witness.get(aid, [])],
            }
        )

    cited = set(taught_in)
    uncited = [n for n in atlas_nodes.values() if n["id"] not in cited]
    by_type: dict[str, int] = {}
    for node in uncited:
        by_type[node["type"]] = by_type.get(node["type"], 0) + 1
    footprint = {
        "taught": len(cited),
        "total": len(atlas_nodes),
        "untaught": len(uncited),
        "untaught_by_type": dict(sorted(by_type.items())),
    }
    return rows, footprint


def build_appendix() -> str:
    rows, footprint = ledger_rows()
    lines = [PREAMBLE]
    lines.append("| Atlas id | Statement | Ledger | Proof (paper) | Taught in | Witnessed by |")
    lines.append("|---|---|---|---|---|---|")
    for row in rows:
        ledger = (
            f"**{row['ledger']}** ({row['ledger_gloss']})" if row["ledger"] else "—"
        )
        labs = "; ".join(f"`{w}`" for w in row["witnessed_by"]) or "—"
        lines.append(
            f"| `{row['id']}` | {row['title']} | {ledger} | {row['proof']} "
            f"| {', '.join(row['taught_in'])} | {labs} |"
        )

    remainder = ", ".join(
        f"{count} {kind}{'s' if count != 1 else ''}"
        for kind, count in footprint["untaught_by_type"].items()
    )
    lines.append("")
    lines.append(
        f"**Footprint.** The book teaches {footprint['taught']} of the paper's "
        f"{footprint['total']} atlas nodes. The remaining {footprint['untaught']} "
        f"({remainder}) are the paper's own business — mostly remarks and "
        f"scaffolding the pedagogy does not need. A node absent here is "
        f"not a claim the book makes silently; it is a claim the book "
        f"does not make."
    )
    lines.append("")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    expected = build_appendix()
    if args.check:
        if not OUTPUT.is_file():
            print(f"[LEDGER_DRIFT] missing {OUTPUT.relative_to(ROOT)}")
            return 1
        if OUTPUT.read_text(encoding="utf-8") != expected:
            print(f"[LEDGER_DRIFT] stale {OUTPUT.relative_to(ROOT)}")
            return 1
        print("appendix current")
        return 0
    OUTPUT.write_text(expected, encoding="utf-8", newline="\n")
    print(f"wrote {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
