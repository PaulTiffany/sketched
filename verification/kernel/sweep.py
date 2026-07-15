"""Hypothesis-mutation sweep: the kernel claims across a family of finite
models, under systematic hypothesis deletion.

model_checker.py checks the paper's claims on ONE hand-picked spine model
and mutates two hypotheses (E7). This tool generalizes both directions:

  BASELINE   every kernel claim re-checked on every model in a family of
             posets (chains, forks, trees, diamonds, crowns — tree and
             non-tree) x generator schemes x persistent valuations. A
             baseline violation means the paper asserts something a finite
             model refutes: exit 1.

  MUTATIONS  each hypothesis dropped in turn, every claim re-checked:
               no-pers   valuation not refinement-closed   (M-Pers)
               no-dense  a non-dense generator injected    (admissibility)
               no-pb     topology closure without pullback stability
               no-tr     topology closure without transitivity
             The last two treat the Grothendieck axioms themselves as
             consumable hypotheses, extending the program's 'debts are the
             theorem hypotheses' discipline to the site axioms.

  Verdicts per (claim, mutation):
    NECESSARY   the claim broke in some mutated model (countermodel named):
                the hypothesis is load-bearing for that claim.
    SURVIVES    the claim held in every mutated model swept — a
                GENERALIZATION CANDIDATE: evidence (not proof) that the
                claim does not consume this hypothesis; a conjecture for a
                sharper theorem.

Scope honesty: the paper's two conjectures (conj:exportability-correlates-
with-regime, conj:residue-contract-break) consume the interface/empirical
layer (chi/epsilon instrumentation, displacement-contract measurement) and
are NOT attackable in this vocabulary; attacking them finitely needs a
finite interface model first. What is attackable is above.

Claims checked (paper anchors):
  persistence   lem:pers    p ||- phi and q <= p  =>  q ||- phi
  truth-lemma   thm:prop    branch truth == forced-along-branch, all
                            maximal filters (up-closures of minimal elts)
  site-bound    lem:sitebound  every J-cover is J_nn-dense
  pos-transfer  (E3 half)   positive phi: p ||-_J phi => p ||-_nn phi
  dec-dense     lem:dec     D_phi order-dense below every p (under ||-_nn;
                            responds to valuation mutations only)

Exit 1 only on baseline violations. Mutation breakage is data, not failure.
"""

from __future__ import annotations

import json
import sys
from itertools import combinations
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from spine import (  # noqa: E402
    DenseTopology,
    FinitePoset,
    Model,
    binary_tree,
    enumerate_formulas,
    neg,
    show,
)
from polarity import classify  # noqa: E402

FORMULA_DEPTH = 2
VAL_CAP = 10  # deterministic cap on valuations sampled per (poset, scheme)
OUT = Path(__file__).resolve().parents[1] / "sweep.json"


# ------------------------------------------------------------- model family

def poset_from_covers(elements, covers):
    """FinitePoset from cover pairs (child, parent), child <= parent."""
    down = {p: {p} for p in elements}
    changed = True
    while changed:
        changed = False
        for c, par in covers:
            if not down[c] <= down[par]:
                down[par] |= down[c]
                changed = True
    return FinitePoset(elements, down)


def family():
    """Named finite posets, tree and non-tree. Elements named so minimal
    elements ('leaves') sort last for readable witnesses."""
    F = []
    F.append(("chain3", poset_from_covers(
        ["t", "m", "b"], [("m", "t"), ("b", "m")])))
    F.append(("chain4", poset_from_covers(
        ["t", "m1", "m2", "b"], [("m1", "t"), ("m2", "m1"), ("b", "m2")])))
    F.append(("fork2", poset_from_covers(
        ["r", "x", "y"], [("x", "r"), ("y", "r")])))
    F.append(("fork3", poset_from_covers(
        ["r", "x", "y", "z"], [("x", "r"), ("y", "r"), ("z", "r")])))
    F.append(("tree2", binary_tree(2)))
    F.append(("diamond", poset_from_covers(
        ["r", "a", "b", "m"], [("a", "r"), ("b", "r"), ("m", "a"), ("m", "b")])))
    F.append(("diamond-tail", poset_from_covers(
        ["r", "a", "b", "m", "t"],
        [("a", "r"), ("b", "r"), ("m", "a"), ("m", "b"), ("t", "m")])))
    F.append(("N", poset_from_covers(
        ["p", "q", "x", "y"], [("x", "p"), ("x", "q"), ("y", "q")])))
    F.append(("crown", poset_from_covers(
        ["p", "q", "x", "y"], [("x", "p"), ("x", "q"), ("y", "p"), ("y", "q")])))
    return F


def maximal_elements(P):
    return [p for p in P.elements
            if not any(p in P.down[q] and q != p for q in P.elements)]


# -------------------------------------------------- topologies with axioms

class VariantTopology:
    """Closure of a generator family under a chosen subset of the
    Grothendieck axioms (maximal sieves always seeded). With both rules
    this coincides with spine.GeneratedTopology; dropping a rule yields a
    deliberately defective 'topology' for necessity testing."""

    def __init__(self, poset, generators, pullback=True, transitivity=True, name="J"):
        self.poset = poset
        self.name = name
        J = {p: {poset.down[p]} for p in poset.elements}
        for p, gs in generators.items():
            for S in gs:
                assert all(poset.down[q] <= S for q in S), "generator not a sieve"
                assert S <= poset.down[p], "generator not on its object"
                J[p].add(frozenset(S))
        all_sieves = {p: poset.sieves_on(p) for p in poset.elements}
        changed = True
        while changed:
            changed = False
            if pullback:
                for p in poset.elements:
                    for S in list(J[p]):
                        for q in poset.down[p]:
                            pb = S & poset.down[q]
                            if pb not in J[q]:
                                J[q].add(pb)
                                changed = True
            if transitivity:
                for p in poset.elements:
                    for R in all_sieves[p]:
                        if R in J[p]:
                            continue
                        if any(
                            all(R & poset.down[q] in J[q] for q in S)
                            for S in J[p]
                        ):
                            J[p].add(R)
                            changed = True
        self.J = J

    def covers(self, p, S):
        return frozenset(S) in self.J[p]


# ------------------------------------------------------- generator schemes

def gens_void(P):
    """At each non-minimal maximal element: 'leave the void' (everything
    strictly below). The spine model's coarse scheme, generalized."""
    return {
        p: [frozenset(P.down[p] - {p})]
        for p in maximal_elements(P)
        if len(P.down[p]) > 1
    }


def gens_leaf(P):
    """At every non-minimal element: the sieve of minimal elements below.
    The finest natural dense scheme."""
    return {
        p: [frozenset(m for m in P.leaves if m in P.down[p])]
        for p in P.elements
        if len(P.down[p]) > 1
    }


def gens_nondense(P):
    """MUTATION: a single-minimal generator at a maximal element that has
    >= 2 minimals below it — a sieve, but not dense. None if the poset has
    no such element."""
    for p in maximal_elements(P):
        mins = [m for m in P.leaves if m in P.down[p]]
        if len(mins) >= 2:
            return {p: [frozenset({mins[0]})]}
    return None


def gens_skew(P):
    """At each maximal element with >= 2 strict refinements: the down-set
    of its first child plus all minimals below — dense (contains every
    minimal) but NOT restriction-stable: its pullback to a sibling branch
    is the minimals-only sieve, which no seed supplies there. This is the
    scheme that makes pullback stability earn its keep; 'void' and 'leaf'
    are restriction-stable and self-supply their pullbacks."""
    out = {}
    for p in maximal_elements(P):
        strict = sorted(P.down[p] - {p})
        if len(strict) < 2:
            continue
        child = max(strict, key=lambda q: (len(P.down[q]), q))
        S = frozenset(P.down[child]) | frozenset(
            m for m in P.leaves if m in P.down[p])
        out[p] = [S]
    return out


GEN_SCHEMES = [("void", gens_void), ("leaf", gens_leaf), ("skew", gens_skew)]


# ------------------------------------------------------------- valuations

def spread(items, cap):
    """Deterministic sample: every k-th of the sorted list."""
    items = sorted(items, key=lambda s: (len(s), sorted(s)))
    if len(items) <= cap:
        return items
    step = len(items) / cap
    return [items[int(i * step)] for i in range(cap)]


def downsets(P):
    out = []
    for mask in range(1 << len(P.elements)):
        S = frozenset(
            P.elements[i] for i in range(len(P.elements)) if mask >> i & 1
        )
        if all(P.down[q] <= S for q in S):
            out.append(S)
    return out


def valuations(P, persistent=True, cap=VAL_CAP):
    """Atom 'a' ranges over a spread of (non-)refinement-closed subsets;
    atom 'b' is fixed to the minimal elements (always closed)."""
    closed = set(downsets(P))
    pool = closed if persistent else (
        {frozenset(s) for s in _all_subsets(P)} - closed
    )
    pool = {s for s in pool if s}  # nonempty 'a' keeps the sweep informative
    return [{"a": set(s), "b": set(P.leaves)} for s in spread(pool, cap)]


def _all_subsets(P):
    for mask in range(1 << len(P.elements)):
        yield frozenset(
            P.elements[i] for i in range(len(P.elements)) if mask >> i & 1
        )


# ------------------------------------------------------------ claim battery

CLAIMS = ["persistence", "truth-lemma", "site-bound", "pos-transfer", "dec-dense"]

# Which mutations can even touch a claim (dec-dense is a ||-_nn statement:
# topology and generator mutations cannot reach it).
RESPONDS = {
    "persistence": {"no-pers", "no-dense", "no-pb", "no-tr"},
    "truth-lemma": {"no-pers", "no-dense", "no-pb", "no-tr"},
    "site-bound": {"no-dense", "no-pb", "no-tr"},
    "pos-transfer": {"no-pers", "no-dense", "no-pb", "no-tr"},
    "dec-dense": {"no-pers"},
}


def check_claims(P, M, J, J_nn, formulas):
    """Each claim -> None (holds) or a compact witness string."""
    memo, memo_n = {}, {}
    out = {}

    out["persistence"] = next(
        (f"{show(f)} at {p}!->{q}"
         for f in formulas for p in P.elements
         if M.forces(J, p, f, memo)
         for q in P.down[p] if not M.forces(J, q, f, memo)),
        None,
    )
    out["truth-lemma"] = next(
        (f"{show(f)} on filter({min(G, key=lambda x: len(P.down[x]))})"
         for G in P.branches() for f in formulas
         if M.branch_models(G, f) != any(M.forces(J, p, f, memo) for p in G)),
        None,
    )
    out["site-bound"] = next(
        (f"sieve {sorted(S)} on {p}"
         for p in P.elements for S in getattr(J, "J", {}).get(p, ())
         if not J_nn.covers(p, S)),
        None,
    )
    out["pos-transfer"] = next(
        (f"{show(f)} at {p}"
         for f in formulas if classify(f) == "positive"
         for p in P.elements
         if M.forces(J, p, f, memo) and not M.forces(J_nn, p, f, memo_n)),
        None,
    )
    dec = None
    for f in formulas:
        D = frozenset(
            q for q in P.elements
            if M.forces(J_nn, q, f, memo_n) or M.forces(J_nn, q, neg(f), memo_n)
        )
        for p in P.elements:
            Dp = D & P.down[p]
            if not all(P.down[q] & Dp for q in P.down[p]):
                dec = f"D_{show(f)} not dense below {p}"
                break
        if dec:
            break
    out["dec-dense"] = dec
    return out


def separations(P, M, J, J_nn, formulas):
    """Census data (expected separations, not failures)."""
    memo = {}
    strict = any(
        J_nn.covers(p, S) and not J.covers(p, S)
        for p in P.elements
        for S in P.sieves_on(p)
    )
    bivalent_gaps = sum(
        1
        for f in formulas
        for p in P.elements
        if not M.forces(J, p, f, memo) and not M.forces(J, p, neg(f), memo)
    )
    return strict, bivalent_gaps


# ------------------------------------------------------------------- sweep

def main() -> int:
    formulas = enumerate_formulas(["a", "b"], FORMULA_DEPTH)
    posets = family()
    print(f"model family: {len(posets)} posets x {len(GEN_SCHEMES)} generator "
          f"schemes x <= {VAL_CAP} valuations; {len(formulas)} formulas "
          f"(depth <= {FORMULA_DEPTH})\n")

    baseline_violations = []
    # results[mutation][claim] = {"broken": [witnesses], "checked": n}
    results = {
        m: {c: {"broken": [], "checked": 0} for c in CLAIMS}
        for m in ("baseline", "no-pers", "no-dense", "no-pb", "no-tr")
    }
    census = []

    for pname, P in posets:
        J_nn = DenseTopology(P)
        vals = valuations(P, persistent=True)
        vals_bad = valuations(P, persistent=False)
        nondense = gens_nondense(P)

        for gname, scheme in GEN_SCHEMES:
            gens = scheme(P)
            configs = {
                "baseline": VariantTopology(P, gens, name="J_adm"),
                "no-pb": VariantTopology(P, gens, pullback=False, name="J_nopb"),
                "no-tr": VariantTopology(P, gens, transitivity=False, name="J_notr"),
            }
            if nondense is not None:
                merged = {**gens}
                for k, v in nondense.items():
                    merged[k] = list(merged.get(k, [])) + list(v)
                configs["no-dense"] = VariantTopology(P, merged, name="J_baddense")

            for vi, V in enumerate(vals):
                M = Model(P, V)
                assert M.persistent()
                where = f"{pname}/{gname}/v{vi}"
                for mut in ("baseline", "no-pb", "no-tr", "no-dense"):
                    if mut not in configs:
                        continue
                    res = check_claims(P, M, configs[mut], J_nn, formulas)
                    for c in CLAIMS:
                        if mut != "baseline" and mut not in RESPONDS[c]:
                            continue
                        results[mut][c]["checked"] += 1
                        if res[c] is not None:
                            results[mut][c]["broken"].append(f"{where}: {res[c]}")
                            if mut == "baseline":
                                baseline_violations.append(f"{c} @ {where}: {res[c]}")
                strict, gaps = separations(P, M, configs["baseline"], J_nn, formulas)
                census.append((pname, gname, vi, strict, gaps))

            # no-pers: non-closed valuations against the honest topology
            for vi, V in enumerate(vals_bad):
                M = Model(P, V)
                where = f"{pname}/{gname}/nonpers-v{vi}"
                res = check_claims(P, M, configs["baseline"], J_nn, formulas)
                for c in CLAIMS:
                    if "no-pers" not in RESPONDS[c]:
                        continue
                    results["no-pers"][c]["checked"] += 1
                    if res[c] is not None:
                        results["no-pers"][c]["broken"].append(f"{where}: {res[c]}")

    # ---- baseline report ---------------------------------------------------
    n_base = results["baseline"][CLAIMS[0]]["checked"]
    print(f"BASELINE: {n_base} models, all 5 claims each")
    if baseline_violations:
        for v in baseline_violations[:10]:
            print(f"  [BASELINE_VIOLATION] {v}")
    else:
        print("  all paper-asserted kernel claims hold on every model swept")

    strict_n = sum(1 for *_, s, _ in census if s)
    gap_models = sum(1 for *_, g in census if g)
    by_scheme = {}
    for pname, gname, vi, s, g in census:
        d = by_scheme.setdefault(gname, [0, 0, 0])
        d[0] += 1
        d[1] += s
        d[2] += bool(g)
    print(f"\nSEPARATION CENSUS ({len(census)} configs): "
          f"J_adm strictly below J_nn in {strict_n}; bivalence gaps in {gap_models}")
    for gname, (n, s, g) in sorted(by_scheme.items()):
        print(f"  scheme '{gname}': strict {s}/{n}, bivalence-gapped {g}/{n}")

    # ---- necessity / generalization table ----------------------------------
    print("\nNECESSITY / GENERALIZATION TABLE (claim x dropped hypothesis)")
    header = f"  {'claim':<14}" + "".join(
        f"{m:>12}" for m in ("no-pers", "no-dense", "no-pb", "no-tr"))
    print(header)
    verdicts = {}
    for c in CLAIMS:
        row = f"  {c:<14}"
        for m in ("no-pers", "no-dense", "no-pb", "no-tr"):
            if m not in RESPONDS[c]:
                cell = "n/a"
            else:
                r = results[m][c]
                cell = (f"BREAKS {len(r['broken'])}/{r['checked']}"
                        if r["broken"] else f"holds {r['checked']}/{r['checked']}")
            verdicts[(c, m)] = cell
            row += f"{cell:>12}"
        print(row)

    print("\nNECESSARY (hypothesis load-bearing; first countermodel):")
    for c in CLAIMS:
        for m in ("no-pers", "no-dense", "no-pb", "no-tr"):
            r = results[m][c]
            if m in RESPONDS[c] and r["broken"]:
                print(f"  {c} consumes {m[3:] or m}: e.g. {r['broken'][0]}")

    # Cells that survive for known structural reasons are not evidence and
    # must not inflate the candidates list.
    EXPLAINED = {
        ("truth-lemma", "no-pb"):
            "minimal-carrier: with a persistent valuation, every minimal "
            "element forces exactly its classical truth under ANY topology "
            "containing maximal sieves, and the branch agrees with its "
            "minimal element — so shrinking J cannot break the finite "
            "truth lemma (a mini-lemma, itself worth stating)",
        ("truth-lemma", "no-tr"): "minimal-carrier (as no-pb)",
        ("dec-dense", "no-pers"):
            "vacuous finitely: minimal elements decide every formula under "
            "any valuation, so D_phi is always order-dense in a finite "
            "poset — this cell cannot falsify lem:dec",
        ("pos-transfer", "no-pb"):
            "monotone: dropping a closure rule only shrinks J_adm, which "
            "only makes adm=>nn transfer easier",
        ("pos-transfer", "no-tr"): "monotone (as no-pb)",
        ("site-bound", "no-pb"):
            "density is preserved by each closure rule separately — this "
            "is lem:sitebound's proof decomposed per axiom, confirmation "
            "rather than a new candidate",
        ("site-bound", "no-tr"): "per-axiom density preservation (as no-pb)",
    }

    print("\nGENERALIZATION CANDIDATES (survived every mutated model swept —")
    print("evidence, not proof; each is a conjecture for a sharper theorem):")
    any_cand = False
    for c in CLAIMS:
        for m in ("no-pers", "no-dense", "no-pb", "no-tr"):
            r = results[m][c]
            if m in RESPONDS[c] and r["checked"] and not r["broken"] \
                    and (c, m) not in EXPLAINED:
                any_cand = True
                print(f"  {c} may not consume {m}  ({r['checked']} models)")
    if not any_cand:
        print("  none")

    print("\nEXPLAINED SURVIVALS (structural, not evidence):")
    for (c, m), why in EXPLAINED.items():
        r = results[m][c]
        if m in RESPONDS[c] and r["checked"] and not r["broken"]:
            print(f"  {c} x {m}: {why}")

    print("\nNOT ATTACKABLE HERE: conj:exportability-correlates-with-regime,")
    print("conj:residue-contract-break (interface/empirical layer; a finite")
    print("interface model is the missing instrument).")

    OUT.write_text(json.dumps({
        "formulas": len(formulas),
        "family": [p for p, _ in posets],
        "baseline_models": n_base,
        "baseline_violations": baseline_violations,
        "census": [
            {"poset": p, "scheme": g, "val": v, "strict": s, "bivalence_gaps": b}
            for p, g, v, s, b in census
        ],
        "table": {
            f"{c}|{m}": {"checked": results[m][c]["checked"],
                         "broken": results[m][c]["broken"][:5]}
            for c in CLAIMS
            for m in ("no-pers", "no-dense", "no-pb", "no-tr")
            if m in RESPONDS[c]
        },
    }, indent=2) + "\n", encoding="utf-8")
    print(f"\nwrote {OUT}")

    if baseline_violations:
        print("\nBASELINE VIOLATIONS PRESENT — a paper-asserted claim failed "
              "with all hypotheses intact")
        return 1
    print("\nALL BASELINE CLAIMS HOLD ACROSS THE FAMILY")
    return 0


if __name__ == "__main__":
    sys.exit(main())
