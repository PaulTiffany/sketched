from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

import binding_audit as audit


def load_repo_state() -> tuple[list[dict], dict[str, str], set[str]]:
    doc = json.loads(audit.BINDINGS.read_text(encoding="utf-8"))
    atlas = json.loads(audit.ATLAS.read_text(encoding="utf-8"))
    shas = {n["id"]: n["statement_sha"] for n in atlas["nodes"]}
    external, unavailable = audit.load_external_shas(doc)
    return doc["bindings"], {**shas, **external}, unavailable


def accepted_receipt(moves: list[tuple[str, str | None, str]]) -> dict:
    return {
        "schema": audit.SCHEMA,
        "id": "attest-test",
        "paper": "test.tex",
        "moves": [{"math_id": m, "from": f, "to": t} for m, f, t in moves],
        "status": "accepted",
        "attested_by": "human",
        "attested_at": "test-supplied",
    }


class BindingAuditTests(unittest.TestCase):
    def test_repository_bound_state_is_clean(self) -> None:
        # skipped is nonzero in packet mode (lean/ and src/ ship separately),
        # so only findings are pinned here.
        bindings, shas, unavailable = load_repo_state()
        receipts, receipt_findings = audit.load_receipts()
        findings, _, _ = audit.audit(bindings, shas, audit.ROOT, receipts)
        self.assertEqual(receipt_findings, [])
        self.assertEqual(findings, [])

    def test_statement_change_is_stale(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        target = bindings[0]["math_id"]
        shas = {**shas, target: "0" * 12}  # the paper's statement moved
        findings, _, _ = audit.audit(bindings, shas, audit.ROOT)
        self.assertTrue(any(code == "BINDING_STALE" and target in msg for code, msg in findings))

    def test_removed_node_is_unknown(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        target = bindings[0]["math_id"]
        shas = {k: v for k, v in shas.items() if k != target}
        findings, _, _ = audit.audit(bindings, shas, audit.ROOT)
        self.assertTrue(any(code == "BINDING_NODE_UNKNOWN" for code, msg in findings))

    def test_missing_marker_is_a_finding(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        forged = [{**bindings[0], "declares": "no_such_marker_xyz"}]
        forged[0].pop("attested_in", None)
        findings, _, _ = audit.audit(forged, shas, audit.ROOT)
        self.assertEqual([code for code, _ in findings], ["BINDING_DECL_MISSING"])

    def test_absent_tree_skips_instead_of_failing(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        with tempfile.TemporaryDirectory() as tmp:
            findings, skipped, _ = audit.audit(bindings, shas, Path(tmp))
        self.assertEqual(findings, [])
        self.assertEqual(skipped, len(bindings))

    def test_attested_in_must_name_an_accepted_receipt(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        forged = [{**bindings[0], "attested_in": "attest-nowhere"}]
        findings, _, _ = audit.audit(forged, shas, audit.ROOT, receipts={})
        self.assertTrue(any(code == "ATTEST_INVALID" for code, _ in findings))
        proposed = {"attest-nowhere": {"status": "proposed"}}
        findings, _, _ = audit.audit(forged, shas, audit.ROOT, receipts=proposed)
        self.assertTrue(any(code == "ATTEST_INVALID" for code, _ in findings))

    def test_unattested_anchors_are_reserved_not_findings(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        forged = [dict(b) for b in bindings]
        for b in forged:
            b.pop("attested_in", None)
        findings, _, unattested = audit.audit(forged, shas, audit.ROOT)
        self.assertEqual(findings, [])
        self.assertEqual(unattested, len(forged))

    def test_pending_moves_are_distinct_and_complete(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        target = bindings[0]["math_id"]
        old = bindings[0]["statement_sha"]
        moved = {**shas, target: "f" * 12}
        moves = audit.pending_moves(bindings, moved)
        self.assertEqual(moves, [(target, old, "f" * 12)])

    def test_stamp_requires_exact_covering_receipt(self) -> None:
        moves = [("lem:a", "1" * 12, "2" * 12), ("lem:b", "3" * 12, "4" * 12)]
        self.assertIsNone(audit.covering_receipt(moves, {}))
        partial = accepted_receipt(moves[:1])
        self.assertIsNone(audit.covering_receipt(moves, {partial["id"]: partial}))
        unsigned = accepted_receipt(moves)
        unsigned["status"] = "proposed"
        self.assertIsNone(audit.covering_receipt(moves, {unsigned["id"]: unsigned}))
        exact = accepted_receipt(moves)
        self.assertIs(audit.covering_receipt(moves, {exact["id"]: exact}), exact)

    def test_apply_stamp_moves_anchor_and_records_receipt(self) -> None:
        binding = {"artifact": "a", "declares": "d", "math_id": "lem:a",
                   "statement_sha": "1" * 12}
        receipt = accepted_receipt([("lem:a", "1" * 12, "2" * 12)])
        log = audit.apply_stamp([binding], receipt, {"lem:a": "2" * 12})
        self.assertEqual(len(log), 1)
        self.assertEqual(binding["statement_sha"], "2" * 12)
        self.assertEqual(binding["attested_in"], "attest-test")

    def test_adopt_records_receipt_on_covered_anchors_only(self) -> None:
        covered = {"artifact": "a", "declares": "d", "math_id": "lem:a",
                   "statement_sha": "2" * 12}
        uncovered = {"artifact": "b", "declares": "d", "math_id": "lem:b",
                     "statement_sha": "9" * 12}
        receipt = accepted_receipt([("lem:a", None, "2" * 12)])
        n = audit.adopt([covered, uncovered], receipt)
        self.assertEqual(n, 1)
        self.assertEqual(covered["attested_in"], "attest-test")
        self.assertNotIn("attested_in", uncovered)

    def test_absent_statement_source_skips_instead_of_failing(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        external = [b for b in bindings if b.get("source")]
        self.assertTrue(external, "expected cross-repo bindings to exist")
        # simulate the principia atlas being absent on this machine
        findings, skipped, _ = audit.audit(
            external, shas, audit.ROOT, unavailable={"principia"})
        self.assertEqual(findings, [])
        self.assertEqual(skipped, len(external))

    def test_external_statement_drift_is_stale(self) -> None:
        bindings, shas, unavailable = load_repo_state()
        ext = next((b for b in bindings if b.get("source")), None)
        self.assertIsNotNone(ext)
        if ext["math_id"] in shas:  # principia atlas present on this machine
            moved = {**shas, ext["math_id"]: "0" * 12}
            findings, _, _ = audit.audit([ext], moved, audit.ROOT)
            self.assertTrue(any(code == "BINDING_STALE" for code, _ in findings))

    def test_acceptance_fields_are_human_only(self) -> None:
        receipt = accepted_receipt([("lem:a", None, "2" * 12)])
        self.assertEqual(audit.validate_receipt(receipt), [])
        agent_signed = {**receipt, "attested_by": "Fable"}
        self.assertTrue(audit.validate_receipt(agent_signed))
        undated = {**receipt, "attested_at": None}
        self.assertTrue(audit.validate_receipt(undated))
        unsigned = {**receipt, "status": "proposed", "attested_by": None,
                    "attested_at": None}
        self.assertEqual(audit.validate_receipt(unsigned), [])


if __name__ == "__main__":
    unittest.main()
