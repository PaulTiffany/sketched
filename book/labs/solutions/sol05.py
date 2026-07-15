"""Solution 05 — ch05 exercise 1 (predict, then run).

Question: add atom c stabilized only at leaf 01. For the branch
G = {r, 0, 01}, does G model c, and which member of G forces it?

Prediction: G models c (01 is in G and stabilizes c), and the forcing
witness in the Truth Lemma pattern is 01 itself — r and 0 do not force
c (each has a refinement, e.g. 00, where c fails), so the existential
"some member of G forces c" is carried by the leaf alone.

Run: python book/labs/solutions/sol05.py    (exit 0 iff the prediction holds)
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

from spine import GeneratedTopology, Model, atom, binary_tree  # noqa: E402

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def main() -> int:
    P = binary_tree(2)
    M = Model(P, {"c": {"01"}})
    J_adm = GeneratedTopology(P, {"r": [frozenset(set(P.elements) - {"r"})]})
    c = atom("c")

    G = frozenset({"r", "0", "01"})
    expect(G in set(P.branches()), "G = {r, 0, 01} is a branch of the spine")
    expect(M.branch_models(G, c), "prediction: G models c")

    witnesses = {q for q in G if M.forces(J_adm, q, c)}
    expect(
        witnesses == {"01"},
        f"prediction: the forcing witness in G is 01 alone (got {sorted(witnesses)})",
    )
    expect(
        M.branch_models(G, c)
        == any(M.forces(J_adm, q, c) for q in G),
        "the Truth Lemma pattern (thm:prop) holds for c on G",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
