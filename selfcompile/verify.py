"""The gate -- transcript verifier.

Numbers must round to a manifest value; status words must be licensed; a line
may not affirm a universal claim over a domain a boundary note guards. Matt
lines must verify clean; Ellie-marked lines may carry unmatched flow.
"""
from __future__ import annotations

import re

from manifest import Manifest

_NUM = re.compile(r"-?\d+(?:\.\d+)?")
_WORD = re.compile(r"[A-Za-z']+")
_STATUS = {"proved", "proven", "shown", "diverges", "diverge",
           "infinite", "infinity", "empty"}
_NEG = (" not ", "n't", " only ", " never ", " nor ", "not for", " no ")


def _rounds_to(tok: str, value: float) -> bool:
    decimals = len(tok.split(".")[1]) if "." in tok else 0
    half = 0.5 * (10 ** (-decimals))
    return abs(value - float(tok)) <= half + 1e-9


def _boundary_flags(speech: str, manifest: Manifest) -> list[str]:
    if not any(c.boundary_note and "alignment systems" in c.boundary_note.lower()
               for c in manifest.claims):
        return []
    flags = []
    for sent in re.split(r"[.?!]", speech):
        s = " " + sent.lower() + " "
        if "alignment systems" in s and not any(neg in s for neg in _NEG):
            flags.append("overstates: universal claim over a guarded domain "
                         "(alignment systems)")
    return flags


def verify_line(speech: str, manifest: Manifest, speaker: str) -> dict:
    flags: list[str] = []
    ground = manifest.groundable()

    for tok in _NUM.findall(speech):
        val = float(tok)
        if not any(_rounds_to(tok, gv) or abs(gv - val) <= gt
                   for gv, _cid, gt in ground):
            flags.append(f"ungrounded number {tok!r}")

    for w in _WORD.findall(speech):
        if w.lower() in _STATUS and not manifest.licenses_status(w):
            flags.append(f"unlicensed status word {w!r}")

    flags += _boundary_flags(speech, manifest)

    clean = not flags
    verdict = "PASS" if (clean or speaker == "Ellie") else "FLAG"
    return {"speaker": speaker, "verdict": verdict, "flags": flags, "clean": clean}
