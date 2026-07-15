"""Solution 03 — ch03 exercise 1 (predict, then run).

Question: add a second J_adm generator, "leave 0" ({00, 01} covers 0).
Does r force b (b = all leaves) under the enlarged topology?

Prediction: NO. Transitivity would need A_b(r) = {00,01,10,11} to be
covered locally at every member of some cover of r. Below 0 the new
generator helps ({00,01} now covers 0 — so 0 itself starts forcing b),
but below 1 nothing changed: the pullback {10,11} is still not a
generated cover of 1, and pullback stability cannot manufacture it.
Buying the root's decision would require spending a generator on BOTH
subtrees.

Run: python book/labs/solutions/sol03.py    (exit 0 iff the prediction holds)
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
    M = Model(P, {"b": set(P.leaves)})
    b = atom("b")

    before = GeneratedTopology(
        P, {"r": [frozenset(set(P.elements) - {"r"})]}, name="J_adm"
    )
    after = GeneratedTopology(
        P,
        {
            "r": [frozenset(set(P.elements) - {"r"})],
            "0": [frozenset({"00", "01"})],
        },
        name="J_adm+leave0",
    )

    expect(not M.forces(before, "0", b), "baseline: 0 does not force b")
    expect(M.forces(after, "0", b), "new generator: 0 now forces b")
    expect(
        not M.forces(after, "1", b),
        "but 1 still does not (nothing was spent on the right subtree)",
    )
    expect(
        not M.forces(after, "r", b),
        "prediction: r still does NOT force b under the enlarged J_adm",
    )
    expect(
        not after.covers("1", frozenset({"10", "11"})),
        "mechanism: {10,11} is still not a generated cover of 1",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
