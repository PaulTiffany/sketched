"""Audit LLMET regime candidates against declared Python boundaries."""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
from pathlib import Path
from typing import Any

SCHEMA = "sketched.llmet-architecture-audit.v1"


def _declarations(tree: ast.AST) -> list[dict[str, Any]]:
    declarations: list[dict[str, Any]] = []
    for node in ast.walk(tree):
        if not isinstance(
            node,
            (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef),
        ):
            continue
        declarations.append(
            {
                "kind": type(node).__name__,
                "name": node.name,
                "start_line": node.lineno,
                "end_line": getattr(node, "end_lineno", node.lineno),
            }
        )
    return sorted(
        declarations,
        key=lambda item: (item["start_line"], -item["end_line"]),
    )


def _nearest_declaration(
    declarations: list[dict[str, Any]],
    line: int,
) -> dict[str, Any] | None:
    if not declarations:
        return None
    declaration = min(
        declarations,
        key=lambda item: abs(item["start_line"] - line),
    )
    return {
        **declaration,
        "distance_to_start": abs(declaration["start_line"] - line),
    }


def _owning_declaration(
    declarations: list[dict[str, Any]],
    line: int,
) -> dict[str, Any] | None:
    owners = [
        declaration
        for declaration in declarations
        if declaration["start_line"] <= line <= declaration["end_line"]
    ]
    if not owners:
        return None
    return min(
        owners,
        key=lambda item: item["end_line"] - item["start_line"],
    )


def audit_architecture(
    source: str,
    multiscale_certificate: dict[str, Any],
    *,
    boundary_tolerance_lines: int = 40,
) -> dict[str, Any]:
    if boundary_tolerance_lines < 0:
        raise ValueError("boundary tolerance must be nonnegative")
    source_sha = hashlib.sha256(source.encode("utf-8")).hexdigest()
    if multiscale_certificate.get("source", {}).get("sha256") != source_sha:
        raise ValueError("multiscale certificate does not match source hash")

    tree = ast.parse(source)
    declarations = _declarations(tree)
    clusters: list[dict[str, Any]] = []
    for cluster in multiscale_certificate.get(
        "persistent_clusters", []
    ):
        line = int(cluster["line_estimate"])
        nearest = _nearest_declaration(declarations, line)
        confounded = (
            nearest is not None
            and nearest["distance_to_start"]
            <= boundary_tolerance_lines
        )
        clusters.append(
            {
                "line_estimate": line,
                "support_count": cluster["support_count"],
                "nearest_declaration": nearest,
                "declared_boundary_confound": confounded,
            }
        )

    unreachable: list[dict[str, Any]] = []
    static_witnesses = multiscale_certificate.get(
        "static_witnesses", {}
    )
    for finding in static_witnesses.get("unreachable_regions", []):
        line = int(finding["start_line"])
        owner = _owning_declaration(declarations, line)
        unreachable.append(
            {
                **finding,
                "owning_declaration": owner,
                "interior_control_flow_witness": (
                    owner is not None and line > owner["start_line"]
                ),
            }
        )

    return {
        "schema": SCHEMA,
        "source": {
            "label": multiscale_certificate["source"]["label"],
            "sha256": source_sha,
            "executed": False,
        },
        "input_certificate_sha256": hashlib.sha256(
            json.dumps(
                multiscale_certificate,
                sort_keys=True,
                separators=(",", ":"),
            ).encode()
        ).hexdigest(),
        "method": {
            "boundary_tolerance_lines": boundary_tolerance_lines,
            "declared_boundary_confound_rule": (
                "cluster center lies within tolerance of a "
                "function, method, or class start"
            ),
            "regime_change_disproved": False,
            "generation_history_claim": False,
            "cognitive_state_claim": False,
            "imagination_claim": False,
        },
        "summary": {
            "declarations": len(declarations),
            "persistent_clusters": len(clusters),
            "clusters_near_declared_boundaries": sum(
                item["declared_boundary_confound"]
                for item in clusters
            ),
            "interior_unreachable_witnesses": sum(
                item["interior_control_flow_witness"]
                for item in unreachable
            ),
        },
        "persistent_cluster_audit": clusters,
        "unreachable_witness_audit": unreachable,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("multiscale_certificate", type=Path)
    parser.add_argument(
        "--boundary-tolerance-lines",
        type=int,
        default=40,
    )
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    source = args.source.read_text(encoding="utf-8-sig")
    multiscale = json.loads(
        args.multiscale_certificate.read_text(encoding="utf-8")
    )
    certificate = audit_architecture(
        source,
        multiscale,
        boundary_tolerance_lines=args.boundary_tolerance_lines,
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
