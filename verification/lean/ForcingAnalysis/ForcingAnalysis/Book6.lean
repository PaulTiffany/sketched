/-
Book6.lean - symbolic mutation / bifurcation dynamics, honest kernel.

Principia Book 6 is about symbolic mutation, bifurcation, recombination, and
mutation-reflection equilibria, almost entirely stated on a Riemannian
symbolic manifold `(M, g)` with a Levi-Civita connection, a Riemann curvature
tensor, a drift vector field `D`, a reflection diffeomorphism `R`, a
time-dependent density `ρ` solving a Fokker-Planck PDE, and a complex-valued
"symbolic state function" with Hilbert-space structure. This module does NOT
attempt manifold, curvature-tensor, PDE, or Hilbert-space formalizations. For
each anchor it extracts the honest static/algebraic/discrete kernel instead:

  * the mutation-threshold "iff" (definition:bk6_mutation_threshold) becomes a
    genuine signed-threshold equivalence: `|ΔF| > τ ↔ ΔF > τ ∨ ΔF < -τ`;
  * the bifurcation classification's signed rank-change
    (theorem:bk6_symbolic_bifurcation_classification) becomes a creation /
    annihilation / stationary trichotomy on an integer, with exhaustiveness
    and pairwise exclusivity as separate theorems;
  * the bifurcation-threshold case split
    (proposition:bk6_bifurcation_threshold) becomes the analogous
    no-bifurcation / bifurcates dichotomy on a real threshold comparison;
  * the structural divergence condition's proof chain
    (proposition:bk6_structural_divergence_condition) becomes the honest
    arithmetic chain `ε₀ * w < Sc * w` and `0 < ε₀ * w` from strict
    hypotheses;
  * reflective mutation inhibition (proposition:bk6_reflective_mutation_inhibition)
    becomes the epsilon-tightening argument in the limit: if the reflection
    operator is within *every* positive tolerance of the identity at a point,
    it is exactly the identity there (a genuine metric-space theorem, not the
    stated exponential-convergence ODE, which is not modeled);
  * reflective regulation of mutation (axiom:bk6_reflective_regulation_of_mutation)
    becomes the discrete consequence of "entropy does not increase under one
    reflection step": entropy does not increase under any finite number of
    iterated reflections either (induction on iterate count);
  * mutation memory (corollary:bk6_mutation_memory) and the symbolic
    regulatory cycle's bounded free-energy clause
    (definition:bk6_symbolic_regulatory_cycle) become discrete
    sequence/telescoping facts: a nonnegative-increment accumulator is
    monotone and nonnegative; a per-step free-energy bound telescopes to an
    n-step bound via the triangle inequality;
  * entropic dissolution (proposition:bk6_entropic_dissolution) becomes the
    discrete dual of a decrease-forces-termination bound: a sequence that
    increases by at least a fixed positive amount every step is unbounded
    above (a real number witnesses being exceeded after finitely many steps);
  * the symbolic configuration spaces' dimension clause
    (definition:bk6_symbolic_configuration_spaces) becomes monotonicity of
    `⌊λ⌋₊ + d₀` in `λ`, via `Nat.floor_mono`;
  * the identity carrier kernel's locality clause
    (definition:bk6_identity_carrier_kernel) becomes the genuine consequence
    that the exponential-decay bound forces `Ψ(x,y) ≤ Ψ(x,x)`;
  * symbolic temperature (definition:bk6_symbolic_temperature) becomes the
    real-inverse sign-preservation fact `0 < a⁻¹ ↔ 0 < a`;
  * the symbolic free-energy functional (definition:bk6_symbolic_free_energy_functional)
    becomes strict antitonicity of `E - T·S` in `S` when `T > 0`;
  * the transformation operator's group-composition clause
    (definition:bk6_transformation_operator_complete) becomes a genuine
    two-step composition identity and the induced bracketing-invariance
    corollary from associativity of the parameter operation;
  * the bifurcation operator's branching offset
    (definition:bk6_bifurcation_operator_complete, using the stability
    threshold of definition:bk6_stability_functional_complete) becomes
    positivity of `2·(γ_min - Υ)/λ_bif` whenever `Υ < γ_min`;
  * symbolic time irreversibility (axiom:bk6_symbolic_time_irreversibility_complete)
    becomes the fully general fact that a non-injective map admits no left
    inverse (retraction);
  * the mutation-bifurcation duality
    (proposition:bk6_mutation_bifurcation_duality, whose source proof chains
    three separate bridge equivalences among the mutation trigger of
    definition:bk6_symbolic_mutation, the tension threshold of
    proposition:bk6_bifurcation_threshold, and the determinant condition of
    definition:bk6_symbolic_bifurcation) becomes the honest transitivity-of-
    equivalences step itself, packaged so the source's proof shape is
    checked without asserting any of the three underlying (manifold-level)
    equivalences;
  * the regulatory basin's power-concentration clause
    (definition:bk6_regulatory_basin) becomes existence of an argmax over
    any nonempty finite index set;
  * the confidence field operator's own defining formula
    (definition:bk6_confidence_field_operator) supplies one genuine fact:
    the confidence value `exp(-β·H)` is always strictly positive;
  * finite closed-system power conservation follows from antisymmetric
    internal pairwise exchange, whose double sum cancels exactly;
  * the confidence-power bound follows from Gaussian locality and the
    confidence codomain [0,1] on any pseudometric state space;
  * conservation of symbolic information is the finite KL-invariance theorem
    under a bijective relabeling, the discrete change-of-variables kernel;
  * reflective coherence (axiom:bk6_reflective_coherence_complete) is kept as
    the definitional unfolding of the reflective-equilibrium set it defines,
    exactly as stated, with no further theorem forced on top.

Anchors that are purely differential-geometric (the symbolic manifold,
curvature tensor and its coordinate-index form, the Laplace-Beltrami and
Hamiltonian operators, the drift/reflection/flow/power/pressure/grace/
modulation/regulatory-basin operators' own defining formulas, the geodesic-
energy bounds), that require Hilbert-space/complex-
amplitude measure theory (the symbolic state function, identity-carrier
normalization, charge and action conservation, the thermodynamic-MAP
duality), that are PDEs (the symbolic density evolution equation, the
Fokker-Planck diffusion theorem), that are asymptotic/limit claims in `t`
(the mutation rate's `Δt → 0` limit, mutation equilibrium, equilibrium of
mutability, the drift-reflection correspondence's `O(‖R-Id‖²)` expansion, MAP
equilibrium invariance's `O(e^{-ηn})` decay, complete operator closure's
"arbitrarily small ε" closure), or that are pure taxonomy/narrative listings
with no independent quantitative content (the symbolic system tuple, the
symbolic operator canon and complete canonical set, both mutation-operator
composition definitions, symbolic recombination's curvature/inner-product
schema, the reflective capacity supremum over an unspecified domain, power
scaling's fractal-dimension law, confidence stratification and its gradient
flow, the fragmentation functional's own double-integral ratio, and the mass/thermodynamic-consistency/confidence-stability axioms)
are left unformalized and listed as open anchors in the accompanying
proposal, rather than forced into decorative theorems.
-/

import Mathlib
import ForcingAnalysis.Book3

namespace ForcingAnalysis.Book6

/- ================================================================
   definition:bk6_mutation_threshold
   ================================================================ -/

/-- Mutation-threshold data (definition:bk6_mutation_threshold): the free
energy perturbation `deltaF` and the positive threshold `tau`. Only the
stated scalar threshold law is modeled; the manifold-level free-energy
functional `F[M,ρ]` it is derived from is not. -/
structure MutationThresholdLaw where
  deltaF : Real
  tau : Real
  tau_pos : 0 < tau

/-- A mutation is triggered exactly when `|ΔF|` exceeds the threshold, per
the source's defining "iff". -/
def MutationTriggered (L : MutationThresholdLaw) : Prop := L.tau < |L.deltaF|

/-- The signed form of the mutation-threshold condition: exceeding the
threshold in absolute value is exactly exceeding it on the positive side or
falling below its negation. -/
theorem mutationTriggered_iff_signed (L : MutationThresholdLaw) :
    MutationTriggered L ↔ L.deltaF > L.tau ∨ L.deltaF < -L.tau := by
  unfold MutationTriggered
  rw [lt_abs]
  constructor
  · rintro (h | h)
    · exact Or.inl h
    · exact Or.inr (by linarith)
  · rintro (h | h)
    · exact Or.inl h
    · exact Or.inr (by linarith)

/- ================================================================
   theorem:bk6_symbolic_bifurcation_classification
   ================================================================ -/

/-- Rank-change data for a bifurcation event
(theorem:bk6_symbolic_bifurcation_classification): the Hessian rank just
after and just before `t*`. Only the signed rank change `B(t*)` and its
classification are modeled; the Hessian operator-norm discontinuity itself
is not. -/
structure BifurcationRankChange where
  rankBefore : Nat
  rankAfter : Nat

/-- The signed rank change `B(t*) = rank(after) - rank(before)`. -/
def BifurcationRankChange.signedChange (b : BifurcationRankChange) : Int :=
  (b.rankAfter : Int) - (b.rankBefore : Int)

/-- `B(t*) > 0`: a creation bifurcation. -/
def IsCreation (b : BifurcationRankChange) : Prop := 0 < b.signedChange

/-- `B(t*) < 0`: an annihilation bifurcation. -/
def IsAnnihilation (b : BifurcationRankChange) : Prop := b.signedChange < 0

/-- `B(t*) = 0`: no topological change. -/
def IsStationary (b : BifurcationRankChange) : Prop := b.signedChange = 0

/-- The classification is exhaustive: every rank change is a creation, an
annihilation, or stationary. -/
theorem bifurcation_classification_exhaustive (b : BifurcationRankChange) :
    IsCreation b ∨ IsAnnihilation b ∨ IsStationary b := by
  rcases lt_trichotomy b.signedChange 0 with h | h | h
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr h)
  · exact Or.inl h

/-- The three classes are pairwise mutually exclusive. -/
theorem bifurcation_classification_exclusive (b : BifurcationRankChange) :
    ¬ (IsCreation b ∧ IsAnnihilation b) ∧
    ¬ (IsCreation b ∧ IsStationary b) ∧
    ¬ (IsAnnihilation b ∧ IsStationary b) := by
  unfold IsCreation IsAnnihilation IsStationary
  refine ⟨?_, ?_, ?_⟩ <;> rintro ⟨h1, h2⟩ <;> linarith

/- ================================================================
   proposition:bk6_bifurcation_threshold
   ================================================================ -/

/-- No bifurcation: the contradictory tension stays below the critical
threshold (proposition:bk6_bifurcation_threshold). -/
def NoBifurcation (tau tauC : Real) : Prop := tau < tauC

/-- Bifurcation occurs: the tension reaches or exceeds the critical
threshold. -/
def Bifurcates (tau tauC : Real) : Prop := tauC ≤ tau

/-- The tension-vs-threshold case split is exhaustive. -/
theorem bifurcation_threshold_dichotomy (tau tauC : Real) :
    NoBifurcation tau tauC ∨ Bifurcates tau tauC :=
  lt_or_ge tau tauC

/-- The two cases are mutually exclusive. -/
theorem bifurcation_threshold_exclusive (tau tauC : Real) :
    ¬ (NoBifurcation tau tauC ∧ Bifurcates tau tauC) := by
  unfold NoBifurcation Bifurcates
  rintro ⟨h1, h2⟩; linarith

/- ================================================================
   proposition:bk6_structural_divergence_condition
   ================================================================ -/

/-- Structural divergence data (proposition:bk6_structural_divergence_condition):
a scalar curvature strictly above a threshold `epsilon0`, and a positive
weight `weight` standing in for `∫(∇·D)ρ`. Only the arithmetic chain the
source's proof performs on these scalars is modeled; the divergence integral
and volume form themselves are not. -/
structure DivergenceLaw where
  scalarCurvature : Real
  epsilon0 : Real
  epsilon0_pos : 0 < epsilon0
  curvature_gt : epsilon0 < scalarCurvature
  weight : Real
  weight_pos : 0 < weight

/-- The source's rate chain `dF/dt = Sc · w > ε₀ · w > 0`. -/
theorem divergenceLaw_energy_rate_pos (L : DivergenceLaw) :
    L.epsilon0 * L.weight < L.scalarCurvature * L.weight ∧
      0 < L.epsilon0 * L.weight :=
  ⟨mul_lt_mul_of_pos_right L.curvature_gt L.weight_pos,
    mul_pos L.epsilon0_pos L.weight_pos⟩

/- ================================================================
   proposition:bk6_reflective_mutation_inhibition
   ================================================================ -/

/-- If the reflection operator is within *every* positive tolerance `δ` of
the identity at a point `x` (proposition:bk6_reflective_mutation_inhibition's
inhibition condition, quantified over all thresholds rather than one fixed
`δ`), it is exactly the identity there. This is the honest limiting content
of the stated exponential convergence to the reflective equilibrium
manifold `E_R`; the convergence rate itself is not modeled. -/
theorem reflective_inhibition_limit {X : Type} [MetricSpace X] (R : X → X)
    (h : ∀ δ : Real, 0 < δ → ∀ x, dist (R x) x < δ) (x : X) : R x = x := by
  have hd : dist (R x) x = 0 := by
    by_contra hne
    have hpos : 0 < dist (R x) x := lt_of_le_of_ne dist_nonneg (Ne.symm hne)
    have := h (dist (R x) x) hpos x
    linarith
  exact dist_eq_zero.mp hd

/- ================================================================
   axiom:bk6_reflective_regulation_of_mutation
   ================================================================ -/

/-- Entropy-regulation data (axiom:bk6_reflective_regulation_of_mutation): a
reflection map that never increases entropy in a single application. Only
this per-step monotonicity is modeled; the damping-coefficient formula
`η(t) = -dS/dt` is not. -/
structure EntropyRegulation (X : Type) where
  entropy : X → Real
  reflect : X → X
  entropy_le : ∀ p, entropy (reflect p) ≤ entropy p

/-- Entropy does not increase under any finite number of iterated
reflections either. -/
theorem entropyRegulation_iterate_le {X : Type} (E : EntropyRegulation X)
    (p : X) (n : Nat) : E.entropy (E.reflect^[n] p) ≤ E.entropy p := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep : E.reflect^[k + 1] p = E.reflect (E.reflect^[k] p) :=
        Function.iterate_succ_apply' E.reflect k p
      rw [hstep]
      exact le_trans (E.entropy_le _) ih

/- ================================================================
   corollary:bk6_mutation_memory
   ================================================================ -/

/-- Mutation-memory data (corollary:bk6_mutation_memory): a step-indexed
accumulator with nonnegative increments. Only this discrete accumulation
law is modeled; the underlying curvature-discontinuity path integral is
not. -/
structure MutationMemory where
  mem : Nat → Real
  step : Nat → Real
  step_nonneg : ∀ n, 0 ≤ step n
  mem_zero : mem 0 = 0
  mem_succ : ∀ n, mem (n + 1) = mem n + step n

/-- Mutation memory is monotone nondecreasing. -/
theorem mutationMemory_monotone (M : MutationMemory) (n : Nat) :
    M.mem n ≤ M.mem (n + 1) := by
  rw [M.mem_succ]; linarith [M.step_nonneg n]

/-- Mutation memory is always nonnegative. -/
theorem mutationMemory_nonneg (M : MutationMemory) (n : Nat) : 0 ≤ M.mem n := by
  induction n with
  | zero => rw [M.mem_zero]
  | succ k ih => rw [M.mem_succ]; linarith [M.step_nonneg k]

/- ================================================================
   proposition:bk6_entropic_dissolution
   ================================================================ -/

/-- Entropy-growth data (proposition:bk6_entropic_dissolution): a
step-indexed entropy sequence that increases by at least a fixed positive
amount every step. Only this discrete growth law is modeled; the underlying
`dS/dt = ∫(μ-η)ρ` integral is not. -/
structure EntropyGrowth where
  entropy : Nat → Real
  delta : Real
  delta_pos : 0 < delta
  growing : ∀ n, entropy n + delta ≤ entropy (n + 1)

/-- Telescoped growth bound, by induction on the number of steps. -/
theorem entropyGrowth_accum (G : EntropyGrowth) (n : Nat) :
    G.entropy 0 + (n : Real) * G.delta ≤ G.entropy n := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep := G.growing k
      have hcast : ((k + 1 : Nat) : Real) * G.delta = (k : Real) * G.delta + G.delta := by
        push_cast; ring
      rw [hcast]
      linarith

/-- Entropic dissolution: a sequence that grows by a fixed positive amount
every step is unbounded above. This is the discrete honest kernel of the
source's `lim_{t→∞} S[ρ(t)] = ∞` claim. -/
theorem entropyGrowth_unbounded (G : EntropyGrowth) (B : Real) :
    ∃ n : Nat, B < G.entropy n := by
  obtain ⟨n, hn⟩ := exists_nat_gt ((B - G.entropy 0) / G.delta)
  have hn' : (B - G.entropy 0) < (n : Real) * G.delta := (div_lt_iff₀ G.delta_pos).mp hn
  have hacc := entropyGrowth_accum G n
  exact ⟨n, by linarith⟩

/- ================================================================
   definition:bk6_symbolic_regulatory_cycle
   ================================================================ -/

/-- Regulatory-cycle free-energy data (definition:bk6_symbolic_regulatory_cycle):
a step-indexed free-energy sequence with a per-step bound `|F(n+1)-F(n)| < ε`.
Only this bound is modeled; the drift/reflection/transformation triple that
produces each step is not. -/
structure RegulatoryCycleBound where
  freeEnergy : Nat → Real
  eps : Real
  step_bound : ∀ n, |freeEnergy (n + 1) - freeEnergy n| < eps

/-- The per-step bound telescopes: after `n` cycle steps, total free-energy
drift is at most `n · ε`, by the triangle inequality and induction. -/
theorem regulatoryCycle_energy_bound (C : RegulatoryCycleBound) (n : Nat) :
    |C.freeEnergy n - C.freeEnergy 0| ≤ (n : Real) * C.eps := by
  induction n with
  | zero => simp
  | succ k ih =>
      have heq : C.freeEnergy (k + 1) - C.freeEnergy 0 =
          (C.freeEnergy (k + 1) - C.freeEnergy k) + (C.freeEnergy k - C.freeEnergy 0) := by
        ring
      have htri : |C.freeEnergy (k + 1) - C.freeEnergy 0| ≤
          |C.freeEnergy (k + 1) - C.freeEnergy k| + |C.freeEnergy k - C.freeEnergy 0| := by
        rw [heq]; exact abs_add_le _ _
      have hstep := (C.step_bound k).le
      have hcast : ((k + 1 : Nat) : Real) * C.eps = (k : Real) * C.eps + C.eps := by
        push_cast; ring
      rw [hcast]
      linarith

/- ================================================================
   definition:bk6_symbolic_configuration_spaces
   ================================================================ -/

/-- The configuration-space dimension at complexity level `lam`
(definition:bk6_symbolic_configuration_spaces): `⌊λ⌋₊ + d₀`. Only this
dimension formula is modeled; the submanifold nesting `P_λ ⊂ P_λ'` and the
induced Riemannian structure are not. -/
noncomputable def configDim (d0 : Nat) (lam : Real) : Nat := ⌊lam⌋₊ + d0

/-- Dimension is monotone nondecreasing in the complexity level, matching
the source's `P_λ ⊂ P_λ'` for `λ < λ'`. -/
theorem configDim_mono (d0 : Nat) {lam lam' : Real} (h : lam ≤ lam') :
    configDim d0 lam ≤ configDim d0 lam' := by
  unfold configDim
  have := Nat.floor_mono h
  omega

/-- Dimension is always at least the base dimension `d₀`. -/
theorem configDim_ge (d0 : Nat) (lam : Real) : d0 ≤ configDim d0 lam := by
  unfold configDim; omega

/- ================================================================
   definition:bk6_identity_carrier_kernel
   ================================================================ -/

/-- Identity-carrier kernel data (definition:bk6_identity_carrier_kernel):
the locality bound `Ψ(x,y) ≤ Ψ(x,x)·exp(-d(x,y)/λᵢ)`. Only this bound (and
the nonnegativity of `Ψ` and of the correlation length) is modeled; the
normalization and symmetry clauses, which need a volume measure, are not. -/
structure IdentityCarrierKernel (X : Type) where
  psi : X → X → Real
  psi_nonneg : ∀ x y, 0 ≤ psi x y
  d : X → X → Real
  d_nonneg : ∀ x y, 0 ≤ d x y
  lambdaI : Real
  lambdaI_pos : 0 < lambdaI
  locality : ∀ x y, psi x y ≤ psi x x * Real.exp (-(d x y / lambdaI))

/-- The locality bound forces `Ψ(x,y) ≤ Ψ(x,x)`: the identity carrier never
exceeds its self-correlation value. -/
theorem identityCarrier_le_self {X : Type} (K : IdentityCarrierKernel X) (x y : X) :
    K.psi x y ≤ K.psi x x := by
  have hdiv : 0 ≤ K.d x y / K.lambdaI := div_nonneg (K.d_nonneg x y) K.lambdaI_pos.le
  have hneg : -(K.d x y / K.lambdaI) ≤ 0 := neg_nonpos.mpr hdiv
  have hexp : Real.exp (-(K.d x y / K.lambdaI)) ≤ 1 := by
    calc Real.exp (-(K.d x y / K.lambdaI)) ≤ Real.exp 0 := Real.exp_le_exp.mpr hneg
      _ = 1 := Real.exp_zero
  calc K.psi x y ≤ K.psi x x * Real.exp (-(K.d x y / K.lambdaI)) := K.locality x y
    _ ≤ K.psi x x * 1 := mul_le_mul_of_nonneg_left hexp (K.psi_nonneg x x)
    _ = K.psi x x := mul_one _

/- ================================================================
   definition:bk6_symbolic_temperature
   ================================================================ -/

/-- Symbolic temperature is defined as the inverse of `∂S/∂E`
(definition:bk6_symbolic_temperature); its positivity constraint
`T_s(p) > 0` is exactly positivity of `∂S/∂E`. -/
theorem temperature_pos_iff (dSdE : Real) : 0 < dSdE⁻¹ ↔ 0 < dSdE := inv_pos

/- ================================================================
   definition:bk6_symbolic_free_energy_functional
   ================================================================ -/

/-- The symbolic free-energy functional `F = E - T·S`
(definition:bk6_symbolic_free_energy_functional). -/
def freeEnergyOf (E T S : Real) : Real := E - T * S

/-- At fixed energy and positive temperature, free energy strictly
decreases as entropy strictly increases. -/
theorem freeEnergy_antitone_in_entropy {E T S1 S2 : Real} (hT : 0 < T) (h : S1 < S2) :
    freeEnergyOf E T S2 < freeEnergyOf E T S1 := by
  unfold freeEnergyOf
  have hmul : T * S1 < T * S2 := mul_lt_mul_of_pos_left h hT
  linarith

/- ================================================================
   definition:bk6_transformation_operator_complete
   ================================================================ -/

/-- Transformation-operator family data
(definition:bk6_transformation_operator_complete): a parameterized family
`T : A → X → X` satisfying the group-composition law `T_a ∘ T_b = T_{a⊕b}`.
Only this composition clause is modeled; complexity conservation and the
stability-preservation clause `Υᵢ(p, T_α(p)) > γ_min` are not. -/
structure TransformationFamily (A X : Type) (op : A → A → A) where
  T : A → X → X
  compose_law : ∀ a b x, T a (T b x) = T (op a b) x

/-- Two-step composition collapses to a single application at the
combined parameter. -/
theorem transformationFamily_triple {A X : Type} {op : A → A → A}
    (F : TransformationFamily A X op) (a b c : A) (x : X) :
    F.T a (F.T b (F.T c x)) = F.T (op a (op b c)) x := by
  rw [F.compose_law b c x, F.compose_law a (op b c) x]

/-- If the parameter operation `⊕` is associative, the two bracketings of a
three-fold composition agree, so the family is genuinely a monoid action on
`X` rather than merely a two-argument composition law. -/
theorem transformationFamily_bracketing_agrees {A X : Type} {op : A → A → A}
    (hassoc : ∀ a b c, op (op a b) c = op a (op b c))
    (F : TransformationFamily A X op) (a b c : A) (x : X) :
    F.T (op (op a b) c) x = F.T (op a (op b c)) x := by
  rw [hassoc]

/- ================================================================
   definition:bk6_bifurcation_operator_complete,
   definition:bk6_stability_functional_complete
   ================================================================ -/

/-- The bifurcation operator's branching offset
`sqrt(2(γ_min - Υᵢ(p,p))/λ_bif)` (definition:bk6_bifurcation_operator_complete)
is well-defined and strictly positive under the sub-threshold condition
`Υᵢ(p,p) < γ_min` from the stability functional's threshold
(definition:bk6_stability_functional_complete): the quantity under the
square root is strictly positive. The square root itself and the unstable
eigenmode projection are not modeled. -/
theorem bifurcation_offset_pos {upsilon gammaMin lambdaBif : Real}
    (h : upsilon < gammaMin) (hlam : 0 < lambdaBif) :
    0 < 2 * (gammaMin - upsilon) / lambdaBif := by
  apply div_pos
  · linarith
  · exact hlam

/- ================================================================
   axiom:bk6_symbolic_time_irreversibility_complete
   ================================================================ -/

/-- Symbolic time irreversibility
(axiom:bk6_symbolic_time_irreversibility_complete): no operator `T` undoes
the drift operator `D_λ`, i.e. `D_λ` has no left inverse (retraction). The
honest general fact underlying this: whenever a map fails to be injective,
no left inverse for it can exist at all. The converse direction (that the
symbolic drift operator specifically fails to be injective) is not asserted
unconditionally; it is the hypothesis under which the axiom's conclusion is
proved here. -/
theorem no_retraction_of_not_injective {X Y : Type} {D : X → Y}
    (hD : ¬ Function.Injective D) : ¬ ∃ T : Y → X, ∀ x, T (D x) = x := by
  rintro ⟨T, hT⟩
  apply hD
  intro x1 x2 hEq
  have := congrArg T hEq
  rwa [hT x1, hT x2] at this

/- ================================================================
   proposition:bk6_mutation_bifurcation_duality,
   definition:bk6_symbolic_mutation, definition:bk6_symbolic_bifurcation
   ================================================================ -/

/-- Mutation-bifurcation bridge data
(proposition:bk6_mutation_bifurcation_duality): the source's proof chains
three conditions -- the mutation trigger of definition:bk6_symbolic_mutation
(`‖D∘R - R∘D‖ > γ`), the contradictory-tension threshold of
proposition:bk6_bifurcation_threshold (`τ(x) ≥ τ_c`), and the determinant
condition of definition:bk6_symbolic_bifurcation (`det(J(t*)) = 0`) -- via
two separate bridge equivalences. Only the logical shape of that chaining is
modeled here: the two bridge equivalences are kept as hypotheses (fields),
since each depends on manifold-level structure (operator norms, the
Jacobian) not otherwise formalized in this file. -/
structure MutationBifurcationBridge where
  MutationCond : Prop
  TensionCond : Prop
  BifurcationCond : Prop
  mutation_iff_tension : MutationCond ↔ TensionCond
  tension_iff_bifurcation : TensionCond ↔ BifurcationCond

/-- The duality itself: mutation occurs iff bifurcation occurs, by
transitivity of the two bridge equivalences. This certifies the source
proof's logical structure (chaining two "iff"s into one), not the bridge
equivalences themselves. -/
theorem mutationBifurcationBridge_iff (Br : MutationBifurcationBridge) :
    Br.MutationCond ↔ Br.BifurcationCond :=
  Br.mutation_iff_tension.trans Br.tension_iff_bifurcation

/- ================================================================
   axiom:bk6_reflective_coherence_complete
   ================================================================ -/

/-- The reflective equilibrium set `E_R`
(axiom:bk6_reflective_coherence_complete): points where the reflection
operator is within `δ_R` of the identity. -/
def ReflectiveEquilibriumSet {X : Type} [MetricSpace X] (R : X → X) (deltaR : Real) :
    Set X := {p | dist (R p) p < deltaR}

/- ================================================================
   definition:bk6_regulatory_basin
   ================================================================ -/

/-- The regulatory basin's power-concentration clause
(definition:bk6_regulatory_basin): some point in the basin achieves the
maximal power value. Modeled as existence of an argmax over any nonempty
finite index set; the confidence-coherence and gradient-flow-convergence
clauses of the same definition are not modeled. -/
theorem regulatoryBasin_power_argmax_exists {ι : Type} (H : Finset ι)
    (hH : H.Nonempty) (power : ι → Real) :
    ∃ h ∈ H, ∀ h' ∈ H, power h' ≤ power h :=
  H.exists_max_image power hH

/- ================================================================
   definition:bk6_confidence_field_operator
   ================================================================ -/

/-- The confidence field `σ(p) = exp(-β·H_conf(p))`
(definition:bk6_confidence_field_operator) is always strictly positive,
regardless of the sign of `β·H_conf(p)`: symbolic confidence, in this
register, is never literally zero. The confidence Hamiltonian and the
threshold case-split producing `p'` are not modeled. -/
theorem confidence_sigma_pos (beta Hconf : Real) :
    0 < Real.exp (-(beta * Hconf)) := Real.exp_pos _

/- ================================================================
   axiom:bk6_power_conservation
   ================================================================ -/

/-- Total pairwise symbolic power on a finite closed system. -/
def totalPairPower {ι : Type} [Fintype ι] (power : ι → ι → Real) : Real :=
  ∑ i, ∑ j, power i j

/-- A closed power evolution changes each directed pair by an internal
exchange. Antisymmetry says every gain is another pair's loss. -/
structure ClosedPowerEvolution (ι : Type) [Fintype ι] where
  power : Nat → ι → ι → Real
  exchange : Nat → ι → ι → Real
  update : ∀ n i j, power (n + 1) i j = power n i j + exchange n i j
  exchange_antisymm : ∀ n i j, exchange n i j = -exchange n j i

/-- Internal antisymmetric exchanges have zero total contribution. -/
theorem closedPower_exchange_sum_zero {ι : Type} [Fintype ι]
    (P : ClosedPowerEvolution ι) (n : Nat) :
    (∑ i, ∑ j, P.exchange n i j) = 0 := by
  classical
  let S : Real := ∑ i, ∑ j, P.exchange n i j
  have hneg : S = -S := by
    calc
      S = ∑ i, ∑ j, -P.exchange n j i := by
        unfold S
        apply Finset.sum_congr rfl
        intro i _
        apply Finset.sum_congr rfl
        intro j _
        exact P.exchange_antisymm n i j
      _ = -(∑ i, ∑ j, P.exchange n j i) := by
        simp only [Finset.sum_neg_distrib]
      _ = -S := by
        unfold S
        rw [Finset.sum_comm]
  linarith

/-- Power Conservation: finite closed internal exchange preserves the double
sum of the pairwise power kernel at every step. -/
theorem closedPower_total_conserved {ι : Type} [Fintype ι]
    (P : ClosedPowerEvolution ι) (n : Nat) :
    totalPairPower (P.power (n + 1)) = totalPairPower (P.power n) := by
  classical
  unfold totalPairPower
  simp_rw [P.update, Finset.sum_add_distrib]
  rw [closedPower_exchange_sum_zero P n, add_zero]

/-- On a finite carrier, Book 6's total pair power is definitionally the
Book 3 metabolic rate. This is the explicit Book 3 → Book 6 interface. -/
theorem totalPairPower_eq_metabolicRate {n : Nat}
    (power : Fin n → Fin n → Real) :
    totalPairPower power = Book3.metabolicRate power := rfl

/-- A closed Book 6 power step preserves the Book 3 homeostatic band. -/
theorem closedPower_homeostatic_step {n : Nat}
    (P : ClosedPowerEvolution (Fin n)) (k : Nat) {rmin rmax : Real}
    (h : Book3.Homeostatic (Book3.metabolicRate (P.power k)) rmin rmax) :
    Book3.Homeostatic (Book3.metabolicRate (P.power (k + 1))) rmin rmax := by
  have hcon := closedPower_total_conserved P k
  rw [totalPairPower_eq_metabolicRate, totalPairPower_eq_metabolicRate] at hcon
  rwa [hcon]

/-- Consequently, initial Book 3 homeostasis persists through every finite
stage of a closed Book 6 power evolution. -/
theorem closedPower_homeostatic_all {n : Nat}
    (P : ClosedPowerEvolution (Fin n)) {rmin rmax : Real}
    (h0 : Book3.Homeostatic (Book3.metabolicRate (P.power 0)) rmin rmax) :
    ∀ k, Book3.Homeostatic (Book3.metabolicRate (P.power k)) rmin rmax := by
  intro k
  induction k with
  | zero => simpa using h0
  | succ k ih =>
      simpa [Nat.succ_eq_add_one] using closedPower_homeostatic_step P k ih
/- ================================================================
   theorem:bk6_confidence_power_bound
   ================================================================ -/

/-- Confidence-Power Bound: Gaussian locality and calibrated confidence in
`[0,1]` imply that confidence-weighting cannot exceed the same Gaussian power
envelope. This is exactly the scalar/metric argument used by the source. -/
theorem confidencePower_gaussian_bound {X : Type} [PseudoMetricSpace X]
    (σ : X → Real) (power : X → X → Real) (Pmax lambdaConf : Real)
    (hσ : ∀ p, 0 ≤ σ p ∧ σ p ≤ 1) (hPmax : 0 ≤ Pmax)
    (_hlambda : 0 < lambdaConf)
    (hlocal : ∀ p p', power p p' ≤
      Pmax * Real.exp (-(dist p p') ^ 2 / (2 * lambdaConf ^ 2)))
    (p p' : X) :
    σ p * power p p' ≤
      Pmax * Real.exp (-(dist p p') ^ 2 / (2 * lambdaConf ^ 2)) := by
  let envelope := Pmax * Real.exp (-(dist p p') ^ 2 / (2 * lambdaConf ^ 2))
  have henv : 0 ≤ envelope := mul_nonneg hPmax (Real.exp_pos _).le
  calc
    σ p * power p p' ≤ σ p * envelope :=
      mul_le_mul_of_nonneg_left (hlocal p p') (hσ p).1
    _ ≤ 1 * envelope := mul_le_mul_of_nonneg_right (hσ p).2 henv
    _ = envelope := one_mul _
/- ================================================================
   lemma:bk6_conservation_of_symbolic_information
   ================================================================ -/

/-!
The source's relative-information conservation lemma is stated for a
diffeomorphic change of variables on a symbolic manifold. The honest finite
kernel is invariance of the raw finite KL sum under a bijective relabelling of
the state space. The analytic measure/Jacobian content remains outside this
module.
-/

noncomputable def symbolicInformation {n : ℕ} (ρ σ : Fin n → Real) : Real :=
  ∑ i, ρ i * Real.log (ρ i / σ i)

theorem symbolicInformation_relabel_invariant {n : ℕ} [NeZero n]
    (e : Fin n ≃ Fin n) (ρ σ : Fin n → Real) :
    symbolicInformation (ρ ∘ e) (σ ∘ e) = symbolicInformation ρ σ := by
  unfold symbolicInformation
  simpa [Function.comp_def] using
    (e.sum_comp (fun i : Fin n => ρ i * Real.log (ρ i / σ i)))
end ForcingAnalysis.Book6
