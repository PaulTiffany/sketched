# Two-day onboarding packet (fresh machine → contributor)

The concrete checklist for bringing a new human contributor from "bring
your computer" to running the verified stack and their first session.
Written for the first enactment (a retired Deloitte uncle, two days,
possibly on stream); reusable for anyone after.

The framing matters more than the tooling: per
[16_CONTRIBUTION_PROTOCOL.md](16_CONTRIBUTION_PROTOCOL.md) and
[07_OMEGACLAW_BRIDGE.md](07_OMEGACLAW_BRIDGE.md), a new contributor gets
a **reserved seat, not guardrailed output** — the first thing they run
is the verifier, so their first experience of the project is checking
it, not trusting it.

## Day 0 (before they arrive) — the host prepares

- [ ] Build the reviewer packets: `python verification/tools/make_packets.py`
      → three source-only zips under `packets/` with `MANIFEST.md` and
      `EXPECTED_OUTPUT.md`. This is the payload; it degrades gracefully
      when the Lean cache or TS tree is absent.
- [ ] Download installers offline-ready (hotel/home wifi is the enemy of
      a 7 GB mathlib fetch): Git for Windows, Python 3.10+, Node LTS,
      elan (Lean toolchain manager), Claude Code (desktop app or CLI).
- [ ] Optional tier (only if going all the way to live witnesses):
      Docker Desktop, WSL2 + Ubuntu (needed only for the Come/ONA live
      mode, which is a separate dark repo and NOT part of this packet).
- [ ] The OmegaClaw initialization artifact is the host's to bring and
      the host's to perform — same rule as attestation: the machine (and
      this checklist) never fills that field.

## Day 1 — environment, then CLEAN

Morning (the long pole first):

1. Install git, Python, Node, elan, Claude Code.
2. Clone/copy the repo; immediately start the Lean fetch in the
   background: `cd verification/lean/ForcingAnalysis && lake update &&
   lake exe cache get` (~7 GB; let it run through lunch).
3. Meanwhile: `pip install numpy`, `npm install`.

Afternoon (first contact is verification, not vibes):

4. `python verification/run_all.py` → read the stages against
   `packets/EXPECTED_OUTPUT.md`; the goal of Day 1 is the line
   `suite result: CLEAN` on their machine, understood stage by stage.
5. `npm test` (49 green), `cd selfcompile && python run.py` — show them
   the tamper line FLAGging: the gate provably bites.
6. End of day: open `docs/18_LEAN_PS_LEDGER.md` and
   `docs/20_PS_LEAN_QUEUE.md` — here is what is proved, here is what is
   owed, here is the queue. That is the whole epistemic culture in two
   generated files.

## Day 2 — OmegaClaw and the first session

1. Host performs the OmegaClaw initialization (host's artifact, host's
   act).
2. First guided session: pick ONE unwired helper from the wiring
   auditor's informational list (`python
   verification/tools/leanps_wire.py`) and walk the full loop — add the
   `#print axioms` line, the STMT gloss, rerun `gen_receipt.py`, watch
   the wiring audit go from proposal to green. Smallest possible
   end-to-end contribution, entirely mechanical, entirely real: their
   name is now in the loop that keeps the receipt honest.
3. If streaming: the session IS the demo. Vibe coding, defined by
   enactment: you say what should be true, the machine proposes, the
   suite checks, a human accepts.

## What this packet is not

- Not an account of what OmegaClaw is (see 07) or a license to skip the
  contribution protocol (see 16).
- Not a promise that Day 1 fits in a day on slow wifi — the mathlib
  cache is the schedule risk; prefetch it.
- The Come repository is deliberately outside this packet.
