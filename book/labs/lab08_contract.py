"""Lab 08 — The contract and the debt (companion to
book/ch08_the_contract_and_the_debt.md).

This chapter's "lab" is not a new computation: it is running the same
operator-correspondence auditor the suite runs on every build, and
checking the two numbers this chapter quotes. Unlike chapters 02-05,
there is no toy model here to compute on — the claim is about the
relationship between the paper's calibration queue and the *actual*
verification/operators.json, and the only honest way to teach that is
to run the real auditor, not a simplified stand-in.

Run: python book/labs/lab08_contract.py    (exit 0 iff the audit is clean
and the calibration queue's 10 items are all covered by at least one
operator entry, realized or target)
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OPERATORS = ROOT / "verification" / "operators.json"
AUDITOR = ROOT / "verification" / "tools" / "operator_audit.py"

CHECKS: list[str] = []
EXPECTED_REALIZED = 18
EXPECTED_TARGET = 7


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def main() -> int:
    print("running the real operator-correspondence auditor "
          "(verification/tools/operator_audit.py):\n")
    rc = subprocess.call([sys.executable, str(AUDITOR)])
    expect(rc == 0, "operator_audit.py exits 0: every code_refs entry checks out")

    ops = json.loads(OPERATORS.read_text(encoding="utf-8"))
    entries = ops["operators"]
    realized = sum(1 for e in entries if e.get("status", "realized") == "realized")
    target = sum(1 for e in entries if e.get("status") == "target")
    print(f"\n  realized operators: {realized}   target operators: {target}")

    covered = {e["calibration_item"] for e in entries if e.get("calibration_item")}
    expect(covered == set(range(1, 11)), "all 10 calibration-queue items have at least one operator entry")
    expect(
        (realized, target) == (EXPECTED_REALIZED, EXPECTED_TARGET),
        f"operator snapshot matches the chapter: {EXPECTED_REALIZED} realized / {EXPECTED_TARGET} target",
    )
    expect(
        target > 0,
        "at least one operator remains 'target': the calibration queue (asm:calibration) is genuinely open, not closed by fiat",
    )

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
