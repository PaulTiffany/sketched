# FabricPC Bridge

FabricPC is a candidate substrate for the Sketched pedagogy and experiment
chains: predictive coding gives the project a concrete graph-settling idiom
without changing the authority model of the surface.

## Source Boundary

The bridge has two distinct evidence layers. External identity and API claims
remain grounded in the FabricPC README and ASI announcement. Local execution is
grounded separately by `verification/fabricpc_install_receipt.json`: FabricPC
0.3.1 at pinned commit `b6f64adf9314` ran on JAX CPU, with 269 upstream tests
passing and the MNIST demo reaching 98.13% test accuracy. This does not establish
that FabricPC's external update implementation realizes `FabricPCGuard.lean`;
that correspondence remains open.

Grounded facts used by the chain:

- FabricPC is an open-source Python library for building and training predictive
  coding networks.
- FabricPC organizes models around nodes, edges, and updates.
- FabricPC supports feedforward, recurrent, skip-connection, and cyclic graph
  topologies with heterogeneous components in one energy-minimization graph.
- FabricPC can train the same graph topology by predictive coding or by
  backpropagation, which makes controlled comparisons a natural bridge.

Sources:

- https://github.com/trueagi-io/FabricPC/blob/main/README.md
- https://x.com/ASI_Alliance/article/2063692767574872247

## Chain Mapping

FabricPC maps cleanly onto the existing `selfcompile` discipline:

| FabricPC term | Sketched chain role |
| --- | --- |
| node | local state and computation surface |
| edge | declared dependency or channel between states |
| update | inference or learning step, analogous to a witnessed mutation proposal |
| energy minimization | pedagogical image for local error settling under constraints |
| PC-vs-backprop comparison | controlled instrument: same topology, different update regime |

The first realized integration is `selfcompile`:

- `selfcompile/fabricpc.py` stores sourced FabricPC facts and the runtime
  boundary.
- `matt.fabricpc_profile` turns those facts into manifest claims.
- `ellie._bridge_fabricpc` renders a bridge lesson from those claims.
- `selfcompile/goals.json` adds `fabricpc-bridge` as a `bridge` mode goal.

## Next Runtime Instrument

A trajectory-level FabricPC runtime adapter should stay optional and emit manifest claims,
not prose. A minimal useful instrument would run a tiny graph and emit:

- graph topology: nodes, edges, update regime;
- run boundary: FabricPC commit or package version, JAX backend, seed;
- observed quantities: loss or energy trace, convergence status, runtime notes;
- comparison mode: predictive coding and backpropagation on the same topology;
- failure boundary: hardware/backend limitations and any divergence from the
  FabricPC demo baselines.

Until that exists, FabricPC is a grounded external bridge, not a local empirical
result.
