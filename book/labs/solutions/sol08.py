"""Solution 08 — ch08 exercise 1 (predict, then run).

Question: before running the lab, guess the realized/target split of the
operator map for a from-scratch witness-layer project at this stage.

The chapter's own answer — the split the shipped map actually carries —
is 18 realized / 7 target. What a reader "should" have guessed is less
interesting than what the numbers mean: every witness-layer primitive
that exists is mapped and checked (realized), and every calibration item
whose discharge would require semantics the code does not yet have is
recorded as debt rather than rounded up (target). The ratio is a
snapshot; the honesty property is that neither bucket is empty.

Run: python book/labs/solutions/sol08.py    (exit 0 iff the split matches)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OPERATORS = ROOT / "verification" / "operators.json"

CHAPTER_REALIZED = 18
CHAPTER_TARGET = 7

CHECKS: list[str] = []


def expect(cond: bool, label: str) -> None:
    print(f"  [{'ok  ' if cond else 'FAIL'}] {label}")
    if not cond:
        CHECKS.append(label)


def main() -> int:
    entries = json.loads(OPERATORS.read_text(encoding="utf-8"))["operators"]
    realized = sum(1 for e in entries if e.get("status", "realized") == "realized")
    target = sum(1 for e in entries if e.get("status") == "target")
    print(f"  operator map today: {realized} realized / {target} target\n")

    expect(
        (realized, target) == (CHAPTER_REALIZED, CHAPTER_TARGET),
        f"the chapter's quoted split ({CHAPTER_REALIZED}/{CHAPTER_TARGET}) "
        "matches the shipped map",
    )
    expect(realized > 0, "realized bucket nonempty: something actually shipped")
    expect(target > 0, "target bucket nonempty: the debt is not hidden")

    print(f"\n{len(CHECKS)} failures.")
    return 1 if CHECKS else 0


if __name__ == "__main__":
    sys.exit(main())
