/-
Contraction.lean — the Lorentz → Galilei kinematic contraction
(ledger LPS-O4, first closure step).

Convention: 1+1 dimensions, coordinates (t, x) in that index order, so a
boost acts on column vectors (t, x)ᵀ; the c-metric is η_c = diag(c², −1)
(the ds² = c²dt² − dx² form of Lorentz.lean's minkEta, made
dimensionful).

What IS proved here (all limits are c → ∞ along atTop, at fixed v):

* `boost_isLorentz` — the c-parameterized boost genuinely satisfies the
  1+1 Lorentz condition Λᵀ η_c Λ = η_c on its declared regime v² < c²,
  0 < c: the thing being contracted is a real Lorentz map, not a
  lookalike (same Λᵀ η Λ = η convention as Lorentz.lean's IsLorentz).
* `gamma_tendsto_one` — γ(v,c) → 1.
* `boost_tendsto_galilean` — every entry of the boost tends to the
  Galilean boost !![1, 0; −v, 1] (t' = t, x' = x − vt): the kinematic
  contraction, entrywise.
* `scaled_metric_eq` + `metric_degenerates` — the c-normalized metric
  (c²)⁻¹ η_c is !![1, 0; 0, −c⁻²] and its spatial entry vanishes in the
  limit: the Galilean limit DEGENERATES the metric, which is exactly why
  Newton.lean's force law carries no metric in its equivariance group
  (the structural contrast noted in Newton.lean's header, now measured
  in the same limit).

What is NOT proved (LPS-O4 stays open, with this progress recorded):
the force-level residual — that the Lorentz four-force of Lorentz.lean,
suitably rescaled, tends to Newton's m•a on a bounded-velocity regime.
That statement needs the 4-velocity normalization and a dimensionally
honest embedding of the 3-force, and is the remaining closure condition
on the ledger row.
-/

import Mathlib
import ForcingKernel.Schema

namespace ForcingAnalysis

noncomputable section

open Filter Matrix

/-- The 1+1 c-metric η_c = diag(c², −1): ds² = c²dt² − dx². -/
def minkEta2 (c : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![c ^ 2, 0; 0, -1]

/-- The Lorentz factor γ(v,c) = (√(1 − v²/c²))⁻¹. -/
def gamma (v c : ℝ) : ℝ := (Real.sqrt (1 - v ^ 2 / c ^ 2))⁻¹

/-- The c-parameterized boost in (t, x) coordinates:
t' = γ(t − vx/c²), x' = γ(x − vt). -/
def boost (v c : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![gamma v c, -gamma v c * v / c ^ 2; -gamma v c * v, gamma v c]

/-- The Galilean boost: t' = t, x' = x − vt. -/
def galileanBoost (v : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, 0; -v, 1]

theorem one_sub_ratio_pos {v c : ℝ} (hc : 0 < c) (hv : v ^ 2 < c ^ 2) :
    0 < 1 - v ^ 2 / c ^ 2 := by
  rw [sub_pos, div_lt_one (by positivity)]
  exact hv

theorem gamma_pos {v c : ℝ} (hc : 0 < c) (hv : v ^ 2 < c ^ 2) :
    0 < gamma v c :=
  inv_pos.mpr (Real.sqrt_pos.mpr (one_sub_ratio_pos hc hv))

theorem gamma_sq {v c : ℝ} (hc : 0 < c) (hv : v ^ 2 < c ^ 2) :
    gamma v c ^ 2 = (1 - v ^ 2 / c ^ 2)⁻¹ := by
  unfold gamma
  rw [inv_pow, Real.sq_sqrt (one_sub_ratio_pos hc hv).le]

/-- The characteristic relation γ²(c² − v²) = c², inverse-free. -/
theorem gamma_sq_mul {v c : ℝ} (hc : 0 < c) (hv : v ^ 2 < c ^ 2) :
    gamma v c ^ 2 * (c ^ 2 - v ^ 2) = c ^ 2 := by
  rw [gamma_sq hc hv]
  have h1 : 1 - v ^ 2 / c ^ 2 = (c ^ 2 - v ^ 2) / c ^ 2 := by
    field_simp
  rw [h1]
  have h2 : c ^ 2 - v ^ 2 ≠ 0 := by nlinarith
  field_simp

/-- **The boost is genuinely Lorentz** on its regime: Λᵀ η_c Λ = η_c
(the 1+1, dimensionful form of Lorentz.lean's IsLorentz). -/
theorem boost_isLorentz {v c : ℝ} (hc : 0 < c) (hv : v ^ 2 < c ^ 2) :
    (boost v c)ᵀ * minkEta2 c * boost v c = minkEta2 c := by
  have hγ := gamma_sq_mul hc hv
  have hc2 : c ^ 2 ≠ 0 := by positivity
  ext i j
  fin_cases i
  · fin_cases j
    · simp [boost, minkEta2, Matrix.mul_apply, Matrix.transpose_apply,
        Fin.sum_univ_two]
      nlinarith [hγ]
    · simp [boost, minkEta2, Matrix.mul_apply, Matrix.transpose_apply,
        Fin.sum_univ_two]
      field_simp
      ring
  · fin_cases j
    · simp [boost, minkEta2, Matrix.mul_apply, Matrix.transpose_apply,
        Fin.sum_univ_two]
      field_simp
      ring
    · simp [boost, minkEta2, Matrix.mul_apply, Matrix.transpose_apply,
        Fin.sum_univ_two]
      field_simp
      nlinarith [hγ]

/-- v²/c² → 0 as c → ∞ (fixed v). -/
theorem ratio_tendsto_zero (v : ℝ) :
    Tendsto (fun c : ℝ => v ^ 2 / c ^ 2) atTop (nhds 0) := by
  have h : Tendsto (fun c : ℝ => c ^ 2) atTop atTop :=
    tendsto_pow_atTop two_ne_zero
  have h1 := h.inv_tendsto_atTop.const_mul (v ^ 2)
  simpa [div_eq_mul_inv] using h1

/-- **γ → 1**: the Lorentz factor contracts to the Galilean value. -/
theorem gamma_tendsto_one (v : ℝ) :
    Tendsto (fun c => gamma v c) atTop (nhds 1) := by
  unfold gamma
  have h1 : Tendsto (fun c : ℝ => 1 - v ^ 2 / c ^ 2) atTop (nhds 1) := by
    simpa using tendsto_const_nhds.sub (ratio_tendsto_zero v)
  have h2 : Tendsto (fun c : ℝ => Real.sqrt (1 - v ^ 2 / c ^ 2))
      atTop (nhds 1) := by
    simpa [Real.sqrt_one] using h1.sqrt
  simpa using h2.inv₀ one_ne_zero

/-- **The kinematic contraction**: every entry of the c-boost tends to
the corresponding Galilean boost entry as c → ∞ (LPS-O4, kinematic
half). -/
theorem boost_tendsto_galilean (v : ℝ) (i j : Fin 2) :
    Tendsto (fun c => boost v c i j) atTop (nhds (galileanBoost v i j)) := by
  have hγ := gamma_tendsto_one v
  have hinv : Tendsto (fun c : ℝ => (c ^ 2)⁻¹) atTop (nhds 0) :=
    (tendsto_pow_atTop two_ne_zero).inv_tendsto_atTop
  fin_cases i
  · fin_cases j
    · simpa [boost, galileanBoost] using hγ
    · have h01 := (hγ.neg.mul_const v).mul hinv
      simpa [boost, galileanBoost, div_eq_mul_inv] using h01
  · fin_cases j
    · have h10 := hγ.neg.mul_const v
      simpa [boost, galileanBoost] using h10
    · simpa [boost, galileanBoost] using hγ

/-- The c-normalized metric in closed form: (c²)⁻¹ η_c = diag(1, −c⁻²). -/
theorem scaled_metric_eq {c : ℝ} (hc : c ≠ 0) :
    (c ^ 2)⁻¹ • minkEta2 c = !![1, 0; 0, -(c ^ 2)⁻¹] := by
  have hc2 : c ^ 2 ≠ 0 := pow_ne_zero 2 hc
  ext i j
  fin_cases i
  · fin_cases j
    · simp [minkEta2, inv_mul_cancel₀ hc2]
    · simp [minkEta2]
  · fin_cases j
    · simp [minkEta2]
    · simp [minkEta2]

/-- **The metric degenerates in the Galilean limit**: the spatial entry
of the normalized metric vanishes as c → ∞ — mechanically confirming
why Newton.lean's equivariance group carries no metric. -/
theorem metric_degenerates :
    Tendsto (fun c : ℝ => -(c ^ 2)⁻¹) atTop (nhds 0) := by
  have h : Tendsto (fun c : ℝ => c ^ 2) atTop atTop :=
    tendsto_pow_atTop two_ne_zero
  simpa using h.inv_tendsto_atTop.neg

end

end ForcingAnalysis
