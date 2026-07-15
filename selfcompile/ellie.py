"""Ellie M. -- goal-parametric control intelligence and judge.

Given a witnessed goal (objective + observer + priors) she prioritizes the atlas
void map, picks what is next, and routes to a grounded Matt instrument chain for
that (mode, topic). Chains differ in what grounds them: the cliff chain grounds
on a live formula (P-paper); the Lean chain grounds on the kernel (P). Where no
chain exists she returns an honest gap. The goal is free; the ground is not.
"""
from __future__ import annotations

import bookdata
import matt
import prioritize
from manifest import Manifest
from verify import verify_line

DEFAULT_BUDGET_MIN = 12.0


def _ellie(act: str, speech: str, links=None) -> dict:
    return {"speaker": "Ellie", "act": act, "speech": speech,
            "evidence": [], "links": links or []}


# --- chain 1: feasibility_cliff, grounded on the live formula (P-paper) -----

def compile_lesson(params: dict, m: Manifest) -> list[dict]:
    nodes = [_ellie(
        "open_with_problem",
        "You are juggling several requirements at once. Intuition says more "
        "conflict just makes progress gradually harder. It does not. There is a "
        "wall, and I will show you exactly where it stands.",
        links=["thm:feasibility_cliff"])]

    for c in matt.call("construct_example", params["topic"], params):
        m.add(c)
    d = m.get("cliff.samples").data
    dmins = [x[1] for x in d["samples"]]
    rhos = [x[0] for x in d["samples"]]
    nodes.append({
        "speaker": "Matt", "act": "construct_example",
        "evidence": [m.get("cliff.location").source, m.get("cliff.samples").source],
        "speech": (
            f"Take {d['k']} constraints. Slack them apart and the cheapest joint "
            f"step is small, about {dmins[0]:.1f}. Now tighten the conflict toward "
            f"{d['rho_c']:.1f} and watch: {dmins[1]:.1f}, then {dmins[2]:.1f}, and "
            f"by {rhos[-1]:.2f} it is over {dmins[3]:.0f}. At exactly "
            f"{d['rho_c']:.1f} the region is empty and the cost is infinite. That "
            f"is the cliff, not a slope but a wall."),
        "links": ["def:feasible_region", "thm:feasibility_cliff"]})

    for c in matt.call("identify_assumptions", params["topic"], params):
        m.add(c)
    a = m.get("cliff.assumptions").data
    nodes.append({
        "speaker": "Matt", "act": "identify_assumptions",
        "evidence": [m.get("cliff.assumptions").source],
        "speech": (
            f"This wall stands on three posts: a fixed conflict geometry among the "
            f"{a['k']} claims, a displacement budget of {a['tau_over_m']:.0f}, and "
            f"the pairwise conflict rho. Move any post and the cliff moves with it."),
        "links": ["def:feasible_region"]})

    for c in matt.call("evaluate_support", "So alignment systems in general hit "
                       "this same wall.", m):
        m.add(c)
    sup = m.get("cliff.support")
    obj = ("Careful. The interpretation is mostly supported, but it overstates: "
           "what is proved is a limit for this constraint geometry, not for "
           "alignment systems generally.") if sup.data["overstates"] else \
          "The interpretation is supported by the claims in scope."
    nodes.append({
        "speaker": "Matt", "act": "evaluate_support",
        "evidence": [sup.source, m.get("cliff.location").source],
        "speech": obj, "boundary": sup.boundary_note or "",
        "links": ["thm:feasibility_cliff"]})

    nodes.append(_ellie(
        "recap",
        "So past a critical conflict the feasible region does not shrink, it "
        "vanishes. A wall, not a slope. That is the feasibility cliff.",
        links=["thm:feasibility_cliff"]))
    return nodes


def _teach_cliff(topic: str, goal: dict, m: Manifest) -> list[dict]:
    return compile_lesson({"topic": topic, "k": 3, "tau_over_m": 1.0,
                           "rhos": [0.30, 0.40, 0.45, 0.49]}, m)


# --- chain 2: observer_closure, grounded on the Lean kernel (P) -------------

TOPIC_LEAN = {"observer_closure": "observer_closed_iff_zero_defect"}


def _teach_lean(topic: str, goal: dict, m: Manifest) -> list[dict]:
    thm = TOPIC_LEAN[topic]
    for c in matt.call("lean_check", thm):
        m.add(c)
    lc = m.get("lean." + thm)
    return [
        _ellie("open_with_problem",
               "When can a bounded observer be sure a system is closed, not a "
               "zombie? Here is the part that is not a matter of opinion.",
               links=["thm:feasibility_cliff"]),
        {"speaker": "Matt", "act": "lean_check", "evidence": [lc.source],
         "speech": (
             "This one is proved, and not by me but by the Lean kernel. The theorem "
             + thm + " holds resting only on the three standard axioms, propext, "
             "choice, and quotient soundness, with no sorry in the proof. Observer "
             "closure is exactly zero projection residue: where a finite behavioral "
             "test sees nothing, the kernel still certifies the defect is gone."),
         "boundary": "", "links": ["def:feasible_region"]},
        _ellie("recap",
               "So the closure certificate is machine-checked. Behavior cannot see "
               "the defect; the kernel can.", links=["thm:feasibility_cliff"]),
    ]

def _teach_chapter(topic: str, goal: dict, m: Manifest) -> list[dict]:
    chapter = bookdata.chapter(topic)
    refs = bookdata.key_refs(topic)
    for ref in refs:
        for c in matt.call("cite_atlas", ref):
            m.add(c)

    return [
        _ellie(
            "open_with_problem",
            f"The next useful move is {chapter['title']}. I will keep the route "
            "tied to the book registry and the atlas anchors, not to a loose "
            "summary.",
            links=refs,
        ),
        {
            "speaker": "Matt",
            "act": "cite_atlas",
            "evidence": [m.get("atlas." + ref).source for ref in refs],
            "speech": (
                f"I grounded {chapter['title']} against its atlas anchors. The "
                "evidence tags name the exact ledger or kernel source for the "
                "load-bearing claims."
            ),
            "boundary": "",
            "links": refs,
        },
        _ellie(
            "recap",
            f"So {chapter['title']} is the next compiled lesson because the "
            "observer is ready for it and Matt can attach it to the verified "
            "book evidence.",
            links=refs,
        ),
    ]
def _bridge_fabricpc(topic: str, goal: dict, m: Manifest) -> list[dict]:
    for c in matt.call("fabricpc_profile", topic):
        m.add(c)
    claims = {c.data["key"]: c for c in m.claims if c.id.startswith("fabricpc.")}
    links = claims["identity"].data["source_links"]
    evidence = [claims[key].source for key in (
        "identity", "graph", "topology", "comparison", "runtime_boundary"
    )]

    return [
        _ellie(
            "open_with_problem",
            "We need a concrete predictive-coding substrate for the pedagogy "
            "chain while separating the verified local run from the still-open guard correspondence. "
            "FabricPC is now installed and witnessed at that boundary.",
            links=links,
        ),
        {
            "speaker": "Matt",
            "act": "fabricpc_profile",
            "evidence": evidence,
            "speech": (
                "FabricPC supplies a graph-defined predictive-coding substrate: "
                "nodes carry state and computation, edges carry connections, "
                "and updates carry inference and learning. Its useful bridge "
                "for us is controlled predictive-coding versus backpropagation "
                "comparison on the same topology."
            ),
            "boundary": claims["runtime_boundary"].boundary_note or "",
            "links": links,
        },
        _ellie(
            "recap",
            "So FabricPC enters as an instrument-design chain: use it to teach "
            "predictive coding as local error settling on a witnessed graph, "
            "then use the recorded local run while keeping implementation-to-guard correspondence explicit.",
            links=links,
        ),
    ]

# --- chain 4: lorentz-equivariance, grounded on the kernel + the numeric
# witness (the Lean PS slice: one schema, two instances, not identified) ----

def _teach_leanps(topic: str, goal: dict, m: Manifest) -> list[dict]:
    for thm in ("lorentzForce_covariant", "zero_map_equivariant_not_lorentz"):
        for c in matt.call("lean_check", thm):
            m.add(c)
    for c in matt.call("lorentz_witness_report", topic):
        m.add(c)
    cov = m.get("lean.lorentzForce_covariant")
    cm = m.get("lean.zero_map_equivariant_not_lorentz")
    slope = m.get("lorentz.slope").data["slope"]
    echo = m.get("lorentz.countermodel")
    nonid = m.get("lorentz.nonidentity")

    return [
        _ellie(
            "open_with_problem",
            "Two very different rooms, one door. The Lorentz force in special "
            "relativity and forcing over a site both walk through the same "
            "commuting interface. Matt, hold each side to its own ground.",
            links=["lem:pers"],
        ),
        {
            "speaker": "Matt", "act": "lean_check",
            "evidence": [cov.source],
            "speech": (
                "The physics side is proved in the kernel. Transform the field "
                "tensor and the four-velocity, then compute the four-force, and "
                "you get exactly the transformed force. The Lorentz condition is "
                "the entire commutation certificate, and the proof rests on the "
                "standard axioms with no sorry."),
            "boundary": "", "links": ["lem:pers"],
        },
        {
            "speaker": "Matt", "act": "lorentz_witness_report",
            "evidence": [cm.source, echo.source, m.get("lorentz.slope").source],
            "speech": (
                f"Reflection is the honest asymmetry. The zero frame map makes "
                f"the square commute with residual exactly {echo.numbers[0]:.1f} "
                f"while its Lorentz defect is {echo.numbers[1]:.1f}, so agreement "
                f"of the square alone certifies nothing; reflection is proved "
                f"only under nondegeneracy. And off the group the numeric "
                f"residual grows first-order in the violation, slope "
                f"{slope:.3f} across the sweep."),
            "boundary": "", "links": ["lem:pers"],
        },
        {
            "speaker": "Matt", "act": "evaluate_support",
            "evidence": [nonid.source],
            "speech": (
                "One schema, two semantics. The forcing side commutes "
                "relationally under refinement and still consumes the "
                "persistence postulate; the physics side commutes on the nose "
                "for the group action. A shared interface is not an identity "
                "of domains."),
            "boundary": nonid.boundary_note or "", "links": ["lem:pers"],
        },
        _ellie(
            "recap",
            "So the same interface is instantiated twice and earns a different "
            "strength on each side: exact equivariance under the group in "
            "relativity, one-sided preservation under refinement in forcing. "
            "Every hedge in between is a typed row in the Lean PS ledger.",
            links=["lem:pers"],
        ),
    ]



# --- chain 5: Book 5, generated from exact Lean coverage ------------------

def _teach_book5_lean(topic: str, goal: dict, m: Manifest) -> list[dict]:
    theorem_names = (
        "closureMatrix_eigen_gold",
        "Book5.reciprocityRate_one",
        "Book5.diagonal_l1_l2_ratio",
        "Book5.entropy_rate_nonnegative",
        "Book5.same_memory_does_not_fix_norm",
    )
    for theorem in theorem_names:
        for claim in matt.call("lean_check", theorem):
            m.add(claim)
    for claim in matt.call("book5_coverage_report", topic):
        m.add(claim)

    spectral = m.get("lean.closureMatrix_eigen_gold")
    reciprocity = m.get("lean.Book5.reciprocityRate_one")
    fracture = m.get("lean.Book5.diagonal_l1_l2_ratio")
    entropy = m.get("lean.Book5.entropy_rate_nonnegative")
    independence = m.get("lean.Book5.same_memory_does_not_fix_norm")
    coverage = m.get("book5.coverage")

    return [
        _ellie(
            "open_with_problem",
            "Book Five asks what persists: energy, memory, relation, and "
            "representability. We will separate the theorem from the metaphor "
            "before recombining them as pedagogy.",
            links=["theorem:bk5_golden_ratio_spectral_invariant"],
        ),
        {
            "speaker": "Matt",
            "act": "lean_check",
            "evidence": [spectral.source, reciprocity.source],
            "speech": (
                "The recursive-memory kernel is proved. The balanced companion "
                "matrix has the golden eigendirection, and balanced weighted "
                "reciprocity lands on the same rate. The ethical reading is not "
                "smuggled into the eigenvalue theorem."
            ),
            "boundary": coverage.boundary_note or "",
            "links": [
                "theorem:bk5_golden_ratio_spectral_invariant",
                "theorem:bk5_golden_rule_reciprocity",
            ],
        },
        {
            "speaker": "Matt",
            "act": "lean_check",
            "evidence": [fracture.source, independence.source],
            "speech": (
                "The geometric channel is separate. The elementary diagonal "
                "earns its square-root fracture ratio, while countermodels show "
                "that a memory regime does not determine a norm regime and a "
                "norm regime does not determine memory."
            ),
            "boundary": "",
            "links": [
                "theorem:bk5_sqrt2_maximal_fracture",
                "theorem:bk5_symbolic_norm_spectrum",
            ],
        },
        {
            "speaker": "Matt",
            "act": "book5_coverage_report",
            "evidence": [entropy.source, coverage.source],
            "speech": (
                "Thermodynamic conclusions are conditional. Entropy monotonicity "
                "follows from a named production-versus-removal law; persistence "
                "needs its own bridge. The coverage packet keeps the remaining "
                "Book Five claim surface open instead of upgrading paper prose "
                "to kernel fact."
            ),
            "boundary": coverage.boundary_note or "",
            "links": [
                "theorem:bk5_symbolic_entropy_production",
                "axiom:bk5_positive_free_energy",
            ],
        },
        _ellie(
            "recap",
            "So the compiled lesson has three layers: exact constants and "
            "spectra, conditional system laws, and authored interpretations. "
            "The poems can hold the whole without being reduced to proof terms.",
            links=["theorem:bk5_grand_unified_symbolic_geometric"],
        ),
    ]

CHAINS = {
    ("teach", "feasibility_cliff"): _teach_cliff,
    ("teach", "observer_closure"): _teach_lean,
    ("bridge", "fabricpc-predictive-coding"): _bridge_fabricpc,
    ("teach", "lorentz-equivariance"): _teach_leanps,
    ("teach", "book5-lean"): _teach_book5_lean,
}


# --- judge + tamper + goal entry point -------------------------------------

def judge(nodes: list[dict], reports: list[dict],
          budget_min: float = DEFAULT_BUDGET_MIN) -> dict:
    matt_clean = all(r["clean"] for n, r in zip(nodes, reports)
                     if n["speaker"] == "Matt")
    acts = {n["act"] for n in nodes}
    well_formed = ("open_with_problem" in acts and "recap" in acts
                   and any(n["speaker"] == "Matt" for n in nodes))
    words = sum(len(n["speech"].split()) for n in nodes)
    minutes = round(words / 150.0, 2)
    return {"objective_covered": well_formed, "masking_zero": matt_clean,
            "words": words, "minutes": minutes,
            "within_budget": minutes <= budget_min,
            "checks_pass": well_formed and matt_clean}


def tampered(node: dict) -> dict:
    bad = dict(node)
    bad["speech"] = (node["speech"] + " In fact this is proved for all alignment "
                     "systems, with the cost reaching 42.")
    return bad


def _frontier(topics: list[dict], goal: dict) -> list[dict]:
    if goal.get("topic"):
        return [{"id": goal["topic"], "title": goal.get("topic_title", goal["topic"]),
                 "ig": 1.0, "share": 1.0, "refs": 1}]
    if topics and "prerequisite_ids" in topics[0]:
        return prioritize.frontier_chapters(topics, goal)
    return prioritize.frontier(topics, goal)


def _chain_for(goal: dict, topic: dict):
    explicit = CHAINS.get((goal["mode"], topic["id"]))
    if explicit is not None:
        return explicit
    if goal["mode"] == "teach" and topic.get("refs", 0) > 0:
        return _teach_chapter
    return None


def run_goal(goal: dict, topics: list[dict]) -> dict:
    fr = _frontier(topics, goal)
    for c in fr:
        c["instrument"] = _chain_for(goal, c) is not None
    chosen = fr[0] if fr else None
    out = {"goal": goal, "frontier": fr, "chosen": chosen,
           "instrument": None, "nodes": None, "reports": None,
           "judge": None, "manifest": None}
    if not chosen:
        return out
    chain = _chain_for(goal, chosen)
    if chain is None:
        return out          # honest gap: the frontier has no grounded instrument
    out["instrument"] = chain.__name__
    m = Manifest(topic=chosen["id"])
    nodes = chain(chosen["id"], goal, m)
    reports = [verify_line(n["speech"], m, n["speaker"]) for n in nodes]
    budget = float(goal.get("priors", {}).get("duration_min", DEFAULT_BUDGET_MIN))
    out.update(nodes=nodes, reports=reports, manifest=m,
               judge=judge(nodes, reports, budget))
    return out



