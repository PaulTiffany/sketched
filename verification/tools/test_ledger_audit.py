"""Regression tests for status-ledger audit severity and source closure."""

from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDITOR = ROOT / "verification" / "tools" / "ledger_audit.py"


class LedgerAuditTests(unittest.TestCase):
    def test_repository_ledger_has_no_errors(self) -> None:
        result = subprocess.run(
            [sys.executable, str(AUDITOR)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("0 errors; 9 informational diagnostics.", result.stdout)

    def test_strict_inventory_mode_retains_open_debt(self) -> None:
        result = subprocess.run(
            [sys.executable, str(AUDITOR), "--strict-info"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("[UNANCHORED_DEBT]", result.stdout)


if __name__ == "__main__":
    unittest.main()
