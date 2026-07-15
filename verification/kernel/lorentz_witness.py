"""Numeric witness for the Lorentz-force equivariance instance (Lean PS).

The Lean instance (ForcingAnalysis/Lorentz.lean) proves, over the schema of
ForcingKernel/Schema.lean:
  * lorentzForce_covariant / lorentzForce_equivariant — the commuting square
    K(Lam.F, Lam u) = Lam K(F, u) under the Lorentz condition Lam^T eta Lam = eta;
  * lorentzForce_reflects — reflection, conditional on nondegeneracy;
  * zero_map_equivariant_not_lorentz — the zero map commutes and is not
    Lorentz, so the nondegeneracy hypothesis is not removable;
  * actF_antisymm — the covariant action preserves antisymmetry for EVERY
    frame map, Lorentz or not.

This script realizes the same square in float64 and deliberately crosses the
theorem's hypothesis boundary, which the proof cannot do:

  1. positive control — genuine boosts/rotations/compositions: equivariance
     residual and the classical invariants (u.eta u, F_uv F^uv) hold at
     machine scale;
  2. negative control (structural) — Lam + delta*P with P fixed non-Lorentz:
     a delta-sweep shows the commutation residual grows FIRST-ORDER in delta
     (log-log slope ~ 1) once above the floating-point floor, separating
     structural violation from numerical noise;
  3. countermodel echo — Lam = 0: residual exactly zero, Lorentz defect ~ 1.
     Numerical agreement of the square does NOT certify the Lorentz
     condition; reflection needs nondegeneracy, exactly as in Lean;
  4. representation check — actF keeps perturbed transports inside the
     antisymmetric (field-tensor) subspace, so the negative control fails
     *structurally*, not by leaving the representation.

Conventions match the Lean file: signature (+,-,-,-), c = 1, F is the
covariant tensor F_{mu nu}, index raising is left-multiplication by eta,
actF(Lam, F) = (eta Lam eta) F (eta Lam^T eta).

Deterministic: fixed inputs + seeded rng; tolerances declared below.
Emits machine-readable results to verification/lorentz_witness.json.

Run: python verification/kernel/lorentz_witness.py   (exit 0 iff all checks pass)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

TOL_EXACT = 1e-12       # machine-scale residual for exact (proved) identities
SLOPE_TOL = 0.15        # allowed deviation of the structural-failure exponent
SEPARATION = 1e3        # negative control must exceed positive control by this
ETA = np.diag([1.0, -1.0, -1.0, -1.0])
OUT = Path(__file__).resolve().parents[1] / "lorentz_witness.json"


def boost_x(rapidity: float) -> np.ndarray:
    ch, sh = np.cosh(rapidity), np.sinh(rapidity)
    L = np.eye(4)
    L[0, 0] = L[1, 1] = ch
    L[0, 1] = L[1, 0] = sh
    return L


def rotation_z(theta: float) -> np.ndarray:
    c, s = np.cos(theta), np.sin(theta)
    L = np.eye(4)
    L[1, 1] = L[2, 2] = c
    L[1, 2] = -s
    L[2, 1] = s
    return L


def field_tensor(E: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Covariant F_{mu nu} from E, B (Gaussian, c=1): F_{0i} = E_i,
    F_{ij} = -eps_{ijk} B_k."""
    F = np.zeros((4, 4))
    F[0, 1:] = E
    F[1:, 0] = -E
    F[1, 2], F[2, 1] = -B[2], B[2]
    F[1, 3], F[3, 1] = B[1], -B[1]
    F[2, 3], F[3, 2] = -B[0], B[0]
    return F


def four_velocity(v: np.ndarray) -> np.ndarray:
    g = 1.0 / np.sqrt(1.0 - float(v @ v))
    return g * np.concatenate(([1.0], v))


def act_f(lam: np.ndarray, F: np.ndarray) -> np.ndarray:
    """Covariant transport, inverse-free exactly as in Lean:
    (eta Lam eta) F (eta Lam^T eta)."""
    return ETA @ lam @ ETA @ F @ (ETA @ lam.T @ ETA)


def force(q: float, F: np.ndarray, u: np.ndarray) -> np.ndarray:
    return q * (ETA @ F) @ u


def lorentz_defect(lam: np.ndarray) -> float:
    return float(np.abs(lam.T @ ETA @ lam - ETA).max())


def commutation_residual(lam: np.ndarray, q: float, F: np.ndarray,
                         u: np.ndarray) -> float:
    lhs = force(q, act_f(lam, F), lam @ u)
    rhs = lam @ force(q, F, u)
    scale = max(float(np.abs(rhs).max()), 1.0)
    return float(np.abs(lhs - rhs).max()) / scale


def main() -> int:
    rng = np.random.default_rng(0)
    ok = True
    results: dict = {"schema": "sketched.lorentz-witness.v1",
                     "tolerances": {"exact": TOL_EXACT, "slope": SLOPE_TOL,
                                    "separation": SEPARATION}}

    q = 1.0
    E = np.array([0.3, -0.1, 0.2])
    B = np.array([0.1, 0.4, -0.2])
    F = field_tensor(E, B)
    u = four_velocity(np.array([0.2, -0.3, 0.1]))
    lams = {
        "boost(0.7)": boost_x(0.7),
        "rotation(0.9)": rotation_z(0.9),
        "boost*rot*boost": boost_x(0.4) @ rotation_z(1.2) @ boost_x(-0.8),
    }

    # 1. positive control: proved identities at machine scale
    print("positive control (Lorentz maps): defect, equivariance residual,")
    print("  invariant drift (u.eta u and F_uv F^uv):")
    inv_u = float(u @ ETA @ u)
    inv_f = float(np.trace(ETA @ F @ ETA @ F))
    pos = {}
    worst_pos = 0.0
    for name, lam in lams.items():
        d = lorentz_defect(lam)
        r = commutation_residual(lam, q, F, u)
        du = abs(float((lam @ u) @ ETA @ (lam @ u)) - inv_u)
        Fp = act_f(lam, F)
        df = abs(float(np.trace(ETA @ Fp @ ETA @ Fp)) - inv_f)
        pos[name] = {"lorentz_defect": d, "residual": r,
                     "u_norm_drift": du, "invariant_F_drift": df}
        worst_pos = max(worst_pos, d, r, du, df)
        print(f"  {name:18s} defect={d:.2e} residual={r:.2e} "
              f"du={du:.2e} dF={df:.2e}")
    if worst_pos < TOL_EXACT:
        print(f"  -> all < {TOL_EXACT}: matches lorentzForce_covariant "
              f"(floating-point floor only)\n")
    else:
        print("  UNEXPECTED: proved identity fails numerically\n")
        ok = False
    results["positive_control"] = pos

    # 2. negative control: structural failure, first-order in delta
    lam0 = lams["boost(0.7)"]
    P = rng.standard_normal((4, 4))
    P /= np.abs(P).max()
    deltas = [10.0 ** (-k) for k in range(12, 0, -1)]
    sweep = []
    print("negative control (Lam + delta*P, P fixed non-Lorentz direction):")
    for d in deltas:
        r = commutation_residual(lam0 + d * P, q, F, u)
        sweep.append({"delta": d, "residual": r})
        print(f"  delta={d:.0e}  residual={r:.3e}")
    # slope over the clearly-structural regime
    xs = np.log10([s["delta"] for s in sweep if 1e-9 <= s["delta"] <= 1e-3])
    ys = np.log10([s["residual"] for s in sweep if 1e-9 <= s["delta"] <= 1e-3])
    slope = float(np.polyfit(xs, ys, 1)[0])
    sep = sweep[-4]["residual"] / max(worst_pos, 1e-300)  # delta = 1e-4
    print(f"  log-log slope on delta in [1e-9,1e-3]: {slope:.3f} (expect ~1)")
    if abs(slope - 1.0) < SLOPE_TOL and sep > SEPARATION:
        print("  -> residual is FIRST-ORDER in the hypothesis violation and "
              "well above the\n     numeric floor: a structural defect, not "
              "noise (the theorem's hypothesis bites)\n")
    else:
        print("  UNEXPECTED: failure signature not structural\n")
        ok = False
    results["negative_control"] = {"sweep": sweep, "slope": slope,
                                   "separation_over_floor": sep}

    # 3. countermodel echo: Lam = 0 commutes, is not Lorentz
    zero = np.zeros((4, 4))
    rz = commutation_residual(zero, q, F, u)
    dz = lorentz_defect(zero)
    print(f"countermodel echo (Lam = 0): residual={rz:.1f}, defect={dz:.1f}")
    if rz == 0.0 and dz == 1.0:
        print("  -> square commutes exactly, Lorentz condition maximally "
              "violated: numerical\n     agreement does not certify the "
              "hypothesis (zero_map_equivariant_not_lorentz)\n")
    else:
        print("  UNEXPECTED: countermodel echo failed\n")
        ok = False
    results["countermodel_echo"] = {"residual": rz, "lorentz_defect": dz}

    # 3b. conformal control: c*Lam (c^2 != 1) is invertible and non-Lorentz, so
    # by reflection (Lean: lorentzForce_reflects_antisym) it cannot commute --
    # the action conventions leave no conformal scalar ambiguity
    c = 1.5
    rc = commutation_residual(c * lam0, q, F, u)
    dc = lorentz_defect(c * lam0)
    print(f"conformal control (c={c}): residual={rc:.3e}, defect={dc:.3f}")
    if rc > SEPARATION * max(worst_pos, 1e-300) and dc > 0.1:
        print("  -> rescaled frames break the square: no conformal ambiguity, "
              "matching the\n     antisymmetric reflection theorem\n")
    else:
        print("  UNEXPECTED: conformal rescaling commuted\n")
        ok = False
    results["conformal_control"] = {"c": c, "residual": rc, "lorentz_defect": dc}

    # 4. representation check: actF preserves antisymmetry off the group too
    Fp = act_f(lam0 + 1e-2 * P, F)
    anti = float(np.abs(Fp + Fp.T).max())
    print(f"representation check (perturbed transport): |F' + F'^T|_max = {anti:.2e}")
    if anti < TOL_EXACT * 10:
        print("  -> negative control stays inside field-tensor space "
              "(actF_antisymm is\n     unconditional in Lam): the failure "
              "is structural, not representational\n")
    else:
        print("  UNEXPECTED: transport left the antisymmetric subspace\n")
        ok = False
    results["representation_check"] = {"antisymmetry_residual": anti}

    results["verdict"] = "pass" if ok else "fail"
    OUT.write_text(json.dumps(results, indent=2) + "\n")
    print(f"machine-readable results -> {OUT.relative_to(OUT.parents[1])}")
    print(f"\n{'ALL NUMERIC CHECKS PASS' if ok else 'FAILURES PRESENT'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
