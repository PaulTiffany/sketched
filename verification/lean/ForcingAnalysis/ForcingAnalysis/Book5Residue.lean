/-
Book5Residue.lean — the honest-kernel remainder of Principia Symbolica Book 5
after two extraction passes (see Book5.lean for the constants core).

Scope, stated honestly: covenant/resilience threshold laws reduce to scalar
iff-forms on ℝ; the MAD/MAP/MAS spectral trichotomy reduces to the
discriminant classification of a real quadratic (with the golden closure
matrix of Book5 as the concrete MAP witness); ESS/invasion-barrier claims
reduce to an explicit ε-neighbourhood threshold construction; metabolic
capacity claims reduce to finite-time depletion and a logarithmic recursion-
depth bound; strategy-space fitness dominance reduces to a finite weighted-
sum strict-inequality lemma; the ℓp-fracture material reduces to finite
Fin n vector-norm inequalities. Genuinely operator-space, PDE/Wasserstein,
probabilistic-limit, and irrational-approximation (continued-fraction)
content is NOT certified here and stays open; see the ledger in the sprint
proposal for the anchor-by-anchor accounting.

Sources: Principia atlas, Book 5 residue packet (r3-book5_packet.md).
-/

import Mathlib
import ForcingAnalysis.Book5

namespace ForcingAnalysis.Book5Residue

open Filter
open scoped goldenRatio

/-! ### Covenant resilience and coupling-stability threshold laws
(definition:bk5_covenant_resilience_index, definition:bk5_reflective_coupling_stab,
definition:bk5_symbolic_bifurcation_man, theorem:bk5_reflective_stability_criterion,
axiom:bk5_covenant_transitivity) -/

/-- The covenant resilience index `ρ(C_AB) = (Ω · λmin) / (‖dA‖ + ‖dB‖)`
(definition:bk5_covenant_resilience_index). -/
noncomputable def resilienceIndex (Ω lambdaMin dAmax dBmax : ℝ) : ℝ :=
  (Ω * lambdaMin) / (dAmax + dBmax)

/-- **Resilience threshold, iff-form**: a covenant is resilient (index > 1)
exactly when the reflective restoring term exceeds the combined maximal
drift load. -/
theorem resilience_gt_one_iff {Ω lambdaMin dAmax dBmax : ℝ}
    (hpos : 0 < dAmax + dBmax) :
    1 < resilienceIndex Ω lambdaMin dAmax dBmax ↔ dAmax + dBmax < Ω * lambdaMin := by
  unfold resilienceIndex
  rw [lt_div_iff₀ hpos, one_mul]

/-- The reflective coupling stability parameter
`Λ_AB = (‖R_AB‖ · Ω_AB) / ((‖dA‖+‖dB‖) · T_s)`
(definition:bk5_reflective_coupling_stab). -/
noncomputable def couplingStability (normR Omega dAmax dBmax Ts : ℝ) : ℝ :=
  (normR * Omega) / ((dAmax + dBmax) * Ts)

/-- **Coupling-stability threshold, iff-form.** -/
theorem coupling_stability_gt_one_iff {normR Omega dAmax dBmax Ts : ℝ}
    (hpos : 0 < (dAmax + dBmax) * Ts) :
    1 < couplingStability normR Omega dAmax dBmax Ts ↔
      (dAmax + dBmax) * Ts < normR * Omega := by
  unfold couplingStability
  rw [lt_div_iff₀ hpos, one_mul]

/-- **The symbolic bifurcation manifold, iff-form**
(definition:bk5_symbolic_bifurcation_man): the codimension-one boundary
`Λ_AB = 1` is exactly where the coupling term balances the drift-temperature
load. -/
theorem bifurcation_eq_one_iff {normR Omega dAmax dBmax Ts : ℝ}
    (hne : (dAmax + dBmax) * Ts ≠ 0) :
    couplingStability normR Omega dAmax dBmax Ts = 1 ↔
      normR * Omega = (dAmax + dBmax) * Ts := by
  unfold couplingStability
  rw [div_eq_one_iff_eq hne]

/-- **Reflective stability criterion, min-splits-to-conjunction**
(theorem:bk5_reflective_stability_criterion): the criterion
`ρ(C)/T_s < min(ηA/‖dA‖, ηB/‖dB‖)` is exactly the conjunction of the two
per-membrane bounds. -/
theorem reflective_stability_iff (rhoC Ts etaA dA etaB dB : ℝ) :
    rhoC / Ts < min (etaA / dA) (etaB / dB) ↔
      rhoC / Ts < etaA / dA ∧ rhoC / Ts < etaB / dB :=
  lt_min_iff

/-- **Covenant transitivity propagates resilience**
(axiom:bk5_covenant_transitivity): if both legs meet a resilience floor `θ`
and the transitive loss `Δ_trans` is small enough, the derived covenant
still clears a (possibly lower) floor `θ'`. -/
theorem covenant_transitivity_propagates {a b Δ θ θ' : ℝ}
    (ha : θ ≤ a) (hb : θ ≤ b) (_hΔ0 : 0 ≤ Δ) (hΔ : Δ ≤ θ - θ') :
    θ' ≤ min a b - Δ := by
  have hmin : θ ≤ min a b := le_min ha hb
  linarith

/-! ### MAD–MAP–MAS spectral trichotomy via the discriminant
(definition:bk5_map_mad_mas_band, theorem:bk5_map_mad_mas_trichotomy,
proposition:bk5_multi_agent_map_mad_classification) -/

/-- If the discriminant `T² - 4D` of `x² - Tx + D` is nonnegative, the
"plus" root is a genuine root: the real (MAP/MAS-side) case of the
MAD–MAP–MAS spectral split. -/
theorem quadratic_real_root_pos {T D : ℝ} (hΔ : 0 ≤ T ^ 2 - 4 * D) :
    ((T + Real.sqrt (T ^ 2 - 4 * D)) / 2) ^ 2 -
        T * ((T + Real.sqrt (T ^ 2 - 4 * D)) / 2) + D = 0 := by
  have hsq : Real.sqrt (T ^ 2 - 4 * D) ^ 2 = T ^ 2 - 4 * D := Real.sq_sqrt hΔ
  nlinarith [hsq]

/-- The "minus" root, same hypothesis. -/
theorem quadratic_real_root_neg {T D : ℝ} (hΔ : 0 ≤ T ^ 2 - 4 * D) :
    ((T - Real.sqrt (T ^ 2 - 4 * D)) / 2) ^ 2 -
        T * ((T - Real.sqrt (T ^ 2 - 4 * D)) / 2) + D = 0 := by
  have hsq : Real.sqrt (T ^ 2 - 4 * D) ^ 2 = T ^ 2 - 4 * D := Real.sq_sqrt hΔ
  nlinarith [hsq]

/-- If the discriminant is negative, `x² - Tx + D` has no real root: the
MAD (rotational / complex-spectrum) case. -/
theorem quadratic_no_real_root_of_disc_neg {T D : ℝ} (hΔ : T ^ 2 - 4 * D < 0)
    (x : ℝ) : x ^ 2 - T * x + D ≠ 0 := by
  intro h
  nlinarith [sq_nonneg (x - T / 2), hΔ, h]

/-- **The MAP witness, concretely**: Book 5's balanced two-step closure
matrix (trace `1`, determinant `-1`) has strictly positive discriminant, so
it sits on the real (non-MAD) side of the trichotomy — consistent with its
dominant eigenvalue being the real number `φ`
(cf. `ForcingAnalysis.closureMatrix_eigen_gold`). -/
theorem closureMatrix_disc_pos : (0 : ℝ) < (1 : ℝ) ^ 2 - 4 * (-1) := by norm_num

/-- **Covenant adjacency classification is an exhaustive trichotomy**
(proposition:bk5_multi_agent_map_mad_classification): given `Λ ≠ 1` and
`Ω ≠ 0`, exactly the MAP / MAD / Decoupled cases are possible, and they
exhaust the parameter space. -/
theorem covenant_adjacency_trichotomy {Λ Ω : ℝ} (hΛ : Λ ≠ 1) (hΩ : Ω ≠ 0) :
    (1 < Λ ∧ 0 < Ω) ∨ (1 < Λ ∧ Ω < 0) ∨ Λ < 1 := by
  rcases lt_or_gt_of_ne hΛ with h | h
  · exact Or.inr (Or.inr h)
  · rcases lt_or_gt_of_ne hΩ with h' | h'
    · exact Or.inr (Or.inl ⟨h, h'⟩)
    · exact Or.inl ⟨h, h'⟩

/-- The three adjacency cases are pairwise exclusive. -/
theorem covenant_adjacency_exclusive {Λ Ω : ℝ} :
    ¬ ((1 < Λ ∧ 0 < Ω) ∧ (1 < Λ ∧ Ω < 0)) ∧
      ¬ ((1 < Λ ∧ 0 < Ω) ∧ Λ < 1) ∧
      ¬ ((1 < Λ ∧ Ω < 0) ∧ Λ < 1) := by
  refine ⟨?_, ?_, ?_⟩
  · rintro ⟨⟨h1, h2⟩, ⟨h3, h4⟩⟩; linarith
  · rintro ⟨⟨h1, h2⟩, h3⟩; linarith
  · rintro ⟨⟨h1, h2⟩, h3⟩; linarith

/-- **Network lift, the combinatorial step**
(lemma:bk5_multi_membrane_map_extension): if the minimum resilience index
across a finite nonempty index set of edges exceeds `1`, then every single
edge's resilience index exceeds `1`. -/
theorem min_resilience_implies_all_edges_resilient {ι : Type*} [Fintype ι]
    (rho : ι → ℝ) {i : ι} (h : 1 < Finset.univ.inf' ⟨i, Finset.mem_univ i⟩ rho) :
    1 < rho i :=
  lt_of_lt_of_le h (Finset.inf'_le rho (Finset.mem_univ i))

/-! ### Golden ratio: thermodynamic optimum and a rescaled ratio limit
(proposition:bk5_golden_ratio_thermodynamic_optimum,
theorem:bk5_golden_ratio_curvature_scalar) -/

/-- **φ is a global minimizer** of the balanced free-energy Lyapunov term
`F_bal(r) = F0 + α(log r - log φ)²`. -/
theorem golden_ratio_thermodynamic_min {F0 α r : ℝ} (hα : 0 ≤ α) :
    F0 ≤ F0 + α * (Real.log r - Real.log φ) ^ 2 := by
  nlinarith [sq_nonneg (Real.log r - Real.log φ),
    mul_nonneg hα (sq_nonneg (Real.log r - Real.log φ))]

/-- **φ is the unique minimizer** among positive ratios `r`. -/
theorem golden_ratio_thermodynamic_optimum_iff {F0 α r : ℝ} (hα : 0 < α)
    (hr : 0 < r) :
    F0 + α * (Real.log r - Real.log φ) ^ 2 = F0 ↔
      r = φ := by
  have hφpos : 0 < φ := by linarith [Real.one_lt_goldenRatio]
  constructor
  · intro h
    have hsq : (Real.log r - Real.log φ) ^ 2 = 0 := by
      have hz : α * (Real.log r - Real.log φ) ^ 2 = 0 := by linarith
      exact (mul_eq_zero.mp hz).resolve_left hα.ne'
    have hlog : Real.log r = Real.log φ := by
      have h0 := sq_eq_zero_iff.mp hsq
      linarith
    exact Real.log_injOn_pos (Set.mem_Ioi.mpr hr) (Set.mem_Ioi.mpr hφpos) hlog
  · intro h; subst h; simp

/-- **The scale-resonance ratio limit, constant-rescaled case**
(theorem:bk5_golden_ratio_curvature_scalar): for any nonzero constant
rescaling `c` of Book 5's balanced two-step memory sequence, the induced
holonomy/curvature amplitude ratio still converges to `φ`. -/
theorem balanced_memory_tendsto_gold_scaled {c : ℝ} (hc : c ≠ 0) :
    Tendsto (fun n => (c * Nat.fib (n + 1) : ℝ) / (c * Nat.fib n)) atTop
      (nhds φ) := by
  have heq : (fun n => (c * Nat.fib (n + 1) : ℝ) / (c * Nat.fib n)) =
      fun n => (Nat.fib (n + 1) : ℝ) / (Nat.fib n : ℝ) := by
    funext n
    rw [mul_div_mul_left _ _ hc]
  rw [heq]
  exact ForcingAnalysis.balanced_memory_tendsto_gold

/-! ### Finite ℓp-fracture: compression ratios and curvature control
(definition:bk5_symbolic_compression_experiment,
definition:bk5_symbolic_curvature_control,
definition:bk5_symbolic_integrability_class) -/

/-- **Perfect ℓ1 compression** (`R_1 = 1`): the ℓ1-encoding of a nonzero
transition against itself is unit ratio. -/
theorem compression_ratio_R1 {n : ℕ} (v : Fin n → ℝ) (h : ∑ i, |v i| ≠ 0) :
    (∑ i, |v i|) / (∑ i, |v i|) = 1 :=
  div_self h

/-- **Minimal ℓ2 fracture** (`R_2 = √2`), re-exposing Book 5's diagonal
fracture ratio. -/
theorem compression_ratio_R2 : (2 : ℝ) / Real.sqrt 2 = Real.sqrt 2 :=
  ForcingAnalysis.diag_fracture_ratio

/-- Helper: for nonnegative terms, the sum of squares is bounded by the
square of the sum. -/
theorem sum_sq_le_sq_sum {n : ℕ} (a : Fin n → ℝ) (ha : ∀ i, 0 ≤ a i) :
    ∑ i, a i ^ 2 ≤ (∑ i, a i) ^ 2 := by
  have hle : ∀ i : Fin n, a i ≤ ∑ j, a j := fun i =>
    Finset.single_le_sum (fun j _ => ha j) (Finset.mem_univ i)
  calc ∑ i, a i ^ 2 = ∑ i, a i * a i := by
        apply Finset.sum_congr rfl; intro i _; ring
    _ ≤ ∑ i, a i * (∑ j, a j) :=
        Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hle i) (ha i))
    _ = (∑ i, a i) * (∑ j, a j) := by rw [← Finset.sum_mul]
    _ = (∑ i, a i) ^ 2 := by ring

/-- **ℓ1 dominates ℓ2** on finite vectors: the axis-generated symbolic
length never undershoots the Euclidean geometric length. -/
theorem l1_ge_l2 {n : ℕ} (v : Fin n → ℝ) :
    Real.sqrt (∑ i, v i ^ 2) ≤ ∑ i, |v i| := by
  have hsq : ∑ i, v i ^ 2 ≤ (∑ i, |v i|) ^ 2 := by
    have h := sum_sq_le_sq_sum (fun i => |v i|) (fun i => abs_nonneg _)
    simpa [sq_abs] using h
  calc Real.sqrt (∑ i, v i ^ 2) ≤ Real.sqrt ((∑ i, |v i|) ^ 2) := Real.sqrt_le_sqrt hsq
    _ = abs (∑ i, |v i|) := Real.sqrt_sq_eq_abs _
    _ = ∑ i, |v i| := abs_of_nonneg (Finset.sum_nonneg fun i _ => abs_nonneg _)

/-- **The `p = 2` symbolic curvature control parameter is nonnegative**
(definition:bk5_symbolic_curvature_control): the extra axis-symbolic cost
of representing a Euclidean-shorter transition is never negative. -/
theorem curvature_control_p2_nonneg {n : ℕ} (v : Fin n → ℝ)
    (h : Real.sqrt (∑ i, v i ^ 2) ≠ 0) :
    0 ≤ (∑ i, |v i|) / Real.sqrt (∑ i, v i ^ 2) - 1 := by
  have hpos : 0 < Real.sqrt (∑ i, v i ^ 2) :=
    lt_of_le_of_ne (Real.sqrt_nonneg _) (Ne.symm h)
  have hge := l1_ge_l2 v
  have h1 : 1 ≤ (∑ i, |v i|) / Real.sqrt (∑ i, v i ^ 2) := by
    rw [le_div_iff₀ hpos, one_mul]; exact hge
  linarith

/-- **The `R_∞` compression ratio equals the support size**
(definition:bk5_symbolic_compression_experiment, `R_∞` case): for a
transition whose nonzero entries share a common magnitude `c`, the ℓ1
length is exactly `c` times the support size. -/
theorem l1_eq_card_mul_c {n : ℕ} {s : Finset (Fin n)} {c : ℝ} {v : Fin n → ℝ}
    (hin : ∀ i ∈ s, |v i| = c) (hout : ∀ i ∉ s, v i = 0) :
    ∑ i, |v i| = (s.card : ℝ) * c := by
  rw [← Finset.sum_add_sum_compl s (fun i => |v i|)]
  have h1 : ∑ i ∈ s, |v i| = ∑ _i ∈ s, c := Finset.sum_congr rfl hin
  have h2 : ∑ i ∈ sᶜ, |v i| = 0 := by
    apply Finset.sum_eq_zero
    intro i hi
    rw [Finset.mem_compl] at hi
    rw [hout i hi]; simp
  rw [h1, h2, Finset.sum_const, add_zero, nsmul_eq_mul]

/-! ### Metabolic capacity: finite-time depletion and recursion-depth bound
(proposition:bk5_fixed_metabolic_capacity, axiom:bk5_metabolically_bounded_reflection,
corollary:bk5__metabolically_bounded_reflection_corollary) -/

/-- **Fixed metabolic capacity forces finite-time exit from viability**
(proposition:bk5_fixed_metabolic_capacity): if a symbolic system's cost
overrun `excess` above its sustainable maximum is strictly positive, the
accumulated deficit goes negative in finite time. -/
theorem energy_depletes_in_finite_time {MC excess : ℝ} (_hMC : 0 ≤ MC)
    (hex : 0 < excess) : ∃ N : ℕ, MC - (N : ℝ) * excess < 0 := by
  obtain ⟨N, hN⟩ := exists_nat_gt (MC / excess)
  refine ⟨N, ?_⟩
  rw [div_lt_iff₀ hex] at hN
  linarith

/-- **Metabolically bounded reflection depth**
(corollary:bk5__metabolically_bounded_reflection_corollary): if the cost of
recursive reflection grows geometrically (`c0 · k^n`) and is capped by the
metabolic budget `B`, the depth `n` is bounded by a logarithm of the budget
ratio. -/
theorem max_recursive_depth_bound {k B c0 : ℝ} (hk : 1 < k) (hc0 : 0 < c0)
    {n : ℕ} (hn : c0 * k ^ n ≤ B) : (n : ℝ) ≤ Real.logb k (B / c0) := by
  have hlogk : 0 < Real.log k := Real.log_pos hk
  have hpow : k ^ n ≤ B / c0 := by rw [le_div_iff₀ hc0]; linarith
  have hlog : (n : ℝ) * Real.log k ≤ Real.log (B / c0) := by
    have h2 : Real.log (k ^ n) ≤ Real.log (B / c0) :=
      Real.log_le_log (by positivity) hpow
    rwa [Real.log_pow] at h2
  show (n : ℝ) ≤ Real.log (B / c0) / Real.log k
  rw [le_div_iff₀ hlogk]
  exact hlog

/-! ### Complexity–stability tradeoff (metabolic budget structure)
(definition:bk5_complexity_stability_maintenance,
theorem:bk5_complexity_stability_tradeoff,
corollary:bk5_complexity_stability_tradeoff) -/

/-- A metabolic budget packages operator complexity `C`, stability margin
`S`, metabolic capacity `MC`, and conversion constant `α` together with the
structural cost law `C · S ≤ α · MC`
(definition:bk5_complexity_stability_maintenance,
theorem:bk5_complexity_stability_tradeoff). -/
structure MetabolicBudget where
  C : ℝ
  S : ℝ
  MC : ℝ
  α : ℝ
  hC : 0 ≤ C
  hS : 0 ≤ S
  hMC : 0 ≤ MC
  hα : 0 < α
  law : C * S ≤ α * MC

/-- The admissible complexity, rearranged. -/
theorem MetabolicBudget.complexity_le (b : MetabolicBudget) (hSpos : 0 < b.S) :
    b.C ≤ b.α * b.MC / b.S := by
  rw [le_div_iff₀ hSpos]
  exact b.law

/-- **Higher metabolic capacity permits higher admissible complexity**
(corollary:bk5_complexity_stability_tradeoff), for fixed stability margin and
conversion constant. -/
theorem admissible_complexity_mono {α S : ℝ} (hα : 0 ≤ α) (hS : 0 < S)
    {MC1 MC2 : ℝ} (h : MC1 ≤ MC2) : α * MC1 / S ≤ α * MC2 / S := by
  have h1 : α * MC1 ≤ α * MC2 := mul_le_mul_of_nonneg_left h hα
  exact div_le_div_of_nonneg_right h1 hS.le

/-! ### Finite-population fitness dominance and ESS invasion thresholds
(lemma:bk5_map_fitness_advantage, lemma:bk5_covenant_non_invasibility,
definition:bk5_symbolic_ess, theorem:bk5_map_as_strong_ess,
definition:bk5_symbolic_invasion_barrier) -/

/-- **Finite weighted-population strict dominance**
(lemma:bk5_map_fitness_advantage, lemma:bk5_covenant_non_invasibility): if a
strategy strictly dominates another on every positively-weighted member of
a finite population, its population-average fitness is strictly higher. -/
theorem weighted_strict_dominance {ι : Type*} [Fintype ι] (w a b : ι → ℝ)
    (hw : ∀ i, 0 ≤ w i) (hdom : ∀ i, 0 < w i → a i < b i)
    (hex : ∃ i, 0 < w i) : ∑ i, w i * a i < ∑ i, w i * b i := by
  apply Finset.sum_lt_sum
  · intro i _
    rcases (hw i).lt_or_eq with h | h
    · exact le_of_lt (mul_lt_mul_of_pos_left (hdom i h) h)
    · simp [← h]
  · obtain ⟨i, hi⟩ := hex
    exact ⟨i, Finset.mem_univ i, mul_lt_mul_of_pos_left (hdom i hi) hi⟩

/-- **An ε-neighbourhood invasion-resistance threshold exists**
(definition:bk5_symbolic_ess, theorem:bk5_map_as_strong_ess,
definition:bk5_symbolic_invasion_barrier): if a strategy strictly beats an
alternative in self-interaction (`c < a`), there is a strictly positive
invasion barrier `ε0` below which the resident strategy still wins the
`(1-ε)`-mixture comparison, for any bounded cross-payoffs `b, d`. -/
theorem ess_invasion_threshold {a b c d : ℝ} (hac : c < a) :
    ∃ ε0 : ℝ, 0 < ε0 ∧ ∀ ε ∈ Set.Ioo (0 : ℝ) ε0,
      (1 - ε) * c + ε * d < (1 - ε) * a + ε * b := by
  set k : ℝ := (b - d) - (a - c) with hk
  refine ⟨(a - c) / (|k| + 1), div_pos (by linarith) (by positivity), ?_⟩
  intro ε hε
  obtain ⟨hε1, hε2⟩ := hε
  have hcalc : ε * |k| < a - c := by
    have step1 : ε * |k| ≤ ε * (|k| + 1) := by nlinarith [abs_nonneg k]
    have step2 : ε * (|k| + 1) < (a - c) / (|k| + 1) * (|k| + 1) :=
      mul_lt_mul_of_pos_right hε2 (by positivity)
    have step3 : (a - c) / (|k| + 1) * (|k| + 1) = a - c := by
      field_simp
    linarith
  have hklow : -(ε * |k|) ≤ ε * k := by nlinarith [neg_abs_le k]
  have hident : (1 - ε) * a + ε * b - ((1 - ε) * c + ε * d) = (a - c) + ε * k := by
    rw [hk]; ring
  linarith

/-! ### Asymptotic regime exclusivity for divergence bounds
(lemma:bk5_symbolic_divergence_bounds) -/

/-- **The MAP and MAD divergence bounds are eventually incompatible**
(lemma:bk5_symbolic_divergence_bounds): a logarithmic upper bound (the MAP
regime's prediction) and a steeper linear lower bound (the MAD regime's
prediction) cannot both hold for large `n` once the linear rate exceeds the
logarithmic one — the two asymptotic regimes are mutually exclusive in the
long run. -/
theorem map_mad_bounds_eventually_incompatible {K1 K2 K3 : ℝ} (hK1 : 0 < K1)
    (hK12 : K1 < K2) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → K1 * Real.log ((n : ℝ) + 1) < K2 * (n : ℝ) - K3 := by
  obtain ⟨N, hN⟩ := exists_nat_gt (K3 / (K2 - K1))
  refine ⟨N, fun n hn => ?_⟩
  have hnR : (N : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hlog : Real.log ((n : ℝ) + 1) ≤ (n : ℝ) := by
    have h1 := Real.log_le_sub_one_of_pos (x := (n : ℝ) + 1) (by positivity)
    linarith
  have hpos : 0 < K2 - K1 := by linarith
  have hgap : K3 < (K2 - K1) * (n : ℝ) := by
    have hlt : K3 / (K2 - K1) < (N : ℝ) := hN
    rw [div_lt_iff₀ hpos] at hlt
    nlinarith [hlt, hnR, hpos]
  have hK1log : K1 * Real.log ((n : ℝ) + 1) ≤ K1 * (n : ℝ) :=
    mul_le_mul_of_nonneg_left hlog hK1.le
  linarith

/-! ### Viability domain monotone chain
(axiom:bk5_mutual_metabolit_viability, proposition:bk5_viability_domain_preservation) -/

/-- **Viability-union monotonicity chains over any horizon**
(axiom:bk5_mutual_metabolit_viability, proposition:bk5_viability_domain_preservation):
if the joint viability union is non-decreasing at every step, it is
non-decreasing between any two comparable times, not just consecutive ones. -/
theorem viability_union_mono_chain {α : Type*} {VA VB : ℕ → Set α}
    (hstep : ∀ n, VA n ∪ VB n ⊆ VA (n + 1) ∪ VB (n + 1)) {m n : ℕ} (hmn : m ≤ n) :
    VA m ∪ VB m ⊆ VA n ∪ VB n := by
  induction n, hmn using Nat.le_induction with
  | base => exact Set.Subset.refl _
  | succ n _ ih => exact ih.trans (hstep n)

end ForcingAnalysis.Book5Residue
