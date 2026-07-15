from __future__ import annotations

import unittest
from unittest.mock import patch

import contribution_audit as audit


class ContributionAuditTests(unittest.TestCase):
    def setUp(self) -> None:
        self.boundary = {
            "id": "eula-content-b",
            "file": "EULA.md",
            "owner": "OmegaClaw",
            "human_acceptor": "human",
            "constraints": ["docs/14_EULA_MATH_BRIEF.md"],
            "reserved_sha256": "reserved",
            "region": {"begin": "begin", "end": "end"},
        }

    def test_repository_reserved_state_is_clean(self) -> None:
        self.assertEqual(audit.audit(), [])

    def test_digest_normalizes_line_endings_and_outer_space(self) -> None:
        self.assertEqual(audit.digest("  hello\r\nworld  "), audit.digest("hello\nworld"))

    def test_changed_content_without_receipt_is_rejected(self) -> None:
        state = audit.BoundaryState(self.boundary, "changed", "constraints")
        with (
            patch.object(audit, "boundary_state", return_value=state),
            patch.object(audit, "matching_receipt", return_value=None),
        ):
            errors = audit.audit()
        self.assertTrue(any("changed without a receipt" in error for error in errors))

    def test_receipt_requires_owner_and_human_acceptance(self) -> None:
        state = audit.BoundaryState(self.boundary, "changed", "constraints")
        proposed = {
            "schema": "sketched.contribution-receipt.v1",
            "id": "oc-1",
            "boundary": "eula-content-b",
            "actor": "OmegaClaw",
            "content_sha256": "changed",
            "constraints_sha256": "constraints",
            "status": "proposed",
            "accepted_by": None,
            "accepted_at": None,
        }
        receipt_path = audit.ROOT / "receipt.json"
        errors = audit.validate_receipt(state, receipt_path, proposed)
        self.assertTrue(any("status" in error for error in errors))
        self.assertTrue(any("accepted_by" in error for error in errors))
        self.assertTrue(any("accepted_at" in error for error in errors))

        accepted = {
            **proposed,
            "status": "accepted",
            "accepted_by": "human",
            "accepted_at": "human-supplied timestamp",
        }
        self.assertEqual(audit.validate_receipt(state, receipt_path, accepted), [])


if __name__ == "__main__":
    unittest.main()
