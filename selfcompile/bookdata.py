"""Bridge to the real textbook architecture.

Reads the book's own registry (chapters + prerequisite graph + atlas_refs) and
the verified atlas (ledger status + proof status per node). The self-compile
engine now prioritizes over THESE, not a toy -- and where an atlas node maps to
a Lean theorem, Matt can ground it in the kernel receipt as well as the ledger.
"""
from __future__ import annotations

import json
from pathlib import Path

SKETCHED = Path(r"C:\src\sketched")
REGISTRY = SKETCHED / "book" / "registry.json"
ATLAS = SKETCHED / "verification" / "atlas.json"

# atlas node -> ForcingAnalysis Lean theorem (kernel receipt via lean_check)
ATLAS_LEAN = {
    "thm:nonid": "transport_identity_iff_residue",
    "prop:chi": "exportability_identity",
    "lem:cauchy": "cauchy_forcing_completion",
    "lem:ordmet": "order_metric_compatibility",
}

_reg = None
_atlas = None


def chapters() -> list[dict]:
    global _reg
    if _reg is None:
        _reg = json.loads(REGISTRY.read_text(encoding="utf-8"))["chapters"]
    return _reg


def chapter(cid: str) -> dict:
    return next(c for c in chapters() if c["id"] == cid)


def atlas_node(aid: str) -> dict | None:
    global _atlas
    if _atlas is None:
        _atlas = {n["id"]: n for n in
                  json.loads(ATLAS.read_text(encoding="utf-8"))["nodes"]}
    return _atlas.get(aid)


def key_refs(cid: str, limit: int = 3) -> list[str]:
    """The chapter's atlas ids, Lean-grounded ones first (best evidence)."""
    refs = chapter(cid)["atlas_refs"]
    lean = [r for r in refs if r in ATLAS_LEAN]
    rest = [r for r in refs if r not in ATLAS_LEAN]
    return (lean + rest)[:limit]
