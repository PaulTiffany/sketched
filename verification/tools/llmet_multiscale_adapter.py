"""Run the LLMET source-regime sensor across neighboring analysis frames."""
from __future__ import annotations

import argparse
import hashlib
import json
import statistics
from pathlib import Path
from typing import Any

from llmet_regime_sensor import analyze_source

SCHEMA = "sketched.llmet-multiscale-certificate.v1"
DEFAULT_FRAMES = ((80, 40), (160, 80), (320, 160))


def _cluster_candidates(
    candidates: list[dict[str, Any]],
    *,
    radius_lines: int,
) -> list[dict[str, Any]]:
    clusters: list[list[dict[str, Any]]] = []
    for candidate in sorted(
        candidates, key=lambda item: item["line_estimate"]
    ):
        selected: list[dict[str, Any]] | None = None
        for cluster in clusters:
            center = statistics.median(
                item["line_estimate"] for item in cluster
            )
            if abs(candidate["line_estimate"] - center) <= radius_lines:
                selected = cluster
                break
        if selected is None:
            selected = []
            clusters.append(selected)
        selected.append(candidate)

    result: list[dict[str, Any]] = []
    for cluster in clusters:
        frames = sorted({item["frame"] for item in cluster})
        result.append(
            {
                "line_estimate": round(
                    statistics.median(
                        item["line_estimate"] for item in cluster
                    )
                ),
                "supporting_frames": frames,
                "support_count": len(frames),
                "persistent_across_frames": len(frames) >= 2,
                "maximum_distance": max(
                    item["distance"] for item in cluster
                ),
                "members": cluster,
            }
        )
    return sorted(
        result,
        key=lambda item: (
            item["support_count"],
            item["maximum_distance"],
        ),
        reverse=True,
    )


def analyze_multiscale(
    source: str,
    *,
    source_label: str,
    frames: tuple[tuple[int, int], ...] = DEFAULT_FRAMES,
    cluster_radius_lines: int = 200,
) -> dict[str, Any]:
    frame_results: list[dict[str, Any]] = []
    candidates: list[dict[str, Any]] = []
    reference_result: dict[str, Any] | None = None

    for window_lines, stride_lines in frames:
        result = analyze_source(
            source,
            source_label=source_label,
            window_lines=window_lines,
            stride_lines=stride_lines,
        )
        if reference_result is None:
            reference_result = result
        frame_name = f"{window_lines}/{stride_lines}"
        frame_candidates: list[dict[str, Any]] = []
        for transition in result["ranked_transitions"]:
            if not transition["candidate_regime_change"]:
                continue
            candidate = {
                "frame": frame_name,
                "window_lines": window_lines,
                "stride_lines": stride_lines,
                "line_estimate": min(
                    len(source.splitlines()),
                    transition["boundary_line"]
                    + window_lines // 2,
                ),
                "distance": transition["distance"],
                "leading_features": transition["leading_features"],
            }
            candidates.append(candidate)
            frame_candidates.append(candidate)

        top_transitions = []
        for transition in result["ranked_transitions"][:8]:
            top_transitions.append(
                {
                    **transition,
                    "line_estimate": min(
                        len(source.splitlines()),
                        transition["boundary_line"]
                        + window_lines // 2,
                    ),
                }
            )
        frame_results.append(
            {
                "frame": frame_name,
                "window_lines": window_lines,
                "stride_lines": stride_lines,
                "summary": result["summary"],
                "transition_threshold": result["method"][
                    "transition_threshold"
                ],
                "curvature_threshold": result["method"][
                    "curvature_threshold"
                ],
                "candidate_transitions": frame_candidates,
                "top_transitions": top_transitions,
                "top_second_order_changes": result[
                    "ranked_second_order_changes"
                ][:8],
            }
        )

    if reference_result is None:
        raise ValueError("at least one analysis frame is required")
    clusters = _cluster_candidates(
        candidates, radius_lines=cluster_radius_lines
    )
    persistent = [
        cluster
        for cluster in clusters
        if cluster["persistent_across_frames"]
    ]
    return {
        "schema": SCHEMA,
        "source": {
            "label": source_label,
            "sha256": hashlib.sha256(
                source.encode("utf-8")
            ).hexdigest(),
            "bytes_utf8": len(source.encode("utf-8")),
            "line_count": len(source.splitlines()),
            "executed": False,
        },
        "method": {
            "frames": [
                {
                    "window_lines": window,
                    "stride_lines": stride,
                }
                for window, stride in frames
            ],
            "cluster_radius_lines": cluster_radius_lines,
            "persistence_rule": (
                "candidate boundaries supported by at least two frames"
            ),
            "line_order_is_generation_history_claim": False,
            "authorship_claim": False,
            "cognitive_state_claim": False,
            "imagination_claim": False,
            "phase_transition_claim": False,
        },
        "summary": {
            "frame_count": len(frames),
            "candidate_observations": len(candidates),
            "candidate_clusters": len(clusters),
            "persistent_clusters": len(persistent),
            "unreachable_regions": reference_result["summary"][
                "unreachable_regions"
            ],
            "warning_suppressions": reference_result["summary"][
                "warning_suppressions"
            ],
        },
        "static_witnesses": reference_result["static_witnesses"],
        "persistent_clusters": persistent,
        "all_candidate_clusters": clusters,
        "frame_results": frame_results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--source-label", default="LLMET.py")
    parser.add_argument(
        "--cluster-radius-lines",
        type=int,
        default=200,
    )
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    source = args.source.read_text(encoding="utf-8-sig")
    certificate = analyze_multiscale(
        source,
        source_label=args.source_label,
        cluster_radius_lines=args.cluster_radius_lines,
    )
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
