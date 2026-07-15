"""Numeric witness for the Channel-Margin analysis (lem:margin, v15).

The Lean countermodel (ForcingKernel/Margin.lean) refutes the v14 per-step
induction over abstract drift sequences. This script realizes the same
failure in actual interaction matrices, with genuine eigenvalues and the
genuine Weyl/Lipschitz constants, and verifies the v15 path-budget repair
numerically.

Family: Gamma(x) = [[1, x], [x, 1]] along a scalar admissible path x_t.
  * lambda_min(Gamma(x)) = 1 - |x|                (exact)
  * ||Gamma(x) - Gamma(y)||_2 = |x - y|           (so L_Gamma = 1)
Anchor x = 0: lambda_min = 1 = eta. The v14 per-step bound allows steps of
size eta/(2 L) = 1/2; two such steps drive lambda_min to 0 — the channel
collapses at depth 2 while every individual step is v14-legal. The v15
budget (total displacement <= eta/(2L)) keeps lambda_min >= eta/2 forever.

Run: python verification/kernel/numeric_margin.py   (exit 0 iff all checks pass)
"""

from __future__ import annotations

import sys

import numpy as np


def gamma(x: float) -> np.ndarray:
    return np.array([[1.0, x], [x, 1.0]])


def lam_min(x: float) -> float:
    return float(np.linalg.eigvalsh(gamma(x)).min())


def spec_norm_diff(x: float, y: float) -> float:
    return float(np.linalg.norm(gamma(x) - gamma(y), ord=2))


def main() -> int:
    eta = 1.0
    L = 1.0
    step_bound = eta / (2 * L)  # v14's per-step allowance
    ok = True

    # sanity: the family's constants are what the analysis says
    for x, y in [(0.0, 0.3), (0.2, 0.5), (-0.1, 0.4)]:
        assert abs(spec_norm_diff(x, y) - abs(x - y)) < 1e-12
        assert abs(lam_min(x) - (1 - abs(x))) < 1e-12

    print(f"family Gamma(x)=[[1,x],[x,1]], anchor x=0: eta={eta}, L_Gamma={L}, "
          f"v14 per-step allowance eta/(2L)={step_bound}\n")

    # v14 path: every step legal per-step; margin collapses at depth 2
    path14 = [0.0, 0.5, 1.0]
    print("v14 per-step-legal path (steps of exactly eta/(2L)):")
    for i, x in enumerate(path14):
        step = "" if i == 0 else f"  step={abs(x - path14[i-1]):.2f} <= {step_bound}"
        print(f"  depth {i}: x={x:+.2f}  lambda_min={lam_min(x):+.3f}{step}")
    collapse = lam_min(path14[-1])
    if collapse < eta / 2:
        print(f"  -> margin {collapse:.3f} < eta/2 = {eta/2}: v14 induction "
              f"FAILS on real matrices (matches Lean countermodel)\n")
    else:
        print("  UNEXPECTED: margin survived\n")
        ok = False

    # v15 path: many steps, cumulative budget respected; margin holds
    n = 50
    path15 = np.cumsum([0.0] + [step_bound / n] * n)  # total = eta/(2L)
    lams = [lam_min(float(x)) for x in path15]
    print(f"v15 budgeted path ({n} steps, total displacement = eta/(2L)):")
    print(f"  min lambda_min along path = {min(lams):.3f} "
          f"(bound eta/2 = {eta/2})")
    if min(lams) >= eta / 2 - 1e-9:
        print("  -> margin >= eta/2 at every depth: path form HOLDS "
              "(matches margin_path_form)")
    else:
        print("  UNEXPECTED: budgeted path lost the margin")
        ok = False

    print(f"\n{'ALL NUMERIC CHECKS PASS' if ok else 'FAILURES PRESENT'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
