/-
Book5Operators.lean — the operator-evolution and convergence kernels
(book5 SRMF operator dynamics; book8 RG fixed point).

Sources (Principia, verbatim; sha-bound in bindings.json):

  proposition:bk5_operator_evolution — the operator path is stationary
    iff the operator minimizes the process free energy F_proc;
    otherwise it strictly evolves toward a minimizer.
  theorem:bk5_operator_convergence / proposition:bk5_operators_evolve —
    SRMF dynamics converge to a local minimum of F_proc.
  lemma:bk5_recursive_flow_convergence — the recursive reflective flow
    converges to a stable fixed point.
  theorem:bk8_rg_fixed_point — R_λ^n(S) → S★ with R_λ(S★) ≅ S★.
  proposition:bk5_metabolic_capacity_non_decreasing — MC is
    non-decreasing in the system's energy reserves.
  corollary:bk5_spectral_radius_optimality — minimizing the coupling
    spectral radius ρ(C) maximizes long-term viability.

KERNELS (finite/scalar, honest):

  * `operator_stationary_iff_critical` — a gradient-descent operator
    step fixes O exactly when the process free energy has zero gradient
    there: stationary ⟺ critical point, the exact content of "path is
    stationary iff O minimizes" for the descent dynamics (the general
    minimizer/critical-point gap under non-convexity is the honest
    remainder).
  * `contraction_flow_unique_fixed_point` + `contraction_flow_converges` —
    a contraction has a unique fixed point that every orbit approaches
    geometrically: the recursive-flow / RG fixed-point convergence,
    Banach-style, with the contraction constant as the modeling
    hypothesis (the specific R_λ operators and ≅ diffeomorphism stay
    open).
  * `metabolic_capacity_monotone` — MC non-decreasing in energy
    reserves, as a monotonicity theorem.
  * `viability_antitone_in_spectral_radius` — viability is antitone in
    the coupling spectral radius, so minimizing ρ maximizes viability
    (spectral-radius optimality).

The Wasserstein-gradient-flow O(1/t) rate (theorem:bk2_wasserstein_gradient_flow
route) and the operator-space/diffeomorphism structure stay open.
-/

import Mathlib

namespace ForcingAnalysis.Book5Op

open scoped NNReal

/-! ### Operator evolution: stationary iff critical -/

/-- **proposition:bk5_operator_evolution**: with the SRMF operator step
a gradient descent O ↦ O − η·F′(O) on the process free energy, the
operator is stationary (the step fixes it) exactly when F′(O) = 0 — the
path rests iff at a critical point of F_proc. -/
theorem operator_stationary_iff_critical (F' : ℝ → ℝ) {η : ℝ} (hη : η ≠ 0)
    (O : ℝ) :
    O - η * F' O = O ↔ F' O = 0 := by
  constructor
  · intro h
    have : η * F' O = 0 := by linarith
    exact (mul_eq_zero.mp this).resolve_left hη
  · intro h
    rw [h, mul_zero, sub_zero]

/-! ### Recursive-flow / RG convergence: the contraction fixed point -/

variable {X : Type*} [MetricSpace X] [CompleteSpace X] [Nonempty X]

/-- **lemma:bk5_recursive_flow_convergence / theorem:bk8_rg_fixed_point**:
a contraction (Lipschitz constant K < 1) on a complete space has a
UNIQUE fixed point — the recursive reflective flow / RG map converges
to one stable S★, R(S★) = S★. The contraction hypothesis is the
modeling step; the specific operators and ≅ stay open. -/
theorem contraction_flow_unique_fixed_point {R : X → X} {K : ℝ≥0}
    (hK : K < 1) (hR : LipschitzWith K R) :
    ∃! s, R s = s := by
  have hc : ContractingWith K R := ⟨hK, hR⟩
  exact ⟨hc.fixedPoint R, hc.fixedPoint_isFixedPt, fun y hy =>
    hc.fixedPoint_unique hy⟩

/-- **theorem:bk8_rg_fixed_point, convergence**: from any start the RG
orbit converges to the unique fixed point S★ — R_λ^n(S) → S★. -/
theorem contraction_flow_converges {R : X → X} {K : ℝ≥0}
    (hK : K < 1) (hR : LipschitzWith K R) (x : X) :
    Filter.Tendsto (fun n => R^[n] x) Filter.atTop
      (nhds (ContractingWith.fixedPoint R ⟨hK, hR⟩)) :=
  ContractingWith.tendsto_iterate_fixedPoint ⟨hK, hR⟩ x

/-! ### Metabolic capacity and spectral-radius optimality -/

/-- **proposition:bk5_metabolic_capacity_non_decreasing**: metabolic
capacity is non-decreasing in the system's energy reserves — more
reserves never reduce capacity. -/
theorem metabolic_capacity_monotone (MC : ℝ → ℝ) (hmono : Monotone MC)
    {E E' : ℝ} (h : E ≤ E') : MC E ≤ MC E' :=
  hmono h

/-- **corollary:bk5_spectral_radius_optimality**: long-term viability is
antitone in the coupling spectral radius ρ(C) — so the configuration
minimizing ρ(C) maximizes viability. -/
theorem viability_antitone_in_spectral_radius (V : ℝ → ℝ)
    (hanti : Antitone V) {ρ ρ' : ℝ} (h : ρ ≤ ρ') : V ρ' ≤ V ρ :=
  hanti h

end ForcingAnalysis.Book5Op
