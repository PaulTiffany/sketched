"""Lab 06 — The margin, spent and preserved (companion to book/ch06_the_margin.md).

Part 1 re-runs the numeric margin witness (the v14 collapse and the v15
budgeted path on real interaction matrices). Part 2 is the chapter's
budget-splitting table: the SAME total budget spent in 1, 2, 5, or 50
steps always lands on the same floor — the margin cares about the sum,
not the schedule. That is the entire content of the repair.

Run: python book/labs/lab06_margin.py   (exit 0 iff all checks pass)
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

import numeric_margin  # noqa: E402
from numeric_margin import lam_min  # noqa: E402


def main() -> int:
    print("=" * 72)
    print("Part 1 — the witness (v14 collapse, v15 preservation)")
    print("=" * 72)
    rc = numeric_margin.main()
    if rc != 0:
        return rc

    print()
    print("=" * 72)
    print("Part 2 — the schedule does not matter; the sum does")
    print("=" * 72)
    eta, budget = 1.0, 0.5  # eta/(2 L) with L = 1
    ok = True
    for n in (1, 2, 5, 50):
        xs = np.cumsum([0.0] + [budget / n] * n)
        floor = min(lam_min(float(x)) for x in xs)
        print(f"  budget {budget} spent in {n:>2} step(s): "
              f"final x = {xs[-1]:.3f}, floor lambda_min = {floor:.3f}")
        ok &= abs(floor - (eta - budget)) < 1e-9
    print()
    if not ok:
        print("LAB 06 FAILURE: floor depended on the schedule")
        return 1
    print("Lab 06 OK — same budget, any schedule, same floor eta/2; "
          "and exceeding the budget (Part 1, v14 path) hits the cliff")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
