// provenance.ts
// "The audit log is what lets the toy become a tool."
//
// Every mutation on the stage answers: who/what did this, what changed, what
// did it depend on, was consent required, was it granted, and can it be undone.

export type ActorKind = "human" | "agent" | "system";

/** Who or what is acting. The human is the authority-bearing observer. */
export interface Actor {
  kind: ActorKind;
  /** Stable id: "human", or an agent id like "agent:scene-painter". */
  id: string;
  /** Optional friendly label for the audit overlay. */
  label?: string;
}

export const HUMAN: Actor = { kind: "human", id: "human", label: "You" };
export const SYSTEM: Actor = { kind: "system", id: "system", label: "System" };

export function agentActor(id: string, label?: string): Actor {
  const fullId = id.startsWith("agent:") ? id : `agent:${id}`;
  return { kind: "agent", id: fullId, label: label ?? id };
}

/** Attached to every layer and generated object. */
export interface Provenance {
  createdBy: Actor;
  createdAt: number;
  /**
   * Ids of layers / assets / proposals this thing relies on. Lets shake and
   * revocation reason about dependencies instead of blindly deleting.
   */
  dependsOn: string[];
  /** Human-readable reason the thing exists. */
  reason?: string;
}

export type AuditEventType =
  | "proposal.received"
  | "proposal.accepted"
  | "proposal.rejected"
  | "layer.created"
  | "layer.updated"
  | "layer.removed"
  | "param.keyframed"
  | "shake"
  | "consent.granted"
  | "consent.denied";

export interface AuditEvent {
  id: string;
  at: number;
  actor: Actor;
  type: AuditEventType;
  /** One-line summary for the audit overlay. */
  summary: string;
  /** Layer affected, when applicable. */
  layerId?: string;
  dependsOn?: string[];
  consentRequired: boolean;
  consentGranted: boolean;
  /** Whether this change can be shaken / reverted. */
  reversible: boolean;
  /** Free-form structured details. */
  details?: Record<string, unknown>;
}

/**
 * Append-only log. It is the run's memory under constraint: we only add,
 * never rewrite history, so a run stays legible afterward.
 */
export class AuditLog {
  private events: AuditEvent[] = [];

  append(event: AuditEvent): AuditEvent {
    this.events.push(event);
    return event;
  }

  list(): readonly AuditEvent[] {
    return this.events;
  }

  byActor(actorId: string): AuditEvent[] {
    return this.events.filter((e) => e.actor.id === actorId);
  }

  byLayer(layerId: string): AuditEvent[] {
    return this.events.filter((e) => e.layerId === layerId);
  }

  byType(type: AuditEventType): AuditEvent[] {
    return this.events.filter((e) => e.type === type);
  }

  clear(): void {
    this.events = [];
  }
}
