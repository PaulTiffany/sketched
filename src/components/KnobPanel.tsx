import type { Layer } from "../core/layer";

interface Props {
  layer: Layer | null;
  /** Human turns a knob: a bounded parameter gesture, keyframed at time t. */
  onKnob: (param: string, value: number) => void;
  disabled: boolean;
}

const KNOBS: { param: string; min: number; max: number; step: number; fallback: number }[] = [
  { param: "hue", min: 0, max: 360, step: 1, fallback: 210 },
  { param: "opacity", min: 0, max: 1, step: 0.01, fallback: 0.8 },
  { param: "energy", min: 0, max: 1, step: 0.01, fallback: 0.5 },
];

/** Knobs are the human's parameter gestures over the selected layer. */
export function KnobPanel({ layer, onKnob, disabled }: Props) {
  return (
    <div className="panel">
      <h2>Knobs</h2>
      {!layer && <p className="hint">Select a layer to turn its knobs.</p>}
      {layer && disabled && (
        <p className="hint">
          You cannot turn knobs on “{layer.name}” — it is not yours to mutate.
        </p>
      )}
      {layer &&
        !disabled &&
        KNOBS.map(({ param, min, max, step, fallback }) => {
          const value = typeof layer.params[param] === "number" ? (layer.params[param] as number) : fallback;
          return (
            <div key={param}>
              <label className="knob">
                {param} — {value.toFixed(param === "hue" ? 0 : 2)}
              </label>
              <input
                type="range"
                min={min}
                max={max}
                step={step}
                value={value}
                onChange={(e) => onKnob(param, Number(e.target.value))}
              />
            </div>
          );
        })}
      <p className="hint">Turning a knob writes a keyframe at the current tick.</p>
    </div>
  );
}
