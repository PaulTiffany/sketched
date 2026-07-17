# FabricPC imagination-detector package

This package is a coherent experimental handoff, not an upstream FabricPC
change and not a claim that imagination has been identified.

The package receipt is
`verification/fabricpc_imagination_package.json`. It binds:

- the pinned external FabricPC repository and commit;
- raw orientation and second-order trajectories;
- four certificates reproduced from their complete inputs;
- the rebuilt multiframe imagination-sweep input;
- the Lean detector/package contract;
- declared thresholds and epistemic claim limits; and
- SHA-256 digests for every included contract, tool, trace, and certificate.

Run the non-mutating audit with:

```powershell
python verification\tools\fabricpc_imagination_package.py --check
```

Regenerate the manifest only after intentionally changing a package artifact:

```powershell
python verification\tools\fabricpc_imagination_package.py
```

## What “ready” means

`ready: true` means the source pin is consistent, stored certificates
reproduce, the multiframe input rebuilds from its raw traces, every included
artifact is hashed, and all forbidden oracle claims remain false.

It does **not** require a positive detector result. A controlled negative
result is a useful deliverable. The current FabricPC calibration has:

- no replicated multiframe screening candidate;
- no orientation-sensitive candidate; and
- no identified imagination, phase transition, Hessian, latent cause, or
  global Lipschitz constant.

The known sigmoid mixed residue remains explicitly architecture-confounded.
The blockwise orientation sweep likewise explains the full-state first-step
gain through interface transport while the originally perturbed hidden block
remains contractive.

## Lean boundary

`Book4ImaginationDetector.ReproduciblePackage` separates package readiness from
candidate detection. Its negative-result theorem proves that provenance,
hashes, thresholds, runtime replication, and controls can form a valid
deliverable even when the detector does not fire.

The older non-identifiability theorem remains decisive: even strict observable
evidence cannot identify an unobserved imaginative traversal without an
additional bridge.

## Authority boundary

The external FabricPC checkout remains ignored and is not bundled or audited as
a live directory by this portable package. A separate local inspection currently
shows the pinned checkout is clean. The receipt records no checkout-state claim
and records that no upstream push is authorized. Any eventual proposal to
FabricPC maintainers should be reviewed by a human and presented as an
experimental instrument with falsifiers, not as a conclusion about FabricPC’s
ontology.
