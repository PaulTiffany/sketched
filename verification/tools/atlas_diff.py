"""Atlas diff: the mechanical change manifest between two paper versions.

    python verification/tools/atlas_diff.py [old.tex] [new.tex] [--json OUT]

With no positional args, diffs the two highest-numbered
forcing_correspondence_v*.tex in the repo root (old = second-highest).

Reports, keyed on atlas node id:

  ADDED / REMOVED     node ids present in one version only
  RENAME_CANDIDATE    a REMOVED and an ADDED node with identical
                      statement_sha — probably the same statement under a
                      new label; confirming identity is a judgment call
  STATEMENT_CHANGED   same id, different statement_sha (label-insensitive,
                      whitespace/comment-insensitive content hash)
  TYPE_CHANGED        environment changed, e.g. conjecture -> theorem
                      (a promotion; the book's STATUS_MISMATCH audit will
                      also demand the pedagogy follow)
  STATUS_CHANGED      proof_status moved (e.g. stated_no_proof -> proved)
  RETITLED            title changed (statement hash covers titles, so this
                      accompanies STATEMENT_CHANGED; listed for legibility)

This is a manifest, not an audit: it always exits 0. Its consumers are
human judgment and binding_audit.py, which decides what counts as stale.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from atlas_extract import extract

ROOT = Path(__file__).resolve().parents[2]


def default_pair() -> tuple[Path, Path]:
    candidates = sorted(
        ROOT.glob("forcing_correspondence_v*.tex"),
        key=lambda p: int(re.search(r"v(\d+)", p.stem).group(1)),
    )
    if len(candidates) < 2:
        sys.exit("need two forcing_correspondence_v*.tex versions to diff")
    return candidates[-2], candidates[-1]


def diff(old: dict, new: dict) -> dict:
    old_nodes = {n["id"]: n for n in old["nodes"]}
    new_nodes = {n["id"]: n for n in new["nodes"]}
    added = sorted(set(new_nodes) - set(old_nodes))
    removed = sorted(set(old_nodes) - set(new_nodes))

    added_by_sha = {new_nodes[i]["statement_sha"]: i for i in added}
    renames = sorted(
        (i, added_by_sha[old_nodes[i]["statement_sha"]])
        for i in removed
        if old_nodes[i]["statement_sha"] in added_by_sha
    )

    changed, promoted, status_moved, retitled = [], [], [], []
    for i in sorted(set(old_nodes) & set(new_nodes)):
        o, n = old_nodes[i], new_nodes[i]
        if o["statement_sha"] != n["statement_sha"]:
            changed.append(i)
        if o["type"] != n["type"]:
            promoted.append((i, o["type"], n["type"]))
        if o["proof_status"] != n["proof_status"]:
            status_moved.append((i, o["proof_status"], n["proof_status"]))
        if o["title"] != n["title"]:
            retitled.append(i)

    return {
        "old": old["source"],
        "new": new["source"],
        "added": added,
        "removed": removed,
        "rename_candidates": renames,
        "statement_changed": changed,
        "type_changed": promoted,
        "status_changed": status_moved,
        "retitled": retitled,
    }


def main() -> int:
    args = [a for a in sys.argv[1:] if a != "--json" and not a.endswith(".json")]
    json_out = None
    if "--json" in sys.argv:
        idx = sys.argv.index("--json")
        if idx + 1 >= len(sys.argv):
            sys.exit("--json requires an output path")
        json_out = Path(sys.argv[idx + 1])

    if args:
        old_tex, new_tex = Path(args[0]).resolve(), Path(args[1]).resolve()
    else:
        old_tex, new_tex = default_pair()

    manifest = diff(extract(old_tex), extract(new_tex))

    print(f"atlas diff: {manifest['old']} -> {manifest['new']}\n")
    for key, label in (
        ("added", "ADDED"),
        ("removed", "REMOVED"),
        ("rename_candidates", "RENAME_CANDIDATE"),
        ("statement_changed", "STATEMENT_CHANGED"),
        ("type_changed", "TYPE_CHANGED"),
        ("status_changed", "STATUS_CHANGED"),
        ("retitled", "RETITLED"),
    ):
        for item in manifest[key]:
            if isinstance(item, tuple) or isinstance(item, list):
                print(f"[{label}] " + " -> ".join(str(x) for x in item))
            else:
                print(f"[{label}] {item}")

    total = sum(len(manifest[k]) for k in (
        "added", "removed", "rename_candidates", "statement_changed",
        "type_changed", "status_changed", "retitled"))
    print(f"\n{total} manifest entries (manifest, not audit: exit 0 always; "
          "binding_audit.py decides staleness)")
    if json_out:
        json_out.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {json_out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
