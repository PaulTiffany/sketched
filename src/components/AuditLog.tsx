import type { AuditEvent } from "../core/provenance";

interface Props {
  events: readonly AuditEvent[];
}

function toneOf(e: AuditEvent): string {
  if (e.type === "proposal.accepted") return "accepted";
  if (e.type === "proposal.rejected" || e.type === "consent.denied") return "rejected";
  if (e.type === "shake") return "shake";
  return "";
}

/** The audit log is what lets the toy become a tool. Newest first. */
export function AuditLog({ events }: Props) {
  const ordered = [...events].reverse();
  return (
    <div className="panel">
      <h2>Audit log ({events.length})</h2>
      <div className="audit">
        {ordered.length === 0 && <p className="hint">Nothing has happened yet.</p>}
        {ordered.map((e) => (
          <div key={e.id} className={`ev ${toneOf(e)}`}>
            <div>{e.summary}</div>
            <div className="who">
              {e.actor.label ?? e.actor.id}
              {e.consentRequired && ` · consent ${e.consentGranted ? "✓" : "✗"}`}
              {` · ${e.reversible ? "reversible" : "final"}`}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
