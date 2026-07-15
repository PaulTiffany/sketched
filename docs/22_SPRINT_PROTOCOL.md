# Sprint protocol (Lean PS program)

How sprints strengthen the Lean layer without weakening the epistemics.
First enacted 2026-07-11 (Sprint A: Book 2; Sprint B: LPS-O4
contraction).

**Execution mode (refined 2026-07-11, second pass): cheap workers,
lead verification.** The first enactment forked lead-model (Fable)
subagents; both burned the monthly inference budget in their READING
phase and died with zero artifacts. The refined economics:

- **Workers are non-lead instances** (Sonnet-class), explicitly pinned
  via the Agent call's model parameter — never inherited.
- **Workers carry no prior context and do no corpus archaeology.** The
  lead slices exactly the anchors a packet needs — verbatim statements
  plus current shas — with `verification/tools/atlas_slice.py` and
  ships the slice WITH the prompt. Reading phases are where the budget
  died; the slice removes them.
- **The lead (Fable) checks all end work**: review, build, fix, wire,
  audit, report. Worker output is a draft, not a merge.

The protocol below (verbatim gate → own file → build clean → wiring
proposal → serial merge → audits → signature) is unchanged; only the
inference distribution moved.

## The shape

```
Paul picks the direction (queue: docs/20_PS_LEAN_QUEUE.md; debts: docs/18)
  -> orchestrator cuts DISJOINT work packets, one agent each
  -> each agent: verbatim gate -> draft its OWN .lean file -> lake build
     until zero errors, zero warnings -> emit a WIRING PROPOSAL (JSON)
  -> orchestrator merges proposals SERIALLY into the shared registries
     (root prints, gen_receipt STMT, coverage maps, bindings with
     computed shas, ledger rows), reruns gen_receipt + full suite
  -> Paul signs the attestation receipts (the machine never fills them)
```

## Why this preserves the covenant

Agents are single-axis knobs; the suite is the second knob; Paul is the
third and the only one that accepts. Concretely:

- **Propose, never merge.** An agent's only repo writes are its own new
  `.lean` file(s). Everything shared — bindings, ledger, maps, the root
  module, gen_receipt — moves only through the orchestrator, serially,
  after audits. Parallel agents therefore cannot collide on registries,
  and no registry row exists that a suite stage didn't check.
- **The kernel is the reviewer.** Lean output is the one artifact class
  where agent speed costs no trust: `lake build` + `#print axioms` +
  the wiring audit bound what a hallucination can do. Prose claims
  would not enjoy this property; that is why sprints target Lean.
- **Hedges stay constituted.** Sprint prompts carry the standing rules:
  laws as structure fields, never Lean axioms; unreachable anchors come
  back as named open rows, not silence; partial progress on an O-item
  updates its evidence, it does not fake a closure.
- **Ground rules baked into every prompt:** no git init (genesis is
  reserved), the Principia corpus is read-only, nothing is published,
  lake lock contention is retried not fought.

## Cutting packets

- Disjoint by FILE: each sprint owns fresh module(s); two sprints never
  share a target file.
- Sized by the queue: a whole small book (book2 = 16 claims) or one
  named ledger debt (LPS-O4) is one packet. The queue doc orders
  candidates by open surface; small books are complete-book wins.
- Each prompt includes: the verbatim gate (principia atlas path), the
  house-style files to read first, pinned-toolchain gotchas learned so
  far, the deliverable schema (lean file + proposal JSON + summary),
  and the tiered target (minimum honest slice before stretch).

## Merge duties (orchestrator checklist)

1. Read the agent's `.lean` file — review, don't trust; build it.
2. Apply proposal: root imports + prints, STMT glosses, map rows /
   new `bookN_lean_map.json`, bindings (compute shas live from the
   principia atlas), ledger rows.
3. `python selfcompile/gen_receipt.py` (receipt from the real build).
4. Full suite (`verification/run_all.py`) + selfcompile gate + npm —
   the wiring audit now catches any print/gloss/receipt drift
   mechanically.
5. Report to Paul with the honest deltas; receipts await signature.

## Known limits

- One lake build dir: concurrent agent builds contend; prompts say
  retry after 60s. Keep sprint rounds to 2–3 agents until this hurts.
- The coverage tool is book5-specific; other books' maps are counted by
  ps_queue but not yet class-validated (generalization is named work).
- Agents inherit no session memory: every prompt re-states the rules.
  The rules living in this doc is what makes that cheap.
