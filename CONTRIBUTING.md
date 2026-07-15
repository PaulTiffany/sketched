# Contributing to Sketched

Thank you for helping improve Sketched and its Principia Symbolica Lean program.

## Before opening a change

1. Keep claims aligned with their cited Principia source and preserve the repository's distinction between proved theorems, modeled assumptions, and interpretive commentary.
2. Do not add secrets, personal recordings, generated build trees, dependency directories, or API keys. Provider keys must remain user-supplied and memory-only.
3. Preserve human authority, provenance, consent, and revocation invariants.
4. For autonomous-research changes, name the affected E1-E10 invariants, the granted scope, claim-status transitions, challenge/negative controls, and the receipt that closes the work. Do not promote an `enforced-slice` or `target` by prose alone; update the operational-epistemology register and satisfy its audit.

## Verify your change

For application changes, run:

```bash
npm install
npm test
npm run build
npm run epistemology:check
```

For verification or Lean changes, run the relevant audit described under `verification/`; the full verification entry point is:

```bash
python verification/run_all.py
```

Open a focused pull request explaining the intent, verification performed, and any remaining source or proof obligation. By contributing, you agree that your contribution is licensed under the repository's MIT License.
