import hashlib
import unittest

from llmet_architecture_audit import (
    SCHEMA,
    audit_architecture,
)


def certificate(source, clusters, unreachable):
    return {
        "source": {
            "label": "synthetic.py",
            "sha256": hashlib.sha256(
                source.encode("utf-8")
            ).hexdigest(),
        },
        "persistent_clusters": clusters,
        "static_witnesses": {
            "unreachable_regions": unreachable,
        },
    }


class LlmetArchitectureAuditTests(unittest.TestCase):
    def test_declared_boundary_is_recorded_as_confound(self):
        source = """\
def first():
    return 1

def second():
    return 2
"""
        result = audit_architecture(
            source,
            certificate(
                source,
                [{"line_estimate": 4, "support_count": 2}],
                [],
            ),
            boundary_tolerance_lines=1,
        )
        self.assertEqual(result["schema"], SCHEMA)
        self.assertEqual(
            result["summary"]["clusters_near_declared_boundaries"],
            1,
        )
        self.assertFalse(result["method"]["imagination_claim"])

    def test_interior_unreachable_witness_is_distinguished(self):
        source = """\
def choose():
    return 1
    print("dead")
"""
        result = audit_architecture(
            source,
            certificate(
                source,
                [],
                [
                    {
                        "kind": "unreachable",
                        "start_line": 3,
                        "end_line": 3,
                    }
                ],
            ),
        )
        witness = result["unreachable_witness_audit"][0]
        self.assertTrue(witness["interior_control_flow_witness"])
        self.assertEqual(
            witness["owning_declaration"]["name"],
            "choose",
        )

    def test_hash_mismatch_is_rejected(self):
        with self.assertRaises(ValueError):
            audit_architecture(
                "x = 1\n",
                {
                    "source": {
                        "label": "wrong.py",
                        "sha256": "0" * 64,
                    }
                },
            )


if __name__ == "__main__":
    unittest.main()
