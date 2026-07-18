# Worked example: apparent amplification resolved as graph transport

This example uses the stored, pinned FabricPC run rather than a hand-written toy
result.

## Setup

- FabricPC commit: `b6f64adf9314863ce665085a92d544807d585819`
- Graph: `source -> hidden -> latent`
- Inference: `InferenceSGD`, `eta_infer = 0.05`, 12 steps
- Parameter seed: 17
- State seed: 23
- Intervention: add `(0.001, 0)` to `hidden.z_latent`
- Observation: concatenate the `hidden` and `latent` latent states

The complete input and certificate are:

- `verification/fabricpc_orientation_trace.json`
- `verification/fabricpc_orientation_certificate.json`

## What the first measurement says

Before the first update, the paired trajectories differ by approximately
`0.00100005`. After the update they differ by approximately `0.00159384`.

```text
whole observed state gain = 0.00159384 / 0.00100005 = 1.59376
orientation cosine        = 0.59611
```

Under the configured `gain > 1` screening rule, this is a candidate transition.
There is no orientation reversal because the cosine remains positive.

A naïve report might stop here and say that the update amplified the
perturbation by about 59%. That statement is true only for the concatenated
observation and is not yet a diagnosis of the perturbed node.

## Blockwise resolution

The blockwise sweep repeats the experiment over 72 combinations of parameter
seed, state seed, inference rate, and perturbation direction. Its first-step
summary is:

```text
whole-state gain breaches: 72 / 72
hidden-node gain breaches:   0 / 72
latent-node emergence:      72 / 72
```

For example, with parameter seed 3, state seed 5, `eta_infer = 0.01`, and
direction `(1, 0)`:

```text
hidden perturbation: 0.000999987 -> 0.000989974  (gain 0.989986)
latent perturbation: 0           -> 0.001182716  (new downstream response)
whole-state gain:                                  1.542377
```

The originally perturbed hidden block contracts. The whole observed state grows
because a new difference appears in the downstream latent block. The graph has
transported the perturbation across `hidden -> latent`.

## Conclusion

The candidate was useful but underdetermined:

```text
whole-state amplification
        does not imply
local instability at the perturbed node
```

The topology-aware interpretation is **interface transport with local
contraction**. This is the concrete value of the probe: it preserves enough
structure to distinguish those claims before anyone patches a sign, changes an
update rule, or labels the transition with a latent cause.

## What this example does not show

It does not show an orientation reversal, phase transition, global Lipschitz
violation, Hessian, FabricPC defect, imagination, or consciousness. It shows a
reproducible observable that would be easy to misclassify without per-node
trajectory analysis.

## Reproduce

Run the stored configuration:

```powershell
powershell -ExecutionPolicy Bypass -File `
  contrib\fabricpc-trajectory-probe\run.ps1 `
  -ParameterSeed 17 -StateSeed 23 `
  -Perturbation 0.001 -DirectionX 1 -DirectionY 0 `
  -Eta 0.05 -InferSteps 12
```

Then compare the generated certificate with
`verification/fabricpc_orientation_certificate.json`. Floating-point output is
expected to match on the recorded JAX/CPU environment; the package receipt
checks the canonical stored evidence independently of rerunning JAX.
