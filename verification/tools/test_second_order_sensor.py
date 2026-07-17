import unittest

from second_order_sensor import SCHEMA, audit


def data(base, first, second, combined, **extra):
    payload = {
        "schema": SCHEMA,
        "base_states": [base],
        "first_states": [first],
        "second_states": [second],
        "combined_states": [combined],
    }
    payload.update(extra)
    return payload


class SecondOrderSensorTests(unittest.TestCase):
    def test_additive_null_has_zero_residue(self):
        result = audit(data([0, 0], [1, 0], [0, 2], [1, 2]))
        self.assertEqual(result["max_residue_norm"], 0)
        self.assertEqual(result["steps_with_second_order_residue"], 0)
        self.assertFalse(result["method"]["imagination_claim"])

    def test_bilinear_positive_control_has_residue(self):
        # Observable includes x*y: F(0,0)=0, F(1,0)=0, F(0,2)=0,
        # F(1,2)=2.
        result = audit(data([0], [0], [0], [2]))
        self.assertEqual(result["max_residue_norm"], 2)
        self.assertEqual(result["steps_with_second_order_residue"], 1)
        self.assertIsNone(result["steps"][0]["interaction_ratio"])

    def test_threshold_is_explicit(self):
        payload = data([0], [0], [0], [0.01])
        payload["thresholds"] = {"residue_norm": 0.1}
        self.assertEqual(audit(payload)["steps_with_second_order_residue"], 0)

    def test_order_commutator_is_separate_observable(self):
        result = audit(
            data(
                [0], [1], [2], [3],
                order_ab_states=[[2]],
                order_ba_states=[[-2]],
                thresholds={"residue_norm": 10, "commutator_norm": 1},
            )
        )
        self.assertTrue(result["method"]["order_branches_measured"])
        self.assertEqual(result["max_commutator_norm"], 4)
        self.assertEqual(result["steps_with_order_dependence"], 1)
        self.assertEqual(result["steps"][0]["commutator"], [4.0])

    def test_partial_order_pair_is_rejected(self):
        with self.assertRaises(ValueError):
            audit(data([0], [1], [0], [1], order_ab_states=[[1]]))

    def test_shape_mismatch_is_rejected(self):
        with self.assertRaises(ValueError):
            audit(data([0], [0, 1], [0], [0]))

    def test_nonfinite_state_is_rejected(self):
        with self.assertRaises(ValueError):
            audit(data([0], [0], [0], [float("nan")]))


if __name__ == "__main__":
    unittest.main()
