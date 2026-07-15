# Sketched roadmap

This roadmap names concrete frontiers without turning maturity into a badge. Every milestone must preserve human authority, explicit consent, provenance, revocation, and honest claim status. Work may proceed out of order, but it must not be reported as a later-layer result until its prerequisites are recognized.

## Foundational mission

Sketched applies the Surface invariants to autonomous research. An agent may range freely inside a bounded research channel, but it may not grant itself a wider angle, erase dependency history, promote its own output, or cross from witness into actuation. Research autonomy is operational freedom under an epistemic contract, not sovereign authority over truth.

The normative contract is [`25_OPERATIONAL_EPISTEMOLOGY.md`](25_OPERATIONAL_EPISTEMOLOGY.md). Roadmap work must name which of its invariants it preserves and what receipt closes the work.

## Snapshot

| Track | Current state | Next closure |
| --- | --- | --- |
| Public repository | MIT license, public README, security and contribution policy, clean candidate set | Initial reviewed commit, push `main`, enable hosted security controls |
| Governed application | Draw, stage, flow, book, audit, BYOK seat; 49 tests | Harden provider/camera boundaries and add deployed smoke tests |
| Autonomous research protocol | Surface invariants and proof/debt ledgers exist in separate subsystems | Introduce one receipted research-run schema and end-to-end reference run |
| Principia coverage | 406/476 mapped; Scholium complete; 4 source obligations | Work the largest honest gaps while respecting dependency spines |
| Lean kernel | Core and 8,630-job analysis build pass; 1,047 declarations | Convert mapped/conditional coverage into stronger typed bridges |
| Fuzzy calculus / SRMF | Operator and perturbation structures formalized across Book 4 modules | Calibrate executable trajectories and assemble operator-level integration tests |
| FabricPC bridge | External 0.3.1 CPU install, 269 tests, MNIST 98.13% | Compare real trajectories with novelty, budget, and no-arrival guards |
| Public media | Visuals cleared; Edge-TTS MP4s withheld | Regenerate narration through a redistribution-cleared local or paid service |

Generated status files supersede this snapshot when numbers change:

- [`20_PS_LEAN_QUEUE.md`](20_PS_LEAN_QUEUE.md)
- [`21_PS_SOURCE_OBLIGATIONS.md`](21_PS_SOURCE_OBLIGATIONS.md)
- [`18_LEAN_PS_LEDGER.md`](18_LEAN_PS_LEDGER.md)

## Milestone 0 - public launch

- Create an intentional initial commit on `main` and inspect the complete file list.
- Create or confirm `PaulTiffany/sketched`, push `main`, and enable secret scanning and private vulnerability reporting.
- Add a minimal CI workflow for application tests/build and the fast verification gates; keep the full mathlib build as a separately cached job.
- Publish the static site only after its base path and deep-route behavior are verified on GitHub Pages.
- Replace or omit withheld narration before advertising the media surface.

Exit condition: a fresh clone can install, test, build, and explain its own verification boundary without private files or undocumented services.

## Milestone 1 - harden the governed surface

- Keep `Stage` as the only mutator and retain tests proving agents cannot mutate the human layer.
- Harden the optional provider seat: explicit request preview, visible provider destination, abort/timeout behavior, and proof that keys never enter storage or audit payloads.
- Exercise camera permission denial, stream shutdown, and page-unload cleanup.
- Add schema/version checks for persisted local state and safe migration or reset behavior.
- Test static deployment paths for `/`, `/stage`, `/flow`, and `/book`.

Exit condition: public deployment does not weaken the local-first consent and privacy boundary documented in ADR-0004.

## Milestone 2 - operational autonomous-research protocol

- Define a versioned `ResearchRun` envelope containing the human objective, source digests, initial claim status, granted angle, lifetime, cumulative budget, perturbation seed, event trace, artifacts, verdict, and promotion receipt.
- Reuse one canonical event stream for STEP and FLOW scheduling so cadence cannot alter epistemic meaning.
- Require every derived claim to name its sources, transformations, dependencies, negative controls, and current status.
- Make authority expansion a distinct denied-by-default event; a run cannot widen its own objective, tools, network access, or publication boundary.
- Separate `run completed`, `evidence reproduced`, `theorem checked`, and `claim accepted`; no program may infer the later states from the earlier ones.
- Preserve failed hypotheses, countermodels, and interrupted runs as typed outputs with receipts.
- Build one end-to-end reference run that begins at a human objective, executes within a budget, survives replay, and stops at a human promotion checkpoint.

Exit condition: the same trace reproduces the same classified evidence under STEP and FLOW, and no mutation of scope, status, or external state can occur without its designated authority event.

## Milestone 3 - continue Principia coverage by dependency spine

Coverage follows three layered programs:

1. `Book 3 -> Book 6 -> Book 9`: logic, transfinite/convergence structure, then reciprocal cognition and late-stage synthesis.
2. `Scholium -> Book 4 -> Book 7`: geometric and dynamical spine, fuzzy calculus, observer charts, curvature, identity, and regulation.
3. `Book 2 -> Book 5 -> Book 8`: thermodynamic foundations, covenant/viability dynamics, and their later consequences.

Immediate queue discipline:

- Attack open claim surfaces in the generated queue, but prefer prerequisites that unlock downstream books over isolated theorem count.
- For every new mapping, bind the exact source anchor and classify it as proved, conditional, partial, definitional, or debt.
- Keep the four tracked source obligations open until both the LaTeX statement and downstream consumption are repaired; Lean coverage alone does not erase a source defect.
- Preserve negative results and countermodels when a displayed source claim is false, ill-typed, or missing a premise.

Exit condition: remaining gaps are either kernel-proved or named, source-pinned obligations with an explicit repair owner and downstream impact.

## Milestone 4 - operational fuzzy calculus and SRMF

- Give TTDC, TTIE, TTCS, and TTPR stable typed contracts, individual regression tests, and composition laws.
- Represent the sustainable-emergence direction explicitly while allowing out-of-order operations to be modeled as unrecognized or unsustainable loops.
- Make each imagination/gluing step explicit rather than hiding it inside equality or coercion.
- Connect controlled perturbation to executable mutation experiments: declared perturbation budget, seeded mutation, observer-relative measurement, rollback, and receipt.
- Assemble the complete local Jacobian only where chart domains and overlap membership license it; keep cross-observer transport distinct from vertical refinement.

Exit condition: an engineer can run a seeded perturbation experiment and point from every operational transition to its Lean contract, budget, observer, and audit receipt.

## Milestone 5 - calibrate the FabricPC bridge

- Build a thin adapter around the pinned external FabricPC checkout without vendoring it.
- Capture real inference trajectories in a stable, machine-readable format.
- Compare those trajectories against the proved guards: novelty floor, bounded KL/Moloch budget, guarded fixed point, and no-arrival offset.
- Add negative controls that deliberately remove each guard.
- Record version, commit, backend, seed, hyperparameters, dataset digest, and measured tolerances in a content-hashed receipt.

Exit condition: the bridge moves from source-grounded analogy plus reference witness to a reproducible external-runtime calibration, without claiming that FabricPC itself proves the Principia interpretation.

## Milestone 6 - deepen the control surface

- Unify human and agent parameter gestures under a bounded `Knob` abstraction.
- Implement expiring channel/permission records with cumulative budgets.
- Enforce angular access over observation, affected layers, parameters, masks, time windows, and clearing rights.
- Require coordinated, human-inclusive motion for genuinely novel shared-space mutations.
- Extend shake to permission records, dependency cascades, context windows, and coupling groups.
- Add timeline play, pause, scrub, and interpolation without weakening logical replay.

Exit condition: bounded flow can proceed between human checkpoints, but budget exhaustion, scope violation, interruption, or shake reliably returns control to a human decision boundary.

## Longer directions

- Local, human-initiated recording/export to ignored paths.
- A real chroma/mask pipeline with provenance-bearing masks.
- File or local-socket proposal bridges for external agents.
- Multiple human witnesses exchanging encoded residues without claiming shared occupancy or identity transport.
- 360/environmental surfaces only after the same consent and revocation model survives the simpler stage.

## How work enters the roadmap

A roadmap item should name:

1. the user-visible capability;
2. the invariant it could endanger;
3. the source or specification it implements;
4. the test, theorem, witness, or receipt that will close it; and
5. what remains explicitly out of scope.

Network access, secrets, capture, background autonomy, or a new authority path requires an ADR before implementation. Add debt explicitly; never make the roadmap greener by weakening the meaning of complete.
