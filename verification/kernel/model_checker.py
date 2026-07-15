"""Finite model checker for the forcing kernel of forcing_correspondence_v15.

The paper defines no toy model; this file supplies one (the "spine model"):
a full binary tree of depth 2 (7 conditions), atoms a, b with
refinement-closed valuations, and a deliberately coarse generator family for
J_adm so that J_adm is strictly below J_nn and the Decision-Reachability
obstruction is visible.

Experiments:
  E1  site bound: J_adm subseteq J_nn, plus a strictness witness
  E2  persistence (lem:pers) for both relations, all formulas
  E3  polarity comparison ||-_adm vs ||-_nn per formula class
  E4  torsion-not vs clause-not countermodel search (calibration item 6)
  E5  deciding sets: order-density (lem:dec) and J_adm-cover failure
      (Decision Reachability), with a bivalence-failure witness
  E6  propositional truth lemma (thm:prop) on every generic branch
  E7  mutations: drop M-Pers (non-persistent valuation); inject a
      non-dense generator (break lem:sitebound)

Exit code 1 if any check that the paper asserts unconditionally fails.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from spine import (  # noqa: E402
    Model,
    DenseTopology,
    GeneratedTopology,
    binary_tree,
    enumerate_formulas,
    neg,
    show,
)
from polarity import classify, hereditarily_calibrated  # noqa: E402

DEPTH = 2
FORMULA_DEPTH = 3


def build():
    P = binary_tree(DEPTH)
    # Refinement-closed valuations: a = left subtree; b = all leaves.
    V = {
        "a": {q for q in P.elements if q.startswith("0")},
        "b": set(P.leaves),
    }
    M = Model(P, V)
    assert M.persistent()
    J_nn = DenseTopology(P)
    # Coarse admissible generators: on the root only, the single dense
    # requirement "leave the void" (everything strictly below r).
    gen = {"r": [frozenset(set(P.elements) - {"r"})]}
    J_adm = GeneratedTopology(P, gen)
    return P, M, J_nn, J_adm


def main() -> int:
    P, M, J_nn, J_adm = build()
    formulas = enumerate_formulas(["a", "b"], FORMULA_DEPTH)
    memo_a, memo_n = {}, {}
    failures = []
    print(f"spine model: binary tree depth {DEPTH} ({len(P.elements)} conditions), "
          f"{len(formulas)} formulas (depth <= {FORMULA_DEPTH})\n")

    # ---- E1: site bound ---------------------------------------------------
    contained = all(
        J_nn.covers(p, S) for p in P.elements for S in J_adm.J[p]
    )
    print(f"E1 site bound (lem:sitebound) J_adm <= J_nn: {'PASS' if contained else 'FAIL'}")
    if not contained:
        failures.append("E1")
    witness = next(
        (
            (p, S)
            for p in P.elements
            for S in P.sieves_on(p)
            if J_nn.covers(p, S) and not J_adm.covers(p, S)
        ),
        None,
    )
    if witness:
        p, S = witness
        print(f"   strictness witness: sieve {sorted(S)} on '{p}' is J_nn-dense "
              f"but not a J_adm-cover  (J_adm strictly below J_nn)")

    # ---- E2: persistence --------------------------------------------------
    for J, memo, label in ((J_adm, memo_a, "adm"), (J_nn, memo_n, "nn")):
        bad = [
            (show(f), p, q)
            for f in formulas
            for p in P.elements
            if M.forces(J, p, f, memo)
            for q in P.down[p]
            if not M.forces(J, q, f, memo)
        ]
        print(f"E2 persistence (lem:pers) for ||-_{label}: "
              f"{'PASS' if not bad else 'FAIL ' + str(bad[:3])}")
        if bad:
            failures.append(f"E2-{label}")

    # ---- E3: polarity comparison ------------------------------------------
    stats = defaultdict(lambda: [0, 0, 0])  # class -> [adm=>nn ok, nn=>adm ok, n]
    examples = {}
    for f in formulas:
        cls = classify(f)
        for p in P.elements:
            fa = M.forces(J_adm, p, f, memo_a)
            fn = M.forces(J_nn, p, f, memo_n)
            s = stats[cls]
            s[2] += 1
            s[0] += (not fa) or fn
            s[1] += (not fn) or fa
            if fa and not fn and cls not in examples:
                examples[cls] = (show(f), p, "adm but not nn")
            if fn and not fa and f[0] == "not" and ("nn_not_adm", cls) not in examples:
                examples[("nn_not_adm", cls)] = (show(f), p, "nn but not adm")
    print("E3 polarity comparison (per class: adm=>nn %, nn=>adm %):")
    pos_ok = True
    for cls in sorted(stats, key=str):
        a2n, n2a, n = stats[cls]
        print(f"   {cls:>18}: adm=>nn {100*a2n//n:3}%   nn=>adm {100*n2a//n:3}%   (n={n})")
        if cls == "positive" and a2n != n:
            pos_ok = False
    print(f"   positive fragment adm=>nn: {'PASS' if pos_ok else 'FAIL'}")
    if not pos_ok:
        failures.append("E3-positive")
    viol = next(
        (
            (show(f), p)
            for f in formulas
            for p in P.elements
            if M.forces(J_adm, p, f, memo_a) and not M.forces(J_nn, p, f, memo_n)
        ),
        None,
    )
    if viol:
        print(f"   adm=>nn VIOLATION (expected only at negation polarity): "
              f"{viol[0]} at '{viol[1]}'")
    hc = sum(
        hereditarily_calibrated(M, J_adm, J_nn, f, memo_a, memo_n) for f in formulas
    )
    print(f"   hereditarily calibrated formulas: {hc}/{len(formulas)} "
          f"(full equivalence holds on all of these by definition)")

    # ---- E4: torsion-not vs clause-not ------------------------------------
    diverge = []
    for f in formulas:
        for p in P.elements:
            clause = not any(M.forces(J_nn, q, f, memo_n) for q in P.down[p])
            torsion = all(M.stab(q, neg(f)) for q in P.down[p])
            if clause != torsion:
                diverge.append((show(f), p, clause, torsion))
    diverge.sort(key=lambda d: (len(d[0]), d[0]))
    print(f"E4 torsion-not vs clause-not (calibration item 6): "
          f"{len(diverge)} divergences"
          + (" -> the two negation semantics are NOT equivalent" if diverge else ""))
    for ex in diverge[:3]:
        f, p, c, t = ex
        print(f"   phi={f:<14} at '{p}': clause-not={c}  torsion(Stab(.,~phi) everywhere)={t}")

    # ---- E5: deciding sets ------------------------------------------------
    dec_dense_ok = True
    reach_witness = None
    bivalence_witness = None
    for f in sorted(formulas, key=lambda g: len(show(g))):
        D = frozenset(
            q
            for q in P.elements
            if M.forces(J_nn, q, f, memo_n) or M.forces(J_nn, q, neg(f), memo_n)
        )
        for p in P.elements:
            Dp = D & P.down[p]
            if not all(P.down[q] & Dp for q in P.down[p]):
                dec_dense_ok = False
        # J_adm-side deciding sets for the reachability check
        Da = frozenset(
            q
            for q in P.elements
            if M.forces(J_adm, q, f, memo_a) or M.forces(J_adm, q, neg(f), memo_a)
        )
        for p in P.elements:
            # sieve generated by Da below p (Da is persistence-closed => sieve)
            Dap = Da & P.down[p]
            if reach_witness is None and not J_adm.covers(p, Dap):
                reach_witness = (show(f), p, sorted(Dap))
            if (
                bivalence_witness is None
                and not M.forces(J_adm, p, f, memo_a)
                and not M.forces(J_adm, p, neg(f), memo_a)
            ):
                bivalence_witness = (show(f), p)
    print(f"E5 deciding sets order-dense for ||-_nn (lem:dec): "
          f"{'PASS' if dec_dense_ok else 'FAIL'}")
    if not dec_dense_ok:
        failures.append("E5-dec")
    if reach_witness:
        f, p, D = reach_witness
        print(f"   Decision Reachability FAILURE for J_adm: D_phi for phi={f} "
              f"at '{p}' = {D} is not a J_adm-cover")
    if bivalence_witness:
        f, p = bivalence_witness
        print(f"   bivalence failure under ||-_adm: '{p}' forces neither {f} nor ~{f}"
              f"  (lem:bivalence needs lem:reach, exactly as the paper says)")

    # ---- E6: truth lemma on generic branches -------------------------------
    for J, memo, label, expect in ((J_nn, memo_n, "nn", True), (J_adm, memo_a, "adm", None)):
        bad = [
            (show(f), sorted(G))
            for G in P.branches()
            for f in formulas
            if M.branch_models(G, f) != any(M.forces(J, p, f, memo) for p in G)
        ]
        verdict = "PASS" if not bad else f"FAIL ({len(bad)} cases, e.g. {bad[0]})"
        print(f"E6 truth lemma (thm:prop) on all branches, ||-_{label}: {verdict}")
        if bad and expect is True:
            failures.append(f"E6-{label}")
        if not bad and label == "adm":
            print("   note: finite trees trivialize genericity (every leaf decides "
                  "every formula), so E6-adm passing does NOT discharge lem:reach; "
                  "the E5 bivalence failure at interior nodes is the real signal")

    # ---- E7: mutations ------------------------------------------------------
    # (a) drop M-Pers: non-refinement-closed valuation.
    Vbad = {"a": {"r"}, "b": set(P.leaves)}
    Mbad = Model(P, Vbad)
    assert not Mbad.persistent()
    memo_bad = {}
    pers_broken = any(
        Mbad.forces(J_nn, p, f, memo_bad)
        and any(not Mbad.forces(J_nn, q, f, memo_bad) for q in P.down[p])
        for f in formulas
        for p in P.elements
    )
    tl_broken = any(
        Mbad.branch_models(G, f) != any(Mbad.forces(J_nn, p, f, memo_bad) for p in G)
        for G in P.branches()
        for f in formulas
    )
    # Expected: clause-level persistence SURVIVES (it is a property of the
    # topology, via pullback stability, independent of the valuation), while
    # the truth lemma breaks. I.e. M-Pers's true blast radius is lem:atomic
    # (=> direction), not lem:pers -- sharper than the paper's ledger note.
    print(f"E7a mutation drop M-Pers: clause persistence broken={pers_broken} "
          f"(expected False), truth lemma broken={tl_broken} (expected True)")
    if pers_broken or not tl_broken:
        failures.append("E7a")
    # (b) inject a non-dense generator: sitebound must fail.
    gen_bad = {"r": [frozenset({"00"})]}
    J_bad = GeneratedTopology(P, gen_bad, name="J_bad")
    sitebound_fails = any(
        not J_nn.covers(p, S) for p in P.elements for S in J_bad.J[p]
    )
    print(f"E7b mutation non-dense generator: J <= J_nn violated={sitebound_fails} "
          f"({'EXPECTED True' if sitebound_fails else 'UNEXPECTED'})")
    if not sitebound_fails:
        failures.append("E7b")
    memo_bad2 = {}
    anomaly = next(
        (
            (show(f), p)
            for f in formulas
            for p in P.elements
            if M.forces(J_bad, p, f, memo_bad2) and not M.forces(J_nn, p, f, memo_n)
        ),
        None,
    )
    if anomaly:
        print(f"   forcing anomaly: {anomaly[0]} forced at '{anomaly[1]}' without "
              f"dense stabilization (admissibility of generators is load-bearing)")

    print(f"\n{'ALL UNCONDITIONAL CHECKS PASS' if not failures else 'FAILURES: ' + str(failures)}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
