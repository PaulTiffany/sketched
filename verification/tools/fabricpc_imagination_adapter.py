"""Feed existing pinned FabricPC square traces into the strict detector.

This is a calibration adapter. The sigmoid frame carries an explicit
architecture confound because its known activation already explains
non-additivity. Each stored frame currently has only one runtime replicate and
no order experiment, so the strict detector must remain clear.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from imagination_sweep_detector import INPUT_SCHEMA, audit

ROOT = Path(__file__).resolve().parents[2]


def _replicate(trace: dict[str, Any], replicate_id: str) -> dict[str, Any]:
    return {
        "replicate_id": replicate_id,
        "base_states": trace["base_states"],
        "first_states": trace["first_states"],
        "second_states": trace["second_states"],
        "combined_states": trace["combined_states"],
    }


def build_payload(linear: dict[str, Any], nonlinear: dict[str, Any]) -> dict[str, Any]:
    if linear["fabricpc_commit"] != nonlinear["fabricpc_commit"]:
        raise ValueError("FabricPC trace commits do not match")
    return {
        "schema": INPUT_SCHEMA,
        "run_id": "fabricpc-imagination-calibration",
        "fabricpc_repository": linear["fabricpc_repository"],
        "fabricpc_commit": linear["fabricpc_commit"],
        "thresholds": {
            "residue_norm": 1e-7,
            "commutator_norm": 1e-7,
            "minimum_frame_hits": 2,
            "minimum_replicate_hits": 2,
        },
        "frames": [
            {
                "frame_id": "linear-activation",
                "frame_metadata": {
                    "activation": "linear",
                    "epsilon": linear["experiment"]["epsilon"],
                },
                "architecture_confound": False,
                "replicates": [_replicate(linear, "seed17-23")],
            },
            {
                "frame_id": "sigmoid-activation",
                "frame_metadata": {
                    "activation": "sigmoid",
                    "epsilon": nonlinear["experiment"]["epsilon"],
                    "known_mechanism": (
                        "sigmoid nonlinearity can produce mixed residue"
                    ),
                },
                "architecture_confound": True,
                "replicates": [_replicate(nonlinear, "seed17-23")],
            },
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--linear",
        type=Path,
        default=ROOT / "verification" / "fabricpc_second_order_trace.json",
    )
    parser.add_argument(
        "--nonlinear",
        type=Path,
        default=(
            ROOT
            / "verification"
            / "fabricpc_second_order_nonlinear_trace.json"
        ),
    )
    parser.add_argument(
        "--input-output",
        type=Path,
        default=(
            ROOT
            / "verification"
            / "fabricpc_imagination_sweep_input.json"
        ),
    )
    parser.add_argument(
        "--certificate-output",
        type=Path,
        default=(
            ROOT
            / "verification"
            / "fabricpc_imagination_sweep_certificate.json"
        ),
    )
    args = parser.parse_args()
    linear = json.loads(args.linear.read_text(encoding="utf-8"))
    nonlinear = json.loads(args.nonlinear.read_text(encoding="utf-8"))
    payload = build_payload(linear, nonlinear)
    certificate = audit(payload)
    args.input_output.write_text(
        json.dumps(payload, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    args.certificate_output.write_text(
        json.dumps(certificate, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(
        "screening="
        f"{certificate['summary']['screening_candidate']}; "
        "orientation="
        f"{certificate['summary']['orientation_sensitive_candidate']}; "
        "identified="
        f"{certificate['summary']['imagination_identified']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
