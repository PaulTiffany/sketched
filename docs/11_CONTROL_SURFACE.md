# 11 · Control Surface — Knobs, Channels, Angles, Coordinated Shake

This is the buildable spec for the model described in
[`../PHILOSOPHY.md`](../PHILOSOPHY.md) under **"The two-knob principle."** It
resolves the realtime tension in [`04_AGENT_PROTOCOL.md`](04_AGENT_PROTOCOL.md):
instead of gating every action, we gate the *coupling*, then let bounded motion
flow.

> Status: **design / target.** MVP-0 today gates every proposal (the crude,
> frame-by-frame version this spec replaces). "MVP-0 today" boxes mark the gap.

> **Implemented slice:** `/flow` now realizes the human-floor subset: a bounded
> channel/angle, cumulative budget and margin meters, scheduler-neutral STEP/FLOW
> clocks, out-of-angle closure, dependency-cascade interrupt, and replay-verified
> traces. Source isolation, general knobs, and coordinated novel-space creation
> remain targets. See [`15_HUMAN_FLOOR_MVP0.md`](15_HUMAN_FLOOR_MVP0.md).

## 1. The core idea

A classic two-knob drawing toy: each knob moves the stylus on one axis. One knob
alone draws only a straight line. **New space requires two knobs turning
together.** The human holds one of the knobs. Therefore new content cannot enter
the scene without coordinated motion that includes human authority.

> **Coordination is the security property.** Not per-frame approval, not free-run
> autonomy — required co-motion.

## 1.5 The isolation boundary: source views vs the host interface

The knob model only works because of *where the boundary is*. There are two zones:

- **Source view (private, sovereign).** Each source — an agent, a generator, a
  video feed — runs in its own view and may tune its own internal knobs *however
  it wants*. This is safe because it is **confined**: nothing in a source view
  touches the shared surface. It is the source's own front panel. Its internals
  are out of scope for the host.
- **Host interface (public, bounded).** The host — the localhost center, the
  human's zero-point — owns the shared surface and exposes a **small, fixed set of
  interface handles**. A source does not reach into the surface; it **accepts the
  host interface** and couples through it. That coupling point is the entire trust
  boundary.

So an agent doing "whatever it wants" inside its own view is not a risk — it is
sandboxed. The only thing that can reach the shared surface is a coupling through
the host interface, and (per §4) a *novel* mark through that interface requires
human-inclusive co-motion. The handles need not be literal knobs — a jack, a
fader, a press-and-hold, a coupling gesture all qualify. In modular-synth terms:
**the source's front-panel knobs are private; the jacks are the host interface,
and a jack is a consent boundary.**

Precedent: this is a display-compositor boundary — clients render into their own
buffers, the compositor owns the screen, no client reads or injects into another
(why Wayland exists over X11). It is also Chalked's boundary re-expressed: agents
acted only in their own color/layer; the human held the eraser.

Practically, this makes the migration in §9 an *acceptance-into-interface* job,
not an engine rewrite: define a small host interface, move source internals out of
scope behind their own views, and enforce coupling-only-through-the-host. MVP-0's
single shared-state `Stage` (agents mutate one blob, gated per action) is exactly
the thing this boundary replaces.

> **MVP-0 today:** no source isolation — agents mutate one shared `Stage`
> directly (gated per proposal). Target: sources own private views; the `Stage`
> becomes the host interface + the coordination checker.

## 2. Knob (unifies human and agent)

A `Knob` is a bounded degree of freedom on one axis. Human knobs and agent knobs
share this shape — this is what "agents are live knobs" means in code.

```ts
interface Knob {
  id: string;
  owner: Actor;              // human | agent | system
  axis: string;             // the single param it drives, e.g. "opacity", "hue"
  targetLayerId: string;    // the layer its axis moves
  range: [number, number];  // bounded travel
  value: number;            // current position on the axis
  couplingGroup?: string;   // knobs sharing a group can co-move (see §4)
}
```

- A **human knob** may open channels and couple knobs (§3, §4). It expresses
  authority.
- An **agent knob** may only turn within a granted channel, within `range`. It
  expresses bounded generation.

> **MVP-0 today:** knobs are UI-only (`KnobPanel.tsx`) and agents are a separate
> `Agent`/`Proposal` path. Target: one `Knob` abstraction, agent = live knob.

## 3. Channel (a permission record / lease)

A `Channel` is delegated authority made explicit, inspectable, revocable, and
shakeable. It is opened by a human gesture and lives for a lease.

> **Term note (aligned to the paper).** "Channel" here is the same object as the
> companion paper's *channel-margin subposet* `P_H^η`: a **grant to operate inside
> a bounded admissible region** (an angle, §5), open only while motion stays in
> margin. Delegated authority + admissible region are one thing. "Exit means return
> to zero-point" (below) is leaving `P_H^η`. See
> [`12_FORCING_CORRESPONDENCE.md`](12_FORCING_CORRESPONDENCE.md).

```ts
interface Channel {
  id: string;
  grantedTo: Actor;         // the agent-knob receiving the angle
  angle: Angle;             // §5 — the bounded relationship to the surface
  opened: number;           // t
  lifetime: "while-held" | { untilT: number } | "until-shaken";
  audit: true;              // channels always leave a trace
}
```

- **Open once, flow within.** While the channel is open, the agent-knob turns in
  realtime along its angle with no per-frame gate. This is the realtime answer.
- **Exit means return to zero-point.** Any attempt to move outside the angle
  closes the channel and returns authority to the human center.
- A channel is a first-class **permission record**: it can expire, be narrowed,
  or be shaken (`shake({ kind: "permission-record", ... })`).

> **MVP-0 today:** `ManualConsentPolicy` grants by transient proposal id — no
> lifetime, no angle, no audit as a record. Target: `Channel` objects.

## 4. Coupling and the coordination rule

Mutations split into two classes:

| Class | Example | Gate |
| --- | --- | --- |
| **Axis drift** | agent moves its own param within `range` | none — flows within its channel |
| **Novel space** | new layer, range extension, cross-axis mark, new composition | **requires coordinated co-motion** |

**Coordination rule:** a novel-space mutation is authorized only when **two or
more coupled knobs move together within a short window, at least one of them a
human knob (or a human-opened channel).** One agent-knob alone can never mark new
space — it can only slide along its axis.

This is the toy's two-knobs-for-a-diagonal, made into an authorization primitive.
It is a physical-feeling multi-party consent: like two keys turned together.

> **MVP-0 today:** any accepted proposal can create a layer solo (gated only by
> consent policy). Target: layer creation / novel marks require coupled co-motion.

## 5. Angle (angular access)

An `Angle` is the bounded relationship a channel grants — spatial, temporal, and
operational at once. It answers, from the human zero-point, *what slice of the
surface this knob may touch.*

```ts
interface Angle {
  observe: string[];        // layers/streams it may read
  affectLayers: string[];   // layers it may move
  params: string[];         // which axes (params) it may drive
  paramBounds?: Record<string, [number, number]>;
  masks?: string[];         // which masks it may touch
  window?: [number, number];// time window it may operate within
  mayClear: ShakeScope[];   // residue it is allowed to shake
  mustAudit: true;          // audit obligations
}
```

Different agents get different angles: a background angle, a mask angle, an
annotation angle, a verifier angle, a preview/debug angle. None gets the room.

> **MVP-0 today:** the only enforced angle is the absolute one — no agent touches
> `human-video`. Everything else is unbounded within `mutableBy`. Target: `Angle`.

## 6. Consent is a gesture, recorded on the log

Consent and revocation are **knob gestures**, and every gesture is keyed onto the
audit log. The physical control *is* the permission act.

- **Press-and-hold** a knob/button → open a channel to that agent for as long as
  it is held (`lifetime: "while-held"`).
- **Coupled turn** (human + agent knobs together) → authorize novel space (§4).
- **Shake + hold(N)** → scoped shake of knob N's coupling group. Composed
  gestures encode the shake scope (e.g. shake while holding 4 wipes 4, 5, 6 if
  they are coupled).

Each of these emits an audit event, so the log reads as the strip of who turned
what, when, under which coupling — "keying knobs on a log."

## 7. Shake = scoped revocation **and** a new context window

Shake keeps its meaning from [`05_SHAKE_AND_REVOCATION.md`](05_SHAKE_AND_REVOCATION.md)
(scoped, preserves human presence) and gains one thing: for generated stream
layers, shake **opens a fresh generative context window.** The stream rebuilds
from a new context based on whatever the surface now is — a new take, not just a
clear.

New/extended shake scopes this model needs:

- `permission-record` — revoke an expired or unwanted channel/lease.
- `coupling-group` — shake the knobs coupled to knob N (the gesture in §6).
- `mask` — clear stale masks specifically (masks are governance objects).
- `context-window` — reset the generator's working context for a layer/stream.

> **MVP-0 today:** scopes are `all-generated | agent | layer | from-timestamp |
> unsafe`. Target: add the four above.

## 8. Director (optional authority router)

A `Director` is an optional timing/routing layer: it opens/narrows channels,
throttles or mutes knobs, routes agents to layers, arbitrates conflicts, triggers
shake, and preserves the human layer. It is **not** the soul of the system — the
invariant stands with or without it: *no knob gets unbounded authority over the
surface.* Sketched runs with zero, one, many, or a human-operated director.

## 9. Migration path from MVP-0

1. Introduce `Knob` and refactor `KnobPanel` + agents onto it (human vs agent
   authority differ; grammar is shared).
2. Add `Channel` + `Angle`; move `ManualConsentPolicy` to issue channels.
3. Add the coordination rule so novel-space mutations require coupled co-motion.
4. Extend `shake` with `permission-record`, `coupling-group`, `mask`,
   `context-window`; wire "new context window" for stream layers.
5. (Optional) add a `Director`.

Every step must preserve the invariants in
[`09_SAFETY_CONSENT_BOUNDARIES.md`](09_SAFETY_CONSENT_BOUNDARIES.md) and stay
legible in the audit log. The zero-order goal remains: a coherent, ethical,
minimal deliverable — not a command center.
