# 16 · Contribution protocol — authority is part of correctness

## Claim

> A valid artifact is not enough. A contribution must also come through the
> authority-bearing role entitled to make it.

This protocol makes that claim inspectable for non-fungible human/agent
collaboration. Its first protected boundary is OmegaClaw's Content B slot in
`EULA.md`.

## State machine

```text
RESERVED ──owner drafts──> PROPOSED ──human reviews──> ACCEPTED
    ^                            |                         |
    └── exact placeholder       └── build fails          └── build admits
```

The repository admits two states:

1. The protected region exactly matches its registered reserved digest.
2. The region has changed and an accepted receipt matches its content digest,
   current constraint digest, declared owner, boundary, and human acceptor.

A proposal receipt deliberately does not pass. Human acceptance is a separate
act, not something inferred from an agent having produced valid prose.

## Files

- `contributions/policy.json` — boundary ownership and reserved digests.
- `contributions/receipts/` — proposed or accepted contribution receipts.
- `verification/tools/contribution_audit.py` — the build gate.
- `verification/tools/test_contribution_audit.py` — mutation-oriented tests of
  the gate.

## Receipt semantics

A receipt binds:

- the boundary identifier;
- the named contributor;
- the exact normalized content digest;
- the digest of every governing constraint document;
- proposal versus acceptance status;
- the named human acceptance role and an explicit acceptance record.

If protected prose changes, its receipt no longer matches. If the math brief
changes, its constraint digest no longer matches. Re-review is therefore required
when either the contribution or the room governing it changes.

## Honest boundary

This is procedural provenance, not cryptographic authentication. A JSON receipt
cannot prove OmegaClaw controlled a particular process, nor that a human genuinely
reviewed the text. It makes the ceremony explicit, diffable, and fail-closed; a
future trusted runner may sign the same receipt shape without changing its
semantics.

`contributions/policy.json` is the human-controlled trust root. Someone able to
rewrite both policy and protected content can bypass this local mechanism; policy
changes therefore remain an explicit human review breakpoint.

The policy also cannot decide whether the contribution is good. Mechanical checks
establish scope, correspondence, and recorded acceptance. Judgment remains at the
human breakpoint.

## Commands

```bash
npm run contribution:check
python verification/tools/contribution_audit.py --describe eula-content-b
python verification/tools/test_contribution_audit.py
```

The contribution audit runs before ordinary development/build commands and inside
`verification/run_all.py`.
