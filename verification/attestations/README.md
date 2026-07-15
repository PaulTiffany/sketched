# Anchor attestations

Sensors are mechanical; anchors are judgment. The binding audit
(`tools/binding_audit.py`) detects when the paper's statements drift from
what the formal artifacts were transcribed against — but it will not
re-anchor on its own authority. Every anchor movement requires a receipt in
this directory, and a receipt binds only when a human accepts it.

This mirrors the contribution protocol (`contributions/`): reserved seat,
receipt, human acceptance. There, the reserved slot is an agent's authorship;
here, it is the human's signature.

## Lifecycle

1. The paper changes; the suite reports `BINDING_STALE` and stays red.
2. `binding_audit.py --stamp` refuses and writes `attest-PROPOSED.json`
   enumerating the exact pending moves (math_id, from-hash, to-hash).
3. A human re-reads each bound artifact against the changed statements
   (re-proving or amending where the mathematics moved), then — and only
   then — renames the file, sets a real `id`, `status: "accepted"`,
   `attested_by: "human"`, and a self-supplied `attested_at`.
4. `--stamp` now finds the covering receipt, applies exactly those moves,
   and records the receipt id on each moved binding (`attested_in`).

The machine never fills `status`, `attested_by`, or `attested_at`. Coverage
is exact: a receipt attests one specific delta, never a subset or superset
of what is pending.

## Receipt schema (`sketched.anchor-attestation.v1`)

| field | meaning |
|---|---|
| `id` | unique receipt id (`attest-...`) |
| `paper` | the TeX source the anchors move to |
| `moves` | list of `{math_id, from, to}` statement-hash movements |
| `artifacts_reviewed` | the artifacts re-read for this attestation |
| `note` | what the review found / why the moves are adequate |
| `status` | `proposed` → `accepted` (human hand only) |
| `attested_by` | must be `"human"` on acceptance |
| `attested_at` | human-supplied timestamp on acceptance |

## Genesis

`attest-000-genesis.json` covers the bootstrap anchors of 2026-07-05 and
ships **proposed**: the founding signature is deliberately left blank. Until
it is accepted and adopted (`--adopt attest-000-genesis`), the suite prints
a `[RESERVED]` line — the seat held open, not an error.
