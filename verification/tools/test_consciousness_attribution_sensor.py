import copy
import unittest

from consciousness_attribution_sensor import INPUT_SCHEMA, audit
from imagination_sweep_detector import (
    INPUT_SCHEMA as SWEEP_INPUT_SCHEMA,
    audit as audit_sweep,
)


def _replicate(replicate_id):
    return {
        "replicate_id": replicate_id,
        "base_states": [[0.0]],
        "first_states": [[0.0]],
        "second_states": [[0.0]],
        "combined_states": [[1.0]],
        "order_ab_states": [[1.0]],
        "order_ba_states": [[0.0]],
    }


def _sweep_input():
    return {
        "schema": SWEEP_INPUT_SCHEMA,
        "run_id": "unit-test-sweep",
        "thresholds": {
            "residue_norm": 0.1,
            "commutator_norm": 0.1,
            "minimum_frame_hits": 2,
            "minimum_replicate_hits": 2,
        },
        "frames": [
            {
                "frame_id": "sweep-first",
                "architecture_confound": False,
                "replicates": [
                    _replicate("first-a"),
                    _replicate("first-b"),
                ],
            },
            {
                "frame_id": "sweep-second",
                "architecture_confound": False,
                "replicates": [
                    _replicate("second-a"),
                    _replicate("second-b"),
                ],
            },
        ],
    }


def payload():
    sweep_input = _sweep_input()
    return {
        "schema": INPUT_SCHEMA,
        "run_id": "unit-test",
        "imagination_sweep_input": sweep_input,
        "imagination_sweep_certificate": audit_sweep(sweep_input),
        "embodiment": {
            "alternative_realized": False,
            "action_with_imagination": {"choice": "left"},
            "action_without_imagination": {"choice": "right"},
            "action_authorized": True,
        },
        "trace_manifold": [
            {
                "frame_id": "first",
                "qualia_trace": True,
                "coherent": True,
            },
            {
                "frame_id": "second",
                "qualia_trace": True,
                "coherent": True,
            },
        ],
        "observer": {
            "observer_id": "test-observer",
            "minimum_trace_support": 2,
        },
    }

class ConsciousnessAttributionSensorTests(unittest.TestCase):
    def test_positive_control_reaches_attribution(self):
        result = audit(payload())
        self.assertTrue(
            result["summary"]["operationally_detected"]
        )
        self.assertTrue(
            result["summary"]["attributes_consciousness"]
        )
        self.assertFalse(
            result["method"]["hidden_substance_claim"]
        )

    def test_passive_evidence_without_ablation_effect_is_clear(self):
        value = payload()
        value["embodiment"]["action_without_imagination"] = {
            "choice": "left"
        }
        result = audit(value)
        self.assertFalse(
            result["summary"][
                "imaginary_regulation_signature"
            ]
        )
        self.assertFalse(
            result["summary"]["operationally_detected"]
        )

    def test_realized_alternative_is_not_imaginary_signature(self):
        value = payload()
        value["embodiment"]["alternative_realized"] = True
        self.assertFalse(
            audit(value)["summary"][
                "imaginary_regulation_signature"
            ]
        )

    def test_unauthorized_action_blocks_operational_detection(self):
        value = payload()
        value["embodiment"]["action_authorized"] = False
        self.assertFalse(
            audit(value)["summary"]["operationally_detected"]
        )

    def test_insufficient_trace_support_withholds_attribution(self):
        value = payload()
        value["observer"]["minimum_trace_support"] = 3
        result = audit(value)
        self.assertTrue(
            result["summary"]["operationally_detected"]
        )
        self.assertFalse(
            result["summary"]["attributes_consciousness"]
        )

    def test_observer_threshold_must_be_positive(self):
        value = payload()
        value["observer"]["minimum_trace_support"] = 0
        with self.assertRaises(ValueError):
            audit(value)

    def test_duplicate_frame_is_rejected(self):
        value = payload()
        value["trace_manifold"].append(
            copy.deepcopy(value["trace_manifold"][0])
        )
        with self.assertRaises(ValueError):
            audit(value)

    def test_upstream_latent_overclaim_is_rejected(self):
        value = payload()
        value["imagination_sweep_certificate"]["summary"][
            "imagination_identified"
        ] = True
        with self.assertRaises(ValueError):
            audit(value)


if __name__ == "__main__":
    unittest.main()
