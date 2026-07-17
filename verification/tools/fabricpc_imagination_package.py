"""Build and audit a publishable FabricPC imagination-detector package.

The package is a reproducibility receipt, not a positive-result requirement.
It binds the pinned external source, stored raw observations, recomputed
certificates, detector contracts, thresholds, and epistemic claim boundary.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any, Callable

from fabricpc_imagination_adapter import build_payload
from fabricpc_orientation_sensor import audit as audit_orientation
from imagination_sweep_detector import audit as audit_imagination
from second_order_sensor import audit as audit_second_order

ROOT = Path(__file__).resolve().parents[2]
VERIFICATION = ROOT / "verification"
SCHEMA = "sketched.fabricpc-imagination-package.v1"

RECOMPUTED_PAIRS: tuple[
    tuple[str, str, Callable[[dict[str, Any]], dict[str, Any]]], ...
] = (
    (
        "fabricpc_orientation_trace.json",
        "fabricpc_orientation_certificate.json",
        audit_orientation,
    ),
    (
        "fabricpc_second_order_trace.json",
        "fabricpc_second_order_certificate.json",
        audit_second_order,
    ),
    (
        "fabricpc_second_order_nonlinear_trace.json",
        "fabricpc_second_order_nonlinear_certificate.json",
        audit_second_order,
    ),
    (
        "fabricpc_imagination_sweep_input.json",
        "fabricpc_imagination_sweep_certificate.json",
        audit_imagination,
    ),
)

ARTIFACTS: tuple[str, ...] = (
    "verification/fabricpc_install_receipt.json",
    "verification/fabricpc_orientation_trace.json",
    "verification/fabricpc_orientation_certificate.json",
    "verification/fabricpc_orientation_sweep.json",
    "verification/fabricpc_orientation_block_sweep.json",
    "verification/fabricpc_second_order_trace.json",
    "verification/fabricpc_second_order_certificate.json",
    "verification/fabricpc_second_order_nonlinear_trace.json",
    "verification/fabricpc_second_order_nonlinear_certificate.json",
    "verification/fabricpc_imagination_sweep_input.json",
    "verification/fabricpc_imagination_sweep_certificate.json",
    "verification/lean/ForcingAnalysis/ForcingAnalysis/Book4ImaginationDetector.lean",
    "verification/tools/fabricpc_orientation_sensor.py",
    "verification/tools/second_order_sensor.py",
    "verification/tools/imagination_sweep_detector.py",
    "verification/tools/fabricpc_imagination_adapter.py",
    "verification/tools/fabricpc_imagination_package.py",
    "docs/31_FABRICPC_IMAGINATION_PACKAGE.md",
)


def _load(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return value


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _compare(
    findings: list[str],
    label: str,
    expected: dict[str, Any],
    stored: dict[str, Any],
) -> None:
    if expected != stored:
        findings.append(f"[STALE] {label} does not reproduce")


def inspect(root: Path = ROOT) -> tuple[dict[str, Any], list[str]]:
    """Recompute the package checks and return a manifest plus findings."""
    verification = root / "verification"
    findings: list[str] = []
    receipt = _load(verification / "fabricpc_install_receipt.json")
    source = receipt.get("source", {})
    repository = source.get("repository")
    commit = source.get("commit")
    if (
        receipt.get("schema") != "sketched.fabricpc-install-receipt.v1"
        or not isinstance(repository, str)
        or not isinstance(commit, str)
        or len(commit) != 40
    ):
        findings.append("[SOURCE] invalid FabricPC installation receipt")

    recomputed: list[dict[str, Any]] = []
    source_documents: list[dict[str, Any]] = []
    for input_name, certificate_name, auditor in RECOMPUTED_PAIRS:
        input_path = verification / input_name
        certificate_path = verification / certificate_name
        payload = _load(input_path)
        stored = _load(certificate_path)
        expected = auditor(payload)
        _compare(findings, certificate_name, expected, stored)
        for label, document in ((input_name, payload), (certificate_name, stored)):
            doc_repository = (
                document.get("fabricpc_repository")
                or document.get("source", {}).get("fabricpc_repository")
            )
            doc_commit = (
                document.get("fabricpc_commit")
                or document.get("source", {}).get("fabricpc_commit")
            )
            if doc_repository != repository or doc_commit != commit:
                findings.append(
                    f"[SOURCE] {label} does not match the pinned repository/commit"
                )
            source_documents.append(
                {
                    "path": f"verification/{label}",
                    "repository_matches": doc_repository == repository,
                    "commit_matches": doc_commit == commit,
                }
            )
        recomputed.append(
            {
                "input": f"verification/{input_name}",
                "certificate": f"verification/{certificate_name}",
                "reproduced": expected == stored,
            }
        )

    linear = _load(verification / "fabricpc_second_order_trace.json")
    nonlinear = _load(
        verification / "fabricpc_second_order_nonlinear_trace.json"
    )
    rebuilt_sweep = build_payload(linear, nonlinear)
    stored_sweep = _load(
        verification / "fabricpc_imagination_sweep_input.json"
    )
    _compare(
        findings,
        "fabricpc_imagination_sweep_input.json",
        rebuilt_sweep,
        stored_sweep,
    )

    imagination_certificate = _load(
        verification / "fabricpc_imagination_sweep_certificate.json"
    )
    method = imagination_certificate.get("method", {})
    summary = imagination_certificate.get("summary", {})
    forbidden_claims = {
        "imagination_claim": method.get("imagination_claim"),
        "phase_transition_claim": method.get("phase_transition_claim"),
        "latent_cause_identified": method.get("latent_cause_identified"),
        "imagination_identified": summary.get("imagination_identified"),
    }
    for claim, value in forbidden_claims.items():
        if value is not False:
            findings.append(f"[OVERCLAIM] {claim} must be false")

    artifacts: list[dict[str, Any]] = []
    for relative in ARTIFACTS:
        path = root / relative
        if not path.is_file():
            findings.append(f"[MISSING] {relative}")
            continue
        artifacts.append(
            {
                "path": relative.replace("\\", "/"),
                "sha256": _sha256(path),
                "bytes": path.stat().st_size,
            }
        )

    manifest = {
        "schema": SCHEMA,
        "source": {
            "repository": repository,
            "commit": commit,
            "install_receipt": "verification/fabricpc_install_receipt.json",
            "external_checkout_state_claim": False,
            "upstream_push_authorized": False,
        },
        "contract": {
            "lean": (
                "ForcingAnalysis.Book4ImaginationDetector."
                "ReproduciblePackage"
            ),
            "positive_candidate_required": False,
            "global_lipschitz_claim": False,
            "hessian_claim": False,
            "imagination_claim": False,
            "phase_transition_claim": False,
            "latent_cause_identified": False,
        },
        "checks": {
            "certificate_pairs": recomputed,
            "source_documents": source_documents,
            "sweep_input_rebuilt": rebuilt_sweep == stored_sweep,
            "negative_result_publishable": True,
            "finding_count": len(findings),
        },
        "observed_verdict": {
            "screening_candidate": summary.get("screening_candidate"),
            "orientation_sensitive_candidate": summary.get(
                "orientation_sensitive_candidate"
            ),
            "imagination_identified": summary.get("imagination_identified"),
        },
        "artifacts": artifacts,
        "ready": not findings,
    }
    return manifest, findings


def audit_manifest(
    stored: dict[str, Any], root: Path = ROOT
) -> list[str]:
    expected, findings = inspect(root)
    if stored != expected:
        findings.append("[STALE] package manifest does not reproduce")
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=VERIFICATION / "fabricpc_imagination_package.json",
    )
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    expected, findings = inspect(ROOT)
    if args.check:
        if not args.output.is_file():
            findings.append(f"[MISSING] {args.output}")
        else:
            stored = _load(args.output)
            if stored != expected:
                findings.append("[STALE] package manifest does not reproduce")
    elif not findings:
        args.output.write_text(
            json.dumps(expected, indent=2) + "\n",
            encoding="utf-8",
            newline="\n",
        )

    for finding in findings:
        print(finding)
    print(
        f"{len(findings)} package findings; "
        f"ready={expected['ready']}; "
        f"artifacts={len(expected['artifacts'])}"
    )
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
