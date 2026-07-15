"""Solution 06 — ch06 exercise 1 (predict, then run).

Question: with per-step allowance 0.25 (half of v14's 0.5), how many
legal steps until lambda_min <= 0 in the Gamma(x) = [[1,x],[x,1]] family?

Prediction: 4. lambda_min(Gamma(x)) = 1 - |x| exactly, so marching x by
the full allowance each step gives lambda_min = 1 - 0.25 n, which hits 0
at n = 4. Halving the per-step allowance only doubles the collapse
depth — the v14 failure is not about the step size, it is about the
absence of a cumulative budget.

Run: python book/labs/solutions/sol06.py    (exit 0 iff the prediction holds)
"""

from __future__ import annotations

import sys

import numpy as np

PREDICTED_STEPS = 4
STEP = 0.25
TOL = 1e-12

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def lam_min(x: float) -> float:
    return float(np.linalg.eigvalsh(np.array([[1.0, x], [x, 1.0]])).min())


def main() -> int:
    x, steps = 0.0, 0
    while lam_min(x) > TOL:
        x += STEP  # each step is legal per-step: |delta| = 0.25 <= allowance
        steps += 1
        print(f"  step {steps}: x = {x:.2f}, lambda_min = {lam_min(x):+.4f}")

    expect(
        steps == PREDICTED_STEPS,
        f"prediction: collapse at step {PREDICTED_STEPS} (got {steps})",
    )
    expect(
        abs(lam_min(0.25 * PREDICTED_STEPS)) <= TOL,
        "and the collapse is exact: lambda_min(1.0) = 0",
    )
    expect(
        lam_min(0.25 * (PREDICTED_STEPS - 1)) > 0,
        "one step earlier the channel is still open",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
