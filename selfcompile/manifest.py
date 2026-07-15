"""Part A -- the claim manifest. Deterministic, source-tagged, tolerance-aware.

A rendered line (Part B) is legal only if every number and status word in it
traces to a Claim here. This is the split from matt_sheen_claim_manifest.md:
the claim layer decides what is true; the rendering layer decides how it sounds;
the gate (verify.py) checks the second against the first instead of trusting it.
"""
from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Claim:
    id: str
    text: str
    kind: str          # definition | measured-value | theorem-status | boundary-note
    source: str        # file/function/run or paper anchor
    status: str        # ledger letter, 'obs', or 'P-paper'
    numbers: tuple[float, ...] = ()   # groundable numeric values this claim licenses
    tolerance: float = 1e-3
    boundary_note: str | None = None
    data: dict = field(default_factory=dict)  # structured payload for the renderer


@dataclass
class Manifest:
    topic: str
    claims: list[Claim] = field(default_factory=list)

    def add(self, c: Claim) -> Claim:
        self.claims.append(c)
        return c

    def get(self, cid: str) -> Claim:
        return next(c for c in self.claims if c.id == cid)

    def groundable(self) -> list[tuple[float, str, float]]:
        """(value, claim_id, tolerance) for every number any claim licenses."""
        return [(v, c.id, c.tolerance) for c in self.claims for v in c.numbers]

    def licenses_status(self, word: str) -> bool:
        w = word.lower()
        if w in {"diverges", "diverge", "infinite", "infinity", "empty"}:
            return any(c.kind == "theorem-status" for c in self.claims)
        if w in {"proved", "proven", "shown"}:
            # only a proved claim (Lean 'P' or paper 'P-paper') licenses these
            return any(c.status in {"P", "P-paper"} for c in self.claims)
        return True
