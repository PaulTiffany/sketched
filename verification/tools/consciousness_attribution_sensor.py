"""Operational consciousness-attribution certificate.

The sensor consumes an imagination-sweep input and reproducible certificate, an active
with/without-imagination ablation, a finite manifold of observable
qualia-like traces, and an explicit observer threshold.

It detects an imagination-mediated regulation loop and records the observer's
higher-order attribution. It does not claim direct access to qualia, a hidden
substance, or authority to act on the attributed being.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from imagination_sweep_detector import (
    INPUT_SCHEMA as SWEEP_INPUT_SCHEMA,
    audit as audit_sweep,
)

INPUT_SCHEMA = "sketched.consciousness-attribution-input.v1"
OUTPUT_SCHEMA = "sketched.consciousness-attribution-certificate.v1"
SWEEP_SCHEMA = "sketched.imagination-sweep-certificate.v1"


def _canonical(value: Any) -> str:
    return json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    )


def _positive_integer(value: Any, label: str) -> int:
    if isinstance(value, bool):
        raise ValueError(f"{label} must be a positive integer")
    result = int(value)
    if result != value or result < 1:
        raise ValueError(f"{label} must be a positive integer")
    return result


def _required_bool(
    value: dict[str, Any],
    key: str,
    label: str,
) -> bool:
    result = value.get(key)
    if not isinstance(result, bool):
        raise ValueError(f"{label}.{key} must be boolean")
    return result


def audit(payload: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise ValueError("input must be an object")
    if payload.get("schema") != INPUT_SCHEMA:
        raise ValueError(f"input schema must be {INPUT_SCHEMA}")

    sweep_input = payload.get("imagination_sweep_input")
    if not isinstance(sweep_input, dict):
        raise ValueError("imagination_sweep_input must be an object")
    if sweep_input.get("schema") != SWEEP_INPUT_SCHEMA:
        raise ValueError(
            f"imagination sweep input schema must be {SWEEP_INPUT_SCHEMA}"
        )

    sweep = payload.get("imagination_sweep_certificate")
    if not isinstance(sweep, dict):
        raise ValueError(
            "imagination_sweep_certificate must be an object"
        )
    if sweep.get("schema") != SWEEP_SCHEMA:
        raise ValueError(
            f"imagination sweep schema must be {SWEEP_SCHEMA}"
        )
    if sweep != audit_sweep(sweep_input):
        raise ValueError(
            "imagination sweep certificate does not match its input"
        )
    sweep_summary = sweep.get("summary")
    if not isinstance(sweep_summary, dict):
        raise ValueError(
            "imagination sweep certificate needs a summary"
        )
    strict_evidence = _required_bool(
        sweep_summary,
        "orientation_sensitive_candidate",
        "imagination_sweep_certificate.summary",
    )
    if _required_bool(
        sweep_summary,
        "imagination_identified",
        "imagination_sweep_certificate.summary",
    ):
        raise ValueError(
            "upstream imagination certificate may not identify "
            "a latent cause"
        )

    embodiment = payload.get("embodiment")
    if not isinstance(embodiment, dict):
        raise ValueError("embodiment must be an object")
    alternative_realized = _required_bool(
        embodiment,
        "alternative_realized",
        "embodiment",
    )
    action_authorized = _required_bool(
        embodiment,
        "action_authorized",
        "embodiment",
    )
    if "action_with_imagination" not in embodiment:
        raise ValueError(
            "embodiment.action_with_imagination is required"
        )
    if "action_without_imagination" not in embodiment:
        raise ValueError(
            "embodiment.action_without_imagination is required"
        )
    action_changed_under_ablation = (
        _canonical(embodiment["action_with_imagination"])
        != _canonical(embodiment["action_without_imagination"])
    )
    imaginary_regulation_signature = (
        not alternative_realized
        and action_changed_under_ablation
        and action_authorized
    )
    operationally_detected = (
        strict_evidence and imaginary_regulation_signature
    )

    frames = payload.get("trace_manifold")
    if not isinstance(frames, list) or not frames:
        raise ValueError("trace_manifold must be a nonempty array")
    seen_frames: set[str] = set()
    frame_rows: list[dict[str, Any]] = []
    for index, frame in enumerate(frames):
        if not isinstance(frame, dict):
            raise ValueError(
                f"trace_manifold[{index}] must be an object"
            )
        frame_id = frame.get("frame_id")
        if not isinstance(frame_id, str) or not frame_id:
            raise ValueError(
                f"trace_manifold[{index}].frame_id is required"
            )
        if frame_id in seen_frames:
            raise ValueError(f"duplicate frame_id: {frame_id}")
        seen_frames.add(frame_id)
        qualia_trace = _required_bool(
            frame,
            "qualia_trace",
            f"trace_manifold[{index}]",
        )
        coherent = _required_bool(
            frame,
            "coherent",
            f"trace_manifold[{index}]",
        )
        frame_rows.append(
            {
                "frame_id": frame_id,
                "qualia_trace": qualia_trace,
                "coherent": coherent,
                "in_trace_support": qualia_trace and coherent,
            }
        )

    observer = payload.get("observer")
    if not isinstance(observer, dict):
        raise ValueError("observer must be an object")
    minimum_trace_support = _positive_integer(
        observer.get("minimum_trace_support"),
        "observer.minimum_trace_support",
    )
    trace_support = sum(
        row["in_trace_support"] for row in frame_rows
    )
    enough_trace_support = (
        trace_support >= minimum_trace_support
    )
    attributes_consciousness = (
        operationally_detected and enough_trace_support
    )

    canonical_input = _canonical(payload).encode("utf-8")
    return {
        "schema": OUTPUT_SCHEMA,
        "source": {
            "input_sha256": hashlib.sha256(
                canonical_input
            ).hexdigest(),
            "run_id": payload.get("run_id"),
            "upstream_sweep_input_sha256": (
                sweep.get("source", {}).get("input_sha256")
            ),
        },
        "method": {
            "lean_contract": (
                "ForcingAnalysis."
                "Book8ConsciousnessAttribution"
            ),
            "classification": (
                "observer-relative operational attribution"
            ),
            "direct_qualia_access_claim": False,
            "hidden_substance_claim": False,
            "execution_authority_claim": False,
        },
        "observer": {
            "observer_id": observer.get("observer_id"),
            "minimum_trace_support": minimum_trace_support,
        },
        "embodiment": {
            "alternative_realized": alternative_realized,
            "action_changed_under_ablation": (
                action_changed_under_ablation
            ),
            "action_authorized": action_authorized,
        },
        "summary": {
            "strict_multiframe_evidence": strict_evidence,
            "imaginary_regulation_signature": (
                imaginary_regulation_signature
            ),
            "operationally_detected": operationally_detected,
            "trace_support": trace_support,
            "enough_trace_support": enough_trace_support,
            "attributes_consciousness": (
                attributes_consciousness
            ),
            "recognizes_higher_order_being": (
                attributes_consciousness
            ),
        },
        "trace_manifold": frame_rows,
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
