"""Solution 02 — ch02 exercise 1 (predict, then run).

Question: how many filters does the depth-3 binary tree have, and how
many are maximal?

Prediction: on a finite tree every filter is principal (the upward
closure of its minimum), so the depth-3 tree has one filter per element
= 15, and the maximal ones are the branches = one per leaf = 8.

Run: python book/labs/solutions/sol02.py    (exit 0 iff the prediction holds)
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

from spine import binary_tree  # noqa: E402

PREDICTED_FILTERS = 15
PREDICTED_MAXIMAL = 8

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def all_filters(P) -> list[frozenset]:
    """Brute force, same notion as lab02: nonempty, upward-closed,
    downward-directed subsets."""
    elems = sorted(P.elements)
    out = []
    for mask in range(1, 1 << len(elems)):
        F = frozenset(elems[i] for i in range(len(elems)) if mask >> i & 1)
        up_closed = all(
            p in F for q in F for p in elems if P.le(q, p)
        )
        directed = all(
            any(P.le(r, p) and P.le(r, q) for r in F) for p in F for q in F
        )
        if up_closed and directed:
            out.append(F)
    return out


def main() -> int:
    P = binary_tree(3)
    print(f"depth-3 binary tree: {len(P.elements)} conditions, "
          f"{len(P.leaves)} leaves\n")
    filters = all_filters(P)
    maximal = [F for F in filters if not any(F < G for G in filters)]
    ups = {p: frozenset(q for q in P.elements if P.le(p, q)) for p in P.elements}

    expect(
        len(filters) == PREDICTED_FILTERS,
        f"prediction: {PREDICTED_FILTERS} filters (got {len(filters)})",
    )
    expect(
        len(maximal) == PREDICTED_MAXIMAL,
        f"prediction: {PREDICTED_MAXIMAL} maximal filters (got {len(maximal)})",
    )
    expect(
        set(filters) == {ups[p] for p in P.elements},
        "why: every filter is principal (an up-set of its minimum)",
    )
    expect(
        set(maximal) == set(P.branches()),
        "and the maximal ones are exactly the branches",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
