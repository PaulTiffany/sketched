"""Goal-general self-compile, end to end:

  witnessed goals (goals.json) + atlas (atlas.json)
    -> for each goal: prioritize the void map relative to its observer
    -> route to a grounded Matt instrument chain where one exists
       (else an honest gap -- never a fabricated artifact)
    -> gate every Matt line; run the judge loop
    -> compile goals + frontiers + lessons into one page (lesson.html)

Run:  python run.py   (exit 0 iff every compiled lesson verifies and the tamper is caught)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import bookdata
import ellie
import render
from verify import verify_line

HERE = Path(__file__).parent
GOALS = json.loads((HERE / "goals.json").read_text(encoding="utf-8"))["goals"]
TOPICS = bookdata.chapters()
OUT = HERE / "lesson.html"


def main() -> int:
    results = [ellie.run_goal(g, TOPICS) for g in GOALS]

    for r in results:
        g = r["goal"]
        nxt = r["chosen"]["id"] if r["chosen"] else "-"
        inst = r["instrument"] or "(no grounded instrument -> honest gap)"
        print(f"goal {g['id']:14} mode={g['mode']:5} -> next={nxt:18} instrument={inst}")
        for c in r["frontier"]:
            tag = "realized" if c.get("instrument") else "target"
            print(f"     ready {c['id']:18} IG={c['ig']:5.1f} share={c.get('share')} [{tag}]")

    print()
    ok = True
    compiled = [r for r in results if r["nodes"]]
    for r in compiled:
        mnode = next(n for n in r["nodes"] if n["speaker"] == "Matt")
        bad = verify_line(ellie.tampered(mnode)["speech"], r["manifest"], "Matt")
        passed = r["judge"]["checks_pass"] and bad["verdict"] == "FLAG"
        ok = ok and passed
        print(f"lesson[{r['goal']['id']}] checks_pass={r['judge']['checks_pass']} "
              f"tamper={bad['verdict']} -> {'PASS' if passed else 'FAIL'}")

    OUT.write_text(render.render_page(results), encoding="utf-8")
    print(f"\ncompiled -> {OUT}")
    ok = ok and bool(compiled)
    print("RESULT:", "PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())


