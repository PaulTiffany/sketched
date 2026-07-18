"""Evaluate a causal FabricPC topology router on Tennessee Eastman alarms.

At observation t, every trained topology sees the same current plant vector.
The router selects the arm with the lowest final inference energy, without
seeing observation t+1.  Once t+1 is revealed, realized prediction loss and
regret are scored.  Small energy margins produce a human-review/defer signal.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

import jax
import jax.numpy as jnp
import optax

from fabricpc.graph_initialization import initialize_params
from fabricpc.training import train_step

from tep_fabricpc_predictive_coding import (
    ROOT,
    _build_structure,
    _history,
    _standardize,
)
from tep_trajectory_probe import load_run

SCHEMA = "sketched.tep-fabricpc-alarm-router.v1"
ARMS = ("process", "dense", "shuffled")


def _fit_arm(
    topology: str,
    x: jnp.ndarray,
    y: jnp.ndarray,
    *,
    latent_width: int,
    infer_steps: int,
    eta_infer: float,
    epochs: int,
    batch_size: int,
    learning_rate: float,
    parameter_seed: int,
):
    structure = _build_structure(
        topology,
        latent_width=latent_width,
        infer_steps=infer_steps,
        eta_infer=eta_infer,
    )
    params = initialize_params(structure, jax.random.PRNGKey(parameter_seed))
    optimizer = optax.adam(learning_rate)
    opt_state = optimizer.init(params)
    key = jax.random.PRNGKey(parameter_seed + 1)
    step = jax.jit(lambda p, o, b, k: train_step(p, o, b, structure, optimizer, k))
    for _epoch in range(epochs):
        for start in range(0, len(x), batch_size):
            key, batch_key = jax.random.split(key)
            batch = {
                "x": x[start : start + batch_size],
                "y": y[start : start + batch_size],
            }
            params, opt_state, _, _ = step(params, opt_state, batch, batch_key)
    return structure, params


def _arm_decision(
    params,
    structure,
    observation: jnp.ndarray,
    target: jnp.ndarray,
    *,
    state_seed: int,
) -> dict[str, float]:
    history, prediction = _history(
        params, structure, observation, state_seed=state_seed
    )
    final = history[-1]
    decision_energy = sum(
        metrics["energy"] for name, metrics in final.items() if name != "source"
    )
    predicted = jnp.asarray(prediction, dtype=target.dtype)
    loss = float(jnp.mean(jnp.square(predicted - target)))
    return {"decision_energy": float(decision_energy), "realized_mse": loss}


def _route_timeline(
    fitted: dict[str, tuple[Any, Any]],
    trajectory: jnp.ndarray,
    *,
    start_index: int,
    state_seed: int,
    defer_margin: float,
) -> dict[str, Any]:
    decisions: list[dict[str, Any]] = []
    cumulative_loss = {name: 0.0 for name in ARMS}
    router_loss = 0.0
    oracle_loss = 0.0
    deferred = 0
    for index in range(start_index, len(trajectory) - 1):
        results = {
            name: _arm_decision(
                fitted[name][1],
                fitted[name][0],
                trajectory[index],
                trajectory[index + 1],
                state_seed=state_seed,
            )
            for name in ARMS
        }
        by_energy = sorted(ARMS, key=lambda name: results[name]["decision_energy"])
        selected = by_energy[0]
        best_energy = results[selected]["decision_energy"]
        second_energy = results[by_energy[1]]["decision_energy"]
        denominator = max(abs(best_energy), abs(second_energy), 1e-12)
        relative_margin = (second_energy - best_energy) / denominator
        defer = relative_margin < defer_margin
        deferred += int(defer)

        realized = {name: results[name]["realized_mse"] for name in ARMS}
        oracle = min(realized.values())
        selected_loss = realized[selected]
        router_loss += selected_loss
        oracle_loss += oracle
        for name in ARMS:
            cumulative_loss[name] += realized[name]
        decisions.append(
            {
                "sample_index": index,
                "selected_arm": selected,
                "action": "human_review" if defer else "auto_route",
                "relative_energy_margin": relative_margin,
                "decision_energy": {
                    name: results[name]["decision_energy"] for name in ARMS
                },
                "realized_next_state_mse": realized,
                "selected_realized_mse": selected_loss,
                "oracle_realized_mse": oracle,
                "instantaneous_regret": selected_loss - oracle,
            }
        )

    random_expected_loss = sum(cumulative_loss.values()) / len(ARMS)
    return {
        "decision_count": len(decisions),
        "deferred_count": deferred,
        "automatic_coverage": 1.0 - deferred / len(decisions),
        "cumulative_realized_mse": {
            **cumulative_loss,
            "energy_router": router_loss,
            "uniform_random_expected": random_expected_loss,
            "hindsight_oracle": oracle_loss,
        },
        "cumulative_regret_to_hindsight_oracle": {
            **{name: cumulative_loss[name] - oracle_loss for name in ARMS},
            "energy_router": router_loss - oracle_loss,
            "uniform_random_expected": random_expected_loss - oracle_loss,
        },
        "decisions": decisions,
    }


def run(
    normal: list[list[float]],
    fault: list[list[float]],
    *,
    train_count: int = 159,
    intervention_index: int = 160,
    latent_width: int = 8,
    infer_steps: int = 20,
    eta_infer: float = 0.03,
    epochs: int = 30,
    batch_size: int = 32,
    learning_rate: float = 1e-3,
    parameter_seed: int = 41,
    state_seed: int = 43,
    defer_margin: float = 0.05,
) -> dict[str, Any]:
    normal_z, fault_z, _, _ = _standardize(normal, fault, train_count)
    train_x = normal_z[: train_count - 1]
    train_y = normal_z[1:train_count]
    fitted = {
        topology: _fit_arm(
            topology,
            train_x,
            train_y,
            latent_width=latent_width,
            infer_steps=infer_steps,
            eta_infer=eta_infer,
            epochs=epochs,
            batch_size=batch_size,
            learning_rate=learning_rate,
            parameter_seed=parameter_seed,
        )
        for topology in ARMS
    }
    normal_eval = _route_timeline(
        fitted,
        normal_z,
        start_index=train_count,
        state_seed=state_seed,
        defer_margin=defer_margin,
    )
    fault_eval = _route_timeline(
        fitted,
        fault_z,
        start_index=intervention_index,
        state_seed=state_seed,
        defer_margin=defer_margin,
    )
    return {
        "schema": SCHEMA,
        "policy": {
            "selection": "minimum final FabricPC inference energy",
            "uses_future_observation_for_selection": False,
            "human_review_if_relative_margin_below": defer_margin,
            "defer_threshold_selected_before_timeline_evaluation": True,
        },
        "training": {
            "normal_only": True,
            "training_observation_count": train_count,
            "epochs": epochs,
            "parameter_seed": parameter_seed,
            "state_seed": state_seed,
        },
        "normal_timeline": normal_eval,
        "fault1_timeline": fault_eval,
        "claims": {
            "causally_ordered_offline_evaluation": True,
            "online_deployment": False,
            "human_review_is_advisory": True,
            "causal_source_identified": False,
            "imagination_identified": False,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--normal-dir", type=Path, required=True)
    parser.add_argument("--fault-dir", type=Path, required=True)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "verification" / "tep_fabricpc_alarm_router.json",
    )
    parser.add_argument("--defer-margin", type=float, default=0.05)
    args = parser.parse_args()
    if not 0.0 <= args.defer_margin < 1.0:
        raise ValueError("defer margin must lie in [0, 1)")
    certificate = run(
        load_run(args.normal_dir),
        load_run(args.fault_dir),
        defer_margin=args.defer_margin,
    )
    args.output.write_text(
        json.dumps(certificate, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"certificate -> {args.output}")
    for timeline in ("normal_timeline", "fault1_timeline"):
        result = certificate[timeline]
        print(
            timeline,
            "coverage=",
            f"{result['automatic_coverage']:.3f}",
            "router_regret=",
            f"{result['cumulative_regret_to_hindsight_oracle']['energy_router']:.4f}",
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
