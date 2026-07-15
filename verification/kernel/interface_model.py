"""Finite interface model: the Hilbert--Banach bridge and the exportability
conjecture, in finite miniature.

Sources are the VERBATIM statements of Principia Symbolica Book 7 (read from
C:/src/principia/bib/principia_atlas.json, never the PDF) and the forcing
paper's interface layer. Statement identity is enforced by bindings.json
(dual-source: forcing atlas + principia atlas).

Experiments (paper anchors in brackets):

  I1  budget-limited minimizer uniqueness
      [lemma:bk7_budgetlimited_minimizer, theorem:bk7_emergent_lp_norm]
      Unique minimizer of the p-cost for p > 1 (strict convexity), with an
      explicit NON-uniqueness witness at p = 1 (the median tie) — the
      theorem's open interval (1, infinity) is load-bearing at its edge.

  I2  interpolated continuity  [theorem:bk7_hilbert_banach_bridge (i)]
      Lyapunov interpolation ||f||_{p_theta} <= ||f||_{p0}^{1-theta}
      ||f||_{p1}^theta on finite measure vectors, plus norm-continuity of
      p -> ||f||_p along the sweep.

  I3  phase shift only at threshold
      [theorem:bk7_hilbert_banach_bridge (iii),
       corollary:bk7_bridge_no_interior_transition]
      Symmetric double-site cost F_kappa(r) = |r-1|^p + |r+1|^p - kappa r^2
      has exact critical coupling kappa*(p) = p(p-1): minimizer unique below,
      bifurcates (ceases to be unique — the theorem's own phrase) at
      threshold. Swept along p(xi): below-threshold sub-sweeps show NO
      interior transition; a kappa crossing kappa*(p(xi)) bifurcates at the
      predicted xi and nowhere else.

  I4  contextuality defect zero only at the Hilbert cross-section
      [definition:bk7_contextuality_defect,
       lemma:bk7_noncontextuality_forces_hilbert]
      Frame-mass of a projector: sum_i |<f_i, psi>|^p over adapted
      orthonormal frames of a 2D subspace of R^3, rotated within the
      subspace. Frame-independent iff p = 2 (Parseval); the defect
      Phi_nc(p) is measured on a rotation grid.

  I5  exportability x regime  [conj:exportability-correlates-with-regime;
      prop:chi orthogonal case, chi^2 + eps^2 = 1]
      DATA, not pass/fail (the conjecture is status C). Trajectories in the
      margin landscape Gamma(x) = [[1,x1],[x1,1]] (lambda_min = 1 - |x1|;
      contract: smooth iff margin >= eta/2 throughout, i.e. max|x1| <= 1/2).
      Canonical channel = the margin-neutral direction e2 (the floor-stable
      residue direction, per the forcing paper's interface layer); chi =
      aligned displacement fraction, eps = sqrt(1 - chi^2). Reports the
      regime/exportability correlation and the counterexample census.

  I6  frame-temperature composite (consistency realization)
      [definition:bk7_frame_temperature_quotient,
       lemma:bk7_frame_temperature_exponent_correspondence]
      With canonical T_F(eps) = 1/eps and the consistency family
      p(xi) = 1 + 1/xi: xi strictly increasing in horizon, p strictly
      decreasing, limits p -> infinity (xi -> 0+) and p -> 1
      (xi -> infinity), unique xi* = 1 with p(xi*) = 2. This REALIZES the
      lemma's interface (a toy model, as spine.py is for the kernel); the
      derivation of p from first principles is the manuscript's.

Exit 1 if any proven-statement realization (I1-I4, I6) fails; I5 is data.
"""

from __future__ import annotations

import math
import sys

# ------------------------------------------------------------ I6 interface

T_RHO = 1.0  # symbolic temperature of the perceived state (fixed)


def t_frame(eps: float) -> float:
    """Canonical frame-resolution temperature: continuous, strictly
    decreasing, to infinity at 0+, to 0 at infinity."""
    return 1.0 / eps


def xi_of(eps: float) -> float:
    return T_RHO / t_frame(eps)


def p_of_xi(xi: float) -> float:
    """Consistency family for the frame-temperature/exponent correspondence:
    continuous, strictly decreasing, p(1) = 2, limits infinity / 1."""
    return 1.0 + 1.0 / xi


# ------------------------------------------------------------------ helpers

def pnorm(v, w, p):
    return sum(wi * abs(x) ** p for x, wi in zip(v, w)) ** (1.0 / p)


def grid_argmin(f, lo, hi, n):
    """Global minimizer clusters of f on a grid: (min value, cluster reps)."""
    xs = [lo + (hi - lo) * i / n for i in range(n + 1)]
    vals = [f(x) for x in xs]
    m = min(vals)
    winners = [x for x, v in zip(xs, vals) if v - m <= 1e-9 * max(1.0, abs(m))]
    clusters = []
    gap = 2.5 * (hi - lo) / n
    for x in winners:
        if not clusters or x - clusters[-1][-1] > gap:
            clusters.append([x])
        else:
            clusters[-1].append(x)
    reps = [c[len(c) // 2] for c in clusters]
    return m, reps


# --------------------------------------------------------------------- I1

def i1_budget_minimizer():
    data = [(-1.0, 1.0), (1.0, 1.0)]  # sites, weights: the median tie
    fails = []
    for p in (1.2, 1.5, 2.0, 3.0):
        _, reps = grid_argmin(
            lambda r: sum(w * abs(x - r) ** p for x, w in data), -2, 2, 8000)
        if len(reps) != 1:
            fails.append(f"p={p}: {len(reps)} minimizer clusters (expected 1)")
    _, reps1 = grid_argmin(
        lambda r: sum(w * abs(x - r) for x, w in data), -2, 2, 8000)
    tie = len(reps1) == 1 and False or len(reps1)  # cluster count at p=1
    # at p=1 every r in [-1,1] is optimal: one wide cluster; detect width
    xs = [x for x in [-1 + i / 100 for i in range(201)]]
    f1 = lambda r: sum(w * abs(x - r) for x, w in data)  # noqa: E731
    flat = all(abs(f1(x) - 2.0) < 1e-12 for x in xs)
    ok = not fails and flat
    print(f"I1 budget-limited minimizer: unique for p>1 "
          f"{'PASS' if not fails else 'FAIL ' + str(fails)}; "
          f"p=1 non-uniqueness witness (flat optimum on [-1,1]): "
          f"{'PASS' if flat else 'FAIL'}")
    return ok


# --------------------------------------------------------------------- I2

def i2_interpolation():
    vecs = [
        ([3.0, -1.0, 0.5, 2.0, -0.25], [0.2, 0.2, 0.2, 0.2, 0.2]),
        ([1.0, 1.0, 1.0, 0.0, 0.0], [0.5, 0.25, 0.125, 0.0625, 0.0625]),
        ([10.0, 0.1, 0.01, 5.0, 1.0], [0.1, 0.3, 0.3, 0.2, 0.1]),
    ]
    bad = None
    for f, w in vecs:
        for p0, p1 in ((1.0, 2.0), (1.3, 3.0), (2.0, 6.0)):
            for k in range(1, 10):
                th = k / 10.0
                pt = 1.0 / ((1 - th) / p0 + th / p1)
                lhs = pnorm(f, w, pt)
                rhs = pnorm(f, w, p0) ** (1 - th) * pnorm(f, w, p1) ** th
                if lhs > rhs * (1 + 1e-12):
                    bad = (f, p0, p1, th, lhs, rhs)
    # continuity of p -> ||f||_p along a fine sweep
    jump = 0.0
    f, w = vecs[0]
    prev = None
    for i in range(1, 401):
        p = 1.0 + i / 100.0
        v = pnorm(f, w, p)
        if prev is not None:
            jump = max(jump, abs(v - prev))
        prev = v
    ok = bad is None and jump < 0.05
    print(f"I2 interpolated continuity: Lyapunov inequality "
          f"{'PASS' if bad is None else 'FAIL ' + str(bad[:4])}; "
          f"max norm step along sweep {jump:.4f} (fine grid) "
          f"{'PASS' if jump < 0.05 else 'FAIL'}")
    return ok


# --------------------------------------------------------------------- I3

def kappa_star(p: float) -> float:
    """Exact critical coupling of F_kappa(r) = |r-1|^p + |r+1|^p - kappa r^2:
    local convexity at the symmetric point is lost when
    F''(0) = 2 p (p-1) - 2 kappa = 0."""
    return p * (p - 1.0)


def minimizer_count(p: float, kappa: float) -> int:
    _, reps = grid_argmin(
        lambda r: abs(r - 1) ** p + abs(r + 1) ** p - kappa * r * r,
        -3, 3, 12000)
    return len(reps)


def i3_threshold():
    # Cold-side sweep: xi in [1/3, 1] -> p = 1 + 1/xi in [2, 4].
    xis = [1.0 / 3.0 + i * (2.0 / 3.0) / 40 for i in range(41)]
    ps = [p_of_xi(x) for x in xis]

    # (a) kappa below every kappa*(p) on the sweep: no interior transition.
    k_low = 1.5  # min kappa* on sweep = kappa*(2) = 2
    counts_low = [minimizer_count(p, k_low) for p in ps]
    no_interior = all(c == 1 for c in counts_low)

    # (b) kappa crossing the threshold mid-sweep: bifurcation exactly at the
    # predicted xi_c where kappa*(p(xi)) = kappa, i.e. p(p-1) = kappa.
    k_hi = 4.0
    p_c = (1 + math.sqrt(1 + 4 * k_hi)) / 2  # p(p-1) = k_hi
    xi_c = 1.0 / (p_c - 1.0)
    counts_hi = [minimizer_count(p, k_hi) for p in ps]
    # sweep runs cold->hot (p decreasing): unique while kappa < kappa*(p),
    # bifurcated once kappa >= kappa*(p)  (hot side)
    flips = [i for i in range(1, len(ps)) if counts_hi[i] != counts_hi[i - 1]]
    single_flip = len(flips) == 1
    observed_xi = xis[flips[0]] if single_flip else None
    step = xis[1] - xis[0]
    at_predicted = single_flip and abs(observed_xi - xi_c) <= 1.5 * step
    ok = no_interior and single_flip and at_predicted
    print(f"I3 phase shift only at threshold: below kappa* no interior "
          f"transition {'PASS' if no_interior else 'FAIL'} "
          f"(41 sweep points, kappa={k_low});")
    print(f"   crossing kappa={k_hi}: minimizer ceases to be unique at "
          f"xi={observed_xi:.3f} vs predicted xi_c={xi_c:.3f} "
          f"(kappa*(p)=p(p-1)) — {'PASS' if at_predicted else 'FAIL'}; "
          f"single flip {'PASS' if single_flip else 'FAIL ' + str(flips)}")
    return ok


# --------------------------------------------------------------------- I4

def i4_contextuality_defect():
    # psi in R^3 (unnormalized is fine; masses are compared, not calibrated)
    psi = (0.6, 0.7, 0.39)
    # projector Pi = span{u, v}
    u0, v0 = (1.0, 0.0, 0.0), (0.0, 1.0, 0.0)

    def mass(p, alpha):
        c, s = math.cos(alpha), math.sin(alpha)
        u = tuple(c * a + s * b for a, b in zip(u0, v0))
        v = tuple(-s * a + c * b for a, b in zip(u0, v0))
        iu = sum(x * y for x, y in zip(u, psi))
        iv = sum(x * y for x, y in zip(v, psi))
        return abs(iu) ** p + abs(iv) ** p

    def defect(p):
        vals = [mass(p, math.pi * k / 180) for k in range(0, 181, 3)]
        return max(vals) - min(vals)

    d2 = defect(2.0)
    off = {p: defect(p) for p in (1.0, 1.5, 2.5, 3.0)}
    ok = d2 < 1e-12 and all(v > 1e-3 for v in off.values())
    pretty = ", ".join(f"p={p}: {v:.4f}" for p, v in off.items())
    print(f"I4 contextuality defect: Phi_nc(2) = {d2:.2e} (frame-free, "
          f"Parseval) {'PASS' if d2 < 1e-12 else 'FAIL'}; off cross-section "
          f"{pretty} — nonzero {'PASS' if all(v > 1e-3 for v in off.values()) else 'FAIL'}")
    return ok


# --------------------------------------------------------------------- I5

def i5_exportability_regime():
    eta, big_l = 1.0, 1.0
    budget = eta / (2 * big_l)  # 0.5 — the smooth-regime bound on |x1|
    rows = []
    for di in range(1, 9):
        d = 0.25 * di  # total displacement 0.25 .. 2.0
        for k in range(0, 91, 5):
            th = math.radians(k)
            max_x1 = d * math.cos(th)
            smooth = max_x1 <= budget + 1e-12
            chi = math.sin(th)  # aligned with the floor-stable channel e2
            eps = math.cos(th)  # chi^2 + eps^2 = 1 (prop:chi orthogonal case)
            rows.append((d, th, smooth, chi, eps))

    n = len(rows)
    xs = [1.0 if r[2] else 0.0 for r in rows]
    ys = [r[3] for r in rows]
    mx, my = sum(xs) / n, sum(ys) / n
    cov = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    vx = math.sqrt(sum((x - mx) ** 2 for x in xs))
    vy = math.sqrt(sum((y - my) ** 2 for y in ys))
    corr = cov / (vx * vy)

    # counterexample census
    smooth_low_chi = [r for r in rows if r[2] and r[3] < 0.5]
    pivot_high_chi = [r for r in rows if not r[2] and r[3] >= 0.5]
    small = [r for r in smooth_low_chi if r[0] <= budget]
    large = [r for r in smooth_low_chi if r[0] > budget]

    print(f"I5 exportability x regime (DATA — conjecture status C): "
          f"{n} trajectories,")
    print(f"   corr(smooth, chi) = {corr:.3f}")
    print(f"   counterexamples: smooth-but-low-chi {len(smooth_low_chi)} "
          f"(of which {len(small)} have displacement <= budget — short paths "
          f"are smooth in ANY direction), pivot-but-high-chi {len(pivot_high_chi)}")
    if large:
        d, th, *_ = large[0]
        print(f"   nontrivial counterexample: d={d}, theta={math.degrees(th):.0f}deg "
              f"— smooth yet chi<0.5")
    if pivot_high_chi:
        d, th, *_ = max(pivot_high_chi, key=lambda r: r[3])
        print(f"   pivot-but-exportable witness: d={d}, "
              f"theta={math.degrees(th):.0f}deg, chi={math.sin(th):.3f} — long "
              f"mostly-aligned paths still burn the margin")
    print("   finite verdict: BOTH conjecture directions carry a "
          "displacement-scale caveat — short paths are smooth in any "
          "direction (smooth !=> high chi), and long aligned paths can "
          "still cross the break (high chi !=> smooth). Correlation is "
          "carried by direction at fixed contract-scale displacement, "
          "not by the regime label alone. Refinement suggested: state the "
          "conjecture per unit displacement (rate form), where the "
          "correspondence chi = sin(theta), margin burn = d*cos(theta) "
          "is exact in this miniature.")
    return True  # data, never fails the run


# --------------------------------------------------------------------- I6

def i6_frame_temperature():
    eps_grid = [10 ** (k / 8.0) for k in range(-32, 33)]
    xis = [xi_of(e) for e in eps_grid]
    mono_xi = all(a < b for a, b in zip(xis, xis[1:]))
    ps = [p_of_xi(x) for x in xis]
    mono_p = all(a > b for a, b in zip(ps, ps[1:]))
    limits = ps[0] > 100 and 1.0 < ps[-1] < 1.01
    # unique xi* with p(xi*) = 2: p strictly decreasing => the first grid
    # point with p <= 2 brackets the unique crossing.
    idx = next((i for i, p in enumerate(ps) if p <= 2.0), None)
    xi_star = xis[idx] if idx is not None else None
    ok = (mono_xi and mono_p and limits and xi_star is not None
          and abs(xi_star - 1.0) < 0.1)
    star = f"{xi_star:.3f}" if xi_star is not None else "NOT FOUND"
    print(f"I6 frame-temperature composite (consistency realization): xi "
          f"strictly increasing {'PASS' if mono_xi else 'FAIL'}, p strictly "
          f"decreasing {'PASS' if mono_p else 'FAIL'}, limits "
          f"{'PASS' if limits else 'FAIL'}, unique xi* = "
          f"{star} with p = 2 {'PASS' if ok else 'FAIL'}")
    print("   note: p(xi) here is a consistency family realizing the lemma's "
          "interface; the derivation of p from the budgeted minimization is "
          "the manuscript's, not re-proved here.")
    return ok


def main() -> int:
    print("finite interface model: Hilbert--Banach bridge + exportability "
          "conjecture, in miniature\n")
    results = [
        i1_budget_minimizer(),
        i2_interpolation(),
        i3_threshold(),
        i4_contextuality_defect(),
        i5_exportability_regime(),
        i6_frame_temperature(),
    ]
    ok = all(results)
    print(f"\n{'ALL INTERFACE CHECKS PASS' if ok else 'INTERFACE FAILURES PRESENT'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
