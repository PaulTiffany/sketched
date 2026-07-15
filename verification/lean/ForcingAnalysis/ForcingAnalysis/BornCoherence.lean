/-
BornCoherence.lean — the observer coherence functional and its Born-rule
covariance kernel (appendix C / dual-horizon cluster).

Sources (Principia appendix C, verbatim; sha-bound in bindings.json):

  theorem:appC_born_rule — the coherence functional on a rank-one
    question Π_a = |a⟩⟨a| is the Born value |⟨a|ψ⟩|².
  axiom:appC_psc2 (Unitary covariance) — C(Uψ, UΠU†) = C(ψ, Π).
  axiom:appC_psc4 (Ray invariance) — C(e^{iθ}ψ, Π) = C(ψ, Π).
  axiom:appC_psc6 (Pure-state calibration) — C(ψ, P_ψ) = 1 for ‖ψ‖=1.
  lemma:appC_unitary_invariance — μ_{Uψ}(UΠU†) = μ_ψ(Π).
  corollary:appC_qubit_case — the qubit Born value |⟨a|ψ⟩|².
  corollary:appC_mixed_states — affine under classical mixtures.

Honest scope, load-bearing: the DEEP content of theorem:appC_born_rule
is GLEASON-TYPE UNIQUENESS — that axioms PS-C1..C6 in dimension d ≥ 3
FORCE the trace form. That uniqueness is NOT proved here and stays a
counsel-permanent open (it needs the Gleason/Busch theorem, outside the
finite-kernel discipline). What IS certified: taking the coherence
functional to BE the Born form C(a,ψ) = ‖⟪a,ψ⟫‖², every covariance and
calibration axiom PS-C2/C4/C6 and the unitary-invariance lemma is a
THEOREM about that functional (the axioms are consistent, the Born form
realizes them), with the amplitude-squared reading made concrete on the
qubit and the mixed-state affinity shown for classical mixtures. The
forward direction Born ⇒ axioms is the finite half; the reverse
axioms ⇒ Born (Gleason) is not modeled. PS-C5 (resolution-limited
distinguishability, needing Bessel's inequality) also stays open.
-/

import Mathlib

namespace ForcingAnalysis.Born

open scoped InnerProductSpace ComplexConjugate

variable {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]

/-- The observer coherence functional on a rank-one question |a⟩⟨a|:
the Born value C_O(ψ, Π_a) = |⟨a|ψ⟩|². Taken as the definition; Gleason
uniqueness (axioms ⇒ this form) is the open half. -/
noncomputable def coh (a ψ : H) : ℝ := ‖(⟪a, ψ⟫_ℂ)‖ ^ 2

theorem coh_nonneg (a ψ : H) : 0 ≤ coh a ψ := by
  unfold coh; positivity

/-- **PS-C6, Pure-state calibration**: a normalized state answers its
own question with full coherence, C(ψ, P_ψ) = 1. -/
theorem psc6_calibration {ψ : H} (hψ : ‖ψ‖ = 1) : coh ψ ψ = 1 := by
  unfold coh
  rw [inner_self_eq_norm_sq_to_K (𝕜 := ℂ)]
  simp [hψ]

/-- **PS-C4, Ray invariance**: multiplying the state by a phase e^{iθ}
does not change any coherence value. -/
theorem psc4_ray_invariance (a ψ : H) (θ : ℝ) :
    coh a (Complex.exp (θ * Complex.I) • ψ) = coh a ψ := by
  unfold coh
  rw [inner_smul_right, norm_mul]
  have hphase : ‖Complex.exp (θ * Complex.I)‖ = 1 := by
    rw [Complex.norm_exp]; simp
  rw [hphase, one_mul]

/-- **PS-C2 / lemma:appC_unitary_invariance, Unitary covariance**:
transporting both the state and the question by a unitary U leaves the
coherence unchanged, C(Ua, Uψ) = C(a, ψ). Unitaries are the linear
isometric equivalences of the Hilbert space. -/
theorem psc2_unitary_covariance (U : H ≃ₗᵢ[ℂ] H) (a ψ : H) :
    coh (U a) (U ψ) = coh a ψ := by
  unfold coh
  rw [U.inner_map_map]

/-- **The Born value is bounded by 1** on unit vectors (Cauchy–Schwarz):
no question is over-answered. -/
theorem coh_le_one {a ψ : H} (ha : ‖a‖ = 1) (hψ : ‖ψ‖ = 1) :
    coh a ψ ≤ 1 := by
  unfold coh
  have hcs : ‖(⟪a, ψ⟫_ℂ)‖ ≤ ‖a‖ * ‖ψ‖ := norm_inner_le_norm a ψ
  rw [ha, hψ, one_mul] at hcs
  nlinarith [norm_nonneg (⟪a, ψ⟫_ℂ)]

/-! ### The qubit Born value, concrete -/

/-- **corollary:appC_qubit_case**: on the qubit `ℂ²`, the coherence of
the state against the i-th computational-basis question is exactly the
squared amplitude |ψ_i|² — the Born rule, computed. -/
theorem qubit_born (ψ : EuclideanSpace ℂ (Fin 2)) (i : Fin 2) :
    coh (EuclideanSpace.single i (1 : ℂ)) ψ = ‖ψ i‖ ^ 2 := by
  unfold coh
  rw [EuclideanSpace.inner_single_left]
  simp

/-! ### Mixed states: affinity under classical mixtures -/

/-- The mixed coherence of a classical mixture ∑ pᵢ |ψᵢ⟩⟨ψᵢ| against the
question |a⟩⟨a|: tr(ρ Π_a) = ∑ pᵢ C(a, ψᵢ). -/
noncomputable def cohMix {n : ℕ} (a : H) (p : Fin n → ℝ) (ψ : Fin n → H) : ℝ :=
  ∑ i, p i * coh a (ψ i)

/-- **corollary:appC_mixed_states**: the mixed coherence is affine in
the mixing weights — the Born value extends from pure states to
classical mixtures by exactly the convex-combination rule. -/
theorem mixed_affine {n : ℕ} (a : H) (p q : Fin n → ℝ) (ψ : Fin n → H)
    (s t : ℝ) :
    cohMix a (fun i => s * p i + t * q i) ψ =
      s * cohMix a p ψ + t * cohMix a q ψ := by
  unfold cohMix
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  ring

/-- Mixed coherence is nonnegative for a genuine (nonnegative-weight)
mixture. -/
theorem cohMix_nonneg {n : ℕ} (a : H) {p : Fin n → ℝ} (ψ : Fin n → H)
    (hp : ∀ i, 0 ≤ p i) : 0 ≤ cohMix a p ψ :=
  Finset.sum_nonneg fun i _ => mul_nonneg (hp i) (coh_nonneg a (ψ i))

end ForcingAnalysis.Born
