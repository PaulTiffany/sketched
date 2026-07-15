# 09 · Safety and Consent Boundaries

Practical rules. These are not aspirations — they describe how MVP-0 actually
behaves, and they are the constraints any contribution must keep.

## Hard rules

- **No camera/mic access without an explicit user action.** MVP-0 never calls
  `getUserMedia`. `webcam`/`screen`/`rear`/`360` modes are declared but not
  implemented, and would require an explicit user gesture + OS/browser grant.
- **No uploads by default.** There are no network calls in the app. The dev
  server binds to `127.0.0.1`.
- **No hidden recording.** Nothing captures or persists frames. `captures/` and
  `recordings/` are git-ignored placeholders for a future, opt-in export path.
- **No background agent execution.** Agents only run when explicitly driven
  (e.g. the "Mock agent propose" button). Nothing loops on its own.
- **No silent persistence of personal video.** MVP-0 has no persistence at all.
- **No deepfake / person-substitution path.** It does not exist and must not be
  added. Generation happens _around_ presence, never _as_ a person.
- **No claim that generated layers are real.** Generated layers are provisional
  hypotheses, labeled as such, and always shakeable.
- **All agent outputs are provisional and shakeable.** Anything an agent creates
  can be revoked with shake; human presence cannot.
- **No secrets in the repo.** No API keys, tokens, or credentials. `.env*`,
  `*.pem`, `*.key` are git-ignored.

## Consent model

- The human's own actions never require consent — the human is the authority.
- Agent actions require a consent decision from the active `ConsentPolicy`:
  - `AutoConsentPolicy` — auto-grants agent actions on generated state (good for
    the local demo).
  - `ManualConsentPolicy` — denies agent actions until a specific proposal id is
    explicitly granted (wire to a UI prompt for a stricter mode).
- **No policy can grant an agent access to human presence.** The
  `humanLayerGuard` denies it before any policy logic runs.

## If a change would break a rule

Stop. A feature that needs the network, a secret, background autonomy, or camera
access without explicit user action is out of scope for MVP-0 and belongs in a
roadmap direction with its own consent design — not a quiet addition.
