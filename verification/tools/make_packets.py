"""Build the source-only verification packets (for external reviewers who
monitor progress without the full repo — e.g. a GPT desktop session).

Produces, under packets/:

  1. forcing_v15_verification_packet.zip — TeX source + Python suite +
     MANIFEST/EXPECTED_OUTPUT + a RUN_TRANSCRIPT captured from an actual
     run of the staged packet (packet mode: operator audit and Lean stages
     skip cleanly). Also ships generated atlas.json/atlas.html as clearly
     marked output evidence.
  2. forcing_v15_lean_packet.zip — Lean sources only (lakefile.toml,
     lean-toolchain, .lean files) for ForcingKernel and ForcingAnalysis,
     plus LAKE_BUILD_TRANSCRIPT.txt captured from the real builds. No
     .lake/, no caches, no mathlib packages.
  3. forcing_v15_operator_packet.zip — operators.json + the referenced
     TypeScript sources + docs + EULA + npm project files, plus captured
     vitest and operator-audit transcripts.

Hygiene: no __pycache__, no node_modules, no build outputs, no caches.
"""

from __future__ import annotations

import platform
import shutil
import subprocess
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACKETS = ROOT / "packets"
STAGE = ROOT / "packets" / "_stage"

LAKE = (
    Path.home()
    / ".elan" / "toolchains" / "leanprover--lean4---v4.31.0" / "bin"
    / ("lake.exe" if sys.platform == "win32" else "lake")
)


def transcript_header(cmd: str, cwd: Path) -> str:
    return (
        f"command : {cmd}\n"
        f"cwd     : {cwd}\n"
        f"date    : {datetime.now(timezone.utc).isoformat()}\n"
        f"os      : {platform.platform()}\n"
        f"python  : {sys.version.split()[0]} ({sys.executable})\n"
        + "=" * 72 + "\n"
    )


def run_captured(cmd: list[str], cwd: Path) -> tuple[int, str]:
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    body = p.stdout + (("\n--- stderr ---\n" + p.stderr) if p.stderr.strip() else "")
    return p.returncode, body + f"\n{'=' * 72}\nexit code: {p.returncode}\n"


def copy(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def zip_dir(stage: Path, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(stage.rglob("*")):
            if f.is_file() and "__pycache__" not in f.parts:
                z.write(f, f.relative_to(stage))
    size = out.stat().st_size / 1024
    print(f"  wrote {out.name} ({size:,.0f} KB)")


def build_main_packet() -> None:
    print("packet 1: verification (source-only + captured run)")
    stage = STAGE / "main"
    shutil.rmtree(stage, ignore_errors=True)

    copy(ROOT / "forcing_correspondence_v15.tex", stage / "forcing_correspondence_v15.tex")
    copy(ROOT / "forcing_correspondence_v15.pdf", stage / "forcing_correspondence_v15.pdf")
    for name in ("run_all.py", "README.md", "FINDINGS.md", "MANIFEST.md", "EXPECTED_OUTPUT.md",
                 "bindings.json"):
        copy(ROOT / "verification" / name, stage / "verification" / name)
    for f in sorted((ROOT / "verification" / "attestations").iterdir()):
        if f.is_file():
            copy(f, stage / "verification" / "attestations" / f.name)
    for sub, names in (
        ("tools", ["atlas_extract.py", "loop_detect.py", "ledger_audit.py",
                   "atlas_viz.py", "operator_audit.py", "binding_audit.py",
                   "test_binding_audit.py", "atlas_diff.py"]),
        ("kernel", ["spine.py", "polarity.py", "model_checker.py", "numeric_margin.py",
                    "sweep.py", "interface_model.py"]),
    ):
        for name in names:
            copy(ROOT / "verification" / sub / name, stage / "verification" / sub / name)
    copy(ROOT / "verification" / "MANIFEST.md", stage / "MANIFEST.md")

    # authentic packet-mode run: executed inside the staged tree itself
    cmd = [sys.executable, "verification/run_all.py"]
    rc, body = run_captured(cmd, stage)
    (stage / "RUN_TRANSCRIPT.txt").write_text(
        transcript_header("python verification/run_all.py", Path("<packet root>")) + body,
        encoding="utf-8",
    )
    if rc != 0:
        sys.exit(f"packet-mode suite run FAILED (exit {rc}) — not shipping a broken packet")
    print("  packet-mode suite run: CLEAN (exit 0)")

    zip_dir(stage, PACKETS / "forcing_v15_verification_packet.zip")


def build_lean_packet() -> None:
    print("packet 2: Lean sources + build transcripts")
    stage = STAGE / "lean"
    shutil.rmtree(stage, ignore_errors=True)

    for proj in ("ForcingKernel", "ForcingAnalysis"):
        base = ROOT / "verification" / "lean" / proj
        for f in base.rglob("*"):
            if f.is_file() and ".lake" not in f.parts and f.suffix in (".lean", ".toml") or f.name == "lean-toolchain":
                if ".lake" in f.parts:
                    continue
                copy(f, stage / "verification" / "lean" / proj / f.relative_to(base))

    transcripts = []
    if LAKE.is_file():
        for proj in ("ForcingKernel", "ForcingAnalysis"):
            cwd = ROOT / "verification" / "lean" / proj
            hdr = transcript_header(f"lake build  ({proj})", cwd)
            rc, body = run_captured([str(LAKE), "build"], cwd)
            transcripts.append(hdr + body)
            print(f"  {proj}: lake build exit {rc}")
    else:
        transcripts.append("lake not found on build machine; no transcript captured\n")
    (stage / "LAKE_BUILD_TRANSCRIPT.txt").write_text("\n\n".join(transcripts), encoding="utf-8")

    (stage / "MANIFEST.md").write_text(
        "# Lean packet (source only)\n\n"
        "- `verification/lean/ForcingKernel/` — core Lean 4, no dependencies.\n"
        "  Build: install elan, then `lake build` (toolchain pinned in\n"
        "  `lean-toolchain`: leanprover/lean4:v4.31.0).\n"
        "- `verification/lean/ForcingAnalysis/` — requires mathlib v4.31.0:\n"
        "  `lake update && lake exe cache get && lake build` (~7 GB fetched;\n"
        "  intentionally NOT included here).\n"
        "- `LAKE_BUILD_TRANSCRIPT.txt` — captured builds from the authoring\n"
        "  machine, including the axiom audit lines (`#print axioms`).\n\n"
        "Expected axiom profile: `site_bound` — no axioms;\n"
        "`margin_path_form`, `per_step_bound_insufficient` — propext,\n"
        "Quot.sound; all others — propext, Classical.choice, Quot.sound.\n",
        encoding="utf-8",
    )
    zip_dir(stage, PACKETS / "forcing_v15_lean_packet.zip")


def build_operator_packet() -> None:
    print("packet 3: operator correspondence (TS sources + audit)")
    stage = STAGE / "operator"
    shutil.rmtree(stage, ignore_errors=True)

    copy(ROOT / "verification" / "operators.json", stage / "verification" / "operators.json")
    copy(ROOT / "verification" / "atlas.json", stage / "verification" / "atlas.json")
    copy(ROOT / "verification" / "tools" / "operator_audit.py",
         stage / "verification" / "tools" / "operator_audit.py")
    for sub in ("core", "agents", "witness"):
        for f in (ROOT / "src" / sub).rglob("*.ts"):
            copy(f, stage / "src" / sub / f.relative_to(ROOT / "src" / sub))
    for f in (ROOT / "docs").glob("*.md"):
        copy(f, stage / "docs" / f.name)
    for name in ("EULA.md", "PHILOSOPHY.md", "README.md", "package.json",
                 "package-lock.json", "tsconfig.json", "vite.config.ts"):
        if (ROOT / name).is_file():
            copy(ROOT / name, stage / name)

    hdr = transcript_header("python verification/tools/operator_audit.py", Path("<packet root>"))
    rc, body = run_captured([sys.executable, "verification/tools/operator_audit.py"], stage)
    hdr2 = transcript_header("npx vitest run  (from full repo)", ROOT)
    rc2, body2 = run_captured(["npx.cmd" if sys.platform == "win32" else "npx", "vitest", "run"], ROOT)
    (stage / "AUDIT_TRANSCRIPT.txt").write_text(hdr + body + "\n\n" + hdr2 + body2, encoding="utf-8")
    print(f"  operator audit exit {rc}; vitest exit {rc2}")
    if rc != 0 or rc2 != 0:
        sys.exit("operator packet checks failed — not shipping")

    zip_dir(stage, PACKETS / "forcing_v15_operator_packet.zip")


def main() -> None:
    PACKETS.mkdir(exist_ok=True)
    build_main_packet()
    build_lean_packet()
    build_operator_packet()
    shutil.rmtree(STAGE, ignore_errors=True)
    print("\nall packets written to packets/")


if __name__ == "__main__":
    main()
