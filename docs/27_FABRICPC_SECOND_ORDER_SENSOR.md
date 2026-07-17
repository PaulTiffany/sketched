# FabricPC second-order interaction sensor

This is a Sketched-owned, read-only experiment bridge. It does not modify the
FabricPC checkout or publish anything upstream.

## Observable square

For a common initial state `x` and two declared perturbations `d1` and `d2`,
the adapter records four trajectories at the same inference times:

```text
base     = F(x)
first    = F(x + d1)
second   = F(x + d2)
combined = F(x + d1 + d2)
```

The certificate computes the mixed finite difference

```text
combined - first - second + base
```

An additive/separable null model has zero residue. A nonzero residue is an
observable second-order interaction (non-additivity). It does not identify a
Hessian, a global Lipschitz constant, an imaginary traversal, or a phase
transition. Those remain hypotheses requiring additional controls.

The sensor can also accept `order_ab_states` and `order_ba_states`. Their
difference is reported separately as a commutator witness. Order dependence
must not be inferred from a square residue alone.

## Synthetic controls

`verification/tools/test_second_order_sensor.py` covers:

- an additive null with exactly zero residue;
- a bilinear positive control whose mixed residue is nonzero;
- explicit threshold behavior;
- a separate order-commutator positive control;
- partial-order, shape, and non-finite-input rejection.

Run them with:

```powershell
python -m unittest discover verification\tools `
  -p test_second_order_sensor.py
```

## Pinned FabricPC run

The adapter checks the FabricPC checkout against
`verification/fabricpc_install_receipt.json` before importing its inference
utility. It uses the same deterministic graph, parameters, state seed, and
inference settings for all four branches:

```powershell
fabric\FabricPC\.venv\Scripts\python.exe `
  verification\tools\fabricpc_second_order_adapter.py --nonlinear
```

The run produced:

| graph | observed steps | maximum residue | interpretation |
| --- | ---: | ---: | --- |
| linear | 0/13 above `1e-7` | `0` | calibration null |
| sigmoid nonlinear (`epsilon=0.1`) | 12/13 above `1e-7` | `1.78511156e-3` | observable non-additivity |

The nonlinear result at `epsilon=0.1` is a useful positive control for the instrument: the
same square protocol that is exactly additive for the linear graph detects a
small residue once the sigmoid activation is introduced. It is not evidence
that FabricPC contains an imaginary state or that a phase transition occurred.

Artifacts:

- `verification/fabricpc_second_order_trace.json`
- `verification/fabricpc_second_order_certificate.json`
- `verification/fabricpc_second_order_nonlinear_trace.json`
- `verification/fabricpc_second_order_nonlinear_certificate.json`

Each certificate hashes its complete input and records the pinned FabricPC
commit. The next defensible extension is a genuine ordered A-then-B versus
B-then-A experiment, followed by metric/block audits like the orientation
sensor's existing audit. A sign or residue anomaly should remain a prompt to
retain intermediate witnesses and audit projection, orientation, and operator
order—not a license to patch the interpretation.
