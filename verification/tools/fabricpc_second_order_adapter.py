"""Generate square second-order certificates from the pinned FabricPC checkout.

This bridge is Sketched-owned.  It imports FabricPC read-only, verifies the
commit recorded in ``fabricpc_install_receipt.json``, and writes only JSON
artifacts in this repository.
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

from fabricpc_orientation_adapter import ROOT, run
from second_order_sensor import SCHEMA, audit


def experiment(
    *,
    epsilon: float,
    infer_steps: int,
    eta: float,
    nonlinear: bool,
) -> tuple[dict, dict]:
    """Run the four corners of one deterministic perturbation square."""
    first, _ = run(
        epsilon,
        infer_steps,
        eta,
        direction=(1.0, 0.0),
        nonlinear=nonlinear,
    )
    second, _ = run(
        epsilon,
        infer_steps,
        eta,
        direction=(0.0, 1.0),
        nonlinear=nonlinear,
    )
    combined, _ = run(
        math.sqrt(2.0) * epsilon,
        infer_steps,
        eta,
        direction=(1.0, 1.0),
        nonlinear=nonlinear,
    )
    if first["base_states"] != second["base_states"]:
        raise RuntimeError("first and second base branches disagree")
    if first["base_states"] != combined["base_states"]:
        raise RuntimeError("first and combined base branches disagree")

    payload = {
        "schema": SCHEMA,
        "run_id": f"fabricpc-four-branch-hidden-e1-e2-eps{epsilon:g}-nonlinear{int(nonlinear)}",
        "fabricpc_repository": first["fabricpc_repository"],
        "fabricpc_commit": first["fabricpc_commit"],
        "thresholds": {"residue_norm": 1e-7},
        "base_states": first["base_states"],
        "first_states": first["probe_states"],
        "second_states": second["probe_states"],
        "combined_states": combined["probe_states"],
        "experiment": {
            "epsilon": epsilon,
            "first_direction": [1.0, 0.0],
            "second_direction": [0.0, 1.0],
            "combined_direction": [1.0, 1.0],
            "eta_infer": eta,
            "infer_steps": infer_steps,
            "nonlinear": nonlinear,
            "interpretation_boundary": (
                "nonzero residue establishes observable non-additivity only; "
                "it does not identify an imaginary traversal"
            ),
        },
    }
    return payload, audit(payload)


def _write_pair(output_dir: Path, stem: str, payload: dict, certificate: dict) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / f"{stem}_trace.json").write_text(
        json.dumps(payload, indent=2) + "\n", encoding="utf-8"
    )
    (output_dir / f"{stem}_certificate.json").write_text(
        json.dumps(certificate, indent=2) + "\n", encoding="utf-8"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, default=ROOT / "verification")
    parser.add_argument("--perturbation", type=float, default=0.1)
    parser.add_argument("--infer-steps", type=int, default=12)
    parser.add_argument("--eta", type=float, default=0.05)
    parser.add_argument(
        "--nonlinear",
        action="store_true",
        help="also run the sigmoid-activated FabricPC graph",
    )
    args = parser.parse_args()
    if args.perturbation == 0 or args.infer_steps < 1 or args.eta <= 0:
        raise ValueError("require nonzero perturbation, infer_steps >= 1, eta > 0")

    linear_payload, linear_certificate = experiment(
        epsilon=args.perturbation,
        infer_steps=args.infer_steps,
        eta=args.eta,
        nonlinear=False,
    )
    _write_pair(
        args.output_dir,
        "fabricpc_second_order",
        linear_payload,
        linear_certificate,
    )
    print(
        "linear: "
        f"{linear_certificate['steps_with_second_order_residue']}/"
        f"{linear_certificate['step_count']} steps above threshold; "
        f"max residue={linear_certificate['max_residue_norm']:.9g}"
    )

    if args.nonlinear:
        nonlinear_payload, nonlinear_certificate = experiment(
            epsilon=args.perturbation,
            infer_steps=args.infer_steps,
            eta=args.eta,
            nonlinear=True,
        )
        _write_pair(
            args.output_dir,
            "fabricpc_second_order_nonlinear",
            nonlinear_payload,
            nonlinear_certificate,
        )
        print(
            "nonlinear: "
            f"{nonlinear_certificate['steps_with_second_order_residue']}/"
            f"{nonlinear_certificate['step_count']} steps above threshold; "
            f"max residue={nonlinear_certificate['max_residue_norm']:.9g}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
