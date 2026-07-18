# FabricPC trajectory probe

A small, falsifiable diagnostic for paired predictive-coding inference runs.

This folder is the community-facing entrance to Sketched's FabricPC experiment.
It asks a technical question without requiring Principia Symbolica terminology:

> When a small perturbation to one node's latent state evolves during
> inference, how much response stays local, how much crosses an edge, and does
> its represented direction reverse?

## Run the demo

Requirements: Windows PowerShell and the pinned FabricPC environment described
in `verification/fabricpc_install_receipt.json`.

```powershell
powershell -ExecutionPolicy Bypass -File `
  contrib\fabricpc-trajectory-probe\run.ps1
```

Vary the frame instead of trusting one run:

```powershell
powershell -ExecutionPolicy Bypass -File `
  contrib\fabricpc-trajectory-probe\run.ps1 `
  -DirectionX 0 -DirectionY 1 -Nonlinear `
  -ParameterSeed 17 -StateSeed 23
```

Outputs go to `C:\tmp\fabricpc-trajectory-probe` by default:

- `fabricpc_orientation_trace.json`: complete paired observations;
- `fabricpc_orientation_certificate.json`: deterministic derived measurements.

The launcher modifies neither FabricPC nor Sketched source files.

## Read the result

For each inference transition, the certificate reports:

- perturbation norm before and after the update;
- finite-difference directional gain;
- cosine between the incoming and outgoing perturbation;
- whether the configured gain or orientation threshold fired.

A candidate is an **audit trigger**, not a diagnosis. In particular:

- gain over one is not a global Lipschitz result;
- whole-state gain can arise from transport into another node;
- negative cosine records reversal in the chosen representation;
- none of these observations identifies imagination or consciousness.

The stored baseline currently gives a controlled negative result: hidden-state
response is locally contractive, product-state growth is explained by interface
transport, and no orientation reversal was observed.

## Why FabricPC might care

FabricPC already exposes full inference histories. This probe demonstrates a
small diagnostic use of those histories: distinguish local update behavior from
perturbation propagation through graph topology. That may be useful when
comparing graph structures, inference settings, activations, or update order.
Open [`presentation/index.html`](presentation/index.html) for the call-ready
keyboard- and touch-navigable HTML presentation.
The [`tennessee-eastman`](tennessee-eastman/) example applies the same
discipline to a public industrial fault-diagnosis benchmark with an exact
paired simulator counterfactual.

See [`EXAMPLE.md`](EXAMPLE.md) for a complete transport-versus-instability case.

The least invasive upstream form would be an example or dashboard recipe. We
should first ask maintainers whether `run_inference_with_full_history` is a
stable public API and where nodewise trajectory diagnostics belong.

## Package map

- `PACKAGE.json`: source pin, entry point, outputs, claims, and non-claims.
- `run.ps1`: reproducible local launcher with visible frame controls.
- `docs/32_FABRICPC_MAINTAINER_HANDOFF.md`: detailed proposal and questions.
- `verification/fabricpc_imagination_package.json`: hashed package receipt.
- `verification/tools/fabricpc_orientation_adapter.py`: FabricPC experiment.
- `verification/tools/fabricpc_orientation_sensor.py`: independent certificate.

Audit the complete receipt:

```powershell
python verification\tools\fabricpc_imagination_package.py --check
```

## Status and authority

Experimental, reproducible, negative-result-compatible. No upstream push is
authorized. Human review is required before turning this into a FabricPC issue
or pull request.
