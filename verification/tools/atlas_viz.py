"""Render verification/atlas.json as a self-contained interactive HTML/SVG
dependency graph: verification/atlas.html.

Layout: sections as swimlane columns (document order, left to right);
nodes stacked within their section. Edges point from a result to what it
depends on (solid = \\ref hard edges, dashed = symbol edges). Node fill
encodes ledger status (P/D/S/M/C/O); assumption tokens appear as chips.
Remarks are hidden by default (toggle). Hovering a node highlights its
dependency neighborhood. No external assets; works offline.
"""

from __future__ import annotations

import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "atlas.json"
OUT = ROOT / "atlas.html"

STATUS_COLORS = {
    "P": "#2e7d32",
    "D": "#1565c0",
    "S": "#00838f",
    "M": "#ef6c00",
    "C": "#6a1b9a",
    "O": "#c62828",
}
DEFAULT_COLOR = "#616161"

TYPE_LABEL = {
    "definition": "def",
    "assumption": "asm",
    "lemma": "lem",
    "proposition": "prop",
    "theorem": "thm",
    "theorem_target": "target",
    "conjecture": "conj",
    "remark": "rem",
}

NODE_W, NODE_H, VGAP, COL_W, PAD = 200, 46, 14, 240, 30


def main() -> None:
    atlas = json.loads(ATLAS.read_text(encoding="utf-8"))
    nodes = [n for n in atlas["nodes"]]
    by_id = {n["id"]: n for n in nodes}

    # assign nodes to section columns in document order
    sections: list[str] = []
    for n in nodes:
        sec = n["section"] or "(front matter)"
        if sec not in sections:
            sections.append(sec)
    col_of = {sec: i for i, sec in enumerate(sections)}

    pos: dict[str, tuple[float, float]] = {}
    depth: dict[int, int] = {}
    for n in nodes:
        c = col_of[n["section"] or "(front matter)"]
        r = depth.get(c, 0)
        depth[c] = r + 1
        x = PAD + c * COL_W
        y = PAD + 40 + r * (NODE_H + VGAP)
        pos[n["id"]] = (x, y)

    width = PAD * 2 + len(sections) * COL_W
    height = PAD * 2 + 40 + max(depth.values()) * (NODE_H + VGAP)

    def status_color(n) -> str:
        s = (n.get("status_ledger_claim") or "").strip()
        return STATUS_COLORS.get(s[:1], DEFAULT_COLOR)

    edges_svg: list[str] = []
    for n in nodes:
        if n["type"] == "remark":
            continue
        x1, y1 = pos[n["id"]]
        for dep, dashed in (
            [(d, False) for d in n["hard_dependencies"]]
            + [(d, True) for d in n.get("symbol_dependencies", [])
               if d not in n["hard_dependencies"]]
        ):
            if dep not in by_id or by_id[dep]["type"] == "remark":
                continue
            x2, y2 = pos[dep]
            sx, sy = x1, y1 + NODE_H / 2
            tx, ty = x2 + NODE_W, y2 + NODE_H / 2
            mx = (sx + tx) / 2
            dash = ' stroke-dasharray="5 4"' if dashed else ""
            edges_svg.append(
                f'<path class="edge from-{n["id"]} to-{dep}" '
                f'd="M {sx} {sy} C {mx} {sy}, {mx} {ty}, {tx} {ty}"'
                f'{dash}/>'
            )

    nodes_svg: list[str] = []
    for n in nodes:
        x, y = pos[n["id"]]
        color = status_color(n)
        remark_cls = " remark" if n["type"] == "remark" else ""
        status = html.escape((n.get("status_ledger_claim") or "").strip() or "·")
        tlabel = TYPE_LABEL.get(n["type"], n["type"])
        title = html.escape(n.get("title") or n["id"])
        chips = " ".join(html.escape(t) for t in n["assumptions_consumed"])
        proofless = (
            n["type"] in ("lemma", "proposition", "theorem")
            and n["proof_status"].startswith("stated_no_proof")
        )
        stroke = "#000" if not proofless else "#c62828"
        nodes_svg.append(
            f'<g class="node{remark_cls}" data-id="{n["id"]}">'
            f'<title>{title}\n[{tlabel}] status={status} '
            f'lines {n["source_span"][0]}-{n["source_span"][1]}'
            + (f"\nconsumes: {chips}" if chips else "")
            + "</title>"
            f'<rect x="{x}" y="{y}" width="{NODE_W}" height="{NODE_H}" rx="6" '
            f'fill="{color}" fill-opacity="0.14" stroke="{stroke}"/>'
            f'<rect x="{x}" y="{y}" width="6" height="{NODE_H}" rx="2" fill="{color}"/>'
            f'<text x="{x + 12}" y="{y + 18}" class="nid">{html.escape(n["id"])}</text>'
            f'<text x="{x + 12}" y="{y + 34}" class="nmeta">[{tlabel}] {status}'
            + (f' — {chips}' if chips else "")
            + "</text></g>"
        )

    headers_svg = [
        f'<text x="{PAD + i * COL_W}" y="{PAD + 14}" class="sec">'
        f"{html.escape(sec[:30])}</text>"
        for i, sec in enumerate(sections)
    ]

    legend = " ".join(
        f'<span class="lg" style="background:{c}">{s}</span>'
        for s, c in STATUS_COLORS.items()
    )

    page = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Forcing Correspondence — dependency atlas</title>
<style>
 body {{ font-family: system-ui, sans-serif; margin: 12px; }}
 .nid {{ font: 12px monospace; }}
 .nmeta {{ font: 10px monospace; fill: #444; }}
 .sec {{ font: bold 11px sans-serif; fill: #333; }}
 .edge {{ fill: none; stroke: #9993; stroke-width: 1.4; pointer-events: none; }}
 .edge.hi {{ stroke: #d32f2f; stroke-width: 2.2; }}
 .node {{ cursor: pointer; }}
 .node.dim {{ opacity: 0.25; }}
 .remark {{ display: none; }}
 body.show-remarks .remark {{ display: inline; }}
 .lg {{ color: #fff; padding: 2px 8px; border-radius: 4px; font: 11px monospace; }}
 .bar {{ margin-bottom: 8px; }}
</style></head><body>
<div class="bar">
 <strong>{html.escape(atlas["source"])}</strong> — theorem dependency atlas
 &nbsp; {legend} &nbsp;
 <label><input type="checkbox" id="rt"> show remarks</label>
 &nbsp; <em>solid = \\ref edge, dashed = symbol edge; red border = no proof
 environment; hover a node to highlight its neighborhood</em>
</div>
<svg width="{width}" height="{height}" id="g">
{chr(10).join(headers_svg)}
{chr(10).join(edges_svg)}
{chr(10).join(nodes_svg)}
</svg>
<script>
 document.getElementById('rt').addEventListener('change', e =>
   document.body.classList.toggle('show-remarks', e.target.checked));
 const nodes = document.querySelectorAll('.node');
 nodes.forEach(n => {{
   n.addEventListener('mouseenter', () => {{
     const id = n.dataset.id;
     const touched = new Set([id]);
     document.querySelectorAll('.edge').forEach(e => {{
       const cls = e.getAttribute('class');
       if (cls.includes('from-' + id + ' ') || cls.endsWith('to-' + id)) {{
         e.classList.add('hi');
         cls.split(' ').forEach(c => {{
           if (c.startsWith('from-')) touched.add(c.slice(5));
           if (c.startsWith('to-')) touched.add(c.slice(3));
         }});
       }}
     }});
     nodes.forEach(m => {{
       if (!touched.has(m.dataset.id)) m.classList.add('dim');
     }});
   }});
   n.addEventListener('mouseleave', () => {{
     document.querySelectorAll('.edge.hi').forEach(e => e.classList.remove('hi'));
     nodes.forEach(m => m.classList.remove('dim'));
   }});
 }});
</script>
</body></html>
"""
    OUT.write_text(page, encoding="utf-8")
    print(f"wrote {OUT} ({len(nodes)} nodes, {len(edges_svg)} edges, "
          f"{len(sections)} section lanes)")


if __name__ == "__main__":
    main()
