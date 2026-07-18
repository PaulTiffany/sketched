"""Train controlled FabricPC next-state models on Tennessee Eastman data.

This is the predictive-coding layer of the trajectory probe.  It learns only
from the paired normal run, then compares the same normal/fault observation
under three graph topologies with matched node widths and edge counts:

* ``process`` follows the coarse Tennessee Eastman material-flow graph;
* ``dense`` uses a deliberately mixing six-edge topology;
* ``shuffled`` preserves the process arm's degree of connectivity while
  permuting its internal destinations.

The result is a screening certificate, not a causal or consciousness claim.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path
from typing import Any

import jax
import jax.numpy as jnp
import optax

from fabricpc.core.activations import IdentityActivation
from fabricpc.core.inference import InferenceSGD
from fabricpc.core.topology import Edge
from fabricpc.graph_assembly import TaskMap, graph
from fabricpc.graph_initialization import initialize_params
from fabricpc.graph_initialization.state_initializer import (
    NodeDistributionStateInit,
    initialize_graph_state,
)
from fabricpc.nodes import IdentityNode, Linear
from fabricpc.training import train_step
from fabricpc.utils.dashboarding.inference_tracking import (
    run_inference_with_history,
    unstack_inference_history,
)

from tep_trajectory_probe import BLOCKS, load_run

ROOT = Path(__file__).resolve().parents[2]
RECEIPT = ROOT / "verification" / "fabricpc_install_receipt.json"
SCHEMA = "sketched.tep-fabricpc-predictive-coding.v1"

BLOCK_NAMES = tuple(BLOCKS)
PROCESS_EDGES = (
    ("feed", "reactor"),
    ("reactor", "separator"),
    ("separator", "recycle_compressor"),
    ("recycle_compressor", "reactor"),
    ("separator", "stripper"),
    ("stripper", "composition_analyzers"),
)
DENSE_EDGES = (
    ("feed", "recycle_compressor"),
    ("feed", "reactor"),
    ("feed", "separator"),
    ("feed", "stripper"),
    ("feed", "composition_analyzers"),
    ("recycle_compressor", "composition_analyzers"),
)
SHUFFLED_EDGES = (
    ("feed", "separator"),
    ("reactor", "stripper"),
    ("separator", "composition_analyzers"),
    ("recycle_compressor", "separator"),
    ("separator", "reactor"),
    ("stripper", "recycle_compressor"),
)


def _checkout_head(checkout: Path) -> str:
    return subprocess.check_output(
        ["git", "-C", str(checkout), "rev-parse", "HEAD"],
        text=True,
        encoding="utf-8",
    ).strip()


def _sha256_json(value: Any) -> str:
    payload = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(payload).hexdigest()


def _standardize(
    normal: list[list[float]], fault: list[list[float]], train_count: int
) -> tuple[jnp.ndarray, jnp.ndarray, list[float], list[float]]:
    train = jnp.asarray(normal[:train_count], dtype=jnp.float32)
    mean = jnp.mean(train, axis=0)
    scale = jnp.std(train, axis=0, ddof=1)
    positive = scale[scale > 0]
    floor = jnp.min(positive) * 1e-6 if positive.size else 1e-12
    scale = jnp.maximum(scale, floor)
    return (
        (jnp.asarray(normal, dtype=jnp.float32) - mean) / scale,
        (jnp.asarray(fault, dtype=jnp.float32) - mean) / scale,
        [float(x) for x in mean],
        [float(x) for x in scale],
    )


def _build_structure(
    topology: str, *, latent_width: int, infer_steps: int, eta_infer: float
):
    source = IdentityNode(shape=(53,), name="source")
    blocks = {
        name: Linear(
            shape=(latent_width,),
            name=name,
            activation=IdentityActivation(),
        )
        for name in BLOCK_NAMES
    }
    output = Linear(shape=(53,), name="next_state", activation=IdentityActivation())
    internal = {
        "process": PROCESS_EDGES,
        "dense": DENSE_EDGES,
        "shuffled": SHUFFLED_EDGES,
    }[topology]
    edges = [Edge(source=source, target=node.slot("in")) for node in blocks.values()]
    edges.extend(
        Edge(source=blocks[left], target=blocks[right].slot("in"))
        for left, right in internal
    )
    edges.extend(
        Edge(source=node, target=output.slot("in")) for node in blocks.values()
    )
    return graph(
        nodes=[source, *blocks.values(), output],
        edges=edges,
        task_map=TaskMap(x=source, y=output),
        graph_state_initializer=NodeDistributionStateInit(),
        inference=InferenceSGD(eta_infer=eta_infer, infer_steps=infer_steps),
    )


def _train(
    structure,
    x: jnp.ndarray,
    y: jnp.ndarray,
    *,
    seed: int,
    epochs: int,
    batch_size: int,
    learning_rate: float,
):
    params = initialize_params(structure, jax.random.PRNGKey(seed))
    optimizer = optax.adam(learning_rate)
    opt_state = optimizer.init(params)
    energies: list[float] = []
    key = jax.random.PRNGKey(seed + 1)
    step = jax.jit(lambda p, o, b, k: train_step(p, o, b, structure, optimizer, k))
    for _epoch in range(epochs):
        epoch_energy = 0.0
        batch_count = 0
        for start in range(0, len(x), batch_size):
            key, batch_key = jax.random.split(key)
            batch = {
                "x": x[start : start + batch_size],
                "y": y[start : start + batch_size],
            }
            params, opt_state, energy, _ = step(params, opt_state, batch, batch_key)
            epoch_energy += float(energy)
            batch_count += 1
        energies.append(epoch_energy / batch_count)
    return params, energies


def _history(
    params,
    structure,
    observation: jnp.ndarray,
    *,
    state_seed: int,
) -> list[dict[str, dict[str, float]]]:
    clamps = {"source": observation.reshape(1, 53)}
    initial = initialize_graph_state(
        structure,
        batch_size=1,
        rng_key=jax.random.PRNGKey(state_seed),
        clamps=clamps,
        params=params,
    )
    final, stacked = run_inference_with_history(params, initial, clamps, structure)
    return (
        unstack_inference_history(stacked),
        [float(x) for x in jnp.ravel(final.nodes["next_state"].z_latent)],
    )


def _mse(prediction: list[float], target: jnp.ndarray) -> float:
    predicted = jnp.asarray(prediction, dtype=target.dtype)
    return float(jnp.mean(jnp.square(predicted - target)))


def _compare_histories(
    normal: list[dict[str, dict[str, float]]],
    fault: list[dict[str, dict[str, float]]],
) -> dict[str, Any]:
    timeline = []
    for step, (base, probe) in enumerate(zip(normal, fault, strict=True), start=1):
        block_delta = {
            name: abs(probe[name]["energy"] - base[name]["energy"])
            for name in BLOCK_NAMES
        }
        total = sum(block_delta.values())
        shares = {
            name: (value / total if total > 0 else 0.0)
            for name, value in block_delta.items()
        }
        concentration = sum(value * value for value in shares.values())
        timeline.append(
            {
                "inference_step": step,
                "block_energy_delta": block_delta,
                "dominant_block": max(block_delta, key=block_delta.get),
                "dominant_share": max(shares.values()),
                "concentration": concentration,
                "effective_block_count": (
                    1.0 / concentration if concentration > 0 else 0.0
                ),
            }
        )
    return {
        "timeline": timeline,
        "final": timeline[-1],
        "mean_effective_block_count": sum(
            item["effective_block_count"] for item in timeline
        )
        / len(timeline),
    }


def run_experiment(
    normal: list[list[float]],
    fault: list[list[float]],
    *,
    intervention_index: int = 160,
    train_count: int = 159,
    latent_width: int = 8,
    infer_steps: int = 20,
    eta_infer: float = 0.03,
    epochs: int = 30,
    batch_size: int = 32,
    learning_rate: float = 1e-3,
    parameter_seed: int = 41,
    state_seed: int = 43,
) -> dict[str, Any]:
    if len(normal) != len(fault) or len(normal) <= intervention_index:
        raise ValueError("need equal paired trajectories through intervention")
    if not 2 <= train_count < intervention_index:
        raise ValueError("training must use only pre-intervention normal observations")
    normal_z, fault_z, means, scales = _standardize(normal, fault, train_count)
    train_x = normal_z[: train_count - 1]
    train_y = normal_z[1:train_count]
    arms: dict[str, Any] = {}
    for topology in ("process", "dense", "shuffled"):
        structure = _build_structure(
            topology,
            latent_width=latent_width,
            infer_steps=infer_steps,
            eta_infer=eta_infer,
        )
        params, energies = _train(
            structure,
            train_x,
            train_y,
            seed=parameter_seed,
            epochs=epochs,
            batch_size=batch_size,
            learning_rate=learning_rate,
        )
        normal_history, normal_prediction = _history(
            params,
            structure,
            normal_z[intervention_index],
            state_seed=state_seed,
        )
        fault_history, fault_prediction = _history(
            params,
            structure,
            fault_z[intervention_index],
            state_seed=state_seed,
        )
        arms[topology] = {
            "internal_edges": [
                list(edge)
                for edge in {
                    "process": PROCESS_EDGES,
                    "dense": DENSE_EDGES,
                    "shuffled": SHUFFLED_EDGES,
                }[topology]
            ],
            "training_energy": energies,
            "normal_next_state_mse": _mse(
                normal_prediction, normal_z[intervention_index + 1]
            ),
            "fault_next_state_mse": _mse(
                fault_prediction, fault_z[intervention_index + 1]
            ),
            "paired_output_displacement_norm": float(
                jnp.linalg.norm(
                    jnp.asarray(fault_prediction) - jnp.asarray(normal_prediction)
                )
            ),
            "paired_inference": _compare_histories(normal_history, fault_history),
        }

    process = arms["process"]["paired_inference"]
    controls = [
        arms[name]["paired_inference"]["mean_effective_block_count"]
        for name in ("dense", "shuffled")
    ]
    process_count = process["mean_effective_block_count"]
    cumulative_energy = {
        name: sum(arm["training_energy"]) for name, arm in arms.items()
    }
    epoch_oracle_regret = {name: 0.0 for name in arms}
    for epoch in range(epochs):
        epoch_best = min(arm["training_energy"][epoch] for arm in arms.values())
        for name, arm in arms.items():
            epoch_oracle_regret[name] += arm["training_energy"][epoch] - epoch_best
    return {
        "schema": SCHEMA,
        "source": {
            "fabricpc_repository": "https://github.com/trueagi-io/FabricPC.git",
            "fabricpc_commit": json.loads(RECEIPT.read_text(encoding="utf-8"))[
                "source"
            ]["commit"],
            "dataset": "The Tennessee Eastman process (TEP)",
            "dataset_doi": "10.17632/g2st27k8ww.1",
            "dataset_license": "CC BY 4.0",
            "paired_input_sha256": _sha256_json({"normal": normal, "fault": fault}),
        },
        "experiment": {
            "task": "one-step prediction from normal process observations",
            "training_observation_count": train_count,
            "evaluation_sample_index": intervention_index,
            "normal_only_training": True,
            "same_parameter_seed_across_arms": True,
            "same_state_seed_across_paired_runs": True,
            "latent_width": latent_width,
            "infer_steps": infer_steps,
            "eta_infer": eta_infer,
            "epochs": epochs,
            "batch_size": batch_size,
            "learning_rate": learning_rate,
            "parameter_seed": parameter_seed,
            "state_seed": state_seed,
            "standardization_mean": means,
            "standardization_scale": scales,
        },
        "arms": arms,
        "comparison": {
            "process_mean_effective_block_count": process_count,
            "control_mean_effective_block_count": sum(controls) / len(controls),
            "process_more_localized_than_both_controls": all(
                process_count < value for value in controls
            ),
            "process_final_dominant_block": process["final"]["dominant_block"],
            "cumulative_training_process_energy": cumulative_energy,
            "training_process_energy_regret_to_per_epoch_oracle": (epoch_oracle_regret),
            "process_zero_training_process_energy_regret": (
                epoch_oracle_regret["process"] == 0.0
            ),
            "regret_scope": (
                "in-sample FabricPC process energy over recorded training epochs; "
                "not held-out prediction regret or causal-localization regret"
            ),
        },
        "claims": {
            "fabricpc_was_trained": True,
            "plant_source_identified": False,
            "causal_identification": False,
            "imagination_identified": False,
            "consciousness_identified": False,
            "topology_comparison_is_exploratory": True,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--normal-dir", type=Path, required=True)
    parser.add_argument("--fault-dir", type=Path, required=True)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "verification" / "tep_fabricpc_predictive_coding.json",
    )
    parser.add_argument("--epochs", type=int, default=30)
    parser.add_argument("--infer-steps", type=int, default=20)
    args = parser.parse_args()

    receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
    checkout = ROOT / receipt["source"]["checkout"]
    actual = _checkout_head(checkout)
    expected = receipt["source"]["commit"]
    if actual != expected:
        raise RuntimeError(f"FabricPC checkout drift: {actual} != {expected}")
    certificate = run_experiment(
        load_run(args.normal_dir),
        load_run(args.fault_dir),
        epochs=args.epochs,
        infer_steps=args.infer_steps,
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(certificate, indent=2) + "\n", encoding="utf-8", newline="\n"
    )
    print(f"certificate -> {args.output}")
    print(json.dumps(certificate["comparison"], indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
