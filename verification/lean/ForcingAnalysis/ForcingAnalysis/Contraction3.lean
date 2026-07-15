/-
Contraction3.lean — deriving the γ³ longitudinal force law
(ledger LPS-O4, final closure step).

Contraction.lean closed the kinematic half (boost entries → Galilean
boost, metric degeneration); Contraction2.lean proved the residual tiers
but CONSUMED the relativistic law a = F/(m·γ³) as a structure field. This
file derives that law, closing the gap the ledger named as LPS-O4's
`next`: differentiating the relativistic momentum p(t) = m·γ(u(t),c)·u(t)
along a differentiable trajectory and reading the acceleration off
dp/dt = F.

The mathematical heart is `hasDerivAt_gammaMul`:

    d/du [γ(u,c)·u] = γ(u,c)³        on the regime u² < c², 0 < c,

proved by the chain rule through √ and ⁻¹ with every regularity
hypothesis explicit, followed by the algebraic collapse
γ + γ³u²/c² = γ³(1 − u²/c²) + γ³u²/c² = γ³. Note the method: γ is kept in
its RAW form (√(1 − u²/c²))⁻¹ throughout — no rapidity normalization, no
`Real.cosh` substitution. The un-normalized representation is exactly
what lets the derivative collapse to γ³ in three lines of algebra
(cf. the repo-wide non-normalized-forms rule).

`force_law_acceleration` then closes LPS-O4: if the momentum has
derivative F at t (the force law as a HYPOTHESIS about the trajectory,
not an axiom), the coordinate acceleration is exactly F/(m·γ³) — the law
Contraction2.lean's RelativisticForceLaw posits is now a theorem, and
with Contraction2's `RelativisticForceLaw.a_rel_tendsto` the whole chain
Lorentz force → γ³ acceleration → Newtonian F/m as c → ∞ is derived end
to end.

Scope honesty: 1+1 dimensions, coordinate velocity/momentum, fixed c on
the declared regime |u(t)| < c. Nothing here claims the 3+1 tensor form.
-/

import Mathlib
import ForcingAnalysis.Contraction

namespace ForcingAnalysis

noncomputable section

/-- The regime quantity 1 − v²/c² has derivative −2u/c² in v at u
(no nonvanishing hypothesis needed: division is total in Lean). -/
theorem hasDerivAt_oneSubRatio (u c : ℝ) :
    HasDerivAt (fun v : ℝ => 1 - v ^ 2 / c ^ 2) (-(2 * u / c ^ 2)) u := by
  have h1 : HasDerivAt (fun v : ℝ => v ^ 2) (2 * u) u := by
    simpa using hasDerivAt_pow 2 u
  have h2 : HasDerivAt (fun v : ℝ => v ^ 2 / c ^ 2) (2 * u / c ^ 2) u :=
    h1.div_const (c ^ 2)
  simpa using h2.const_sub 1

/-- **The γ³ law, derived**: d/dv [γ(v,c)·v] = γ(u,c)³ at v = u on the
regime u² < c². The longitudinal factor is not an input — it falls out
of the chain rule applied to the raw inverse-square-root form of γ. -/
theorem hasDerivAt_gammaMul {u c : ℝ} (hc : 0 < c) (hu : u ^ 2 < c ^ 2) :
    HasDerivAt (fun v => gamma v c * v) (gamma u c ^ 3) u := by
  have hf : 0 < 1 - u ^ 2 / c ^ 2 := one_sub_ratio_pos hc hu
  have hspos : 0 < Real.sqrt (1 - u ^ 2 / c ^ 2) := Real.sqrt_pos.mpr hf
  have hs2 : Real.sqrt (1 - u ^ 2 / c ^ 2) ^ 2 = 1 - u ^ 2 / c ^ 2 :=
    Real.sq_sqrt hf.le
  set s := Real.sqrt (1 - u ^ 2 / c ^ 2) with hsdef
  -- chain: ratio → sqrt → inverse
  have hsqrt : HasDerivAt (fun v => Real.sqrt (1 - v ^ 2 / c ^ 2))
      (-(2 * u / c ^ 2) / (2 * s)) u :=
    (hasDerivAt_oneSubRatio u c).sqrt hf.ne'
  have hinv : HasDerivAt (fun v => (Real.sqrt (1 - v ^ 2 / c ^ 2))⁻¹)
      (-(-(2 * u / c ^ 2) / (2 * s)) / s ^ 2) u := hsqrt.inv hspos.ne'
  have hgamma : HasDerivAt (fun v => gamma v c) (u / (c ^ 2 * s ^ 3)) u := by
    have heq : -(-(2 * u / c ^ 2) / (2 * s)) / s ^ 2 = u / (c ^ 2 * s ^ 3) := by
      field_simp
    rw [heq] at hinv
    exact hinv
  have hprod : HasDerivAt (fun v => gamma v c * v)
      (u / (c ^ 2 * s ^ 3) * u + gamma u c * 1) u :=
    hgamma.mul (hasDerivAt_id u)
  -- algebraic collapse: u²/(c²s³) + s⁻¹ = s⁻³, since s² = 1 − u²/c²
  have hgs : gamma u c = s⁻¹ := by rw [gamma, hsdef]
  have hcs : u ^ 2 + c ^ 2 * s ^ 2 = c ^ 2 := by
    rw [hs2]
    field_simp
    ring
  have hcollapse : u / (c ^ 2 * s ^ 3) * u + gamma u c * 1 = gamma u c ^ 3 := by
    rw [hgs, mul_one]
    calc u / (c ^ 2 * s ^ 3) * u + s⁻¹
        = (u ^ 2 + c ^ 2 * s ^ 2) / (c ^ 2 * s ^ 3) := by
          field_simp
      _ = c ^ 2 / (c ^ 2 * s ^ 3) := by rw [hcs]
      _ = (s ^ 3)⁻¹ := by
          rw [inv_eq_one_div, div_eq_div_iff (by positivity) (by positivity)]
          ring
      _ = (s⁻¹) ^ 3 := (inv_pow s 3).symm
  rw [hcollapse] at hprod
  exact hprod

/-- Along a differentiable trajectory staying in the regime, the
relativistic momentum m·γ(u(t),c)·u(t) has derivative m·γ³·u̇. -/
theorem momentum_hasDerivAt (m : ℝ) {c : ℝ} (hc : 0 < c)
    {u : ℝ → ℝ} {a t : ℝ} (hu : HasDerivAt u a t)
    (hreg : (u t) ^ 2 < c ^ 2) :
    HasDerivAt (fun τ => m * (gamma (u τ) c * u τ))
      (m * (gamma (u t) c ^ 3 * a)) t := by
  have h := (hasDerivAt_gammaMul hc hreg).comp t hu
  exact h.const_mul m

/-- **LPS-O4, closed**: if the relativistic momentum obeys dp/dt = F at
t (the force law as a hypothesis on the trajectory), the coordinate
acceleration is exactly F/(m·γ³) — the γ-cubed law of
Contraction2.lean's RelativisticForceLaw, derived rather than posited. -/
theorem force_law_acceleration {m c F : ℝ} (hc : 0 < c) (hm : m ≠ 0)
    {u : ℝ → ℝ} {a t : ℝ} (hu : HasDerivAt u a t)
    (hreg : (u t) ^ 2 < c ^ 2)
    (hF : HasDerivAt (fun τ => m * (gamma (u τ) c * u τ)) F t) :
    a = F / (m * gamma (u t) c ^ 3) := by
  have huniq : m * (gamma (u t) c ^ 3 * a) = F :=
    (momentum_hasDerivAt m hc hu hreg).unique hF
  have hγ : 0 < gamma (u t) c := gamma_pos hc hreg
  have hden : m * gamma (u t) c ^ 3 ≠ 0 :=
    mul_ne_zero hm (by positivity)
  rw [eq_div_iff hden]
  linear_combination huniq

end

end ForcingAnalysis
