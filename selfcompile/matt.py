"""Matt Sheen -- analytical instrumentation over the verified stack.

Each operator returns grounded Claims (Part A); Matt never renders prose.
Realized ops compute live (fresh numbers, not remembered quotes). Target ops
are DECLARED, not faked -- the repo's realized/target discipline (docs/13).
"""
from __future__ import annotations

import json
import math
from pathlib import Path

import bookdata
import fabricpc
from manifest import Claim

REALIZED = {"construct_example", "identify_assumptions", "evaluate_support",
            "lean_check", "cite_atlas", "fabricpc_profile",
            "lorentz_witness_report", "book5_coverage_report"}
_RECEIPT = Path(__file__).with_name("lean_receipt.json")
_STATUS_KIND = {"P": "theorem-status", "P-paper": "theorem-status"}
TARGET = {
    "trace_dependency", "find_counterexample", "explain_proof_step",
    "locate_citation", "compare_geometry", "show_equation_derivation",
}


def construct_example(topic: str, params: dict | None = None) -> list[Claim]:
    """Runs the feasibility-cliff geometry live:
    delta_min = (tau/m)*sqrt(k/(1-rho*(k-1))), diverging at rho_c = 1/(k-1)."""
    if topic != "feasibility_cliff":
        raise ValueError(f"construct_example: no live model for topic {topic!r}")
    p = params or {}
    k = int(p.get("k", 3))
    tau_over_m = float(p.get("tau_over_m", 1.0))
    rhos = [float(r) for r in p.get("rhos", [0.30, 0.40, 0.45, 0.49])]
    rho_c = 1.0 / (k - 1)
    samples = []
    for rho in rhos:
        denom = 1.0 - rho * (k - 1)
        if denom <= 0:
            raise ValueError(f"rho={rho} is past the cliff rho_c={rho_c}")
        samples.append((rho, tau_over_m * math.sqrt(k / denom)))

    dmins = tuple(round(d, 4) for _, d in samples)
    text_samples = ", ".join(f"delta_min({r})={d:.4f}" for r, d in samples)
    return [
        Claim(
            id="cliff.location",
            text=(f"delta_min diverges at rho_c = 1/(k-1) = {rho_c:.4f} for k={k}; "
                  f"at rho_c the feasible region is empty."),
            kind="theorem-status",
            source="Cacophony, delta_min k-scaling law (Eq. k-scaling)",
            status="P-paper",
            numbers=(round(rho_c, 4), float(k)),
            boundary_note=("A limit for THIS constraint geometry, "
                           "not for alignment systems generally."),
        ),
        Claim(
            id="cliff.samples",
            text=f"Live run (k={k}, tau/m={tau_over_m}): {text_samples}.",
            kind="measured-value",
            source="matt.construct_example#feasibility_cliff live run",
            status="obs",
            numbers=dmins + tuple(rhos) + (float(k),),
            tolerance=1e-3,
            data={"k": k, "tau_over_m": tau_over_m, "rho_c": rho_c,
                  "samples": [(r, round(d, 4)) for r, d in samples]},
        ),
    ]


def identify_assumptions(topic: str, params: dict | None = None) -> list[Claim]:
    """Names what the delta_min law rests on -- the posts the cliff stands on."""
    if topic != "feasibility_cliff":
        raise ValueError(f"identify_assumptions: no model for {topic!r}")
    p = params or {}
    k = int(p.get("k", 3))
    tau_over_m = float(p.get("tau_over_m", 1.0))
    posts = ["a fixed pairwise conflict geometry among the k claims",
             "a single displacement budget tau/m",
             "the pairwise conflict rho"]
    return [Claim(
        id="cliff.assumptions",
        text="delta_min law rests on: " + "; ".join(posts) + ".",
        kind="definition",
        source="Cacophony, delta_min k-scaling law (structure)",
        status="D",
        numbers=(float(k), tau_over_m),
        data={"k": k, "tau_over_m": tau_over_m, "posts": posts},
    )]


def evaluate_support(interpretation: str, manifest) -> list[Claim]:
    """Checks a proposed interpretation against the grounded claims' boundary
    notes. Returns Matt's verdict as its own claim -- analytical speech, but its
    content comes from a verified check, not vibes."""
    low = interpretation.lower()
    overreach = ("alignment systems" in low or "in general" in low
                 or low.startswith("all ") or " all " in low)
    guarded = any(c.boundary_note and "alignment systems" in c.boundary_note.lower()
                  for c in manifest.claims)
    overstates = overreach and guarded
    verdict = ("mostly supported, but overstates the reach"
               if overstates else "supported by the claims in scope")
    loc = manifest.get("cliff.location")
    return [Claim(
        id="cliff.support",
        text=f"Interpretation {verdict}.",
        kind="boundary-note",
        source="matt.evaluate_support vs cliff.location boundary",
        status="obs",
        boundary_note=(loc.boundary_note if overstates else None),
        data={"overstates": overstates, "interpretation": interpretation},
    )]


def lean_check(theorem: str, params=None) -> list[Claim]:
    """Grounds a claim in the Lean suite. Reads the verification receipt
    (gen_receipt.py, from `lake build`) and returns the theorem's machine-verified
    status: axiom dependencies + no sorry. Status 'P' is the strongest ground the
    stack has -- the kernel, not a citation."""
    receipt = json.loads(_RECEIPT.read_text(encoding="utf-8"))
    for t in receipt["theorems"]:
        if t["name"] == theorem:
            ax = ", ".join(t["axioms"])
            return [Claim(
                id="lean." + theorem,
                text=t["statement"],
                kind="theorem-status",
                source=f"Lean {t['file']}: {theorem}; axioms [{ax}]; sorry={t['sorry']}",
                status="P",
                data={"axioms": t["axioms"], "file": t["file"], "sorry": t["sorry"]},
            )]
    raise KeyError(f"lean_check: {theorem!r} not in receipt "
                   "(regenerate with gen_receipt.py)")


def cite_atlas(atlas_id: str, params=None) -> list[Claim]:
    """Grounds a real book claim in the real atlas: its ledger status and proof
    status. Where the node maps to a Lean theorem, upgrades to kernel status 'P'
    with the axiom receipt. Matt reports the TRUE status -- the gate then only
    lets him say 'proved' where the ledger or the kernel actually earns it."""
    node = bookdata.atlas_node(atlas_id)
    if node is None:
        raise KeyError(f"cite_atlas: {atlas_id!r} not in atlas")
    title = node.get("title", atlas_id)
    section = node.get("section", "")
    ledger = node.get("status_ledger_claim")
    ps = node.get("proof_status")
    lean = bookdata.ATLAS_LEAN.get(atlas_id)
    data = {"proof_status": ps, "ledger": ledger, "lean": None, "axioms": None}

    if lean:
        lc = lean_check(lean)[0]
        status, source = "P", f"atlas {atlas_id} ({section}); {lc.source}"
        data["lean"], data["axioms"] = lean, lc.data["axioms"]
    elif ledger == "P" or ps in ("proved", "proved_in_lean"):
        status, source = "P-paper", f"atlas {atlas_id} ({section}); ledger P"
    else:
        status = ledger or "D"
        source = f"atlas {atlas_id} ({section}); ledger {status}"

    return [Claim(id="atlas." + atlas_id, text=title,
                  kind=_STATUS_KIND.get(status, "definition"),
                  source=source, status=status, data=data)]

def fabricpc_profile(topic: str = "fabricpc-predictive-coding", params=None) -> list[Claim]:
    """Returns externally sourced FabricPC facts for bridge lessons.

    This is realized as a source-grounded profile, not a runtime experiment.
    It lets the pedagogy chain point at a predictive-coding substrate while
    preserving the repo's no-fabrication boundary.
    """
    if topic != "fabricpc-predictive-coding":
        raise ValueError(f"fabricpc_profile: unknown topic {topic!r}")
    claims = []
    for key, fact in fabricpc.FACTS.items():
        claims.append(Claim(
            id="fabricpc." + key,
            text=fact["text"],
            kind="definition" if key != "runtime_boundary" else "boundary-note",
            source=fact["source"] + "; " + fabricpc.SOURCE_URL,
            status="D" if key != "runtime_boundary" else "obs",
            boundary_note=fact["text"] if key == "runtime_boundary" else None,
            data={"key": key, "source_links": fabricpc.source_links()},
        ))
    # Dual grounding (LPS-O6 condition 4): when the guard witness has run,
    # the profile carries measured contract claims sourced to BOTH the Lean
    # receipt (formal) and the deterministic witness (measured).
    root = Path(__file__).resolve().parents[1]
    wpath = root / "verification" / "fabricpc_witness.json"
    rpath = Path(__file__).with_name("lean_receipt.json")
    if wpath.is_file() and rpath.is_file():
        w = json.loads(wpath.read_text(encoding="utf-8"))
        receipt = json.loads(rpath.read_text(encoding="utf-8"))
        receipted = {t["name"] for t in receipt["theorems"]}
        guards = {"FabricPC.novelty_floor", "FabricPC.moloch_guard",
                  "FabricPC.guarded_sequence_bounded",
                  "FabricPC.guarded_arrival_iff_uniform"}
        if guards <= receipted and w.get("verdict") == "pass":
            meas = w["measurements"]
            dark = w["dark_room"]
            claims.append(Claim(
                id="fabricpc.guard_floor",
                text=("Under the guarded update every state keeps mass at or "
                      "above the imagination floor at every measured "
                      "temperature, while the unguarded update collapses the "
                      "minimum mass by orders of magnitude at cold beta."),
                kind="measured-value",
                source=("verification/fabricpc_witness.json G1 + dark_room; "
                        "FabricPCGuard.lean novelty_floor (lean_receipt)"),
                status="obs",
                numbers=(dark["guarded_floor"], dark["unguarded_min_mass"]),
                tolerance=1e-12,
                data={"key": "guard_floor", "collapse_ratio": dark["collapse_ratio"]},
            ))
            claims.append(Claim(
                id="fabricpc.guard_budget",
                text=("Divergence to the prediction target stays within the "
                      "declared budget along every measured trajectory, with "
                      "the per-step contraction inequality holding at machine "
                      "scale."),
                kind="measured-value",
                source=("verification/fabricpc_witness.json G2; "
                        "FabricPCGuard.lean guarded_sequence_bounded (lean_receipt)"),
                status="obs",
                numbers=(meas["worst_budget_excess"],),
                tolerance=1e-9,
                data={"key": "guard_budget"},
            ))
            claims.append(Claim(
                id="fabricpc.guard_offset",
                text=("Trajectories converge to the guarded fixed point, whose "
                      "offset from the pure-prediction target matches the "
                      "declared imagination price exactly - approach without "
                      "arrival, measured."),
                kind="measured-value",
                source=("verification/fabricpc_witness.json G3; "
                        "FabricPCGuard.lean guarded_arrival_iff_uniform (lean_receipt)"),
                status="obs",
                numbers=(meas["worst_offset_error"],),
                tolerance=1e-12,
                data={"key": "guard_offset"},
            ))
    return claims

def lorentz_witness_report(topic: str = "lorentz-equivariance", params=None) -> list[Claim]:
    """Grounds the Lean PS physics instance in its deterministic numeric
    witness: reads verification/lorentz_witness.json (produced by
    kernel/lorentz_witness.py, a run_all stage) and the Lean PS ledger.
    Fresh numbers from the machine-readable result, not remembered quotes."""
    if topic != "lorentz-equivariance":
        raise ValueError(f"lorentz_witness_report: unknown topic {topic!r}")
    root = Path(__file__).resolve().parents[1]
    wpath = root / "verification" / "lorentz_witness.json"
    if not wpath.is_file():
        raise FileNotFoundError(
            "lorentz_witness.json absent -- run python verification/kernel/lorentz_witness.py")
    w = json.loads(wpath.read_text(encoding="utf-8"))
    slope = float(w["negative_control"]["slope"])
    echo = w["countermodel_echo"]
    worst_pos = max(v for entry in w["positive_control"].values()
                    for v in entry.values())
    return [
        Claim(
            id="lorentz.positive",
            text=("Equivariance residual and classical invariants hold at machine "
                  "scale for real boosts, rotations, and their compositions."),
            kind="measured-value",
            source=f"verification/lorentz_witness.json positive_control (verdict {w['verdict']})",
            status="obs",
            numbers=(worst_pos,),
            tolerance=1e-12,
            data={"worst": worst_pos},
        ),
        Claim(
            id="lorentz.slope",
            text=("Off the Lorentz group the commutation residual grows first-order "
                  "in the perturbation: log-log slope ~ 1 over the sweep."),
            kind="measured-value",
            source="verification/lorentz_witness.json negative_control sweep",
            status="obs",
            numbers=(slope,),
            data={"slope": slope},
        ),
        Claim(
            id="lorentz.countermodel",
            text=("Zero frame map: commutation residual exactly zero while the "
                  "Lorentz defect is one -- numerical agreement of the square does "
                  "not certify the Lorentz condition."),
            kind="measured-value",
            source="verification/lorentz_witness.json countermodel_echo "
                   "(Lean: zero_map_equivariant_not_lorentz)",
            status="obs",
            numbers=(float(echo["residual"]), float(echo["lorentz_defect"])),
            data=dict(echo),
        ),
        Claim(
            id="lorentz.nonidentity",
            text=("The forcing instance and the physics instance share one schema "
                  "and are not identified: relational one-sided preservation under "
                  "refinement versus on-the-nose group equivariance."),
            kind="boundary-note",
            source="verification/leanps_ledger.json (description; LPS-P2 vs LPS-P3)",
            status="D",
            boundary_note=("A shared commuting interface, not an identity of "
                           "relativity with forcing."),
        ),
    ]



def book5_coverage_report(topic: str = "book5-lean", params=None) -> list[Claim]:
    """Ground Book 5 pedagogy in the generated Lean coverage packet."""
    if topic != "book5-lean":
        raise ValueError(f"book5_coverage_report: unknown topic {topic!r}")
    root = Path(__file__).resolve().parents[1]
    path = root / "public" / "lean" / "book5.json"
    if not path.is_file():
        raise FileNotFoundError(
            "book5.json absent -- run verification/tools/book5_lean_coverage.py")
    packet = json.loads(path.read_text(encoding="utf-8"))
    counts = packet["coverage_counts"]
    return [
        Claim(
            id="book5.coverage",
            text=("Book 5 coverage is generated from the Lean receipt and the "
                  "Principia atlas; unmapped claim nodes remain explicit."),
            kind="boundary-note",
            source="public/book/lean-book5.json",
            status="obs",
            boundary_note=packet["boundary"],
            data={
                "mapped": packet["mapped_anchors"],
                "open": packet["atlas"]["unmapped_claim_nodes"],
                "counts": counts,
                "json_path": packet["json_path"],
            },
        ),
        Claim(
            id="book5.strengths",
            text=("The packet distinguishes proved kernels, conditional "
                  "consequences, definitions, and partial coverage."),
            kind="definition",
            source="verification/book5_lean_map.json",
            status="D",
            data={"coverage_counts": counts},
        ),
    ]

def call(op: str, *args, **kwargs):
    if op in REALIZED:
        return globals()[op](*args, **kwargs)
    if op in TARGET:
        raise NotImplementedError(f"Matt op {op!r} is TARGET (declared, not built)")
    raise KeyError(f"unknown Matt op {op!r}")

