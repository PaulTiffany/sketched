"""Solution appb — Appendix B exercise 1 (predict, then run).

Question: E7 drops (M-Pers) by giving atom `a` a non-refinement-closed
valuation (true only at the root `r`). Before running the checker,
predict which earlier experiment's property must now break, and at
which kind of condition (root, interior, leaf) the counterexample sits.

The tempting wrong prediction: "persistence breaks" (lem:pers). It does
not — persistence is a property of the TOPOLOGY (pullback stability),
independent of whether the valuation itself is refinement-closed, so
forcing stays downward-persistent no matter how broken V is.

What actually breaks is the Truth Lemma (lem:atomic's => direction):
branch_models reads raw set membership over the WHOLE branch and sees
`r` (the only member of V[a]) is present, so it says the branch models
`a`. But `forces` requires a locally DENSE membership set below every
condition, and V[a] = {r} is dense nowhere — not even below r itself
(down("0") never meets {r}). So forcing fails at the root, every
interior condition, AND the leaf: there is no single "counterexample
condition" narrower than the whole branch. The break is total, not
localized -- M-Pers's real blast radius is lem:atomic, sharper than the
paper's ledger note.

Run: python book/labs/solutions/solappb.py    (exit 0 iff the prediction holds)
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "verification" / "kernel"))

from spine import DenseTopology, Model, atom, binary_tree, enumerate_formulas  # noqa: E402

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def main() -> int:
    P = binary_tree(2)
    Vbad = {"a": {"r"}, "b": set(P.leaves)}
    M = Model(P, Vbad)
    assert not M.persistent(), "the valuation must actually be non-refinement-closed"

    J_nn = DenseTopology(P)
    formulas = enumerate_formulas(["a", "b"], depth=2)

    pers_broken = any(
        M.forces(J_nn, p, f) and any(not M.forces(J_nn, q, f) for q in P.down[p])
        for f in formulas
        for p in P.elements
    )
    expect(not pers_broken, "prediction: clause persistence (lem:pers) SURVIVES")

    a = atom("a")
    tl_broken_branches = [
        G for G in P.branches() if M.branch_models(G, a) != any(M.forces(J_nn, p, a) for p in G)
    ]
    expect(
        len(tl_broken_branches) == len(P.branches()),
        f"prediction: the Truth Lemma breaks on EVERY branch "
        f"({len(tl_broken_branches)}/{len(P.branches())})",
    )

    witness = tl_broken_branches[0]
    expect(M.branch_models(witness, a), "branch_models says the branch models a (r is a member)")
    forces_here = {p: M.forces(J_nn, p, a) for p in witness}
    expect(
        not any(forces_here.values()),
        f"prediction: forces(a) is False at EVERY condition in the branch {forces_here} "
        "-- root, interior, and leaf alike; there is no single narrower counterexample "
        "condition than the whole branch",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
