"""Compare blockwise metrics for the pinned FabricPC orientation sweep."""
from __future__ import annotations

import hashlib
import json
import math

from fabricpc_orientation_adapter import ROOT, run

SCHEMA = "sketched.fabricpc-orientation-block-sweep.v1"


def norm(values: list[float]) -> float:
    return math.sqrt(sum(x * x for x in values))


def sub(left: list[float], right: list[float]) -> list[float]:
    return [x - y for x, y in zip(left, right, strict=True)]


def ratio(after: float, before: float, tolerance: float = 1e-12) -> float | None:
    return None if before <= tolerance else after / before


def main() -> int:
    parameter_seeds = [3, 17, 41]
    state_seeds = [5, 23]
    rates = [0.01, 0.05, 0.2]
    directions = [(1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (1.0, -1.0)]
    rows = []
    for parameter_seed in parameter_seeds:
        for state_seed in state_seeds:
            for eta in rates:
                for direction in directions:
                    payload, _ = run(
                        perturbation=1e-3,
                        infer_steps=12,
                        eta=eta,
                        parameter_seed=parameter_seed,
                        state_seed=state_seed,
                        direction=direction,
                    )
                    perturbations = [
                        sub(probe, base)
                        for base, probe in zip(
                            payload["base_states"],
                            payload["probe_states"],
                            strict=True,
                        )
                    ]
                    step_rows = []
                    for step, (before, after) in enumerate(
                        zip(perturbations, perturbations[1:])
                    ):
                        hidden_before, latent_before = norm(before[:2]), norm(before[2:])
                        hidden_after, latent_after = norm(after[:2]), norm(after[2:])
                        product_before, product_after = norm(before), norm(after)
                        max_before = max(hidden_before, latent_before)
                        max_after = max(hidden_after, latent_after)
                        step_rows.append(
                            {
                                "step": step,
                                "product_l2_gain": ratio(product_after, product_before),
                                "max_block_gain": ratio(max_after, max_before),
                                "hidden_gain": ratio(hidden_after, hidden_before),
                                "latent_gain": ratio(latent_after, latent_before),
                                "hidden_before": hidden_before,
                                "hidden_after": hidden_after,
                                "latent_before": latent_before,
                                "latent_after": latent_after,
                                "latent_emergence": (
                                    latent_before <= 1e-12 and latent_after > 1e-12
                                ),
                            }
                        )
                    first = step_rows[0]
                    rows.append(
                        {
                            "run_id": payload["run_id"],
                            "parameter_seed": parameter_seed,
                            "state_seed": state_seed,
                            "eta_infer": eta,
                            "direction": list(direction),
                            "first_transition": first,
                            "product_breach": first["product_l2_gain"] > 1,
                            "max_block_breach": first["max_block_gain"] > 1,
                            "hidden_breach": first["hidden_gain"] > 1,
                            "steps": step_rows,
                        }
                    )

    report = {
        "schema": SCHEMA,
        "method": {
            "state_layout": {"hidden": [0, 2], "latent": [2, 4]},
            "metrics": {
                "product_l2": "Euclidean norm on concatenated hidden and latent blocks",
                "max_block": "maximum of hidden and latent Euclidean block norms",
                "hidden": "Euclidean norm restricted to the originally perturbed block",
            },
            "breach_threshold": 1.0,
            "selection": "same complete 72-run Cartesian sweep",
        },
        "run_count": len(rows),
        "first_step_product_breaches": sum(r["product_breach"] for r in rows),
        "first_step_max_block_breaches": sum(r["max_block_breach"] for r in rows),
        "first_step_hidden_breaches": sum(r["hidden_breach"] for r in rows),
        "first_step_latent_emergence": sum(
            r["first_transition"]["latent_emergence"] for r in rows
        ),
        "runs": rows,
    }
    canonical = json.dumps(report, sort_keys=True, separators=(",", ":")).encode()
    report["report_sha256"] = hashlib.sha256(canonical).hexdigest()
    output = ROOT / "verification" / "fabricpc_orientation_block_sweep.json"
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"block sweep -> {output}")
    print(
        f"first-step breaches: product={report['first_step_product_breaches']}, "
        f"max-block={report['first_step_max_block_breaches']}, "
        f"hidden={report['first_step_hidden_breaches']}; "
        f"latent-emergence={report['first_step_latent_emergence']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
