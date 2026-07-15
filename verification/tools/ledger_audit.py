"""Status-ledger auditor (check C5).

Parses the tabular in \\section{Status ledger} of the TeX source, joins rows
to atlas nodes via \\ref, and checks:

  LEGEND_VIOLATION      status token not exactly one of {P, M, C, O}
  NO_PROOF_MARKED_P     row marked P whose node has no proof environment
  TYPE_MISMATCH         row marked P whose node is a definition/spec
  UNDERCOUNTED_CONSUMES computed transitive assumption closure contains a
                        token not mentioned in the row's Consumes cell
  UNMATCHED_ROW         row that joins to no atlas node (info)
  UNLEDGERED            provable atlas node with no ledger row (info)
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ATLAS = ROOT / "verification" / "atlas.json"


def resolve_tex() -> Path:
    if len(sys.argv) > 1:
        return Path(sys.argv[1]).resolve()
    candidates = sorted(
        ROOT.glob("forcing_correspondence_v*.tex"),
        key=lambda p: int(re.search(r"v(\d+)", p.stem).group(1)),
    )
    if not candidates:
        sys.exit("no forcing_correspondence_v*.tex found")
    return candidates[-1]


TEX = resolve_tex()

LEGEND = {"P", "D", "S", "M", "C", "O"}
PROVABLE = {"lemma", "proposition", "theorem"}

# How each assumption token may legitimately appear in a Consumes cell.
TOKEN_ALIASES = {
    "M-Pers": ["M-Pers", "persistence", "soft-min"],
    "M-Cvx": ["M-Cvx", "convex"],
    "M-Cl": ["M-Cl", "closed"],
    "M-Bridge": ["M-Bridge"],
    "C-smooth-ii": ["(ii)", "smoothness", "smooth", "descent (b)", "asm:smooth"],
    "C-calibration-queue": ["calibration", "asm:calibration"],
    "M-Bound": ["M-Bound", "resource-bounded", "bounded", "countab", "observer bound"],
    "O-quantifiers": ["quantifier"],
}


def parse_ledger_rows(tex: str) -> list:
    m = re.search(r"\\section\{Status ledger\}.*?(?=\\section\{)", tex, re.S)
    if not m:
        sys.exit("ledger section not found")
    rows = []
    for raw in m.group(0).splitlines():
        line = raw.strip()
        if "&" not in line or not line.endswith(r"\\"):
            continue
        if line.startswith(("\\multicolumn", "\\textbf{Claim}")):
            continue
        cells = [c.strip() for c in re.split(r"(?<!\\)&", line[:-2])]
        if len(cells) != 3:
            continue
        claim, status, consumes = cells
        refs = re.findall(r"\\ref\{([^}]*)\}", claim)
        status_clean = re.sub(r"\\textbf\{([^}]*)\}", r"\1", status)
        status_clean = re.sub(r"\\;|\\,|\\ |\$", "", status_clean).strip()
        rows.append(
            {
                "claim": claim,
                "status": status_clean,
                "consumes": consumes,
                "refs": refs,
            }
        )
    return rows


# Nodes whose direct assumption tokens are AMBIENT: consumed by everything
# through the definition of P_H^eta itself (the ledger preamble declares this
# once), so they are excluded from per-row undercount checks unless the row's
# node reaches the token through some other path.
AMBIENT_NODES = {"def:refine", "defi:refinement-order-and-channel-margin"}


def assumption_closure(node_id: str, nodes: dict, memo: dict) -> set:
    if node_id in memo:
        return memo[node_id]
    memo[node_id] = set()  # cycle guard (cycles exist; loop_detect reports them)
    n = nodes.get(node_id)
    if n is None:
        return set()
    if node_id in AMBIENT_NODES:
        return set()  # ambient debt declared once in the ledger preamble
    acc = set(n["assumptions_consumed"])
    deps = set(n["hard_dependencies"]) | set(n.get("symbol_dependencies", []))
    for d in deps:
        acc |= assumption_closure(d, nodes, memo)
    memo[node_id] = acc
    return acc


def main() -> int:
    tex = TEX.read_text(encoding="utf-8")
    atlas = json.loads(ATLAS.read_text(encoding="utf-8"))
    nodes = {n["id"]: n for n in atlas["nodes"]}
    rows = parse_ledger_rows(tex)
    print(f"parsed {len(rows)} ledger rows\n")

    findings = []
    memo: dict = {}
    matched_ids = set()

    for row in rows:
        rid = next((r for r in row["refs"] if r in nodes), None)
        tag = rid or f"<{row['claim'][:48]}>"

        if row["status"] not in LEGEND:
            findings.append(
                ("LEGEND_VIOLATION", f"{tag}: status token '{row['status']}'")
            )

        if rid is None:
            # P/D/S rows claim results/architecture and must join a formal
            # node; M/C/O rows are named debts and may live in prose.
            if row["status"] and row["status"][0] in "PDS":
                findings.append(
                    ("UNMATCHED_ROW", f"no atlas join: {row['claim'][:60]}")
                )
            else:
                findings.append(
                    ("UNANCHORED_DEBT", f"(info) M/C/O prose row: {row['claim'][:60]}")
                )
            continue

        matched_ids.add(rid)
        node = nodes[rid]
        node["status_ledger_claim"] = row["status"]

        if row["status"].startswith("P"):
            if node["proof_status"].startswith("stated_no_proof"):
                findings.append(
                    (
                        "NO_PROOF_MARKED_P",
                        f"{rid} marked '{row['status']}' but has no proof environment",
                    )
                )
            if node["type"] == "definition":
                findings.append(
                    (
                        "TYPE_MISMATCH",
                        f"{rid} marked '{row['status']}' but is a definition "
                        f"(should be D under the extended legend)",
                    )
                )

        closure = assumption_closure(rid, nodes, memo)
        cell = row["consumes"].lower()
        missing = [
            t
            for t in sorted(closure)
            if not any(a.lower() in cell for a in TOKEN_ALIASES.get(t, [t]))
        ]
        if missing and row["status"].startswith("P"):
            findings.append(
                (
                    "UNDERCOUNTED_CONSUMES",
                    f"{rid}: transitive closure adds {missing}; "
                    f"Consumes cell says only: {row['consumes'][:70]}",
                )
            )

    for n in atlas["nodes"]:
        if n["type"] in PROVABLE and n["id"] not in matched_ids:
            findings.append(("UNLEDGERED", f"{n['id']} ({n['type']}) has no ledger row"))

    order = [
        "LEGEND_VIOLATION", "NO_PROOF_MARKED_P", "TYPE_MISMATCH",
        "UNDERCOUNTED_CONSUMES", "UNMATCHED_ROW", "UNLEDGERED",
        "UNANCHORED_DEBT",
    ]
    findings.sort(key=lambda f: order.index(f[0]))
    for code, msg in findings:
        print(f"[{code}] {msg}")
    print(f"\n{len(findings)} findings.")

    ATLAS.write_text(json.dumps(atlas, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
