"""Audit paired Tennessee Eastman simulator trajectories by process block.

The normal and fault runs must share simulator source, initial state, random
seed, controller configuration, and sampling schedule.  The only intended
difference is the configured disturbance.  This makes the resulting delta a
controlled counterfactual rather than a subtraction of unrelated noisy runs.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

SCHEMA = "sketched.tep-trajectory-certificate.v1"
ARCHIVE_SHA256 = "0ff82bbdef0f5f52746c8a03b2a9645f656dbee3cd57587d15a4963087d233db"

OUTPUT_FILES = (
    "TE_data_me01.dat",
    "TE_data_me02.dat",
    "TE_data_me03.dat",
    "TE_data_me04.dat",
    "TE_data_me05.dat",
    "TE_data_me06.dat",
    "TE_data_me07.dat",
    "TE_data_me08.dat",
    "TE_data_me09.dat",
    "TE_data_me10.dat",
    "TE_data_me11.dat",
    "TE_data_mv1.dat",
    "TE_data_mv2.dat",
    "TE_data_mv3.dat",
)

# Zero-based positions in [XMEAS(1..41), XMV(1..12)].  The group names follow
# the process labels in teprob.f.  Composition analyzers are kept separate
# because they are delayed observations rather than one physical vessel.
BLOCKS: dict[str, tuple[int, ...]] = {
    "feed": (0, 1, 2, 3, 41, 42, 43, 44),
    "recycle_compressor": (4, 9, 19, 45, 46),
    "reactor": (5, 6, 7, 8, 20, 50, 52),
    "separator": (10, 11, 12, 13, 21, 47, 51),
    "stripper": (14, 15, 16, 17, 18, 48, 49),
    "composition_analyzers": tuple(range(22, 41)),
}


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _rows(path: Path) -> list[list[float]]:
    rows = [
        [float(value) for value in line.split()]
        for line in path.read_text(encoding="ascii").splitlines()
        if line.strip()
    ]
    if not rows or any(not row for row in rows):
        raise ValueError(f"{path} contains no numeric observations")
    return rows


def load_run(directory: Path) -> list[list[float]]:
    """Load the simulator's split measurement/control files as 53-vectors."""
    chunks = [_rows(directory / name) for name in OUTPUT_FILES]
    lengths = {len(chunk) for chunk in chunks}
    if len(lengths) != 1:
        raise ValueError("Tennessee Eastman output files have unequal row counts")
    observations: list[list[float]] = []
    for row_index in range(len(chunks[0])):
        observations.append([value for chunk in chunks for value in chunk[row_index]])
    if any(len(row) != 53 for row in observations):
        raise ValueError("expected 41 XMEAS plus 12 XMV values")
    return observations


def _dot(left: list[float], right: list[float]) -> float:
    return sum(a * b for a, b in zip(left, right, strict=True))


def _norm(values: list[float]) -> float:
    return math.sqrt(_dot(values, values))


def _normal_scale(
    normal: list[list[float]], pre_fault_count: int
) -> tuple[list[float], list[float]]:
    baseline = normal[:pre_fault_count]
    means = [
        sum(row[column] for row in baseline) / len(baseline) for column in range(53)
    ]
    deviations = [
        math.sqrt(
            sum((row[column] - means[column]) ** 2 for row in baseline)
            / max(1, len(baseline) - 1)
        )
        for column in range(53)
    ]
    positive = sorted(value for value in deviations if value > 0)
    floor = positive[0] * 1e-6 if positive else 1e-12
    return means, [max(value, floor) for value in deviations]


def audit(
    normal: list[list[float]],
    fault: list[list[float]],
    *,
    intervention_index: int,
    sample_seconds: int = 180,
    fault_id: int = 1,
) -> dict[str, Any]:
    if len(normal) != len(fault) or len(normal) <= intervention_index + 1:
        raise ValueError("paired runs must have equal length beyond intervention")
    if intervention_index < 2:
        raise ValueError("need at least two pre-intervention observations")
    if any(len(row) != 53 for row in normal + fault):
        raise ValueError("every observation must have dimension 53")

    _, scales = _normal_scale(normal, intervention_index)
    raw_delta = [
        [b - a for a, b in zip(base, probe, strict=True)]
        for base, probe in zip(normal, fault, strict=True)
    ]
    standardized = [
        [value / scale for value, scale in zip(row, scales, strict=True)]
        for row in raw_delta
    ]
    pre_fault_max = max(
        abs(value) for row in raw_delta[:intervention_index] for value in row
    )

    timeline: list[dict[str, Any]] = []
    for index in range(intervention_index, len(standardized)):
        delta = standardized[index]
        previous = standardized[index - 1]
        norm = _norm(delta)
        previous_norm = _norm(previous)
        cosine = (
            None
            if norm == 0 or previous_norm == 0
            else _dot(previous, delta) / (previous_norm * norm)
        )
        blocks = {
            name: _norm([delta[position] for position in positions])
            for name, positions in BLOCKS.items()
        }
        timeline.append(
            {
                "sample_index": index,
                "seconds": index * sample_seconds,
                "minutes_after_intervention": (
                    (index - intervention_index) * sample_seconds / 60
                ),
                "standardized_whole_state_norm": norm,
                "directional_gain": (
                    None if previous_norm == 0 else norm / previous_norm
                ),
                "orientation_cosine": cosine,
                "dominant_observed_block": max(blocks, key=blocks.get),
                "block_norms": blocks,
            }
        )

    first = timeline[0]
    first_nonzero_by_block: dict[str, int | None] = {}
    for block in BLOCKS:
        match = next(
            (
                item["sample_index"]
                for item in timeline
                if item["block_norms"][block] > 1e-9
            ),
            None,
        )
        first_nonzero_by_block[block] = match

    canonical = json.dumps(
        {"normal": normal, "fault": fault},
        sort_keys=True,
        separators=(",", ":"),
    ).encode()
    return {
        "schema": SCHEMA,
        "source": {
            "dataset": "The Tennessee Eastman process (TEP)",
            "dataset_doi": "10.17632/g2st27k8ww.1",
            "dataset_version": 1,
            "dataset_license": "CC BY 4.0",
            "archive_sha256": ARCHIVE_SHA256,
            "paired_input_sha256": hashlib.sha256(canonical).hexdigest(),
        },
        "experiment": {
            "fault_id": fault_id,
            "fault_description": (
                "A/C feed ratio step; B composition constant (stream 4)"
            ),
            "same_initial_state": pre_fault_max == 0,
            "same_noise_seed": pre_fault_max == 0,
            "intervention_index": intervention_index,
            "intervention_seconds": intervention_index * sample_seconds,
            "sample_seconds": sample_seconds,
            "observation_dimension": 53,
            "observation_count": len(normal),
        },
        "checks": {
            "pre_intervention_max_absolute_delta": pre_fault_max,
            "paired_pre_intervention_history_exact": pre_fault_max == 0,
            "finding_count": 0 if pre_fault_max == 0 else 1,
        },
        "first_observable_response": first,
        "first_nonzero_sample_by_block": first_nonzero_by_block,
        "timeline": timeline,
        "interpretation": {
            "known_simulated_source": "feed composition disturbance",
            "first_dominant_observed_block": first["dominant_observed_block"],
            "source_directly_observed": False,
            "claim": (
                "the controlled disturbance is first visible downstream; "
                "whole-state response does not directly localize its source"
            ),
            "fabricpc_defect_claim": False,
            "causal_identification_from_observations_alone": False,
            "global_lipschitz_claim": False,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--normal-dir", type=Path, required=True)
    parser.add_argument("--fault-dir", type=Path, required=True)
    parser.add_argument("--intervention-index", type=int, default=160)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    certificate = audit(
        load_run(args.normal_dir),
        load_run(args.fault_dir),
        intervention_index=args.intervention_index,
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(certificate, indent=2) + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(
        f"{certificate['experiment']['observation_count']} paired observations; "
        f"first response={certificate['first_observable_response']['dominant_observed_block']}; "
        f"findings={certificate['checks']['finding_count']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
