# Principia alignment contract

The release architecture is directional without being reductive:

```text
Lean program -> typed Atlas correspondence -> human-facing Principia LaTeX
```

Lean is the validity boundary for formal claims. `verification/ps_alignment.json`
is the claim-level correspondence layer keyed to the existing authoritative Principia
Atlas. The LaTeX remains the semantic and literary source. Equality between these
layers is neither expected nor asserted.

## Status vocabulary

- `exact`: the stated formal claim is directly supported by the named receipt declarations.
- `constructed`: Lean explicitly constructs the claimed object.
- `conditional`: the named theorem is complete under every premise listed in `premises`.
- `countermodel`: a concrete formal witness bounds a stronger claim.
- `refuted`: the proposed implication is formally false; `countermodels` names the proof.
- `open_bridge`: a typed implication is genuinely unconstructed.
- `interpretive`: philosophical, explanatory, analogical, or synthetic prose grounded in formal results but not identical to a theorem.
- `poetic`: intentionally non-propositional/operator-poetic material outside theorem certification.

The last two statuses are not failures. They carry `kernel_certified: false` so that
formal silence cannot be mistaken for rejection and literary expression cannot be
mistaken for a kernel theorem.

## Mechanical contract

`verification/tools/alignment_audit.py` checks that every alignment entry:

1. resolves to the authoritative Atlas file, anchor, line, and normalized statement hash;
2. uses the established status vocabulary;
3. resolves every formal witness and countermodel against the committed Lean receipt;
4. exposes premises for conditional claims;
5. connects negative boundaries to countermodels and the claims they bound;
6. prevents interpretive, poetic, and open material from claiming kernel certification;
7. agrees with an active coverage-map status when one is declared; and
8. rejects stale missing-field, reverse-lift, and false full-Gleason wording.

A minimal `verification/ps_alignment_atlas_projection.json` carries only the reviewed anchor metadata and hashes, so a clean Sketched checkout can enforce the contract without copying manuscript prose. When the authoritative Atlas is present, the auditor cross-checks that projection against it.

Bindings continue to provide declaration-to-source drift protection and human
attestation. Coverage maps continue to summarize whole anchors. Source obligations
continue to record repair and downstream discharge. The alignment registry adds only
the missing claim-level typing needed when one literary anchor contains several
formal statuses.

## Observer-boundary alignment

The aligned quantum cluster records two complementary Gleason-facing half-bridges.
The source-to-readout half runs from normalized pure state through Hermitian density
and fixed observer resolution. The readout-to-representation half constructs a
Hermitian or quadratic representation when its explicit certificate laws are
available. The second half represents the values visible at the observer surface; it
is not an inverse of the first and does not recover an originating source state.

Their seam is a proved non-invertible observer lowering. Global phase supplies a
concrete collision, while the frame and resolution countermodels block unconditional
reverse reconstruction. Finite partial trace is separately recorded as an exact
reduction preserving trace and represented local expectations.

Temporal direction has its own exact Cacophony-facing backbone: finite-support
compression obeys norm-fracture bounds and a strict diagonal cost gap; staged paths
carry telescoped per-step displacement; and JKO minimization pays transport cost from
free-energy decrease. Convergence is conditional on the registered summability,
completeness, preservation, or Lyapunov-descent premises. What remains `interpretive`
is the functionally interpretive physical mapping of quantum decoherence/noise onto
this general directed cost-and-loss geometry, not temporal becoming itself. Like a
weather map, that correspondence is operational and testable without being a kernel
identity between domains.

The Book VII attractor reading and Hilbert-cross-section scholium remain explicitly
interpretive. `Operatio` is registered as poetry: it is preserved as a semantic
carrier rather than treated as a theorem-shaped debt.

## Remaining editorial inventory

This pass is complete for passages directly changed by the final Lean sprint. It is
not a claim of book-wide semantic review. `verification/ps_alignment_review.json`
lists the remaining individually inspected Appendix C passages whose broader human
mathematics or interpretation should receive later editorial judgment. The inventory
is anchored and reasoned; it is not a keyword-generated queue.