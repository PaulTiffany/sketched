"""Finite-difference sensor for second-order interaction and order dependence.

The square experiment keeps four observable trajectories at the same times:

    base, first, second, combined

and reports the mixed finite difference

    combined - first - second + base.

This is an observable non-additivity certificate.  It is not a Hessian
estimate, a global Lipschitz result, or an imagination detector.  Optional
``order_ab_states`` and ``order_ba_states`` trajectories provide a separate
commutator witness for order-sensitive procedures.
"""
from __future__ import annotations

import hashlib
import json
import math
from typing import Any

SCHEMA = "sketched.second-order-input.v1"
OUTPUT_SCHEMA = "sketched.second-order-certificate.v1"

_SQUARE_BRANCHES = ("base_states", "first_states", "second_states", "combined_states")
_ORDER_BRANCHES = ("order_ab_states", "order_ba_states")


def _trajectory(payload: dict[str, Any], key: str) -> list[list[float]]:
    value = payload.get(key)
    if not isinstance(value, list) or not value:
        raise ValueError(f"{key} must be a nonempty trajectory")
    result: list[list[float]] = []
    for index, state in enumerate(value):
        if not isinstance(state, list) or not state:
            raise ValueError(f"{key}[{index}] must be a nonempty numeric array")
        try:
            vector = [float(x) for x in state]
        except (TypeError, ValueError) as exc:
            raise ValueError(f"{key}[{index}] must be numeric") from exc
        if not all(math.isfinite(x) for x in vector):
            raise ValueError(f"{key}[{index}] contains a non-finite value")
        result.append(vector)
    dimension = len(result[0])
    if any(len(state) != dimension for state in result):
        raise ValueError(f"{key} has inconsistent state dimensions")
    return result


def _norm(vector: list[float]) -> float:
    return math.sqrt(sum(x * x for x in vector))


def _subtract(left: list[float], right: list[float]) -> list[float]:
    if len(left) != len(right):
        raise ValueError("state vectors must have equal dimensions")
    return [x - y for x, y in zip(left, right, strict=True)]


def _square_residue(
    base: list[float],
    first: list[float],
    second: list[float],
    combined: list[float],
) -> list[float]:
    if not (len(base) == len(first) == len(second) == len(combined)):
        raise ValueError("state vectors must have equal dimensions")
    return [
        both - one - two + origin
        for origin, one, two, both in zip(
            base, first, second, combined, strict=True
        )
    ]


def _thresholds(payload: dict[str, Any]) -> tuple[float, float]:
    raw = payload.get("thresholds", {})
    if not isinstance(raw, dict):
        raise ValueError("thresholds must be an object")
    residue = float(raw.get("residue_norm", 1e-9))
    commutator = float(raw.get("commutator_norm", residue))
    if (
        not math.isfinite(residue)
        or not math.isfinite(commutator)
        or residue < 0
        or commutator < 0
    ):
        raise ValueError("residue and commutator thresholds must be finite and nonnegative")
    return residue, commutator


def audit(payload: dict[str, Any]) -> dict[str, Any]:
    """Validate a square experiment and emit a hash-pinned certificate."""
    if not isinstance(payload, dict) or payload.get("schema") != SCHEMA:
        raise ValueError(f"input schema must be {SCHEMA}")

    branches = {name: _trajectory(payload, name) for name in _SQUARE_BRANCHES}
    lengths = {len(trajectory) for trajectory in branches.values()}
    dimensions = {len(trajectory[0]) for trajectory in branches.values()}
    if len(lengths) != 1 or len(dimensions) != 1:
        raise ValueError("all four square branches must have matching shapes")

    residue_threshold, commutator_threshold = _thresholds(payload)
    order_present = [payload.get(name) is not None for name in _ORDER_BRANCHES]
    if any(order_present) and not all(order_present):
        raise ValueError("order_ab_states and order_ba_states must be supplied together")
    order: dict[str, list[list[float]]] = {}
    if all(order_present):
        order = {name: _trajectory(payload, name) for name in _ORDER_BRANCHES}
        order_lengths = {len(trajectory) for trajectory in order.values()}
        order_dimensions = {len(trajectory[0]) for trajectory in order.values()}
        if (
            len(order_lengths) != 1
            or len(order_dimensions) != 1
            or next(iter(order_lengths)) != next(iter(lengths))
            or next(iter(order_dimensions)) != next(iter(dimensions))
        ):
            raise ValueError("order branches must match the square branch shape")

    rows: list[dict[str, Any]] = []
    square = [branches[name] for name in _SQUARE_BRANCHES]
    for step, (base, first, second, combined) in enumerate(zip(*square, strict=True)):
        residue = _square_residue(base, first, second, combined)
        residue_norm = _norm(residue)
        first_delta_norm = _norm(_subtract(first, base))
        second_delta_norm = _norm(_subtract(second, base))
        scale = max(first_delta_norm, second_delta_norm)
        row: dict[str, Any] = {
            "step": step,
            "residue": residue,
            "residue_norm": residue_norm,
            "interaction_ratio": residue_norm / scale if scale > 0 else None,
            "second_order_observed": residue_norm > residue_threshold,
        }
        if order:
            commutator = _subtract(
                order["order_ab_states"][step], order["order_ba_states"][step]
            )
            commutator_norm = _norm(commutator)
            row.update(
                {
                    "commutator": commutator,
                    "commutator_norm": commutator_norm,
                    "order_dependence_observed": commutator_norm > commutator_threshold,
                }
            )
        rows.append(row)

    canonical = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    order_measured = bool(order)
    result: dict[str, Any] = {
        "schema": OUTPUT_SCHEMA,
        "source": {
            "input_sha256": hashlib.sha256(canonical).hexdigest(),
            "run_id": payload.get("run_id"),
            "fabricpc_repository": payload.get("fabricpc_repository"),
            "fabricpc_commit": payload.get("fabricpc_commit"),
        },
        "method": {
            "observable": "mixed finite-difference interaction residue",
            "formula": "F(x+d1+d2)-F(x+d1)-F(x+d2)+F(x)",
            "commutator_formula": "F_A_then_B(x)-F_B_then_A(x)",
            "order_branches_measured": order_measured,
            "residue_threshold": residue_threshold,
            "commutator_threshold": commutator_threshold,
            "global_lipschitz_claim": False,
            "hessian_claim": False,
            "imagination_claim": False,
            "latent_cause_identified": False,
        },
        "dimension": next(iter(dimensions)),
        "step_count": len(rows),
        "steps_with_second_order_residue": sum(
            row["second_order_observed"] for row in rows
        ),
        "max_residue_norm": max(row["residue_norm"] for row in rows),
        "steps": rows,
    }
    if order_measured:
        result["steps_with_order_dependence"] = sum(
            row["order_dependence_observed"] for row in rows
        )
        result["max_commutator_norm"] = max(row["commutator_norm"] for row in rows)
    else:
        result["steps_with_order_dependence"] = None
        result["max_commutator_norm"] = None
    return result


if __name__ == "__main__":
    import argparse
    from pathlib import Path

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    certificate = audit(json.loads(args.input.read_text(encoding="utf-8")))
    rendered = json.dumps(certificate, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8", newline="\n")
    else:
        print(rendered, end="")
