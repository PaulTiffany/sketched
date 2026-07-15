/-
Book4C.lean - Principia Book 4 unmapped remainder (first half): perception
covenants, modal geometry, observer-induced metrics, honest kernel.

Book 4's remainder is heavy on symbolic-manifold, Riemannian-metric,
Hilbert-space, and mutual-information machinery (identity carriers on a
manifold with a measure, observer kernels as convolution operators, Ricci
curvature of a symbolic metric, hierarchical auto-encoders scored by mutual
information, fiber bundles of recursive identity, homology/persistence of
the TTIE envelope, stochastic TTCS sampling). None of that heavy machinery
is modeled directly. For each anchor this file extracts the honest
algebraic/order/finite/limit kernel instead, using the FracturedAtlas
chart-complex substrate exactly where the source's proof only ever compares
distances across an assumed "the metric g":

  * "identity resolution" `R_n` and its "eventually exceeds 1" enhancement
    criterion become one ratio-threshold algebra (`1 < a/b ↔ b < a`) plus a
    monotone-sequence persistence lemma -- once a monotone resolution
    sequence clears the threshold at some depth it never falls back;
  * the SR-Initialization triplet's boundedness proposition becomes the
    honest convex-combination fact underneath it: a weighted average of
    `[0,1]`-valued readings with nonnegative weights summing to `1` is
    itself in `[0,1]`;
  * the SRMF-Constrained Action Norm lemma becomes the abstract normed-space
    triangle/homogeneity bound on a linear combination of three
    budget-bounded generators, dropping the Lie-algebra exponential map
    (only the stated linear bound, not its exp-derivation, is modeled);
  * the "Imagination Bridges the Wheel" reintegration threshold
    `beta * |gap| < theta` becomes a genuine monotonicity fact: shrinking
    the phase gap preserves reintegrability;
  * "Symbolic Identity Continuity" becomes the honest analytic content of a
    bounded-velocity path: a Lipschitz curve is uniformly continuous, with
    an explicit `delta` witness;
  * the curvature-bounded TTIE expansion-rate lemma and its symbolic
    light-cone corollary become, respectively, the algebraic fact that the
    stated rate bound never exceeds the coherence speed `c_s`, and the
    monotonicity of the light-cone radius in time;
  * the TTIE "let M be a symbolic manifold equipped with the observer-
    induced metric g_O" presupposition is re-read against
    `ForcingAnalysis.Atlas`: the metric g_O it needs exists exactly when the
    underlying chart complex is glued (`consistent_of_glued`), and can
    provably fail to exist at all on the FracturedAtlas dual-horizon
    example -- TTIE's own opening hypothesis is non-vacuous;
  * the TTCS stability/coherence-preservation pair (expected curvature
    bounded near the seed, expected coherence at least `gamma`) becomes the
    discrete finite-sample average-is-squeezed-by-its-bounds fact, in both
    directions;
  * "Neighborhood Completeness" becomes the honest metric-space fact a
    closed subset of a complete space inherits: completeness of the
    coherence neighborhood is kept as the hypothesis "it is closed" rather
    than derived from the coherence/drift constraints, which are not
    modeled;
  * "Symbolic Work" and its path-dependence proposition become an explicit
    two-path numerical countermodel (discretized work differs by
    discretization for a non-constant force) paired with the degenerate
    case where a constant force *is* path-independent -- the honest
    boundary of the claim;
  * the Fragmentation Measure `1 - I/H` becomes the bounded-ratio fact
    `frag ∈ [0,1]` from `0 ≤ I ≤ H`, plus the equality case;
  * the Symbolic Identity Carrier's normalization condition
    `sum Psi_i = 1` (discretized from the integral) forces every component
    to lie in `[0,1]`;
  * the Reflexive Operator's stated `O(lambda)` approximation property
    becomes a genuine squeeze-theorem convergence: `R_lambda(s) -> s` as
    `lambda -> 0`.

Anchors that are purely narrative/taxonomic (symbolic emergence, order
parameters, the membrane coupling axiom, emergence criterion, differentiation
boundaries, proto-symbolic spaces, bounded observers as abstract TVS triples,
meta-stability, the information-bottleneck arg-min, hierarchical
auto-encoding, emergent abstraction's mutual-information inequality,
individuation paths as gradient flows, the recursive identity/spinor bundle,
identity collapse and test-time differentiation collapse -- both entangled
with an unformalized recursive-divergence limit and free-energy singularity
-- test-time precision refinement and its interpretability/stability lemmas
-- all depending on an axiom (refinement contraction) not present in this
packet), require genuine Riemannian curvature (the two symbolic-curvature
formulations, the coherence metric via the inverse metric tensor), require
homology/spectral-sequence/persistence-diagram machinery (homological
extension, its spectral stability, topological persistence under refinement,
homological coherence bounds), require measure-theoretic convolution or
stochastic process machinery (the observer-kernel convolution, TTCS's
stochastic operator and its weak-* convergence theorem, bounded
accessibility's existential neighborhood), or are pure narrative synthesis of
already-covered material (symbolic link activation, the paradoxical arrow of
time, TTCS's three-bullet properties list) are left unformalized and listed
as open anchors in the accompanying proposal, rather than forced into
decorative theorems.
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas

namespace ForcingAnalysis.Book4C

/- ================================================================
   definition:bk4_identity_resolution, theorem:bk4_recursive_identity_enhancem
   ================================================================ -/

/-- The ratio-threshold algebra underlying the identity-resolution formula
`R_n = I(M_i;M_i^(n)) / I(M_i;M_i^(1))` (definition:bk4_identity_resolution):
the ratio clears `1` exactly when the numerator clears the denominator. -/
theorem identityResolution_gt_one_iff (a b : ℝ) (hb : 0 < b) :
    1 < a / b ↔ b < a := by
  rw [lt_div_iff₀ hb, one_mul]

/-- theorem:bk4_recursive_identity_enhancem's persistence half: once a
monotone resolution sequence `R` clears the threshold `1` at some critical
depth `n_c`, it stays above `1` at every deeper level -- the honest
discrete kernel of "`R_n > 1` for all `n ≥ n_c`", dropping the mutual-
information "additional contextual information" characterization of *why*
`R` is monotone. -/
theorem identityResolution_threshold_persists (R : ℕ → ℝ) (hmono : Monotone R)
    (n_c : ℕ) (hnc : 1 < R n_c) :
    ∀ n, n_c ≤ n → 1 < R n :=
  fun _ hn => lt_of_lt_of_le hnc (hmono hn)

/- ================================================================
   definition:bk4_sr_initialization_map, proposition:bk4_bounded_sr_initial_state
   ================================================================ -/

/-- The honest convex-combination fact underneath the Bounded SR-Initial
State proposition: each of `I_0, M_0, C_0` is a `w`-weighted integral of a
`[0,1]`-valued observer-kernel reading, discretized here to a finite
weighted sum. A weighted average of `[0,1]`-valued readings with
nonnegative weights summing to `1` stays in `[0,1]`. -/
theorem convexCombination_mem_Icc {n : ℕ} (w x : Fin n → ℝ)
    (hw_nonneg : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1)
    (hx : ∀ i, x i ∈ Set.Icc (0 : ℝ) 1) :
    (∑ i, w i * x i) ∈ Set.Icc (0 : ℝ) 1 := by
  constructor
  · exact Finset.sum_nonneg fun i _ => mul_nonneg (hw_nonneg i) (hx i).1
  · calc ∑ i, w i * x i ≤ ∑ i, w i * 1 :=
          Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hx i).2 (hw_nonneg i)
      _ = ∑ i, w i := by simp
      _ = 1 := hw_sum

/- ================================================================
   lemma:bk4_srmf_constrained_action_norm
   ================================================================ -/

/-- The SRMF-Constrained Action Norm bound, kept abstractly: for three
budget-bounded generators in any real normed space, the norm of their
linear combination is controlled by the budget `B` and the coefficient
sizes. The Lie-algebra exponential map `Lambda_O` itself is not modeled;
only its stated linear consequence is. -/
theorem srmfActionNorm_bound {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {x y z : E} {B a b c : ℝ} (hx : ‖x‖ ≤ B) (hy : ‖y‖ ≤ B) (hz : ‖z‖ ≤ B) :
    ‖a • x + b • y + c • z‖ ≤ B * (|a| + |b| + |c|) := by
  have h1a : ‖a • x + b • y‖ ≤ ‖a • x‖ + ‖b • y‖ := norm_add_le _ _
  have h1b : ‖a • x + b • y + c • z‖ ≤ ‖a • x + b • y‖ + ‖c • z‖ := norm_add_le _ _
  have h1 : ‖a • x + b • y + c • z‖ ≤ ‖a • x‖ + ‖b • y‖ + ‖c • z‖ := by linarith
  have h2 : ‖a • x‖ = |a| * ‖x‖ := by rw [norm_smul, Real.norm_eq_abs]
  have h3 : ‖b • y‖ = |b| * ‖y‖ := by rw [norm_smul, Real.norm_eq_abs]
  have h4 : ‖c • z‖ = |c| * ‖z‖ := by rw [norm_smul, Real.norm_eq_abs]
  rw [h2, h3, h4] at h1
  have hxa : |a| * ‖x‖ ≤ |a| * B := mul_le_mul_of_nonneg_left hx (abs_nonneg a)
  have hyb : |b| * ‖y‖ ≤ |b| * B := mul_le_mul_of_nonneg_left hy (abs_nonneg b)
  have hzc : |c| * ‖z‖ ≤ |c| * B := mul_le_mul_of_nonneg_left hz (abs_nonneg c)
  have hring : B * (|a| + |b| + |c|) = |a| * B + |b| * B + |c| * B := by ring
  rw [hring]
  linarith

/- ================================================================
   proposition:bk4_imagination_bridges_wheel
   ================================================================ -/

/-- The reintegration threshold from proposition:bk4_imagination_bridges_wheel:
the accrued imaginary distance across a phase gap stays within tolerance. -/
def Reintegrable (beta theta gap : ℝ) : Prop := beta * |gap| < theta

/-- Shrinking the phase gap preserves reintegrability -- the honest
monotonicity content of "the destination mode is reintegrable ... iff the
accrued imaginary distance stays within tolerance". -/
theorem reintegrable_of_smaller_gap {beta theta gap gap' : ℝ} (hbeta : 0 ≤ beta)
    (h : Reintegrable beta theta gap) (hle : |gap'| ≤ |gap|) :
    Reintegrable beta theta gap' := by
  unfold Reintegrable at h ⊢
  calc beta * |gap'| ≤ beta * |gap| := mul_le_mul_of_nonneg_left hle hbeta
    _ < theta := h

/- ================================================================
   theorem:bk4_symbolic_identity_continuit
   ================================================================ -/

/-- A path with a budget on its per-step displacement (bounded free energy
and drift variance, discretized to a global Lipschitz bound `K`): the
honest analytic content of "individuation path" that Symbolic Identity
Continuity actually uses. -/
structure LipschitzPath (S : Type*) [PseudoMetricSpace S] where
  gamma : ℝ → S
  K : ℝ
  K_pos : 0 < K
  lipschitz : ∀ s t, dist (gamma s) (gamma t) ≤ K * |s - t|

/-- theorem:bk4_symbolic_identity_continuit: a Lipschitz path is uniformly
continuous, with an explicit witness `delta` in terms of the Lipschitz
constant. -/
theorem lipschitzPath_uniform {S : Type*} [PseudoMetricSpace S] (L : LipschitzPath S)
    {eps : ℝ} (heps : 0 < eps) :
    ∃ delta, 0 < delta ∧ ∀ t : ℝ, dist (L.gamma (t + delta)) (L.gamma t) < eps := by
  have hK2 : (0 : ℝ) < 2 * L.K := by linarith [L.K_pos]
  have hdelta_pos : 0 < eps / (2 * L.K) := div_pos heps hK2
  refine ⟨eps / (2 * L.K), hdelta_pos, fun t => ?_⟩
  have hbound := L.lipschitz (t + eps / (2 * L.K)) t
  have hsub : t + eps / (2 * L.K) - t = eps / (2 * L.K) := by ring
  have habs : |t + eps / (2 * L.K) - t| = eps / (2 * L.K) := by
    rw [hsub]; exact abs_of_pos hdelta_pos
  rw [habs] at hbound
  have hK0 : L.K ≠ 0 := L.K_pos.ne'
  have heq : L.K * (eps / (2 * L.K)) = eps / 2 := by field_simp
  rw [heq] at hbound
  linarith

/- ================================================================
   lemma:bk4_ttie_expansion_rate, corollary:bk4_symbolic_lightcone
   ================================================================ -/

/-- The curvature-bounded expansion-rate data of lemma:bk4_ttie_expansion_rate. -/
structure TTIEExpansionBound where
  vExp : ℝ
  cs : ℝ
  cs_nonneg : 0 ≤ cs
  kappa : ℝ
  delta : ℝ
  rate_bound : vExp ≤ cs / Real.sqrt (1 + kappa ^ 2 * delta ^ 2)

/-- The stated expansion rate never exceeds the coherence speed `c_s`
itself: the curvature/resolution correction factor only ever shrinks the
bound. -/
theorem ttieExpansionBound_le_cs (b : TTIEExpansionBound) : b.vExp ≤ b.cs := by
  have hprod : 0 ≤ b.kappa ^ 2 * b.delta ^ 2 := mul_nonneg (sq_nonneg b.kappa) (sq_nonneg b.delta)
  have h1 : (1 : ℝ) ≤ 1 + b.kappa ^ 2 * b.delta ^ 2 := by linarith
  have h2 : (1 : ℝ) ≤ Real.sqrt (1 + b.kappa ^ 2 * b.delta ^ 2) := by
    have h3 := Real.sqrt_le_sqrt h1
    rwa [Real.sqrt_one] at h3
  exact le_trans b.rate_bound (div_le_self b.cs_nonneg h2)

/-- corollary:bk4_symbolic_lightcone's monotonicity content: the coherence
cone's admissible distance grows with elapsed time, for a nonnegative
coherence speed. -/
theorem coherenceCone_mono {cs d t1 t2 : ℝ} (hcs : 0 ≤ cs) (ht : t1 ≤ t2)
    (hd : d ≤ cs * t1) : d ≤ cs * t2 :=
  le_trans hd (mul_le_mul_of_nonneg_left ht hcs)

/- ================================================================
   definition:bk4_test_time_integrative_expansion (the "let M be a symbolic
   manifold equipped with the observer-induced metric g_O" opening
   presupposition, re-read against ForcingAnalysis.Atlas)
   ================================================================ -/

/-- TTIE's opening presupposition, discharged in the positive case: a
glued, pair-covering chart complex does carry the single observer-induced
metric `g_O` that TTIE's Coherence Constraint (C1) is stated relative to --
exactly `Atlas.consistent_of_glued`, named here for the anchor it
discharges. -/
theorem ttieMetric_exists_of_glued {X : Type*} {C : ForcingAnalysis.Atlas.ChartComplex X}
    (hGlued : ForcingAnalysis.Atlas.Glued C) (hCov : ForcingAnalysis.Atlas.PairCovers C) :
    ∃ D : X → X → ℝ, ForcingAnalysis.Atlas.Consistent C D :=
  ForcingAnalysis.Atlas.consistent_of_glued hGlued hCov

/-- TTIE's opening presupposition is non-vacuous in the negative direction:
on the FracturedAtlas dual-horizon example, no single observer-induced
metric `g_O` exists at all, for any positive resolution floor -- TTIE
cannot even be stated there before any expansion step is taken. -/
theorem ttieMetric_presupposition_fails_on_dual_horizon {ε : ℝ} (hε : 0 < ε) :
    ¬ ∃ D : ℝ → ℝ → ℝ, ForcingAnalysis.Atlas.Consistent (ForcingAnalysis.Atlas.dualHorizon ε) D :=
  ForcingAnalysis.Atlas.no_single_geometry_for_dual_horizon hε

/- ================================================================
   lemma:bk4_ttcs_stability, corollary:bk4_coherence_preservation
   ================================================================ -/

/-- The discrete finite-sample kernel of lemma:bk4_ttcs_stability: if every
sampled reading is at most `M`, the sample average is at most `M`. -/
theorem ttcs_sample_average_le {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) (M : ℝ)
    (h : ∀ i, f i ≤ M) :
    (∑ i, f i) / (n : ℝ) ≤ M := by
  have hsum : ∑ i : Fin n, f i ≤ ∑ _i : Fin n, M := Finset.sum_le_sum fun i _ => h i
  have hconst : (∑ _i : Fin n, M) = (n : ℝ) * M := by
    simp [Finset.sum_const, Finset.card_univ, mul_comm]
  rw [hconst] at hsum
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [div_le_iff₀ hn']
  linarith

/-- The dual, corridor-preservation direction (corollary:bk4_coherence_preservation):
if every sampled reading is at least `gamma`, the sample average is at
least `gamma`. -/
theorem ttcs_sample_average_ge {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) (gamma : ℝ)
    (h : ∀ i, gamma ≤ f i) :
    gamma ≤ (∑ i, f i) / (n : ℝ) := by
  have hsum : ∑ _i : Fin n, gamma ≤ ∑ i : Fin n, f i := Finset.sum_le_sum fun i _ => h i
  have hconst : (∑ _i : Fin n, gamma) = (n : ℝ) * gamma := by
    simp [Finset.sum_const, Finset.card_univ, mul_comm]
  rw [hconst] at hsum
  have hn' : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  rw [le_div_iff₀ hn']
  linarith

/-- The unnormalized finite TTCS sampling weight associated with symbolic
free energy `F` and positive inverse temperature `β`. -/
noncomputable def ttcsWeight (β F : ℝ) : ℝ := Real.exp (-β * F)

/-- TTCS strictly prefers lower symbolic free energy: at positive inverse
temperature, a lower-energy state receives strictly greater weight. -/
theorem ttcsWeight_strictAnti {β Flow Fhigh : ℝ} (hβ : 0 < β)
    (hF : Flow < Fhigh) : ttcsWeight β Fhigh < ttcsWeight β Flow := by
  unfold ttcsWeight
  apply Real.exp_lt_exp.mpr
  nlinarith

/-- A finite TTCS candidate carries both constraints stated in Book 4:
coherence above `γ` and observer distance from the initial state at most
`ε`. -/
structure TTCSAdmissibleSample (X : Type*) [PseudoMetricSpace X]
    (s0 : X) (γ ε : ℝ) where
  state : X
  coherence : ℝ
  freeEnergy : ℝ
  coherent : γ ≤ coherence
  observer_bounded : dist state s0 ≤ ε

/-- **lemma:bk4_properties_of_ttcs**, finite operational kernel: among two
admissible candidates, lower free energy is strictly preferred, while the
chosen candidate retains both its coherence floor and observer leash. -/
theorem ttcs_properties {X : Type*} [PseudoMetricSpace X]
    {s0 : X} {γ ε β : ℝ} (hβ : 0 < β)
    (low high : TTCSAdmissibleSample X s0 γ ε)
    (henergy : low.freeEnergy < high.freeEnergy) :
    ttcsWeight β high.freeEnergy < ttcsWeight β low.freeEnergy ∧
      γ ≤ low.coherence ∧ dist low.state s0 ≤ ε :=
  ⟨ttcsWeight_strictAnti hβ henergy, low.coherent, low.observer_bounded⟩

/-- The empirical evaluation of an observable along the first `N` TTCS
samples. This is the scalar test-function face of empirical weak-* measure
convergence. -/
noncomputable def ttcsEmpiricalObservableAverage {X : Type*}
    (sample : ℕ → X) (observable : X → ℝ) (N : ℕ) : ℝ :=
  (∑ i ∈ Finset.range N, observable (sample i)) / (N : ℝ)

/-- A TTCS sampler concentrated at one state has exactly its Dirac
observable evaluation at every positive empirical sample size. -/
theorem ttcsEmpiricalObservableAverage_const {X : Type*}
    (x : X) (observable : X → ℝ) {N : ℕ} (hN : 0 < N) :
    ttcsEmpiricalObservableAverage (fun _ => x) observable N = observable x := by
  simp [ttcsEmpiricalObservableAverage, hN.ne']

/-- **theorem:bk4_ttcs_convergence**, deterministic Dirac specialization:
the empirical observable evaluations of a sampler concentrated at one
admissible state converge to that state's Dirac evaluation. -/
theorem ttcs_const_empirical_tendsto {X : Type*}
    (x : X) (observable : X → ℝ) :
    Filter.Tendsto
      (fun N => ttcsEmpiricalObservableAverage (fun _ => x) observable N)
      Filter.atTop (nhds (observable x)) := by
  apply tendsto_const_nhds.congr'
  filter_upwards [Filter.eventually_ge_atTop 1] with N hN
  symm
  exact ttcsEmpiricalObservableAverage_const x observable (by omega)

/-- The observer-relative cloud activated by a finite TTCS sample family. -/
def ttcsActivatedCloud {X : Type*} [PseudoMetricSpace X]
    {n : ℕ} {s0 : X} {γ ε : ℝ}
    (sample : Fin n → TTCSAdmissibleSample X s0 γ ε) : Set X :=
  Set.range (fun i => (sample i).state)

/-- Every indexed sample is present in the activated TTCS cloud. -/
theorem mem_ttcsActivatedCloud {X : Type*} [PseudoMetricSpace X]
    {n : ℕ} {s0 : X} {γ ε : ℝ}
    (sample : Fin n → TTCSAdmissibleSample X s0 γ ε) (i : Fin n) :
    (sample i).state ∈ ttcsActivatedCloud sample :=
  ⟨i, rfl⟩

/-- **theorem:bk4_symbolic_link_activation**, finite operational kernel:
a nonempty indexed TTCS family activates a nonempty state cloud; lower
energy is strictly preferred; and every activated sample retains coherence
and observer anchoring. -/
theorem ttcs_link_activation {X : Type*} [PseudoMetricSpace X]
    {n : ℕ} [Nonempty (Fin n)] {s0 : X} {γ ε β : ℝ} (hβ : 0 < β)
    (sample : Fin n → TTCSAdmissibleSample X s0 γ ε) (low high : Fin n)
    (henergy : (sample low).freeEnergy < (sample high).freeEnergy) :
    (ttcsActivatedCloud sample).Nonempty ∧
      ttcsWeight β (sample high).freeEnergy <
        ttcsWeight β (sample low).freeEnergy ∧
      ∀ i, γ ≤ (sample i).coherence ∧ dist (sample i).state s0 ≤ ε := by
  let i0 : Fin n := Classical.choice inferInstance
  refine ⟨⟨(sample i0).state, mem_ttcsActivatedCloud sample i0⟩,
    ttcsWeight_strictAnti hβ henergy, ?_⟩
  intro i
  exact ⟨(sample i).coherent, (sample i).observer_bounded⟩

/- ================================================================
   proposition:bk4_neighborhood_completeness
   ================================================================ -/

/-- proposition:bk4_neighborhood_completeness's honest metric-space
content: a closed subset of a complete space is itself complete. The
coherence/drift constraints defining the neighborhood are not modeled;
closedness is kept as a named hypothesis exactly where the source's proof
would consume it. -/
theorem neighborhoodCompleteness {X : Type*} [PseudoMetricSpace X] [CompleteSpace X]
    {S : Set X} (hS : IsClosed S) : IsComplete S :=
  hS.isComplete

/- ================================================================
   definition:bk4_symbolic_work_functional, proposition:bk4_symbolic_work_path_dependence
   ================================================================ -/

/-- Discretized symbolic work along a two-point path (definition:bk4_symbolic_work_functional). -/
def work2 (F : ℝ → ℝ) (a b : ℝ) : ℝ := F a * (b - a)

/-- Discretized symbolic work along a three-point path. -/
def work3 (F : ℝ → ℝ) (a b c : ℝ) : ℝ := F a * (b - a) + F b * (c - b)

/-- proposition:bk4_symbolic_work_path_dependence's punchline, as an explicit
countermodel: for a non-constant force, two discretizations of the same
start/end refinement trajectory can disagree. -/
theorem symbolicWork_path_dependent_example :
    work3 id 0 1 2 ≠ work2 id 0 2 := by
  norm_num [work2, work3]

/-- The honest boundary of the claim: for a constant force, work *is*
path-independent -- the degenerate case dropped by "in general" in the
source proposition. -/
theorem symbolicWork_path_independent_of_constant (k a b c : ℝ) :
    work3 (fun _ => k) a b c = work2 (fun _ => k) a c := by
  simp only [work2, work3]
  ring

/- ================================================================
   definition:bk4_fragmentation_measure
   ================================================================ -/

/-- The mutual-information/entropy data underlying the Fragmentation
Measure (definition:bk4_fragmentation_measure), kept as named hypotheses:
mutual information is nonnegative and bounded above by entropy (the
data-processing content of "optimal partition"), and entropy is positive. -/
structure FragmentationMeasure where
  mutInfo : ℝ
  entropy : ℝ
  entropy_pos : 0 < entropy
  mutInfo_nonneg : 0 ≤ mutInfo
  mutInfo_le_entropy : mutInfo ≤ entropy

/-- The fragmentation measure `1 - I/H`. -/
noncomputable def fragMeasure (f : FragmentationMeasure) : ℝ := 1 - f.mutInfo / f.entropy

/-- The fragmentation measure always lies in `[0,1]`. -/
theorem fragMeasure_mem_Icc (f : FragmentationMeasure) :
    fragMeasure f ∈ Set.Icc (0 : ℝ) 1 := by
  have hle : f.mutInfo / f.entropy ≤ 1 := by
    rw [div_le_one₀ f.entropy_pos]
    exact f.mutInfo_le_entropy
  have hge : 0 ≤ f.mutInfo / f.entropy := div_nonneg f.mutInfo_nonneg f.entropy_pos.le
  unfold fragMeasure
  constructor <;> linarith

/-- The fragmentation measure vanishes exactly when the partition captures
all of the membrane's information (`I = H`). -/
theorem fragMeasure_eq_zero_iff (f : FragmentationMeasure) :
    fragMeasure f = 0 ↔ f.mutInfo = f.entropy := by
  unfold fragMeasure
  rw [sub_eq_zero, eq_comm]
  exact div_eq_one_iff_eq f.entropy_pos.ne'

/- ================================================================
   definition:bk4_symbolic_identity_carrie
   ================================================================ -/

/-- The normalization condition of the Symbolic Identity Carrier
(`integral over M_i of Psi_i = 1`), discretized to a finite sum: it forces
every component reading to lie in `[0,1]`. -/
theorem symbolicIdentityCarrier_component_le_one {n : ℕ} (Psi : Fin n → ℝ)
    (hnonneg : ∀ i, 0 ≤ Psi i) (hsum : ∑ i, Psi i = 1) (j : Fin n) :
    Psi j ≤ 1 := by
  have h := Finset.single_le_sum (f := Psi) (fun i _ => hnonneg i) (Finset.mem_univ j)
  rwa [hsum] at h

/- ================================================================
   definition:bk4_reflexive_operator
   ================================================================ -/

/-- A reflexive-operator family with the stated `O(lambda)` approximation
budget (definition:bk4_reflexive_operator, Approximation Property): the
Coherence-Preservation and Temporal-Consistency clauses are not modeled,
only the displacement budget the Approximation Property imposes. -/
structure ReflexiveOperatorFamily (S : Type*) [PseudoMetricSpace S] where
  R : ℝ → S → S
  C : ℝ
  C_nonneg : 0 ≤ C
  approx : ∀ (lam : ℝ) (s : S), dist (R lam s) s ≤ C * |lam|

/-- The honest analytic payoff of "`‖R_lambda(s) - s‖ = O(lambda)`": as
`lambda -> 0`, the reflexive operator converges to the identity, by a
squeeze between `0` and the vanishing budget `C * |lambda|`. -/
theorem reflexiveOperator_tendsto_self {S : Type*} [PseudoMetricSpace S]
    (F : ReflexiveOperatorFamily S) (s : S) :
    Filter.Tendsto (fun lam => dist (F.R lam s) s) (nhds 0) (nhds 0) := by
  have habs : Filter.Tendsto (fun lam : ℝ => |lam|) (nhds 0) (nhds 0) := by
    simpa using continuous_abs.tendsto (0 : ℝ)
  have hupper : Filter.Tendsto (fun lam : ℝ => F.C * |lam|) (nhds 0) (nhds 0) := by
    simpa using habs.const_mul F.C
  have hlower : Filter.Tendsto (fun _ : ℝ => (0 : ℝ)) (nhds 0) (nhds 0) := tendsto_const_nhds
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le hlower hupper
    (fun lam => dist_nonneg) (fun lam => F.approx lam s)

end ForcingAnalysis.Book4C
