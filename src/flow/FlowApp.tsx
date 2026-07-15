import { useEffect, useMemo, useState } from "react";
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
  verifyTrace,
  type ClockMode,
  type FlowEvent,
} from "./engine";
import "./flow.css";
import "./flow-stage.css";

const FLOW_INTERVAL_MS = 320;

export function FlowApp() {
  const [events, setEvents] = useState<FlowEvent[]>(createSession);
  const [mode, setMode] = useState<ClockMode>("step");
  const state = useMemo(() => replay(events), [events]);
  const meters = channelMeters(state);
  const trace = useMemo(() => exportTrace(events), [events]);
  const verdict = useMemo(() => verifyTrace(trace), [trace]);
  const channelOpen = state.channel?.status === "open";

  useEffect(() => {
    if (mode !== "flow" || !channelOpen) return;
    const timer = window.setInterval(
      () => setEvents((current) => advanceOne(current)),
      FLOW_INTERVAL_MS,
    );
    return () => window.clearInterval(timer);
  }, [mode, channelOpen]);

  useEffect(() => {
    if (mode === "flow" && state.channel && state.channel.status === "closed")
      setMode("step");
  }, [mode, state.channel]);

  const background = state.layers[BACKGROUND_LAYER_ID];
  const foreground = state.layers[FOREGROUND_LAYER_ID];
  const hue = background?.params.hue ?? 210;
  const energy = background?.params.energy ?? 0.2;
  const orbit = foreground?.params.orbit ?? 0;

  function reset() {
    setMode("step");
    setEvents(createSession());
  }

  function downloadTrace() {
    const blob = new Blob([JSON.stringify(trace, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = `sketched-flow-t${state.tick}.json`;
    anchor.click();
    URL.revokeObjectURL(url);
  }

  return (
    <div className="flow-app">
      <header className="flow-header">
        <div>
          <div className="flow-kicker">SKETCHED / HUMAN FLOOR MVP0</div>
          <h1>One engine. Two clocks.</h1>
        </div>
        <div className="clock-switch" aria-label="clock mode">
          <button
            className={mode === "step" ? "active" : ""}
            onClick={() => setMode("step")}
          >
            STEP
          </button>
          <button
            className={mode === "flow" ? "active" : ""}
            disabled={!channelOpen}
            onClick={() => setMode("flow")}
          >
            FLOW
          </button>
        </div>
        <div className="flow-header-state">
          <span>tick {state.tick}</span>
          <span>context {state.context}</span>
          <span className={verdict.valid ? "verified" : "failed"}>
            trace {verdict.valid ? "verified" : "failed"}
          </span>
        </div>
      </header>

      <aside className="flow-panel flow-controls">
        <section>
          <h2>Human checkpoint</h2>
          <p>
            Open one bounded interval. STEP exposes every decision boundary; FLOW advances
            the same deterministic event stream below the human floor.
          </p>
          <div className="flow-control-stack">
            <button
              className="flow-primary"
              onClick={() => setEvents((current) => openChannel(current))}
            >
              {channelOpen ? "RENEW CHANNEL" : "OPEN CHANNEL"}
            </button>
            <button
              disabled={mode === "flow"}
              onClick={() => setEvents((current) => advanceOne(current))}
            >
              ADVANCE ONE TICK
            </button>
            <button
              disabled={!channelOpen}
              onClick={() => setEvents((current) => probeBoundary(current))}
            >
              PROBE OUTSIDE ANGLE
            </button>
            <button
              className="flow-danger"
              onClick={() => setEvents((current) => interrupt(current))}
            >
              INTERRUPT / SHAKE
            </button>
          </div>
        </section>

        <section>
          <h2>Channel telemetry</h2>
          <Meter
            label="Flow budget"
            value={meters.budgetRemaining}
            max={meters.budget || 1}
            detail={`${meters.budgetRemaining} / ${meters.budget}`}
          />
          <Meter
            label="Margin lower bound"
            value={meters.marginLowerBound}
            max={meters.anchorMargin || 1}
            floor={meters.marginFloor}
            detail={
              state.channel
                ? `≥ ${meters.marginLowerBound}; floor ${meters.marginFloor}`
                : "open a channel"
            }
          />
          <div className={`channel-card ${channelOpen ? "open" : "closed"}`}>
            <strong>{channelOpen ? "CHANNEL OPEN" : "CHANNEL CLOSED"}</strong>
            <span>
              {state.channel
                ? (state.channel.closeReason ??
                  `lease ends at tick ${state.channel.untilTick}`)
                : "awaiting human grant"}
            </span>
          </div>
        </section>

        <section className="flow-small-actions">
          <button onClick={downloadTrace}>EXPORT TRACE</button>
          <button onClick={reset}>RESET RUN</button>
          <a href="/">MVP-0 stage</a>
          <a href="/book">Book</a>
        </section>
      </aside>

      <main className="flow-stage-shell">
        <div
          className="flow-atmosphere"
          style={{
            background: `radial-gradient(circle at 50% 48%, hsl(${hue} 75% ${25 + energy * 22}%), hsl(${(hue + 48) % 360} 55% 8%) 68%)`,
          }}
        />
        <div className="human-signal">
          <div
            className="human-pulse"
            style={{ transform: `scale(${1 + (state.tick % 5) * 0.012})` }}
          />
          <strong>HUMAN SIGNAL</strong>
          <span>protected / continuous</span>
        </div>
        {foreground && (
          <div className="orbit-track" style={{ transform: `rotate(${orbit}deg)` }}>
            <div className="orbit-object">dependent</div>
          </div>
        )}
        <div className="stage-readout">
          <span>hue {Math.round(hue)}°</span>
          <span>energy {energy.toFixed(2)}</span>
          <span>{foreground ? "dependency live" : "dependency revoked"}</span>
        </div>
        <div className="human-floor-line">
          <span>{mode === "flow" ? "FRAME ACTIONS" : "HUMAN DECISION"}</span>
          <i />
          <span>{mode === "flow" ? "below floor" : "at boundary"}</span>
        </div>
      </main>

      <aside className="flow-panel trace-panel">
        <div className="trace-heading">
          <h2>Witness strip</h2>
          <span>
            {events.length} events · {trace.finalDigest}
          </span>
        </div>
        <div className="trace-list">
          {[...events].reverse().map((event) => (
            <EventRow event={event} key={event.seq} />
          ))}
        </div>
      </aside>
    </div>
  );
}

function Meter({
  label,
  value,
  max,
  floor,
  detail,
}: {
  label: string;
  value: number;
  max: number;
  floor?: number;
  detail: string;
}) {
  const percent = Math.max(0, Math.min(100, (value / max) * 100));
  const floorPercent = floor === undefined ? undefined : (floor / max) * 100;
  return (
    <div className="meter-block">
      <div className="meter-label">
        <span>{label}</span>
        <strong>{detail}</strong>
      </div>
      <div className="meter-track">
        <div className="meter-fill" style={{ width: `${percent}%` }} />
        {floorPercent !== undefined && (
          <i className="meter-floor" style={{ left: `${floorPercent}%` }} />
        )}
      </div>
    </div>
  );
}

function EventRow({ event }: { event: FlowEvent }) {
  const tone = event.type.includes("rejected")
    ? "reject"
    : event.type === "shake.committed"
      ? "shake"
      : event.type.includes("accepted") || event.type === "channel.opened"
        ? "accept"
        : "";
  let detail = "";
  if (event.type === "mutation.accepted") {
    detail = `${event.layerId} · ${Object.keys(event.params).join("+")} · −${event.cost}`;
  } else if (event.type === "mutation.rejected") {
    detail = event.reason;
  } else if (event.type === "channel.closed") {
    detail = event.reason;
  } else if (event.type === "shake.committed") {
    detail = `${event.removedDependents.length} dependent removed · context ${event.nextContext}`;
  } else if (event.type === "channel.opened") {
    detail = `budget ${event.channel.budget} · until tick ${event.channel.untilTick}`;
  } else if (event.type === "layer.created") {
    detail = event.layer.name;
  }
  return (
    <div className={`trace-event ${tone}`}>
      <span className="trace-seq">{String(event.seq).padStart(3, "0")}</span>
      <div>
        <strong>{event.type}</strong>
        {detail && <span>{detail}</span>}
      </div>
      <time>t{event.t}</time>
    </div>
  );
}

export const flowLayerIds = [HUMAN_LAYER_ID, BACKGROUND_LAYER_ID, FOREGROUND_LAYER_ID];
