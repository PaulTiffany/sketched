/-
Book2.lean — the finite Gibbs kernel of Principia Symbolica Book 2
(symbolic thermodynamics).

Scope, stated honestly: Book 2 is built on a Riemannian symbolic manifold
(M, g) with a Fokker–Planck PDE, Wasserstein gradient flow, and integral
thermodynamic identities. NONE of that continuum apparatus is certified
here. What IS certified is the finite-state Gibbs kernel that the book's
equilibrium theory instantiates on any finite symbolic alphabet: the
partition function, the Gibbs density, the variational principle (free
energy is uniquely minimized at equilibrium — the arithmetic heart of
both the Equilibrium Distribution theorem and the H-theorem's endpoint),
entropy bounds, probability conservation under stochastic evolution,
detailed balance as the finite shadow of the gradient condition, and the
classical finite-size fact that the free energy is differentiable in β —
i.e. genuine phase transitions REQUIRE an infinite limit. Dynamical
monotonicity (dF/ds ≤ 0 along the flow) is NOT proved: it needs the
continuum flow or a discrete data-processing inequality, and remains a
named open item.

Sources (Principia atlas, transcribed 2026-07-11; bindings in
verification/bindings.json):

  definition:bk2_symbolic_partition_funct — Z(β) = ∫ e^{−βH} dμ_g;
    finitely: `partition`, positivity `partition_pos`.
  theorem:bk2_equilibrium_distribution — ρ_eq = Z⁻¹e^{−βH}; finitely:
    `gibbs` is a density (`gibbs_isDensity`), is stationary for every
    detailed-balance evolution (`detailedBalance_stationary`), and is
    the UNIQUE free-energy minimizer (`gibbs_minimizes`,
    `gibbs_unique_minimizer`).
  theorem:bk2_h_theorem_for_symbolic_evol — F_β is a Lyapunov functional
    with equality iff ρ = ρ_eq; certified kernel: the endpoint
    characterization (unique minimum, `freeEnergy_gibbs` = −β⁻¹ log Z);
    the monotone-decrease claim along the flow is open (see above).
  definition:bk2_symbolic_free_energy / definition:bk2_symbolic_entropy —
    `freeEnergy`, `entropy` (finite forms; 0·log 0 = 0 by Lean's
    log 0 = 0 convention, matching the measure-theoretic convention).
  lemma:bk2_finiteness_of_symbolic_entropy — finitely: two-sided bounds
    0 ≤ S[ρ] ≤ log n (`entropy_nonneg`, `entropy_le_log_card`).
  lemma:bk2_conservation_of_probability — finitely: row-stochastic
    evolution preserves total mass and density-hood
    (`evolve_conserves`, `evolve_isDensity`).
  axiom:bk2_gradient_structure_drift — D = −∇_g H + ξ with ξ solenoidal;
    finite shadow: reversibility = `DetailedBalance` (the gradient part)
    and the 3-cycle `cycle_stationary_not_reversible` (a stationary but
    irreversible chain — the solenoidal component ξ, exhibited).
  axiom:bk2_symbolic_fokker_planck_equation — finite skeleton only:
    evolution by a stochastic kernel (`IsStochastic`, `evolve`); the
    manifold PDE is not certified.
  definition:bk2_symbolic_phase_transitio /
  theorem:bk2_classification_symb_phase_transitions — certified
    negative-space kernel: at ANY finite alphabet the free energy
    f(β) = −β⁻¹ log Z is differentiable at every β > 0
    (`no_finite_phase_transition`), so the non-analyticity that DEFINES
    a symbolic phase transition requires an infinite system. The
    classification by derivative order is not certified.
  definition:bk2_symbolic_energy — the bridge identity ⟨H⟩ = −d/dβ log Z
    (`energy_eq_neg_deriv_log_partition`), the derivative form the
    temperature definition (definition:bk2_symbolic_temperature)
    differentiates.
-/

import Mathlib
import ForcingKernel.Schema

namespace ForcingAnalysis.Book2

noncomputable section

open Filter Finset

variable {n : ℕ} [NeZero n]

/-! ### Densities, entropy, free energy -/

/-- A probability density on the finite symbolic alphabet. -/
structure IsDensity (ρ : Fin n → ℝ) : Prop where
  nonneg : ∀ i, 0 ≤ ρ i
  sum_one : ∑ i, ρ i = 1

/-- Finite symbolic entropy (definition:bk2_symbolic_entropy); Lean's
`log 0 = 0` gives the standard 0·log 0 = 0 convention. -/
def entropy (ρ : Fin n → ℝ) : ℝ := -∑ i, ρ i * Real.log (ρ i)

/-- Finite symbolic free energy (definition:bk2_symbolic_free_energy):
F_β[ρ] = ⟨H⟩_ρ − β⁻¹ S[ρ]. -/
def freeEnergy (β : ℝ) (H ρ : Fin n → ℝ) : ℝ :=
  (∑ i, ρ i * H i) - β⁻¹ * entropy ρ

/-- The symbolic partition function
(definition:bk2_symbolic_partition_funct). -/
def partition (β : ℝ) (H : Fin n → ℝ) : ℝ := ∑ i, Real.exp (-β * H i)

/-- The Gibbs density ρ_eq = Z⁻¹ e^{−βH}
(theorem:bk2_equilibrium_distribution). -/
def gibbs (β : ℝ) (H : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (-β * H i) / partition β H

theorem partition_pos (β : ℝ) (H : Fin n → ℝ) : 0 < partition β H :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty

theorem gibbs_pos (β : ℝ) (H : Fin n → ℝ) (i : Fin n) : 0 < gibbs β H i :=
  div_pos (Real.exp_pos _) (partition_pos β H)

/-- The Gibbs state is well-posed: a genuine probability density
(lemma:bk2_wellposedness_symb_prob_space, finite kernel). -/
theorem gibbs_isDensity (β : ℝ) (H : Fin n → ℝ) : IsDensity (gibbs β H) where
  nonneg i := (gibbs_pos β H i).le
  sum_one := by
    simp only [gibbs]
    rw [← Finset.sum_div]
    exact div_self (partition_pos β H).ne'

theorem log_gibbs (β : ℝ) (H : Fin n → ℝ) (i : Fin n) :
    Real.log (gibbs β H i) = -β * H i - Real.log (partition β H) := by
  simp only [gibbs]
  rw [Real.log_div (Real.exp_pos _).ne' (partition_pos β H).ne', Real.log_exp]

/-! ### The Gibbs inequality (finite KL nonnegativity) -/

omit [NeZero n] in
/-- Per-state bound: ρᵢ (log σᵢ − log ρᵢ) ≤ σᵢ − ρᵢ, including the
ρᵢ = 0 boundary. -/
private theorem term_le {ρ σ : Fin n → ℝ} (hρ : ∀ i, 0 ≤ ρ i)
    (hσ : ∀ i, 0 < σ i) (i : Fin n) :
    ρ i * Real.log (σ i) - ρ i * Real.log (ρ i) ≤ σ i - ρ i := by
  rcases eq_or_lt_of_le (hρ i) with h0 | hpos
  · simpa [← h0] using (hσ i).le
  · have hlog := Real.log_le_sub_one_of_pos (div_pos (hσ i) hpos)
    rw [Real.log_div (hσ i).ne' hpos.ne'] at hlog
    have h := mul_le_mul_of_nonneg_left hlog hpos.le
    calc ρ i * Real.log (σ i) - ρ i * Real.log (ρ i)
        = ρ i * (Real.log (σ i) - Real.log (ρ i)) := by ring
      _ ≤ ρ i * (σ i / ρ i - 1) := h
      _ = σ i - ρ i := by field_simp

omit [NeZero n] in
/-- **Gibbs' inequality**: against any positive density σ, the
cross-entropy dominates the entropy. -/
theorem gibbs_inequality {ρ σ : Fin n → ℝ} (hρ : IsDensity ρ)
    (hσpos : ∀ i, 0 < σ i) (hσ : ∑ i, σ i = 1) :
    ∑ i, ρ i * Real.log (σ i) ≤ ∑ i, ρ i * Real.log (ρ i) := by
  have h := Finset.sum_le_sum
    (fun i (_ : i ∈ Finset.univ) => term_le hρ.nonneg hσpos i)
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, hσ, hρ.sum_one] at h
  linarith

omit [NeZero n] in
/-- Strict Gibbs' inequality: any deviation from σ is detected. -/
theorem gibbs_inequality_strict {ρ σ : Fin n → ℝ} (hρ : IsDensity ρ)
    (hσpos : ∀ i, 0 < σ i) (hσ : ∑ i, σ i = 1) (hne : ρ ≠ σ) :
    ∑ i, ρ i * Real.log (σ i) < ∑ i, ρ i * Real.log (ρ i) := by
  obtain ⟨j, hj⟩ := Function.ne_iff.mp hne
  have hstrict : ρ j * Real.log (σ j) - ρ j * Real.log (ρ j) < σ j - ρ j := by
    rcases eq_or_lt_of_le (hρ.nonneg j) with h0 | hpos
    · simpa [← h0] using hσpos j
    · have hne1 : σ j / ρ j ≠ 1 := by
        intro h
        rw [div_eq_iff hpos.ne', one_mul] at h
        exact hj h.symm
      have hlog := Real.log_lt_sub_one_of_pos (div_pos (hσpos j) hpos) hne1
      rw [Real.log_div (hσpos j).ne' hpos.ne'] at hlog
      have h := mul_lt_mul_of_pos_left hlog hpos
      calc ρ j * Real.log (σ j) - ρ j * Real.log (ρ j)
          = ρ j * (Real.log (σ j) - Real.log (ρ j)) := by ring
        _ < ρ j * (σ j / ρ j - 1) := h
        _ = σ j - ρ j := by field_simp
  have h := Finset.sum_lt_sum
    (fun i (_ : i ∈ Finset.univ) => term_le hρ.nonneg hσpos i)
    ⟨j, Finset.mem_univ j, hstrict⟩
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, hσ, hρ.sum_one] at h
  linarith

/-! ### Entropy bounds (finiteness, made quantitative) -/

omit [NeZero n] in
/-- Entropy is nonnegative on densities
(lemma:bk2_finiteness_of_symbolic_entropy, lower half). -/
theorem entropy_nonneg {ρ : Fin n → ℝ} (hρ : IsDensity ρ) : 0 ≤ entropy ρ := by
  unfold entropy
  rw [neg_nonneg]
  apply Finset.sum_nonpos
  intro i _
  have hle : ρ i ≤ 1 := by
    have := Finset.single_le_sum (fun j (_ : j ∈ Finset.univ) => hρ.nonneg j)
      (Finset.mem_univ i)
    linarith [hρ.sum_one]
  exact mul_nonpos_of_nonneg_of_nonpos (hρ.nonneg i)
    (Real.log_nonpos (hρ.nonneg i) hle)

/-- Entropy is at most log n: the uniform bound
(lemma:bk2_finiteness_of_symbolic_entropy, upper half). -/
theorem entropy_le_log_card {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    entropy ρ ≤ Real.log n := by
  have hn : (0 : ℝ) < n := by
    exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne n)
  have huni : ∑ _i : Fin n, (n : ℝ)⁻¹ = 1 := by
    simp [Finset.sum_const, Finset.card_univ]
  have h := gibbs_inequality hρ (fun _ => inv_pos.mpr hn) huni
  have hleft : ∑ i, ρ i * Real.log ((n : ℝ)⁻¹) = -Real.log n := by
    rw [← Finset.sum_mul, hρ.sum_one, one_mul, Real.log_inv]
  rw [hleft] at h
  unfold entropy
  linarith

/-! ### The variational principle -/

/-- The KL decomposition of the free energy: F_β[ρ] splits into a
relative-entropy term against the Gibbs state plus the equilibrium
value −β⁻¹ log Z. -/
theorem freeEnergy_eq_kl {β : ℝ} (hβ : β ≠ 0) (H : Fin n → ℝ)
    {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    freeEnergy β H ρ =
      β⁻¹ * ((∑ i, ρ i * Real.log (ρ i)) - ∑ i, ρ i * Real.log (gibbs β H i))
        - β⁻¹ * Real.log (partition β H) := by
  have hterm : ∀ i, ρ i * Real.log (gibbs β H i)
      = -β * (ρ i * H i) - Real.log (partition β H) * ρ i := by
    intro i; rw [log_gibbs]; ring
  have hcross : ∑ i, ρ i * Real.log (gibbs β H i)
      = -β * (∑ i, ρ i * H i) - Real.log (partition β H) := by
    rw [Finset.sum_congr rfl fun i _ => hterm i, Finset.sum_sub_distrib,
        ← Finset.mul_sum, ← Finset.mul_sum, hρ.sum_one, mul_one]
  rw [hcross]
  unfold freeEnergy entropy
  field_simp
  ring

/-- **Equilibrium free energy** = −β⁻¹ log Z: the value the variational
principle pins (theorem:bk2_h_theorem_for_symbolic_evol, endpoint). -/
theorem freeEnergy_gibbs {β : ℝ} (hβ : β ≠ 0) (H : Fin n → ℝ) :
    freeEnergy β H (gibbs β H) = -β⁻¹ * Real.log (partition β H) := by
  rw [freeEnergy_eq_kl hβ H (gibbs_isDensity β H)]
  ring

/-- **The Gibbs variational principle**
(theorem:bk2_equilibrium_distribution, variational form): the Gibbs
state minimizes the free energy over all densities. -/
theorem gibbs_minimizes {β : ℝ} (hβ : 0 < β) (H : Fin n → ℝ)
    {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    freeEnergy β H (gibbs β H) ≤ freeEnergy β H ρ := by
  rw [freeEnergy_gibbs hβ.ne' H, freeEnergy_eq_kl hβ.ne' H hρ]
  have hkl := gibbs_inequality hρ (gibbs_pos β H) (gibbs_isDensity β H).sum_one
  have hpos : 0 ≤ β⁻¹ * ((∑ i, ρ i * Real.log (ρ i))
      - ∑ i, ρ i * Real.log (gibbs β H i)) :=
    mul_nonneg (inv_pos.mpr hβ).le (by linarith)
  linarith

/-- **Uniqueness of the equilibrium**: any other density pays strictly
more free energy (theorem:bk2_equilibrium_distribution, uniqueness;
theorem:bk2_h_theorem_for_symbolic_evol, equality-iff kernel). -/
theorem gibbs_unique_minimizer {β : ℝ} (hβ : 0 < β) (H : Fin n → ℝ)
    {ρ : Fin n → ℝ} (hρ : IsDensity ρ) (hne : ρ ≠ gibbs β H) :
    freeEnergy β H (gibbs β H) < freeEnergy β H ρ := by
  rw [freeEnergy_gibbs hβ.ne' H, freeEnergy_eq_kl hβ.ne' H hρ]
  have hkl := gibbs_inequality_strict hρ (gibbs_pos β H)
    (gibbs_isDensity β H).sum_one hne
  have hpos : 0 < β⁻¹ * ((∑ i, ρ i * Real.log (ρ i))
      - ∑ i, ρ i * Real.log (gibbs β H i)) :=
    mul_pos (inv_pos.mpr hβ) (by linarith)
  linarith

/-! ### Stochastic evolution: conservation and detailed balance -/

/-- Row-stochastic evolution kernel: the finite skeleton of
axiom:bk2_symbolic_fokker_planck_equation. -/
def IsStochastic (P : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  (∀ i j, 0 ≤ P i j) ∧ ∀ i, ∑ j, P i j = 1

/-- One evolution step of a density under the kernel. -/
def evolve (P : Matrix (Fin n) (Fin n) ℝ) (ρ : Fin n → ℝ) : Fin n → ℝ :=
  fun j => ∑ i, ρ i * P i j

omit [NeZero n] in
/-- **Conservation of probability**
(lemma:bk2_conservation_of_probability, finite form). -/
theorem evolve_conserves {P : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsStochastic P) (ρ : Fin n → ℝ) :
    ∑ j, evolve P ρ j = ∑ i, ρ i := by
  unfold evolve
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => by
    rw [← Finset.mul_sum, hP.2 i, mul_one]

omit [NeZero n] in
/-- Evolution preserves density-hood. -/
theorem evolve_isDensity {P : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsStochastic P) {ρ : Fin n → ℝ} (hρ : IsDensity ρ) :
    IsDensity (evolve P ρ) where
  nonneg j := Finset.sum_nonneg fun i _ =>
    mul_nonneg (hρ.nonneg i) (hP.1 i j)
  sum_one := by rw [evolve_conserves hP, hρ.sum_one]

/-- Reversibility with respect to a distribution: the finite shadow of
the gradient condition D = −∇_g H
(axiom:bk2_gradient_structure_drift, ξ = 0 case). -/
def DetailedBalance (P : Matrix (Fin n) (Fin n) ℝ) (μ : Fin n → ℝ) : Prop :=
  ∀ i j, μ i * P i j = μ j * P j i

omit [NeZero n] in
/-- **Detailed balance forces stationarity**: every reversible kernel
has its balancing distribution as a fixed point
(theorem:bk2_equilibrium_distribution, stationarity half). -/
theorem detailedBalance_stationary {P : Matrix (Fin n) (Fin n) ℝ}
    {μ : Fin n → ℝ} (hP : IsStochastic P) (hdb : DetailedBalance P μ) :
    evolve P μ = μ := by
  funext j
  unfold evolve
  calc ∑ i, μ i * P i j = ∑ i, μ j * P j i :=
        Finset.sum_congr rfl fun i _ => hdb i j
    _ = μ j * ∑ i, P j i := by rw [Finset.mul_sum]
    _ = μ j := by rw [hP.2 j, mul_one]

/-- **The solenoidal witness** (axiom:bk2_gradient_structure_drift,
ξ ≠ 0 exhibited): the 3-cycle is stationary for the uniform density but
violates detailed balance — stationarity does NOT imply reversibility,
which is exactly the non-conservative component the axiom names. -/
theorem cycle_stationary_not_reversible :
    ∃ (P : Matrix (Fin 3) (Fin 3) ℝ) (μ : Fin 3 → ℝ),
      IsStochastic P ∧ IsDensity μ ∧ evolve P μ = μ ∧
        ¬ DetailedBalance P μ := by
  refine ⟨fun i j => if j = i + 1 then 1 else 0, fun _ => 3⁻¹,
    ⟨fun i j => ?_, fun i => ?_⟩,
    ⟨fun _ => by norm_num, by norm_num [Fin.sum_univ_three]⟩, ?_, ?_⟩
  · dsimp only
    split <;> norm_num
  · fin_cases i <;> simp +decide [Fin.sum_univ_three]
  · funext j
    unfold evolve
    fin_cases j <;> simp +decide [Fin.sum_univ_three]
  · intro h
    have h01 := h 0 1
    simp +decide at h01

/-! ### No finite phase transition, and the energy identity -/

omit [NeZero n] in
theorem partition_hasDerivAt (β : ℝ) (H : Fin n → ℝ) :
    HasDerivAt (fun b => partition b H)
      (∑ i, Real.exp (-β * H i) * (-H i)) β := by
  unfold partition
  have h2 : (fun b => ∑ i, Real.exp (-b * H i))
      = ∑ i : Fin n, fun b => Real.exp (-b * H i) := by
    funext b
    rw [Finset.sum_apply]
  rw [h2]
  refine HasDerivAt.sum fun i _ => ?_
  have h1 : HasDerivAt (fun b : ℝ => -b * H i) (-H i) β := by
    simpa using (hasDerivAt_id β).neg.mul_const (H i)
  exact h1.exp

/-- **No phase transition at finite alphabet**
(definition:bk2_symbolic_phase_transitio /
theorem:bk2_classification_symb_phase_transitions, negative-space
kernel): the free energy f(β) = −β⁻¹ log Z(β) is differentiable at
every β > 0, so the non-analyticity that DEFINES a symbolic phase
transition requires an infinite system. -/
theorem no_finite_phase_transition (H : Fin n → ℝ) {β : ℝ} (hβ : 0 < β) :
    DifferentiableAt ℝ (fun b => -Real.log (partition b H) / b) β := by
  have hZ := (partition_hasDerivAt β H).differentiableAt
  exact ((hZ.log (partition_pos β H).ne').neg).div differentiableAt_id hβ.ne'

/-- **The energy identity** (definition:bk2_symbolic_energy, bridge
form): the Gibbs mean energy is the negative β-derivative of log Z —
the derivative the symbolic-temperature definition
(definition:bk2_symbolic_temperature) differentiates. -/
theorem energy_eq_neg_deriv_log_partition (β : ℝ) (H : Fin n → ℝ) :
    HasDerivAt (fun b => -Real.log (partition b H))
      (∑ i, H i * gibbs β H i) β := by
  have h := ((partition_hasDerivAt β H).log (partition_pos β H).ne').neg
  have h3 : ∑ i, Real.exp (-β * H i) * (-H i)
      = -∑ i, H i * Real.exp (-β * H i) := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  have key : ∑ i, H i * gibbs β H i
      = -((∑ i, Real.exp (-β * H i) * (-H i)) / partition β H) := by
    simp only [gibbs, ← mul_div_assoc]
    rw [← Finset.sum_div, h3, neg_div, neg_neg]
  rw [key]
  exact h

end

end ForcingAnalysis.Book2
