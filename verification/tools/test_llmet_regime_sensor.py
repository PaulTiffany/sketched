import unittest

from llmet_regime_sensor import SCHEMA, analyze_source


class LlmetRegimeSensorTests(unittest.TestCase):
    def test_certificate_denies_hidden_state_claims(self):
        result = analyze_source(
            "x = 1\ny = 2\n",
            source_label="tiny.py",
            window_lines=2,
            stride_lines=1,
        )
        self.assertEqual(result["schema"], SCHEMA)
        self.assertFalse(result["method"]["authorship_claim"])
        self.assertFalse(result["method"]["cognitive_state_claim"])
        self.assertFalse(result["method"]["imagination_claim"])

    def test_unreachable_duplicate_strategy_is_retained(self):
        source = """\
def choose():
    try:
        return 1
    except Exception:
        return 2
    print("unreachable strategy")
"""
        result = analyze_source(
            source,
            source_label="unreachable.py",
            window_lines=3,
            stride_lines=1,
        )
        findings = result["static_witnesses"]["unreachable_regions"]
        self.assertEqual(len(findings), 1)
        self.assertEqual(findings[0]["start_line"], 6)

    def test_uniform_source_has_no_spurious_distance(self):
        source = "\n".join(f"v{i} = {i}" for i in range(24)) + "\n"
        result = analyze_source(
            source,
            source_label="uniform.py",
            window_lines=6,
            stride_lines=6,
        )
        self.assertTrue(
            all(
                item["distance"] == 0
                for item in result["ranked_transitions"]
            )
        )
        self.assertEqual(
            result["summary"]["candidate_regime_changes"],
            0,
        )

    def test_defensive_shift_changes_feature_vector(self):
        direct = "\n".join(f"x{i} = {i}" for i in range(12))
        guarded = "\n".join(
            (
                f"try:\n"
                f"    y{i} = solve({i})\n"
                f"except Exception:\n"
                f"    logging.error('fallback')"
            )
            for i in range(6)
        )
        result = analyze_source(
            direct + "\n" + guarded + "\n",
            source_label="shift.py",
            window_lines=12,
            stride_lines=12,
        )
        self.assertGreater(
            result["ranked_transitions"][0]["distance"],
            0,
        )
        leading = {
            item["feature"]
            for item in result["ranked_transitions"][0][
                "leading_features"
            ]
        }
        self.assertTrue(
            leading
            & {
                "try_rate",
                "broad_handler_rate",
                "defensive_term_rate",
            }
        )

    def test_invalid_python_is_rejected(self):
        with self.assertRaises(ValueError):
            analyze_source("try:\n", source_label="broken.py")


if __name__ == "__main__":
    unittest.main()
