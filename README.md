# Sketched

**A local-first, witnessed stage where humans remain the authority and agents propose auditable changes.**

Sketched carries the governance model of a consent-gated drawing surface into time. Marks become time-indexed layer mutations; erasure becomes scoped revocation; every accepted or rejected proposal leaves a trace.

> **Agents propose; the surface disposes.**

The repository also houses the executable companion program for *Principia Symbolica*: a browser textbook, source-to-proof ledgers, finite and numerical witnesses, and a growing Lean formalization.

## What you can open

| Route | Surface |
| --- | --- |
| `/` | Governed drawing surface with optional, human-seated BYOK agent |
| `/stage` | Layer, timeline, consent, shake, and audit workbench |
| `/flow` | STEP/FLOW control experiment with bounded channels and replay |
| `/book` | *Forcing at the Surface*: textbook, ledger, Lean coverage, and glossary |

The application is static and local-first. It has no Sketched backend, analytics, or telemetry. Camera access and provider requests require explicit human action. Provider keys remain in browser memory and are sent directly to the selected provider; they are not stored by Sketched.

## Core commitments

- **Human authority is structural.** Agents cannot mutate or replace the human layer.
- **Consent bounds flow.** A channel has a visible scope, lifetime, and budget.
- **Shake is revocation.** It clears generated residue while preserving human presence.
- **Provenance is required.** Generated layers identify their actor, source, dependencies, and clearing rights.
- **Claims carry status.** Proved theorems, conditional models, observations, and open debts are not collapsed into one another.
- **Layering matters.** Principia coverage follows the dependency spines `3 -> 6 -> 9`, `Scholium -> 4 -> 7`, and `2 -> 5 -> 8`.

## Mission: operational epistemology for autonomous research

Sketched is building a substrate for **bounded autonomous research**. Here, autonomy means freedom to schedule and perform operations inside a declared research interval. It does not mean authority to silently expand the question, promote a hypothesis into a fact, act outside the witness surface, or deploy a result.

The Surface invariants become epistemic invariants:

- a source may compute privately, but it reaches shared knowledge only through a small, governed interface;
- hypotheses are generated layers: labeled, provisional, dependent, auditable, reversible, and challengeable;
- scope, time, perturbation, and cumulative cost are explicit research budgets;
- STEP and FLOW may change cadence, never meaning;
- negative results and failed traversals remain evidence rather than being smoothed away;
- proofs, measurements, interpretations, and source debts retain distinct statuses; and
- no agent may autonomously close the loop from its own output to an authoritative claim or external action.

The intended research cycle is:

> source -> propose -> authorize -> execute -> witness -> challenge -> classify -> human checkpoint

Operations can occur out of order, but an out-of-order run is not recognized as a closed result until its missing provenance, authorization, and validation edges are supplied. The detailed contract and current enforcement matrix live in [`docs/25_OPERATIONAL_EPISTEMOLOGY.md`](docs/25_OPERATIONAL_EPISTEMOLOGY.md).

## Current status

- React/Vite application with **49 passing tests** and a passing production build.
- Principia Lean program: **476 of 476** claim-bearing atlas nodes mapped; the exact claim frontier is closed.
- **1,345** verified Lean declarations, with no `sorry` admitted in the tracked program.
- Core Lean kernel and the mathlib-backed analysis layer build successfully (8,695 analysis jobs in the current environment).
- Books 1-3 and the Scholium are complete. Book 4 is complete; Books 5-9 and the appendices have complete claim-bearing atlas coverage; hardening and source-debt repair remain active.
- FabricPC 0.3.1 has a pinned external installation receipt, 269 passing upstream tests, and a successful CPU MNIST run. The next bridge step is comparing real FabricPC trajectories with the proved guard contracts.

Coverage is not presented as completion. The generated queue and source-debt register are the authority:

- [`docs/20_PS_LEAN_QUEUE.md`](docs/20_PS_LEAN_QUEUE.md)
- [`docs/22_PS_LEAN_FRONTIER.md`](docs/22_PS_LEAN_FRONTIER.md) — every open claim by source anchor and dependency
- [`docs/23_PS_BINDING_LEDGER.md`](docs/23_PS_BINDING_LEDGER.md) — human projection of the machine-readable SHA bindings
- [`docs/21_PS_SOURCE_OBLIGATIONS.md`](docs/21_PS_SOURCE_OBLIGATIONS.md)
- [`docs/18_LEAN_PS_LEDGER.md`](docs/18_LEAN_PS_LEDGER.md)

## Quick start

Prerequisites: Node.js 18+ and npm. Python 3.10+ is required for the verification tools; Lean development uses the toolchains pinned under `verification/lean/`.

```bash
npm install
npm run dev
```

Open <http://127.0.0.1:5173>. Useful gates:

```bash
npm test
npm run build
python verification/run_all.py
```

The full verification runner includes Python, TypeScript, numeric witnesses, the core Lean kernel, and the mathlib analysis project. The first Lean analysis build downloads a substantial mathlib cache; see [`verification/README.md`](verification/README.md) before running it.

## Repository map

| Path | Purpose |
| --- | --- |
| `src/core/` | Stage, layers, timeline, consent, provenance, and shake |
| `src/agents/` | Proposal protocol, gatekeeper, deterministic and BYOK seats |
| `src/draw/`, `src/flow/`, `src/book/` | Public application surfaces |
| `book/` | Source chapters and executable labs |
| `public/book/` | Generated browser projection of the book and ledgers |
| `verification/` | Audits, bindings, witnesses, coverage maps, and Lean projects |
| `selfcompile/` | Grounded lesson/compiler experiments |
| `docs/` | Architecture, ADRs, contracts, correspondence, and roadmap |

FabricPC is intentionally not vendored. Its exact checkout and environment are recorded in [`verification/fabricpc_install_receipt.json`](verification/fabricpc_install_receipt.json), and the formal bridge is described in [`docs/17_FABRICPC_BRIDGE.md`](docs/17_FABRICPC_BRIDGE.md).

## Read next

- [`PHILOSOPHY.md`](PHILOSOPHY.md) - narrative and north star
- [`docs/00_PROJECT_THESIS.md`](docs/00_PROJECT_THESIS.md) - builder-facing thesis
- [`docs/02_ARCHITECTURE.md`](docs/02_ARCHITECTURE.md) - implementation map
- [`docs/10_ROADMAP.md`](docs/10_ROADMAP.md) - active milestones and frontiers
- [`docs/11_CONTROL_SURFACE.md`](docs/11_CONTROL_SURFACE.md) - knobs, channels, angular access, and coordinated shake
- [`book/README.md`](book/README.md) - executable pedagogy layer
- [`docs/12_FORCING_CORRESPONDENCE.md`](docs/12_FORCING_CORRESPONDENCE.md) - theory correspondence and non-actuation boundary

## Public media

Certified video metadata, posters, subtitles, and provenance are retained. MP4 files generated with the Microsoft Edge online TTS endpoint are withheld until their narration is replaced using a redistribution-cleared path. See [`ASSET_ATTRIBUTION.md`](ASSET_ATTRIBUTION.md) and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## Contributing and security

Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before changing proof mappings, contractual regions, or human-layer invariants. Report security or privacy issues according to [`SECURITY.md`](SECURITY.md), not in a public issue. `EULA.md` is an application-level session contract; it does not replace the repository license.

## License

Copyright (c) 2026 Paul Carver Tiffany III. Released under the [MIT License](LICENSE). Third-party material remains under its stated license.
