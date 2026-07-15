// remoteSeat.ts
// A real, subordinate agent seat. Bring-your-own-key; the request goes from
// this browser straight to the provider (no Sketched server exists). The seat
// is bound by the same contract as every agent: it only ever emits `annotate`
// proposals, which the Gatekeeper consent-checks and the Stage records. There
// is no code path from this class to the canvas or to a human layer.
//
// The snapshot (a PNG of the current board) is the ONLY thing sent, and only
// when the human calls askOnce(). Nothing is streamed, stored remotely, or
// sent unprompted.

import type { Agent, AgentContext, Proposal } from "./agentProtocol";
import type { Actor } from "../core/provenance";

export type ProviderId = "anthropic" | "openrouter";

export interface SeatConfig {
  provider: ProviderId;
  apiKey: string;
  /** Optional override; sensible vision-capable defaults per provider. */
  model?: string;
}

const DEFAULTS: Record<ProviderId, string> = {
  anthropic: "claude-haiku-4-5-20251001",
  openrouter: "qwen/qwen-2.5-vl-7b-instruct:free",
};

// The seat's standing orders. Editable in source — it still cannot reach the
// canvas, because its only output is annotate proposals through the gate.
export const SEAT_ORDERS =
  "You are a seated agent on a human's shared drawing surface, bound by a " +
  "covenant: you see the board only when the human asks, you may only add " +
  "brief annotations in your own layer, and the human can clear you at any " +
  "time. You cannot draw on or erase the human's marks. Given the board " +
  "snapshot, reply with 1 to 3 short, warm, useful annotations (each under " +
  "140 characters): what you see, one genuine observation, one playful " +
  "question. Reply as a JSON array of strings and nothing else. If the board " +
  "is blank, say so kindly and suggest one small thing to draw.";

function extractArray(text: string): string[] {
  const a = text.indexOf("["), b = text.lastIndexOf("]");
  if (a >= 0 && b > a) {
    try {
      const parsed = JSON.parse(text.slice(a, b + 1));
      if (Array.isArray(parsed)) return parsed.map(String);
    } catch {
      /* fall through */
    }
  }
  return [text.trim().slice(0, 140)];
}

/**
 * The seat is an Agent, but it does not manufacture proposals on a tick
 * (propose() returns []). Instead the UI calls askOnce() with a fresh
 * snapshot; the resulting annotation strings are turned into proposals by
 * the caller and submitted through the Gatekeeper. This keeps "the agent
 * reads only when asked" true by construction.
 */
export class RemoteSeat implements Agent {
  constructor(
    readonly actor: Actor,
    private config: SeatConfig,
  ) {}

  /** No unprompted proposals, ever. */
  propose(_context: AgentContext): Proposal[] {
    return [];
  }

  get label(): string {
    return `${this.config.provider}:${this.config.model ?? DEFAULTS[this.config.provider]}`;
  }

  /** Ask once with a PNG data URL. Returns annotation strings (never mutations). */
  async askOnce(pngDataUrl: string): Promise<string[]> {
    const b64 = pngDataUrl.split(",")[1] ?? "";
    const model = this.config.model ?? DEFAULTS[this.config.provider];
    if (this.config.provider === "anthropic") {
      return this.askAnthropic(model, b64);
    }
    return this.askOpenRouter(model, pngDataUrl);
  }

  private async askAnthropic(model: string, b64: string): Promise<string[]> {
    const r = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-api-key": this.config.apiKey,
        "anthropic-version": "2023-06-01",
        "anthropic-dangerous-direct-browser-access": "true",
      },
      body: JSON.stringify({
        model,
        max_tokens: 300,
        system: SEAT_ORDERS,
        messages: [
          {
            role: "user",
            content: [
              { type: "image", source: { type: "base64", media_type: "image/png", data: b64 } },
              { type: "text", text: "The human tapped ask. Annotate their board." },
            ],
          },
        ],
      }),
    });
    const j = await r.json();
    if (j.error) throw new Error(j.error.message || "provider error");
    const txt = j?.content?.[0]?.text ?? "[]";
    return extractArray(txt).slice(0, 3);
  }

  private async askOpenRouter(model: string, pngDataUrl: string): Promise<string[]> {
    const r = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${this.config.apiKey}`,
      },
      body: JSON.stringify({
        model,
        max_tokens: 300,
        messages: [
          { role: "system", content: SEAT_ORDERS },
          {
            role: "user",
            content: [
              { type: "text", text: "The human tapped ask. Annotate their board." },
              { type: "image_url", image_url: { url: pngDataUrl } },
            ],
          },
        ],
      }),
    });
    const j = await r.json();
    if (j.error) throw new Error(j.error.message || "provider error");
    const txt = j?.choices?.[0]?.message?.content ?? "[]";
    return extractArray(typeof txt === "string" ? txt : JSON.stringify(txt)).slice(0, 3);
  }
}
