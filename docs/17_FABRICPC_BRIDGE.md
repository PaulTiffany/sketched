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

## Runtime instruments

The first trajectory-level instruments now exist outside the ignored checkout.
They emit hash-pinned JSON certificates rather than prose claims:

- `verification/tools/fabricpc_orientation_adapter.py` records paired finite
  differences, directional gain, and orientation transport;
- `verification/tools/fabricpc_orientation_block_sweep.py` compares full,
  blockwise, and hidden-only metrics so downstream transport is not misread as
  intrinsic instability;
- `verification/tools/fabricpc_second_order_adapter.py` records the four
  perturbation-square branches and the mixed finite-difference residue.

The second-order certificate has an explicit additive null and nonlinear positive
control. It can also accept ordered A-then-B and B-then-A trajectories, but a
square residue alone is not an order or imagination certificate. See
[`docs/26_FABRICPC_ORIENTATION_SENSOR.md`](26_FABRICPC_ORIENTATION_SENSOR.md)
and [`docs/27_FABRICPC_SECOND_ORDER_SENSOR.md`](27_FABRICPC_SECOND_ORDER_SENSOR.md).

These adapters verify the FabricPC commit from the local installation receipt,
retain raw trajectories, and never infer a latent cause from a scalar anomaly.
FabricPC remains a grounded external bridge; the correspondence to
`FabricPCGuard.lean` is still conditional and no upstream changes are made.
