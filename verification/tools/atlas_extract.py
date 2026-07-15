"""Atlas extractor: forcing_correspondence_v*.tex -> atlas.json (targets the
highest-numbered version present; v15 at the time of writing).

Parses the TeX source as a formal dependency object. Every theorem-like
environment becomes an atlas node; \\ref occurrences become dependency edges
classified by where they occur (statement vs. attached proof vs. remark);
named postulate tokens (M-Pers, M-Cvx, ...) and external cross-document
references (Eq.~1, Cacophony, ...) are scanned per node.

Mechanical only: no hand-curated judgments are injected here. Judgment lives
in loop_detect.py / ledger_audit.py, which consume this output.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "verification" / "atlas.json"


def resolve_tex() -> Path:
    """argv[1] if given, else the highest-versioned forcing_correspondence_v*.tex."""
    if len(sys.argv) > 1:
        return Path(sys.argv[1]).resolve()
    candidates = sorted(
        ROOT.glob("forcing_correspondence_v*.tex"),
        key=lambda p: int(re.search(r"v(\d+)", p.stem).group(1)),
    )
    if not candidates:
        sys.exit("no forcing_correspondence_v*.tex found")
    return candidates[-1]


def statement_sha(text: str) -> str:
    """Content hash of a statement, insensitive to labels and whitespace.

    Labels are identity, not content: renaming a node must not read as a
    statement change (renames are the atlas_diff/RENAME_CANDIDATE channel).
    Comments and whitespace are presentation. Everything else — including
    the environment title — counts: over-detection routes to re-attestation,
    which fails safe.
    """
    body = re.sub(r"(?<!\\)%.*", "", text)
    body = re.sub(r"\\label\{[^}]*\}", "", body)
    body = re.sub(r"\s+", " ", body).strip()
    return hashlib.sha256(body.encode("utf-8")).hexdigest()[:12]

THEOREM_ENVS = {
    "definition": "definition",
    "assumption": "assumption",
    "lemma": "lemma",
    "proposition": "proposition",
    "theorem": "theorem",
    "theoremtarget": "theorem_target",
    "conjecture": "conjecture",
    "remark": "remark",
}

# Named modeling/calibration/open tokens. Patterns are deliberately narrow;
# known limitation: "(ii)" also names item (ii) of Thm nonid's equality
# condition, so the C-smooth-ii pattern requires a qualifying context word.
ASSUMPTION_PATTERNS = {
    "M-Pers": r"M-Pers",
    "M-Cvx": r"M-Cvx",
    "M-Cl": r"M-Cl\b",
    "M-Bridge": r"M-Bridge",
    "C-smooth-ii": r"(?:contract\}?~?\s*\(ii\)|[Hh]ypothesis\s*\(ii\)|smoothness\s+contract|displacement\s+contract|\(ii\)\s+(?:holds|fails)|conditional\s+on\s+\(ii\)|asm:smooth)",
    "C-calibration-queue": r"calibration\s+(?:queue|hypothesis)|asm:calibration",
    "M-Bound": r"M-Bound|resource-bounded\s+observer|observer\s+bounded-countability",
    "O-quantifiers": r"[Qq]uantifiers[^.]{0,40}open|\\emph\{Quantifiers\}",
}

# Macro/symbol usage -> defining node. Catches dependencies that carry no
# \ref (e.g. def:force uses \Stab without citing the Stability definition).
# Used for assumption blast-radius closure, kept separate from ref edges.
# Values are candidate node ids, first existing one wins (v15 labels first,
# v14 synthetic slugs as fallback).
SYMBOL_MAP = {
    r"\\Stab\b|A_\\varphi\b": ["def:stab", "defi:stability"],
    r"\\forcesH\b|\\nforcesH\b|\\forcesnn\b|\\nforcesnn\b": ["def:force"],
    r"\\PHeta\b": ["def:refine", "defi:refinement-order-and-channel-margin"],
    r"\\Jadm\b": ["def:site"],
    r"\\Jwit\b": ["def:wit"],
    r"\\Dadm\b": ["def:req"],
    r"\\Kt\b": ["def:cond", "defi:conditions"],
    r"\\mathcal\{D\}_p\^\\ast": ["def:closure"],
    r"D_\\varphi\b": ["def:clauses"],
}

EXTERNAL_PATTERNS = {
    "HS:Eq1": r"Eq\.~?1\b",
    "HS:AxiomH0": r"Axiom\s+H\.0",
    "HS:S4.1": r"Hypothesis\s+Surface\s+\\S4\.1",
    "HS:generators-3a-3d": r"3a--3d",
    "cacophony": r"Cacophony",
    "cacophony:M20": r"Thm\.~?M\.20|M\.20",
    "principia": r"Principia",
}


def slugify(title: str, prefix: str) -> str:
    words = re.sub(r"[^a-z0-9 -]", "", title.lower()).split()
    return prefix + ":" + "-".join(words[:4] or ["untitled"])


def extract(tex: Path) -> dict:
    """Parse one TeX source into the atlas dict (pure; writes nothing)."""
    lines = tex.read_text(encoding="utf-8").splitlines()

    nodes = []
    sections = []  # (line, title)
    open_env = None  # dict for the env being read
    last_theorem_node = None  # for attaching proofs
    in_proof_for = None

    begin_re = re.compile(r"\\begin\{(\w+)\}(?:\[([^\]]*)\])?")
    end_re = re.compile(r"\\end\{(\w+)\}")
    label_re = re.compile(r"\\label\{([^}]*)\}")
    ref_re = re.compile(r"\\ref\{([^}]*)\}")
    section_re = re.compile(r"\\section\*?\{([^}]*)\}")

    for i, line in enumerate(lines, start=1):
        msec = section_re.search(line)
        if msec:
            sections.append((i, msec.group(1)))

        for m in begin_re.finditer(line):
            env = m.group(1)
            if env in THEOREM_ENVS:
                open_env = {
                    "env": env,
                    "type": THEOREM_ENVS[env],
                    "title": m.group(2) or "",
                    "label": None,
                    "start": i,
                    "end": None,
                    "statement_refs": [],
                    "text_lines": [],
                }
            elif env == "proof" and last_theorem_node is not None:
                in_proof_for = last_theorem_node
                in_proof_for["proof_span"] = [i, None]
                in_proof_for["proof_refs"] = in_proof_for.get("proof_refs", [])
                in_proof_for["proof_text"] = in_proof_for.get("proof_text", [])

        if open_env is not None:
            mlab = label_re.search(line)
            if mlab and open_env["label"] is None:
                open_env["label"] = mlab.group(1)
            open_env["statement_refs"] += ref_re.findall(line)
            open_env["text_lines"].append(line)
        elif in_proof_for is not None:
            in_proof_for["proof_refs"] += ref_re.findall(line)
            in_proof_for["proof_text"].append(line)

        for m in end_re.finditer(line):
            env = m.group(1)
            if open_env is not None and env == open_env["env"]:
                open_env["end"] = i
                nodes.append(open_env)
                if open_env["type"] != "remark":
                    last_theorem_node = open_env
                open_env = None
            elif env == "proof" and in_proof_for is not None:
                in_proof_for["proof_span"][1] = i
                in_proof_for = None

    # Assign IDs and section context.
    seen_ids = set()
    for n in nodes:
        nid = n["label"] or slugify(n["title"], n["env"][:4])
        while nid in seen_ids:
            nid += "-b"
        seen_ids.add(nid)
        n["id"] = nid
        n["section"] = next(
            (t for (ln, t) in reversed(sections) if ln <= n["start"]), None
        )

    label_to_id = {n["label"]: n["id"] for n in nodes if n["label"]}

    # First-occurrence sites of assumption tokens (for smuggle detection).
    # Scan starts at the first \section so the abstract cannot front-run the
    # defining occurrence.
    full_text = "\n".join(lines)
    body_start = full_text.find("\\section")
    if body_start < 0:
        body_start = 0
    # A token counts as anchored if ANY occurrence lies inside a definition or
    # assumption environment (the defining site); otherwise its first
    # occurrence determines the smuggle classification.
    assumption_first = {}
    for token, pat in ASSUMPTION_PATTERNS.items():
        best = None
        for m in re.finditer(pat, full_text[body_start:]):
            line_no = full_text[: body_start + m.start()].count("\n") + 1
            host = next(
                (
                    n
                    for n in nodes
                    if n["start"] <= line_no <= max(n["end"], n.get("proof_span", [0, 0])[1] or 0)
                ),
                None,
            )
            rec = {
                "line": line_no,
                "host_env": host["type"] if host else "prose",
                "host_id": host["id"] if host else None,
            }
            if best is None:
                best = rec
            if rec["host_env"] in ("definition", "assumption"):
                best = rec
                break
        if best is not None:
            assumption_first[token] = best

    def scan(text: str, patterns: dict) -> list:
        return sorted(t for t, p in patterns.items() if re.search(p, text))

    records = []
    for n in nodes:
        stmt_text = "\n".join(n["text_lines"])
        proof_text = "\n".join(n.get("proof_text", []))

        def resolve(refs):
            hard, dangling = [], []
            for r in refs:
                if r.startswith("sec:"):
                    continue  # section refs are expository
                (hard if r in label_to_id else dangling).append(r)
            return sorted(set(hard)), sorted(set(dangling))

        stmt_hard, stmt_dangling = resolve(n["statement_refs"])
        proof_hard, proof_dangling = resolve(n.get("proof_refs", []))

        has_proof = "proof_span" in n
        if n["type"] == "theorem_target":
            proof_status = "target"
        elif n["type"] == "remark":
            proof_status = "n/a"
        elif has_proof:
            proof_status = "proved"
        elif "\\cite{" in stmt_text:
            proof_status = "stated_no_proof_cited"
        else:
            proof_status = "stated_no_proof"

        soft = n["type"] == "remark"
        symbol_deps = sorted(
            {
                next((c for c in candidates if c in seen_ids), candidates[0])
                for pat, candidates in SYMBOL_MAP.items()
                if re.search(pat, stmt_text + "\n" + proof_text)
            }
            & seen_ids
            - {n["id"]}
        )
        records.append(
            {
                "id": n["id"],
                "type": n["type"],
                "title": n["title"],
                "statement_sha": statement_sha(stmt_text),
                "section": n["section"],
                "source_span": [n["start"], n["end"]],
                "proof_span": n.get("proof_span"),
                "proof_status": proof_status,
                "hard_dependencies": [] if soft else sorted(set(stmt_hard + proof_hard)),
                "statement_dependencies": stmt_hard,
                "proof_dependencies": proof_hard,
                "soft_dependencies": stmt_hard if soft else [],
                "symbol_dependencies": symbol_deps,
                "dangling_refs": sorted(set(stmt_dangling + proof_dangling)),
                "assumptions_consumed": scan(stmt_text + "\n" + proof_text, ASSUMPTION_PATTERNS),
                "external_refs": scan(stmt_text + "\n" + proof_text, EXTERNAL_PATTERNS),
                "status_ledger_claim": None,  # filled by ledger_audit.py
                "risk_notes": [],
            }
        )

    return {
        "source": tex.name,
        "nodes": records,
        "assumption_first_occurrence": assumption_first,
        "sections": [{"line": ln, "title": t} for ln, t in sections],
    }


def main() -> None:
    atlas = extract(resolve_tex())
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(atlas, indent=2), encoding="utf-8")

    records = atlas["nodes"]
    counts = {}
    for r in records:
        counts[r["type"]] = counts.get(r["type"], 0) + 1
    print(f"wrote {OUT} with {len(records)} nodes: {counts}")
    no_proof = [r["id"] for r in records if r["proof_status"].startswith("stated_no_proof")]
    print(f"stated_no_proof: {no_proof}")


if __name__ == "__main__":
    sys.exit(main())
