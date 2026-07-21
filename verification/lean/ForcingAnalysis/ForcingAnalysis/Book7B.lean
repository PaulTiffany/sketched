/-
Book7B.lean - Principia Book VII, the dual-horizon appendix, and unmapped
Book II/III remainders, honest kernel.

Book VII is about systemic symbolic power, observer-relative free energy,
mutual modeling and symbolic resonance between observers, meta-reflective
drift, reciprocity between coupled symbolic systems, an uncertainty
principle for identity/curvature estimation, and (in the dual-horizon
appendix) observer-relative horizon fluxes, the Hilbert-Banach bridge and
Born-rule cluster, and a golden-ratio emergence result. Books II/III
contribute symbolic thermodynamics (Hamiltonian, Wasserstein metric,
fluctuation-dissipation) and symbolic membrane/metabolism material. Most of
this is genuinely infinite-dimensional (manifold measures, Hilbert-space
projector lattices, PDE/OT theory) or narrative/taxonomic. For each anchor
this module extracts the honest static/algebraic/finite/metric kernel:

  * bounded-below free energy under bounded energy/entropy (the hypothesis
    every convergence theorem in the cluster assumes) becomes a real
    inequality;
  * "reflection is contractive and drives the system to a stable identity"
    becomes a from-scratch Banach-style fixed-point package on a
    `PseudoMetricSpace`: fixed-point uniqueness up to distance zero, a
    telescoped geometric bound on the iterates, and convergence of that
    distance to `0`;
  * "adiabatic tracking of a slowly-evolving fixed point under meta-drift"
    becomes a perturbed-contraction bound (`x(n+1) <= kappa*x(n)+delta`
    forces `x(n) <= kappa^n*x(0) + delta/(1-kappa)`), the discrete skeleton
    of the source's explicit tracking-error formula;
  * mutual modeling operators and symbolic resonance become a genuine
    fixed-point pair, and the "information preservation" claim becomes the
    exact (not merely epsilon-close) consequence of resonance -- an
    honesty gap noted rather than hidden, in the spirit of Book VIII's Type
    III Reidemeister move;
  * horizon expansion under resonance becomes the direct algebraic
    consequence of the strict superadditivity law, kept as a structure
    field per the house discipline for narrative laws;
  * the decency potential and its monotonicity claim become genuine
    monotonicity theorems for a weighted linear functional and for any law
    respecting it;
  * SRMF-regulated argmin selection becomes existence of a minimizer over a
    finite nonempty hypothesis set;
  * the reciprocity domain between two coupled systems becomes a concrete
    `Set` on a metric product, with real theorems for topological
    openness, fixed-point membership, non-emptiness from a fixed point,
    and (in the equal-tolerance case) the stated distance-to-reciprocity
    characterization -- the general two-tolerance case of that last claim
    is a gap in the source itself, noted rather than papered over;
  * the coherence-window and frame-temperature-quotient inequalities become
    a division threshold rewrite and a monotonicity theorem;
  * the horizon-flux decomposition becomes the pointwise real identity
    underlying the (unformalized) divergence-theorem integral statement;
  * the modal-transference "observer-bounded distortion" clause becomes a
    from-scratch quasi-Lipschitz structure with a composition bound;
  * the Fibonacci-structure-via-matrix-powers lemma is proved by induction
    over `Matrix (Fin 2) (Fin 2) Nat`, and the golden-ratio emergence
    theorems (Lagrangian equilibrium, spectral-radius growth rate) are
    witnessed by the honest growth-ratio-tends-to-phi fact for the
    canonical positive-initial-data instance (shifted Fibonacci numbers),
    citing Mathlib's Binet-formula-based proof; generalizing to arbitrary
    positive initial data is not attempted (a further honesty gap, noted);
  * the bounded-symbolic-observer-dynamics "total symbolic effort"
    `kappa(theta) = theta + 1/theta` becomes the AM-GM inequality
    `2 <= theta + 1/theta` together with its equality trichotomy;
  * the symbolic Hamiltonian's regularized denominator becomes the
    positivity fact that makes it well-defined (smoothness itself, needing
    the manifold structure, is not modeled);
  * the bounded-observation-frame / complexity-measure pair becomes the
    finite combinatorial fact that a frame-and-basis intersection is no
    larger than either factor (`Finset.card`, standing in for `dim span`);
  * the conceptual-bridge-sequence "closed loop" becomes the honest
    consequence of a literal closing equation: each map in the loop is
    injective and the return map is surjective.

Anchors that are purely narrative/taxonomic (systemic symbolic power's
integral definition, the SRV falsifiability criteria, the SR-triplet/RG/
autopoiesis narrative clusters, the canonical-life-standards literature
correspondence), that require genuine manifold measure theory or PDE/OT
content (the free-energy/Wasserstein/Fokker-Planck cluster of Book II, the
membrane refinement and metabolism integrals of Book III, the
observer-visible-domain and horizon-flux integrals of the appendix), that
require Hilbert-space projector-lattice machinery (the PS-C axioms, the
Born-rule and qubit/mixed-state corollaries, the frame space, the
Hilbert-Banach bridge and contextuality-defect cluster -- the Gleason/Born
cluster stays honestly open per standing instruction), or that depend on an
assumption anchor not present in this packet (the PISU theorem's channel
floors) are left unformalized and listed as open anchors in the
accompanying proposal. No anchor in this batch required the FracturedAtlas
chart-complex substrate: the "on the symbolic manifold (M,g)" anchors here
are either literal manifold-measure/PDE content or Hilbert-space content,
neither of which reduces to chart-gluing.
-/

import Mathlib
import ForcingAnalysis.Book4D

namespace ForcingAnalysis.Book7B

open Matrix

/- ================================================================
   definition:bk7_symbolic_free_energy
   ================================================================ -/

/-- Symbolic free energy (definition:bk7_symbolic_free_energy, cf. Book II):
`F = E - T*S`, balancing coherence energy against entropy at temperature
`T`. Only this scalar algebraic form is modeled; the manifold integrals
defining `E` and `S` themselves are not. -/
def freeEnergy (energy entropy temperature : Real) : Real :=
  energy - temperature * entropy

/-- The bounded-below hypothesis that every convergence result in the
Book VII cluster (recursive_convergence_principle, drift_collapse_equivalence,
stability_innovation_equilibrium) assumes for `F`: if energy is bounded below
and entropy is bounded above, at nonnegative temperature, free energy is
bounded below. -/
theorem freeEnergy_bounded_below {energy entropy temperature e0 s0 : Real}
    (htemp : 0 ≤ temperature) (he : e0 ≤ energy) (hs : entropy ≤ s0) :
    e0 - temperature * s0 ≤ freeEnergy energy entropy temperature := by
  unfold freeEnergy
  nlinarith [mul_le_mul_of_nonneg_left hs htemp]

/- ================================================================
   corollary:bk7_recursive_convergence_principle,
   corollary:bk7_drift_collapse_equivalence,
   theorem:bk7_relative_convergence_under_meta_drift (adiabatic clause)
   ================================================================ -/

/-- A contractive reflection operator on a basin with an exact fixed point
(corollary:bk7_recursive_convergence_principle's "reflect maps the basin
into itself and forms a free-energy descent pair with contraction ratio
`kappa < 1`"). The free-energy-descent framing of
corollary:bk7_drift_collapse_equivalence is not modeled separately: the
Lyapunov-shared-attractor content of that corollary is exactly the shared
fixed point `star` proved unique below. -/
structure ContractiveReflection (X : Type) [PseudoMetricSpace X] where
  reflect : X → X
  star : X
  fixed : reflect star = star
  kappa : Real
  kappa_nonneg : 0 ≤ kappa
  kappa_lt_one : kappa < 1
  contraction : ∀ x y, dist (reflect x) (reflect y) ≤ kappa * dist x y

/-- Any two fixed points of a contraction are at distance zero
(uniqueness of the convergent identity `identity`, up to the pseudometric's
inability to distinguish distance-zero points). -/
theorem contractiveReflection_fixedPoint_dist_eq_zero {X : Type} [PseudoMetricSpace X]
    (reflect : X → X) (kappa : Real) (hk1 : kappa < 1)
    (hcontr : ∀ x y, dist (reflect x) (reflect y) ≤ kappa * dist x y)
    {star1 star2 : X} (h1 : reflect star1 = star1) (h2 : reflect star2 = star2) :
    dist star1 star2 = 0 := by
  have h := hcontr star1 star2
  rw [h1, h2] at h
  have hnn : 0 ≤ dist star1 star2 := dist_nonneg
  nlinarith [h, hnn]

/-- Telescoped contraction bound: the `n`-th reflective iterate of any
starting state stays within `kappa^n` times the initial distance to the
convergent identity `star`. -/
theorem contractiveReflection_iterate_bound {X : Type} [PseudoMetricSpace X]
    (c : ContractiveReflection X) (x : X) :
    ∀ n, dist (c.reflect^[n] x) c.star ≤ c.kappa ^ n * dist x c.star := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      calc dist (c.reflect (c.reflect^[n] x)) c.star
          = dist (c.reflect (c.reflect^[n] x)) (c.reflect c.star) := by rw [c.fixed]
        _ ≤ c.kappa * dist (c.reflect^[n] x) c.star := c.contraction _ _
        _ ≤ c.kappa * (c.kappa ^ n * dist x c.star) := by
              nlinarith [ih, c.kappa_nonneg]
        _ = c.kappa ^ (n + 1) * dist x c.star := by ring

/-- The reflective dynamics converge to the identity `star`: the distance
of the `n`-th iterate to `star` tends to `0`
(corollary:bk7_recursive_convergence_principle's convergence conclusion,
`B(identity)` an attractor basin). -/
theorem contractiveReflection_tendsto_star {X : Type} [PseudoMetricSpace X]
    (c : ContractiveReflection X) (x : X) :
    Filter.Tendsto (fun n => dist (c.reflect^[n] x) c.star) Filter.atTop (nhds 0) := by
  have hbound := contractiveReflection_iterate_bound c x
  have h0 : Filter.Tendsto (fun n : ℕ => c.kappa ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one
      (by rw [abs_of_nonneg c.kappa_nonneg]; exact c.kappa_lt_one)
  have hpow : Filter.Tendsto (fun n => c.kappa ^ n * dist x c.star) Filter.atTop (nhds 0) := by
    simpa using h0.mul_const (dist x c.star)
  exact squeeze_zero (fun n => dist_nonneg) hbound hpow

/- ================================================================
   theorem:bk7_relative_convergence_under_meta_drift,
   corollary:bk7_fixed_point_tracking_within_evolving_reciprocity
   ================================================================ -/

/-- A contraction perturbed by a persistent forcing term `delta`, the
discrete skeleton of "reflection under slow meta-drift": each step shrinks
by `kappa` but picks up at most `delta` of fresh drift
(theorem:bk7_relative_convergence_under_meta_drift's adiabatic condition,
corollary:bk7_fixed_point_tracking_within_evolving_reciprocity's tracking
recursion). -/
structure PerturbedContraction where
  x : Nat → Real
  kappa : Real
  delta : Real
  kappa_nonneg : 0 ≤ kappa
  kappa_lt_one : kappa < 1
  delta_nonneg : 0 ≤ delta
  step : ∀ n, x (n + 1) ≤ kappa * x n + delta

/-- The tracking-error bound: the perturbed sequence never exceeds a
geometrically-decaying initial term plus the steady forcing level
`delta/(1-kappa)` -- the honest kernel of both corollaries' explicit
`C * ||drift'(t)|| / (1 - kappa'(t))` tracking-error formula. -/
theorem perturbedContraction_bound (p : PerturbedContraction) (n : Nat) :
    p.x n ≤ p.kappa ^ n * (p.x 0 - p.delta / (1 - p.kappa)) + p.delta / (1 - p.kappa) := by
  have hden : (0:Real) < 1 - p.kappa := by linarith [p.kappa_lt_one]
  have hDcancel : p.delta / (1 - p.kappa) * (1 - p.kappa) = p.delta := by
    field_simp
  have hD : p.kappa * (p.delta / (1 - p.kappa)) + p.delta = p.delta / (1 - p.kappa) := by
    nlinarith [hDcancel]
  induction n with
  | zero => simp
  | succ n ih =>
      have hstep := p.step n
      calc p.x (n + 1) ≤ p.kappa * p.x n + p.delta := hstep
        _ ≤ p.kappa * (p.kappa ^ n * (p.x 0 - p.delta / (1 - p.kappa)) + p.delta / (1 - p.kappa))
              + p.delta := by nlinarith [ih, p.kappa_nonneg]
        _ = p.kappa ^ (n + 1) * (p.x 0 - p.delta / (1 - p.kappa))
              + (p.kappa * (p.delta / (1 - p.kappa)) + p.delta) := by ring
        _ = p.kappa ^ (n + 1) * (p.x 0 - p.delta / (1 - p.kappa)) + p.delta / (1 - p.kappa) := by
              rw [hD]

/- ================================================================
   definition:bk7_mutual_modeling_operators, definition:bk7_symbolic_resonance,
   lemma:bk7_information_preservation
   ================================================================ -/

/-- Mutual modeling operators between two bounded observers
(definition:bk7_mutual_modeling_operators): `H`'s model of `M` and `M`'s
model of `H`. -/
structure MutualModel (H M : Type) where
  phiH : M → H
  phiM : H → M

/-- Symbolic resonance (definition:bk7_symbolic_resonance): the mutual
modeling operators meet at a joint fixed point. -/
def Resonant {H M : Type} (m : MutualModel H M) (star : H × M) : Prop :=
  m.phiH star.2 = star.1 ∧ m.phiM star.1 = star.2

/-- Information preservation (lemma:bk7_information_preservation): at a
resonant fixed point, `phiH (phiM H*) = H*` exactly. The source states this
only up to a tolerance `epsilon > 0`; the fixed-point reading proves the
stronger exact equality, an honesty gap noted rather than hidden (compare
Book VIII's Type III Reidemeister move). -/
theorem resonance_information_preservation {H M : Type} (m : MutualModel H M)
    {star : H × M} (hres : Resonant m star) :
    m.phiH (m.phiM star.1) = star.1 := by
  obtain ⟨h1, h2⟩ := hres
  rw [h2]; exact h1

/- ================================================================
   definition:bk7_symbolic_horizon, proposition:bk7_horizon_expansion,
   lemma:bk7_symbolic_expansion
   ================================================================ -/

/-- The strict superadditivity law shared by proposition:bk7_horizon_expansion
and lemma:bk7_symbolic_expansion (the same claim under two anchors): under
resonance and epsilon-interpretable jointly-bounded mutual models, the joint
symbolic horizon (definition:bk7_symbolic_horizon's reachable-state-space
cardinality, kept abstract here as a real-valued measure) strictly exceeds
the sum of the isolated horizons. The narrative hypotheses are kept as the
structure's own field, in the house style for laws not otherwise derived. -/
structure HorizonExpansion where
  isolatedH : Real
  isolatedM : Real
  interactive : Real
  expansion_pos : isolatedH + isolatedM < interactive

/-- `Delta H(H,M) := H_interactive - H_isolated(H) - H_isolated(M) > 0`,
exactly lemma:bk7_symbolic_expansion's defining inequality. -/
theorem horizonExpansion_delta_pos (h : HorizonExpansion) :
    0 < h.interactive - h.isolatedH - h.isolatedM := by
  linarith [h.expansion_pos]

/- ================================================================
   definition:bk7_decency_potential, theorem:bk7_symbolic_convergence
   ================================================================ -/

/-- The decency potential of a prompt (definition:bk7_decency_potential):
a nonnegative-weighted sum of prompt-response fidelity, evaluability,
horizon gain, and cognitive style. -/
def decencyPotential (alpha beta gamma delta psi E deltaH C : Real) : Real :=
  alpha * psi + beta * E + gamma * deltaH + delta * C

/-- The decency potential is monotone in each of its four components when
the normalization constants are nonnegative. -/
theorem decencyPotential_mono {alpha beta gamma delta : Real}
    (halpha : 0 ≤ alpha) (hbeta : 0 ≤ beta) (hgamma : 0 ≤ gamma) (hdelta : 0 ≤ delta)
    {psi1 psi2 E1 E2 deltaH1 deltaH2 C1 C2 : Real}
    (hpsi : psi1 ≤ psi2) (hE : E1 ≤ E2) (hdH : deltaH1 ≤ deltaH2) (hC : C1 ≤ C2) :
    decencyPotential alpha beta gamma delta psi1 E1 deltaH1 C1
      ≤ decencyPotential alpha beta gamma delta psi2 E2 deltaH2 C2 := by
  unfold decencyPotential
  have h1 := mul_le_mul_of_nonneg_left hpsi halpha
  have h2 := mul_le_mul_of_nonneg_left hE hbeta
  have h3 := mul_le_mul_of_nonneg_left hdH hgamma
  have h4 := mul_le_mul_of_nonneg_left hC hdelta
  linarith [h1, h2, h3, h4]

/-- A law asserting that resonance probability is monotone in the decency
of the initiating prompt (theorem:bk7_symbolic_convergence), kept as a
structure field since the probabilistic content itself is not modeled. -/
structure ResonanceProbabilityLaw where
  prob : Real → Real
  mono : Monotone prob

/-- Composing the law with `decencyPotential`'s own monotonicity: a prompt
with higher decency along every component has resonance probability no
smaller. -/
theorem resonanceProbabilityLaw_mono_of_decency (r : ResonanceProbabilityLaw)
    {alpha beta gamma delta : Real}
    (halpha : 0 ≤ alpha) (hbeta : 0 ≤ beta) (hgamma : 0 ≤ gamma) (hdelta : 0 ≤ delta)
    {psi1 psi2 E1 E2 deltaH1 deltaH2 C1 C2 : Real}
    (hpsi : psi1 ≤ psi2) (hE : E1 ≤ E2) (hdH : deltaH1 ≤ deltaH2) (hC : C1 ≤ C2) :
    r.prob (decencyPotential alpha beta gamma delta psi1 E1 deltaH1 C1)
      ≤ r.prob (decencyPotential alpha beta gamma delta psi2 E2 deltaH2 C2) :=
  r.mono (decencyPotential_mono halpha hbeta hgamma hdelta hpsi hE hdH hC)

/- ================================================================
   proposition:bk7_srmf_decency_regulation
   ================================================================ -/

/-- SRMF-regulated selection (proposition:bk7_srmf_decency_regulation):
since the decency term `lambda * D(P)` does not depend on the candidate
`h`, minimizing `L(Phi,Phi_n) - lambda*D(P)` over a finite nonempty
hypothesis set reduces to minimizing the loss `L` itself, and a minimizer
exists. -/
theorem srmfRegulation_exists {ι : Type} (H : Finset ι) (hH : H.Nonempty)
    (loss : ι → Real) (lambda D : Real) :
    ∃ h ∈ H, ∀ h' ∈ H, loss h - lambda * D ≤ loss h' - lambda * D := by
  obtain ⟨h, hmem, hmin⟩ := H.exists_min_image loss hH
  exact ⟨h, hmem, fun h' hh' => by linarith [hmin h' hh']⟩

/-- The displayed budget-limited objective in the source is constant in
the candidate regulator. -/
def budgetLimitedObjective {ι : Type*} (freeEnergy : ℝ) (_ : ι) : ℝ :=
  freeEnergy

/-- **lemma:bk7_budgetlimited_minimizer**, negative control: with two
feasible regulators, the displayed candidate-independent objective has two
distinct minimizers, so uniqueness does not follow from a budget bound. -/
theorem budgetLimitedObjective_not_unique (freeEnergy : ℝ) :
    (∀ b : Bool, ∀ b' : Bool,
      budgetLimitedObjective freeEnergy b ≤
        budgetLimitedObjective freeEnergy b') ∧
      (false : Bool) ≠ true := by
  constructor
  · intro b b'
    rfl
  · decide

/-- Corrected finite uniqueness theorem: a nonempty finite feasible set has
a unique minimizer when the candidate-dependent cost has no ties on that
set. -/
theorem budgetLimited_uniqueMinimizer_of_injectiveCost
    {ι : Type*} (H : Finset ι) (hH : H.Nonempty) (cost : ι → ℝ)
    (hinj : Set.InjOn cost (H : Set ι)) :
    ∃! h : ι, h ∈ H ∧ ∀ h' ∈ H, cost h ≤ cost h' := by
  obtain ⟨h, hh, hmin⟩ := H.exists_min_image cost hH
  refine ⟨h, ⟨hh, hmin⟩, ?_⟩
  rintro y ⟨hy, hymin⟩
  apply hinj hy hh
  exact le_antisymm (hymin h hh) (hmin y hy)

/-- Analytic source-level repair of **lemma:bk7_budgetlimited_minimizer**.
A nonempty compact admissible regulator class and a lower-semicontinuous
candidate-dependent cost supply existence; strict convexity supplies
uniqueness. This is the ordinary compact-topological kernel of the printed
weak-star theorem, without pretending that Lean has manufactured a weak-star
topology or proved compactness of a derivative-bounded regulator class. -/
theorem budgetLimited_existsUniqueMinimizer_of_compact
    {E : Type*} [TopologicalSpace E] [AddCommMonoid E] [Module ℝ E]
    (admissible : Set E) (hne : admissible.Nonempty)
    (hcompact : IsCompact admissible) (cost : E → ℝ)
    (hlsc : LowerSemicontinuousOn cost admissible)
    (hstrict : StrictConvexOn ℝ admissible cost) :
    ∃! x : E, x ∈ admissible ∧ IsMinOn cost admissible x := by
  obtain ⟨x, hx, hxmin⟩ := hlsc.exists_isMinOn hne hcompact
  refine ⟨x, ⟨hx, hxmin⟩, ?_⟩
  rintro y ⟨hy, hymin⟩
  exact hstrict.eq_of_isMinOn hymin hxmin hy hx

/- ================================================================
   definition:bk7_reciprocity_domain,
   proposition:bk7_structural_properties_of_reciprocity_domain,
   lemma:bk7_non_triviality_via_convergence_potential,
   definition:bk7_time_varying_reciprocity_domain
   ================================================================ -/

/-- The reciprocity domain between two symbolic systems
(definition:bk7_reciprocity_domain): joint states where mutual reflection
is within tolerance of self-consistency. Applying this pointwise at each
time `t` (with time-dependent `reflectA`, `reflectB`, `epsA`, `epsB`) is
exactly definition:bk7_time_varying_reciprocity_domain; no separate
definition is needed. -/
def ReciprocityDomain {A B : Type} [PseudoMetricSpace A] [PseudoMetricSpace B]
    (reflectA : B → A) (reflectB : A → B) (epsA epsB : Real) : Set (A × B) :=
  {p | dist (reflectA p.2) p.1 < epsA ∧ dist (reflectB p.1) p.2 < epsB}

/-- Structural property (2), Contains Fixed Points: a joint fixed point of
the mutual reflections lies in the reciprocity domain for every positive
choice of tolerances. -/
theorem reciprocity_contains_fixed_point {A B : Type} [PseudoMetricSpace A] [PseudoMetricSpace B]
    (reflectA : B → A) (reflectB : A → B) {x : A} {y : B}
    (hx : reflectA y = x) (hy : reflectB x = y) (epsA epsB : Real)
    (hA : 0 < epsA) (hB : 0 < epsB) :
    (x, y) ∈ ReciprocityDomain reflectA reflectB epsA epsB := by
  constructor
  · show dist (reflectA y) x < epsA
    rw [hx, dist_self]; exact hA
  · show dist (reflectB x) y < epsB
    rw [hy, dist_self]; exact hB

/-- Structural property (1), Topological Openness: if the reflection
operators are continuous, the reciprocity domain is an open subset of the
product manifold. -/
theorem reciprocityDomain_isOpen {A B : Type} [PseudoMetricSpace A] [PseudoMetricSpace B]
    (reflectA : B → A) (reflectB : A → B) (hA : Continuous reflectA) (hB : Continuous reflectB)
    (epsA epsB : Real) :
    IsOpen (ReciprocityDomain reflectA reflectB epsA epsB) := by
  have h1 : IsOpen {p : A × B | dist (reflectA p.2) p.1 < epsA} :=
    isOpen_Iio.preimage ((hA.comp continuous_snd).dist continuous_fst)
  have h2 : IsOpen {p : A × B | dist (reflectB p.1) p.2 < epsB} :=
    isOpen_Iio.preimage ((hB.comp continuous_fst).dist continuous_snd)
  exact h1.inter h2

/-- Structural property (5), Information-Theoretic Interpretation, in the
honest equal-tolerance case `epsA = epsB = eps`: the reciprocity domain is
exactly the preimage of `[0,eps)` under the distance-to-reciprocity
function `r`. The source's stated general form (distinct `epsA`, `epsB`
collapsed via a single `eps = max{epsA,epsB}`) does not hold as an exact
set equality in general; only the equal-tolerance specialization is
provably exact, and that gap is noted rather than papered over. -/
theorem reciprocityDomain_eq_preimage_of_eq_eps {A B : Type} [PseudoMetricSpace A]
    [PseudoMetricSpace B] (reflectA : B → A) (reflectB : A → B) (eps : Real) :
    ReciprocityDomain reflectA reflectB eps eps =
      {p : A × B | max (dist (reflectA p.2) p.1) (dist (reflectB p.1) p.2) < eps} := by
  ext p
  constructor
  · rintro ⟨h1, h2⟩
    exact max_lt h1 h2
  · intro h
    exact ⟨lt_of_le_of_lt (le_max_left _ _) h, lt_of_le_of_lt (le_max_right _ _) h⟩

/-- Non-triviality (lemma:bk7_non_triviality_via_convergence_potential): the
reciprocity domain is nonempty whenever the coupled reflective interaction
has a joint fixed point. The source's antecedent is "the joint free energy
has a minimum and the interaction operator decreases it"; the load-bearing
but unstated step -- that such a minimizer is itself a fixed point of the
interaction -- is promoted to an explicit hypothesis here rather than left
implicit. -/
theorem reciprocityDomain_nonempty_of_fixed_point {A B : Type} [PseudoMetricSpace A]
    [PseudoMetricSpace B] (reflectA : B → A) (reflectB : A → B) {x : A} {y : B}
    (hx : reflectA y = x) (hy : reflectB x = y) (epsA epsB : Real)
    (hA : 0 < epsA) (hB : 0 < epsB) :
    (ReciprocityDomain reflectA reflectB epsA epsB).Nonempty :=
  ⟨(x, y), reciprocity_contains_fixed_point reflectA reflectB hx hy epsA epsB hA hB⟩

/- ================================================================
   lemma:bk7_coherence_window, definition:bk7_frame_temperature_quotient
   ================================================================ -/

/-- The coherence-window bound (lemma:bk7_coherence_window) as an iff-form
threshold rewrite: `N <= B_R*deltaO/||Delta D||` exactly when
`N*||Delta D|| <= B_R*deltaO`, clearing the (positive) drift-norm
denominator. -/
theorem coherenceWindow_iff {BR deltaO normDrift N : Real} (hnorm : 0 < normDrift) :
    N ≤ (BR * deltaO) / normDrift ↔ N * normDrift ≤ BR * deltaO := by
  rw [le_div_iff₀ hnorm]

/-- The frame-temperature quotient (definition:bk7_frame_temperature_quotient)
`xi = T/T_F(eps)` is strictly increasing in `eps` whenever the
frame-resolution temperature `T_F` is strictly decreasing there: coarser
frames (smaller `T_F`) make a fixed system relatively hotter. -/
theorem frameTempQuotient_mono {T : Real} (hT : 0 < T) {TF1 TF2 : Real}
    (hpos1 : 0 < TF1) (hpos2 : 0 < TF2) (hlt : TF2 < TF1) :
    T / TF1 < T / TF2 := by
  rw [div_lt_div_iff₀ hpos1 hpos2]
  exact mul_lt_mul_of_pos_left hlt hT

/- ================================================================
   definition:appC_horizon_fluxes
   ================================================================ -/

/-- The pointwise algebraic identity underlying
definition:appC_horizon_fluxes's divergence-theorem remark: the generative
part (positive divergence) minus the stabilizing part (negative divergence,
sign-flipped) recovers the signed value exactly. Only this real-analytic
core is modeled; the observer measure and manifold integral themselves are
not. -/
theorem posPart_sub_negPart (x : Real) : max x 0 - max (-x) 0 = x := by
  rcases le_total 0 x with h | h
  · rw [max_eq_left h, max_eq_right (by linarith : -x ≤ 0)]; ring
  · rw [max_eq_right h, max_eq_left (by linarith : 0 ≤ -x)]; ring

/- ================================================================
   definition:appC_modal_transference_map, theorem:appC_modal_transference
   ================================================================ -/

/-- A quasi-Lipschitz map between metric spaces, the honest kernel of
definition:appC_modal_transference_map's "observer-bounded distortion"
clause: displacement is controlled by a Lipschitz factor `L` plus an
observer-resolution slack `eps`. The ordinal-preservation and
operator-semi-conjugacy clauses are not modeled (they need the order and
the emergence operator `E`). -/
structure QuasiLipschitz (X Y : Type) [PseudoMetricSpace X] [PseudoMetricSpace Y] where
  f : X → Y
  L : Real
  eps : Real
  L_nonneg : 0 ≤ L
  eps_nonneg : 0 ≤ eps
  bound : ∀ x y, dist (f x) (f y) ≤ L * dist x y + eps

/-- theorem:appC_modal_transference's transitivity content: composing two
observer-bounded-distortion transference maps yields another one, with
distortion propagating exactly as `L = L1*L2`, `eps = L1*eps2 + eps1`. This
is the quantitative kernel behind "invariants transfer up to observer
resolution" across a chain of modalities. -/
theorem quasiLipschitz_comp {X Y Z : Type} [PseudoMetricSpace X] [PseudoMetricSpace Y]
    [PseudoMetricSpace Z] (g : QuasiLipschitz Y Z) (f : QuasiLipschitz X Y) (x y : X) :
    dist (g.f (f.f x)) (g.f (f.f y)) ≤ g.L * f.L * dist x y + (g.L * f.eps + g.eps) := by
  calc dist (g.f (f.f x)) (g.f (f.f y)) ≤ g.L * dist (f.f x) (f.f y) + g.eps := g.bound _ _
    _ ≤ g.L * (f.L * dist x y + f.eps) + g.eps := by
        have := f.bound x y
        nlinarith [mul_le_mul_of_nonneg_left this g.L_nonneg]
    _ = g.L * f.L * dist x y + (g.L * f.eps + g.eps) := by ring

/- ================================================================
   lemma:appC_fibonacci_structure_matrix_powers,
   theorem:appC_phi_from_lagrangian, theorem:appC_phi_as_spectral_radius,
   theorem:appC_modal_transference (golden-ratio tail)
   ================================================================ -/

/-- The 2x2 growth matrix of lemma:appC_fibonacci_structure_matrix_powers. -/
def fibMatrix : Matrix (Fin 2) (Fin 2) Nat := !![1, 1; 1, 0]

/-- `fibMatrix^(n+1) = [[fib(n+2), fib(n+1)], [fib(n+1), fib n]]`, the
`n >= 1` claim of lemma:appC_fibonacci_structure_matrix_powers reindexed by
`n |-> n+1` to avoid `Nat` subtraction at the excluded case `n = 0`. -/
theorem fibMatrix_pow_succ (n : Nat) :
    fibMatrix ^ (n + 1) = !![Nat.fib (n + 2), Nat.fib (n + 1); Nat.fib (n + 1), Nat.fib n] := by
  induction n with
  | zero => decide
  | succ n ih =>
      have h1 : Nat.fib (n + 1 + 2) = Nat.fib (n + 1) + Nat.fib (n + 2) := Nat.fib_add_two
      have h2 : Nat.fib (n + 1 + 1) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
      rw [pow_succ, ih]
      unfold fibMatrix
      rw [Matrix.mul_fin_two]
      ext i j
      fin_cases i <;> fin_cases j <;> simp <;> omega

/-- The canonical positive-initial-data instance of the two-step balanced
closure `C(n+1) = C(n) + C(n-1)` (theorem:appC_phi_from_lagrangian) is the
shifted Fibonacci sequence `C n := fib(n+1)` (so `C 0 = C 1 = 1 > 0`); its
growth ratios `C(n+1)/C(n) = fib(n+2)/fib(n+1)` converge to the golden
ratio, citing Mathlib's Binet-formula proof of the unshifted statement.
This is also the honest kernel of theorem:appC_phi_as_spectral_radius's
spectral-radius claim (the growth rate of the sequence, without formalizing
the operator norm/spectral radius itself) and of theorem:appC_modal_transference's
golden-ratio tail clause. Generalizing from this canonical instance to
arbitrary positive initial data `C_0, C_1 > 0` is not attempted, a further
honesty gap noted here. -/
theorem shiftedFib_ratio_tendsto_goldenRatio :
    Filter.Tendsto (fun n : Nat => (Nat.fib (n + 1 + 1) : Real) / Nat.fib (n + 1))
      Filter.atTop (nhds Real.goldenRatio) :=
  tendsto_fib_succ_div_fib_atTop.comp (Filter.tendsto_add_atTop_nat 1)

/- ================================================================
   definition:appC_bounded_symbolic_observer_dynamics,
   lemma:appC_geometric_interpretation_curvature
   ================================================================ -/

/-- The total symbolic effort `kappa(theta) = theta + 1/theta`
(lemma:appC_geometric_interpretation_curvature, combining
definition:appC_bounded_symbolic_observer_dynamics's forward-drift rate
`theta` and reflective-curvature-penalty `1/theta`) is bounded below by `2`
for every positive drift rate -- the AM-GM inequality underlying "bounded
memory imposes a curvature penalty". -/
theorem symbolicEffort_ge_two {theta : Real} (h : 0 < theta) : 2 ≤ theta + theta⁻¹ := by
  have hinv : theta * theta⁻¹ = 1 := mul_inv_cancel₀ h.ne'
  nlinarith [sq_nonneg (theta - 1), hinv, h]

/-- Equality in the effort bound holds exactly at unit drift rate: minimal
symbolic effort is achieved when forward drift and reflective curvature
penalty are perfectly balanced. -/
theorem symbolicEffort_eq_two_iff {theta : Real} (h : 0 < theta) :
    theta + theta⁻¹ = 2 ↔ theta = 1 := by
  constructor
  · intro heq
    have hinv : theta * theta⁻¹ = 1 := mul_inv_cancel₀ h.ne'
    nlinarith [sq_nonneg (theta - 1), hinv, heq]
  · intro heq; rw [heq]; norm_num

/- ================================================================
   definition:bk2_symbolic_hamiltonian, lemma:bk2_wellposedness_symb_hamiltonian
   ================================================================ -/

/-- The regularized denominator `||D(x)||_g + eps` of the symbolic
Hamiltonian (definition:bk2_symbolic_hamiltonian) is always positive,
exactly the real-analytic core of lemma:bk2_wellposedness_symb_hamiltonian's
well-definedness claim. Smoothness of `H` itself needs the manifold
structure and is not modeled. -/
theorem hamiltonian_denom_pos {normD eps : Real} (hnorm : 0 ≤ normD) (heps : 0 < eps) :
    0 < normD + eps := by
  linarith

/- ================================================================
   definition:appC_bounded_observation_frame, definition:appC_complexity_measure
   ================================================================ -/

/-- The complexity measure `C(t) = dim(span(F_delta(t) inter learned_basis(t)))`
(definition:appC_complexity_measure, over the bounded observation frame
`F_delta(t)` of definition:appC_bounded_observation_frame) has its
finite combinatorial skeleton here: the intersection of two finite index
sets is no larger than either factor, `Finset.card` standing in for
`dim span`. -/
theorem complexity_card_le {S : Type} [DecidableEq S] (frame basis : Finset S) :
    (frame ∩ basis).card ≤ frame.card ∧ (frame ∩ basis).card ≤ basis.card :=
  ⟨Finset.card_le_card Finset.inter_subset_left, Finset.card_le_card Finset.inter_subset_right⟩

/- ================================================================
   definition:bk3_conceptual_bridge_sequence,
   theorem:bk3_closure_conceptual_bridge_sequence
   ================================================================ -/

/-- The conceptual bridge sequence (definition:bk3_conceptual_bridge_sequence)
`M -> sigma -> Sigma -> N -> M_meta`, with the honest reading of "can form a
closed loop, meta-level membrane feeding back into the originals"
(theorem:bk3_closure_conceptual_bridge_sequence) taken literally: the
composite of all four bridge maps is the identity on `M`. -/
structure ConceptualBridgeLoop (M Sigma1 Sigma2 N : Type) where
  toSigma1 : M → Sigma1
  toSigma2 : Sigma1 → Sigma2
  toN : Sigma2 → N
  toM : N → M
  closes : ∀ x, toM (toN (toSigma2 (toSigma1 x))) = x

/-- Closure of the loop forces every map along the way in from `M` to be
injective: no symbolic content is lost in the forward direction. -/
theorem conceptualBridgeLoop_toSigma1_injective {M Sigma1 Sigma2 N : Type}
    (L : ConceptualBridgeLoop M Sigma1 Sigma2 N) : Function.Injective L.toSigma1 := by
  intro a b hab
  have ha := L.closes a
  have hb := L.closes b
  rw [hab] at ha
  exact ha.symm.trans hb

/-- Closure of the loop forces the meta-level return map `toM` to be
surjective onto `M`: the feedback into the original membranes reaches
every original state. -/
theorem conceptualBridgeLoop_toM_surjective {M Sigma1 Sigma2 N : Type}
    (L : ConceptualBridgeLoop M Sigma1 Sigma2 N) : Function.Surjective L.toM :=
  fun y => ⟨L.toN (L.toSigma2 (L.toSigma1 y)), L.closes y⟩

/- ================================================================
   corollary:bk7_stability_innovation_equilibrium
   ================================================================ -/

/-- A contextual Book 4 curvature certificate and a Book 7 reflective
convergence certificate coexist: structural novelty need not be erased by
convergence to a stable identity. This is the dynamical kernel of the
stability–innovation equilibrium; optimization of the source's free-energy
functional remains a separate obligation. -/
theorem contextualCurvature_with_stableIdentity
    {X : Type} [PseudoMetricSpace X]
    (U : ℝ → ℝ → ℝ)
    (hgrowth : ¬ ∃ f : ℝ → ℝ, ∃ g : ℝ → ℝ,
      U = fun ξ χ => f ξ + g χ)
    {ε : ℝ} (hε : ε ≠ 0) (c : ContractiveReflection X) (x : X) :
    (∃ ξ χ,
      ForcingAnalysis.Atlas.routeAB ε
          (ForcingAnalysis.Book4D.crossErrorTransport
            (ForcingAnalysis.ScholiumC.crossTerm U ξ χ))
          ForcingAnalysis.Book4D.contextTransport ≠
        ForcingAnalysis.Atlas.routeBA ε
          (ForcingAnalysis.Book4D.crossErrorTransport
            (ForcingAnalysis.ScholiumC.crossTerm U ξ χ))
          ForcingAnalysis.Book4D.contextTransport) ∧
      Filter.Tendsto (fun n => dist (c.reflect^[n] x) c.star)
        Filter.atTop (nhds 0) := by
  exact ⟨ForcingAnalysis.Book4D.contextualStructuralGrowth_induces_curvature
      U hgrowth hε,
    contractiveReflection_tendsto_star c x⟩
end ForcingAnalysis.Book7B
