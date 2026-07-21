from verification.tools.alignment_audit import audit
from verification.tools.atlas_extract import statement_sha


def node():
    return {"nodes": [{"label": "a", "statement_sha": statement_sha(""), "latex_body": "", "file": "b.tex", "line": 4}]}


def receipt(*names):
    return {"theorems": [{"name": name} for name in names]}


def entry(status="exact"):
    return {
        "id": "x", "atlas_id": "a", "source_statement_sha": statement_sha(""),
        "source_file": "b.tex", "source_line": 4, "status": status,
        "claim": "claim", "lean_witnesses": ["T"], "countermodels": [],
        "premises": [], "bounds": [], "kernel_certified": True,
    }


def test_exact_resolves_to_receipt_and_source_hash():
    doc = {"schema": "sketched.ps-alignment.v1", "entries": [entry()]}
    assert audit(doc, node(), receipt("T")) == []


def test_conditional_requires_visible_premise():
    e = entry("conditional")
    doc = {"schema": "sketched.ps-alignment.v1", "entries": [e]}
    assert any("expose its premise" in f for f in audit(doc, node(), receipt("T")))


def test_refuted_requires_countermodel():
    e = entry("refuted")
    doc = {"schema": "sketched.ps-alignment.v1", "entries": [e]}
    assert any("connected countermodel" in f for f in audit(doc, node(), receipt("T")))


def test_interpretive_is_allowed_but_not_kernel_certified():
    e = entry("interpretive")
    e["lean_witnesses"] = []
    e["kernel_certified"] = False
    doc = {"schema": "sketched.ps-alignment.v1", "entries": [e]}
    assert audit(doc, node(), receipt()) == []


def test_reversible_observer_lowering_wording_is_rejected():
    e = entry()
    e["claim"] = "Observer lowering is a reversible equivalence."
    doc = {"schema": "sketched.ps-alignment.v1", "entries": [e]}
    assert any("stale reverse-lift" in f for f in audit(doc, node(), receipt("T")))
