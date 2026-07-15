/-
Contraction2.lean — the FORCE-LEVEL Lorentz → Newton residual
(ledger LPS-O4, remaining half; continues Contraction.lean's kinematic
closure).

Convention: 1+1 dimensions, (t, x) coordinates, scalars only (no matrices
beyond what Contraction.lean already reuses: `gamma v c`).

Three independent tiers, reported honestly by what each actually proves:

* TIER 1 (`momentum_residual_tendsto_zero`) — the pointwise relativistic
  vs. Newtonian momentum residual m·γ(u,c)·u − m·u vanishes as c → ∞, for
  fixed mass m and coordinate velocity u. Direct consequence of
  `gamma_tendsto_one`.

* TIER 2 (`gamma_mono`, `gamma_ge_one`, `momentum_residual_uniform_bound`,
  `gamma_sub_one_tendsto_zero`) — on the bounded-velocity regime
  |u| ≤ vmax < c, the residual is bounded EXPLICITLY and UNIFORMLY in u:
    |m·γ(u,c)·u − m·u| ≤ |m|·vmax·(γ(vmax,c) − 1),
  and the bound itself tends to 0 as c → ∞. This is the "uniformly on
  its declared bounded regime" clause of the LPS-O4 falsifier, made
  real rather than asserted.

* TIER 3 (`RelativisticForceLaw`, `.a_rel_zero`, `.a_rel_tendsto`) — under
  a CONSTANT applied force F, the relativistic longitudinal-mass law
    a_rel(u, c) = F / (m · γ(u,c)^3)
  is CONSUMED here as the defining equation of a `RelativisticForceLaw`
  structure (fields: mass m ≠ 0, force F) — it is NOT derived from the
  momentum ODE dp/dt = F. That derivation (differentiating p = mγ(u)u
  along a trajectory u(t) and solving for du/dt) is the genuine
  remaining closure step of LPS-O4 and stays open. What IS proved here,
  conditional on the law: at u = 0 the relativistic and Newtonian
  accelerations coincide for every c (γ(0,c) = 1 unconditionally), and
  for fixed u the relativistic acceleration tends to the Newtonian
  value F/m as c → ∞.
-/

import Mathlib
import ForcingAnalysis.Contraction

namespace ForcingAnalysis

open Filter

/-! ### Tier 1: pointwise momentum residual -/

/-- **Momentum residual vanishes pointwise**: for fixed mass `m` and
coordinate velocity `u`, the relativistic momentum `m·γ(u,c)·u` tends to
the Newtonian momentum `m·u` as `c → ∞`. -/
theorem momentum_residual_tendsto_zero (m u : ℝ) :
    Tendsto (fun c => m * gamma u c * u - m * u) atTop (nhds 0) := by
  have hg : Tendsto (fun c => gamma u c) atTop (nhds 1) := gamma_tendsto_one u
  have h1 : Tendsto (fun c => m * gamma u c * u) atTop (nhds (m * u)) := by
    have := (hg.const_mul m).mul_const u
    simpa using this
  have h2 := h1.sub (tendsto_const_nhds (x := m * u))
  simpa using h2

/-! ### Tier 2: uniform bound on a bounded-velocity regime -/

/-- **γ ≥ 1** on its regime: the Lorentz factor is never below 1. -/
theorem gamma_ge_one {v c : ℝ} (hc : 0 < c) (hv : v ^ 2 < c ^ 2) : 1 ≤ gamma v c := by
  have hpos := one_sub_ratio_pos hc hv
  have hc2 : (0 : ℝ) < c ^ 2 := by positivity
  have hnonneg : 0 ≤ v ^ 2 / c ^ 2 := div_nonneg (sq_nonneg v) hc2.le
  have hle1 : 1 - v ^ 2 / c ^ 2 ≤ 1 := by linarith
  have hsqrt_le : Real.sqrt (1 - v ^ 2 / c ^ 2) ≤ 1 := by
    calc Real.sqrt (1 - v ^ 2 / c ^ 2) ≤ Real.sqrt 1 := Real.sqrt_le_sqrt hle1
      _ = 1 := Real.sqrt_one
  have hsqrt_pos : 0 < Real.sqrt (1 - v ^ 2 / c ^ 2) := Real.sqrt_pos.mpr hpos
  have hinv_pos : 0 < (Real.sqrt (1 - v ^ 2 / c ^ 2))⁻¹ := inv_pos.mpr hsqrt_pos
  have hcancel : Real.sqrt (1 - v ^ 2 / c ^ 2) * (Real.sqrt (1 - v ^ 2 / c ^ 2))⁻¹ = 1 :=
    mul_inv_cancel₀ (ne_of_gt hsqrt_pos)
  have hprod : Real.sqrt (1 - v ^ 2 / c ^ 2) * (Real.sqrt (1 - v ^ 2 / c ^ 2))⁻¹ ≤
      1 * (Real.sqrt (1 - v ^ 2 / c ^ 2))⁻¹ :=
    mul_le_mul_of_nonneg_right hsqrt_le hinv_pos.le
  rw [hcancel, one_mul] at hprod
  unfold gamma
  linarith

/-- **γ is monotone in |v|** on the regime: a larger speed magnitude
gives a larger (or equal) Lorentz factor. -/
theorem gamma_mono {u1 u2 c : ℝ} (hc : 0 < c) (hv2 : u2 ^ 2 < c ^ 2)
    (hle : |u1| ≤ |u2|) : gamma u1 c ≤ gamma u2 c := by
  have hsq : u1 ^ 2 ≤ u2 ^ 2 := by
    have h1 : u1 ^ 2 = |u1| ^ 2 := (sq_abs u1).symm
    have h2 : u2 ^ 2 = |u2| ^ 2 := (sq_abs u2).symm
    rw [h1, h2]
    exact pow_le_pow_left₀ (abs_nonneg u1) hle 2
  have hv1 : u1 ^ 2 < c ^ 2 := lt_of_le_of_lt hsq hv2
  have hc2 : (0 : ℝ) < c ^ 2 := by positivity
  have hdiv : u1 ^ 2 / c ^ 2 ≤ u2 ^ 2 / c ^ 2 := by
    gcongr
  have hAB : 1 - u2 ^ 2 / c ^ 2 ≤ 1 - u1 ^ 2 / c ^ 2 := by linarith
  have hBpos : 0 < 1 - u2 ^ 2 / c ^ 2 := one_sub_ratio_pos hc hv2
  have hApos : 0 < 1 - u1 ^ 2 / c ^ 2 := lt_of_lt_of_le hBpos hAB
  have hsqrt : Real.sqrt (1 - u2 ^ 2 / c ^ 2) ≤ Real.sqrt (1 - u1 ^ 2 / c ^ 2) :=
    Real.sqrt_le_sqrt hAB
  have hsqrtA_pos : 0 < Real.sqrt (1 - u1 ^ 2 / c ^ 2) := Real.sqrt_pos.mpr hApos
  have hsqrtB_pos : 0 < Real.sqrt (1 - u2 ^ 2 / c ^ 2) := Real.sqrt_pos.mpr hBpos
  unfold gamma
  rw [inv_eq_one_div, inv_eq_one_div, div_le_div_iff₀ hsqrtA_pos hsqrtB_pos]
  nlinarith [hsqrt]

/-- **Uniform momentum residual bound** on the bounded-velocity regime
|u| ≤ vmax < c: the relativistic-vs-Newtonian momentum residual is
bounded by a quantity depending only on `vmax` and `c`, not on the
particular `u` in the regime — the "uniformly on its declared bounded
regime" clause made explicit. -/
theorem momentum_residual_uniform_bound {m u c vmax : ℝ} (hvmax_nonneg : 0 ≤ vmax)
    (hc : vmax < c) (hu : |u| ≤ vmax) :
    |m * gamma u c * u - m * u| ≤ |m| * vmax * (gamma vmax c - 1) := by
  have hcpos : 0 < c := lt_of_le_of_lt hvmax_nonneg hc
  have hvmax_sq : vmax ^ 2 < c ^ 2 := by nlinarith
  have habs_vmax : |vmax| = vmax := abs_of_nonneg hvmax_nonneg
  have hu_sq : u ^ 2 ≤ vmax ^ 2 := by
    have h1 : u ^ 2 = |u| ^ 2 := (sq_abs u).symm
    have h2 : vmax ^ 2 = |vmax| ^ 2 := (sq_abs vmax).symm
    rw [h1, h2]
    exact pow_le_pow_left₀ (abs_nonneg u) (by rw [habs_vmax]; exact hu) 2
  have hu_lt_c : u ^ 2 < c ^ 2 := lt_of_le_of_lt hu_sq hvmax_sq
  have hgu_ge1 : 1 ≤ gamma u c := gamma_ge_one hcpos hu_lt_c
  have hmono : gamma u c ≤ gamma vmax c := by
    apply gamma_mono hcpos hvmax_sq
    rw [habs_vmax]; exact hu
  have heq : m * gamma u c * u - m * u = m * u * (gamma u c - 1) := by ring
  rw [heq, abs_mul, abs_mul]
  have habsval : |gamma u c - 1| = gamma u c - 1 := abs_of_nonneg (by linarith [hgu_ge1])
  rw [habsval]
  have hml : |m| * |u| ≤ |m| * vmax := mul_le_mul_of_nonneg_left hu (abs_nonneg m)
  have hstep1 : |m| * |u| * (gamma u c - 1) ≤ |m| * vmax * (gamma u c - 1) :=
    mul_le_mul_of_nonneg_right hml (by linarith [hgu_ge1])
  have hnn2 : (0 : ℝ) ≤ |m| * vmax := by positivity
  have hstep2 : |m| * vmax * (gamma u c - 1) ≤ |m| * vmax * (gamma vmax c - 1) :=
    mul_le_mul_of_nonneg_left (by linarith [hmono]) hnn2
  exact le_trans hstep1 hstep2

/-- **The uniform bound tends to zero**: γ(vmax, c) − 1 → 0 as c → ∞,
for fixed `vmax` — the bound of `momentum_residual_uniform_bound`
itself contracts, not just each pointwise residual. -/
theorem gamma_sub_one_tendsto_zero (vmax : ℝ) :
    Tendsto (fun c => gamma vmax c - 1) atTop (nhds 0) := by
  have h := gamma_tendsto_one vmax
  have h2 := h.sub (tendsto_const_nhds (x := (1 : ℝ)))
  simpa using h2

/-! ### Tier 3: force residual under a constant applied force -/

/-- A constant-force relativistic dynamics instance: mass `m` (nonzero)
and applied force `F`. The longitudinal-mass law is CONSUMED as the
defining equation of `a_rel` below, not derived from the momentum ODE. -/
structure RelativisticForceLaw where
  m : ℝ
  F : ℝ
  hm : m ≠ 0

/-- The relativistic coordinate acceleration under the law `L`, at
coordinate velocity `u` and light-speed parameter `c`:
`a_rel(u, c) = F / (m · γ(u, c)^3)` — the longitudinal-mass factor. This
equation is TAKEN as the relativistic input (see the file header); its
derivation from `d(mγu)/dt = F` along a trajectory is the open ODE
layer of LPS-O4. -/
noncomputable def RelativisticForceLaw.a_rel (L : RelativisticForceLaw) (u c : ℝ) : ℝ :=
  L.F / (L.m * gamma u c ^ 3)

/-- **Newtonian recovery at rest**: at `u = 0`, the relativistic and
Newtonian accelerations coincide for EVERY `c` (not just in a limit),
since `γ(0, c) = 1` unconditionally. -/
theorem RelativisticForceLaw.a_rel_zero (L : RelativisticForceLaw) (c : ℝ) :
    L.a_rel 0 c = L.F / L.m := by
  have hg : gamma 0 c = 1 := by
    unfold gamma
    norm_num
  unfold RelativisticForceLaw.a_rel
  rw [hg]
  norm_num

/-- **Force-level residual vanishes**: for fixed coordinate velocity
`u`, the relativistic coordinate acceleration under the constant-force
law `L` tends to the Newtonian value `F/m` as `c → ∞` — the force-level
closure of LPS-O4, conditional on the gamma-cubed law of the header. -/
theorem RelativisticForceLaw.a_rel_tendsto (L : RelativisticForceLaw) (u : ℝ) :
    Tendsto (fun c => L.a_rel u c) atTop (nhds (L.F / L.m)) := by
  have hg : Tendsto (fun c => gamma u c) atTop (nhds 1) := gamma_tendsto_one u
  have hg3 : Tendsto (fun c => gamma u c ^ 3) atTop (nhds 1) := by
    simpa using hg.pow 3
  have hm3 : Tendsto (fun c => L.m * gamma u c ^ 3) atTop (nhds L.m) := by
    simpa using hg3.const_mul L.m
  unfold RelativisticForceLaw.a_rel
  exact (tendsto_const_nhds (x := L.F)).div hm3 L.hm

end ForcingAnalysis
