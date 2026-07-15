"""Void cartography, goal-relative: what is next.

Reads an atlas (nodes with depends_on / cited_by / taught) and a goal's observer
(assumed_ground = what the learner already holds). The ready frontier is the set
of nodes whose prerequisites are all in ground but which the observer does not
yet hold -- ranked by information gain (downstream leverage = cited_by) reweighted
by the goal's emphasis priors, sharpened by beta. Same schema as the real atlas.
"""
from __future__ import annotations

import math


def frontier(atlas: list[dict], goal: dict) -> list[dict]:
    obs = goal.get("observer", {})
    ground = set(obs.get("assumed_ground", []))
    priors = goal.get("priors", {})
    emphasis = priors.get("emphasis", {})
    beta = float(priors.get("beta", 3.0))

    cand = []
    for n in atlas:
        nid = n["id"]
        if nid in ground:
            continue
        if set(n.get("depends_on", [])) <= ground:      # prerequisites met -> ready
            ig = (1 + n.get("cited_by", 0)) * float(emphasis.get(nid, 1.0))
            cand.append({"id": nid, "title": n.get("title", nid),
                         "ig": round(ig, 3), "cited_by": n.get("cited_by", 0),
                         "taught": bool(n.get("taught", False))})

    if cand:  # Gibbs share over the frontier (beta = inverse epistemic temperature)
        ws = [math.exp(beta * math.log(max(c["ig"], 1e-9))) for c in cand]
        z = sum(ws)
        for c, w in zip(cand, ws):
            c["share"] = round(w / z, 3)
    cand.sort(key=lambda c: c["ig"], reverse=True)
    return cand


def frontier_chapters(chapters: list[dict], goal: dict) -> list[dict]:
    """The same void cartography over the book's real chapter graph: a chapter is
    ready when its prerequisite chapters are all in the observer's ground; leverage
    is how many later chapters build on it."""
    obs = goal.get("observer", {})
    ground = set(obs.get("assumed_ground", []))
    priors = goal.get("priors", {})
    emphasis = priors.get("emphasis", {})
    beta = float(priors.get("beta", 3.0))

    downstream: dict[str, int] = {}
    for c in chapters:
        for p in c.get("prerequisite_ids", []):
            downstream[p] = downstream.get(p, 0) + 1

    cand = []
    for c in chapters:
        cid = c["id"]
        if cid in ground:
            continue
        if set(c.get("prerequisite_ids", [])) <= ground:
            ig = (1 + downstream.get(cid, 0)) * float(emphasis.get(cid, 1.0))
            cand.append({"id": cid, "title": c["title"], "ig": round(ig, 3),
                         "downstream": downstream.get(cid, 0),
                         "refs": len(c.get("atlas_refs", []))})

    if cand:
        ws = [math.exp(beta * math.log(max(c["ig"], 1e-9))) for c in cand]
        z = sum(ws)
        for c, w in zip(cand, ws):
            c["share"] = round(w / z, 3)
    cand.sort(key=lambda c: c["ig"], reverse=True)
    return cand
