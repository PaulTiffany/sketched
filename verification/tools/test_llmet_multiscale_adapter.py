import unittest

from llmet_multiscale_adapter import (
    SCHEMA,
    _cluster_candidates,
    analyze_multiscale,
)


class LlmetMultiscaleAdapterTests(unittest.TestCase):
    def test_nearby_candidates_persist_across_frames(self):
        candidates = [
            {
                "frame": "80/40",
                "line_estimate": 100,
                "distance": 2.0,
            },
            {
                "frame": "160/80",
                "line_estimate": 140,
                "distance": 1.5,
            },
        ]
        clusters = _cluster_candidates(
            candidates, radius_lines=60
        )
        self.assertEqual(len(clusters), 1)
        self.assertTrue(clusters[0]["persistent_across_frames"])

    def test_one_frame_does_not_manufacture_persistence(self):
        candidates = [
            {
                "frame": "80/40",
                "line_estimate": 100,
                "distance": 2.0,
            },
            {
                "frame": "80/40",
                "line_estimate": 120,
                "distance": 1.5,
            },
        ]
        clusters = _cluster_candidates(
            candidates, radius_lines=60
        )
        self.assertFalse(clusters[0]["persistent_across_frames"])

    def test_multiscale_certificate_denies_imagination_claim(self):
        direct = "\n".join(f"x{i} = {i}" for i in range(30))
        guarded = "\n".join(
            (
                f"try:\n"
                f"    y{i} = solve({i})\n"
                f"except Exception:\n"
                f"    logging.error('fallback')"
            )
            for i in range(10)
        )
        result = analyze_multiscale(
            direct + "\n" + guarded + "\n",
            source_label="synthetic.py",
            frames=((12, 6), (24, 12)),
            cluster_radius_lines=20,
        )
        self.assertEqual(result["schema"], SCHEMA)
        self.assertFalse(result["method"]["imagination_claim"])
        self.assertFalse(result["source"]["executed"])


if __name__ == "__main__":
    unittest.main()
