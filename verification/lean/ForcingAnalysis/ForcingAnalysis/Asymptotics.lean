/-
Asymptotics.lean - Principia Books 6/7 asymptotic-anchor honest kernel.

This packet consists of 13 anchors on symbolic-mutation equilibrium,
reflective stabilization, and observer-exponent asymptotics that earlier
formalization passes skipped as "asymptotic/limit claims" under a
no-limits discipline. Here `Filter.Tendsto` over `atTop` is the intended
tool: every anchor below either IS a discrete-sequence limit claim in the
source text, or is reduced to one by discretizing a continuous-time limit
(`Δt → 0`, `t → ∞`) as a `ℕ`-indexed rate/iteration sequence. No manifolds,
Hilbert/Banach spaces, curvature, ODEs/PDEs, or measure theory beyond
finite sums are used; operators `R`, `D`, free-energy functionals `F`, and
"symbolic identity" targets are all modeled as bare functions/points on
`ℝ` or as abstract sequences `ℕ → ℝ`, with the modeling laws entering as
structure fields rather than `axiom`s.

Two generic engines cover most anchors:

  * `Contraction`: a map `f : ℝ → ℝ` with a fixed point `fixedPt` that
    `f` approaches geometrically (`|f x - fixedPt| ≤ rate * |x - fixedPt|`,
    `0 ≤ rate < 1`). `Contraction.tendsto_fixedPt` proves the iterate
    sequence `n ↦ f^[n] x0` tends to `fixedPt` -- the honest kernel of
    every "repeated application of the reflection operator converges to a
    coherent/stable identity" claim in Books 6-7.
  * `GeometricErrorBound` / `QuadraticErrorBound`: an error sequence
    dominated by `C * rate^n` (resp. `C * eps n * eps n` for `eps n → 0`)
    tends to `0` by the squeeze theorem -- the honest kernel of every
    `+ O(e^{-ηn})` / `+ O(‖R - Id‖²)` residual claim.

Anchor-by-anchor:
  * definition:bk6_mutation_rate -> `windowAverage`, a Cesàro-type
    running average of a `{0,1}`-valued bifurcation indicator over a
    window of length `n` (discretizing `Δt → 0` as `n → ∞` in the source
    definition); `windowAverage_mem_unitInterval` is the one genuine
    consequence (the rate always lies in `[0,1]`).
  * proposition:bk6_mutation_equilibrium -> `MutationEquilibrium` bundles
    the stated convergence `Tendsto rate atTop (nhds limit)` with
    `limit > 0` as its defining law; `MutationEquilibrium.eventually_pos`
    is the genuine consequence (the rate is eventually strictly positive).
    The entropy-balance clause (`σ_prod = σ_diss`) and its proof via
    operator commutation are not modeled: they are geometric/operator
    claims with no scalar-sequence content in this text.
  * proposition:bk6_drift_reflection_correspondence -> `QuadraticErrorBound`
    instantiated with `eps n = ‖R_n - Id‖ → 0`: the O(‖R-Id‖²) residual
    tends to `0`, the honest content of "D → (1/2)(R - R⁻¹) as R → Id".
  * axiom:bk6_equilibrium_of_mutability -> `MutabilityEquilibrium` bundles
    `Tendsto (μ - η) atTop (nhds 0)` as its law;
    `MutabilityEquilibrium.eta_tendsto_of_mu_tendsto` derives that if `μ`
    additionally converges to `L` (as in `MutationEquilibrium`), `η`
    converges to the same `L`.
  * definition:bk6_reflection_operator_complete -> the "attracting fixed
    points" clause is exactly a `Contraction` instance
    (`Contraction.tendsto_fixedPt`); the "entropy reduction" clause is
    exactly an `AntitoneBoundedProcess` instance
    (`AntitoneBoundedProcess.tendsto_iInf`, entropy is antitone and
    bounded below along the iterates, hence converges). The
    "near-involution" clause (`‖R∘R - Id‖ ≤ ε_λ`) is a single numeric
    bound with no further consequence to prove and is left as a modeling
    note rather than forced into a decorative theorem.
  * definition:bk6_regulatory_basin_operator -> `eventually_mem_ball_of_tendsto`:
    the honest content of "`lim_{t→∞} Φ_t(q) ∈ B_ε(p)`" is that a
    sequence converging to `p` is eventually inside every `ε`-ball
    around `p`.
  * axiom:bk6_map_equilibrium_invariance_complete -> `GeometricErrorBound`
    instantiated with `rate = e^{-η}` (kept as an abstract rate in
    `[0,1)` rather than reintroducing `Real.exp`, since only the decay
    property is used, not the exponential's algebraic structure): the
    functional residual `F[(...)^n(p)] - F[p]` tends to `0`.
  * theorem:bk6_complete_operator_closure -> SKIPPED, see open anchors.
  * lemma:bk6_grace_basin_correspondence -> SKIPPED, see open anchors.
  * lemma:bk7_reflective_integration_lemma___formalized -> reuses
    `GeometricErrorBound.tendsto_zero`: the divergence residual
    `‖∇·(R^n Δφ)‖` decaying geometrically tends to `0`, the honest kernel
    of "recursive reflection systematically reduces drift-induced
    divergence".
  * axiom:bk7_reflective_stabilization -> two clauses, both genuine: the
    free-energy sequence along the combined flow is antitone and bounded
    below, hence converges (`AntitoneBoundedProcess.tendsto_iInf`); the
    contractive-reflection stabilization of a perturbation is exactly
    `Contraction.tendsto_fixedPt` with `fixedPt` playing the role of
    `identity`.
  * axiom:bk7_emergence_of_coherence_via_convergence -> again exactly
    `Contraction.tendsto_fixedPt`: the recursive reflective dynamics
    `R^n(ρ0)` converging to `identity` is the fixed-point-attraction
    conclusion for any starting point within the contraction's basin.
  * theorem:bk7_emergent_lp_norm -> `AsymptoticExponentField` bundles the
    stated boundary limit `lim_{ε→∞} p(ε) = 1` together with `p ε > 1`
    everywhere as its laws; `AsymptoticExponentField.eventually_near_one`
    derives that `p` is eventually within any `δ > 0` of `1` from above.
    The companion limit `lim_{ε→0+} p(ε) = ∞`, the `C¹` and strict
    monotonicity clauses, and the existence/uniqueness of `p` itself are
    not modeled: they involve a one-sided limit at a domain boundary,
    differentiability, and an existence claim respectively, none of which
    add further scalar-sequence content beyond the boundary-limit kernel
    already captured.

Open anchors (no honest scalar/sequence kernel without inventing
structure absent from the text):
  * theorem:bk6_complete_operator_closure: an operator-algebra closure
    claim (`O1 ∘ O2 = Σ c_k O_k + E` with `‖E‖_op` arbitrarily small) over
    an unspecified operator space `C_ext`; there is no underlying
    real/sequence law in the text to extract without inventing the
    operator space and its norm from scratch.
  * lemma:bk6_grace_basin_correspondence: a set-membership claim
    (`G(p) ∈ ⋃_{q ∈ E_R} R_B(q)`) relating three previously-abstract
    operators/sets (`G`, `R_B`, `E_R`) on an unspecified state space
    `P_λ`; no numeric law is stated to formalize.
-/
import Mathlib

namespace ForcingAnalysis.Asymptotics

open Filter

/- ================================================================
   Generic engine 1: contraction to a fixed point.
   Covers: definition:bk6_reflection_operator_complete (attracting fixed
   points clause), lemma:bk7_reflective_integration_lemma___formalized
   (via GeometricErrorBound below), axiom:bk7_reflective_stabilization
   (basin-of-attraction clause), axiom:bk7_emergence_of_coherence_via_convergence.
   ================================================================ -/

/-- A map `f` with a fixed point `fixedPt` that it approaches
geometrically at every point, at rate `rate ∈ [0,1)`. This is the
scalar/discrete honest kernel of "recursive reflection `R^n` converges to
a convergent symbolic identity". -/
structure Contraction where
  f : Real → Real
  fixedPt : Real
  rate : Real
  rate_nonneg : 0 ≤ rate
  rate_lt_one : rate < 1
  contracts : ∀ x, |f x - fixedPt| ≤ rate * |x - fixedPt|

/-- The distance to the fixed point after `n` iterations is bounded by
`rate ^ n` times the initial distance, by induction on `n`. -/
theorem Contraction.iterate_dist_le (c : Contraction) (x0 : Real) :
    ∀ n : ℕ, |c.f^[n] x0 - c.fixedPt| ≤ c.rate ^ n * |x0 - c.fixedPt| := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply']
      calc |c.f (c.f^[k] x0) - c.fixedPt|
          ≤ c.rate * |c.f^[k] x0 - c.fixedPt| := c.contracts _
        _ ≤ c.rate * (c.rate ^ k * |x0 - c.fixedPt|) :=
              mul_le_mul_of_nonneg_left ih c.rate_nonneg
        _ = c.rate ^ (k + 1) * |x0 - c.fixedPt| := by
              rw [pow_succ]; ring

/-- The iterate sequence `n ↦ f^[n] x0` converges to the fixed point:
the honest kernel of every "recursive reflection converges to a coherent
identity" claim (definition:bk6_reflection_operator_complete,
lemma:bk7_reflective_integration_lemma___formalized,
axiom:bk7_reflective_stabilization,
axiom:bk7_emergence_of_coherence_via_convergence). -/
theorem Contraction.tendsto_fixedPt (c : Contraction) (x0 : Real) :
    Tendsto (fun n => c.f^[n] x0) atTop (nhds c.fixedPt) := by
  have hrate : Tendsto (fun n : ℕ => c.rate ^ n) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one
      (by rw [abs_of_nonneg c.rate_nonneg]; exact c.rate_lt_one)
  have hbound : Tendsto (fun n : ℕ => c.rate ^ n * |x0 - c.fixedPt|) atTop (nhds 0) := by
    simpa using hrate.mul_const |x0 - c.fixedPt|
  have hlow : Tendsto (fun n : ℕ => c.fixedPt - c.rate ^ n * |x0 - c.fixedPt|) atTop
      (nhds c.fixedPt) := by
    simpa using (tendsto_const_nhds (x := c.fixedPt)).sub hbound
  have hhigh : Tendsto (fun n : ℕ => c.fixedPt + c.rate ^ n * |x0 - c.fixedPt|) atTop
      (nhds c.fixedPt) := by
    simpa using (tendsto_const_nhds (x := c.fixedPt)).add hbound
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le hlow hhigh
    (fun n => by linarith [(abs_le.mp (c.iterate_dist_le x0 n)).1])
    (fun n => by linarith [(abs_le.mp (c.iterate_dist_le x0 n)).2])

/- ================================================================
   Generic engine 2: geometric and quadratic error-residual decay.
   Covers: axiom:bk6_map_equilibrium_invariance_complete,
   lemma:bk7_reflective_integration_lemma___formalized (divergence
   residual), proposition:bk6_drift_reflection_correspondence.
   ================================================================ -/

/-- An error sequence dominated by `C * rate ^ n` with `rate ∈ [0,1)`:
the honest kernel of every `+ O(e^{-η n})` residual claim
(axiom:bk6_map_equilibrium_invariance_complete,
lemma:bk7_reflective_integration_lemma___formalized). The rate is kept
abstract in `[0,1)` rather than reconstructed as `Real.exp (-η)`, since
only the decay property (not the exponential's algebraic structure) is
used. -/
structure GeometricErrorBound where
  err : ℕ → Real
  C : Real
  rate : Real
  C_nonneg : 0 ≤ C
  rate_nonneg : 0 ≤ rate
  rate_lt_one : rate < 1
  bound : ∀ n, |err n| ≤ C * rate ^ n

/-- The error sequence tends to `0`, by the squeeze theorem against
`± C * rate ^ n`. -/
theorem GeometricErrorBound.tendsto_zero (g : GeometricErrorBound) :
    Tendsto g.err atTop (nhds 0) := by
  have hrate : Tendsto (fun n : ℕ => g.rate ^ n) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one
      (by rw [abs_of_nonneg g.rate_nonneg]; exact g.rate_lt_one)
  have hbound : Tendsto (fun n : ℕ => g.C * g.rate ^ n) atTop (nhds 0) := by
    simpa using hrate.const_mul g.C
  have hlow : Tendsto (fun n : ℕ => -(g.C * g.rate ^ n)) atTop (nhds 0) := by
    simpa using hbound.neg
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le hlow hbound
    (fun n => (abs_le.mp (g.bound n)).1)
    (fun n => (abs_le.mp (g.bound n)).2)

/-- An error sequence dominated by `C * eps n * eps n` for a control
sequence `eps` tending to `0`: the honest kernel of the `+ O(‖R - Id‖²)`
residual in proposition:bk6_drift_reflection_correspondence, with
`eps n = ‖R_n - Id‖`. -/
structure QuadraticErrorBound where
  eps : ℕ → Real
  err : ℕ → Real
  C : Real
  C_nonneg : 0 ≤ C
  eps_tendsto : Tendsto eps atTop (nhds 0)
  bound : ∀ n, |err n| ≤ C * (eps n * eps n)

/-- The error sequence tends to `0`: the honest content of
"`D = (1/2)(R - R⁻¹) + O(‖R - Id‖²)`" as `R → Id`. -/
theorem QuadraticErrorBound.tendsto_zero (q : QuadraticErrorBound) :
    Tendsto q.err atTop (nhds 0) := by
  have hsq : Tendsto (fun n => q.eps n * q.eps n) atTop (nhds 0) := by
    simpa using q.eps_tendsto.mul q.eps_tendsto
  have hCsq : Tendsto (fun n => q.C * (q.eps n * q.eps n)) atTop (nhds 0) := by
    simpa using hsq.const_mul q.C
  have hlow : Tendsto (fun n => -(q.C * (q.eps n * q.eps n))) atTop (nhds 0) := by
    simpa using hCsq.neg
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le hlow hCsq
    (fun n => (abs_le.mp (q.bound n)).1)
    (fun n => (abs_le.mp (q.bound n)).2)

/- ================================================================
   definition:bk6_mutation_rate
   ================================================================ -/

/-- The windowed average of a bifurcation indicator over the first `n`
symbolic time steps: the discrete honest kernel of `μ(t) = (1/Δt) ∫
χ_bifurcation`, discretizing `Δt → 0` as a growing window `n → ∞`. -/
noncomputable def windowAverage (indicator : ℕ → Real) (n : ℕ) : Real :=
  (Finset.range n).sum indicator / n

/-- If the bifurcation indicator only ever takes the values `0` and `1`,
the windowed mutation rate always lies in the unit interval. -/
theorem windowAverage_mem_unitInterval {indicator : ℕ → Real}
    (hind : ∀ k, indicator k = 0 ∨ indicator k = 1) {n : ℕ} (hn : 0 < n) :
    0 ≤ windowAverage indicator n ∧ windowAverage indicator n ≤ 1 := by
  unfold windowAverage
  have hsum_nonneg : 0 ≤ (Finset.range n).sum indicator := by
    apply Finset.sum_nonneg
    intro k _
    rcases hind k with h | h <;> simp [h]
  have hsum_le : (Finset.range n).sum indicator ≤ n := by
    have hstep : (Finset.range n).sum indicator ≤ (Finset.range n).sum (fun _ => (1 : Real)) := by
      apply Finset.sum_le_sum
      intro k _
      rcases hind k with h | h <;> simp [h]
    simpa using hstep
  refine ⟨div_nonneg hsum_nonneg (by positivity), ?_⟩
  rw [div_le_one (by exact_mod_cast hn)]
  exact hsum_le

/- ================================================================
   proposition:bk6_mutation_equilibrium
   ================================================================ -/

/-- Mutation equilibrium: the symbolic mutation rate converges to a
strictly positive limit. -/
structure MutationEquilibrium where
  rate : ℕ → Real
  limit : Real
  limit_pos : 0 < limit
  converges : Tendsto rate atTop (nhds limit)

/-- At mutation equilibrium the rate is eventually strictly positive
(halfway to its positive limit). The entropy-balance clause
(`σ_prod = σ_diss`) of the source proposition is a geometric/operator
identity with no further scalar consequence and is not modeled. -/
theorem MutationEquilibrium.eventually_pos (m : MutationEquilibrium) :
    ∃ N, ∀ n ≥ N, 0 < m.rate n := by
  obtain ⟨N, hN⟩ := (Metric.tendsto_atTop.mp m.converges) (m.limit / 2) (by linarith [m.limit_pos])
  refine ⟨N, fun n hn => ?_⟩
  have hdist := hN n hn
  rw [Real.dist_eq] at hdist
  have habs := (abs_lt.mp hdist).1
  linarith [m.limit_pos]

/- ================================================================
   axiom:bk6_equilibrium_of_mutability
   ================================================================ -/

/-- Equilibrium of mutability: the gap between the mutation rate `mu`
and the reflective damping `eta` tends to `0`. -/
structure MutabilityEquilibrium where
  mu : ℕ → Real
  eta : ℕ → Real
  balance : Tendsto (fun n => mu n - eta n) atTop (nhds 0)

/-- If in addition the mutation rate converges to `L` (as in
`MutationEquilibrium`), the reflective damping converges to the same
limit. -/
theorem MutabilityEquilibrium.eta_tendsto_of_mu_tendsto (e : MutabilityEquilibrium)
    {L : Real} (hmu : Tendsto e.mu atTop (nhds L)) :
    Tendsto e.eta atTop (nhds L) := by
  have h : Tendsto (fun n => e.mu n - (e.mu n - e.eta n)) atTop (nhds (L - 0)) :=
    hmu.sub e.balance
  have heq : (fun n => e.mu n - (e.mu n - e.eta n)) = e.eta := by
    funext n; ring
  rw [heq, sub_zero] at h
  exact h

/- ================================================================
   definition:bk6_reflection_operator_complete (entropy-reduction clause)
   ================================================================ -/

/-- A process (e.g. an entropy or free-energy functional evaluated along
the iterates of a reflection/stabilization operator) that is antitone
and bounded below. -/
structure AntitoneBoundedProcess where
  seq : ℕ → Real
  antitone : Antitone seq
  bddBelow : BddBelow (Set.range seq)

/-- An antitone process bounded below converges to its infimum: the
honest kernel of the "entropy reduction" clause of
definition:bk6_reflection_operator_complete, and of the free-energy
convergence clause of axiom:bk7_reflective_stabilization
(`lim_{t→∞} F[...] = F_min`). -/
theorem AntitoneBoundedProcess.tendsto_iInf (p : AntitoneBoundedProcess) :
    Tendsto p.seq atTop (nhds (⨅ n, p.seq n)) :=
  tendsto_atTop_ciInf p.antitone p.bddBelow

/- ================================================================
   definition:bk6_regulatory_basin_operator
   ================================================================ -/

/-- If a symbolic flow `φ` converges to `p`, it is eventually inside
every `ε`-neighborhood of `p`: the honest kernel of the basin-operator
clause `lim_{t→∞} Φ_t(q) ∈ B_ε(p)`. -/
theorem eventually_mem_ball_of_tendsto {φ : ℕ → Real} {p : Real}
    (hφ : Tendsto φ atTop (nhds p)) {eps : Real} (heps : 0 < eps) :
    ∃ N, ∀ n ≥ N, φ n ∈ Metric.ball p eps := by
  obtain ⟨N, hN⟩ := (Metric.tendsto_atTop.mp hφ) eps heps
  exact ⟨N, fun n hn => Metric.mem_ball.mpr (hN n hn)⟩

/- ================================================================
   theorem:bk7_emergent_lp_norm
   ================================================================ -/

/-- The observer-exponent field `p` from theorem:bk7_emergent_lp_norm:
always strictly above `1`, and tending to `1` as the horizon `ε → ∞`. -/
structure AsymptoticExponentField where
  p : Real → Real
  p_gt_one : ∀ eps, 1 < p eps
  limit_at_top : Tendsto p atTop (nhds 1)

/-- The exponent eventually lies within any `δ > 0` of its limiting
value `1`, from above. The companion limit `lim_{ε→0+} p(ε) = ∞`, the
`C¹`/strict-monotonicity clauses, and the existence/uniqueness of `p`
itself are not modeled (a boundary limit at `0`, differentiability, and
an existence claim add no further scalar-sequence content here). -/
theorem AsymptoticExponentField.eventually_near_one (a : AsymptoticExponentField)
    {delta : Real} (hdelta : 0 < delta) :
    ∃ E, ∀ eps ≥ E, a.p eps < 1 + delta := by
  obtain ⟨E, hE⟩ := (Metric.tendsto_atTop.mp a.limit_at_top) delta hdelta
  refine ⟨E, fun eps heps => ?_⟩
  have hdist := hE eps heps
  rw [Real.dist_eq] at hdist
  have habs := (abs_lt.mp hdist).2
  linarith

end ForcingAnalysis.Asymptotics
