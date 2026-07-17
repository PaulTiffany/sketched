import unittest

from imagination_certificate_audit import audit_artifacts


class ImaginationCertificateAuditTests(unittest.TestCase):
    def test_repository_certificates_are_current(self):
        self.assertEqual(audit_artifacts(), [])


if __name__ == "__main__":
    unittest.main()
