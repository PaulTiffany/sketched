import unittest

from fabricpc_orientation_sensor import SCHEMA, audit


def payload(base, probe):
    return {
        "schema": SCHEMA,
        "fabricpc_repository": "https://github.com/trueagi-io/FabricPC.git",
        "fabricpc_commit": "b6f64adf9314863ce665085a92d544807d585819",
        "run_id": "unit-test",
        "base_states": base,
        "probe_states": probe,
    }


class OrientationSensorTests(unittest.TestCase):
    def test_contracting_orientation_preserving_pair_is_clear(self):
        result = audit(payload([[0, 0], [0, 0]], [[1, 0], [0.5, 0]]))
        step = result["transitions"][0]
        self.assertEqual(step["directional_gain"], 0.5)
        self.assertEqual(step["orientation_cosine"], 1.0)
        self.assertFalse(step["candidate_transition"])

    def test_gain_breach_is_candidate(self):
        result = audit(payload([[0], [0]], [[1], [1.1]]))
        step = result["transitions"][0]
        self.assertTrue(step["gain_breach"])
        self.assertTrue(step["candidate_transition"])

    def test_orientation_reversal_is_candidate(self):
        result = audit(payload([[0, 0], [0, 0]], [[1, 0], [-0.5, 0]]))
        step = result["transitions"][0]
        self.assertEqual(step["orientation_cosine"], -1.0)
        self.assertTrue(step["orientation_reversal"])

    def test_zero_perturbation_does_not_invent_orientation(self):
        result = audit(payload([[0], [0]], [[0], [1]]))
        step = result["transitions"][0]
        self.assertIsNone(step["directional_gain"])
        self.assertIsNone(step["orientation_cosine"])
        self.assertTrue(step["degenerate_orientation"])
        self.assertFalse(step["candidate_transition"])

    def test_dimension_mismatch_is_rejected(self):
        with self.assertRaises(ValueError):
            audit(payload([[0], [0, 1]], [[1], [1]]))


if __name__ == "__main__":
    unittest.main()
