"""Cut a self-contained work packet from the Principia atlas.

The inference-economy tool for sprint workers: instead of a worker agent
re-reading the corpus (the expensive phase), the lead slices exactly the
anchors a packet needs — verbatim latex bodies plus their current
statement shas — into one text block that travels INSIDE the worker's
prompt. The worker gets no filesystem archaeology, only the statements;
the shas let the lead bind whatever comes back without re-deriving them.

Usage:
  python atlas_slice.py --book book3                 # whole book
  python atlas_slice.py --labels a,b,c               # named anchors
  python atlas_slice.py --book book3 --types theorem,lemma
  python atlas_slice.py --book book3 --out packet.md # write to file

Claim-bearing types default to theorem/proposition/lemma/corollary/axiom
plus definition (workers need the definitions to state the claims).
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from atlas_extract import statement_sha  # noqa: E402

DEFAULT_TYPES = ["definition", "axiom", "lemma", "proposition", "theorem",
                 "corollary"]


def atlas_path() -> Path | None:
    configured = os.environ.get("PRINCIPIA_ATLAS")
    candidates = [
        Path(configured) if configured else None,
        ROOT.parent / "principia" / "bib" / "principia_atlas.json",
        ROOT / "verification" / "principia_atlas.json",
    ]
    return next((p for p in candidates if p and p.is_file()), None)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--book")
    parser.add_argument("--labels", help="comma-separated anchor labels")
    parser.add_argument("--types", default=",".join(DEFAULT_TYPES))
    parser.add_argument("--out", help="write packet here instead of stdout")
    args = parser.parse_args()
    if not args.book and not args.labels:
        parser.error("need --book or --labels")

    src = atlas_path()
    if src is None:
        print("Principia atlas not found", file=sys.stderr)
        return 1
    atlas = json.loads(src.read_text(encoding="utf-8"))
    bylab = {n["label"]: n for n in atlas["nodes"] if "label" in n}

    types = {t.strip() for t in args.types.split(",") if t.strip()}
    if args.labels:
        labels = [l.strip() for l in args.labels.split(",") if l.strip()]
        missing = [l for l in labels if l not in bylab]
        if missing:
            print(f"unknown labels: {missing}", file=sys.stderr)
            return 1
        nodes = [bylab[l] for l in labels]
    else:
        nodes = [n for n in atlas["nodes"]
                 if n.get("book") == args.book and n.get("type") in types]
        if not nodes:
            print(f"no nodes for book {args.book!r}", file=sys.stderr)
            return 1

    lines = [
        f"# Principia atlas slice ({args.book or 'labels'})",
        "",
        "Verbatim statements with current statement shas. Formalize from",
        "THESE texts only; do not paraphrase from memory. Each anchor's sha",
        "is what the lead will pin the resulting binding to.",
        "",
    ]
    for n in nodes:
        sha = statement_sha(n.get("latex_body", ""))
        lines += [
            "-" * 72,
            f"ANCHOR: {n['label']}",
            f"TYPE: {n.get('type')}   NAME: {n.get('name') or ''}",
            f"STATEMENT_SHA: {sha}",
            "",
            n.get("latex_body", "").strip(),
            "",
        ]
    lines.append(f"({len(nodes)} anchors)")
    packet = "\n".join(lines)

    if args.out:
        Path(args.out).write_text(packet, encoding="utf-8")
        print(f"{len(nodes)} anchors -> {args.out} "
              f"({len(packet)} chars)", file=sys.stderr)
    else:
        print(packet)
    return 0


if __name__ == "__main__":
    sys.exit(main())
