# EXPECTED_OUTPUT — what a correct suite run prints (v15 packet)

`python verification/run_all.py` from the packet root must end with
`suite result: CLEAN` and exit 0. Stage-by-stage:

## 1. Atlas extraction
```
wrote .../atlas.json with 57 nodes: {'definition': 12, 'assumption': 2,
'lemma': 13, 'remark': 18, 'theorem_target': 2, 'theorem': 3,
'proposition': 5, 'conjecture': 2}
```
The `stated_no_proof` list must contain only definitions, assumptions,
conjectures, and `prop:chalked` (an S-status specification) — no lemma,
theorem, or P-marked proposition.

## 2. Loop detection — exactly 6 findings, all informational
Six `FWD_TARGET_INFO` lines (the unnumbered Theorem Target surveying the
later lemmas that discharge its joints — by design). **Fatal codes that
must NOT appear:** `CYCLE`, `FWD_DEF`, `FWD_PROOF`, `TARGET_AS_PROVED`,
`REMARK_SMUGGLE`, `PROSE_SMUGGLE`, `DANGLING_REF`. Exit 0.

## 3. Ledger audit — exactly 8 findings, all accepted policy
`parsed 35 ledger rows`, then eight `UNANCHORED_DEBT` lines — M/C/O rows
that live in prose (named debts, not results; the P/D/S-must-join policy
is documented in the tool). **Failure codes that must NOT appear:**
`LEGEND_VIOLATION`, `NO_PROOF_MARKED_P`, `TYPE_MISMATCH`,
`UNDERCOUNTED_CONSUMES`, `UNMATCHED_ROW`, `UNLEDGERED`.

## 4. Atlas visualization
```
wrote .../atlas.html (57 nodes, 80 edges, 11 section lanes)
```

## 5. Operator correspondence audit (packet mode)
```
src/ tree or operators.json absent — packet mode; operator correspondence
audit skipped (ships in the operator packet)
```
(In the full repo or the operator packet this instead prints
`0 findings; 18 realized + 7 target operators`.)

## 5b. Binding staleness audit
```
0 binding findings; 11 bindings checked against 57 hashed statements
(22 skipped: tree or statement source not present; absent sources: principia)
```
In the packet, bindings into `verification/lean/` and `src/` skip (their
trees ship in the Lean/operator packets), and principia-sourced bindings
skip (that atlas lives in its own repo); the 11 forcing-sourced kernel
bindings (model checker ×4, numeric margin ×1, sweep ×4, interface
model ×2) are still checked. In the full repo with C:/src/principia
present, all 33 are checked against 63 hashed statements, 0 skipped. **Codes that
must NOT appear:** `BINDING_STALE`, `BINDING_UNSTAMPED`,
`BINDING_NODE_UNKNOWN`, `BINDING_FILE_MISSING`, `BINDING_DECL_MISSING`,
`ATLAS_UNHASHED`, `ATTEST_MALFORMED`, `ATTEST_INVALID`. A `BINDING_STALE`
here means the paper's statement moved after the artifact was attested —
the intended alarm, not packet noise.

A `[RESERVED] N anchors await the human signature` line is expected info,
not a finding, while the genesis attestation
(`attestations/attest-000-genesis.json`) remains unaccepted: the seat is
deliberately held open for the human. The binding audit tests print
`Ran 12 tests ... OK`.

## 6. Finite model checker — `ALL UNCONDITIONAL CHECKS PASS`
Required PASS lines: E1 site bound, E2 persistence (both relations),
E3 positive fragment adm=>nn, E5 deciding sets order-dense, E6 truth
lemma on all branches (both relations). Required *witness* lines
(expected separations, not failures):
- E1 strictness: leaf sieve on `r` is dense but not a J_adm-cover;
- E4: `1264 divergences` between torsion-not and clause-not, minimal
  countermodel `phi=~b` at `r` — the two negation semantics are NOT
  equivalent (calibration item 6, compound case);
- E5: Decision Reachability failure — `D_phi for phi=b at 'r'` is not a
  J_adm-cover; bivalence failure — `'r' forces neither a nor ~a`;
- E7a: clause persistence broken=False (expected), truth lemma
  broken=True (expected) — M-Pers's true blast radius;
- E7b: J <= J_nn violated=True (expected) with a forcing anomaly line.

## 7. Numeric margin witness — `ALL NUMERIC CHECKS PASS`
- v14 per-step-legal path: `lambda_min` reaches `+0.000` at depth 2, with
  the line `v14 induction FAILS on real matrices (matches Lean
  countermodel)`;
- v15 budgeted path: `min lambda_min along path = 0.500` and
  `path form HOLDS (matches margin_path_form)`.

## 8. Lean stages (packet mode)
Both print a skip notice (project or packages absent). In the Lean packet
with the toolchain installed, ForcingKernel must print
`Build completed successfully` and an axiom audit where `site_bound`
depends on **no axioms**, `margin_path_form` / `per_step_bound_insufficient`
on `[propext, Quot.sound]`, and the rest on
`[propext, Classical.choice, Quot.sound]`.

## Final line
```
suite result: CLEAN
```
Exit code 0. Any deviation from the counts above (57 nodes, 6/8 findings,
1264 divergences, the PASS lines) is a regression to investigate, not
noise.
