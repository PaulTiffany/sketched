# MANIFEST — source-only verification packet (v15)

Target paper: `forcing_correspondence_v15.tex`.
**Latest-version resolution rule:** every tool, given no argument, targets
the highest-numbered `forcing_correspondence_v*.tex` in the packet root;
pass an explicit TeX path as the first argument to audit another version.

## Main packet contents

```
forcing_correspondence_v15.tex     required — the atlas/ledger tools parse TeX;
                                   the PDF cannot substitute
forcing_correspondence_v15.pdf     optional, for human reading
MANIFEST.md                        this file
RUN_TRANSCRIPT.txt                 captured run: command, OS, Python version,
                                   full stdout, exit code
verification/
  run_all.py                       orchestrator; exit 0 iff CLEAN
  README.md                        toolchain documentation
  FINDINGS.md                      audit history (v14 findings + v15 resolution)
  EXPECTED_OUTPUT.md               what a correct run must print
  bindings.json                    formal artifacts pinned to attested statement hashes
  attestations/                    anchor-attestation receipts (genesis ships proposed:
                                   the human signature is deliberately blank)
  tools/
    atlas_extract.py               TeX -> atlas.json (nodes carry statement_sha)
    loop_detect.py                 cycles / forward refs / smuggled assumptions
    ledger_audit.py                status-ledger consistency
    atlas_viz.py                   atlas.json -> atlas.html (SVG dependency graph)
    operator_audit.py              math<->engineering trace; SKIPS in this packet
                                   (needs src/ + operators.json from the operator packet)
    binding_audit.py               statement-drift sensor + receipt-gated re-anchoring;
                                   lean/ and src/ bindings SKIP in this packet
    test_binding_audit.py          contract tests for the above
    atlas_diff.py                  change manifest between two paper versions
                                   (needs two v*.tex; informational, exit 0)
  kernel/
    spine.py                       finite posets, sieves, J_nn, generated J_adm, KJ forcing
    polarity.py                    formula polarity classifier
    model_checker.py               experiments E1-E7 (exit 0 iff unconditional checks pass)
    numeric_margin.py              numpy eigenvalue witness (exit 0 iff checks pass)
    sweep.py                       hypothesis-mutation sweep across a 9-poset family
                                   (standalone; exit 0 iff baseline claims hold)
    interface_model.py             finite Hilbert-Banach bridge + exportability probe
                                   (standalone; principia-atlas bindings skip when that
                                   repo is absent)
```

Generated at runtime (may also ship as output evidence, clearly optional):
`verification/atlas.json`, `verification/atlas.html`.

## Requirements

Python 3.10+; numpy (for `numeric_margin.py` only). No other third-party
packages. Run from the packet root:

```
python verification/run_all.py
```

## Companion packets (separate, optional)

- **Lean packet** — `verification/lean/ForcingKernel/` (core Lean, no deps)
  and `verification/lean/ForcingAnalysis/` (requires mathlib) — *source
  only*: `lakefile.toml`, `lean-toolchain`, `.lean` files. No `.lake/`, no
  caches, no mathlib packages (~7 GB on first fetch — excluded by design).
  Ships with `LAKE_BUILD_TRANSCRIPT.txt` as the captured evidence of the
  Lean claims. ForcingKernel builds with only the pinned toolchain
  (`leanprover/lean4:v4.31.0`); ForcingAnalysis additionally needs
  `lake update && lake exe cache get` before `lake build`.
- **Operator packet** — `verification/operators.json`, `src/core/`,
  `src/agents/`, `src/witness/`, `docs/`, `EULA.md`, plus `package.json` /
  `tsconfig.json` so `npm install && npm test` reproduces the 23 vitest
  tests. Restores the operator-correspondence audit stage that the main
  packet skips.

## Reproducibility boundary — which claims are checked by what

| Layer | Claims | Checked by |
|---|---|---|
| Python suite (this packet) | atlas structure, no proof cycles/forward defs, ledger consistency, finite-model soundness of the forcing clauses (E1–E6), M-Pers mutation behavior (E7), torsion-¬ countermodel, Decision-Reachability failure witness | `run_all.py`, deterministic |
| Numeric witness (this packet) | margin collapse under v14 per-step control; margin preservation under the v15 budget — in real 2×2 interaction matrices | `numeric_margin.py` (numpy eigvalsh) |
| Lean core kernel (Lean packet) | sitebound, persistence+consistency, deciding density, Rasiowa–Sikorski, propositional Truth Lemma, margin path form, formal refutation of the v14 induction | `lake build` (kernel-checked; axiom audit printed) |
| Lean mathlib layer (Lean packet) | lem:cauchy, lem:ordmet, thm:nonid (2 forms), prop:chi | `lake build` with mathlib v4.31.0 |
| Operator audit (operator packet) | every "realized" math↔engineering trace points at an existing TypeScript export; targets claim no code; calibration items 1–10 all addressed | `operator_audit.py` + vitest |
| Paper-level, NOT machine-checked | M-Pers, M-Cvx, M-Cl, M-Bridge, M-Bound (modeling postulates); Assumption 1 smoothness contract and Assumption 2 calibration queue (C); quantifier layer, Reading B, strong Born (O); lem:margin's Weyl step (cited matrix analysis); lem:bw (Bourbaki–Witt, cited) | the status ledger, §16 of the paper |
