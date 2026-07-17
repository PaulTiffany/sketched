"""Check that stored imagination-sweep certificates are reproducible.

This audit is intentionally non-mutating. It rebuilds the FabricPC calibration
input and four detector/attribution certificates in memory, compares them with the committed JSON,
and checks the expected epistemic boundary:

* the synthetic control reaches both candidate predicates;
* the current FabricPC calibration reaches neither; and
* neither imagination certificate identifies a latent cause; and
* attribution controls preserve their declared observer-policy polarity.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from consciousness_attribution_sensor import audit as audit_attribution
from fabricpc_imagination_adapter import build_payload
from imagination_sweep_detector import audit

ROOT = Path(__file__).resolve().parents[2]
VERIFICATION = ROOT / "verification"


def _load(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _compare(
    findings: list[str],
    label: str,
    expected: dict[str, Any],
    stored: dict[str, Any],
) -> None:
    if stored != expected:
        findings.append(
            f"[STALE] {label}: regenerate the stored artifact"
        )


def audit_artifacts(root: Path = ROOT) -> list[str]:
    verification = root / "verification"
    findings: list[str] = []

    linear = _load(
        verification / "fabricpc_second_order_trace.json"
    )
    nonlinear = _load(
        verification
        / "fabricpc_second_order_nonlinear_trace.json"
    )
    expected_fabric_input = build_payload(linear, nonlinear)
    stored_fabric_input = _load(
        verification / "fabricpc_imagination_sweep_input.json"
    )
    _compare(
        findings,
        "FabricPC imagination-sweep input",
        expected_fabric_input,
        stored_fabric_input,
    )

    expected_fabric_certificate = audit(expected_fabric_input)
    stored_fabric_certificate = _load(
        verification
        / "fabricpc_imagination_sweep_certificate.json"
    )
    _compare(
        findings,
        "FabricPC imagination-sweep certificate",
        expected_fabric_certificate,
        stored_fabric_certificate,
    )

    positive_input = _load(
        verification
        / "imagination_sweep_positive_control_input.json"
    )
    expected_positive_certificate = audit(positive_input)
    stored_positive_certificate = _load(
        verification
        / "imagination_sweep_positive_control_certificate.json"
    )
    _compare(
        findings,
        "imagination-sweep positive-control certificate",
        expected_positive_certificate,
        stored_positive_certificate,
    )

    fabric_summary = expected_fabric_certificate["summary"]
    if (
        fabric_summary["screening_candidate"]
        or fabric_summary["orientation_sensitive_candidate"]
    ):
        findings.append(
            "[CALIBRATION] FabricPC control unexpectedly reached "
            "a candidate predicate"
        )

    positive_summary = expected_positive_certificate["summary"]
    if not (
        positive_summary["screening_candidate"]
        and positive_summary["orientation_sensitive_candidate"]
    ):
        findings.append(
            "[CONTROL] synthetic control failed to reach both "
            "candidate predicates"
        )

    for label, summary in (
        ("FabricPC", fabric_summary),
        ("synthetic control", positive_summary),
    ):
        if summary["imagination_identified"]:
            findings.append(
                f"[OVERCLAIM] {label} certificate identifies imagination"
            )

    attribution_controls = (
        ("consciousness_attribution_positive_control", True),
        ("consciousness_attribution_withholding_control", False),
    )
    for stem, expected_attribution in attribution_controls:
        attribution_input = _load(
            verification / f"{stem}_input.json"
        )
        expected_attribution_certificate = audit_attribution(
            attribution_input
        )
        stored_attribution_certificate = _load(
            verification / f"{stem}_certificate.json"
        )
        _compare(
            findings,
            stem.replace("_", " ") + " certificate",
            expected_attribution_certificate,
            stored_attribution_certificate,
        )
        attribution_summary = expected_attribution_certificate[
            "summary"
        ]
        if not attribution_summary["operationally_detected"]:
            findings.append(
                f"[CONTROL] {stem} lost operational detection"
            )
        if (
            attribution_summary["attributes_consciousness"]
            is not expected_attribution
        ):
            findings.append(
                f"[CONTROL] {stem} has the wrong attribution polarity"
            )
        method = expected_attribution_certificate["method"]
        if (
            method["direct_qualia_access_claim"]
            or method["hidden_substance_claim"]
            or method["execution_authority_claim"]
        ):
            findings.append(
                f"[OVERCLAIM] {stem} exceeds operational attribution"
            )

    return findings


def main() -> int:
    findings = audit_artifacts()
    for finding in findings:
        print(finding)
    print(
        f"{len(findings)} imagination-certificate findings; "
        "4 certificates checked"
    )
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
