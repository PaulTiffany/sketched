"""Loop detector for the forcing-correspondence atlas (checks C1-C4).

Error codes:
  CYCLE            circular hard proof dependency (Tarjan SCC > 1)
  FWD_DEF          a definition's statement references a later node
  FWD_PROOF        a proof or statement references a later node
  REMARK_SMUGGLE   an assumption token consumed by proofs whose defining
                   occurrence lives in a remark
  PROSE_SMUGGLE    same, but the token is never defined in any environment
  TARGET_AS_PROVED a proof depends on a theorem_target as if it were proved
  EXTERNAL_HARD_DEP a proved node's statement/proof cites a cross-document
                   object with no anchor in this paper
  DANGLING_REF     \\ref target that resolves to no label

Exit code 1 iff CYCLE or FWD_DEF or TARGET_AS_PROVED is present.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ATLAS = Path(__file__).resolve().parents[1] / "atlas.json"

PROVABLE = {"lemma", "proposition", "theorem"}


def tarjan_sccs(graph: dict) -> list:
    index_counter = [0]
    stack, lowlink, index, on_stack = [], {}, {}, set()
    sccs = []

    def strongconnect(v):
        index[v] = lowlink[v] = index_counter[0]
        index_counter[0] += 1
        stack.append(v)
        on_stack.add(v)
        for w in graph.get(v, ()):
            if w not in index:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif w in on_stack:
                lowlink[v] = min(lowlink[v], index[w])
        if lowlink[v] == index[v]:
            scc = []
            while True:
                w = stack.pop()
                on_stack.discard(w)
                scc.append(w)
                if w == v:
                    break
            sccs.append(scc)

    for v in list(graph):
        if v not in index:
            strongconnect(v)
    return [s for s in sccs if len(s) > 1]


def main() -> int:
    atlas = json.loads(ATLAS.read_text(encoding="utf-8"))
    nodes = {n["id"]: n for n in atlas["nodes"]}
    findings = []

    # --- C1: cycles over hard (ref) edges, and separately incl. symbol edges.
    ref_graph = {i: set(n["hard_dependencies"]) & set(nodes) for i, n in nodes.items()}
    for scc in tarjan_sccs(ref_graph):
        findings.append(("CYCLE", f"ref-edge cycle: {sorted(scc)}"))
    full_graph = {
        i: (set(n["hard_dependencies"]) | set(n.get("symbol_dependencies", []))) & set(nodes)
        for i, n in nodes.items()
    }
    for scc in tarjan_sccs(full_graph):
        findings.append(("CYCLE", f"symbol-edge cycle: {sorted(scc)}"))

    # --- C2: forward references (position order).
    for n in atlas["nodes"]:
        if n["type"] == "remark":
            continue
        for dep in n["statement_dependencies"]:
            d = nodes.get(dep)
            if d and d["source_span"][0] > n["source_span"][1]:
                code = "FWD_DEF" if n["type"] == "definition" else "FWD_PROOF"
                if n["type"] == "theorem_target":
                    code = "FWD_TARGET_INFO"
                findings.append(
                    (
                        code,
                        f"{n['id']} (lines {n['source_span']}) statement references "
                        f"later node {dep} (line {d['source_span'][0]})",
                    )
                )
        for dep in n["proof_dependencies"]:
            d = nodes.get(dep)
            if d and d["source_span"][0] > (n.get("proof_span") or n["source_span"])[1]:
                findings.append(
                    ("FWD_PROOF", f"proof of {n['id']} references later node {dep}")
                )

    # --- C3: assumption tokens defined outside definition environments.
    first = atlas.get("assumption_first_occurrence", {})
    for token, occ in first.items():
        consumers = [
            n["id"]
            for n in atlas["nodes"]
            if token in n["assumptions_consumed"]
            and n["type"] in PROVABLE
        ]
        if not consumers:
            continue
        if occ["host_env"] == "remark":
            findings.append(
                (
                    "REMARK_SMUGGLE",
                    f"{token}: defining occurrence in remark ({occ['host_id']}, "
                    f"line {occ['line']}); consumed by {consumers}",
                )
            )
        elif occ["host_env"] == "prose":
            findings.append(
                (
                    "PROSE_SMUGGLE",
                    f"{token}: first occurrence in unanchored prose (line "
                    f"{occ['line']}); consumed by {consumers}",
                )
            )

    # --- C4: theorem targets used as proved results.
    targets = {i for i, n in nodes.items() if n["type"] == "theorem_target"}
    for n in atlas["nodes"]:
        if n["type"] == "remark":
            continue
        used = (set(n["proof_dependencies"]) | set(n["statement_dependencies"])) & targets
        for t in used:
            findings.append(("TARGET_AS_PROVED", f"{n['id']} depends on target {t}"))

    # --- External hard deps and dangling refs.
    for n in atlas["nodes"]:
        if n["type"] in PROVABLE and n["external_refs"]:
            findings.append(
                (
                    "EXTERNAL_HARD_DEP",
                    f"{n['id']} ({n['proof_status']}) cites external: {n['external_refs']}",
                )
            )
        for r in n["dangling_refs"]:
            findings.append(("DANGLING_REF", f"{n['id']} -> \\ref{{{r}}} unresolved"))

    order = [
        "CYCLE", "FWD_DEF", "TARGET_AS_PROVED", "FWD_PROOF", "REMARK_SMUGGLE",
        "PROSE_SMUGGLE", "EXTERNAL_HARD_DEP", "DANGLING_REF", "FWD_TARGET_INFO",
    ]
    findings.sort(key=lambda f: order.index(f[0]))
    for code, msg in findings:
        print(f"[{code}] {msg}")
    print(f"\n{len(findings)} findings.")

    fatal = {"CYCLE", "FWD_DEF", "TARGET_AS_PROVED"}
    return 1 if any(c in fatal for c, _ in findings) else 0


if __name__ == "__main__":
    sys.exit(main())
