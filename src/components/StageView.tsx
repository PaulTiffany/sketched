import type { Layer } from "../core/layer";
import { isHumanLayer } from "../core/layer";
import { mockFrameAt, type InputModeId } from "../video/inputModes";

interface Props {
  layers: Layer[];
  inputMode: InputModeId;
  t: number;
}

function num(v: unknown, fallback: number): number {
  return typeof v === "number" ? v : fallback;
}

/** Paints the layer stack. Human presence is drawn distinctly and on top-ish. */
export function StageView({ layers, inputMode, t }: Props) {
  return (
    <div className="stage-wrap" aria-label="stage">
      {layers.map((layer, i) => {
        if (!layer.visible) return null;
        const human = isHumanLayer(layer);
        const hue = num(layer.params["hue"], 210);
        const opacity = num(layer.params["opacity"], human ? 1 : 0.8);

        // The human/video layer shows either a blank surface or a mock feed.
        const background = human
          ? humanBackground(inputMode, t)
          : `hsl(${hue} 70% 55% / ${opacity})`;

        return (
          <div
            key={layer.id}
            className={`layer${human ? " human" : ""}`}
            style={{ background, zIndex: i, opacity }}
          >
            {human ? humanLabel(inputMode) : layer.name}
          </div>
        );
      })}
    </div>
  );
}

function humanBackground(mode: InputModeId, t: number): string {
  if (mode === "mock") {
    const f = mockFrameAt(t);
    return `linear-gradient(${f.hue}deg, hsl(${f.hue} 40% 20%), hsl(${(f.hue + 60) % 360} 40% 30%))`;
  }
  return "#11151c";
}

function humanLabel(mode: InputModeId): string {
  return mode === "mock"
    ? "HUMAN / VIDEO — mock stream"
    : "HUMAN / VIDEO — blank stage (no camera)";
}
