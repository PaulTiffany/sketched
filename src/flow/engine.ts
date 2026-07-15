export type ClockMode = "step" | "flow";

export interface FlowLayer {
  id: string;
  name: string;
  kind: "human" | "generated-background" | "generated-foreground";
  owner: "human" | "agent";
  dependsOn: string[];
  params: Record<string, number>;
}

export interface Angle {
  affectLayers: string[];
  paramBounds: Record<string, [number, number]>;
}

export interface FlowChannel {
  id: string;
  openedAt: number;
  untilTick: number;
  budget: number;
  spent: number;
  anchorMargin: number;
  angle: Angle;
  status: "open" | "closed";
  closeReason?: string;
}

interface EventBase {
  seq: number;
  t: number;
}

export type FlowEvent =
  | (EventBase & { type: "session.started" })
  | (EventBase & { type: "layer.created"; layer: FlowLayer })
  | (EventBase & { type: "tick.advanced" })
  | (EventBase & { type: "channel.opened"; channel: FlowChannel })
  | (EventBase & {
      type: "channel.closed";
      channelId: string;
      reason: "human-interrupt" | "budget-exhausted" | "lease-expired" | "out-of-angle";
    })
  | (EventBase & {
      type: "mutation.accepted";
      channelId: string;
      layerId: string;
      params: Record<string, number>;
      cost: number;
    })
  | (EventBase & {
      type: "mutation.rejected";
      channelId?: string;
      layerId: string;
      params: Record<string, number>;
      reason: string;
    })
  | (EventBase & {
      type: "shake.committed";
      rootLayerId: string;
      removedDependents: string[];
      nextContext: number;
    });

export interface FlowState {
  tick: number;
  context: number;
  layers: Record<string, FlowLayer>;
  channel?: FlowChannel;
}

export interface FlowTrace {
  schema: "sketched.flow-trace.v1";
  events: FlowEvent[];
  finalDigest: string;
}

export interface TraceVerdict {
  valid: boolean;
  reasons: string[];
}

export const HUMAN_LAYER_ID = "human-signal";
export const BACKGROUND_LAYER_ID = "agent-atmosphere";
export const FOREGROUND_LAYER_ID = "agent-orbit";

const BACKGROUND_BASELINE = { hue: 210, energy: 0.2 };

function initialLayers(): Record<string, FlowLayer> {
  return {
    [HUMAN_LAYER_ID]: {
      id: HUMAN_LAYER_ID,
      name: "Human signal",
      kind: "human",
      owner: "human",
      dependsOn: [],
      params: { presence: 1 },
    },
    [BACKGROUND_LAYER_ID]: {
      id: BACKGROUND_LAYER_ID,
      name: "Atmosphere",
      kind: "generated-background",
      owner: "agent",
      dependsOn: [HUMAN_LAYER_ID],
      params: { ...BACKGROUND_BASELINE },
    },
    [FOREGROUND_LAYER_ID]: foregroundLayer(),
  };
}

function foregroundLayer(): FlowLayer {
  return {
    id: FOREGROUND_LAYER_ID,
    name: "Dependent orbit",
    kind: "generated-foreground",
    owner: "agent",
    dependsOn: [BACKGROUND_LAYER_ID],
    params: { orbit: 0 },
  };
}

function cloneLayer(layer: FlowLayer): FlowLayer {
  return { ...layer, dependsOn: [...layer.dependsOn], params: { ...layer.params } };
}

export function replay(events: readonly FlowEvent[]): FlowState {
  let state: FlowState = { tick: 0, context: 0, layers: {} };
  for (const event of events) {
    switch (event.type) {
      case "session.started":
        state = { tick: 0, context: 0, layers: initialLayers() };
        break;
      case "layer.created":
        state = {
          ...state,
          layers: { ...state.layers, [event.layer.id]: cloneLayer(event.layer) },
        };
        break;
      case "tick.advanced":
        state = { ...state, tick: event.t };
        break;
      case "channel.opened":
        state = {
          ...state,
          channel: { ...event.channel, angle: cloneAngle(event.channel.angle) },
        };
        break;
      case "channel.closed":
        if (state.channel?.id === event.channelId) {
          state = {
            ...state,
            channel: { ...state.channel, status: "closed", closeReason: event.reason },
          };
        }
        break;
      case "mutation.accepted": {
        const layer = state.layers[event.layerId];
        if (!layer) break;
        state = {
          ...state,
          layers: {
            ...state.layers,
            [event.layerId]: { ...layer, params: { ...layer.params, ...event.params } },
          },
          channel:
            state.channel?.id === event.channelId
              ? { ...state.channel, spent: state.channel.spent + event.cost }
              : state.channel,
        };
        break;
      }
      case "mutation.rejected":
        break;
      case "shake.committed": {
        const layers = { ...state.layers };
        for (const id of event.removedDependents) delete layers[id];
        const background = layers[event.rootLayerId];
        if (background) {
          layers[event.rootLayerId] = {
            ...background,
            params: { ...BACKGROUND_BASELINE },
          };
        }
        state = {
          ...state,
          context: event.nextContext,
          layers,
          channel: state.channel
            ? { ...state.channel, status: "closed", closeReason: "human-interrupt" }
            : undefined,
        };
        break;
      }
    }
  }
  return state;
}

function cloneAngle(angle: Angle): Angle {
  return {
    affectLayers: [...angle.affectLayers],
    paramBounds: Object.fromEntries(
      Object.entries(angle.paramBounds).map(([key, bounds]) => [key, [...bounds]]),
    ),
  };
}

function append<T extends Omit<FlowEvent, "seq">>(
  events: readonly FlowEvent[],
  input: T,
): FlowEvent[] {
  return [...events, { ...input, seq: events.length } as FlowEvent];
}

export function createSession(): FlowEvent[] {
  return [{ seq: 0, t: 0, type: "session.started" }];
}

export function openChannel(
  events: readonly FlowEvent[],
  budget = 48,
  lifetime = 40,
): FlowEvent[] {
  const state = replay(events);
  let next = [...events];
  if (!state.layers[FOREGROUND_LAYER_ID]) {
    next = append(next, {
      t: state.tick,
      type: "layer.created",
      layer: foregroundLayer(),
    });
  }
  const id = `channel-${state.context}-${state.tick}-${next.length}`;
  return append(next, {
    t: state.tick,
    type: "channel.opened",
    channel: {
      id,
      openedAt: state.tick,
      untilTick: state.tick + lifetime,
      budget,
      spent: 0,
      anchorMargin: budget * 2,
      status: "open",
      angle: {
        affectLayers: [BACKGROUND_LAYER_ID, FOREGROUND_LAYER_ID],
        paramBounds: {
          hue: [180, 320],
          energy: [0.15, 0.9],
          orbit: [0, 360],
        },
      },
    },
  });
}

export function advanceOne(events: readonly FlowEvent[]): FlowEvent[] {
  const before = replay(events);
  const t = before.tick + 1;
  let next = append(events, { t, type: "tick.advanced" });
  const state = replay(next);
  const channel = state.channel;
  if (!channel || channel.status !== "open") return next;
  if (t > channel.untilTick) {
    return append(next, {
      t,
      type: "channel.closed",
      channelId: channel.id,
      reason: "lease-expired",
    });
  }

  const proposals = [
    {
      layerId: BACKGROUND_LAYER_ID,
      params: { hue: 180 + ((t * 13) % 140), energy: 0.25 + (t % 8) * 0.07 },
      cost: 2,
    },
    { layerId: FOREGROUND_LAYER_ID, params: { orbit: (t * 27) % 360 }, cost: 1 },
  ];

  for (const proposal of proposals) {
    const current = replay(next);
    const active = current.channel;
    if (!active || active.status !== "open") break;
    if (active.spent + proposal.cost > active.budget) {
      next = append(next, {
        t,
        type: "mutation.rejected",
        channelId: active.id,
        layerId: proposal.layerId,
        params: proposal.params,
        reason: "cumulative channel budget exhausted",
      });
      next = append(next, {
        t,
        type: "channel.closed",
        channelId: active.id,
        reason: "budget-exhausted",
      });
      break;
    }
    next = append(next, {
      t,
      type: "mutation.accepted",
      channelId: active.id,
      layerId: proposal.layerId,
      params: proposal.params,
      cost: proposal.cost,
    });
  }
  return next;
}

export function probeBoundary(events: readonly FlowEvent[]): FlowEvent[] {
  const state = replay(events);
  const channel = state.channel;
  if (!channel || channel.status !== "open") return events.slice();
  let next = append(events, {
    t: state.tick,
    type: "mutation.rejected",
    channelId: channel.id,
    layerId: HUMAN_LAYER_ID,
    params: { presence: 0 },
    reason: "outside angle: human presence is not in the channel",
  });
  next = append(next, {
    t: state.tick,
    type: "channel.closed",
    channelId: channel.id,
    reason: "out-of-angle",
  });
  return next;
}

export function interrupt(events: readonly FlowEvent[]): FlowEvent[] {
  const state = replay(events);
  const removed = dependencyClosure(state.layers, BACKGROUND_LAYER_ID).filter(
    (id) => id !== BACKGROUND_LAYER_ID && id !== HUMAN_LAYER_ID,
  );
  let next = [...events];
  if (state.channel?.status === "open") {
    next = append(next, {
      t: state.tick,
      type: "channel.closed",
      channelId: state.channel.id,
      reason: "human-interrupt",
    });
  }
  return append(next, {
    t: state.tick,
    type: "shake.committed",
    rootLayerId: BACKGROUND_LAYER_ID,
    removedDependents: removed,
    nextContext: state.context + 1,
  });
}

export function dependencyClosure(
  layers: Readonly<Record<string, FlowLayer>>,
  rootId: string,
): string[] {
  const closure = new Set([rootId]);
  let changed = true;
  while (changed) {
    changed = false;
    for (const layer of Object.values(layers)) {
      if (closure.has(layer.id)) continue;
      if (layer.dependsOn.some((id) => closure.has(id))) {
        closure.add(layer.id);
        changed = true;
      }
    }
  }
  return [...closure];
}

export function channelMeters(state: FlowState): {
  budgetRemaining: number;
  budget: number;
  marginLowerBound: number;
  marginFloor: number;
  anchorMargin: number;
} {
  const channel = state.channel;
  if (!channel) {
    return {
      budgetRemaining: 0,
      budget: 0,
      marginLowerBound: 0,
      marginFloor: 0,
      anchorMargin: 0,
    };
  }
  return {
    budgetRemaining: Math.max(0, channel.budget - channel.spent),
    budget: channel.budget,
    marginLowerBound: channel.anchorMargin - channel.spent,
    marginFloor: channel.budget,
    anchorMargin: channel.anchorMargin,
  };
}

export function exportTrace(events: readonly FlowEvent[]): FlowTrace {
  return {
    schema: "sketched.flow-trace.v1",
    events: events.map((event) => structuredClone(event)),
    finalDigest: stateDigest(replay(events)),
  };
}

export function verifyTrace(trace: FlowTrace): TraceVerdict {
  const reasons: string[] = [];
  let state: FlowState = { tick: 0, context: 0, layers: {} };
  trace.events.forEach((event, index) => {
    if (event.seq !== index) reasons.push(`event ${index}: non-contiguous sequence`);
    if (event.type === "mutation.accepted") {
      const channel = state.channel;
      const layer = state.layers[event.layerId];
      if (!channel || channel.status !== "open" || channel.id !== event.channelId) {
        reasons.push(`event ${index}: mutation has no active channel`);
      } else {
        if (event.t > channel.untilTick)
          reasons.push(`event ${index}: mutation exceeds lease`);
        if (!channel.angle.affectLayers.includes(event.layerId)) {
          reasons.push(`event ${index}: layer is outside channel angle`);
        }
        if (layer?.kind === "human") reasons.push(`event ${index}: human layer mutated`);
        if (channel.spent + event.cost > channel.budget) {
          reasons.push(`event ${index}: cumulative budget exceeded`);
        }
        for (const [param, value] of Object.entries(event.params)) {
          const bounds = channel.angle.paramBounds[param];
          if (!bounds || value < bounds[0] || value > bounds[1]) {
            reasons.push(`event ${index}: ${param}=${value} is outside angle`);
          }
        }
      }
    }
    state = replay([...trace.events.slice(0, index + 1)]);
  });
  if (stateDigest(state) !== trace.finalDigest)
    reasons.push("final state digest mismatch");
  return { valid: reasons.length === 0, reasons };
}

export function stateDigest(state: FlowState): string {
  const stable = JSON.stringify({
    tick: state.tick,
    context: state.context,
    layers: Object.fromEntries(
      Object.entries(state.layers)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([id, layer]) => [id, { ...layer, params: sortedRecord(layer.params) }]),
    ),
    channel: state.channel
      ? {
          ...state.channel,
          angle: {
            ...state.channel.angle,
            paramBounds: sortedRecord(state.channel.angle.paramBounds),
          },
        }
      : null,
  });
  let hash = 0x811c9dc5;
  for (let i = 0; i < stable.length; i += 1) {
    hash ^= stable.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return (hash >>> 0).toString(16).padStart(8, "0");
}

function sortedRecord<T>(record: Record<string, T>): Record<string, T> {
  return Object.fromEntries(
    Object.entries(record).sort(([a], [b]) => a.localeCompare(b)),
  );
}
