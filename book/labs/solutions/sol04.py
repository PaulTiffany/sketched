"""Solution 04 — ch04 exercise 1 (predict, then run).

Question: add atom c stabilized only at {01}. Which conditions force c
under the dense relation, and which force ~c?

Predicted column (7 conditions):
    c   forced at: 01 only — everywhere else the stability set below
        the condition misses some refinement (e.g. 00 below 0).
    ~c  forced at: 00, 10, 11, 1 — every condition none of whose
        refinements forces c.
    neither: r and 0 — both have a refinement forcing c (01) and a
        refinement forcing ~c (e.g. 00), so they stay undecided.

Run: python book/labs/solutions/sol04.py    (exit 0 iff the prediction holds)
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

from spine import DenseTopology, Model, atom, binary_tree, neg  # noqa: E402

PREDICTED_C = {"01"}
PREDICTED_NOT_C = {"00", "10", "11", "1"}
PREDICTED_UNDECIDED = {"r", "0"}

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def main() -> int:
    P = binary_tree(2)
    M = Model(P, {"c": {"01"}})
    assert M.persistent()
    J_nn = DenseTopology(P)
    c = atom("c")

    forces_c = {p for p in P.elements if M.forces(J_nn, p, c)}
    forces_not_c = {p for p in P.elements if M.forces(J_nn, p, neg(c))}

    print("condition | c | ~c")
    for p in sorted(P.elements, key=len):
        print(f"    {p:>2}    | {'Y' if p in forces_c else '.'} |"
              f" {'Y' if p in forces_not_c else '.'}")
    print()

    expect(forces_c == PREDICTED_C, f"c forced exactly at {sorted(PREDICTED_C)}")
    expect(
        forces_not_c == PREDICTED_NOT_C,
        f"~c forced exactly at {sorted(PREDICTED_NOT_C)}",
    )
    expect(
        set(P.elements) - forces_c - forces_not_c == PREDICTED_UNDECIDED,
        f"undecided exactly at {sorted(PREDICTED_UNDECIDED)}",
    )
    expect(
        not (forces_c & forces_not_c),
        "consistency (lem:pers): nothing forces both",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
