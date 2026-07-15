# Verification toolchain for *Forcing Correspondence*

Mechanical checks that treat the paper's TeX source as a formal dependency
object rather than prose. By default the suite targets the highest-versioned
`forcing_correspondence_v*.tex` in the repo root; pass an explicit path as
the first argument to `run_all.py` (or to the individual tools) to audit an
older version. The goal is a theorem-engineered
artifact: dependency atlas, loop detector, status-ledger auditor, and a
finite model checker for the forcing kernel.

## Layout

```
verification/
  run_all.py            run every stage; nonzero exit on fatal findings
  atlas.json            generated: the theorem-dependency atlas (each node
                        carries statement_sha, a label- and whitespace-
                        insensitive content hash of its statement)
  bindings.json         formal artifacts pinned to the statement hashes
                        they were transcribed/attested against
  leanps_ledger.json    Lean PS research ledger (schema + Lorentz + forcing
                        instances; P/D/S/M/C/O with debt closure) — the
                        human view is docs/18_LEAN_PS_LEDGER.md, generated
  attestations/         anchor-attestation receipts: every anchor movement
                        needs one, and only a human can accept one (the
                        genesis receipt ships proposed — the founding
                        signature is deliberately blank)
  FINDINGS.md           findings from the latest full run against v14
  tools/
    atlas_extract.py    TeX -> atlas.json (nodes, ref/symbol edges,
                        assumption tokens, external cross-document refs)
    loop_detect.py      C1 cycles (Tarjan), C2 forward refs, C3 smuggled
                        assumptions, C4 targets-used-as-proved
    ledger_audit.py     C5: parses the status-ledger tabular; legend
                        violations, P-without-proof, transitive
                        assumption-closure vs the Consumes column
                        (P/D/S rows must join the atlas; M/C/O rows are
                        named debts and may live in prose)
    atlas_viz.py        renders atlas.json as atlas.html: interactive
                        SVG dependency graph, section swimlanes, status
                        colors, hover-highlighted neighborhoods
    operator_audit.py   the math<->engineering trace: checks every
                        'realized' entry of operators.json against the
                        atlas (math side) and the TypeScript exports
                        (code side); regenerates docs/13_OPERATOR_MAP.md
    binding_audit.py    staleness sensor for hand-transcribed statements:
                        checks every binding in bindings.json (Lean
                        theorems, kernel checks, witness TS) against the
                        atlas's per-node statement_sha; a paper edit that
                        changes a bound statement becomes BINDING_STALE
                        instead of a silently-green kernel. Re-anchoring is
                        receipt-gated: --stamp refuses without an accepted
                        receipt in attestations/ covering exactly the
                        pending moves (it writes a proposed one instead);
                        the machine never fills the acceptance fields
    atlas_diff.py       change manifest between two paper versions:
                        ADDED/REMOVED, RENAME_CANDIDATE (hash-identical),
                        STATEMENT_CHANGED, TYPE_CHANGED (promotions),
                        STATUS_CHANGED, RETITLED; a manifest, not an audit
                        (always exit 0)
    contribution_audit.py  checks reserved authorship regions and accepted
                           contribution receipts before protected prose ships
    book5_lean_coverage.py  Principia Book 5 anchor-to-Lean coverage projection
    ps_queue.py         the whole-Principia work queue (ledger LPS-O5):
                        claim-bearing atlas nodes per book vs the coverage
                        maps and dual-source bindings, sorted by open claim
                        surface; regenerates docs/20_PS_LEAN_QUEUE.md
    leanps_wire.py      wiring auditor: a verified theorem must join the
                        root #print axioms, the gen_receipt gloss, and the
                        generated receipt consistently (gen_receipt
                        silently intersects the first two); enumerates the
                        exact missing rows and lists unwired helpers
    leanps_audit.py     Lean PS research ledger: validates
                        leanps_ledger.json (statuses, deps, artifact/decl
                        existence), computes the transitive M/C/O debt
                        closure mechanically, regenerates
                        docs/18_LEAN_PS_LEDGER.md
  kernel/
    spine.py            finite posets, sieves, J_nn (dense topology),
                        generated J_adm, recursive Kripke-Joyal forcing
    polarity.py         formula polarity classifier
    model_checker.py    experiments E1-E7 on the 7-condition spine model
    sweep.py            hypothesis-mutation sweep: the kernel claims across
                        9 posets x 3 generator schemes x sampled valuations,
                        each hypothesis (M-Pers, generator density, and the
                        two Grothendieck axioms) dropped in turn; emits a
                        necessity/generalization table (see FINDINGS.md
                        section 0c for the results). Standalone research
                        instrument: not a run_all stage; exit 1 only on
                        baseline violations
    interface_model.py  finite interface model of the Hilbert-Banach bridge
                        (Principia Symbolica Book 7, statements read
                        verbatim from the principia atlas) + the forcing
                        paper's exportability conjecture: budget-limited
                        minimizer uniqueness, interpolation continuity,
                        bifurcation exactly at kappa*, contextuality defect
                        zero only at p=2, exportability x regime data
                        (FINDINGS.md section 0d). Standalone; cross-repo
                        anchored via dual-source bindings
  lean/ForcingKernel/   mathlib-free Lean 4 formalization of the abstract
                        kernel: sieves/topologies (Site.lean), KJ forcing
                        with persistence by construction (Forcing.lean),
                        Rasiowa-Sikorski + propositional Truth Lemma
                        (Generic.lean), the margin path-form lemma and the
                        machine-checked refutation of the v14 per-step
                        induction (Margin.lean). M-Pers is the
                        `Persistent` typeclass; M-Bound is the `enum`
                        surjection; the Site Bound is the `hdense`
                        hypothesis — the ledger's debts are the theorem
                        hypotheses, mechanically. Schema.lean carries the
                        Lean PS commuting interface (Commutes /
                        RelationallyCommutes / Equivariant) and the forcing
                        instance; Witness.lean the observer–refinement
                        witness kernel (Principia-anchored, axiom-free):
                        local M-Pers derived from witness restriction,
                        class-relative material persistence, the
                        preservation/reflection separation, and the
                        agreement-is-not-persistence + naturality-gap
                        countermodels (ledger LPS-O3).
  lean/ForcingAnalysis/ mathlib-backed analytic layer (Lean + mathlib
                        v4.31.0): lem:cauchy, lem:ordmet (Descent.lean),
                        thm:nonid, prop:chi (Transport.lean). First build:
                        `lake update && lake exe cache get && lake build`
                        (~7 GB of packages + cache).
  kernel/numeric_margin.py  numpy eigenvalue witness: the margin
                        countermodel in real interaction matrices, and the
                        budgeted path holding eta/2.
  kernel/fabricpc_witness.py  numpy witness for the triple-guarded
                        predictive-coding contract (FabricPCGuard.lean,
                        ledger LPS-O6): novelty floor at every beta, the
                        dark-room negative control (unguarded collapse),
                        the Moloch budget invariant with per-step KL
                        contraction, and the no-arrival fixed-point
                        offset matching delta/(eps+delta)*||u-sigma||_1;
                        emits fabricpc_witness.json
  kernel/lorentz_witness.py  numpy witness for the Lean PS physics instance
                        (ForcingAnalysis/Lorentz.lean over the Schema.lean
                        interface): equivariance at machine scale for real
                        boosts/rotations, a delta-sweep negative control
                        showing first-order structural failure off the
                        Lorentz group, the zero-map countermodel echo, and
                        the antisymmetry representation check; emits
                        lorentz_witness.json (machine-readable).
```

## Run

```
python verification/run_all.py                                   # latest version
python verification/run_all.py forcing_correspondence_v14.tex    # historical audit
```

Requires Python 3.10+; numpy for the numeric margin witness only.

## Version upgrades (the drift contract)

When a new `forcing_correspondence_v*.tex` lands, the suite retargets to it
automatically, and the label-keyed audits (ledger, operator, book) follow or
fail loudly on their own. The hand-transcribed layer is covered by the
binding audit:

1. `python verification/tools/atlas_diff.py` — read the change manifest
   (old = previous version, new = latest).
2. `python verification/run_all.py` — every binding whose statement moved
   reports `BINDING_STALE`; the suite is red until discharged.
3. `python verification/tools/binding_audit.py --stamp` — it refuses and
   writes `attestations/attest-PROPOSED.json` enumerating the exact moves.
4. Re-read each stale artifact against its new statement; re-prove or amend
   where the mathematics moved. Then accept the receipt *by hand* (real id,
   `status: accepted`, `attested_by: human`, your own `attested_at`).
5. `--stamp` again — it finds the covering receipt, applies exactly those
   moves, and records the receipt id on each moved binding. Mechanical
   detection, human discharge, receipted anchor.

## Packets for external reviewers

`python verification/tools/make_packets.py` builds three source-only zips
under `packets/` (main suite + captured RUN_TRANSCRIPT, Lean sources +
LAKE_BUILD_TRANSCRIPT, operator/TS sources + AUDIT_TRANSCRIPT) — see
`MANIFEST.md` for contents, `EXPECTED_OUTPUT.md` for what a correct run
prints, and the reproducibility-boundary table for which claims are
checked by which layer. The main suite degrades gracefully in packet mode:
the operator audit and Lean stages skip with a notice when their inputs
are intentionally absent.

## Reading the results

- `atlas.json` node fields follow the schema in the audit report
  (`source_span`, `proof_status`, `hard/statement/proof/symbol
  dependencies`, `assumptions_consumed`, `status_ledger_claim`).
- Detector error codes are documented in each tool's docstring.
- The model checker's PASS/FAIL lines mark claims the paper asserts
  unconditionally; witness lines (strictness, reachability failure,
  bivalence failure, torsion divergence) are *expected* separations that
  quantify how much the calibrated site J_adm differs from the ambient
  dense topology J_nn on a concrete model.

## Known limitations

- Ref edges only see `\ref{...}`; symbol edges cover the main macros
  (`\Stab`, `\forcesH`, `\PHeta`, `\Jadm`, `\Jwit`, `\Dadm`, `\Kt`).
  Prose-level dependencies without either are invisible.
- The `(ii)` smoothness-contract token is matched by context words; item
  (ii) of Thm nonid's equality condition is excluded by construction.
- Finite trees trivialize genericity (leaves decide everything), so the
  truth-lemma experiment E6 validates clause structure, not
  Rasiowa-Sikorski content; the Decision-Reachability obstruction is
  instead exhibited at interior nodes (E5).
