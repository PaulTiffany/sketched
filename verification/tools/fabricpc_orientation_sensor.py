"""Orientation-sensitive audit for paired FabricPC trajectories.

This tool is deliberately external to the ignored FabricPC checkout.  It reads
JSON exported by an experiment and emits a deterministic certificate; it does
not patch, import, or push FabricPC.

For paired base/probe states x_t and x'_t, let d_t = x'_t - x_t.  The measured
directional gain across one update is

    ||d_(t+1)|| / ||d_t||.

This is a finite-difference directional Lipschitz observation, not a global
Lipschitz constant.  Orientation transport is the cosine between d_t and
d_(t+1).  Negative cosine records a reversal in the represented tangent
direction.  A candidate transition requires an explicit configured rule; the
default is a gain breach or orientation reversal.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

SCHEMA = "sketched.fabricpc-orientation-input.v1"
OUTPUT_SCHEMA = "sketched.fabricpc-orientation-certificate.v1"


def _vector(value: Any, label: str) -> list[float]:
    if not isinstance(value, list) or not value:
        raise ValueError(f"{label} must be a nonempty numeric array")
    result = [float(x) for x in value]
    if not all(math.isfinite(x) for x in result):
        raise ValueError(f"{label} contains a non-finite value")
    return result


def _sub(left: list[float], right: list[float]) -> list[float]:
    if len(left) != len(right):
        raise ValueError("paired states must have equal dimensions")
    return [x - y for x, y in zip(left, right, strict=True)]


def _norm(vector: list[float]) -> float:
    return math.sqrt(sum(x * x for x in vector))


def _dot(left: list[float], right: list[float]) -> float:
    if len(left) != len(right):
        raise ValueError("transported perturbations must have equal dimensions")
    return sum(x * y for x, y in zip(left, right, strict=True))


def audit(payload: dict[str, Any]) -> dict[str, Any]:
    if payload.get("schema") != SCHEMA:
        raise ValueError(f"input schema must be {SCHEMA}")

    base = [_vector(x, f"base_states[{i}]") for i, x in enumerate(payload["base_states"])]
    probe = [_vector(x, f"probe_states[{i}]") for i, x in enumerate(payload["probe_states"])]
    if len(base) != len(probe) or len(base) < 2:
        raise ValueError("base_states and probe_states must have equal length >= 2")

    dimension = len(base[0])
    if any(len(x) != dimension for x in base + probe):
        raise ValueError("all states must have one common dimension")

    thresholds = payload.get("thresholds", {})
    gain_limit = float(thresholds.get("directional_gain", 1.0))
    orientation_floor = float(thresholds.get("orientation_cosine", 0.0))
    zero_tolerance = float(thresholds.get("zero_tolerance", 1e-12))
    if gain_limit < 0 or not -1 <= orientation_floor <= 1 or zero_tolerance < 0:
        raise ValueError("invalid sensor thresholds")

    perturbations = [_sub(p, b) for p, b in zip(probe, base, strict=True)]
    transitions: list[dict[str, Any]] = []
    for step in range(len(perturbations) - 1):
        before = perturbations[step]
        after = perturbations[step + 1]
        before_norm = _norm(before)
        after_norm = _norm(after)
        degenerate = before_norm <= zero_tolerance or after_norm <= zero_tolerance
        gain = None if before_norm <= zero_tolerance else after_norm / before_norm
        cosine = (
            None
            if degenerate
            else _dot(before, after) / (before_norm * after_norm)
        )
        gain_breach = gain is not None and gain > gain_limit
        orientation_reversal = cosine is not None and cosine < orientation_floor
        candidate = gain_breach or orientation_reversal
        transitions.append(
            {
                "step": step,
                "input_perturbation_norm": before_norm,
                "output_perturbation_norm": after_norm,
                "directional_gain": gain,
                "orientation_cosine": cosine,
                "degenerate_orientation": degenerate,
                "gain_breach": gain_breach,
                "orientation_reversal": orientation_reversal,
                "candidate_transition": candidate,
                "interpretation": (
                    "candidate: audit latent traversal, operator order, and projection"
                    if candidate
                    else "no configured breach observed"
                ),
            }
        )

    canonical_input = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return {
        "schema": OUTPUT_SCHEMA,
        "source": {
            "input_sha256": hashlib.sha256(canonical_input).hexdigest(),
            "fabricpc_repository": payload.get("fabricpc_repository"),
            "fabricpc_commit": payload.get("fabricpc_commit"),
            "run_id": payload.get("run_id"),
        },
        "method": {
            "quantity": "paired finite-difference directional gain",
            "global_lipschitz_claim": False,
            "imagination_claim": False,
            "thresholds": {
                "directional_gain": gain_limit,
                "orientation_cosine": orientation_floor,
                "zero_tolerance": zero_tolerance,
            },
        },
        "dimension": dimension,
        "transition_count": len(transitions),
        "candidate_count": sum(t["candidate_transition"] for t in transitions),
        "transitions": transitions,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    payload = json.loads(args.input.read_text(encoding="utf-8"))
    certificate = audit(payload)
    rendered = json.dumps(certificate, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8", newline="\n")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
