import { describe, expect, it } from "vitest";
import {
  BACKGROUND_LAYER_ID,
  FOREGROUND_LAYER_ID,
  HUMAN_LAYER_ID,
  advanceOne,
  channelMeters,
  createSession,
  exportTrace,
  interrupt,
  openChannel,
  probeBoundary,
  replay,
  stateDigest,
  verifyTrace,
  type FlowEvent,
} from "./engine";

function advance(events: FlowEvent[], count: number): FlowEvent[] {
  let next = events;
  for (let i = 0; i < count; i += 1) next = advanceOne(next);
  return next;
}

describe("human-floor flow engine", () => {
  it("spends a cumulative budget while preserving the margin floor", () => {
    const events = advance(openChannel(createSession()), 3);
    const state = replay(events);
    const meters = channelMeters(state);

    expect(state.channel?.spent).toBe(9);
    expect(meters.budgetRemaining).toBe(39);
    expect(meters.marginLowerBound).toBe(87);
    expect(meters.marginLowerBound).toBeGreaterThanOrEqual(meters.marginFloor);
    expect(verifyTrace(exportTrace(events))).toEqual({ valid: true, reasons: [] });
  });

  it("closes before a frame can exceed the interval budget", () => {
    const events = advance(openChannel(createSession(), 5), 2);
    const state = replay(events);

    expect(state.channel?.spent).toBe(5);
    expect(state.channel?.status).toBe("closed");
    expect(state.channel?.closeReason).toBe("budget-exhausted");
    expect(events.some((event) => event.type === "mutation.rejected")).toBe(true);
    expect(verifyTrace(exportTrace(events)).valid).toBe(true);
  });

  it("treats an out-of-angle probe as a refusal and closes the channel", () => {
    const before = openChannel(createSession());
    const events = probeBoundary(before);
    const state = replay(events);

    expect(state.channel?.closeReason).toBe("out-of-angle");
    expect(state.layers[HUMAN_LAYER_ID]?.params.presence).toBe(1);
    expect(events[events.length - 2]?.type).toBe("mutation.rejected");
  });

  it("interrupts the flow, rewinds its root, and cascades through dependents", () => {
    const active = advance(openChannel(createSession()), 4);
    const events = interrupt(active);
    const state = replay(events);

    expect(state.layers[HUMAN_LAYER_ID]).toBeDefined();
    expect(state.layers[BACKGROUND_LAYER_ID]?.params).toEqual({ hue: 210, energy: 0.2 });
    expect(state.layers[FOREGROUND_LAYER_ID]).toBeUndefined();
    expect(state.context).toBe(1);
    expect(state.channel?.status).toBe("closed");

    const renewed = replay(openChannel(events));
    expect(renewed.layers[FOREGROUND_LAYER_ID]).toBeDefined();
    expect(renewed.channel?.status).toBe("open");
  });

  it("gives STEP and FLOW scheduling identical traces", () => {
    const seed = openChannel(createSession());
    const stepRun = advance(seed, 7);
    const flowRun = [0, 1, 2, 3, 4, 5, 6].reduce((events) => advanceOne(events), seed);

    expect(flowRun).toEqual(stepRun);
    expect(stateDigest(replay(flowRun))).toBe(stateDigest(replay(stepRun)));
  });

  it("detects a forged accepted mutation against the human layer", () => {
    const events = openChannel(createSession());
    const channel = replay(events).channel!;
    const forged: FlowEvent = {
      seq: events.length,
      t: 0,
      type: "mutation.accepted",
      channelId: channel.id,
      layerId: HUMAN_LAYER_ID,
      params: { presence: 0 },
      cost: 1,
    };
    const trace = exportTrace([...events, forged]);
    const verdict = verifyTrace(trace);

    expect(verdict.valid).toBe(false);
    expect(verdict.reasons.join(" ")).toMatch(/outside channel angle|human layer/);
  });
});
