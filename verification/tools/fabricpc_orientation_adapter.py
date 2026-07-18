"""Export a paired real-FabricPC inference trace for orientation auditing."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

import jax
import jax.numpy as jnp

from fabricpc.core.activations import SigmoidActivation
from fabricpc.core.inference import InferenceSGD
from fabricpc.core.topology import Edge
from fabricpc.graph_assembly import TaskMap, graph
from fabricpc.graph_initialization import initialize_params
from fabricpc.graph_initialization.state_initializer import initialize_graph_state
from fabricpc.nodes import IdentityNode, Linear
from fabricpc.utils.dashboarding.inference_tracking import (
    run_inference_with_full_history,
)

from fabricpc_orientation_sensor import SCHEMA, audit

ROOT = Path(__file__).resolve().parents[2]
RECEIPT = ROOT / "verification" / "fabricpc_install_receipt.json"


def _checkout_head(checkout: Path) -> str:
    return subprocess.check_output(
        ["git", "-C", str(checkout), "rev-parse", "HEAD"],
        text=True,
        encoding="utf-8",
    ).strip()


def _state_vector(state, node_order: list[str]) -> list[float]:
    values: list[float] = []
    for name in node_order:
        values.extend(float(x) for x in jnp.ravel(state.nodes[name].z_latent))
    return values


def _total_energy(state, node_order: list[str]) -> float:
    return float(sum(jnp.sum(state.nodes[name].energy) for name in node_order))


def run(
    perturbation: float,
    infer_steps: int,
    eta: float,
    parameter_seed: int = 17,
    state_seed: int = 23,
    direction: tuple[float, float] = (1.0, 0.0),
    nonlinear: bool = False,
) -> tuple[dict, dict]:
    receipt = json.loads(RECEIPT.read_text(encoding="utf-8"))
    checkout = ROOT / receipt["source"]["checkout"]
    expected_commit = receipt["source"]["commit"]
    actual_commit = _checkout_head(checkout)
    if actual_commit != expected_commit:
        raise RuntimeError(
            f"FabricPC checkout drift: receipt={expected_commit}, actual={actual_commit}"
        )

    source = IdentityNode(shape=(2,), name="source")
    activation = SigmoidActivation() if nonlinear else None
    hidden = Linear(
        shape=(2,), name="hidden", **({"activation": activation} if activation else {})
    )
    latent = Linear(
        shape=(2,), name="latent", **({"activation": activation} if activation else {})
    )
    structure = graph(
        nodes=[source, hidden, latent],
        edges=[
            Edge(source=source, target=hidden.slot("in")),
            Edge(source=hidden, target=latent.slot("in")),
        ],
        task_map=TaskMap(x=source),
        inference=InferenceSGD(eta_infer=eta, infer_steps=infer_steps),
    )
    params = initialize_params(structure, jax.random.PRNGKey(parameter_seed))
    clamps = {"source": jnp.asarray([[0.25, -0.5]], dtype=jnp.float32)}
    base_initial = initialize_graph_state(
        structure,
        batch_size=1,
        rng_key=jax.random.PRNGKey(state_seed),
        clamps=clamps,
        params=params,
    )
    hidden_state = base_initial.nodes["hidden"]
    direction_array = jnp.asarray(direction, dtype=hidden_state.z_latent.dtype)
    direction_norm = jnp.linalg.norm(direction_array)
    if float(direction_norm) == 0.0:
        raise ValueError("perturbation direction must be nonzero")
    delta = (perturbation * direction_array / direction_norm).reshape(1, 2)
    probe_initial = base_initial._replace(
        nodes={
            **base_initial.nodes,
            "hidden": hidden_state._replace(z_latent=hidden_state.z_latent + delta),
        }
    )

    _, base_history = run_inference_with_full_history(
        params, base_initial, clamps, structure
    )
    _, probe_history = run_inference_with_full_history(
        params, probe_initial, clamps, structure
    )
    base_states = [base_initial, *base_history]
    probe_states = [probe_initial, *probe_history]
    observed_nodes = ["hidden", "latent"]
    payload = {
        "schema": SCHEMA,
        "fabricpc_repository": receipt["source"]["repository"],
        "fabricpc_commit": actual_commit,
        "run_id": (
            f"tiny-paired-inference-seed{parameter_seed}-{state_seed}"
            f"-eta{eta:g}-eps{perturbation:g}-dir{direction[0]:g},{direction[1]:g}"
            f"-nonlinear{int(nonlinear)}"
        ),
        "thresholds": {
            "directional_gain": 1.0,
            "orientation_cosine": 0.0,
            "zero_tolerance": 1e-12,
        },
        "base_states": [_state_vector(s, observed_nodes) for s in base_states],
        "probe_states": [_state_vector(s, observed_nodes) for s in probe_states],
        "fabricpc_observations": {
            "graph": {
                "nodes": ["source", "hidden", "latent"],
                "edges": ["source->hidden:in", "hidden->latent:in"],
                "observed_nodes": observed_nodes,
            },
            "inference": {
                "algorithm": "InferenceSGD",
                "eta_infer": eta,
                "infer_steps": infer_steps,
                "parameter_seed": parameter_seed,
                "state_seed": state_seed,
                "probe_node": "hidden",
                "nonlinear": nonlinear,
                "probe_direction": list(direction),
                "probe_perturbation": [float(x) for x in delta.ravel()],
            },
            "base_energy": [_total_energy(s, observed_nodes) for s in base_states],
            "probe_energy": [_total_energy(s, observed_nodes) for s in probe_states],
        },
    }
    return payload, audit(payload)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export paired FabricPC inference trajectory diagnostics."
    )
    parser.add_argument("--output-dir", type=Path, default=ROOT / "verification")
    parser.add_argument("--perturbation", type=float, default=1e-3)
    parser.add_argument("--infer-steps", type=int, default=12)
    parser.add_argument("--eta", type=float, default=0.05)
    parser.add_argument("--parameter-seed", type=int, default=17)
    parser.add_argument("--state-seed", type=int, default=23)
    parser.add_argument(
        "--direction",
        type=float,
        nargs=2,
        metavar=("X", "Y"),
        default=(1.0, 0.0),
    )
    parser.add_argument("--nonlinear", action="store_true")
    args = parser.parse_args()
    if args.perturbation == 0 or args.infer_steps < 1 or args.eta <= 0:
        raise ValueError("require nonzero perturbation, infer_steps >= 1, eta > 0")

    if args.direction[0] == 0 and args.direction[1] == 0:
        raise ValueError("require a nonzero perturbation direction")
    payload, certificate = run(
        args.perturbation,
        args.infer_steps,
        args.eta,
        parameter_seed=args.parameter_seed,
        state_seed=args.state_seed,
        direction=tuple(args.direction),
        nonlinear=args.nonlinear,
    )
    args.output_dir.mkdir(parents=True, exist_ok=True)
    raw_path = args.output_dir / "fabricpc_orientation_trace.json"
    cert_path = args.output_dir / "fabricpc_orientation_certificate.json"
    raw_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    cert_path.write_text(json.dumps(certificate, indent=2) + "\n", encoding="utf-8")
    print(f"trace -> {raw_path}")
    print(f"certificate -> {cert_path}")
    print(
        f"{certificate['candidate_count']} candidates across "
        f"{certificate['transition_count']} transitions"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
