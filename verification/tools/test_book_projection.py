"""Regression tests for the pedagogical projection contract."""

from __future__ import annotations

import copy
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from verification.tools.book_projection import (  # noqa: E402
    CONTENT_B_BEGIN,
    CONTENT_B_END,
    ProjectionError,
    validate_manifest,
)


def fixtures() -> tuple[dict, dict, str]:
    registry = {
        "chapters": [
            {"id": "ch01", "prerequisite_ids": []},
            {"id": "ch02", "prerequisite_ids": ["ch01"]},
            {"id": "ch03", "prerequisite_ids": ["ch02"]},
        ]
    }
    projections = {
        "schema_version": 1,
        "paths": [
            {
                "id": "closed",
                "chapter_ids": ["ch01", "ch02", "ch03"],
                "assumed_chapter_ids": [],
            }
        ],
        "content_b": {
            "owner": "OmegaClaw",
            "status": "reserved",
            "inclusion": "reference-only",
            "rules": ["Do not synthesize."],
        },
    }
    eula = CONTENT_B_BEGIN + "\nreserved\n" + CONTENT_B_END
    return registry, projections, eula


class ProjectionChainTests(unittest.TestCase):
    def test_accepts_closed_ordered_chain(self) -> None:
        registry, projections, eula = fixtures()
        validate_manifest(registry, projections, eula)

    def test_rejects_prerequisite_cycle(self) -> None:
        registry, projections, eula = fixtures()
        registry["chapters"][0]["prerequisite_ids"] = ["ch03"]
        with self.assertRaisesRegex(ProjectionError, "cycle"):
            validate_manifest(registry, projections, eula)

    def test_rejects_selected_chapter_before_prerequisite(self) -> None:
        registry, projections, eula = fixtures()
        projections["paths"][0]["chapter_ids"] = ["ch02", "ch01"]
        with self.assertRaisesRegex(ProjectionError, "appears before prerequisites"):
            validate_manifest(registry, projections, eula)

    def test_accepts_transitively_closed_assumptions(self) -> None:
        registry, projections, eula = fixtures()
        projections["paths"][0]["chapter_ids"] = ["ch03"]
        projections["paths"][0]["assumed_chapter_ids"] = ["ch01", "ch02"]
        validate_manifest(registry, projections, eula)

    def test_rejects_incomplete_assumption_chain(self) -> None:
        registry, projections, eula = fixtures()
        projections["paths"][0]["chapter_ids"] = ["ch03"]
        projections["paths"][0]["assumed_chapter_ids"] = ["ch02"]
        with self.assertRaisesRegex(ProjectionError, "assumption ch02 omits"):
            validate_manifest(registry, projections, eula)

    def test_rejects_content_b_authorship_in_manifest(self) -> None:
        registry, projections, eula = fixtures()
        altered = copy.deepcopy(projections)
        altered["content_b"]["content"] = "synthetic substitute"
        with self.assertRaisesRegex(ProjectionError, "must not contain authored content"):
            validate_manifest(registry, altered, eula)


if __name__ == "__main__":
    unittest.main()