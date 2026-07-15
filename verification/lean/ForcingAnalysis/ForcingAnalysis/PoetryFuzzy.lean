/-
PoetryFuzzy.lean — the fuzzy lift of the operator-poetry carrier
(LPS-P44's named next: the parameterization, reintroduced).

Poetry.lean is the fuzzy calculus with parameterization reduced to zero.
This file turns the knob back up: edges carry a confidence weight and
composition along a path multiplies weights (the NAL deduction rule the
Come/ONA substrate runs), with max-product semantics over fuel-bounded
paths (best-supported derivation).

Representation, per the non-normalized-forms rule taken all the way
down: the weights are RAW SCALED NATURALS, not rationals. A weight
num/den at fuel n is carried as the integer value scaled by den^n —
a path of length k evaluates to num^k · den^(n−k), every value exact,
every comparison kernel-computable. ℚ is the quotient (normalized) form
of these integers; the quotient is documented here, not baked into the
type. (The first draft used ℚ and the kernel's rational arithmetic
refused to reduce — the normalized representation literally would not
compute. The raw one does.)

The design theorem is `zero_parameterization`: at weight 1/1 the fuzzy
reach collapses to the crisp carrier exactly — fuzzy value 1 iff a
crisp path exists, for every pair of concepts (all 576, by kernel
evaluation). The poems really are the zero-parameter limit.

The substrate correspondence, now computed rather than transcribed
(input confidence 9/10, scale 10^8):

  * `fuzzy_bridge` — the cross-seed bridge evaluates to 81·10⁶, i.e.
    81/100 of the scale: the deduction confidence 0.81 the live ONA
    run printed for <emergence_of_structure ==> wave>.
  * `fuzzy_full_arc` — the four-step arc emergence ⇝ freedom evaluates
    to 6561·10⁴, i.e. 6561/10000: the 0.6561 the June 12 drummer-boy
    session recorded for <emergence_of_structure ==> freedom>. That
    night's trace number is now this file's kernel computation.
  * `fuzzy_drift_forward` — drift ⇝ freedom evaluates to 0 forward:
    the abduction-only status of the full poetic arc survives the lift.

Priorities and revision remain substrate-internal, dark-trace content.
-/

import Mathlib
import ForcingAnalysis.Poetry

namespace ForcingAnalysis.Poetry

deriving instance Fintype for Concept

/-- Fuel-bounded fuzzy reachability in raw scaled naturals: at fuel n
every value is scaled by den^n, so a path of length k evaluates to
num^k · den^(n−k) and max-product composition stays in ℕ. -/
def freachN : Nat → Edges → Nat → Nat → Concept → Concept → Nat
  | 0, _, _, _, a, b => if a == b then 1 else 0
  | n + 1, E, num, den, a, b =>
      if a == b then den ^ (n + 1)
      else E.foldr
        (fun e acc => max acc
          (if e.1 == a then num * freachN n E num den e.2 b else 0)) 0

set_option maxRecDepth 16000

/-- **The zero-parameterization theorem** (the design claim, proved):
at weight 1/1 the fuzzy calculus IS the crisp carrier — fuzzy reach 1
exactly where a crisp path exists, for every pair of concepts. -/
theorem zero_parameterization :
    ∀ a b : Concept,
      (freachN 8 quartet 1 1 a b = 1 ↔ Reaches quartet a b) := by
  decide

/-- **The bridge, computed**: input confidence 9/10 composes across the
two-seed bridge to 81·10⁶ at scale 10⁸ — exactly 81/100, the deduction
confidence the live ONA run printed. -/
theorem fuzzy_bridge :
    freachN 8 (operatio ++ executio) 9 10 Concept.emergenceOfStructure
      Concept.wave = 81 * 10 ^ 6 := by decide

/-- **The full arc, computed**: the four-step composition
emergence ⇝ operator ⇝ wave ⇝ resonance ⇝ freedom evaluates to
6561·10⁴ at scale 10⁸ — exactly 6561/10000, the 0.6561 recorded in the
June 12 drummer-boy trace. -/
theorem fuzzy_full_arc :
    freachN 8 quartet 9 10 Concept.emergenceOfStructure
      Concept.freedom = 6561 * 10 ^ 4 := by decide

/-- The abduction-only status survives the lift: drift ⇝ freedom has
fuzzy value 0 in the forward calculus. -/
theorem fuzzy_drift_forward :
    freachN 8 quartet 9 10 Concept.drift Concept.freedom = 0 := by decide

end ForcingAnalysis.Poetry
