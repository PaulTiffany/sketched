"""Compile canonical book sources into deterministic browser projection packets.

The Markdown chapters remain authoritative. This compiler emits bounded JSON
views for humans and browser-instantiated agents. Content B is represented only
by its protected authorship/interface contract; its reserved prose is never
copied, summarized, or synthesized here.

Usage:
  python verification/tools/book_projection.py
  python verification/tools/book_projection.py --check
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "book" / "registry.json"
PROJECTIONS = ROOT / "book" / "projections.json"
ATLAS = ROOT / "verification" / "atlas.json"
OPERATORS = ROOT / "verification" / "operators.json"
COLLISIONS = ROOT / "book" / "collisions.json"
EULA = ROOT / "EULA.md"
OUTPUT = ROOT / "public" / "book"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from book_audit import classify_tag_mention, status_tags_near  # noqa: E402
from book_ledger import ATLAS_REF_RE, ledger_rows  # noqa: E402
from book_glossary import glossary_terms  # noqa: E402

SECTION_RE = re.compile(r"^## (.+)$", re.MULTILINE)
CONTENT_B_BEGIN = "<!-- BEGIN performative-slot -->"
CONTENT_B_END = "<!-- END performative-slot -->"


class ProjectionError(ValueError):
    """A source or projection contract is invalid."""


def read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ProjectionError(f"{path.relative_to(ROOT)} must contain a JSON object")
    return value

def safe_source(relative: str) -> Path:
    target = (ROOT / relative).resolve()
    try:
        target.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ProjectionError(f"source escapes repository: {relative}") from exc
    if not target.is_file():
        raise ProjectionError(f"source is missing: {relative}")
    return target

def slug(value: str) -> str:
    cleaned = re.sub(r"[^\w\s-]", "", value.lower(), flags=re.UNICODE)
    return re.sub(r"[-\s]+", "-", cleaned).strip("-")


def split_sections(markdown: str) -> list[dict[str, str]]:
    matches = list(SECTION_RE.finditer(markdown))
    sections: list[dict[str, str]] = []
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(markdown)
        title = match.group(1).strip()
        sections.append(
            {
                "id": slug(title),
                "title": title,
                "markdown": markdown[start:end].strip(),
            }
        )
    return sections


def source_digest(paths: list[Path]) -> str:
    digest = hashlib.sha256()
    for path in sorted(paths):
        digest.update(path.relative_to(ROOT).as_posix().encode("utf-8"))
        digest.update(b"::")
        digest.update(path.read_bytes())
        digest.update(b"::")
    return digest.hexdigest()

def chapter_packet(chapter: dict[str, Any]) -> dict[str, Any]:
    source = safe_source(chapter["file"])
    markdown = source.read_text(encoding="utf-8")
    sections = split_sections(markdown)
    if not sections:
        raise ProjectionError(f"{chapter['id']}: chapter has no level-two sections")
    section_map = {section["title"].lower(): section["markdown"] for section in sections}
    if "aim" not in section_map or "boundary note" not in section_map:
        raise ProjectionError(f"{chapter['id']}: chapter must expose Aim and Boundary note")
    lab: dict[str, Any]
    if chapter.get("lab"):
        lab = {"kind": "python", "path": chapter["lab"]}
    elif chapter.get("lab_command"):
        lab = {"kind": "command", "argv": chapter["lab_command"]}
    else:
        raise ProjectionError(f"{chapter['id']}: no lab declared")
    return {
        "schema": "sketched.pedagogy.chapter.v1",
        "id": chapter["id"],
        "title": chapter["title"],
        "status": chapter["status"],
        "prerequisite_ids": chapter["prerequisite_ids"],
        "source_path": chapter["file"],
        "browser_path": f"/book/chapter/{chapter['id']}",
        "json_path": f"/book/chapters/{chapter['id']}.json",
        "aim": section_map["aim"],
        "boundary_note": section_map["boundary note"],
        "atlas_refs": chapter["atlas_refs"],
        "code_refs": chapter.get("code_refs", []),
        "lab": lab,
        "word_count": len(re.findall(r"\b[\w–—'-]+\b", markdown)),
        "sections": sections,
        "raw_markdown": markdown,
    }

def validate_manifest(
    registry: dict[str, Any], projections: dict[str, Any], eula: str
) -> None:
    if projections.get("schema_version") != 1:
        raise ProjectionError("book/projections.json schema_version must be 1")
    chapters = registry.get("chapters")
    paths = projections.get("paths")
    if not isinstance(chapters, list) or not isinstance(paths, list):
        raise ProjectionError("registry chapters and projection paths must be arrays")
    chapter_ids = [chapter.get("id") for chapter in chapters]
    if len(chapter_ids) != len(set(chapter_ids)):
        raise ProjectionError("chapter ids must be unique")
    path_ids = [path.get("id") for path in paths]
    if len(path_ids) != len(set(path_ids)):
        raise ProjectionError("projection path ids must be unique")
    known = set(chapter_ids)
    chapter_map = {chapter["id"]: chapter for chapter in chapters}
    for chapter in chapters:
        cid = chapter["id"]
        prereqs = chapter.get("prerequisite_ids")
        if not isinstance(prereqs, list):
            raise ProjectionError(f"{cid}: prerequisite_ids must be an array")
        if len(prereqs) != len(set(prereqs)):
            raise ProjectionError(f"{cid}: duplicate prerequisites")
        unknown_prereqs = set(prereqs) - known
        if unknown_prereqs:
            raise ProjectionError(f"{cid}: unknown prerequisites {sorted(unknown_prereqs)}")
        if cid in prereqs:
            raise ProjectionError(f"{cid}: chapter cannot require itself")

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(cid: str) -> None:
        if cid in visiting:
            raise ProjectionError(f"prerequisite cycle reaches {cid}")
        if cid in visited:
            return
        visiting.add(cid)
        for prerequisite in chapter_map[cid]["prerequisite_ids"]:
            visit(prerequisite)
        visiting.remove(cid)
        visited.add(cid)

    for cid in chapter_ids:
        visit(cid)

    for path in paths:
        path_id = path.get("id")
        selected = path.get("chapter_ids")
        assumed = path.get("assumed_chapter_ids")
        if not isinstance(selected, list) or not selected:
            raise ProjectionError(f"{path_id}: chapter_ids must be nonempty")
        if not isinstance(assumed, list):
            raise ProjectionError(f"{path_id}: assumed_chapter_ids must be an array")
        unknown = (set(selected) | set(assumed)) - known
        if unknown:
            raise ProjectionError(f"{path_id}: unknown chapters {sorted(unknown)}")
        if len(selected) != len(set(selected)) or len(assumed) != len(set(assumed)):
            raise ProjectionError(f"{path_id}: duplicate chapter ids")
        overlap = set(selected) & set(assumed)
        if overlap:
            raise ProjectionError(f"{path_id}: selected and assumed overlap {sorted(overlap)}")

        assumed_set = set(assumed)
        for assumed_id in assumed:
            missing = set(chapter_map[assumed_id]["prerequisite_ids"]) - assumed_set
            if missing:
                raise ProjectionError(
                    f"{path_id}: assumption {assumed_id} omits {sorted(missing)}"
                )

        available = set(assumed)
        for selected_id in selected:
            missing = set(chapter_map[selected_id]["prerequisite_ids"]) - available
            if missing:
                raise ProjectionError(
                    f"{path_id}: {selected_id} appears before prerequisites {sorted(missing)}"
                )
            available.add(selected_id)
    content_b = projections.get("content_b")
    if not isinstance(content_b, dict) or content_b.get("status") != "reserved":
        raise ProjectionError("Content B must remain an explicit reserved object")
    if content_b.get("owner") != "OmegaClaw":
        raise ProjectionError("Content B owner must remain OmegaClaw")
    if content_b.get("inclusion") != "reference-only":
        raise ProjectionError("Content B inclusion must remain reference-only")
    if "content" in content_b:
        raise ProjectionError("Content B manifest must not contain authored content")
    rules = content_b.get("rules")
    if not isinstance(rules, list) or not rules or not all(isinstance(rule, str) for rule in rules):
        raise ProjectionError("Content B rules must be a nonempty string array")
    if CONTENT_B_BEGIN not in eula or CONTENT_B_END not in eula:
        raise ProjectionError("EULA Content B boundary markers are missing")
    if eula.index(CONTENT_B_BEGIN) >= eula.index(CONTENT_B_END):
        raise ProjectionError("EULA Content B boundary markers are reversed")


def render_json(value: Any) -> str:
    return json.dumps(value, indent=2, ensure_ascii=False) + "\n"

def expected_outputs() -> dict[Path, str]:
    registry = read_json(REGISTRY)
    projections = read_json(PROJECTIONS)
    eula = EULA.read_text(encoding="utf-8")
    validate_manifest(registry, projections, eula)

    chapters = {
        chapter["id"]: chapter_packet(chapter) for chapter in registry["chapters"]
    }
    dependency_edges = [
        {"from": prerequisite, "to": chapter["id"]}
        for chapter in registry["chapters"]
        for prerequisite in chapter["prerequisite_ids"]
    ]
    for chapter_id, packet in chapters.items():
        packet["prerequisites"] = [
            {
                "id": prerequisite,
                "title": chapters[prerequisite]["title"],
                "browser_path": chapters[prerequisite]["browser_path"],
            }
            for prerequisite in packet["prerequisite_ids"]
        ]
        packet["dependents"] = [
            {
                "id": edge["to"],
                "title": chapters[edge["to"]]["title"],
                "browser_path": chapters[edge["to"]]["browser_path"],
            }
            for edge in dependency_edges
            if edge["from"] == chapter_id
        ]
    digest_paths = [REGISTRY, PROJECTIONS, EULA, ATLAS, OPERATORS, COLLISIONS] + [
        ROOT / chapter["file"] for chapter in registry["chapters"]
    ]
    digest = source_digest(digest_paths)
    for packet in chapters.values():
        packet["source_digest"] = digest

    source = projections["content_b"]
    content_b = {
        "schema": "sketched.pedagogy.content-boundary.v1",
        "source_digest": digest,
        "id": source["id"],
        "title": source["title"],
        "owner": source["owner"],
        "status": source["status"],
        "source": source["source"],
        "inclusion": source["inclusion"],
        "content": None,
        "rules": source["rules"],
        "browser_path": "/book/content-b",
        "json_path": "/book/content-b.json",
        "note": (
            "A reserved seat, not a fence. The mathematics of Part A bounds "
            "what Part B may promise, but Part B is what a person actually "
            "reads at the moment of consent — so how OmegaClaw frames those "
            "bounds becomes the contract as experienced. The words are "
            "theirs to write; null is the honest state of words not yet "
            "written."
        ),
    }

    path_summaries: list[dict[str, Any]] = []
    outputs: dict[Path, str] = {}
    for chapter_id, packet in chapters.items():
        outputs[Path("chapters") / f"{chapter_id}.json"] = render_json(packet)

    for path in projections["paths"]:
        summary = {
            **path,
            "browser_path": f"/book/path/{path['id']}",
            "json_path": f"/book/context/{path['id']}.json",
            "chapter_count": len(path["chapter_ids"]),
            "assumption_count": len(path["assumed_chapter_ids"]),
        }
        path_summaries.append(summary)
        packet = {
            "schema": "sketched.pedagogy.projection.v1",
            "source_digest": digest,
            "title": projections["title"],
            "medium": projections["medium"],
            "projection": summary,
            "chain": {
                "assumed_chapter_ids": path["assumed_chapter_ids"],
                "sequence": path["chapter_ids"],
                "edges": [
                    edge
                    for edge in dependency_edges
                    if edge["to"] in path["chapter_ids"]
                    and (
                        edge["from"] in path["chapter_ids"]
                        or edge["from"] in path["assumed_chapter_ids"]
                    )
                ],
            },
            "content_b": content_b if path["includes_content_b"] else {
                "id": content_b["id"],
                "status": "reserved-not-included",
                "owner": content_b["owner"],
                "browser_path": content_b["browser_path"],
            },
            "chapters": [chapters[chapter_id] for chapter_id in path["chapter_ids"]],
        }
        outputs[Path("context") / f"{path['id']}.json"] = render_json(packet)

    rows, footprint = ledger_rows()

    # --- the book's own hypothesis surface (judge-free, text-computed) ----
    atlas_nodes = {
        n["id"]: n for n in read_json(ATLAS)["nodes"]
    }
    tagged = 0
    masked = 0
    for chapter in registry["chapters"]:
        if chapter["status"] != "drafted":
            continue
        text = (ROOT / chapter["file"]).read_text(encoding="utf-8")
        for aid in set(ATLAS_REF_RE.findall(text)):
            node = atlas_nodes.get(aid)
            if node is None:
                continue
            claim = node.get("status_ledger_claim")
            if claim is None and node.get("type") == "definition":
                claim = "D"
            for tags in status_tags_near(text, aid):
                tagged += 1
                _, is_mismatch = classify_tag_mention(tags, claim)
                if is_mismatch:
                    masked += 1

    def band(row: dict[str, Any]) -> str:
        if row["ledger"] in ("P", "D"):
            return "ground"
        if row["ledger"] in ("C", "S", "M"):
            return "frontier"
        if row["ledger"] == "O":
            return "open"
        return "ground" if row["type"] == "definition" else "open"

    geography: dict[str, list[dict[str, Any]]] = {
        "ground": [],
        "frontier": [],
        "open": [],
    }
    for row in rows:
        geography[band(row)].append(row)

    operators = read_json(OPERATORS)["operators"]
    targets = [
        {
            "math_id": op["math_id"],
            "calibration_item": op["calibration_item"],
            "math_operator": op["math_operator"],
            "would_need": op["engineering_operator"],
        }
        for op in operators
        if op.get("status") == "target"
    ]

    surface = {
        "schema": "sketched.pedagogy.surface.v1",
        "source_digest": digest,
        "title": "The Surface of This Book",
        "note": (
            "The book's own epistemic geography, in the sense of the "
            "Hypothesis Surface: no bare claims (every statement carries an "
            "atlas fiber), anti-masking (a chapter may hedge, never claim "
            "above the ledger), typed certificates (torsion is permanent, "
            "contingent is evidence-revisable). Everything on this page is "
            "computed from the chapters and the checked sources at build "
            "time; nothing is judged."
        ),
        "invariants": [
            {
                "name": "No bare claims",
                "surface_form": "every claim carries an epistemic fiber",
                "book_form": (
                    "every mathematical statement cites an atlas anchor; "
                    "uncited or unregistered anchors fail the audit"
                ),
                "enforced_by": "ANCHOR_MISSING / ANCHOR_UNREGISTERED / ATLAS_ID_UNKNOWN",
            },
            {
                "name": "Anti-masking",
                "surface_form": "expressed confidence may not exceed substantiated confidence",
                "book_form": (
                    "a status tag may not claim more than the paper's ledger "
                    "backs; hedging down is legal, masking up fails the build"
                ),
                "enforced_by": "STATUS_MISMATCH",
            },
            {
                "name": "Certificate classification",
                "surface_form": "every impossibility is typed: torsion or contingent",
                "book_form": (
                    "statuses are typed, and the split is taught: torsion is "
                    "structural (the non-identity theorem), open items are "
                    "contingent (the calibration queue, evidence-revisable)"
                ),
                "enforced_by": "STATUS_TAG_UNKNOWN + the ledger vocabulary",
            },
        ],
        "masking": {
            "tagged_mentions": tagged,
            "masked": masked,
            "mu": round(masked / tagged, 4) if tagged else 0.0,
            "note": (
                "masking rate mu = masked tagged mentions / all tagged "
                "mentions, computed from chapter text against the atlas at "
                "packet-build time. The audit fails any build where mu > 0."
            ),
        },
        "geography": {
            "note": (
                "ground: proved or constitutive (P, D). frontier: measured "
                "and revisable (C, S, M). open: owed (O, and untyped "
                "assumptions). Research is the dynamics of the frontier."
            ),
            "ground": geography["ground"],
            "frontier": geography["frontier"],
            "open": geography["open"],
        },
        "voids": {
            "note": (
                "A void is not an error; it is the shape of what the system "
                "does not yet know, with the evidence type that would resolve "
                "it. These are the calibration queue's target operators and "
                "the atlas nodes the book leaves to the paper."
            ),
            "calibration_targets": targets,
            "untaught_nodes": footprint["untaught"],
            "untaught_by_type": footprint["untaught_by_type"],
        },
        "browser_path": "/book/surface",
        "json_path": "/book/surface.json",
    }

    glossary = {
        "schema": "sketched.pedagogy.glossary.v1",
        "source_digest": digest,
        "title": "Glossary: Words That Collide",
        "note": (
            "Every double-booked term, each of its senses, and either a "
            "verified repo anchor or an explicit, unverified citation to "
            "outside work. Identical to book/glossary_collisions.md and "
            "re-checked every build."
        ),
        "terms": glossary_terms(),
        "browser_path": "/book/glossary",
        "json_path": "/book/glossary.json",
    }

    ledger = {
        "schema": "sketched.pedagogy.ledger.v1",
        "source_digest": digest,
        "title": "Appendix A · The Ledger at a Glance",
        "note": (
            "One row per atlas node the book teaches. Generated from the "
            "paper's atlas and the chapter registry; identical to "
            "book/appendix_a_the_ledger.md and re-checked every build."
        ),
        "status_gloss": {
            "P": "proved",
            "D": "definitional",
            "S": "conformance",
            "M": "postulate",
            "C": "contract",
            "O": "open",
        },
        "rows": rows,
        "footprint": footprint,
        "browser_path": "/book/ledger",
        "json_path": "/book/ledger.json",
    }

    meta = {
        "schema": "sketched.pedagogy.index.v1",
        "source_digest": digest,
        "title": projections["title"],
        "medium": projections["medium"],
        "paths": path_summaries,
        "chapters": [
            {
                key: chapter[key]
                for key in (
                    "id",
                    "title",
                    "status",
                    "prerequisite_ids",
                    "source_path",
                    "browser_path",
                    "json_path",
                    "aim",
                    "word_count",
                )
            }
            for chapter in chapters.values()
        ],
        "dependency_graph": {
            "nodes": [
                {"id": chapter["id"], "title": chapter["title"]}
                for chapter in chapters.values()
            ],
            "edges": dependency_edges,
        },
        "content_b": content_b,
        "ledger": {
            "browser_path": ledger["browser_path"],
            "json_path": ledger["json_path"],
            "rows": len(rows),
            "footprint": footprint,
        },
        "surface": {
            "browser_path": surface["browser_path"],
            "json_path": surface["json_path"],
            "mu": surface["masking"]["mu"],
            "ground": len(geography["ground"]),
            "frontier": len(geography["frontier"]),
            "open": len(geography["open"]),
            "voids": len(targets),
        },
        "glossary": {
            "browser_path": glossary["browser_path"],
            "json_path": glossary["json_path"],
            "terms": len(glossary["terms"]),
        },
        "links": {
            "browser_home": "/book",
            "machine_index": "/book/meta.json",
            "content_b": "/book/content-b.json",
            "ledger": "/book/ledger.json",
            "surface": "/book/surface.json",
            "glossary": "/book/glossary.json",
        },
    }
    outputs[Path("meta.json")] = render_json(meta)
    outputs[Path("content-b.json")] = render_json(content_b)
    outputs[Path("ledger.json")] = render_json(ledger)
    outputs[Path("surface.json")] = render_json(surface)
    outputs[Path("glossary.json")] = render_json(glossary)
    return outputs


def check_outputs(outputs: dict[Path, str]) -> int:
    findings: list[str] = []
    expected_paths = {OUTPUT / relative for relative in outputs}
    for relative, expected in outputs.items():
        target = OUTPUT / relative
        if not target.is_file():
            findings.append(f"missing {target.relative_to(ROOT)}")
        elif target.read_text(encoding="utf-8") != expected:
            findings.append(f"stale {target.relative_to(ROOT)}")
    if OUTPUT.is_dir():
        for target in OUTPUT.rglob("*.json"):
            if target not in expected_paths:
                findings.append(f"unexpected {target.relative_to(ROOT)}")
    for finding in findings:
        print(f"[PROJECTION_DRIFT] {finding}")
    if findings:
        print(f"\n{len(findings)} projection findings.")
        return 1
    print(f"0 projection findings; {len(outputs)} browser packets current")
    return 0

def write_outputs(outputs: dict[Path, str]) -> None:
    for relative, content in outputs.items():
        target = OUTPUT / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8", newline="\n")
    expected_paths = {OUTPUT / relative for relative in outputs}
    if OUTPUT.is_dir():
        for target in OUTPUT.rglob("*.json"):
            if target not in expected_paths:
                target.unlink()
    print(f"wrote {len(outputs)} browser packets under {OUTPUT.relative_to(ROOT)}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    try:
        outputs = expected_outputs()
    except (OSError, json.JSONDecodeError, KeyError, TypeError, ProjectionError) as exc:
        print(f"[PROJECTION_INVALID] {exc}")
        return 1
    if args.check:
        return check_outputs(outputs)
    write_outputs(outputs)
    return 0


if __name__ == "__main__":
    sys.exit(main())