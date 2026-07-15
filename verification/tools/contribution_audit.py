"""Audit reserved authorship regions and their contribution receipts.

This is procedural provenance, not authentication. It proves that the repository
contains the expected boundary, content digest, constraint digest, owner label,
and human-acceptance record. It does not prove that a named actor controlled a
process or key.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
POLICY = ROOT / "contributions" / "policy.json"
RECEIPTS = ROOT / "contributions" / "receipts"


@dataclass(frozen=True)
class BoundaryState:
    boundary: dict[str, Any]
    content_sha256: str
    constraints_sha256: str


def normalized(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n").strip()


def digest(text: str) -> str:
    return hashlib.sha256(normalized(text).encode("utf-8")).hexdigest()


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def extract_region(path: Path, begin: str, end: str) -> str:
    text = path.read_text(encoding="utf-8")
    if text.count(begin) != 1 or text.count(end) != 1:
        raise ValueError(f"{path.relative_to(ROOT)} must contain each boundary marker exactly once")
    before, tail = text.split(begin, 1)
    body, after = tail.split(end, 1)
    if not before or after is None:
        raise ValueError(f"invalid boundary ordering in {path.relative_to(ROOT)}")
    return normalized(body)


def constraint_digest(paths: list[str]) -> str:
    framed: list[str] = []
    for name in paths:
        path = ROOT / name
        framed.append(f"--- {name} ---\n{normalized(path.read_text(encoding='utf-8'))}")
    return digest("\n".join(framed))


def boundary_state(boundary: dict[str, Any]) -> BoundaryState:
    region = boundary["region"]
    body = extract_region(ROOT / boundary["file"], region["begin"], region["end"])
    return BoundaryState(
        boundary=boundary,
        content_sha256=digest(body),
        constraints_sha256=constraint_digest(boundary["constraints"]),
    )


def receipt_files() -> list[Path]:
    return sorted(path for path in RECEIPTS.glob("*.json") if path.name != "EXAMPLE.json")


def matching_receipt(state: BoundaryState) -> tuple[Path, dict[str, Any]] | None:
    boundary = state.boundary
    for path in receipt_files():
        receipt = load_json(path)
        if receipt.get("boundary") != boundary["id"]:
            continue
        if receipt.get("content_sha256") != state.content_sha256:
            continue
        if receipt.get("constraints_sha256") != state.constraints_sha256:
            continue
        return path, receipt
    return None


def validate_receipt(state: BoundaryState, path: Path, receipt: dict[str, Any]) -> list[str]:
    boundary = state.boundary
    errors: list[str] = []
    prefix = str(path.relative_to(ROOT))
    expected = {
        "schema": "sketched.contribution-receipt.v1",
        "boundary": boundary["id"],
        "actor": boundary["owner"],
        "content_sha256": state.content_sha256,
        "constraints_sha256": state.constraints_sha256,
        "status": "accepted",
        "accepted_by": boundary["human_acceptor"],
    }
    for key, value in expected.items():
        if receipt.get(key) != value:
            errors.append(f"{prefix}: {key} must equal {value!r}")
    if not receipt.get("id"):
        errors.append(f"{prefix}: id must be nonempty")
    if not receipt.get("accepted_at"):
        errors.append(f"{prefix}: accepted_at must be nonempty")
    return errors


def audit(policy_path: Path = POLICY) -> list[str]:
    policy = load_json(policy_path)
    errors: list[str] = []
    if policy.get("schema") != "sketched.contribution-policy.v1":
        return ["policy schema must be sketched.contribution-policy.v1"]
    boundaries = policy.get("boundaries")
    if not isinstance(boundaries, list) or not boundaries:
        return ["policy must declare at least one boundary"]
    ids: set[str] = set()
    for boundary in boundaries:
        boundary_id = boundary.get("id", "(missing)")
        if boundary_id in ids:
            errors.append(f"duplicate boundary id: {boundary_id}")
            continue
        ids.add(boundary_id)
        try:
            state = boundary_state(boundary)
        except (KeyError, OSError, ValueError) as exc:
            errors.append(f"{boundary_id}: {exc}")
            continue
        if state.content_sha256 == boundary.get("reserved_sha256"):
            print(f"[RESERVED] {boundary_id}: owner={boundary['owner']}; placeholder intact")
            continue
        match = matching_receipt(state)
        if match is None:
            errors.append(
                f"{boundary_id}: protected content changed without a receipt matching "
                f"content={state.content_sha256} constraints={state.constraints_sha256}"
            )
            continue
        path, receipt = match
        receipt_errors = validate_receipt(state, path, receipt)
        errors.extend(receipt_errors)
        if not receipt_errors:
            print(f"[ACCEPTED] {boundary_id}: {receipt['actor']} / {receipt['id']}")
    return errors


def describe(boundary_id: str) -> int:
    policy = load_json(POLICY)
    boundary = next((b for b in policy["boundaries"] if b["id"] == boundary_id), None)
    if boundary is None:
        print(f"unknown boundary: {boundary_id}")
        return 1
    state = boundary_state(boundary)
    print(json.dumps({
        "boundary": boundary_id,
        "owner": boundary["owner"],
        "content_sha256": state.content_sha256,
        "constraints_sha256": state.constraints_sha256,
        "reserved": state.content_sha256 == boundary["reserved_sha256"],
    }, indent=2))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--describe", metavar="BOUNDARY")
    args = parser.parse_args()
    if args.describe:
        return describe(args.describe)
    errors = audit()
    for error in errors:
        print(f"[CONTRIBUTION_BOUNDARY] {error}")
    print(f"\n{len(errors)} contribution findings.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
