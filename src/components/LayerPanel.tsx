import type { Layer } from "../core/layer";
import { isHumanLayer } from "../core/layer";

interface Props {
  layers: Layer[];
  selectedId: string | null;
  onSelect: (id: string) => void;
}

/** Lists layers with ownership + provenance so authority is always visible. */
export function LayerPanel({ layers, selectedId, onSelect }: Props) {
  return (
    <div className="panel">
      <h2>Layers</h2>
      {layers.length === 0 && <p className="hint">No layers.</p>}
      {layers.map((layer) => {
        const human = isHumanLayer(layer);
        const ownerClass = human ? "human" : layer.owner.kind === "agent" ? "agent" : "";
        return (
          <div
            key={layer.id}
            className={`layer-item${layer.id === selectedId ? " selected" : ""}`}
            onClick={() => onSelect(layer.id)}
          >
            <div className="row" style={{ justifyContent: "space-between" }}>
              <strong>{layer.name}</strong>
              <span className={`badge ${ownerClass}`}>{layer.owner.label ?? layer.owner.id}</span>
            </div>
            <div className="meta">
              {layer.kind} · {layer.shakeable ? "shakeable" : "preserved"} ·
              mutable by {layer.mutableBy}
            </div>
            {layer.provenance.reason && (
              <div className="meta">“{layer.provenance.reason}”</div>
            )}
          </div>
        );
      })}
    </div>
  );
}
