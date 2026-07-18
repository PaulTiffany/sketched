# FabricPC maintainer handoff

## Proposal

**Inference trajectory sensitivity diagnostics for FabricPC graphs**

This is a small experimental instrument built on FabricPC's existing graph,
`InferenceSGD`, and full-history utilities. It compares a baseline inference
trajectory with a nearby trajectory produced by perturbing one node's latent
state. No change to FabricPC's learning or inference algorithms is proposed.

The neutral question is: when a small perturbation changes during inference,
is the response local to the perturbed node, transported across graph edges,
sensitive to perturbation order, or evidence of nonlinear interaction?

## Sixty-second path

From Sketched, using the pinned FabricPC environment:

```powershell
fabric\FabricPC\.venv\Scripts\python.exe `
  verification\tools\fabricpc_orientation_adapter.py `
  --output-dir C:\tmp\fabricpc-probe `
  --perturbation 0.001 --direction 1 0
```

This verifies the source pin, builds `source -> hidden -> latent`, runs paired
`InferenceSGD` histories through `run_inference_with_full_history`, and exports
complete JSON traces plus a directional-gain certificate. Both seeds, inference
steps, learning rate, direction, and linear/sigmoid choice are CLI controls.

Audit the stored package without running FabricPC:

```powershell
python verification\tools\fabricpc_imagination_package.py --check
```

## Current result

The current calibration is a useful negative result:

- the perturbed hidden-node block is locally contractive;
- the combined state can initially grow as perturbation reaches `latent`;
- no orientation reversal was observed;
- no replicated multiframe candidate was identified; and
- nonlinear mixed residue remains architecture-confounded.

A concatenated-state norm increase therefore need not mean that the update at
the perturbed node is unstable. It may record propagation into another node.

## Vocabulary and API mapping

| Diagnostic concept | FabricPC realization |
|---|---|
| inference system | graph of nodes and edges |
| update rule | `InferenceSGD` |
| intervention | perturb `NodeState.z_latent` |
| observation | `run_inference_with_full_history` |
| local response | hidden-node trajectory delta |
| transported response | latent-node trajectory delta |
| nonlinear interaction | mixed finite difference over four trajectories |
| order sensitivity | compare opposite perturbation orders |

The philosophical labels used elsewhere in Sketched are not needed to review
or use this diagnostic.

## Smallest plausible upstream contribution

If maintainers find it useful, the least invasive shape is an example or
recipe that runs paired inference histories, reports per-node and whole-state
perturbation norms, and preserves configuration in machine-readable output.
The current code should not be copied upstream unchanged because it includes
Sketched-specific provenance and certificate schemas.

Before any pull request, ask maintainers:

1. Is `run_inference_with_full_history` intended as stable user-facing API?
2. Does this belong as an example, dashboard diagnostic, or external recipe?
3. What is their preferred interface for exporting nodewise histories?
4. Which baseline graph best matches their demo conventions?

No upstream push is authorized by this package.

## Non-claims and provenance

This does not establish a global Lipschitz constant, Hessian, phase transition,
hidden cause, consciousness or imagination, or a defect in FabricPC.
"Imagination detector" is Sketched's downstream interpretation and requires
replication, controls, and an explicit bridge beyond trajectory evidence.

The package pins FabricPC commit
`b6f64adf9314863ce665085a92d544807d585819`. The external checkout remains
ignored and unmodified. Stored traces, certificates, thresholds, source
references, and hashes are bound by
`verification/fabricpc_imagination_package.json`.
