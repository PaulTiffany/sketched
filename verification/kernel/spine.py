"""Finite forcing kernel: posets, sieves, dense and generated topologies,
recursive Kripke-Joyal forcing per the clauses of forcing_correspondence_v15.

Conventions (matching the paper):
  - q <= p means q refines p ("stronger"); refinement descends.
  - A sieve on p is a refinement-closed subset of down(p).
  - J_nn: S covers p iff S is dense below p (every q <= p has r <= q in S).
  - J_adm: least Grothendieck topology containing a designated generator
    family (the finite stand-in for the admissible dense requirements).
  - Forcing clauses (paper section 8):
      p ||- atom       iff  {q <= p : Stab(q, atom)} in J(p)
      p ||- phi & psi  iff  p ||- phi and p ||- psi
      p ||- phi | psi  iff  {q <= p : q ||- phi or q ||- psi} in J(p)
      p ||- ~phi       iff  no q <= p has q ||- phi
"""

from __future__ import annotations

from itertools import combinations


# ---------------------------------------------------------------- formulas

def atom(name):
    return ("atom", name)


def conj(a, b):
    return ("and", a, b)


def disj(a, b):
    return ("or", a, b)


def neg(a):
    return ("not", a)


def show(phi) -> str:
    k = phi[0]
    if k == "atom":
        return phi[1]
    if k == "not":
        return f"~{show(phi[1])}"
    op = " & " if k == "and" else " | "
    return f"({show(phi[1])}{op}{show(phi[2])})"


def enumerate_formulas(atoms, depth):
    """All formulas over `atoms` with connective-nesting depth <= depth,
    deduplicated structurally (commutative binary ops canonicalized)."""
    layers = [{("atom", a) for a in atoms}]
    for _ in range(depth):
        prev = set().union(*layers)
        new = {("not", f) for f in prev}
        for f, g in combinations(sorted(prev), 2):
            new.add(("and", f, g))
            new.add(("or", f, g))
        for f in prev:
            new.add(("and", f, f))
        layers.append(new - set().union(*layers))
    return sorted(set().union(*layers))


# ------------------------------------------------------------------ posets

class FinitePoset:
    """Finite poset given by a reflexive down-set map."""

    def __init__(self, elements, down):
        self.elements = list(elements)
        self.down = {p: frozenset(down[p]) for p in elements}  # {q : q <= p}
        self.leaves = [p for p in elements if self.down[p] == frozenset([p])]

    def le(self, q, p):
        return q in self.down[p]

    def sieves_on(self, p):
        """All refinement-closed subsets of down(p)."""
        dom = sorted(self.down[p])
        out = []
        for mask in range(1 << len(dom)):
            S = frozenset(dom[i] for i in range(len(dom)) if mask >> i & 1)
            if all(self.down[q] <= S for q in S):
                out.append(S)
        return out

    def branches(self):
        """Maximal filters: for tree posets, root-to-leaf chains (upward
        closure of a leaf). These are the finite stand-ins for generics."""
        ups = {p: frozenset(q for q in self.elements if self.le(p, q)) for p in self.elements}
        return [ups[leaf] for leaf in self.leaves]


def binary_tree(depth):
    """Full binary tree; root 'r', children by appending '0'/'1'.
    q <= p iff q is a descendant-or-self of p (q startswith p, with 'r'
    as the empty address)."""
    names = ["r"]
    frontier = [""]
    for _ in range(depth):
        frontier = [w + c for w in frontier for c in "01"]
        names += frontier
    def addr(n):
        return "" if n == "r" else n
    down = {
        p: {q for q in names if addr(q).startswith(addr(p))}
        for p in names
    }
    return FinitePoset(names, down)


# -------------------------------------------------------------- topologies

class DenseTopology:
    """J_nn: covers are exactly the dense sieves."""

    name = "J_nn"

    def __init__(self, poset):
        self.poset = poset

    def covers(self, p, S):
        return all(self.poset.down[q] & S for q in self.poset.down[p])


class GeneratedTopology:
    """Least Grothendieck topology containing `generators`
    (dict: element -> iterable of sieves on it). Computed by fixpoint over
    the finite sieve lattice: maximal sieves + pullback stability +
    transitivity (which also yields supersieve monotonicity)."""

    def __init__(self, poset, generators, name="J_adm"):
        self.poset = poset
        self.name = name
        J = {p: {poset.down[p]} for p in poset.elements}  # maximal sieves
        for p, gs in generators.items():
            for S in gs:
                assert all(poset.down[q] <= S for q in S), "generator not a sieve"
                assert S <= poset.down[p], "generator not on its object"
                J[p].add(frozenset(S))
        all_sieves = {p: poset.sieves_on(p) for p in poset.elements}
        changed = True
        while changed:
            changed = False
            # pullback stability
            for p in poset.elements:
                for S in list(J[p]):
                    for q in poset.down[p]:
                        pb = S & poset.down[q]
                        if pb not in J[q]:
                            J[q].add(pb)
                            changed = True
            # transitivity / local character
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


# ----------------------------------------------------------------- forcing

class Model:
    """A finite site with an atomic valuation.

    valuation: atom name -> set of elements (must be refinement-closed for
    M-Pers to hold; pass a non-closed set to mutation-test persistence).
    """

    def __init__(self, poset, valuation):
        self.poset = poset
        self.V = {a: frozenset(s) for a, s in valuation.items()}

    def persistent(self):
        return all(
            all(self.poset.down[q] <= S for q in S) for S in self.V.values()
        )

    # classical node-level satisfaction ("phi holds at q") -----------------
    def holds(self, q, phi):
        k = phi[0]
        if k == "atom":
            return q in self.V[phi[1]]
        if k == "and":
            return self.holds(q, phi[1]) and self.holds(q, phi[2])
        if k == "or":
            return self.holds(q, phi[1]) or self.holds(q, phi[2])
        return not self.holds(q, phi[1])

    # Stab(q, phi): "phi holds at q and persists under refinement" ---------
    def stab(self, q, phi):
        return all(self.holds(r, phi) for r in self.poset.down[q])

    # Kripke-Joyal forcing over a topology J -------------------------------
    def forces(self, J, p, phi, memo=None):
        if memo is None:
            memo = {}
        key = (id(J), p, phi)
        if key in memo:
            return memo[key]
        k = phi[0]
        down = self.poset.down[p]
        if k == "atom":
            S = frozenset(q for q in down if q in self.V[phi[1]])
            out = J.covers(p, S)
        elif k == "and":
            out = self.forces(J, p, phi[1], memo) and self.forces(J, p, phi[2], memo)
        elif k == "or":
            S = frozenset(
                q
                for q in down
                if self.forces(J, q, phi[1], memo) or self.forces(J, q, phi[2], memo)
            )
            out = J.covers(p, S)
        else:  # not
            out = not any(self.forces(J, q, phi[1], memo) for q in down)
        memo[key] = out
        return out

    # truth on a generic branch (classical, per thm:prop bivalence) --------
    def branch_models(self, G, phi):
        k = phi[0]
        if k == "atom":
            return any(q in self.V[phi[1]] for q in G)
        if k == "and":
            return self.branch_models(G, phi[1]) and self.branch_models(G, phi[2])
        if k == "or":
            return self.branch_models(G, phi[1]) or self.branch_models(G, phi[2])
        return not self.branch_models(G, phi[1])
