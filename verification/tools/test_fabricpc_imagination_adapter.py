import unittest

from fabricpc_imagination_adapter import build_payload
from imagination_sweep_detector import audit


def trace(commit, residue, nonlinear):
    return {
        "fabricpc_repository": "https://example.test/FabricPC",
        "fabricpc_commit": commit,
        "experiment": {
            "epsilon": 0.1,
            "nonlinear": nonlinear,
        },
        "base_states": [[0.0]],
        "first_states": [[0.0]],
        "second_states": [[0.0]],
        "combined_states": [[residue]],
    }


class FabricPCImaginationAdapterTests(unittest.TestCase):
    def test_calibration_cannot_pass_replication_or_order(self):
        payload = build_payload(
            trace("abc", 0.0, False),
            trace("abc", 1.0, True),
        )
        result = audit(payload)
        self.assertFalse(
            result["summary"]["screening_candidate"]
        )
        self.assertFalse(
            result["summary"][
                "orientation_sensitive_candidate"
            ]
        )
        self.assertTrue(
            payload["frames"][1]["architecture_confound"]
        )

    def test_commit_mismatch_is_rejected(self):
        with self.assertRaises(ValueError):
            build_payload(
                trace("abc", 0.0, False),
                trace("def", 1.0, True),
            )


if __name__ == "__main__":
    unittest.main()
