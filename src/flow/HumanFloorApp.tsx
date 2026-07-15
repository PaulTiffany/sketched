import { useEffect, useMemo, useState } from "react";
import {
  BACKGROUND_LAYER_ID,
  FOREGROUND_LAYER_ID,
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
import "./plain.css";

const FLOW_INTERVAL_MS = 420;

export function HumanFloorApp() {
  const [events, setEvents] = useState<FlowEvent[]>(createSession);
  const [mode, setMode] = useState<ClockMode>("step");
  const state = useMemo(() => replay(events), [events]);
  const meters = channelMeters(state);
  const trace = useMemo(() => exportTrace(events), [events]);
  const verdict = useMemo(() => verifyTrace(trace), [trace]);
  const channelOpen = state.channel?.status === "open";
  const explanation = explainState(
    state.channel?.status,
    state.channel?.closeReason,
    mode,
  );
  const movesLeft = Math.floor(meters.budgetRemaining / 3);
  const totalMoves = Math.floor(meters.budget / 3);

  useEffect(() => {
    if (mode !== "flow" || !channelOpen) return;
    const timer = window.setInterval(
      () => setEvents((current) => advanceOne(current)),
      FLOW_INTERVAL_MS,
    );
    return () => window.clearInterval(timer);
  }, [mode, channelOpen]);

  useEffect(() => {
    if (mode === "flow" && state.channel?.status === "closed") setMode("step");
  }, [mode, state.channel?.status]);

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
    <div className="plain-app">
      <header>
        <div>
          <small>SKETCHED</small>
          <h1>Let an agent move the background without giving it the whole stage.</h1>
        </div>
        <div className={`run-state ${mode}`}>
          {mode === "flow" ? "AGENT RUNNING" : "AGENT PAUSED"}
        </div>
      </header>

      <aside className="plain-controls">
        <h2>Try these four things</h2>
        <ol>
          <li>Give the agent a small allowance.</li>
          <li>Move once, or let it run.</li>
          <li>Try a forbidden move.</li>
          <li>Stop and rewind.</li>
        </ol>
        <div className="plain-buttons">
          <button
            className="allow"
            onClick={() => setEvents((current) => openChannel(current))}
          >
            1. {channelOpen ? "REFILL: 16 MOVES" : "ALLOW 16 MOVES"}
          </button>
          <button
            disabled={mode === "flow" || !channelOpen}
            onClick={() => setEvents((current) => advanceOne(current))}
          >
            2A. MOVE ONCE
          </button>
          <button
            disabled={!channelOpen}
            onClick={() => setMode((current) => (current === "flow" ? "step" : "flow"))}
          >
            2B. {mode === "flow" ? "PAUSE" : "RUN CONTINUOUSLY"}
          </button>
          <button
            disabled={!channelOpen}
            onClick={() => setEvents((current) => probeBoundary(current))}
          >
            3. TRY FORBIDDEN MOVE
          </button>
          <button
            className="stop"
            onClick={() => setEvents((current) => interrupt(current))}
          >
            4. STOP + REWIND
          </button>
        </div>

        <section className="allowance">
          <h2>The agent's allowance</h2>
          <PlainMeter label="Moves left" value={movesLeft} max={totalMoves || 1} />
          <strong>
            {state.channel
              ? `${movesLeft} of ${totalMoves} moves remain`
              : "Nothing granted"}
          </strong>
          <p>Every move spends this allowance. The agent cannot refill it.</p>
        </section>

        <div className="plain-links">
          <button onClick={downloadTrace}>Export proof</button>
          <button onClick={reset}>Start over</button>
          <a href="/">Original stage</a>
        </div>
      </aside>

      <main className="plain-stage">
        <div
          className="plain-background"
          style={{
            background: `radial-gradient(circle, hsl(${hue} 75% ${25 + energy * 22}%), hsl(${(hue + 48) % 360} 55% 8%) 70%)`,
          }}
        />
        <div className="explanation">
          <strong>{explanation.title}</strong>
          <span>{explanation.detail}</span>
        </div>
        <div className="person">
          <div className="person-ring" />
          <strong>YOU</strong>
          <span>protected: the agent cannot change this</span>
        </div>
        {foreground && (
          <div className="plain-orbit" style={{ transform: `rotate(${orbit}deg)` }}>
            <span>generated helper</span>
          </div>
        )}
        <div className="plain-legend">
          <span className="human-dot" /> you
          <span className="agent-dot" /> agent work
        </div>
      </main>

      <aside className="plain-proof">
        <h2>What this demonstrates</h2>
        <p>
          The agent can make many small changes without asking every time—but only inside
          the allowance you gave it.
        </p>
        <ul>
          <li>Your signal never changes.</li>
          <li>The allowance only goes down.</li>
          <li>A forbidden move is blocked and ends permission.</li>
          <li>Stop removes generated work that depended on the background.</li>
        </ul>

        <div className={`proof-check ${verdict.valid ? "pass" : "fail"}`}>
          <strong>{verdict.valid ? "REPLAY CHECK PASSED" : "REPLAY CHECK FAILED"}</strong>
          <span>The event history reconstructs this exact screen.</span>
        </div>

        <details>
          <summary>Technical details ({events.length} events)</summary>
          <div className="plain-events">
            {[...events].reverse().map((event) => (
              <div key={event.seq}>
                <code>{event.type}</code>
                <span>t{event.t}</span>
              </div>
            ))}
          </div>
        </details>
      </aside>
    </div>
  );
}

function PlainMeter({
  label,
  value,
  max,
}: {
  label: string;
  value: number;
  max: number;
}) {
  const percent = Math.max(0, Math.min(100, (value / max) * 100));
  return (
    <div className="plain-meter" aria-label={`${label}: ${value} of ${max}`}>
      <div style={{ width: `${percent}%` }} />
    </div>
  );
}

function explainState(
  status: "open" | "closed" | undefined,
  reason: string | undefined,
  mode: ClockMode,
): { title: string; detail: string } {
  if (!status) return { title: "Nothing can move yet.", detail: "Start with button 1." };
  if (status === "open" && mode === "flow") {
    return {
      title: "The agent is changing only the background.",
      detail: "Small moves happen automatically while the allowance counts down.",
    };
  }
  if (status === "open") {
    return {
      title: "The agent is allowed, but paused.",
      detail: "Make one move to inspect it, or let it run continuously.",
    };
  }
  if (reason === "out-of-angle") {
    return {
      title: "Forbidden move blocked. Permission ended.",
      detail: "The agent tried to change you. Nothing happened.",
    };
  }
  if (reason === "budget-exhausted") {
    return {
      title: "The allowance ran out. The agent stopped.",
      detail: "It could not spend one move beyond what you granted.",
    };
  }
  if (reason === "human-interrupt") {
    return {
      title: "You stopped it and rewound its work.",
      detail: "You remained. Generated dependent work was removed.",
    };
  }
  return { title: "Permission ended.", detail: "Use button 1 to grant a new allowance." };
}
