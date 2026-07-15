"""Lab 02 — Conditions and refinement on the spine model (companion to
book/ch02_conditions_and_refinement.md).

Builds the 7-condition spine poset and verifies every structural fact the
chapter quotes: the order axioms, the down-sets, that filters are exactly
the 7 principal up-sets, that the 4 maximal filters are the branches, and
that persistence ("you never un-know") holds for refinement-closed
valuations and breaks — detectably — for a mutated one.

Run: python book/labs/lab02_conditions.py    (exit 0 iff all chapter facts hold)
"""

from __future__ import annotations

import sys
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

from spine import Model, binary_tree  # noqa: E402

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def all_filters(P):
    """Brute force: nonempty, upward-closed, downward-directed subsets."""
    up = {p: frozenset(q for q in P.elements if P.le(p, q)) for p in P.elements}
    out = []
    elems = sorted(P.elements)
    for mask in range(1, 1 << len(elems)):
        F = frozenset(elems[i] for i in range(len(elems)) if mask >> i & 1)
        if not all(up[p] <= F for p in F):
            continue  # not upward closed
        if all(
            any(P.le(r, p) and P.le(r, q) for r in F)
            for p, q in combinations(F, 2)
        ):
            out.append(F)
    return out


def main() -> int:
    P = binary_tree(2)
    up = {p: frozenset(q for q in P.elements if P.le(p, q)) for p in P.elements}

    print("spine model: conditions r > {0,1} > {00,01,10,11}\n")

    # ---- the order is a partial order (the chapter's 'order axioms') ------
    expect(len(P.elements) == 7, "7 conditions")
    expect(sorted(P.leaves) == ["00", "01", "10", "11"], "4 leaves")
    expect(all(P.le(p, p) for p in P.elements), "reflexive: every condition refines itself")
    expect(
        all(not (P.le(q, p) and P.le(p, q)) or p == q for p in P.elements for q in P.elements),
        "antisymmetric: mutual refinement is identity",
    )
    expect(
        all(
            not (P.le(s, q) and P.le(q, p)) or P.le(s, p)
            for p in P.elements for q in P.elements for s in P.elements
        ),
        "transitive: refinement composes",
    )

    # ---- down-sets the chapter reads off ----------------------------------
    print("\ndown-sets (everything below a condition):")
    for p in P.elements:
        print(f"  down({p:>2}) = {{{', '.join(sorted(P.down[p]))}}}")
    expect(P.down["0"] == frozenset({"0", "00", "01"}), "down(0) = {0, 00, 01}")
    expect(P.down["r"] == frozenset(P.elements), "down(r) = everything: the root commits to nothing")
    expect(
        not P.le("00", "1") and not P.le("1", "00"),
        "00 and 1 are incompatible: no common refinement",
    )

    # ---- filters: coherent courses of commitment --------------------------
    F = all_filters(P)
    print(f"\nfilters found by brute force over all 2^7 subsets: {len(F)}")
    expect(len(F) == 7, "exactly 7 filters")
    expect(
        set(F) == {up[p] for p in P.elements},
        "every filter is principal: up(x) for some condition x",
    )
    branches = P.branches()
    maximal = [G for G in F if not any(G < H for H in F)]
    expect(len(branches) == 4, "4 branches (upward closures of leaves)")
    expect(set(maximal) == set(branches), "maximal filters = branches, exactly")
    expect(
        frozenset({"r", "0"}) in F and frozenset({"r", "1"}) in F,
        "up(0) and up(1): filters that stop early are allowed",
    )
    expect(
        all(not (frozenset({"r", "0", "1"}) <= G) for G in F),
        "no filter contains both 0 and 1: incompatible commitments never cohere",
    )

    # ---- persistence: you never un-know by refining -----------------------
    good = Model(P, {"a": {q for q in P.elements if q.startswith("0")}})
    bad = Model(P, {"a": {"0"}})  # holds at 0, forgotten at 00/01
    expect(good.persistent(), "V(a) = left subtree is refinement-closed: persistent")
    expect(not bad.persistent(), "V(a) = {0} alone is NOT persistent: refinement would un-know a")
    expect(
        good.stab("0", ("atom", "a")) and not bad.stab("0", ("atom", "a")),
        "Stab(0, a) holds exactly when a survives every further refinement",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
