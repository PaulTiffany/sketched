"""Self-compile target: goal + frontier + lesson -> a self-contained page.

The witnessed pre-prompt (the goal), the void-map frontier it induces, and the
gated lesson where an instrument grounds it -- rendered together, so the steering
sits on the page next to the teaching. One program, one more rendering.
"""
from __future__ import annotations

import json

_CHIP = {"Matt": "#6fb2ef", "Ellie": "#d9b25f"}


def esc(s) -> str:
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


_CSS = """
:root{--slate:#0d0f0e;--chalk:#f4f1e8;--dust:#9aa2ad;--rule:#2a2f2c;}
*{box-sizing:border-box}
body{margin:0;background:
  radial-gradient(120% 90% at 50% -10%,#16181c 0%,var(--slate) 60%,#070908 100%);
  color:var(--chalk);font-family:Georgia,serif;line-height:1.55;padding:3rem 1.2rem 5rem}
.wrap{max-width:780px;margin:0 auto}
h1{font-weight:400;letter-spacing:.02em;margin:0 0 .1rem;font-size:1.7rem}
h2{font-weight:400;color:#d9b25f;font-size:1.05rem;letter-spacing:.04em;
  margin:2rem 0 .6rem;text-transform:uppercase}
.sub{color:var(--dust);font-style:italic;margin:0 0 1rem}
.rule{height:1px;background:linear-gradient(90deg,transparent,#d9b25f88,transparent);margin:1.4rem 0}
.goal{border:1px solid var(--rule);border-radius:10px;padding:.9rem 1.05rem;margin:.8rem 0;
  background:rgba(255,255,255,.015)}
.goal .id{font-family:ui-monospace,Consolas,monospace;color:#d9b25f;font-size:12px}
.goal .obj{margin:.25rem 0 .5rem;font-size:1.02rem}
.kv{font-family:ui-monospace,Consolas,monospace;font-size:11px;color:var(--dust);margin:.15rem 0}
.chip{font-family:ui-monospace,Consolas,monospace;font-size:10.5px;border-radius:4px;
  padding:2px 7px;color:#dfd7c4;background:#ffffff0d;border:1px solid #ffffff1a;margin-right:.3rem}
table{border-collapse:collapse;width:100%;margin:.5rem 0;font-family:ui-monospace,Consolas,monospace;font-size:12px}
td,th{text-align:left;padding:.28rem .5rem;border-bottom:1px solid var(--rule);color:var(--dust)}
th{color:#cfcabb;font-weight:400}
td.realized{color:#93c94a}td.target{color:#e0a24c}
tr.pick td{color:var(--chalk)}
.note{color:#e0a24c;font-style:italic;font-size:.95rem;margin:.4rem 0}
.seg{border:1px solid var(--rule);border-radius:10px;padding:1rem 1.15rem;margin:1rem 0;
  background:rgba(255,255,255,.015)}
.head{display:flex;align-items:center;gap:.6rem;margin-bottom:.5rem}
.who{font-size:1.05rem;letter-spacing:.03em}
.act{font-family:ui-monospace,Consolas,monospace;font-size:11px;color:var(--dust)}
.pass{margin-left:auto;font-family:ui-monospace,monospace;font-size:11px;color:#0c1a0c;
  background:#93c94a;border-radius:4px;padding:1px 7px}
.flow{margin-left:auto;font-family:ui-monospace,monospace;font-size:11px;color:#3a2f10;
  background:#d9b25f;border-radius:4px;padding:1px 7px}
.speech{margin:.2rem 0 .6rem;font-size:1.08rem}
.boundary{color:#d9b25f;font-style:italic;font-size:.92rem;margin:.2rem 0 .5rem;
  border-left:2px solid #d9b25f55;padding-left:.6rem}
.meta{display:flex;flex-wrap:wrap;gap:.35rem}
.ev{font-family:ui-monospace,Consolas,monospace;font-size:10.5px;border-radius:4px;padding:2px 7px;
  color:#cfe0f6;background:#6fb2ef22;border:1px solid #6fb2ef33}
.lk{font-family:ui-monospace,Consolas,monospace;font-size:10.5px;border-radius:4px;padding:2px 7px;
  color:#dfd7c4;background:#ffffff0d;border:1px solid #ffffff1a}
.foot{margin-top:1rem;font-family:ui-monospace,Consolas,monospace;font-size:12px;color:var(--dust)}
.foot b{color:#93c94a;font-weight:400}
details{margin-top:1rem}summary{cursor:pointer;color:var(--dust);font-size:12px;font-family:ui-monospace,monospace}
pre{overflow-x:auto;background:#0000004d;border:1px solid var(--rule);border-radius:8px;
  padding:1rem;font-size:11.5px;color:#cdd3cb}
"""


def _frontier_table(res: dict) -> str:
    if not res["frontier"]:
        return '<p class="note">frontier empty &mdash; the observer already holds the ready set.</p>'
    rows = ""
    for c in res["frontier"]:
        pick = res["chosen"] and c["id"] == res["chosen"]["id"]
        inst = "realized" if c.get("instrument") else "target"
        rows += (f'<tr class="{"pick" if pick else ""}"><td>{"&#9733;" if pick else ""}</td>'
                 f'<td>{esc(c["id"])}</td><td>{c["ig"]:.1f}</td>'
                 f'<td>{c.get("share", "")}</td><td class="{inst}">{inst}</td></tr>')
    return ('<table><tr><th></th><th>ready topic</th><th>IG</th><th>share</th>'
            f'<th>instrument</th></tr>{rows}</table>')


def _goal_card(res: dict) -> str:
    g = res["goal"]
    ground = "".join(f'<span class="chip">{esc(x)}</span>'
                     for x in g["observer"].get("assumed_ground", [])) or \
             '<span class="chip">(empty)</span>'
    pr = g.get("priors", {})
    emph = pr.get("emphasis", {}) or "none"
    chosen = res["chosen"]
    if chosen and res["instrument"]:
        nxt = (f'<p class="kv">next: <b style="color:#93c94a">{esc(chosen["id"])}</b> '
               f'&rarr; instrument <b style="color:#93c94a">realized</b> '
               f'&rarr; compiled below.</p>')
    elif chosen:
        nxt = (f'<p class="note">next: {esc(chosen["id"])} &mdash; no grounded '
               f'instrument yet (target). Ellie returns a gap here, not a fabricated '
               f'lesson. This is exactly where an instrument is needed.</p>')
    else:
        nxt = '<p class="note">nothing ready.</p>'
    return (f'<div class="goal"><div class="id">goal: {esc(g["id"])} &middot; mode={esc(g["mode"])}</div>'
            f'<div class="obj">{esc(g["objective"])}</div>'
            f'<div class="kv">observer holds: {ground}</div>'
            f'<div class="kv">priors: beta={pr.get("beta")} &middot; emphasis={esc(emph)} '
            f'&middot; budget={pr.get("duration_min")}m</div>'
            f'{_frontier_table(res)}{nxt}</div>')


def _seg(node: dict, rep: dict) -> str:
    sp = node["speaker"]
    color = _CHIP.get(sp, "#ccc")
    ev = "".join(f'<span class="ev">{esc(e)}</span>' for e in node.get("evidence", []))
    lk = "".join(f'<span class="lk">{esc(l)}</span>' for l in node.get("links", []))
    badge = (f'<span class="pass">{rep["verdict"]}</span>' if sp == "Matt"
             else '<span class="flow">flow</span>')
    boundary = (f'<p class="boundary">boundary: {esc(node["boundary"])}</p>'
                if node.get("boundary") else "")
    return (f'<div class="seg"><div class="head"><span class="who" style="color:{color}">{sp}</span>'
            f'<span class="act">{esc(node["act"])}</span>{badge}</div>'
            f'<p class="speech">{esc(node["speech"])}</p>{boundary}'
            f'<div class="meta">{ev}{lk}</div></div>')


def _lesson(res: dict) -> str:
    segs = "\n".join(_seg(n, r) for n, r in zip(res["nodes"], res["reports"]))
    j = res["judge"]
    ok = "PASS" if j["checks_pass"] else "FAIL"
    node_json = esc(json.dumps(res["nodes"], indent=2))
    return (f'<h2>Lesson &mdash; {esc(res["goal"]["id"])} &rarr; {esc(res["chosen"]["id"])}</h2>{segs}'
            f'<div class="foot"><p>judge &mdash; objective covered: <b>{j["objective_covered"]}</b> '
            f'&middot; Matt masking &mu;=0: <b>{j["masking_zero"]}</b> &middot; ~{j["minutes"]} min '
            f'&middot; overall <b>{ok}</b></p>'
            f'<p>self-compiles from one program to: podcast &middot; textbook &middot; slides &middot; video</p></div>'
            f'<details><summary>semantic program (the nodes)</summary><pre>{node_json}</pre></details>')


def render_page(results: list[dict]) -> str:
    control = "\n".join(_goal_card(r) for r in results)
    lessons = "\n".join(_lesson(r) for r in results if r["nodes"])
    return f"""<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Ellie &amp; Matt &mdash; goal-general</title>
<style>{_CSS}</style></head><body><div class="wrap">
<h1>Ellie &amp; Matt &mdash; one engine, any goal</h1>
<p class="sub">Swap the goal (a witnessed pre-prompt). The void map re-scores relative
to the observer it serves. A lesson compiles only where a grounded instrument exists.</p>
<h2>Control &mdash; the goals and their frontiers</h2>
{control}
<div class="rule"></div>
{lessons}
</div></body></html>"""
