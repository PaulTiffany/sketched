import copy
import unittest

from fabricpc_imagination_package import audit_manifest, inspect


class FabricPCImaginationPackageTests(unittest.TestCase):
    def test_repository_package_is_ready(self):
        manifest, findings = inspect()
        self.assertEqual(findings, [])
        self.assertTrue(manifest["ready"])
        self.assertFalse(
            manifest["contract"]["positive_candidate_required"]
        )
        self.assertFalse(manifest["contract"]["imagination_claim"])

    def test_manifest_tampering_is_rejected(self):
        manifest, findings = inspect()
        self.assertEqual(findings, [])
        tampered = copy.deepcopy(manifest)
        tampered["source"]["commit"] = "0" * 40
        self.assertIn(
            "[STALE] package manifest does not reproduce",
            audit_manifest(tampered),
        )

    def test_observed_verdict_remains_non_oracular(self):
        manifest, _ = inspect()
        self.assertFalse(
            manifest["observed_verdict"]["imagination_identified"]
        )
        self.assertFalse(
            manifest["contract"]["latent_cause_identified"]
        )


if __name__ == "__main__":
    unittest.main()
