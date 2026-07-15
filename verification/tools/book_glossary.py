"""Generate the term-collision glossary from book/collisions.json.

The senses are hand-authored (a machine cannot decide what a word means),
but everything checkable is checked: every evidence anchor must exist and
still contain its quoted phrase, and the per-chapter occurrence counts
are recomputed from the drafted chapters on every run. A sense may cite
external work instead of an evidence anchor; citations are never
mechanically verified, and both the Markdown page and the JSON packet
mark them as such, so the honesty discipline is never overstated.

`glossary_terms()` exposes the same terms as structured data; the browser
projection compiler (book_projection.py) publishes them as
/book/glossary.json so the interface renders the identical glossary.
Emits book/glossary_collisions.md; book_audit.py fails the build when it
drifts.

Usage:
  python verification/tools/book_glossary.py           # (re)write the glossary
  python verification/tools/book_glossary.py --check   # exit 1 if stale
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
COLLISIONS = ROOT / "book" / "collisions.json"
REGISTRY = ROOT / "book" / "registry.json"
OUTPUT = ROOT / "book" / "glossary_collisions.md"

PREAMBLE = """\
# Glossary · Words That Collide

<!-- GENERATED FILE — do not edit by hand.
     Senses live in book/collisions.json; regenerate with
     python verification/tools/book_glossary.py.
     Verified current on every build by verification/tools/book_audit.py. -->

The paper and Sketched share vocabulary but not referents, and chapter 02
warns about the two worst offenders in a box the reader is told to read
twice (§"Two words that collide"). This glossary is that box,
industrialized: every double-booked term, each of its senses, and either
a verified anchor (a file that exists and still contains the quoted
phrase, re-checked on every build) or an explicit citation to outside
work, marked as unverified because a build inside this repository cannot
check a source that lives outside it. The *meanings* are hand-written (no
tool can decide what a word means); everything checkable around them is
machine-checked, including the occurrence counts below, so this page
cannot quietly outlive a renaming.
"""


def occurrences(term: str, text: str) -> int:
    return len(re.findall(rf"\b{re.escape(term)}\w*", text, flags=re.IGNORECASE))


def glossary_terms() -> list[dict[str, Any]]:
    """The glossary as data: one entry per term, each sense's anchors
    verified (repo evidence) or flagged unverified (external citation)."""
    data = json.loads(COLLISIONS.read_text(encoding="utf-8"))
    if data.get("schema_version") != 1:
        raise SystemExit("collisions.json schema_version must be 1")
    registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    chapters = [
        (ch["id"], (ROOT / ch["file"]).read_text(encoding="utf-8"))
        for ch in registry["chapters"]
        if ch["status"] == "drafted"
    ]

    terms: list[dict[str, Any]] = []
    for entry in data["terms"]:
        term = entry["term"]
        senses: list[dict[str, Any]] = []
        for sense in entry["senses"]:
            anchors: list[str] = []
            for ev in sense.get("evidence", []):
                path = ROOT / ev["file"]
                if not path.is_file():
                    raise SystemExit(
                        f"{term}/{sense['context']}: evidence file missing: {ev['file']}"
                    )
                if ev["contains"] not in path.read_text(encoding="utf-8"):
                    raise SystemExit(
                        f"{term}/{sense['context']}: {ev['file']} no longer "
                        f"contains {ev['contains']!r}"
                    )
                anchors.append(ev["file"])
            citation = sense.get("citation")
            if not anchors and not citation:
                raise SystemExit(
                    f"{term}/{sense['context']}: sense has neither evidence nor citation"
                )
            senses.append(
                {
                    "context": sense["context"],
                    "meaning": sense["meaning"],
                    "anchors": anchors,
                    "citation": citation,
                }
            )
        counts = {
            cid: n
            for cid, text in chapters
            if (n := occurrences(term, text)) > 0
        }
        terms.append(
            {
                "term": term,
                "rule": entry["rule"],
                "senses": senses,
                "occurrences": counts,
            }
        )
    return terms


def build_glossary() -> str:
    terms = glossary_terms()
    lines = [PREAMBLE]
    for entry in terms:
        lines.append(f"## {entry['term']}")
        lines.append("")
        lines.append("| Sense | Meaning | Anchor |")
        lines.append("|---|---|---|")
        for sense in entry["senses"]:
            if sense["anchors"]:
                anchor_cell = "; ".join(f"`{a}`" for a in sense["anchors"])
            else:
                anchor_cell = f"_cited, not verified: {sense['citation']}_"
            lines.append(
                f"| **{sense['context']}** | {sense['meaning']} | {anchor_cell} |"
            )
        lines.append("")
        lines.append(f"**Rule.** {entry['rule']}")
        counts = [f"{cid} ({n})" for cid, n in entry["occurrences"].items()]
        lines.append("")
        lines.append(
            f"**Where the reader meets it:** {', '.join(counts) if counts else 'nowhere yet'}."
        )
        lines.append("")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    expected = build_glossary()
    if args.check:
        if not OUTPUT.is_file():
            print(f"[GLOSSARY_DRIFT] missing {OUTPUT.relative_to(ROOT)}")
            return 1
        if OUTPUT.read_text(encoding="utf-8") != expected:
            print(f"[GLOSSARY_DRIFT] stale {OUTPUT.relative_to(ROOT)}")
            return 1
        print("glossary current")
        return 0
    OUTPUT.write_text(expected, encoding="utf-8", newline="\n")
    print(f"wrote {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
