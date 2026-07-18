import unittest

from tep_trajectory_probe import audit


class TennesseeEastmanTrajectoryProbeTests(unittest.TestCase):
    def test_exact_prefault_pair_and_downstream_response(self):
        normal = [[float(i + j) for j in range(53)] for i in range(5)]
        fault = [row.copy() for row in normal]
        fault[3][6] += 2.0
        fault[4][12] += 3.0

        result = audit(normal, fault, intervention_index=3)

        self.assertTrue(result["checks"]["paired_pre_intervention_history_exact"])
        self.assertEqual(
            result["first_observable_response"]["dominant_observed_block"],
            "reactor",
        )
        self.assertFalse(
            result["interpretation"]["causal_identification_from_observations_alone"]
        )

    def test_misaligned_prefault_pair_is_reported(self):
        normal = [[float(i + j) for j in range(53)] for i in range(5)]
        fault = [row.copy() for row in normal]
        fault[1][0] += 0.5
        fault[3][6] += 2.0

        result = audit(normal, fault, intervention_index=3)

        self.assertFalse(result["checks"]["paired_pre_intervention_history_exact"])
        self.assertEqual(result["checks"]["finding_count"], 1)


if __name__ == "__main__":
    unittest.main()
