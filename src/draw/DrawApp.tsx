import { useEffect, useRef, useState } from "react";
import { createBlankStage, Stage } from "../core/stage";
import { HUMAN, type Actor } from "../core/provenance";
import { shake } from "../core/shake";
import { AutoConsentPolicy } from "../core/consent";
import { Gatekeeper } from "../agents/gatekeeper";
import { RemoteSeat, type ProviderId, type SeatConfig } from "../agents/remoteSeat";
import type { Proposal } from "../agents/agentProtocol";
import "./draw.css";

// Draw mode is the presented face of Sketched. It is not a separate toy: every
// stroke is a real, human-owned layer on the Stage (agents cannot mutate it),
// every agent note arrives as an annotate Proposal through the Gatekeeper, and
// the audit log is the real one. The interface hides the machinery; the
// "under the hood" reveal shows it.

interface Stroke {
  pts: [number, number][];
}
const AGENT: Actor = { kind: "agent", id: "seat", label: "Seated agent" };
const SEAT_KEY = "sketched.seat.v1";
const INK_KEY = "sketched.ink.v1";

function loadStrokes(): Stroke[] {
  try {
    return JSON.parse(localStorage.getItem(INK_KEY) || "[]");
  } catch {
    return [];
  }
}

export function DrawApp() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const wiring = useRef<{ stage: Stage; gate: Gatekeeper } | null>(null);
  if (!wiring.current) {
    const stage = createBlankStage();
    // The human's ink: a human-owned, human-mutable layer. Agents have no
    // path to it (mutableBy: "human"); shake preserves it (shakeable: false).
    stage.createLayer(
      {
        kind: "annotation",
        name: "Human ink",
        mutableBy: "human",
        shakeable: false,
        params: { strokes: JSON.stringify(loadStrokes()) },
        reason: "The human's own marks. Held by the human.",
      },
      HUMAN,
    );
    wiring.current = { stage, gate: new Gatekeeper(stage, new AutoConsentPolicy()) };
  }
  const { stage, gate } = wiring.current;
  const inkId = stage.listLayers().find((l) => l.name === "Human ink")!.id;

  const [, bump] = useState(0);
  const rerender = () => bump((v) => v + 1);
  const [strokes, setStrokes] = useState<Stroke[]>(loadStrokes);
  const [camera, setCamera] = useState(false);
  const [seated, setSeated] = useState<boolean>(() => !!localStorage.getItem(SEAT_KEY));
  const [seatOpen, setSeatOpen] = useState(false);
  const [status, setStatus] = useState("");
  const [showAudit, setShowAudit] = useState(false);
  const seat = useRef<RemoteSeat | null>(null);
  const cur = useRef<Stroke | null>(null);

  // agent annotation layers, newest first
  const notes = stage
    .listLayers()
    .filter((l) => l.kind === "annotation" && l.owner.kind === "agent")
    .reverse();

  useEffect(() => {
    const c = canvasRef.current;
    if (!c) return;
    const dpr = window.devicePixelRatio || 1;
    const fit = () => {
      const r = c.getBoundingClientRect();
      c.width = r.width * dpr;
      c.height = r.height * dpr;
      paint();
    };
    const paint = () => {
      const ctx = c.getContext("2d")!;
      ctx.clearRect(0, 0, c.width, c.height);
      ctx.strokeStyle = "rgba(244,241,232,0.94)";
      ctx.lineWidth = 3.2 * dpr;
      ctx.lineCap = "round";
      ctx.lineJoin = "round";
      for (const s of strokes) {
        ctx.beginPath();
        s.pts.forEach(([x, y], i) =>
          i ? ctx.lineTo(x * c.width, y * c.height) : ctx.moveTo(x * c.width, y * c.height),
        );
        ctx.stroke();
      }
    };
    fit();
    window.addEventListener("resize", fit);
    return () => window.removeEventListener("resize", fit);
  }, [strokes]);

  // camera is embodied presence: rendered locally into the human-video ground,
  // never recorded, never uploaded. Toggling it is a human mutation on the
  // human layer (permitted; agents can never do this).
  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;
    if (camera) {
      navigator.mediaDevices
        ?.getUserMedia({ video: { facingMode: "environment" } })
        .then((s) => {
          v.srcObject = s;
          v.play().catch(() => {});
          const ground = stage.listLayers().find((l) => l.kind === "human-video");
          if (ground) stage.updateParams(ground.id, { mode: "camera" }, HUMAN);
        })
        .catch(() => setStatus("camera unavailable"));
    } else {
      const s = v.srcObject as MediaStream | null;
      s?.getTracks().forEach((t) => t.stop());
      v.srcObject = null;
      const ground = stage.listLayers().find((l) => l.kind === "human-video");
      if (ground) stage.updateParams(ground.id, { mode: "blank" }, HUMAN);
    }
  }, [camera]);

  function pos(e: React.PointerEvent) {
    const r = canvasRef.current!.getBoundingClientRect();
    return [(e.clientX - r.left) / r.width, (e.clientY - r.top) / r.height] as [number, number];
  }
  function down(e: React.PointerEvent) {
    e.preventDefault();
    cur.current = { pts: [pos(e)] };
    setStrokes((s) => [...s, cur.current!]);
  }
  function move(e: React.PointerEvent) {
    if (!cur.current) return;
    cur.current.pts.push(pos(e));
    setStrokes((s) => [...s]);
  }
  function up() {
    if (!cur.current) return;
    cur.current = null;
    // Persist the stroke as a mutation on the human ink layer: audited, owned.
    const next = strokes;
    stage.updateParams(inkId, { strokes: JSON.stringify(next) }, HUMAN);
    localStorage.setItem(INK_KEY, JSON.stringify(next));
    rerender();
  }

  function erase() {
    // The human holds the eraser. Clears human ink directly (human authority).
    setStrokes([]);
    stage.updateParams(inkId, { strokes: "[]" }, HUMAN);
    localStorage.setItem(INK_KEY, "[]");
    rerender();
  }
  function clearAgent() {
    // Scoped revocation: shake the agent's contributions only. Human ink is
    // non-shakeable and the human-video ground is preserved regardless.
    shake(stage, { kind: "agent", agentId: AGENT.id }, HUMAN);
    rerender();
  }

  function snapshot(): string {
    const c = canvasRef.current!;
    const out = document.createElement("canvas");
    out.width = c.width;
    out.height = c.height;
    const o = out.getContext("2d")!;
    o.fillStyle = "#20242b";
    o.fillRect(0, 0, out.width, out.height);
    const v = videoRef.current;
    if (camera && v && v.videoWidth) o.drawImage(v, 0, 0, out.width, out.height);
    o.drawImage(c, 0, 0);
    return out.toDataURL("image/png");
  }

  async function ask() {
    if (!seat.current) return;
    setStatus("agent: looking (you asked)");
    try {
      const lines = await seat.current.askOnce(snapshot());
      // Each line becomes an annotate proposal through the gate. The gate
      // consent-checks and the stage audits; nothing bypasses it.
      const props: Proposal[] = lines.map((text) => ({
        id: stage.newId("proposal"),
        from: AGENT,
        at: stage.now(),
        action: { type: "annotate", text },
        reason: "Seated agent annotation (human asked).",
      }));
      const results = gate.submitAll(props);
      const ok = results.filter((r) => r.outcome === "accepted").length;
      setStatus(`agent: ${ok} note${ok === 1 ? "" : "s"} added, through the gate`);
      rerender();
    } catch (err) {
      setStatus("agent: could not answer (" + String((err as Error).message).slice(0, 60) + ")");
    }
  }

  function seatAgent(provider: ProviderId, apiKey: string, model?: string) {
    const cfg: SeatConfig = { provider, apiKey, model: model || undefined };
    seat.current = new RemoteSeat(AGENT, cfg);
    localStorage.setItem(SEAT_KEY, JSON.stringify({ provider, model: model || "" }));
    // key is held in memory only for the session; not persisted to storage.
    setSeated(true);
    setSeatOpen(false);
    setStatus("agent seated on your terms");
  }
  function unseat() {
    seat.current = null;
    localStorage.removeItem(SEAT_KEY);
    clearAgent();
    setSeated(false);
    setStatus("seat empty");
  }

  const events = stage.audit.list ? stage.audit.list() : [];

  return (
    <div className="draw-app">
      <header className="draw-bar">
        <div className="draw-brand">
          <strong>Sketched</strong>
          <small>draw mode · every mark is governed</small>
        </div>
        <span className="draw-spacer" />
        <button onClick={() => setCamera((c) => !c)} className={camera ? "on" : ""}>
          {camera ? "camera on" : "camera"}
        </button>
        <button onClick={erase}>erase</button>
        {seated ? (
          <>
            <button className="amber" onClick={ask}>
              ask agent
            </button>
            <button onClick={clearAgent}>clear notes</button>
            <button className="ghost" onClick={unseat} title="remove notes, seat, and key">
              unseat
            </button>
          </>
        ) : (
          <button className="amber" onClick={() => setSeatOpen(true)}>
            seat an agent
          </button>
        )}
      </header>

      <main className="draw-stage">
        <video ref={videoRef} className="draw-video" playsInline muted />
        <canvas
          ref={canvasRef}
          className="draw-canvas"
          onPointerDown={down}
          onPointerMove={move}
          onPointerUp={up}
          onPointerLeave={up}
        />
        {notes.length > 0 && (
          <div className="note-strip">
            {notes.map((n) => (
              <div className="note" key={n.id}>
                {String(n.params.text ?? "")}
                <small>agent · through the gate · tap “clear notes” to revoke</small>
              </div>
            ))}
          </div>
        )}
      </main>

      <footer className="draw-foot">
        <span>{status || "your marks live in your browser only"}</span>
        <span className="draw-spacer" />
        <button className="ghost" onClick={() => setShowAudit((s) => !s)}>
          {showAudit ? "hide" : "under the hood"}
        </button>
        <a className="ghost" href="/book">
          the theory
        </a>
      </footer>

      {showAudit && (
        <aside className="audit-drawer">
          <h3>Audit log · {events.length} events</h3>
          <p className="audit-note">
            Every stroke, every agent proposal, every consent decision, every
            shake — recorded here, in order. Agents propose; the surface disposes.
          </p>
          <ol>
            {events
              .slice(-40)
              .reverse()
              .map((e) => (
                <li key={e.id} className={"ev ev-" + e.type.replace(/\./g, "-")}>
                  <code>{e.actor.kind}</code> {e.summary}
                  {e.consentRequired && (
                    <em>{e.consentGranted ? " · consent granted" : " · consent denied"}</em>
                  )}
                </li>
              ))}
          </ol>
        </aside>
      )}

      {seatOpen && (
        <SeatDialog onCancel={() => setSeatOpen(false)} onSeat={seatAgent} />
      )}
    </div>
  );
}

function SeatDialog({
  onCancel,
  onSeat,
}: {
  onCancel: () => void;
  onSeat: (p: ProviderId, k: string, m?: string) => void;
}) {
  const [provider, setProvider] = useState<ProviderId>("openrouter");
  const [key, setKey] = useState("");
  const [model, setModel] = useState("");
  return (
    <div className="seat-scrim" onClick={onCancel}>
      <div className="seat-card" onClick={(e) => e.stopPropagation()}>
        <span className="eyebrow">the agent’s covenant · it sits below you</span>
        <h2>Seat a real agent.</h2>
        <ul>
          <li>
            <strong>Reads only when you ask</strong> — one snapshot per tap, sent
            from this browser straight to the provider. No Sketched server exists.
          </li>
          <li>
            <strong>Writes only notes in its own layer</strong> — it cannot draw,
            erase, or touch a human mark. Every note passes the Gatekeeper and is
            logged.
          </li>
          <li>
            <strong>You clear it anytime</strong> — notes, seat, and key, all
            revocable.
          </li>
          <li>
            <strong>Your key, held in memory only</strong> — not written to
            storage; gone when you close the tab.
          </li>
        </ul>
        <div className="seat-providers">
          <button
            className={provider === "openrouter" ? "sel" : ""}
            onClick={() => setProvider("openrouter")}
          >
            OpenRouter (free models)
          </button>
          <button
            className={provider === "anthropic" ? "sel" : ""}
            onClick={() => setProvider("anthropic")}
          >
            Anthropic
          </button>
        </div>
        <input
          type="password"
          autoComplete="off"
          placeholder={provider === "anthropic" ? "sk-ant-..." : "sk-or-..."}
          value={key}
          onChange={(e) => setKey(e.target.value)}
        />
        <input
          type="text"
          placeholder={
            provider === "openrouter"
              ? "model (blank = free Qwen-VL)"
              : "model (blank = Haiku)"
          }
          value={model}
          onChange={(e) => setModel(e.target.value)}
        />
        <p className="fine">
          Keys come from the provider’s console. The call carries an honest
          direct-browser-access header. Nothing here talks to a server of mine.
        </p>
        <button className="amber wide" disabled={!key.trim()} onClick={() => onSeat(provider, key.trim(), model.trim())}>
          seat the agent on these terms
        </button>
        <button className="ghost wide" onClick={onCancel}>
          leave the seat empty
        </button>
      </div>
    </div>
  );
}
