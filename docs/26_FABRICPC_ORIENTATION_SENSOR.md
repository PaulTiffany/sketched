# FabricPC orientation sensor

This is an external, read-only experiment bridge. It does not modify the
ignored FabricPC checkout and does not claim that FabricPC implements the Lean
guard merely because a trajectory can be measured.

## Hypothesis

An imagination-sensitive transition may coincide with a local failure of
contractivity, an orientation reversal, or a projection that erases the
intermediate traversal. These are candidate correlations, not definitions of
imagination or proof of a phase transition.

For paired base/probe trajectories, the sensor computes

```text
d_t = probe_t - base_t
gain_t = ||d_(t+1)|| / ||d_t||
orientation_t = cosine(d_t, d_(t+1))
```

`gain_t` is a finite-difference directional observation. It is not a global
Lipschitz constant. Negative orientation cosine means that the represented
perturbation reversed direction over the update; it does not by itself explain
which latent operator, phase, ordering, or projection caused the reversal.

## Safety and authority

- FabricPC remains pinned and read-only.
- Raw runs must record repository commit, run identifier, and thresholds.
- The generated certificate hashes its complete input.
- Flags say “candidate: audit,” never “imagination detected.”
- Nothing is pushed upstream without explicit human review and conversation
  with the FabricPC maintainers.

## Smoke run

```powershell
python verification\tools\fabricpc_orientation_sensor.py `
  verification\fabricpc_orientation_example.json

python -m unittest discover verification\tools `
  -p test_fabricpc_orientation_sensor.py
```

## Real FabricPC paired run

The Sketched-owned adapter now wraps FabricPC's existing
`run_inference_with_full_history` utility without changing FabricPC source. It
verifies the checkout against the installation receipt, constructs a
deterministic three-node graph, perturbs one hidden latent coordinate, and
exports the paired trajectories:

```powershell
fabric\FabricPC\.venv\Scripts\python.exe `
  verification\tools\fabricpc_orientation_adapter.py
```

Outputs:

- `verification/fabricpc_orientation_trace.json`
- `verification/fabricpc_orientation_certificate.json`

The first run observed one candidate among twelve transitions. At step zero,
the perturbation norm increased from approximately `0.00100005` to
`0.00159384`, a directional gain of approximately `1.59376`. Orientation
remained positive (cosine approximately `0.59611`), so this is a local gain
breach, not a sign reversal.

This is an empirical smoke witness for the instrumentation path. It does not
validate a universal phase-transition hypothesis or establish every premise of
`FabricPCGuard.lean`. Next experiments should vary seeds, perturbation
directions, graph topology, and inference rate, then test whether candidate
events cluster with energy changes, rank loss, or projection-sensitive sign
conflicts.

## Bounded sweep result

A complete Cartesian sweep covered 72 runs: three parameter seeds, two state
seeds, three inference rates, and four perturbation directions. No run was
selected or discarded based on its result.

- **72 / 72** runs had exactly one gain candidate.
- Every candidate occurred on the first inference transition.
- **0 / 72** runs had an orientation reversal.
- **0 / 72** runs had a joint gain-and-orientation event.
- Maximum observed gain ranged from approximately `1.17902` to `2.81268`
  (median approximately `1.65456`).
- Minimum orientation cosine remained positive, ranging from approximately
  `0.29076` to `0.75264`.

This is evidence that the first-step expansion is structural for this tiny
graph and measurement setup. It is not yet evidence of an imagination phase
transition. The initial perturbation occupies only the hidden-node block; after
one FabricPC update it can spread into the downstream latent block. Under the
current equal-weight product norm, adding a transported component can increase
total perturbation norm even when no represented direction reverses. Metric
choice and per-node transport therefore must be audited before interpreting the
gain as a Lipschitz-contract breach of the intrinsic dynamics.

That result motivated the completed blockwise revision below, which compares three declared metrics before interpreting a gain or sign anomaly.

Sweep certificate: `verification/fabricpc_orientation_sweep.json`.
## Blockwise metric audit

The same 72-run sweep was decomposed into the originally perturbed hidden
block and the downstream latent block. Three geometries were compared: full
product L2, maximum block norm, and hidden-only L2.

- Product-L2 first-step breaches: **72 / 72**.
- Max-block first-step breaches: **66 / 72**.
- Hidden-only first-step breaches: **0 / 72**.
- Downstream latent emergence from a zero perturbation: **72 / 72**.
- Hidden gain ranged from approximately `0.79997` to `0.99003`
  (median approximately `0.95000`).
- Product gain ranged from approximately `1.17902` to `2.81268`.

Therefore the initially perturbed channel is contractive throughout this sweep.
The apparent full-state breach occurs because the perturbation is transported
across the hidden/latent interface and occupies an additional coordinate block.
This does not make the full product gain false; it makes its interpretation
metric- and interface-dependent. The retained intermediate/block witness
explains a qualitative result that a scalar norm alone would misclassify.

This is the first concrete support for orientation-sensitive traversal auditing:
audit the interface and projection before calling a scalar gain or sign change
an intrinsic instability. No orientation reversal or phase transition was
observed in this experiment.

Block certificate: `verification/fabricpc_orientation_block_sweep.json`.