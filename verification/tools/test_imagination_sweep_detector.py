import unittest

from imagination_sweep_detector import INPUT_SCHEMA, audit


def replicate(replicate_id, residue=0.0, commutator=None):
    result = {
        "replicate_id": replicate_id,
        "base_states": [[0.0]],
        "first_states": [[0.0]],
        "second_states": [[0.0]],
        "combined_states": [[residue]],
    }
    if commutator is not None:
        result["order_ab_states"] = [[commutator]]
        result["order_ba_states"] = [[0.0]]
    return result


def frame(frame_id, *replicates, confounded=False):
    return {
        "frame_id": frame_id,
        "architecture_confound": confounded,
        "replicates": list(replicates),
    }


def payload(*frames):
    return {
        "schema": INPUT_SCHEMA,
        "run_id": "unit-test",
        "thresholds": {
            "residue_norm": 0.1,
            "commutator_norm": 0.1,
            "minimum_frame_hits": 2,
            "minimum_replicate_hits": 2,
        },
        "frames": list(frames),
    }


class ImaginationSweepDetectorTests(unittest.TestCase):
    def test_additive_null_stays_clear(self):
        result = audit(
            payload(
                frame(
                    "a",
                    replicate("a1"),
                    replicate("a2"),
                ),
                frame(
                    "b",
                    replicate("b1"),
                    replicate("b2"),
                ),
            )
        )
        self.assertFalse(
            result["summary"]["screening_candidate"]
        )
        self.assertFalse(
            result["summary"][
                "orientation_sensitive_candidate"
            ]
        )

    def test_one_frame_cannot_manufacture_persistence(self):
        result = audit(
            payload(
                frame(
                    "a",
                    replicate("a1", residue=1.0),
                    replicate("a2", residue=1.0),
                )
            )
        )
        self.assertEqual(
            result["summary"]["replicated_residue_frames"],
            1,
        )
        self.assertFalse(
            result["summary"]["cross_frame_residue_persistent"]
        )

    def test_architecture_confound_blocks_screening(self):
        result = audit(
            payload(
                frame(
                    "a",
                    replicate("a1", residue=1.0),
                    replicate("a2", residue=1.0),
                    confounded=True,
                ),
                frame(
                    "b",
                    replicate("b1", residue=1.0),
                    replicate("b2", residue=1.0),
                    confounded=True,
                ),
            )
        )
        self.assertTrue(
            result["summary"]["cross_frame_residue_persistent"]
        )
        self.assertFalse(
            result["summary"]["screening_candidate"]
        )

    def test_strict_candidate_requires_replicated_order_channel(self):
        result = audit(
            payload(
                frame(
                    "a",
                    replicate(
                        "a1", residue=1.0, commutator=1.0
                    ),
                    replicate(
                        "a2", residue=1.0, commutator=1.0
                    ),
                ),
                frame(
                    "b",
                    replicate(
                        "b1", residue=1.0, commutator=1.0
                    ),
                    replicate(
                        "b2", residue=1.0, commutator=1.0
                    ),
                ),
            )
        )
        self.assertTrue(
            result["summary"]["screening_candidate"]
        )
        self.assertTrue(
            result["summary"][
                "orientation_sensitive_candidate"
            ]
        )
        self.assertFalse(
            result["summary"]["imagination_identified"]
        )
        self.assertFalse(result["method"]["imagination_claim"])

    def test_duplicate_frame_id_is_rejected(self):
        with self.assertRaises(ValueError):
            audit(
                payload(
                    frame("same", replicate("a")),
                    frame("same", replicate("b")),
                )
            )

    def test_minimums_cannot_collapse_to_one(self):
        value = payload(
            frame("a", replicate("a")),
            frame("b", replicate("b")),
        )
        value["thresholds"]["minimum_frame_hits"] = 1
        with self.assertRaises(ValueError):
            audit(value)


if __name__ == "__main__":
    unittest.main()
