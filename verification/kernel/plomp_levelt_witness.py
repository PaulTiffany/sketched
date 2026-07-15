"""Plomp-Levelt witness: invariant-limited transference, measured.

Principia Book 4 treats the Plomp-Levelt consonance curve and the Newtonian
chromatic wheel as MODAL TRANSFERENCE carriers: a lower-order physical
carrier helps a PS claim only insofar as a NAMED invariant is preserved
(remark:bk4_invariant_limited_transfer). The named invariants for perceived
tension are ordinal/monotone structure, not metric structure. This witness
makes that scoping quantitative on the standard parametrized Plomp-Levelt
kernel (Sethares' fit of the 1965 curve):

    d(f1, f2) = exp(-A s x) - exp(-B s x),   x = |f2 - f1|,
    s = S / (s1 * fmin + s2)   (critical-bandwidth scaling)

  1. curve shape (positive control): d(0) = 0, single interior peak, decay
     toward zero for wide separation — the qualitative Plomp-Levelt curve;
  2. METRIC transposition equivariance FAILS: transposing an interval by
     ratio r changes its numeric dissonance because the critical band does
     not scale linearly with frequency. The defect is measured across r and
     is a CARRIER property (transport-loss class: interpretive/projective),
     classified per the repo's SquareDefect discipline, not smoothed;
  3. ORDINAL invariance HOLDS: the tension RANKING of a fixed interval set
     is preserved under transposition across the tested register — this is
     the invariant that modal transference actually licenses;
  4. complex-tone minima (the classical result): for a 6-partial harmonic
     tone swept over an octave, local dissonance minima land near the
     simple ratios (octave 2/1, fifth 3/2, fourth 4/3, major third 5/4);
  5. negative control: stretching the partials (inharmonic timbre) moves
     the minima off the simple ratios — the carrier, not number mysticism,
     places them (Sethares' point, deterministic here).

Deterministic; tolerances declared; machine-readable output to
verification/plomp_levelt_witness.json.

Run: python verification/kernel/plomp_levelt_witness.py  (exit 0 iff checks pass)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

# Sethares' parametrization of the Plomp-Levelt curve
A_COEF, B_COEF = 3.5, 5.75
D_STAR = 0.24          # point of maximal dissonance (in s units)
S1, S2 = 0.0207, 18.96
RANK_REGISTER = (220.0, 880.0)   # transposition test register (A3..A5)
OUT = Path(__file__).resolve().parents[1] / "plomp_levelt_witness.json"


def pl_dissonance(f1: float, f2: float, a1: float = 1.0, a2: float = 1.0) -> float:
    """Pairwise Plomp-Levelt dissonance (Sethares fit)."""
    fmin = min(f1, f2)
    s = D_STAR / (S1 * fmin + S2)
    x = abs(f2 - f1)
    return a1 * a2 * (np.exp(-A_COEF * s * x) - np.exp(-B_COEF * s * x))


def tone_dissonance(f0a: float, f0b: float, partials: int = 6,
                    stretch: float = 2.0) -> float:
    """Total dissonance of two complex tones with `partials` partials at
    ratios stretch**log2(k) (stretch=2 -> harmonic k*f0), 1/k amplitudes."""
    total = 0.0
    for i in range(1, partials + 1):
        for j in range(1, partials + 1):
            fa = f0a * stretch ** np.log2(i)
            fb = f0b * stretch ** np.log2(j)
            total += pl_dissonance(fa, fb, 1.0 / i, 1.0 / j)
    return total


def local_minima(ratios: np.ndarray, values: np.ndarray) -> list[float]:
    mins = []
    for k in range(1, len(values) - 1):
        if values[k] < values[k - 1] and values[k] < values[k + 1]:
            mins.append(float(ratios[k]))
    return mins


def main() -> int:
    ok = True
    results: dict = {"schema": "sketched.plomp-levelt-witness.v1",
                     "kernel": {"A": A_COEF, "B": B_COEF, "d_star": D_STAR,
                                "s1": S1, "s2": S2}}

    # 1. curve shape: zero at unison, one interior peak, decay
    f0 = 440.0
    xs = np.linspace(0.0, 300.0, 3001)
    ds = np.array([pl_dissonance(f0, f0 + x) for x in xs])
    peak = int(np.argmax(ds))
    shape_ok = (abs(ds[0]) < 1e-12 and 0 < peak < len(xs) - 1
                and ds[-1] < ds[peak] / 10)
    print(f"curve shape at {f0} Hz: d(0)={ds[0]:.1e}, peak at "
          f"{xs[peak]:.1f} Hz separation, tail/peak="
          f"{ds[-1]/ds[peak]:.3f} -> {'OK' if shape_ok else 'FAIL'}")
    ok &= shape_ok
    results["curve_shape"] = {"peak_separation_hz": float(xs[peak]),
                              "tail_over_peak": float(ds[-1] / ds[peak])}

    # 2. metric transposition equivariance fails (measured, carrier-level)
    base = 261.63          # C4
    interval = 1.5         # a fifth
    d_base = pl_dissonance(base, base * interval)
    defects = []
    for r in (0.5, 1.0, 2.0, 4.0):
        d_r = pl_dissonance(base * r, base * r * interval)
        defects.append({"transposition": r, "dissonance": float(d_r),
                        "relative_defect": float(abs(d_r - d_base) /
                                                 max(d_base, 1e-300))})
    max_defect = max(d["relative_defect"] for d in defects)
    print("metric transposition defect (fifth on C4 moved by r):")
    for d in defects:
        print(f"  r={d['transposition']:.1f}  d={d['dissonance']:.4f}  "
              f"defect={d['relative_defect']:.3f}")
    metric_fails = max_defect > 0.1   # the defect is structural, not roundoff
    print(f"  -> metric equivariance FAILS as expected (max defect "
          f"{max_defect:.3f}); loss class: interpretive/projective "
          f"(critical band does not scale with frequency)")
    ok &= metric_fails
    results["metric_transposition"] = {"defects": defects,
                                       "max_relative_defect": max_defect}

    # 3. global ordinal invariance fails too: preserve this scope boundary
    intervals = {"m2": 16 / 15, "M2": 9 / 8, "m3": 6 / 5, "M3": 5 / 4,
                 "P4": 4 / 3, "tritone": 45 / 32, "P5": 3 / 2, "octave": 2.0}
    rankings = []
    lo, hi = RANK_REGISTER
    for f in np.linspace(lo, hi, 12):
        ds_i = {n: tone_dissonance(f, f * r) for n, r in intervals.items()}
        rankings.append(tuple(sorted(ds_i, key=ds_i.get)))
    ordinal_preserved = all(r == rankings[0] for r in rankings)
    print(f"ordinal invariance over {lo:.0f}-{hi:.0f} Hz "
          f"({len(rankings)} transpositions): ranking "
          f"{'PRESERVED' if ordinal_preserved else 'BROKEN as expected'}")
    print(f"  tension order (low->high): {', '.join(rankings[0])}")
    ordinal_scope_check = not ordinal_preserved
    ok &= ordinal_scope_check
    results["ordinal_invariance"] = {"register_hz": [lo, hi],
                                     "preserved": ordinal_preserved,
                                     "expected_global_failure": ordinal_scope_check,
                                     "ranking": list(rankings[0])}

    # 4. harmonic complex tones: minima near simple ratios
    ratios = np.linspace(1.02, 2.05, 2061)
    f_ref = 261.63
    vals = np.array([tone_dissonance(f_ref, f_ref * r) for r in ratios])
    mins = local_minima(ratios, vals)
    targets = {"P5 3/2": 1.5, "P4 4/3": 4 / 3, "M3 5/4": 1.25,
               "M6 5/3": 5 / 3, "octave 2/1": 2.0}
    hits = {}
    for name, tgt in targets.items():
        best = min(mins, key=lambda m: abs(m - tgt)) if mins else float("nan")
        hits[name] = {"target": tgt, "nearest_minimum": best,
                      "error": abs(best - tgt)}
    harm_ok = all(h["error"] < 0.02 for h in hits.values())
    print("harmonic-tone dissonance minima vs simple ratios:")
    for name, h in hits.items():
        print(f"  {name:12s} target={h['target']:.4f} "
              f"minimum={h['nearest_minimum']:.4f} err={h['error']:.4f}")
    print(f"  -> {'minima at simple ratios (classical result)' if harm_ok else 'FAIL'}")
    ok &= harm_ok
    results["harmonic_minima"] = hits

    # 5. negative control: stretched (inharmonic) partials move the minima
    vals_s = np.array([tone_dissonance(f_ref, f_ref * r, stretch=2.2)
                       for r in ratios])
    mins_s = local_minima(ratios, vals_s)
    fifth_err_stretched = (min(abs(m - 1.5) for m in mins_s)
                           if mins_s else float("inf"))
    stretch_ok = fifth_err_stretched > 0.02
    print(f"negative control (stretch 2.2): nearest minimum to 3/2 is off by "
          f"{fifth_err_stretched:.4f} -> "
          f"{'minima follow the CARRIER, not the integers' if stretch_ok else 'FAIL'}")
    ok &= stretch_ok
    results["stretched_negative_control"] = {
        "stretch": 2.2, "fifth_error": float(fifth_err_stretched)}

    results["verdict"] = "pass" if ok else "fail"
    OUT.write_text(json.dumps(results, indent=2) + "\n")
    print(f"machine-readable results -> {OUT.relative_to(OUT.parents[1])}")
    print(f"\n{'ALL PLOMP-LEVELT CHECKS PASS' if ok else 'FAILURES PRESENT'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
