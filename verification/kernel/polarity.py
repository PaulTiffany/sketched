"""Formula-polarity classifier (task 5 of the verification plan).

Classes:
  positive             no negation anywhere
  neg_of_positive      exactly ~phi with phi positive
  alternation-k        maximum negation nesting depth k >= 2
  hereditarily_calibrated  (model-relative) every subformula gets the same
                       verdict under ||-_adm and ||-_nn at every condition
"""

from __future__ import annotations


def neg_depth(phi) -> int:
    k = phi[0]
    if k == "atom":
        return 0
    if k == "not":
        return 1 + neg_depth(phi[1])
    return max(neg_depth(phi[1]), neg_depth(phi[2]))


def classify(phi) -> str:
    d = neg_depth(phi)
    if d == 0:
        return "positive"
    if d == 1 and phi[0] == "not":
        return "neg_of_positive"
    if d == 1:
        return "mixed_single_neg"
    return f"alternation-{d}"


def subformulas(phi):
    yield phi
    if phi[0] == "not":
        yield from subformulas(phi[1])
    elif phi[0] in ("and", "or"):
        yield from subformulas(phi[1])
        yield from subformulas(phi[2])


def hereditarily_calibrated(model, J_adm, J_nn, phi, memo_a, memo_n) -> bool:
    return all(
        model.forces(J_adm, p, sub, memo_a) == model.forces(J_nn, p, sub, memo_n)
        for sub in set(subformulas(phi))
        for p in model.poset.elements
    )
