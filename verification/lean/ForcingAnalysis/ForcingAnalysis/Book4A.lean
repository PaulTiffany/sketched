/-
Book4A.lean - Principia Book 4, first half (modal transference, the chromatic
wheel, symbolic covenants of perception), honest kernel.

Book 4's first half is stated on symbolic manifolds, observer-relative
Hilbert/Banach bundles, Riemannian coherence metrics, mutual-information
functionals between symbolic membranes, homological/spectral-sequence
apparatus for "test-time integrative expansion," and stochastic sampling
processes on manifolds ("test-time coherent sampling"). This module does NOT
attempt any of that: no manifolds, no curvature tensors, no general Hilbert/Banach bundle
geometry, and no measure theory beyond finite sums. The TTPR anchor does use
the standard Banach fixed-point theorem on a nonempty complete metric space. For each anchor it extracts the honest static/algebraic/finite/real
kernel instead:

  * "existence of symbolic identity" becomes the threshold algebra its
    stated inequality already contains: a stability bound strictly above a
    critical error threshold;
  * the "recursive identity encoding" distortion bound becomes a genuine
    fact about finite partial sums of a summable nonnegative real sequence;
  * the "operator algebra of identity" noncommutativity claim becomes an
    explicit two-function countermodel (functions on `Bool` that do not
    commute under composition), since noncommutativity is an existence
    claim, not a universal one;
  * the "self-reference operator" recursion `S_1 = R`, `S_n = R ∘ S_{n-1}`
    becomes literally `Function.iterate`; fixed points remain fixed at every
    finite stage, and under the later complete-metric contraction hypothesis
    every recursive self-reference sequence converges geometrically to the
    unique TTPR identity;
  * "formation of differentiation boundaries" becomes a genuine threshold
    dichotomy (`lt_or_ge`) rather than a one-sided implication;
  * "symbolic curvature" and its four basic properties become a concrete
    quadratic-form model `kappa K R lam s := K * (R lam s - s) ^ 2`: this is
    honestly degree-two in the symbolic argument (the source's own
    stipulation), so non-negativity, scale invariance by `alpha ^ 2`, and
    reflexive vanishing are genuine theorems, while "observer dependence"
    (stated as `in general`, not `always`) becomes an explicit two-kernel
    countermodel rather than a false universal inequality;
  * the symbolic transition rate is strictly positive; the richer symbolic
    auto-encoder has actual encoding/decoding maps, and its exponential
    pattern has weight one exactly at an exact reconstruction;
  * "emergence through timescale separation" becomes the transitivity of
    the three stated strict inequalities;
  * the auto-encoder reconstruction constraint gives the finite-sample sum
    bound; zero error budget forces exact decoding and makes the encoder
    injective, so identity cannot collapse in code space;
  * the "imaginary symbolic distance" pair `(d_Re, d_Im)` becomes a concrete
    complex number `d_Re + i d_Im`, with its real/imaginary parts and the
    standard `|Re z| <= |z|` bound as genuine facts;
  * the "Imaginative Continuity Principle" is modeled exactly as the
    conjunction of real and imaginary threshold conditions, with its
    biconditional, monotonicity under enlarged tolerances, exact failure
    disjunction, and an explicit uncanny-recognition countermodel;
  * the Event Horizon Wheel's four open quadrants (cut by the sign pair of
    `(Re, Im)` of the transported overlap) become genuine exhaustiveness and
    mutual-exclusivity theorems for the four sign classes on `ℝ x ℝ`;
  * the "spiral transition between modes" and the "Golden Event Horizon
    Spiral" become genuine per-step recurrence laws for magnitude and phase
    sequences, including the honest algebraic fact that a real number
    satisfying `phi^2 = phi + 1` (the golden ratio) forces the stated
    two-step Fibonacci-type recurrence on `phi^n * r0`; for nonzero initial
    radius, every consecutive-radius ratio is exactly `phi`, hence converges
    to it;
  * the "Curvature-Bounded Expansion Rate" bound survives to the extent
    that it needs to: this and the homological/spectral apparatus around it
    are left open (see below), since the curvature/manifold content itself
    is not modeled;
  * the "Refinement Contraction Axiom" becomes a genuine finite-iteration
    contraction bound: if `R` is `kappa`-Lipschitz with `kappa < 1`, then
    `dist (R^[n] s) (R^[n] s') <= kappa ^ n * dist s s'`, proved by
    induction; on a nonempty complete metric space, the same structure is
    bridged to Mathlib's contraction interface, yielding a unique fixed point
    and convergence of every refinement orbit to it;
  * "Drift-Reflection Imbalance" becomes the honest pointwise threshold
    consequence: if drift strictly exceeds `theta` times reflection with
    `theta > 1` and reflection is non-negative, drift strictly exceeds
    reflection;
  * the "Chromatic transference of the wheel" corollary is the flagship
    cyclic-structure anchor: the phase wheel is modeled concretely as
    `ZMod 12`, adjacency as differing by `+-1`, and diametric opposition as
    `+6`. Rotation (`+ c`) genuinely preserves adjacency and commutes with
    opposition, and opposition is a genuine involution -- but an explicit
    non-rotation bijection (a transposition of two elements) is exhibited
    that breaks adjacency on an adjacent pair, an honest countermodel for
    "not every relabeling is a modal transference, only the structured
    ones."

Anchors that are purely narrative/taxonomic (symbolic emergence, order
parameters, proto-symbolic space, bounded observers, the domain-by-domain
"interpretations" of symbolic curvature across math-ph/hep-th/quant-ph/
cond-mat/cs.LG, the observe/reflect narrative around TTCS), that require
mutual-information/entropy functionals with no finite model (identity
resolution and its recursive enhancement, symbolic emergence criterion,
emergent abstraction, fragmentation measure), that require genuinely
infinite-dimensional or asymptotic apparatus (Hilbert/Banach symbolic
bundles, Riemannian coherence metrics and Ricci curvature, homology/Betti
numbers and spectral sequences, weak-* convergence of empirical measures,
Cauchy-completeness of an abstract manifold, path-dependent work integrals),
or that are stated as the same claim under a different anchor with no
independent kernel are left unformalized and listed as open anchors in the
accompanying proposal.
-/

import Mathlib
import ForcingAnalysis.ScholiumA

namespace ForcingAnalysis.Book4A

/- ================================================================
   theorem:bk4_existence_of_symbolic_ident
   ================================================================ -/

/-- The threshold algebra underlying the existence criterion
(theorem:bk4_existence_of_symbolic_ident): if stability is bounded below by
`1 - eps`, and `eps` is strictly below a critical bound `epsCrit < 1`, then
stability is both strictly above `1 - epsCrit` and strictly positive. Only
this scalar consequence of the stated inequality is modeled; the existence
quantifier over time intervals `Delta T` and the membrane/stability-criteria
apparatus it depends on are not. -/
theorem stability_lower_bound (stability eps epsCrit : ℝ)
    (hstab : stability ≥ 1 - eps) (heps : eps < epsCrit) (hcrit : epsCrit < 1) :
    stability > 1 - epsCrit ∧ 0 < stability := by
  constructor
  · linarith
  · linarith

/- ================================================================
   definition:bk4_recursive_identity_encod,
   lemma:bk4_convergence_of_recursive_enco
   ================================================================ -/

/-- The distortion-accumulation bound of definition:bk4_recursive_identity_encod
(`d_g(...) <= sum_{k=1}^n eps_k`) is honestly a statement about finite
partial sums of the per-level distortions `eps`. Combined with summability,
every finite partial sum is bounded by the total sum. The metric encoding
model below additionally proves that summable successive distortions make
the hierarchy Cauchy and, in a complete space, produce a limiting
representation with distance controlled by the remaining distortion tail.
When levels arise by a continuous recursive refinement, that limit is also
proved refinement-fixed. -/
theorem recursive_encoding_partial_sum_le_total (eps : ℕ → ℝ)
    (heps_nonneg : ∀ k, 0 ≤ eps k) (hsummable : Summable eps) (n : ℕ) :
    ∑ k ∈ Finset.range n, eps k ≤ ∑' k, eps k :=
  hsummable.sum_le_tsum (Finset.range n) (fun k _ => heps_nonneg k)

/-- A recursive identity encoding in a symbolic metric space: each new level
moves by at most `eps n`, and the total distortion budget is summable. -/
structure RecursiveEncoding (S : Type) [PseudoMetricSpace S] where
  encoded : ℕ → S
  eps : ℕ → ℝ
  step_dist_le : ∀ n, dist (encoded n) (encoded (n + 1)) ≤ eps n
  summable_eps : Summable eps

/-- Scholium → Book 4: every summably controlled Scholium stage chain is a
Book 4 recursive identity encoding with the same states and distortion
budget. -/
def RecursiveEncoding.ofChainedApprox
    {S : Type} [PseudoMetricSpace S] (c : ScholiumA.ChainedApprox S) :
    RecursiveEncoding S where
  encoded := c.path
  eps := c.step
  step_dist_le := fun n => by
    simpa [dist_comm] using c.step_bound n
  summable_eps := c.summable_step

/-- Summable inter-level distortion makes the recursive encoding hierarchy
Cauchy. -/
theorem RecursiveEncoding.cauchySeq {S : Type} [PseudoMetricSpace S]
    (e : RecursiveEncoding S) : CauchySeq e.encoded := by
  apply cauchySeq_of_dist_le_of_summable e.eps
  · intro n
    simpa [Nat.succ_eq_add_one] using e.step_dist_le n
  · exact e.summable_eps

/-- On a complete symbolic metric space, a recursive encoding has a limiting
representation. Moreover, every finite level lies within the remaining
summable distortion tail of that representation. -/
theorem RecursiveEncoding.exists_limit_with_tail_bound
    {S : Type} [MetricSpace S] [CompleteSpace S] (e : RecursiveEncoding S) :
    ∃ limit : S,
      Filter.Tendsto e.encoded Filter.atTop (nhds limit) ∧
      ∀ n, dist (e.encoded n) limit ≤ ∑' m, e.eps (n + m) := by
  obtain ⟨limit, hlimit⟩ := cauchySeq_tendsto_of_complete e.cauchySeq
  refine ⟨limit, hlimit, ?_⟩
  intro n
  apply dist_le_tsum_of_dist_le_of_tendsto e.eps
  · intro k
    simpa [Nat.succ_eq_add_one] using e.step_dist_le k
  · exact e.summable_eps
  · exact hlimit

/-- Scholium → Book 4: a summably decaying stage chain in a complete metric
space yields an actual limiting Book 4 representation with the inherited
tail distortion bound. -/
theorem chainedApprox_yields_recursiveEncoding_limit
    {S : Type} [MetricSpace S] [CompleteSpace S]
    (c : ScholiumA.ChainedApprox S) :
    ∃ limit : S,
      Filter.Tendsto c.path Filter.atTop (nhds limit) ∧
      ∀ n, dist (c.path n) limit ≤ ∑' m, c.step (n + m) := by
  simpa [RecursiveEncoding.ofChainedApprox] using
    (RecursiveEncoding.ofChainedApprox c).exists_limit_with_tail_bound

/-- If each encoding level is obtained by applying a continuous refinement
operator to the preceding level, the limiting representation is genuinely
refinement-fixed. The tail distortion estimate is retained. -/
theorem RecursiveEncoding.exists_fixed_limit_with_tail_bound
    {S : Type} [MetricSpace S] [CompleteSpace S] (e : RecursiveEncoding S)
    (R : S → S) (hR : Continuous R)
    (hstep : ∀ n, e.encoded (n + 1) = R (e.encoded n)) :
    ∃ limit : S,
      Filter.Tendsto e.encoded Filter.atTop (nhds limit) ∧
      R limit = limit ∧
      ∀ n, dist (e.encoded n) limit ≤ ∑' m, e.eps (n + m) := by
  obtain ⟨limit, hlimit, htail⟩ := e.exists_limit_with_tail_bound
  have hRlimit : Filter.Tendsto (fun n => R (e.encoded n))
      Filter.atTop (nhds (R limit)) := (hR.tendsto limit).comp hlimit
  have hshift : Filter.Tendsto (fun n => e.encoded (n + 1))
      Filter.atTop (nhds limit) := hlimit.comp (Filter.tendsto_add_atTop_nat 1)
  have hRtoLimit : Filter.Tendsto (fun n => R (e.encoded n))
      Filter.atTop (nhds limit) := by
    apply hshift.congr'
    filter_upwards with n
    exact hstep n
  exact ⟨limit, hlimit, tendsto_nhds_unique hRlimit hRtoLimit, htail⟩

/- ================================================================
   definition:bk4_identity_operators, theorem:bk4_operator_algebra_of_identit
   ================================================================ -/

/-- theorem:bk4_operator_algebra_of_identit claims the identity operators
(definition:bk4_identity_operators) do not all commute. Non-commutativity is
an existence claim, not a universal one: this is an explicit witness on
`Bool` of two functions whose compositions differ in the two possible
orders, the honest kernel of "the identity operators form a non-commutative
algebra." -/
theorem operator_noncommutativity_witness :
    ∃ P R : Bool → Bool, P ∘ R ≠ R ∘ P := by
  refine ⟨fun _ => true, fun b => !b, ?_⟩
  intro h
  have h2 := congrFun h false
  simp at h2

/- ================================================================
   definition:bk4_self_reference_operator, theorem:bk4_fixed_points_of_self_refere
   ================================================================ -/

/-- The self-reference operator (definition:bk4_self_reference_operator),
`S_1 = R`, `S_n = R ∘ S_{n-1}` for `n >= 2`, is literally the iterate of
`R`: `S_n = R^[n]`. -/
def selfReferenceIterate (R : ℝ → ℝ) (n : ℕ) : ℝ → ℝ := R^[n]

/-- The defining recursion `S_{n+1} = R ∘ S_n`. -/
theorem selfReferenceIterate_succ (R : ℝ → ℝ) (n : ℕ) (x : ℝ) :
    selfReferenceIterate R (n + 1) x = R (selfReferenceIterate R n x) :=
  Function.iterate_succ_apply' R n x

/-- theorem:bk4_fixed_points_of_self_refere's finite kernel: a fixed point
of `R` is a fixed point of every iterate `S_n`, so the sequence `{S_n(I)}`
is exactly stationary there. The complete-metric contraction specialization
below adds the distortion bound, unique identity, and full convergence. -/
theorem selfReference_fixed_point (R : ℝ → ℝ) (x : ℝ) (hfix : R x = x) (n : ℕ) :
    selfReferenceIterate R n x = x :=
  Function.iterate_fixed hfix n

/- ================================================================
   theorem:bk4_formation_differentiation_boundaries
   ================================================================ -/

/-- Whether a differentiation boundary forms
(theorem:bk4_formation_differentiation_boundaries): the local symbolic
curvature divergence strictly exceeds the critical threshold. Only the
scalar comparison is modeled; the divergence operator and submanifold
structure of definition:bk4_differentiation_boundary are not. -/
def BoundaryForms (kappaSymb kappaCrit : ℝ) : Prop := kappaSymb > kappaCrit

/-- Exhaustive dichotomy: boundaries either form or they do not -- the
honest classification-by-threshold-comparison content, using `lt_or_ge`
rather than a one-sided implication. -/
theorem boundary_forms_dichotomy (kappaSymb kappaCrit : ℝ) :
    BoundaryForms kappaSymb kappaCrit ∨ kappaSymb ≤ kappaCrit := by
  rcases lt_or_ge kappaCrit kappaSymb with h | h
  · exact Or.inl h
  · exact Or.inr h

/- ================================================================
   definition:bk4_symbolic_curvature, theorem:bk4_symbolic_curvature_properties
   ================================================================ -/

/-- The residual `R_lam(s) - s` underlying symbolic curvature
(definition:bk4_symbolic_curvature): only this real-valued residual is
modeled, not the full second-order observer derivation `delta_O^2`. -/
def residual (R : ℝ → ℝ → ℝ) (lam s : ℝ) : ℝ := R lam s - s

/-- Symbolic curvature (definition:bk4_symbolic_curvature) as a concrete
quadratic form in the residual, scaled by a non-negative kernel-energy
constant `K`: honestly degree-two in the symbolic argument, matching the
definition's own stipulation ("curvature is the kernel energy ... not its
square root"). -/
def kappa (K : ℝ) (R : ℝ → ℝ → ℝ) (lam s : ℝ) : ℝ := K * residual R lam s ^ 2

/-- Non-negativity (theorem:bk4_symbolic_curvature_properties, clause 1). -/
theorem kappa_nonneg (K : ℝ) (hK : 0 ≤ K) (R : ℝ → ℝ → ℝ) (lam s : ℝ) :
    0 ≤ kappa K R lam s :=
  mul_nonneg hK (sq_nonneg _)

/-- Scale invariance by `alpha ^ 2` (theorem:bk4_symbolic_curvature_properties,
clause 3), given that the reflexive operator acts linearly on the scaled
argument. -/
theorem kappa_scale (K : ℝ) (R : ℝ → ℝ → ℝ)
    (hlin : ∀ lam s α : ℝ, R lam (α * s) = α * R lam s) (lam s α : ℝ) :
    kappa K R lam (α * s) = α ^ 2 * kappa K R lam s := by
  unfold kappa residual
  rw [hlin lam s α]
  ring

/-- Reflexive vanishing (theorem:bk4_symbolic_curvature_properties, clause
4): if `s` is already a fixed point of the reflexive operator, its curvature
is zero. -/
theorem kappa_reflexive_vanishing (K : ℝ) (R : ℝ → ℝ → ℝ) (lam s : ℝ)
    (h : R lam s = s) : kappa K R lam s = 0 := by
  unfold kappa residual
  rw [h]
  ring

/-- Observer dependence (theorem:bk4_symbolic_curvature_properties, clause
2) is stated `in general`, i.e. as an existence claim, not a false universal
inequality: an explicit witness with two different kernel-energy constants
assigning different curvature to the same residual. -/
theorem kappa_observer_dependent :
    ∃ (R : ℝ → ℝ → ℝ) (lam s : ℝ), kappa 1 R lam s ≠ kappa 2 R lam s := by
  refine ⟨fun _ s => s + 1, 0, 0, ?_⟩
  unfold kappa residual
  norm_num

/- ================================================================
   definition:bk4_symbolic_transition_rate, theorem:bk4_auto_encoding_and_identity
   ================================================================ -/

/-- The Arrhenius-form transition rate (definition:bk4_symbolic_transition_rate)
is strictly positive whenever the structural prefactor is, since `Real.exp`
is always strictly positive. Only this positivity consequence is modeled;
the free-energy-barrier interpretation is not. -/
theorem transitionRate_pos (A dF Ts : ℝ) (hA : 0 < A) :
    0 < A * Real.exp (-(dF / Ts)) :=
  mul_pos hA (Real.exp_pos _)

/-- The same exponential-positivity fact certifies
theorem:bk4_auto_encoding_and_identity's core symbolic pattern formula
`Psi_i(x) ~ exp(-lambda * d_g(...))`: it is always strictly positive,
independent of the reconstruction distance. -/
theorem autoEncoderPattern_pos (lam d : ℝ) : 0 < Real.exp (-(lam * d)) :=
  Real.exp_pos _

/- ================================================================
   theorem:bk4_emergence_through_timescale_separation
   ================================================================ -/

/-- The three-way strict timescale separation
(theorem:bk4_emergence_through_timescale_separation) kept as a structure. -/
structure TimescaleSeparation where
  tauMicro : ℝ
  tauTransition : ℝ
  tauObservation : ℝ
  micro_lt_transition : tauMicro < tauTransition
  transition_lt_observation : tauTransition < tauObservation

/-- The separation is transitive end-to-end. -/
theorem timescaleSeparation_micro_lt_observation (t : TimescaleSeparation) :
    t.tauMicro < t.tauObservation :=
  lt_trans t.micro_lt_transition t.transition_lt_observation

/- ================================================================
   definition:bk4_symbolic_auto_encoder
   ================================================================ -/

/-- Scalar reconstruction data for a symbolic auto-encoder
(definition:bk4_symbolic_auto_encoder): a non-negative per-point error
bounded above by `epsRecon`. The richer `SymbolicAutoEncoder` below adds the
actual encoding and decoding maps while this summary remains available for
finite-sample aggregation. -/
structure AutoEncoderReconstruction (X : Type) where
  reconError : X → ℝ
  reconError_nonneg : ∀ x, 0 ≤ reconError x
  epsRecon : ℝ
  epsRecon_pos : 0 < epsRecon
  reconError_le : ∀ x, reconError x ≤ epsRecon

/-- A symbolic auto-encoder with actual encoding and decoding maps. Its
pointwise reconstruction distance is uniformly bounded by `epsRecon`. -/
structure SymbolicAutoEncoder (X Z : Type) [PseudoMetricSpace X] where
  encode : X → Z
  decode : Z → X
  epsRecon : ℝ
  epsRecon_nonneg : 0 ≤ epsRecon
  reconstruction_le : ∀ x, dist (decode (encode x)) x ≤ epsRecon

/-- The reconstruction distance associated to an actual symbolic
encoder/decoder pair. -/
def SymbolicAutoEncoder.reconstructionDistance
    {X Z : Type} [PseudoMetricSpace X] (A : SymbolicAutoEncoder X Z) (x : X) : ℝ :=
  dist (A.decode (A.encode x)) x

/-- The exponential identity-pattern weight attached to reconstruction. -/
noncomputable def SymbolicAutoEncoder.identityPattern
    {X Z : Type} [PseudoMetricSpace X] (A : SymbolicAutoEncoder X Z)
    (lam : ℝ) (x : X) : ℝ :=
  Real.exp (-(lam * A.reconstructionDistance x))

/-- A zero reconstruction budget forces exact recovery of every identity. -/
theorem SymbolicAutoEncoder.exact_reconstruction_of_eps_eq_zero
    {X Z : Type} [MetricSpace X] (A : SymbolicAutoEncoder X Z)
    (heps : A.epsRecon = 0) (x : X) :
    A.decode (A.encode x) = x := by
  apply dist_eq_zero.mp
  exact le_antisymm (by simpa [heps] using A.reconstruction_le x) dist_nonneg

/-- At nonzero pattern sensitivity, maximal identity-pattern weight is
exactly equivalent to exact reconstruction. -/
theorem SymbolicAutoEncoder.identityPattern_eq_one_iff
    {X Z : Type} [MetricSpace X] (A : SymbolicAutoEncoder X Z)
    (lam : ℝ) (hlam : lam ≠ 0) (x : X) :
    A.identityPattern lam x = 1 ↔ A.decode (A.encode x) = x := by
  simp [SymbolicAutoEncoder.identityPattern,
    SymbolicAutoEncoder.reconstructionDistance, Real.exp_eq_one_iff, hlam]

/-- Exact reconstruction makes the encoder injective: distinct identities
cannot collapse to the same code. -/
theorem SymbolicAutoEncoder.encode_injective_of_eps_eq_zero
    {X Z : Type} [MetricSpace X] (A : SymbolicAutoEncoder X Z)
    (heps : A.epsRecon = 0) : Function.Injective A.encode := by
  intro x y hxy
  calc
    x = A.decode (A.encode x) := (A.exact_reconstruction_of_eps_eq_zero heps x).symm
    _ = A.decode (A.encode y) := by rw [hxy]
    _ = y := A.exact_reconstruction_of_eps_eq_zero heps y

/-- The genuine Finset consequence: over any finite sample, total (hence
average) reconstruction error is bounded by sample size times the
per-point bound. -/
theorem autoEncoder_finite_sum_le {X : Type} (A : AutoEncoderReconstruction X)
    (s : Finset X) :
    ∑ x ∈ s, A.reconError x ≤ s.card * A.epsRecon := by
  calc ∑ x ∈ s, A.reconError x ≤ ∑ _x ∈ s, A.epsRecon :=
        Finset.sum_le_sum (fun x _ => A.reconError_le x)
    _ = s.card * A.epsRecon := by rw [Finset.sum_const, nsmul_eq_mul]

/- ================================================================
   definition:bk4_imaginary_symbolic_distance
   ================================================================ -/

/-- The observer-relative complex symbolic distance
(definition:bk4_imaginary_symbolic_distance), `D_O^C = d_Re + i d_Im`, kept
as a concrete complex number built from its two real components. The
parallel-transported overlap and Hermitian metric it is derived from are
not modeled; only the resulting complex pair is. -/
def complexSymbolicDistance (dRe dIm : ℝ) : ℂ := dRe + dIm * Complex.I

theorem complexSymbolicDistance_re (dRe dIm : ℝ) :
    (complexSymbolicDistance dRe dIm).re = dRe := by
  simp [complexSymbolicDistance]

theorem complexSymbolicDistance_im (dRe dIm : ℝ) :
    (complexSymbolicDistance dRe dIm).im = dIm := by
  simp [complexSymbolicDistance]

/-- The real displacement never exceeds the full complex distance in
magnitude -- the standard `|Re z| <= ‖z‖` fact, specialized to
`complexSymbolicDistance`. -/
theorem complexSymbolicDistance_re_le_abs (dRe dIm : ℝ) :
    |dRe| ≤ ‖complexSymbolicDistance dRe dIm‖ := by
  have h := Complex.abs_re_le_norm (complexSymbolicDistance dRe dIm)
  rwa [complexSymbolicDistance_re] at h

/- ================================================================
   proposition:bk4_imaginative_continuity_principle
   ================================================================ -/

/-- Identity is reintegrable across an unobserved interval
(proposition:bk4_imaginative_continuity_principle) exactly when both the
real and imaginary displacements stay within their observer-relative
thresholds. -/
def ReintegrableIdentity (dRe dIm epsO thetaO : ℝ) : Prop :=
  dRe < epsO ∧ dIm < thetaO

/-- The Imaginative Continuity Principle as an explicit biconditional:
identity reintegration is equivalent to simultaneously resolving its real
and imaginary displacements. -/
theorem reintegrableIdentity_iff (dRe dIm epsO thetaO : ℝ) :
    ReintegrableIdentity dRe dIm epsO thetaO ↔
      dRe < epsO ∧ dIm < thetaO :=
  Iff.rfl

/-- Reintegration persists when either observer tolerance is enlarged. -/
theorem ReintegrableIdentity.mono_thresholds
    {dRe dIm epsO thetaO epsO' thetaO' : ℝ}
    (h : ReintegrableIdentity dRe dIm epsO thetaO)
    (heps : epsO ≤ epsO') (htheta : thetaO ≤ thetaO') :
    ReintegrableIdentity dRe dIm epsO' thetaO' := by
  exact ⟨h.1.trans_le heps, h.2.trans_le htheta⟩

/-- Failure of imaginative continuity occurs exactly when the real threshold
or the imaginary threshold is breached. -/
theorem not_reintegrableIdentity_iff (dRe dIm epsO thetaO : ℝ) :
    ¬ ReintegrableIdentity dRe dIm epsO thetaO ↔
      epsO ≤ dRe ∨ thetaO ≤ dIm := by
  constructor
  · intro h
    by_cases hre : dRe < epsO
    · right
      by_contra him
      exact h ⟨hre, lt_of_not_ge him⟩
    · exact Or.inl (le_of_not_gt hre)
  · rintro (hre | him) ⟨hre', him'⟩ <;> linarith

/-- The "uncanny recognition" case made non-vacuous: an explicit witness
where the real displacement is within tolerance but the imaginary
displacement is not, so reintegrability genuinely fails even though the
observable (real) mismatch alone would have looked fine. -/
theorem uncanny_recognition_countermodel :
    ∃ dRe dIm epsO thetaO : ℝ, dRe < epsO ∧ ¬ ReintegrableIdentity dRe dIm epsO thetaO := by
  refine ⟨0, 10, 1, 1, by norm_num, ?_⟩
  rintro ⟨-, h2⟩
  norm_num at h2

/- ================================================================
   definition:bk4_event_horizon_wheel, proposition:bk4_wheel_refines_signature
   ================================================================ -/

/-- The four open Event Horizon modes (definition:bk4_event_horizon_wheel)
are cut by the sign pair `(sign Re, sign Im)` of the transported overlap;
here modeled directly as the four open sign-quadrants of `ℝ x ℝ`. -/
def PosPos (p : ℝ × ℝ) : Prop := 0 < p.1 ∧ 0 < p.2
def PosNeg (p : ℝ × ℝ) : Prop := 0 < p.1 ∧ p.2 < 0
def NegPos (p : ℝ × ℝ) : Prop := p.1 < 0 ∧ 0 < p.2
def NegNeg (p : ℝ × ℝ) : Prop := p.1 < 0 ∧ p.2 < 0

/-- proposition:bk4_wheel_refines_signature's exhaustiveness half: every
point off both axes falls into one of the four quadrant classes. -/
theorem quadrant_exhaustive (p : ℝ × ℝ) (h1 : p.1 ≠ 0) (h2 : p.2 ≠ 0) :
    PosPos p ∨ PosNeg p ∨ NegPos p ∨ NegNeg p := by
  rcases lt_or_gt_of_ne h1 with hp1 | hp1 <;> rcases lt_or_gt_of_ne h2 with hp2 | hp2
  · exact Or.inr (Or.inr (Or.inr ⟨hp1, hp2⟩))
  · exact Or.inr (Or.inr (Or.inl ⟨hp1, hp2⟩))
  · exact Or.inr (Or.inl ⟨hp1, hp2⟩)
  · exact Or.inl ⟨hp1, hp2⟩

/-- Mutual exclusivity of two diametrically opposite quadrants: the
fourfold partition is genuinely a partition, not an overlapping cover. -/
theorem quadrants_disjoint (p : ℝ × ℝ) : ¬ (PosPos p ∧ NegNeg p) := by
  rintro ⟨⟨h1, _⟩, ⟨h2, _⟩⟩
  linarith

/- ================================================================
   proposition:bk4_spiral_transition, theorem:bk4_golden_event_horizon_spiral
   ================================================================ -/

/-- The spiral orbit magnitude `r_n = rho^n * r0`
(proposition:bk4_spiral_transition). -/
def spiralMagnitude (rho r0 : ℝ) (n : ℕ) : ℝ := rho ^ n * r0

/-- The spiral orbit phase `theta_n = theta0 + n * alpha`
(proposition:bk4_spiral_transition). -/
def spiralPhase (alpha theta0 : ℝ) (n : ℕ) : ℝ := theta0 + n * alpha

/-- The per-step magnitude law: multiplication by `rho` at each emergence
step, the honest per-step-evolution kernel of "combined rotation and
scaling rather than ... discontinuous jumps." -/
theorem spiralMagnitude_recurrence (rho r0 : ℝ) (n : ℕ) :
    spiralMagnitude rho r0 (n + 1) = rho * spiralMagnitude rho r0 n := by
  unfold spiralMagnitude
  ring

/-- The per-step phase law: addition of `alpha` at each emergence step. -/
theorem spiralPhase_recurrence (alpha theta0 : ℝ) (n : ℕ) :
    spiralPhase alpha theta0 (n + 1) = spiralPhase alpha theta0 n + alpha := by
  unfold spiralPhase
  push_cast
  ring

/-- The golden ratio, as the Perron root of theorem:bk4_golden_event_horizon_spiral's
balanced two-step memory closure. -/
noncomputable def goldenRatio : ℝ := (1 + Real.sqrt 5) / 2

/-- The defining quadratic identity `phi ^ 2 = phi + 1`. -/
theorem goldenRatio_sq : goldenRatio ^ 2 = goldenRatio + 1 := by
  have h5 : Real.sqrt 5 * Real.sqrt 5 = 5 := Real.mul_self_sqrt (by norm_num)
  unfold goldenRatio
  field_simp
  nlinarith [h5]

/-- theorem:bk4_golden_event_horizon_spiral's balanced two-step recurrence
`r_{n+2} = r_{n+1} + r_n` for the golden spiral magnitudes, derived purely
from `phi ^ 2 = phi + 1` -- the honest algebraic content behind "the
wheel's radius is the balanced-memory (Fibonacci) sequence." -/
theorem goldenSpiral_recurrence (r0 : ℝ) (n : ℕ) :
    spiralMagnitude goldenRatio r0 (n + 2) =
      spiralMagnitude goldenRatio r0 (n + 1) + spiralMagnitude goldenRatio r0 n := by
  unfold spiralMagnitude
  have key : goldenRatio ^ (n + 2) = goldenRatio ^ (n + 1) + goldenRatio ^ n := by
    have hpow : goldenRatio ^ (n + 2) = goldenRatio ^ n * goldenRatio ^ 2 := by ring
    rw [hpow, goldenRatio_sq]
    ring
  rw [key]
  ring

/-- The golden spiral's growth coefficient is strictly positive. -/
theorem goldenRatio_pos : 0 < goldenRatio := by
  unfold goldenRatio
  positivity

/-- For every nonzero initial radius, the ratio of consecutive golden-spiral
magnitudes is exactly `goldenRatio` at every stage. -/
theorem goldenSpiral_ratio_eq (r0 : ℝ) (hr0 : r0 ≠ 0) (n : ℕ) :
    spiralMagnitude goldenRatio r0 (n + 1) /
      spiralMagnitude goldenRatio r0 n = goldenRatio := by
  unfold spiralMagnitude
  rw [pow_succ]
  field_simp [hr0, ne_of_gt goldenRatio_pos]

/-- The source's asymptotic radius-ratio claim follows, more strongly, from
stagewise equality of every ratio to the golden growth coefficient. -/
theorem goldenSpiral_ratio_tendsto (r0 : ℝ) (hr0 : r0 ≠ 0) :
    Filter.Tendsto
      (fun n => spiralMagnitude goldenRatio r0 (n + 1) /
        spiralMagnitude goldenRatio r0 n)
      Filter.atTop (nhds goldenRatio) := by
  simp [goldenSpiral_ratio_eq r0 hr0]

/- ================================================================
   axiom:bk4_refinement_contraction
   ================================================================ -/

/-- The Refinement Contraction Axiom (axiom:bk4_refinement_contraction) kept
as a structure: a `kappa`-Lipschitz self-map with `kappa < 1`. Its finite
contraction law holds already in a pseudometric space; below, a nonempty
complete metric specialization supplies the Banach fixed-point limit. -/
structure ContractionRefinement (S : Type) [PseudoMetricSpace S] where
  R : S → S
  kappa : ℝ
  kappa_pos : 0 < kappa
  kappa_lt_one : kappa < 1
  contract : ∀ s s', dist (R s) (R s') ≤ kappa * dist s s'

/-- The finite quantitative kernel of TTPR convergence
(proposition:bk4_ttpr_convergence): after `n` refinement steps, any two
starting points have moved at most `kappa ^ n` times closer together,
proved by induction (telescoping the per-step contraction). -/
theorem contractionRefinement_iterate {S : Type} [PseudoMetricSpace S]
    (c : ContractionRefinement S) (n : ℕ) (s s' : S) :
    dist (c.R^[n] s) (c.R^[n] s') ≤ c.kappa ^ n * dist s s' := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', Function.iterate_succ_apply']
      calc dist (c.R (c.R^[k] s)) (c.R (c.R^[k] s'))
          ≤ c.kappa * dist (c.R^[k] s) (c.R^[k] s') := c.contract _ _
        _ ≤ c.kappa * (c.kappa ^ k * dist s s') :=
            mul_le_mul_of_nonneg_left ih (le_of_lt c.kappa_pos)
        _ = c.kappa ^ (k + 1) * dist s s' := by ring

/-- The nonnegative contraction constant attached to a refinement. -/
def ContractionRefinement.contractionConstant {S : Type} [PseudoMetricSpace S]
    (c : ContractionRefinement S) : NNReal :=
  ⟨c.kappa, le_of_lt c.kappa_pos⟩

/-- A refinement satisfying the Book 4 contraction axiom is a contraction
in Mathlib's metric fixed-point interface. -/
theorem ContractionRefinement.contractingWith {S : Type} [MetricSpace S]
    (c : ContractionRefinement S) :
    ContractingWith c.contractionConstant c.R := by
  constructor
  · exact_mod_cast c.kappa_lt_one
  · apply LipschitzWith.of_dist_le_mul
    intro s s'
    change dist (c.R s) (c.R s') ≤ c.kappa * dist s s'
    exact c.contract s s'

/-- The TTPR limit of a contraction refinement on a nonempty complete metric
space, supplied by the Banach fixed-point theorem. -/
noncomputable def ContractionRefinement.ttprLimit {S : Type} [MetricSpace S]
    [CompleteSpace S] [Nonempty S] (c : ContractionRefinement S) : S :=
  c.contractingWith.fixedPoint c.R

/-- The TTPR limit is invariant under one further refinement. -/
theorem ContractionRefinement.ttprLimit_fixed {S : Type} [MetricSpace S]
    [CompleteSpace S] [Nonempty S] (c : ContractionRefinement S) :
    c.R c.ttprLimit = c.ttprLimit :=
  c.contractingWith.fixedPoint_isFixedPt

/-- Every refinement-fixed point is the TTPR limit. -/
theorem ContractionRefinement.fixed_eq_ttprLimit {S : Type} [MetricSpace S]
    [CompleteSpace S] [Nonempty S] (c : ContractionRefinement S) {s : S}
    (hs : c.R s = s) : s = c.ttprLimit :=
  c.contractingWith.fixedPoint_unique hs

/-- Iterated test-time refinement converges to the unique TTPR limit from
every starting point in a nonempty complete metric symbolic space. -/
theorem ContractionRefinement.tendsto_iterate_ttprLimit {S : Type} [MetricSpace S]
    [CompleteSpace S] [Nonempty S] (c : ContractionRefinement S) (s : S) :
    Filter.Tendsto (fun n => c.R^[n] s) Filter.atTop (nhds c.ttprLimit) :=
  c.contractingWith.tendsto_iterate_fixedPoint s

/-- The recursive self-reference sequence approaches its identity with the
same explicit geometric distortion bound as the underlying refinement. -/
theorem ContractionRefinement.selfReference_dist_ttprLimit_le
    (c : ContractionRefinement ℝ) (n : ℕ) (x : ℝ) :
    dist (selfReferenceIterate c.R n x) c.ttprLimit ≤
      c.kappa ^ n * dist x c.ttprLimit := by
  have h := contractionRefinement_iterate c n x c.ttprLimit
  rw [Function.iterate_fixed c.ttprLimit_fixed n] at h
  simpa [selfReferenceIterate] using h

/-- A real symbolic state is self-reference-fixed exactly when it is the
unique TTPR identity selected by the contraction. -/
theorem ContractionRefinement.selfReference_fixed_iff_eq_ttprLimit
    (c : ContractionRefinement ℝ) (x : ℝ) :
    c.R x = x ↔ x = c.ttprLimit := by
  constructor
  · exact c.fixed_eq_ttprLimit
  · intro hx
    rw [hx]
    exact c.ttprLimit_fixed

/-- The recursively defined Book 4 self-reference operators converge from
every real starting state to the unique TTPR identity. -/
theorem ContractionRefinement.tendsto_selfReferenceIterate
    (c : ContractionRefinement ℝ) (x : ℝ) :
    Filter.Tendsto (fun n => selfReferenceIterate c.R n x)
      Filter.atTop (nhds c.ttprLimit) := by
  simpa [selfReferenceIterate] using c.tendsto_iterate_ttprLimit x

/- ================================================================
   theorem:bk4_drift_reflection_imbalance
   ================================================================ -/

/-- A membrane region is drift-imbalanced (theorem:bk4_drift_reflection_imbalance)
when drift strictly exceeds `theta` times reflection everywhere on it, for
an imbalance parameter `theta > 1`. -/
def Imbalanced (driftNorm reflectNorm : ℝ → ℝ) (U : Set ℝ) (theta : ℝ) : Prop :=
  ∀ x ∈ U, driftNorm x > theta * reflectNorm x

/-- The honest pointwise consequence: on an imbalanced region, drift
strictly exceeds reflection outright, not merely `theta` times it. -/
theorem imbalanced_drift_exceeds_reflect
    (driftNorm reflectNorm : ℝ → ℝ) (U : Set ℝ) (theta : ℝ)
    (htheta : 1 < theta) (hrefl_nonneg : ∀ x, 0 ≤ reflectNorm x)
    (h : Imbalanced driftNorm reflectNorm U theta) {x : ℝ} (hx : x ∈ U) :
    driftNorm x > reflectNorm x := by
  have h1 := h x hx
  have h2 := hrefl_nonneg x
  nlinarith [mul_nonneg (le_of_lt (sub_pos.mpr htheta)) h2]

/- ================================================================
   corollary:bk4_chromatic_transference_of_wheel
   ================================================================ -/

/-- The Event Horizon Wheel modeled concretely as a twelve-position
chromatic wheel (corollary:bk4_chromatic_transference_of_wheel): adjacency
is differing by one step. -/
def Adjacent (x y : ZMod 12) : Prop := y = x + 1 ∨ y = x - 1

/-- Rotation (`+ c`) genuinely preserves adjacency: the honest finite
invariant behind "the phase-to-hue assignment ... preserves cyclic order
and adjacency on `S^1`." -/
theorem adjacent_rotate {x y : ZMod 12} (c : ZMod 12) (h : Adjacent x y) :
    Adjacent (x + c) (y + c) := by
  rcases h with h | h
  · left; rw [h]; ring
  · right; rw [h]; ring

/-- Diametric opposition, `theta |-> theta + pi` transported to the wheel as
`x |-> x + 6`. -/
def Opposite (x : ZMod 12) : ZMod 12 := x + 6

/-- Opposition is an involution: applying it twice returns the original
position, the honest finite content of "diametric opposition." -/
theorem opposite_involutive (x : ZMod 12) : Opposite (Opposite x) = x := by
  have h : (6 : ZMod 12) + 6 = 0 := by decide
  show x + 6 + 6 = x
  calc x + 6 + 6 = x + (6 + 6) := by ring
    _ = x + 0 := by rw [h]
    _ = x := by ring

/-- Rotation and opposition commute -- the wheel is preserved as a
structure carried by rotations, not disturbed by them. -/
theorem opposite_add (x c : ZMod 12) : Opposite (x + c) = Opposite x + c := by
  unfold Opposite
  ring

/-- Not every relabeling of the wheel is a modal transference: the
transposition swapping positions `1` and `6` (and fixing everything else)
sends the adjacent pair `(0, 1)` to the non-adjacent pair `(0, 6)`. This is
the honest countermodel for "the wheel is preserved as an invariant of the
symbolic structure" holding specifically for rotations, not for arbitrary
bijective relabelings. -/
def swapPerm (x : ZMod 12) : ZMod 12 := if x = 1 then 6 else if x = 6 then 1 else x

theorem swapPerm_breaks_adjacency :
    Adjacent (0 : ZMod 12) 1 ∧ ¬ Adjacent (swapPerm 0) (swapPerm 1) := by
  unfold Adjacent swapPerm
  decide

end ForcingAnalysis.Book4A
