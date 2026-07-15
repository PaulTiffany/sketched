"""Grounded FabricPC source facts for the self-compile bridge.

This module is a source capsule plus a verified local-run receipt reader, not a
FabricPC runtime adapter. It may report only what the checked-in receipt certifies;
correspondence between external FabricPC updates and the Lean guard remains open.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALL_RECEIPT = ROOT / "verification" / "fabricpc_install_receipt.json"

SOURCE_URL = "https://github.com/trueagi-io/FabricPC/blob/main/README.md"
ANNOUNCEMENT_URL = "https://x.com/ASI_Alliance/article/2063692767574872247"

FACTS = {
    "identity": {
        "text": (
            "FabricPC is an open-source Python library for building and "
            "training predictive coding networks."
        ),
        "source": "FabricPC README: project summary",
    },
    "graph": {
        "text": (
            "FabricPC organizes models around nodes, edges, and updates: "
            "nodes hold state and computation, edges define connections, and "
            "updates implement inference and learning algorithms."
        ),
        "source": "FabricPC README: internal abstractions",
    },
    "topology": {
        "text": (
            "FabricPC supports feedforward, recurrent, skip-connection, and "
            "cyclic graph topologies with heterogeneous components in one "
            "energy-minimization graph."
        ),
        "source": "FabricPC README: What It Does",
    },
    "comparison": {
        "text": (
            "FabricPC can train the same graph topology by predictive coding "
            "or by backpropagation, making controlled PC-vs-backprop "
            "comparisons a first-class use case."
        ),
        "source": "FabricPC README: PC_backprop_compare",
    },
    "runtime_boundary": {
        "text": "runtime receipt not loaded",
        "source": "verification/fabricpc_install_receipt.json",
    },
}


def _runtime_boundary() -> str:
    if not INSTALL_RECEIPT.is_file():
        return (
            "No local FabricPC installation receipt is present. The Lean guard "
            "contract is local, but external-code correspondence remains open."
        )
    receipt = json.loads(INSTALL_RECEIPT.read_text(encoding="utf-8"))
    env = receipt["environment"]
    checks = receipt["verification"]
    tests = checks["upstream_tests"]
    mnist = checks["mnist_demo"]
    commit = receipt["source"]["commit"][:12]
    return (
        f"FabricPC {env['fabricpc']} at commit {commit} is installed locally on "
        f"{env['device']}; {tests['passed']} upstream tests and the CPU MNIST "
        f"demo passed ({mnist['test_accuracy_percent']:.2f}% accuracy). This "
        "certifies installation and execution, not correspondence between the "
        "external update implementation and FabricPCGuard.lean; that measured "
        "bridge remains the open integration step."
    )


FACTS["runtime_boundary"]["text"] = _runtime_boundary()

def source_links() -> list[str]:
    return [SOURCE_URL, ANNOUNCEMENT_URL]
