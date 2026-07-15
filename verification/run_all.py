"""Run the full verification suite against the paper's TeX source.

Latest-version resolution rule: with no argument, the suite targets the
highest-numbered forcing_correspondence_v*.tex in the repo root (v15 at the
time of writing); pass an explicit TeX path as argv[1] to audit another
version. Order matters: the atlas must exist before the detectors run.
Exit code is nonzero if any stage reports fatal findings.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent

STAGES = [
    ("atlas extraction", HERE / "tools" / "atlas_extract.py", False),
    ("loop detection", HERE / "tools" / "loop_detect.py", True),
    ("ledger audit", HERE / "tools" / "ledger_audit.py", True),
    ("atlas visualization", HERE / "tools" / "atlas_viz.py", False),
    ("operator correspondence audit", HERE / "tools" / "operator_audit.py", True),
    ("epistemology invariant audit", HERE / "tools" / "epistemology_audit.py", True),
    ("binding staleness audit", HERE / "tools" / "binding_audit.py", True),
    ("binding audit tests", HERE / "tools" / "test_binding_audit.py", True),
    ("contribution boundary audit", HERE / "tools" / "contribution_audit.py", True),
    ("contribution audit tests", HERE / "tools" / "test_contribution_audit.py", True),
    ("book projection contract", HERE / "tools" / "test_book_projection.py", True),
    ("book audit", HERE / "tools" / "book_audit.py", True),
    ("Book 5 Lean coverage", HERE / "tools" / "book5_lean_coverage.py", True),
    ("PS program queue", HERE / "tools" / "ps_queue.py", True),
    ("PS source obligations", HERE / "tools" / "source_obligations.py", True),
    ("lean ps ledger audit", HERE / "tools" / "leanps_audit.py", True),
    ("lean ps wiring audit", HERE / "tools" / "leanps_wire.py", True),
    ("finite model checker", HERE / "kernel" / "model_checker.py", True),
    ("numeric margin witness", HERE / "kernel" / "numeric_margin.py", True),
    ("lorentz equivariance witness", HERE / "kernel" / "lorentz_witness.py", True),
    ("Plomp-Levelt carrier witness", HERE / "kernel" / "plomp_levelt_witness.py", True),
    ("FabricPC guard witness", HERE / "kernel" / "fabricpc_witness.py", True),
]


def find_lake() -> Path | None:
    """Locate lake.exe: PATH first, then the pinned elan toolchain."""
    for d in os.environ.get("PATH", "").split(os.pathsep):
        cand = Path(d) / ("lake.exe" if os.name == "nt" else "lake")
        if cand.is_file():
            return cand
    pinned = (
        Path.home()
        / ".elan" / "toolchains" / "leanprover--lean4---v4.31.0" / "bin"
        / ("lake.exe" if os.name == "nt" else "lake")
    )
    return pinned if pinned.is_file() else None


def main() -> int:
    # Selective execution (the mutation-testing trick): --only SUBSTR runs
    # just the stages whose name contains SUBSTR; --skip-lean skips the lake
    # builds. Full-suite CLEAN remains the only merge gate — selection is a
    # mid-iteration tool, never the final word. A bare .tex argument is still
    # the historical-audit passthrough.
    args = sys.argv[1:]
    only = None
    skip_lean = False
    tex_args = []
    it = iter(range(len(args)))
    i = 0
    while i < len(args):
        if args[i] == "--only" and i + 1 < len(args):
            only = args[i + 1].lower()
            i += 2
        elif args[i] == "--skip-lean":
            skip_lean = True
            i += 1
        else:
            tex_args.append(args[i])
            i += 1

    worst = 0
    for name, script, fatal_matters in STAGES:
        if only is not None and only not in name.lower():
            continue
        print(f"\n{'=' * 72}\n== {name}: {script.name}\n{'=' * 72}", flush=True)
        # atlas/ledger stages accept an optional TeX path passthrough
        takes_tex = script.name in ("atlas_extract.py", "ledger_audit.py")
        extra = tex_args if takes_tex else []
        rc = subprocess.call([sys.executable, str(script)] + extra)
        if fatal_matters and rc != 0:
            worst = 1
    lake = find_lake()
    lean_projects = [
        ("Lean kernel (core)", HERE / "lean" / "ForcingKernel",
         (HERE / "lean" / "ForcingKernel").is_dir()),
        # mathlib layer: only built if the mathlib packages have been fetched
        ("Lean analysis (mathlib)", HERE / "lean" / "ForcingAnalysis",
         (HERE / "lean" / "ForcingAnalysis" / ".lake" / "packages" / "mathlib").is_dir()),
    ]
    if skip_lean or (only is not None and "lean" not in only):
        lean_projects = [] if (skip_lean or only is not None) else lean_projects
    for name, proj, enabled in lean_projects:
        print(f"\n{'=' * 72}\n== {name}: lake build\n{'=' * 72}", flush=True)
        if lake is None:
            print("lake not found; skipping (install elan to enable)")
        elif not enabled:
            print("project or its packages absent; skipping (Lean sources ship "
                  "in the separate Lean packet; mathlib needs `lake update` + "
                  "`lake exe cache get`)")
        else:
            rc = subprocess.call([str(lake), "build"], cwd=proj)
            if rc != 0:
                worst = 1
    label = "CLEAN" if not worst else "FINDINGS PRESENT (see above)"
    if only is not None or skip_lean:
        label += "  [PARTIAL RUN — not a merge gate]"
    print(f"\n{'=' * 72}\nsuite result: {label}")
    return worst


if __name__ == "__main__":
    sys.exit(main())
