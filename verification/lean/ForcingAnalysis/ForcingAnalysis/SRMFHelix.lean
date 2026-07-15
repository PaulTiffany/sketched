/-
SRMFHelix.lean — Gödel-safe circularity: the SRMF loop as a helix.

Paul's design note (2026-07-12): "we deeply respect Gödel-safe
circularity, and each of those imagination points between an SRMF step
is an opportunity for the introduction of drift by observer interaction
with time. Gödel-safety isn't really predictive code, so much as a
mantra for predictive coding best practice."

This file makes the mantra structural, honestly scoped: it does NOT
prove anything about its own consistency (that would be the unsafe
circle). It proves the dichotomy the mantra encodes:

  * an SRMF revolution whose imagination points inject drift δ₁…δₖ
    (observer interaction with time, between steps — bk4's imaginary
    traversal as counterfactual branch points) closes into a genuine
    circle IFF the injected drift sums to zero (`turn_closes_iff`);
  * with nonzero net drift the loop is a HELIX: n revolutions displace
    by exactly n·Σδ (`turns_formula`), never return
    (`helix_never_returns`), and escape every bound
    (`helix_unbounded`) — the loop's failure to close is where time
    comes from, matching Book 6's irreversibility kernel and the
    genesis intent's "time is internal to symbolic transformation";
  * the general Gödel-safety law, for ANY cycle on ANY state space
    with ANY potential: a step that does strict work cannot close
    (`strict_work_breaks_closure`), and for a descent cycle whose
    off-fixed-point steps are strictly decreasing, closure holds
    exactly where no work is done (`closure_iff_no_work`) — the only
    honest circle is the one at equilibrium. Everywhere else the
    circle is a helix and the system is still alive. This is the
    H-theorem's equality-iff clause (Book2H) restated as a law about
    self-reference: a self-improving loop cannot certify itself closed,
    because closing and improving are exclusive.

Best-practice reading (the mantra, not a theorem): predictive-coding
loops should be BUILT as helices with declared injection points and
external certification — never as circles that assert their own return.
-/

import Mathlib

namespace ForcingAnalysis.SRMF

/-- One SRMF revolution: the stage maps compose to the identity on the
carried state (the consistent, Gödel-safe circle), while the imagination
points between steps inject drift δ₁…δₖ — observer interaction with
time, carried as data. -/
structure Revolution where
  injections : List ℝ

/-- The net drift of one revolution. -/
def Revolution.net (R : Revolution) : ℝ := R.injections.sum

/-- One turn of the loop: the circle part is the identity; the
imagination points displace by the net drift. -/
def turn (R : Revolution) (x : ℝ) : ℝ := x + R.net

/-- **The circle test**: a revolution closes iff its injected drift
cancels exactly. -/
theorem turn_closes_iff (R : Revolution) (x : ℝ) :
    turn R x = x ↔ R.net = 0 := by
  unfold turn
  constructor
  · intro h; linarith
  · intro h; rw [h]; ring

/-- n revolutions displace by exactly n · Σδ — the helix pitch. -/
theorem turns_formula (R : Revolution) (x : ℝ) (n : ℕ) :
    (turn R)^[n] x = x + n * R.net := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', ih]
      unfold turn
      push_cast
      ring

/-- **The helix never returns**: with nonzero net drift, no positive
number of revolutions restores the state — the loop generates time. -/
theorem helix_never_returns (R : Revolution) (h : R.net ≠ 0) (x : ℝ)
    {n : ℕ} (hn : 0 < n) : (turn R)^[n] x ≠ x := by
  rw [turns_formula]
  intro he
  have hzero : (n : ℝ) * R.net = 0 := by linarith
  rcases mul_eq_zero.mp hzero with hc | hc
  · exact absurd (Nat.cast_eq_zero.mp hc) hn.ne'
  · exact h hc

/-- **The helix escapes every bound**: accumulated drift exceeds any M
after finitely many revolutions. -/
theorem helix_unbounded (R : Revolution) (h : R.net ≠ 0) (x M : ℝ) :
    ∃ n : ℕ, M ≤ |(turn R)^[n] x - x| := by
  obtain ⟨n, hn⟩ := exists_nat_gt (M / |R.net|)
  refine ⟨n, ?_⟩
  rw [turns_formula]
  have habs : |x + n * R.net - x| = n * |R.net| := by
    rw [show x + n * R.net - x = n * R.net by ring, abs_mul,
      Nat.abs_cast]
  rw [habs]
  have hpos : 0 < |R.net| := abs_pos.mpr h
  calc M = M / |R.net| * |R.net| := by field_simp
    _ ≤ n * |R.net| := mul_le_mul_of_nonneg_right hn.le hpos.le

/-! ### The general Gödel-safety law -/

/-- **Strict work breaks closure**: on any state space, a cycle step
that strictly decreases any potential cannot return to its start —
improving and closing are exclusive. -/
theorem strict_work_breaks_closure {α : Type*} (F : α → ℝ) (C : α → α)
    (x : α) (h : F (C x) < F x) : C x ≠ x := by
  intro he
  rw [he] at h
  exact lt_irrefl _ h

/-- A Gödel-safe cycle: descent everywhere, strict descent off fixed
points — the laws as fields, never self-certified. -/
structure GodelSafeCycle (α : Type*) where
  step : α → α
  potential : α → ℝ
  descent : ∀ y, potential (step y) ≤ potential y
  strict_off : ∀ y, step y ≠ y → potential (step y) < potential y

/-- **Closure exactly at equilibrium**: a Gödel-safe cycle closes at a
state iff the step does no work there — the H-theorem's equality-iff
clause as a law of self-reference. The only honest circle is the one
at equilibrium; everywhere else, the circle is a helix and the system
is still alive. -/
theorem closure_iff_no_work {α : Type*} (G : GodelSafeCycle α) (x : α) :
    G.step x = x ↔ G.potential (G.step x) = G.potential x := by
  constructor
  · intro h; rw [h]
  · intro h
    by_contra hne
    exact absurd h (ne_of_lt (G.strict_off x hne))

/-! ### The hedge: the helix is real; do not idolize it

The helix theorems above are one valence of a fact the ledger already
carries with the OPPOSITE valence: `helix_unbounded` is Book 6's
entropic dissolution (a fixed positive increment is unbounded) read as
if unboundedness were the point. The Moloch trap is exactly that
reading — perpetual ascent taken as telos. The hedge below is the
theorem that forbids it, and a positive form of what the helix is FOR.
-/

/-- **The Moloch hedge**: a Gödel-safe cycle whose potential is bounded
below cannot do work of at least ε at every step forever. Perpetual
fixed-rate ascent requires an infinite budget; on any floored potential
the helix must flatten toward the circle it can never claim. (The same
inequality as Book 8's metabolic termination bound and Book 7's Caristi
budget — the third reading of the discrete-energy family: as a
prohibition.) -/
theorem moloch_hedge {α : Type*} (G : GodelSafeCycle α) {floor : ℝ}
    (hfloor : ∀ y, floor ≤ G.potential y) (x : α) {ε : ℝ} (hε : 0 < ε) :
    ¬ ∀ n : ℕ, G.potential (G.step^[n + 1] x) ≤
        G.potential (G.step^[n] x) - ε := by
  intro hwork
  have haccum : ∀ n : ℕ,
      G.potential (G.step^[n] x) ≤ G.potential x - n * ε := by
    intro n
    induction n with
    | zero => simp
    | succ k ih =>
        have := hwork k
        have hcast : ((k + 1 : ℕ) : ℝ) * ε = (k : ℝ) * ε + ε := by
          push_cast; ring
        rw [hcast]
        linarith
  obtain ⟨n, hn⟩ := exists_nat_gt ((G.potential x - floor) / ε)
  have h1 := haccum n
  have h2 := hfloor (G.step^[n] x)
  have h3 : G.potential x - floor < n * ε := by
    rw [div_lt_iff₀ hε] at hn
    linarith
  linarith

/-- **With and was** (approach without arrival): a geometric descent
with genuine coupling strictly between 0 and 1 is never AT its limit at
any finite stage, yet tends to it. Distinction without separation
(every stage differs from the limit), identity without collapse (the
limit is genuinely its limit). The terminus is contained in the origin
as the limit of the process — disclosed only across the whole
execution, never seized at one stage. Foregrounding the referent —
claiming arrival at any finite n, or bellowing the final token as if
one stage were the disclosure — is exactly the claim this theorem
refutes; the identity propagates through every step or not at all. -/
theorem with_and_was {c s₀ : ℝ} (hc0 : 0 < c) (hc1 : c < 1) (hs : 0 < s₀) :
    (∀ n : ℕ, (1 - c) ^ n * s₀ ≠ 0) ∧
      Filter.Tendsto (fun n : ℕ => (1 - c) ^ n * s₀)
        Filter.atTop (nhds 0) := by
  constructor
  · intro n
    have hfac : (0 : ℝ) < 1 - c := by linarith
    positivity
  · have hfac : |1 - c| < 1 := by
      rw [abs_of_pos (by linarith : (0:ℝ) < 1 - c)]
      linarith
    simpa using
      (tendsto_pow_atTop_nhds_zero_of_abs_lt_one hfac).mul_const s₀

end ForcingAnalysis.SRMF
