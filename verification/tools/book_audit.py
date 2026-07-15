"""Book auditor: the pedagogy under the same discipline as the paper.

Reads book/registry.json and verifies:

  CHAPTER_MISSING    a 'drafted' chapter file does not exist
  ANCHOR_MISSING     a drafted chapter does not mention a declared atlas id
  ANCHOR_UNREGISTERED a chapter cites an atlas id absent from its registry row
  ATLAS_ID_UNKNOWN   a cited or declared atlas id resolves to no atlas node
  REGISTRY_VERSION   registry schema version is unsupported
  REGISTRY_DUPLICATE chapter ids, files, or atlas refs are duplicated
  STATUS_TAG_UNKNOWN a canonical tagged mention uses a letter outside PDSMCO/obs
  STATUS_MISMATCH    a chapter's status tag for an id contradicts the ledger:
                     every tagged mention `id`, **X** must include the atlas
                     node's status_ledger_claim among its letters (compound
                     tags like "P atomic / O compound" pass if the claim is
                     one of them); definitions with no ledger row must be D;
                     untagged mentions are not findings
  CODE_REF_MISSING   a declared code anchor's file/export is absent
  LAB_MISSING        a declared lab file does not exist
  LAB_COMMAND_INVALID a declared lab command is empty or malformed
  LAB_FAILED         a declared lab exits nonzero
  SOLUTION_MISSING   a declared solution script does not exist
  SOLUTION_FAILED    a declared solution script exits nonzero (the
                     chapter's predict-then-run answer no longer holds)
  SOLUTION_NOTE_INVALID a declared solutions_note's referenced file is
                     missing or no longer contains its quoted phrase
                     (used when the answer key is an existing test rather
                     than a new script, e.g. a chapter bound to vitest)
  PROJECTION_DRIFT   browser projection packets are missing or stale
  LEDGER_DRIFT       the generated appendix (book/appendix_a_the_ledger.md)
                     is missing or stale relative to atlas/registry/chapters
  GLOSSARY_DRIFT     the generated glossary (book/glossary_collisions.md) is
                     missing/stale, or a collision sense's evidence anchor
                     no longer contains its quoted phrase
  STATUS_UNKNOWN     chapter status not in {drafted, outline}

Skips cleanly (packet mode) when book/ is absent. Exit 1 on any finding.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REGISTRY = ROOT / "book" / "registry.json"
ATLAS = ROOT / "verification" / "atlas.json"
PROJECTION = ROOT / "verification" / "tools" / "book_projection.py"
LEDGER = ROOT / "verification" / "tools" / "book_ledger.py"
GLOSSARY = ROOT / "verification" / "tools" / "book_glossary.py"

EXPORT_RE = "export\\s+(?:async\\s+)?(?:function|const|let|class|interface|type|enum)\\s+{name}\\b"

REGISTRY_SCHEMA_VERSION = 2
ATLAS_REF_RE = re.compile(r"`((?:def|lem|thm|prop|asm|rem):[^`]+)`")

# Status tokens the book vocabulary allows on a tagged mention.
STATUS_TAGS = set("PDSMCO") | {"obs"}
# A "tagged mention" uses the canonical `id`, **X** syntax: the comma must
# be followed immediately by a single-letter status or `obs`. This excludes
# ordinary prose such as (`lem:dec`, chapter 04) while retaining compound
# tags such as P atomic / O compound. The window ends at the first closing
# paren, period, semicolon, or em-dash (or TAG_WINDOW characters), and only
# the leading token plus *bolded* tokens count as tags, so a lone capital in
# following prose ("see Lemma B") is never read as a status.
TAG_WINDOW = 48
TAG_WINDOW_END_RE = re.compile(r"[).;—]")
LEADING_TAG_RE = re.compile(r"^\s*\*{0,2}(obs|[A-Z])\*{0,2}(?![\w*])")
BOLD_TAG_RE = re.compile(r"\*\*(obs|[A-Z])\*\*(?![\w*])")


def status_tags_near(text: str, aid: str) -> list[set[str]]:
    """Sets of status letters found on each tagged mention of `aid`."""
    out: list[set[str]] = []
    for m in re.finditer(re.escape(f"`{aid}`") + r"\s*,", text):
        window = TAG_WINDOW_END_RE.split(text[m.end() : m.end() + TAG_WINDOW])[0]
        lead = LEADING_TAG_RE.search(window)
        if not lead:
            continue  # a prose comma, not canonical status syntax
        tags = {lead.group(1)}
        tags.update(t.group(1) for t in BOLD_TAG_RE.finditer(window))
        out.append(tags)
    return out


def classify_tag_mention(tags: set[str], claim: str | None) -> tuple[bool, bool]:
    """(is_unknown, is_mismatch) for one tagged mention's letter set.

    Single source of truth for what counts as a masking event: book_audit's
    STATUS_MISMATCH finding and book_projection's masking-rate mu must agree
    on this exactly, or the enforced invariant and the displayed number can
    silently diverge.
    """
    unknown = bool(tags - STATUS_TAGS)
    valid = tags & STATUS_TAGS
    mismatch = bool(valid) and claim is not None and claim not in valid
    return unknown, mismatch


def main() -> int:
    if not REGISTRY.is_file():
        print("book/ absent — packet mode; book audit skipped")
        return 0
    reg = json.loads(REGISTRY.read_text(encoding="utf-8"))
    findings: list[tuple[str, str]] = []
    if reg.get("schema_version") != REGISTRY_SCHEMA_VERSION:
        findings.append(
            (
                "REGISTRY_VERSION",
                f"expected {REGISTRY_SCHEMA_VERSION}, got {reg.get('schema_version')!r}",
            )
        )
    atlas_nodes = {
        n["id"]: n for n in json.loads(ATLAS.read_text(encoding="utf-8"))["nodes"]
    }
    atlas_ids = set(atlas_nodes)

    drafted = 0
    labs_run = 0
    seen_ids: set[str] = set()
    seen_files: set[str] = set()
    for ch in reg["chapters"]:
        cid = ch["id"]
        if cid in seen_ids:
            findings.append(("REGISTRY_DUPLICATE", f"duplicate chapter id: {cid}"))
        seen_ids.add(cid)
        if ch["file"] in seen_files:
            findings.append(
                ("REGISTRY_DUPLICATE", f"duplicate chapter file: {ch['file']}")
            )
        seen_files.add(ch["file"])
        if len(ch["atlas_refs"]) != len(set(ch["atlas_refs"])):
            findings.append(("REGISTRY_DUPLICATE", f"{cid}: duplicate atlas_refs"))
        if ch["status"] not in ("drafted", "outline"):
            findings.append(("STATUS_UNKNOWN", f"{cid}: '{ch['status']}'"))
        for aid in ch["atlas_refs"]:
            if aid not in atlas_ids:
                findings.append(("ATLAS_ID_UNKNOWN", f"{cid}: '{aid}'"))
        for ref in ch.get("code_refs", []):
            f = ROOT / ref["file"]
            if not f.is_file() or not re.search(
                EXPORT_RE.format(name=re.escape(ref["export"])),
                f.read_text(encoding="utf-8"),
            ):
                findings.append(
                    ("CODE_REF_MISSING", f"{cid}: {ref['file']}#{ref['export']}")
                )
        if ch["status"] != "drafted":
            continue
        drafted += 1
        chapter = ROOT / ch["file"]
        if not chapter.is_file():
            findings.append(("CHAPTER_MISSING", f"{cid}: {ch['file']}"))
            continue
        text = chapter.read_text(encoding="utf-8")
        declared = set(ch["atlas_refs"])
        discovered = set(ATLAS_REF_RE.findall(text))
        for aid in sorted(declared - discovered):
            findings.append(
                ("ANCHOR_MISSING", f"{cid}: drafted chapter never cites '{aid}'")
            )
        for aid in sorted(discovered - declared):
            findings.append(
                ("ANCHOR_UNREGISTERED", f"{cid}: cited atlas id '{aid}'")
            )
        for aid in sorted(discovered):
            node = atlas_nodes.get(aid)
            if node is None:
                if aid not in declared:  # declared unknown ids were reported above
                    findings.append(("ATLAS_ID_UNKNOWN", f"{cid}: '{aid}'"))
                continue
            claim = node.get("status_ledger_claim")
            if claim is None:
                # No ledger row: definitions must read D; other types are
                # unconstrained (their status lives in prose, e.g. 'obs').
                claim = "D" if node.get("type") == "definition" else None
            for tags in status_tags_near(text, aid):
                is_unknown, is_mismatch = classify_tag_mention(tags, claim)
                if is_unknown:
                    findings.append(
                        (
                            "STATUS_TAG_UNKNOWN",
                            f"{cid}: '{aid}' uses {sorted(tags - STATUS_TAGS)}",
                        )
                    )
                if is_mismatch:
                    findings.append(
                        (
                            "STATUS_MISMATCH",
                            f"{cid}: '{aid}' tagged {sorted(tags & STATUS_TAGS)} "
                            f"but the ledger says {claim}",
                        )
                    )
        lab = ch.get("lab")
        lab_command = ch.get("lab_command")
        if not lab and lab_command is None:
            findings.append(("LAB_MISSING", f"{cid}: no lab or lab_command declared"))
        if lab:
            lab_path = ROOT / lab
            if not lab_path.is_file():
                findings.append(("LAB_MISSING", f"{cid}: {lab}"))
            else:
                rc = subprocess.call(
                    [sys.executable, str(lab_path)], stdout=subprocess.DEVNULL
                )
                labs_run += 1
                if rc != 0:
                    findings.append(("LAB_FAILED", f"{cid}: {lab} exit {rc}"))

        note = ch.get("solutions_note")
        if note:
            note_path = ROOT / note["file"]
            if not note_path.is_file() or note["contains"] not in note_path.read_text(
                encoding="utf-8"
            ):
                findings.append(
                    ("SOLUTION_NOTE_INVALID", f"{cid}: {note['file']} no longer contains {note['contains']!r}")
                )

        for sol in ch.get("solutions", []):
            sol_path = ROOT / sol
            if not sol_path.is_file():
                findings.append(("SOLUTION_MISSING", f"{cid}: {sol}"))
            else:
                rc = subprocess.call(
                    [sys.executable, str(sol_path)], stdout=subprocess.DEVNULL
                )
                labs_run += 1
                if rc != 0:
                    findings.append(("SOLUTION_FAILED", f"{cid}: {sol} exit {rc}"))

        if lab_command is not None:
            if (
                not isinstance(lab_command, list)
                or not lab_command
                or not all(isinstance(arg, str) and arg for arg in lab_command)
            ):
                findings.append(
                    ("LAB_COMMAND_INVALID", f"{cid}: lab_command must be a nonempty string array")
                )
            else:
                rc = subprocess.call(
                    lab_command, cwd=ROOT, stdout=subprocess.DEVNULL
                )
                labs_run += 1
                if rc != 0:
                    findings.append(
                        ("LAB_FAILED", f"{cid}: {' '.join(lab_command)} exit {rc}")
                    )

    projection_rc = subprocess.call(
        [sys.executable, str(PROJECTION), "--check"], stdout=subprocess.DEVNULL
    )
    if projection_rc != 0:
        findings.append(("PROJECTION_DRIFT", "run npm run book:project"))
    ledger_rc = subprocess.call(
        [sys.executable, str(LEDGER), "--check"], stdout=subprocess.DEVNULL
    )
    if ledger_rc != 0:
        findings.append(("LEDGER_DRIFT", "run python verification/tools/book_ledger.py"))
    glossary_rc = subprocess.call(
        [sys.executable, str(GLOSSARY), "--check"], stdout=subprocess.DEVNULL
    )
    if glossary_rc != 0:
        findings.append(
            ("GLOSSARY_DRIFT", "run python verification/tools/book_glossary.py")
        )
    for code, msg in findings:
        print(f"[{code}] {msg}")
    print(f"\n{len(findings)} findings; {drafted} drafted chapters "
          f"({len(reg['chapters'])} total), {labs_run} labs run green"
          if not findings else f"\n{len(findings)} findings.")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
