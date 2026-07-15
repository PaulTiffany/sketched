# 14 · EULA math brief — constraints for drafting the performative terms

**Audience:** the drafting agent (OmegaClaw) filling the Part B slot of
[`../EULA.md`](../EULA.md), and the humans holding final edit at the
break-points. **Purpose:** feed the drafter the mathematics first, so the
plain-language terms are *performances of theorems*, not vibes. Every
obligation below has a paper anchor (`forcing_correspondence_v15.tex`,
atlas node ids), a code anchor (verified each suite run by
`verification/tools/operator_audit.py`), and a mechanization status.

The contracts framing is exact, not decorative: a contract is an exchange
of obligations whose **performance** can be audited. Here the audit is
literal — `python verification/run_all.py` is the performance monitor.
Part A's clauses are enforced in code; Part B must describe that same room
in human language without promising a different room.

## 1. What the contract *is*, mathematically

The paper proves the shared origin of disjoint observer surfaces is the
unique depth-0 condition — the void, operationally localhost
(`lem:void`, `prop:zeroth`; both machine-verified in Lean). The void is
**neutral**: commensurability, not authority. The EULA is the
**constitutive act** that seats the human at that origin
(`docs/12`, "The EULA places the human in the surface"). This is the one
normative move the math does not make for you — so the drafted terms must
state it as a *grant by contract*, never as a mathematical consequence.

Operationally: `ZeroOrderAnchor.eulaAccepted` must be true before any
witness trace validates (`src/witness/witness.ts#anchor`,
`src/witness/validate.ts#validateTrace`). Acceptance of the terms is not
paperwork — it is the write that turns a neutral origin into
authority-origin. Draft Part B so the reader understands: *by accepting,
you are seated; nothing routes except relative to you.*

## 2. Clause obligations (draft against these, in order)

| # | The terms must say (in plain language) | Math anchor | Code anchor | Verified |
|---|---|---|---|---|
| 1 | You are seated at the shared zero-point by this contract; the point itself is neutral until you accept | `lem:void`, `prop:zeroth` | `witness.ts#anchor` | Lean (core) |
| 2 | Nothing an agent sends you is your state or anyone's state — it is a **reconstruction** of an exported residue, and the loss is declared | `thm:factor`, `thm:nonid` | `residue.ts#decodeResidue` (branded type: the claim is a compile-time fact) | Lean (mathlib) |
| 3 | What leaves your session is a **projected residue**, never the "whole feel of it"; the projection is an explicit whitelist you can read | `thm:nonid` (i)–(iii) | `residue.ts#project`, `#encodeResidue` | Lean (mathlib) |
| 4 | Every flow interval begins at a human gate; frame-level changes may proceed without repeated consent only inside that interval's angle, lease, and cumulative budget | `def:wit`, `lem:margin` | `flow/engine.ts#openChannel`, `#advanceOne` | Lean (core) + vitest |
| 5 | Your presence is **structurally** untouchable by agents — not "denied for now" but *torsion*: refusable at every refinement, permanently | `rem:torsion` (atomic case) | `consent.ts#ConsentPolicy` (human-layer guard) | Lean (core, atomic) |
| 6 | You hold the interrupt: revocation closes the active interval, clears dependent generated context, and never clears your presence | `prop:chalked` (revision authority) | `flow/engine.ts#interrupt` | vitest |
| 7 | The visible budget and margin meters are computed from cumulative trace expenditure; they do not silently refill during an interval | `lem:margin` (path budget) | `flow/engine.ts#channelMeters` | Lean (core) + vitest |
| 8 | The full history is yours to read, export, verify, and replay | `def:wit` (witness ledger) | `flow/engine.ts#exportTrace`, `#verifyTrace` | vitest |
| 9 | The system witnesses and requests; it cannot open or enlarge its own interval | non-actuation boundary (paper §15) | `flow/engine.ts#openChannel` (human UI action) | architectural |

### Human-floor calibration boundary

The Lean kernel proves the path-budget implication: cumulative drift bounded by
`epsilon` keeps a trajectory above its margin floor. The Flow MVP0 instantiates
that arithmetic with event costs and displays the unspent budget. It does **not**
prove that event cost is a physical, cognitive, or spectral measurement. That
identification remains calibration data and must be described as an operational
meter, not a theorem about human perception.

STEP and FLOW are scheduler presentations over the same `advanceOne` transition;
their trace equivalence is tested in Vitest. The current harness does not model a
continuous-time process. It models discrete refinements occurring below a human
interaction floor and bounded intervals at which human authority is exercised.

## 3. Vocabulary discipline (from docs/12 — binding)

- Never use "forcing" loosely. Two senses exist: **control forcing**
  (say "coordination") and **logical forcing** `⊩` (do not claim it; the
  calibration queue is open). Prefer **coordination, consent,
  stabilization, witness**.
- "Channel" means *the admissible region plus the authority to move in
  it* — a grant, bounded, revocable at exit.
- "Reconstruction, not possession." "Residue, not ceiling." These pairs
  are load-bearing; keep them verbatim if used.

## 4. MUST NOT — claims the terms may never make

1. **No identity transport.** Never imply the user (or agent) receives
   anyone's actual state. `D_B(E_A(T_A x)) = x` requires the named
   equality conditions (`thm:nonid` (i)–(iii)) which this system does not
   and will not certify.
2. **No autonomous closure.** No clause may grant, or read as granting,
   an agent the right to execute unwitnessed or self-approved mutations.
3. **No occupancy.** No clause may describe collaboration as a shared
   canvas or shared mind; collaboration is encoded residues crossing a
   public medium (`thm:factor`).
4. **No discharge of (C).** Never state that Sketched *implements* the
   paper's forcing semantics. It realizes the witness discipline; the
   calibration queue (Assumption 2, `asm:calibration`) is open, and
   `docs/13_OPERATOR_MAP.md` marks exactly which operators are realized
   vs. target. Presenting a target as shipped is a ledger violation.
5. **No weakening of Part A.** Part A wins every conflict. If a drafted
   sentence is in tension with Part A, the sentence is wrong.
6. **No new ontology.** Do not introduce entities (souls, minds,
   presence-fields) the math does not define. The paper's appendix
   firewall applies: symbolic readings are interpretive, not operational.

## 5. Drafting protocol

1. Read `PHILOSOPHY.md` for voice, `docs/13_OPERATOR_MAP.md` for the
   current realized/target split, and this brief for semantics.
2. Fill the Part B slot in `EULA.md` clause-aligned to §2 above — one
   plain-language paragraph per row is enough; cite nothing, promise
   nothing beyond the rows.
3. Leave `TODO(human)` where judgment is needed. Humans hold final edit
   at the break-points.
4. After drafting, run `python verification/run_all.py` and
   `npm test && npm run build`. A drafted EULA that required changing a
   Part A clause or an operator status to make its language true has
   failed the brief.
