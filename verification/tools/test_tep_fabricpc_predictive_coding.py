"""Unit tests for Tennessee Eastman FabricPC comparison logic."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FABRICPC = ROOT / "fabric" / "FabricPC"
sys.path.insert(0, str(FABRICPC))

try:
    from tep_fabricpc_predictive_coding import (
        BLOCK_NAMES,
        DENSE_EDGES,
        PROCESS_EDGES,
        SHUFFLED_EDGES,
        _compare_histories,
    )
except ModuleNotFoundError as error:
    if error.name in {"jax", "optax", "fabricpc"}:
        raise unittest.SkipTest("FabricPC environment is not installed") from error
    raise


class TopologyContractTests(unittest.TestCase):
    def test_control_arms_match_process_edge_count(self) -> None:
        self.assertEqual(len(PROCESS_EDGES), len(DENSE_EDGES))
        self.assertEqual(len(PROCESS_EDGES), len(SHUFFLED_EDGES))

    def test_internal_edges_have_no_self_loops(self) -> None:
        for edges in (PROCESS_EDGES, DENSE_EDGES, SHUFFLED_EDGES):
            self.assertTrue(all(source != target for source, target in edges))

    def test_effective_count_is_one_for_localized_delta(self) -> None:
        def state(changed: float) -> dict[str, dict[str, float]]:
            return {
                name: {"energy": changed if name == "reactor" else 0.0}
                for name in BLOCK_NAMES
            }

        result = _compare_histories([state(0.0)], [state(2.0)])
        self.assertEqual(result["final"]["dominant_block"], "reactor")
        self.assertAlmostEqual(result["final"]["effective_block_count"], 1.0)

    def test_effective_count_is_six_for_uniform_delta(self) -> None:
        base = {name: {"energy": 0.0} for name in BLOCK_NAMES}
        probe = {name: {"energy": 1.0} for name in BLOCK_NAMES}
        result = _compare_histories([base], [probe])
        self.assertAlmostEqual(
            result["final"]["effective_block_count"], len(BLOCK_NAMES)
        )


if __name__ == "__main__":
    unittest.main()
