import { describe, it, expect } from "vitest";
import { createBlankStage, Stage, MutationDeniedError } from "./stage";
import { agentActor, HUMAN } from "./provenance";
import { isHumanLayer } from "./layer";
import { shake } from "./shake";

const painter = agentActor("scene-painter");

describe("stage authority", () => {
  it("agent cannot mutate the human/video layer directly", () => {
    const stage = createBlankStage();
    const human = stage.listLayers().find(isHumanLayer)!;
    expect(() =>
      stage.updateParams(human.id, { opacity: 0 }, painter),
    ).toThrow(MutationDeniedError);
  });

  it("agent cannot create a human/video layer", () => {
    const stage = new Stage();
    expect(() =>
      stage.createLayer({ kind: "human-video", name: "steal" }, painter),
    ).toThrow(MutationDeniedError);
  });

  it("human may mutate the human layer", () => {
    const stage = createBlankStage();
    const human = stage.listLayers().find(isHumanLayer)!;
    const updated = stage.updateParams(human.id, { opacity: 0.5 }, HUMAN);
    expect(updated.params["opacity"]).toBe(0.5);
  });

  it("generated layers carry ownership and provenance", () => {
    const stage = new Stage();
    const layer = stage.createLayer(
      { kind: "generated-background", name: "Dawn", reason: "demo" },
      painter,
    );
    expect(layer.owner.id).toBe("agent:scene-painter");
    expect(layer.provenance.createdBy.kind).toBe("agent");
    expect(typeof layer.provenance.createdAt).toBe("number");
    expect(layer.provenance.reason).toBe("demo");
    expect(layer.shakeable).toBe(true);
  });

  it("records an audit event for an accepted mutation", () => {
    const stage = new Stage();
    const layer = stage.createLayer({ kind: "generated-foreground", name: "Shapes" }, painter);
    stage.updateParams(layer.id, { hue: 120 }, painter);
    const updates = stage.audit.byType("layer.updated");
    expect(updates.length).toBe(1);
    expect(updates[0]!.layerId).toBe(layer.id);
  });
});

describe("shake", () => {
  it("clears generated layers but preserves human presence", () => {
    const stage = createBlankStage();
    stage.createLayer({ kind: "generated-background", name: "bg" }, painter);
    stage.createLayer({ kind: "generated-foreground", name: "fg" }, painter);

    const before = stage.listLayers();
    expect(before.some(isHumanLayer)).toBe(true);
    expect(before.length).toBe(3);

    const result = shake(stage, { kind: "all-generated" });

    const after = stage.listLayers();
    expect(after.length).toBe(1);
    expect(after.every(isHumanLayer)).toBe(true);
    expect(result.clearedLayerIds.length).toBe(2);
    expect(result.preservedLayerIds.length).toBe(1);
  });

  it("shaking one agent leaves other agents' layers", () => {
    const stage = new Stage();
    const other = agentActor("annotator");
    const a = stage.createLayer({ kind: "generated-background", name: "a" }, painter);
    const b = stage.createLayer({ kind: "annotation", name: "b" }, other);

    shake(stage, { kind: "agent", agentId: painter.id });

    expect(stage.getLayer(a.id)).toBeUndefined();
    expect(stage.getLayer(b.id)).toBeDefined();
  });

  it("shake-from-timestamp revokes later keyframes but keeps the layer", () => {
    const stage = new Stage();
    const layer = stage.createLayer({ kind: "generated-background", name: "bg" }, painter);
    stage.keyframe(layer.id, "hue", 0, 10, painter);
    stage.keyframe(layer.id, "hue", 5, 200, painter);

    shake(stage, { kind: "from-timestamp", t: 5 });

    expect(stage.getLayer(layer.id)).toBeDefined();
    expect(stage.timeline.sample(layer.id, "hue", 10)).toBe(10);
  });
});
