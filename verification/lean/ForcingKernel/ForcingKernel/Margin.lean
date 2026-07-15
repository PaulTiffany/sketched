/-
Margin.lean — the Channel-Margin lemma, path form (lem:margin of
forcing_correspondence_v15), and a formal refutation of the v14 per-step
induction.

The analytic content of lem:margin is Weyl's eigenvalue perturbation
inequality composed with the Lipschitz hypothesis; both are packaged here
as the per-step drift bound `lam (i+1) ≥ lam i - δ i` (this is exactly how
Assumption asm:smooth feeds the lemma — the matrix analysis is cited, not
re-proved; formalizing Weyl itself needs mathlib's spectral theory).
What remains is pure order-additive arithmetic, so we state it over `Int`;
the argument transports verbatim to any linearly ordered abelian group
(in particular ℝ).

Two results:

* `margin_path_form` — the v15 repair: a cumulative drift budget gives a
  depth-uniform margin. (P; hypotheses are asm:smooth in drift form.)
* `per_step_bound_insufficient` — the v14 defect, machine-checked: bounding
  each step's drift, with the same anchor, does NOT give a uniform margin.
  The witness is the linear decay λ_i = 4 - 2i with per-step drift 2,
  crossing zero at depth 2 — the "margin decays linearly in depth" failure
  the verification suite's audit identified.
-/

namespace ForcingKernel

/-- Cumulative drift budget spent after `n` steps. -/
def driftSum (δ : Nat → Int) : Nat → Int
  | 0 => 0
  | n + 1 => driftSum δ n + δ n

/-- The margin never falls below the anchor minus the spent budget. -/
theorem margin_ge_anchor_sub_budget (lam δ : Nat → Int)
    (hstep : ∀ i, lam (i + 1) ≥ lam i - δ i) :
    ∀ n, lam n ≥ lam 0 - driftSum δ n := by
  intro n
  induction n with
  | zero => simp [driftSum]
  | succ n ih =>
    have h := hstep n
    simp only [driftSum]
    omega

/-- **Channel-Margin, path form** (lem:margin, v15): if the anchor margin
is `2ε` and the cumulative drift budget is `ε`, the margin stays `≥ ε` at
every depth. -/
theorem margin_path_form (lam δ : Nat → Int) (ε : Int)
    (hstep : ∀ i, lam (i + 1) ≥ lam i - δ i)
    (hbudget : ∀ n, driftSum δ n ≤ ε)
    (hanchor : lam 0 ≥ 2 * ε) :
    ∀ n, lam n ≥ ε := by
  intro n
  have h := margin_ge_anchor_sub_budget lam δ hstep n
  have hb := hbudget n
  omega

/-- **The v14 induction is unsound** (machine-checked countermodel):
per-step drift control with the same anchor does not bound the margin
uniformly in depth. Witness: λ_i = 4 - 2i, per-step drift 2, anchor 4;
the claimed bound λ_n ≥ 2 fails at depth 2. -/
theorem per_step_bound_insufficient :
    ¬ (∀ (lam δ : Nat → Int) (ε : Int),
        (∀ i, lam (i + 1) ≥ lam i - δ i) →   -- same drift hypothesis
        (∀ i, δ i ≤ ε) →                      -- v14: only per-step control
        lam 0 ≥ 2 * ε →                       -- same anchor
        ∀ n, lam n ≥ ε) := by
  intro h
  have hfail :=
    h (fun i => 4 - 2 * (i : Int)) (fun _ => 2) 2
      (by intro i; simp; omega)
      (by intro i; omega)
      (by simp)
      2
  simp at hfail

end ForcingKernel
