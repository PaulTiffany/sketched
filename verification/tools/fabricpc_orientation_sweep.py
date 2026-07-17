"""Run a bounded, deterministic orientation sweep against pinned FabricPC."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from fabricpc_orientation_adapter import ROOT, run

SCHEMA = "sketched.fabricpc-orientation-sweep.v1"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "verification" / "fabricpc_orientation_sweep.json",
    )
    parser.add_argument("--infer-steps", type=int, default=12)
    parser.add_argument("--perturbation", type=float, default=1e-3)
    args = parser.parse_args()

    parameter_seeds = [3, 17, 41]
    state_seeds = [5, 23]
    rates = [0.01, 0.05, 0.2]
    directions = [(1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (1.0, -1.0)]
    runs = []
    for parameter_seed in parameter_seeds:
        for state_seed in state_seeds:
            for eta in rates:
                for direction in directions:
                    payload, certificate = run(
                        perturbation=args.perturbation,
                        infer_steps=args.infer_steps,
                        eta=eta,
                        parameter_seed=parameter_seed,
                        state_seed=state_seed,
                        direction=direction,
                    )
                    transitions = certificate["transitions"]
                    gains = [
                        t["directional_gain"]
                        for t in transitions
                        if t["directional_gain"] is not None
                    ]
                    cosines = [
                        t["orientation_cosine"]
                        for t in transitions
                        if t["orientation_cosine"] is not None
                    ]
                    runs.append(
                        {
                            "run_id": payload["run_id"],
                            "parameter_seed": parameter_seed,
                            "state_seed": state_seed,
                            "eta_infer": eta,
                            "direction": list(direction),
                            "candidate_count": certificate["candidate_count"],
                            "gain_breach_count": sum(t["gain_breach"] for t in transitions),
                            "orientation_reversal_count": sum(
                                t["orientation_reversal"] for t in transitions
                            ),
                            "joint_count": sum(
                                t["gain_breach"] and t["orientation_reversal"]
                                for t in transitions
                            ),
                            "degenerate_count": sum(
                                t["degenerate_orientation"] for t in transitions
                            ),
                            "max_directional_gain": max(gains) if gains else None,
                            "min_orientation_cosine": min(cosines) if cosines else None,
                            "input_sha256": certificate["source"]["input_sha256"],
                        }
                    )

    report = {
        "schema": SCHEMA,
        "method": {
            "parameter_seeds": parameter_seeds,
            "state_seeds": state_seeds,
            "eta_infer": rates,
            "directions": [list(x) for x in directions],
            "infer_steps": args.infer_steps,
            "perturbation": args.perturbation,
            "selection": "complete Cartesian product; no result-dependent filtering",
        },
        "run_count": len(runs),
        "runs_with_candidates": sum(r["candidate_count"] > 0 for r in runs),
        "runs_with_gain_breach": sum(r["gain_breach_count"] > 0 for r in runs),
        "runs_with_orientation_reversal": sum(
            r["orientation_reversal_count"] > 0 for r in runs
        ),
        "runs_with_joint_event": sum(r["joint_count"] > 0 for r in runs),
        "runs": runs,
    }
    canonical = json.dumps(report, sort_keys=True, separators=(",", ":")).encode()
    report["report_sha256"] = hashlib.sha256(canonical).hexdigest()
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"sweep -> {args.output}")
    print(
        f"{report['runs_with_candidates']}/{report['run_count']} runs with candidates; "
        f"gain={report['runs_with_gain_breach']}, "
        f"orientation={report['runs_with_orientation_reversal']}, "
        f"joint={report['runs_with_joint_event']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
