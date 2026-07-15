import { useMemo, useRef, useState } from "react";
import { createBlankStage, actorMayMutate, Stage } from "./core/stage";
import { HUMAN } from "./core/provenance";
import { isHumanLayer } from "./core/layer";
import { shake } from "./core/shake";
import { AutoConsentPolicy } from "./core/consent";
import { Gatekeeper } from "./agents/gatekeeper";
import { MockAgent, OverreachingAgent } from "./agents/mockAgent";
import type { AgentContext } from "./agents/agentProtocol";
import { INPUT_MODES, type InputModeId } from "./video/inputModes";
import { StageView } from "./components/StageView";
import { LayerPanel } from "./components/LayerPanel";
import { KnobPanel } from "./components/KnobPanel";
import { AuditLog } from "./components/AuditLog";

interface Wiring {
  stage: Stage;
  gate: Gatekeeper;
  agent: MockAgent;
  grabby: OverreachingAgent;
}

function boot(): Wiring {
  const stage = createBlankStage();
  const gate = new Gatekeeper(stage, new AutoConsentPolicy());
  return { stage, gate, agent: new MockAgent(), grabby: new OverreachingAgent() };
}

export function App() {
  const wiring = useRef<Wiring>();
  if (!wiring.current) wiring.current = boot();
  const { stage, gate, agent, grabby } = wiring.current;

  const [, setVersion] = useState(0);
  const bump = () => setVersion((v) => v + 1);
  const [t, setT] = useState(0);
  const [inputMode, setInputMode] = useState<InputModeId>("blank");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const layers = stage.listLayers();
  const selected = selectedId ? (stage.getLayer(selectedId) ?? null) : null;
  const knobDisabled = !selected || !actorMayMutate(selected, HUMAN);

  const agentContext = (): AgentContext => ({
    t,
    ownedLayerIds: stage.layersBy(agent.actor.id).map((l) => l.id),
    nextId: () => stage.newId("proposal"),
  });

  function onKnob(param: string, value: number) {
    if (!selected) return;
    stage.updateParams(selected.id, { [param]: value }, HUMAN, { atTime: t });
    bump();
  }

  function mockPropose() {
    gate.submitAll(agent.propose(agentContext()));
    bump();
  }

  function agentGrabsHuman() {
    const humanId = layers.find(isHumanLayer)?.id;
    gate.submitAll(
      grabby.propose({
        t,
        ownedLayerIds: humanId ? [humanId] : [],
        nextId: () => stage.newId("proposal"),
      }),
    );
    bump();
  }

  function shakeGenerated() {
    shake(stage, { kind: "all-generated" });
    if (selectedId && !stage.getLayer(selectedId)) setSelectedId(null);
    bump();
  }

  function tick() {
    const next = t + 1;
    setT(next);
    stage.sampleAt(next);
    bump();
  }

  const availableModes = useMemo(() => INPUT_MODES.filter((m) => m.available), []);

  return (
    <div className="app">
      <header>
        <h1>Sketched</h1>
        <span className="tag">
          Chalked through time · agents propose, the surface disposes
        </span>
        <a href="/flow">Open Human Floor MVP0 →</a>
      </header>

      <LayerPanel layers={layers} selectedId={selectedId} onSelect={setSelectedId} />

      <div
        className="panel"
        style={{ display: "flex", flexDirection: "column", gap: 12 }}
      >
        <div className="row" style={{ justifyContent: "space-between" }}>
          <div className="row">
            <span className="badge">tick {t}</span>
            <label className="knob" style={{ margin: 0 }}>
              input:&nbsp;
              <select
                value={inputMode}
                onChange={(e) => setInputMode(e.target.value as InputModeId)}
              >
                {availableModes.map((m) => (
                  <option key={m.id} value={m.id}>
                    {m.label}
                  </option>
                ))}
              </select>
            </label>
          </div>
          <div className="row">
            <button onClick={tick}>Advance tick</button>
            <button className="primary" onClick={mockPropose}>
              Mock agent propose
            </button>
            <button onClick={agentGrabsHuman}>Agent grabs human (denied)</button>
            <button className="danger" onClick={shakeGenerated}>
              Shake generated
            </button>
          </div>
        </div>

        <StageView layers={layers} inputMode={inputMode} t={t} />

        <KnobPanel layer={selected} onKnob={onKnob} disabled={knobDisabled} />
      </div>

      <AuditLog events={stage.audit.list()} />
    </div>
  );
}
