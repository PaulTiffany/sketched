"""Runtime multiframe certificate for the Book 4 imagination detector.

Each frame contains repeated four-branch experiments. The detector delegates
mixed-residue and optional order-commutator measurements to
``second_order_sensor``. It then enforces replication, cross-frame persistence,
and architecture-confound rejection.

The strongest output is an orientation-sensitive *candidate*. The tool never
identifies imagination or a phase transition.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

from second_order_sensor import (
    SCHEMA as SECOND_ORDER_SCHEMA,
    audit as audit_second_order,
)

INPUT_SCHEMA = "sketched.imagination-sweep-input.v1"
OUTPUT_SCHEMA = "sketched.imagination-sweep-certificate.v1"


def _nonnegative_float(value: Any, label: str) -> float:
    result = float(value)
    if not math.isfinite(result) or result < 0:
        raise ValueError(f"{label} must be finite and nonnegative")
    return result


def _minimum(value: Any, label: str) -> int:
    if isinstance(value, bool):
        raise ValueError(f"{label} must be an integer >= 2")
    result = int(value)
    if result != value or result < 2:
        raise ValueError(f"{label} must be an integer >= 2")
    return result


def _settings(payload: dict[str, Any]) -> dict[str, Any]:
    raw = payload.get("thresholds", {})
    if not isinstance(raw, dict):
        raise ValueError("thresholds must be an object")
    residue = _nonnegative_float(
        raw.get("residue_norm", 1e-7),
        "residue_norm",
    )
    commutator = _nonnegative_float(
        raw.get("commutator_norm", residue),
        "commutator_norm",
    )
    return {
        "residue_norm": residue,
        "commutator_norm": commutator,
        "minimum_frame_hits": _minimum(
            raw.get("minimum_frame_hits", 2),
            "minimum_frame_hits",
        ),
        "minimum_replicate_hits": _minimum(
            raw.get("minimum_replicate_hits", 2),
            "minimum_replicate_hits",
        ),
    }


def _replicate_payload(
    root: dict[str, Any],
    frame: dict[str, Any],
    replicate: dict[str, Any],
    settings: dict[str, Any],
) -> dict[str, Any]:
    result = {
        "schema": SECOND_ORDER_SCHEMA,
        "run_id": (
            f"{root.get('run_id', 'sweep')}/"
            f"{frame['frame_id']}/{replicate['replicate_id']}"
        ),
        "fabricpc_repository": root.get("fabricpc_repository"),
        "fabricpc_commit": root.get("fabricpc_commit"),
        "thresholds": {
            "residue_norm": settings["residue_norm"],
            "commutator_norm": settings["commutator_norm"],
        },
    }
    for key in (
        "base_states",
        "first_states",
        "second_states",
        "combined_states",
        "order_ab_states",
        "order_ba_states",
    ):
        if key in replicate:
            result[key] = replicate[key]
    return result


def audit(payload: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise ValueError("input must be an object")
    if payload.get("schema") != INPUT_SCHEMA:
        raise ValueError(f"input schema must be {INPUT_SCHEMA}")
    frames = payload.get("frames")
    if not isinstance(frames, list) or not frames:
        raise ValueError("frames must be a nonempty array")
    settings = _settings(payload)

    seen_frames: set[str] = set()
    frame_rows: list[dict[str, Any]] = []
    for frame_index, frame in enumerate(frames):
        if not isinstance(frame, dict):
            raise ValueError(f"frames[{frame_index}] must be an object")
        frame_id = frame.get("frame_id")
        if not isinstance(frame_id, str) or not frame_id:
            raise ValueError(f"frames[{frame_index}].frame_id is required")
        if frame_id in seen_frames:
            raise ValueError(f"duplicate frame_id: {frame_id}")
        seen_frames.add(frame_id)
        architecture_confound = frame.get("architecture_confound")
        if not isinstance(architecture_confound, bool):
            raise ValueError(
                f"frame {frame_id} architecture_confound must be boolean"
            )
        replicates = frame.get("replicates")
        if not isinstance(replicates, list) or not replicates:
            raise ValueError(
                f"frame {frame_id} replicates must be a nonempty array"
            )

        seen_replicates: set[str] = set()
        replicate_rows: list[dict[str, Any]] = []
        for replicate_index, replicate in enumerate(replicates):
            if not isinstance(replicate, dict):
                raise ValueError(
                    f"frame {frame_id} replicate {replicate_index} "
                    "must be an object"
                )
            replicate_id = replicate.get("replicate_id")
            if not isinstance(replicate_id, str) or not replicate_id:
                raise ValueError(
                    f"frame {frame_id} replicate_id is required"
                )
            if replicate_id in seen_replicates:
                raise ValueError(
                    f"frame {frame_id} duplicate replicate_id: "
                    f"{replicate_id}"
                )
            seen_replicates.add(replicate_id)

            certificate = audit_second_order(
                _replicate_payload(
                    payload,
                    frame,
                    replicate,
                    settings,
                )
            )
            residue_observed = (
                certificate["steps_with_second_order_residue"] > 0
            )
            order_measured = certificate["method"][
                "order_branches_measured"
            ]
            order_observed = (
                certificate["steps_with_order_dependence"] is not None
                and certificate["steps_with_order_dependence"] > 0
            )
            replicate_rows.append(
                {
                    "replicate_id": replicate_id,
                    "input_sha256": certificate["source"][
                        "input_sha256"
                    ],
                    "residue_observed": residue_observed,
                    "max_residue_norm": certificate[
                        "max_residue_norm"
                    ],
                    "order_measured": order_measured,
                    "order_observed": order_observed,
                    "max_commutator_norm": certificate[
                        "max_commutator_norm"
                    ],
                    "joint_residue_and_order": (
                        residue_observed and order_observed
                    ),
                }
            )

        minimum_replicates = settings["minimum_replicate_hits"]
        residue_hits = sum(
            row["residue_observed"] for row in replicate_rows
        )
        order_hits = sum(
            row["order_observed"] for row in replicate_rows
        )
        joint_hits = sum(
            row["joint_residue_and_order"] for row in replicate_rows
        )
        residue_replicated = residue_hits >= minimum_replicates
        order_replicated = order_hits >= minimum_replicates
        joint_replicated = joint_hits >= minimum_replicates
        frame_rows.append(
            {
                "frame_id": frame_id,
                "frame_metadata": frame.get("frame_metadata"),
                "architecture_confound": architecture_confound,
                "replicate_count": len(replicate_rows),
                "residue_hit_count": residue_hits,
                "order_hit_count": order_hits,
                "joint_hit_count": joint_hits,
                "residue_replicated": residue_replicated,
                "order_replicated": order_replicated,
                "joint_replicated": joint_replicated,
                "unconfounded_residue_hit": (
                    residue_replicated
                    and not architecture_confound
                ),
                "unconfounded_joint_hit": (
                    joint_replicated
                    and not architecture_confound
                ),
                "replicates": replicate_rows,
            }
        )

    minimum_frames = settings["minimum_frame_hits"]
    replicated_residue_frames = sum(
        row["residue_replicated"] for row in frame_rows
    )
    replicated_joint_frames = sum(
        row["joint_replicated"] for row in frame_rows
    )
    unconfounded_residue_frames = sum(
        row["unconfounded_residue_hit"] for row in frame_rows
    )
    unconfounded_joint_frames = sum(
        row["unconfounded_joint_hit"] for row in frame_rows
    )
    cross_frame_residue = (
        replicated_residue_frames >= minimum_frames
    )
    cross_frame_joint = replicated_joint_frames >= minimum_frames
    screening_candidate = (
        cross_frame_residue
        and unconfounded_residue_frames >= minimum_frames
    )
    orientation_sensitive_candidate = (
        cross_frame_joint
        and unconfounded_joint_frames >= minimum_frames
    )

    canonical = json.dumps(
        payload,
        sort_keys=True,
        separators=(",", ":"),
    ).encode()
    return {
        "schema": OUTPUT_SCHEMA,
        "source": {
            "input_sha256": hashlib.sha256(canonical).hexdigest(),
            "run_id": payload.get("run_id"),
            "fabricpc_repository": payload.get(
                "fabricpc_repository"
            ),
            "fabricpc_commit": payload.get("fabricpc_commit"),
        },
        "method": {
            "lean_contract": (
                "ForcingAnalysis.Book4ImaginationDetector"
            ),
            "settings": settings,
            "screening_rule": (
                "replicated mixed residue in at least two distinct, "
                "unconfounded frames"
            ),
            "strict_rule": (
                "screening rule plus replicated order commutator "
                "in the same supporting frames"
            ),
            "imagination_claim": False,
            "phase_transition_claim": False,
            "latent_cause_identified": False,
        },
        "summary": {
            "frame_count": len(frame_rows),
            "replicated_residue_frames": (
                replicated_residue_frames
            ),
            "replicated_joint_frames": replicated_joint_frames,
            "unconfounded_residue_frames": (
                unconfounded_residue_frames
            ),
            "unconfounded_joint_frames": (
                unconfounded_joint_frames
            ),
            "cross_frame_residue_persistent": (
                cross_frame_residue
            ),
            "cross_frame_joint_persistent": cross_frame_joint,
            "screening_candidate": screening_candidate,
            "orientation_sensitive_candidate": (
                orientation_sensitive_candidate
            ),
            "imagination_identified": False,
        },
        "frames": frame_rows,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    payload = json.loads(args.input.read_text(encoding="utf-8"))
    certificate = audit(payload)
    rendered = json.dumps(certificate, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(
            rendered,
            encoding="utf-8",
            newline="\n",
        )
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
