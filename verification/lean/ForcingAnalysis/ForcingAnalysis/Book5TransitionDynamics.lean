/-
Book5TransitionDynamics.lean — exact exponential-step kernel for transitional
covenant dynamics in Principia Symbolica Book 5.
-/
import Mathlib

namespace ForcingAnalysis.Book5TransitionDynamics

/-- Exact MAP-side update corresponding to the source's displayed
constant-coefficient exponential approximation. -/
noncomputable def mapStep (F alpha Lambda dt : ℝ) : ℝ :=
  F * Real.exp (alpha * (Lambda - 1) * dt)

/-- Exact MAD-side update corresponding to the source's displayed decay. -/
noncomputable def madStep (F beta Lambda dt : ℝ) : ℝ :=
  F * Real.exp (-beta * (|Lambda| - 1) * dt)

/-- Above the coupling boundary, a positive-rate MAP step strictly increases
positive free energy. -/
theorem mapStep_strict_growth {F alpha Lambda dt : ℝ}
    (hF : 0 < F) (hAlpha : 0 < alpha) (hLambda : 1 < Lambda)
    (hdt : 0 < dt) :
    F < mapStep F alpha Lambda dt := by
  have hExponent : 0 < alpha * (Lambda - 1) * dt := by positivity
  have hExp : 1 < Real.exp (alpha * (Lambda - 1) * dt) :=
    Real.one_lt_exp_iff.mpr hExponent
  have hProduct := mul_pos hF (sub_pos.mpr hExp)
  unfold mapStep
  nlinarith

/-- Beyond the absolute coupling boundary, a positive-rate MAD step strictly
decreases positive free energy while preserving positivity. -/
theorem madStep_strict_decay {F beta Lambda dt : ℝ}
    (hF : 0 < F) (hBeta : 0 < beta) (hLambda : 1 < |Lambda|)
    (hdt : 0 < dt) :
    0 < madStep F beta Lambda dt ∧ madStep F beta Lambda dt < F := by
  have hExponent : -beta * (|Lambda| - 1) * dt < 0 := by
    have : 0 < beta * (|Lambda| - 1) * dt := by positivity
    nlinarith
  have hExpPos : 0 < Real.exp (-beta * (|Lambda| - 1) * dt) := Real.exp_pos _
  have hExpLt : Real.exp (-beta * (|Lambda| - 1) * dt) < 1 :=
    Real.exp_lt_one_iff.mpr hExponent
  constructor
  · exact mul_pos hF hExpPos
  · have hProduct := mul_pos hF (sub_pos.mpr hExpLt)
    unfold madStep
    nlinarith

/-- The MAP update is the identity exactly on the Lambda=1 boundary. -/
theorem mapStep_at_boundary (F alpha dt : ℝ) :
    mapStep F alpha 1 dt = F := by
  simp [mapStep]

/-- A boundary crossing by itself does not determine the next free energy;
the exponential evolution law is separate, load-bearing structure. -/
theorem crossing_alone_does_not_force_growth :
    ∃ (before after Fnext : ℝ),
      before < 1 ∧ 1 < after ∧ Fnext < 0 := by
  exact ⟨0, 2, -1, by norm_num, by norm_num, by norm_num⟩

/-! ### Continuous evolution behind the exact step

The step formulas above are now recovered from a trajectory that is proved to
satisfy the stated constant-rate differential law. This is still a model of
the supplied law, not a claim that a boundary crossing generates the law. -/

/-- Constant-rate free-energy evolution from initial value `F0`. -/
noncomputable def expEvolution (F0 rate t : ℝ) : ℝ :=
  F0 * Real.exp (rate * t)

@[simp] theorem expEvolution_zero (F0 rate : ℝ) :
    expEvolution F0 rate 0 = F0 := by
  simp [expEvolution]

/-- The constructed trajectory satisfies `F' = rate * F`. -/
theorem expEvolution_hasDerivAt (F0 rate t : ℝ) :
    HasDerivAt (expEvolution F0 rate)
      (rate * expEvolution F0 rate t) t := by
  change HasDerivAt (fun y : ℝ => F0 * Real.exp (rate * y))
    (rate * (F0 * Real.exp (rate * t))) t
  simpa [mul_assoc, mul_left_comm, mul_comm] using
    (((hasDerivAt_id t).const_mul rate).exp.const_mul F0)

/-- Constant-rate evolution composes exactly across adjacent time steps. -/
theorem expEvolution_add (F0 rate s dt : ℝ) :
    expEvolution F0 rate (s + dt) =
      expEvolution (expEvolution F0 rate s) rate dt := by
  simp [expEvolution, mul_add, Real.exp_add, mul_assoc]

/-- The MAP step is evaluation of the positive-oriented evolution law. -/
theorem mapStep_eq_expEvolution (F alpha Lambda dt : ℝ) :
    mapStep F alpha Lambda dt =
      expEvolution F (alpha * (Lambda - 1)) dt := by
  simp [mapStep, expEvolution]

/-- The MAD step is evaluation of the negative-oriented evolution law. -/
theorem madStep_eq_expEvolution (F beta Lambda dt : ℝ) :
    madStep F beta Lambda dt =
      expEvolution F (-beta * (|Lambda| - 1)) dt := by
  simp [madStep, expEvolution]

/-! ### Uniqueness of the supplied constant-rate law -/

/-- Every globally differentiable solution of `F' = rate * F` is determined by
its value at any reference time. This discharges the uniqueness premise behind
the displayed exact step law; it does not derive the ODE from a regime
crossing. -/
theorem solution_eq_shifted_expEvolution
    (F : ℝ → ℝ) (rate s t : ℝ)
    (hODE : ∀ u, HasDerivAt F (rate * F u) u) :
    F t = F s * Real.exp (rate * (t - s)) := by
  let invariant : ℝ → ℝ := fun u => F u * Real.exp (-rate * u)
  have hinvariant_deriv (u : ℝ) : HasDerivAt invariant 0 u := by
    have hExp : HasDerivAt (fun v : ℝ => Real.exp (-rate * v))
        ((-rate) * Real.exp (-rate * u)) u := by
      simpa [mul_comm] using (((hasDerivAt_id u).const_mul (-rate)).exp)
    change HasDerivAt (F * fun v => Real.exp (-rate * v)) 0 u
    have hprod := (hODE u).mul hExp
    have hzero :
        rate * F u * Real.exp (-rate * u) +
          F u * (-rate * Real.exp (-rate * u)) = 0 := by
      ring
    rw [hzero] at hprod
    exact hprod
  have hinvariant_diff : Differentiable ℝ invariant :=
    fun u => (hinvariant_deriv u).differentiableAt
  have hinvariant_const : invariant t = invariant s :=
    is_const_of_deriv_eq_zero hinvariant_diff
      (fun u => (hinvariant_deriv u).deriv) t s
  have hcancel (u : ℝ) :
      Real.exp (-rate * u) * Real.exp (rate * u) = 1 := by
    rw [← Real.exp_add]
    ring_nf
    exact Real.exp_zero
  calc
    F t = invariant t * Real.exp (rate * t) := by
      simp only [invariant, mul_assoc]
      rw [hcancel, mul_one]
    _ = invariant s * Real.exp (rate * t) := by rw [hinvariant_const]
    _ = F s * (Real.exp (-rate * s) * Real.exp (rate * t)) := by
      simp [invariant, mul_assoc]
    _ = F s * Real.exp (rate * (t - s)) := by
      rw [← Real.exp_add]
      congr 2
      ring

/-- Hence an arbitrary solution of the supplied ODE obeys the exact adjacent
step law used by the source proposition. -/
theorem exact_step_of_constant_rate_ode
    (F : ℝ → ℝ) (rate s dt : ℝ)
    (hODE : ∀ u, HasDerivAt F (rate * F u) u) :
    F (s + dt) = expEvolution (F s) rate dt := by
  rw [solution_eq_shifted_expEvolution F rate s (s + dt) hODE]
  simp [expEvolution]

/-- Two solutions of the same supplied constant-rate law that agree once agree
everywhere. -/
theorem constant_rate_ode_solution_unique
    (F G : ℝ → ℝ) (rate s : ℝ)
    (hF : ∀ u, HasDerivAt F (rate * F u) u)
    (hG : ∀ u, HasDerivAt G (rate * G u) u)
    (hinit : F s = G s) :
    F = G := by
  funext t
  rw [solution_eq_shifted_expEvolution F rate s t hF,
    solution_eq_shifted_expEvolution G rate s t hG, hinit]
end ForcingAnalysis.Book5TransitionDynamics
