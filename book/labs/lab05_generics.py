"""Lab 05 — Generics and truth on the spine model (companion to
book/ch05_generics_and_truth.md).

The spine's four branches are the finite stand-ins for generics. This lab
checks, computationally, the two things a 7-condition model CAN show:

  (1) the Atomic/Propositional Truth Lemma pattern
      G |= phi  iff  exists q in G with q ||-_adm phi
      holds for every branch G and every formula in a small enumerated set;
  (2) bivalence on each branch: exactly one of phi, ~phi is modeled by G,
      for every formula tested (never both, never neither).

It also prints, and asserts, the thing the chapter insists you notice:
that a branch decides everything is a triviality of *finiteness with a
total leaf valuation*, not a witness to Rasiowa-Sikorski doing real work.
Contrast is drawn against the root r, which (per ch04) remains genuinely
undecided under the admissible reading for some formulas even though
every branch through it decides them.

Run: python book/labs/lab05_generics.py    (exit 0 iff all chapter facts hold)
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

from spine import (  # noqa: E402
    GeneratedTopology,
    Model,
    atom,
    binary_tree,
    conj,
    disj,
    neg,
    show,
)

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def main() -> int:
    P = binary_tree(2)
    V = {
        "a": {q for q in P.elements if q.startswith("0")},
        "b": set(P.leaves),
    }
    M = Model(P, V)
    J_adm = GeneratedTopology(P, {"r": [frozenset(set(P.elements) - {"r"})]})
    branches = P.branches()

    a, b = atom("a"), atom("b")
    formulas = [a, b, neg(a), neg(b), neg(neg(b)), conj(a, b), disj(a, b)]

    print("4 branches (finite generics):")
    for G in branches:
        print(f"  {sorted(G)}")

    # ---- (1) Truth Lemma pattern: G |= phi iff exists q in G, q ||-_adm phi
    print("\nchecking G |= phi  <=>  exists q in G with q ||-_adm phi, for")
    print(f"{len(formulas)} formulas across {len(branches)} branches:")
    mismatches = 0
    for G in branches:
        for phi in formulas:
            classical = M.branch_models(G, phi)
            forced_by_some = any(M.forces(J_adm, q, phi) for q in G)
            ok = classical == forced_by_some
            mismatches += not ok
            tag = "ok  " if ok else "FAIL"
            print(f"  [{tag}] {sorted(G)}: {show(phi):>10}  classical={classical!s:5} exists-forces={forced_by_some!s:5}")
    expect(mismatches == 0, "Truth Lemma pattern holds for every (branch, formula) pair tested")

    # ---- (2) bivalence on each branch: exactly one of phi, ~phi holds ------
    biv_fail = 0
    atomics = [a, b]
    for G in branches:
        for phi in atomics:
            yes = M.branch_models(G, phi)
            no = M.branch_models(G, neg(phi))
            if yes == no:  # both or neither: not bivalent
                biv_fail += 1
    expect(biv_fail == 0, "bivalence: every branch decides a and b, never both ways and never neither")

    # ---- the honesty check: r itself remains undecided under ||-_adm -------
    r_decides_b = M.forces(J_adm, "r", b) or M.forces(J_adm, "r", neg(b))
    expect(
        not r_decides_b,
        "r itself does NOT decide b under ||-_adm, even though every branch through r does",
    )
    print(
        "\n  r undecided on b (adm) while every branch through r decides b:"
        " this is the whole content -- descending along an admissible chain"
        " is what buys the decision; the endpoint (a branch) always has it"
        " for free on a finite total model, which is exactly the triviality"
        " this chapter warns about."
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
