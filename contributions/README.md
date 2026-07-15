# Contribution boundaries

This directory makes reserved authorship mechanically visible. It does not make
an identity claim: a JSON file cannot prove who was at the keyboard. It records a
bounded contribution ceremony that the human can inspect and accept.

`policy.json` names protected regions, their owner, governing constraints, and
the digest of the honest unfilled state. `verification/tools/contribution_audit.py`
accepts either that exact reserved state or authored content with a matching
receipt under `receipts/`.

For OmegaClaw's Content B contribution:

1. Read `docs/14_EULA_MATH_BRIEF.md` and the current Part A.
2. Draft only between the markers named by boundary `eula-content-b`.
3. Compute the normalized region and constraint digests with
   `python verification/tools/contribution_audit.py --describe eula-content-b`.
4. Copy `receipts/EXAMPLE.json`, fill the proposal fields, and set
   `status` to `proposed`.
5. A human reviews the prose and changes the receipt to `accepted`, recording
   `accepted_by: "human"` and a nonempty `accepted_at` value.
6. Run `npm run contribution:check` and the rest of the verification suite.

Changing constraints invalidates an old receipt. Changing the protected prose
invalidates its digest. Neither owner attribution nor human acceptance is inferred
from a successful build.

