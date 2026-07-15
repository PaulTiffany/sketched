/-
Book68B.lean - Principia Books 6 and 8, unmapped remainders: mutation
operators, state functions, projection dynamics.

Book 6's operator canon and Book 8's projection/entanglement layer are
stated almost entirely on a symbolic Riemannian/Banach manifold (M, g),
a Hilbert-space representational frame, or as C^1 ODE systems (the
SR-triplet). None of that continuum apparatus is certified here. What
IS certified, anchor by anchor:

  * "symbolic recombination"'s coherence-preservation clause becomes a
    genuine Lipschitz-type bound (`RecombinationCoherence`), with the
    honest consequence that exact input coherence (distance zero)
    forces exact output coherence -- the qualitative content of "small
    epsilon in, small C*epsilon out" pushed to its epsilon = 0 limit.
    Its drift-alignment clause becomes the direct nonvanishing
    consequence of a positive inner product;
  * "mutation as curvature discontinuity" becomes a genuine one-sided
    sequential-limit mismatch: `SequentialJump` packages two sequences
    approaching a time `t` from below/above whose images converge to
    different limits, and any such mismatch refutes continuity at `t`
    -- the honest real-analytic content of "Delta kappa(t) != 0";
  * "bifurcation conserves symbolic density" becomes the finite-sum
    fact that every emergent piece is bounded by the conserved total;
  * "reflective capacity" C_R = sup{...} becomes the standard
    least-upper-bound property of `sSup` over a bounded, nonempty set
    of ratios;
  * the "Complete Operator Closure" and "Symbolic Mass Conservation"
    axioms, together with the discrete Fokker-Planck skeleton of
    "Symbolic Diffusion Governs Thermodynamic Evolution" and the
    composition definitions of the Mutation Operator, get the discrete
    skeleton this repo already certifies (ForcingAnalysis.Book2's
    row-stochastic kernels): row-stochastic matrices are closed under
    composition (`isStochastic_mul`, the EXACT, unconditional discrete
    shadow of the source's closure-up-to-epsilon claim), evolution
    composes with matrix multiplication (`evolve_comp`), and hence any
    composite of canonical stochastic operators still conserves
    density (`composedEvolution_isDensity`);
  * the "symbolic confidence field"'s density-coupling clause becomes
    an exact finite weighted-average bound against a Book2 density:
    total confidence is between 0 and 1;
  * "symbolic power" being a product of nonnegative factors is
    genuinely nonnegative; its fractal scaling law becomes the
    multiplicativity of a real-power homogeneity law under composed
    rescalings (`powerScaling_compose`, via `Real.rpow`);
  * "non-commutativity of evolution and reflection" becomes an iff
    between the commutator vanishing and the two operators literally
    commuting, plus an explicit finite countermodel (on `ZMod 4`)
    exhibiting a genuinely nonzero commutator;
  * the "Mutually Assured Progress" viability clause of Symbolic
    Entanglement (free-energy surplus positive indefinitely, under a
    fixed positive per-step growth) becomes real unboundedness:
    `Filter.Tendsto ... atTop atTop`, the dual of Book8's
    `metabolicSufficiency_terminates` decrease bound;
  * the "Reflexive Debugging Operator"'s four-step composite
    (detect/project/repair/validate) becomes a per-step operator
    structure whose composite is injective whenever every stage is
    (`debugCompose_injective`) -- the same substructure corollary
    'Symbolic Agents as O_debug Projections' names;
  * the "Symbolic Hypothesis Set" / "Projective Compression Operator"
    argmin claims become the existence of a minimal-image element of
    any nonempty finite index set (`exists_argmin`, `Finset.exists_min_image`).

Left honestly open (see the accompanying proposal's `open_anchors`):
pure manifold/tensor definitions with no derivable law (symbolic
system, curvature tensor and its coordinate-index form, manifold
structure, operator canon, complete canonical set); Hilbert-space
state functions, energy/entropy/fragmentation functionals built on
them; the Fokker-Planck/SDE-flavored confidence-gradient, drift, power,
pressure, grace, modulation, flow, Laplace-Beltrami, and Hamiltonian
operator definitions (vector-field-valued gradients, no scalar law);
differential thermodynamic identities and sup-conservation axioms with
no inequality content (thermodynamic consistency, confidence-stability
coupling, power conservation, the Laplace-Beltrami observer extension);
quantum-entanglement/decoherence-as-flattening propositions requiring a
genuine Hilbert tensor product or curvature tensor; the SR-triplet's
C^1 ODE dynamics and its Lyapunov/RG-fixed-point convergence claims;
rank/dimension "Freedom Emergence" criteria (no linear-algebra model,
consistent with Book8.lean's prior judgment on the same family); vague
existential projection/transfer claims between DIFFERENT manifolds with
no explicit invariant formula (symbolic projection, symbolic transfer,
symbolic interface, resonant cognition) -- distinct from FracturedAtlas's
chart-overlap-within-ONE-space model, which none of these anchors fit.
-/

import Mathlib
import ForcingAnalysis.Book2

namespace ForcingAnalysis.Book68B

open Filter Finset
open ForcingAnalysis.Book2 (IsStochastic IsDensity evolve evolve_isDensity)

/- ================================================================
   definition:bk6_symbolic_recombination
   ================================================================ -/

/-- The coherence-preservation and drift-alignment data of a symbolic
recombination operator: whenever two structures' curvature distance is
below `eps`, the recombined structure's curvature distance from the
first is below `C * eps`, for a fixed positive constant `C` (the
Lipschitz-type reading of "for some constant C > 0 and small eps > 0");
and the recombined drift is positively aligned with the sum of the
input drifts. -/
structure RecombinationCoherence where
  inputDist : Real
  outputDist : Real
  inputDist_nonneg : 0 ≤ inputDist
  outputDist_nonneg : 0 ≤ outputDist
  driftAlign : Real
  driftAlign_pos : 0 < driftAlign
  C : Real
  C_pos : 0 < C
  bound : ∀ eps : Real, 0 < eps → inputDist < eps → outputDist < C * eps

/-- Coherence preservation pushed to its limit: exact input coherence
(curvature distance zero) forces exact output coherence, not merely an
arbitrarily small one. -/
theorem recombinationCoherence_zero_preserved (R : RecombinationCoherence)
    (hzero : R.inputDist = 0) : R.outputDist = 0 := by
  by_contra hne
  have hpos : 0 < R.outputDist := R.outputDist_nonneg.lt_of_ne (Ne.symm hne)
  have heps : 0 < R.outputDist / (2 * R.C) := div_pos hpos (mul_pos two_pos R.C_pos)
  have hlt : R.inputDist < R.outputDist / (2 * R.C) := by rw [hzero]; exact heps
  have hb := R.bound _ heps hlt
  have hCne : R.C ≠ 0 := R.C_pos.ne'
  have heq : R.C * (R.outputDist / (2 * R.C)) = R.outputDist / 2 := by
    field_simp
  rw [heq] at hb
  linarith

/-- Drift alignment's direct consequence: a positive alignment is
nonzero, i.e. the recombined drift genuinely fails to be orthogonal to
the sum of the input drifts. -/
theorem recombinationCoherence_driftAlign_ne_zero (R : RecombinationCoherence) :
    R.driftAlign ≠ 0 :=
  R.driftAlign_pos.ne'

/- ================================================================
   axiom:bk6_symbolic_mutation_as_curvature_transition
   ================================================================ -/

/-- A witnessed one-sided sequential jump of `kappa` at time `t`: two
sequences approaching `t` strictly from below and strictly above whose
images under `kappa` converge to genuinely different limits -- the
honest real-analytic content of "Delta kappa(t) = lim kappa(t+eps) -
lim kappa(t-eps) != 0". -/
structure SequentialJump (kappa : Real → Real) (t : Real) where
  left : Nat → Real
  right : Nat → Real
  left_lt : ∀ k, left k < t
  right_gt : ∀ k, t < right k
  left_to_t : Tendsto left atTop (nhds t)
  right_to_t : Tendsto right atTop (nhds t)
  leftLim : Real
  rightLim : Real
  hleft : Tendsto (kappa ∘ left) atTop (nhds leftLim)
  hright : Tendsto (kappa ∘ right) atTop (nhds rightLim)
  jump : leftLim ≠ rightLim

/-- A witnessed one-sided jump refutes continuity at `t`: mismatched
one-sided limits are exactly what "symbolic mutation" demarcates. -/
theorem sequentialJump_not_continuousAt {kappa : Real → Real} {t : Real}
    (J : SequentialJump kappa t) : ¬ ContinuousAt kappa t := by
  intro hcont
  have hL : Tendsto (kappa ∘ J.left) atTop (nhds (kappa t)) :=
    hcont.tendsto.comp J.left_to_t
  have hR : Tendsto (kappa ∘ J.right) atTop (nhds (kappa t)) :=
    hcont.tendsto.comp J.right_to_t
  have eL : J.leftLim = kappa t := tendsto_nhds_unique J.hleft hL
  have eR : J.rightLim = kappa t := tendsto_nhds_unique J.hright hR
  exact J.jump (eL.trans eR.symm)

/- ================================================================
   axiom:bk6_bifurcation_as_emergence_operator
   ================================================================ -/

/-- Every emergent piece of a bifurcation is bounded by the conserved
total symbolic density: the finite-sum shadow of
`sum_i rho(x_i) = rho(x)` together with nonnegativity of density. -/
theorem bifurcation_piece_le_total {n : Nat} (rho : Fin n → Real) (rhoTotal : Real)
    (hnonneg : ∀ i, 0 ≤ rho i) (hconserve : ∑ i, rho i = rhoTotal) (i : Fin n) :
    rho i ≤ rhoTotal := by
  rw [← hconserve]
  exact Finset.single_le_sum (fun j _ => hnonneg j) (Finset.mem_univ i)

/- ================================================================
   corollary:bk6_reflective_capacity_theorem
   ================================================================ -/

/-- The reflective capacity data: the (nonempty, bounded-above) set of
admissible eta/mu ratios over the domain of admissible densities. -/
structure ReflectiveCapacity where
  ratios : Set Real
  nonempty : ratios.Nonempty
  bddAbove : BddAbove ratios

/-- The reflective capacity C_R = sup{...}. -/
noncomputable def capacity (R : ReflectiveCapacity) : Real := sSup R.ratios

/-- Every admissible ratio is dominated by the reflective capacity: the
defining least-upper-bound property of the sup. -/
theorem capacity_isUB (R : ReflectiveCapacity) {x : Real} (hx : x ∈ R.ratios) :
    x ≤ capacity R :=
  le_csSup R.bddAbove hx

/- ================================================================
   theorem:bk6_complete_operator_closure, definition:bk6_mutation_operator,
   definition:bk6_mutation_operator_complete,
   axiom:bk6_symbolic_mass_conservation_complete,
   theorem:bk6_symbolic_diffusion_governs_evolution,
   definition:bk6_symbolic_density_evolution
   ================================================================ -/

variable {n : Nat}

/-- **The discrete, exact shadow of Complete Operator Closure**:
row-stochastic evolution kernels are closed under composition, with NO
error term -- strictly stronger than the source's "up to an operator
norm smaller than any epsilon" qualifier, an honesty gap noted rather
than hidden (cf. Book8.lean's `reflective_permutation_assoc`, the same
kind of gap for associativity). -/
theorem isStochastic_mul {P Q : Matrix (Fin n) (Fin n) Real}
    (hP : IsStochastic P) (hQ : IsStochastic Q) : IsStochastic (P * Q) := by
  refine ⟨fun i k => ?_, fun i => ?_⟩
  · rw [Matrix.mul_apply]
    exact Finset.sum_nonneg fun j _ => mul_nonneg (hP.1 i j) (hQ.1 j k)
  · calc ∑ k, (P * Q) i k = ∑ k, ∑ j, P i j * Q j k := by
          simp [Matrix.mul_apply]
      _ = ∑ j, ∑ k, P i j * Q j k := Finset.sum_comm
      _ = ∑ j, P i j * ∑ k, Q j k := by
          refine Finset.sum_congr rfl fun j _ => ?_
          rw [Finset.mul_sum]
      _ = ∑ j, P i j := by
          refine Finset.sum_congr rfl fun j _ => ?_
          rw [hQ.2 j, mul_one]
      _ = 1 := hP.2 i

/-- The symbolic flow operator composes with matrix multiplication: two
canonical evolution steps in sequence equal one step under the composed
kernel -- the discrete Fokker-Planck skeleton underlying "Symbolic
Diffusion Operator Governs Thermodynamic Evolution" and the composition
`M_t = R_t o B_t o D_t` of the Mutation Operator. -/
theorem evolve_comp (P Q : Matrix (Fin n) (Fin n) Real) (rho : Fin n → Real) :
    evolve Q (evolve P rho) = evolve (P * Q) rho := by
  funext k
  show ∑ j, (∑ i, rho i * P i j) * Q j k = ∑ i, rho i * (P * Q) i k
  simp_rw [Finset.sum_mul]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Matrix.mul_apply, Finset.mul_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  ring

/-- **Symbolic Mass Conservation for any composed canonical operator**:
composing two row-stochastic canonical operators still conserves total
probability mass and density-hood, for the sequential (not merely
single-step) evolution the source's "for any canonical operator O"
quantifies over. -/
theorem composedEvolution_isDensity {P Q : Matrix (Fin n) (Fin n) Real}
    (hP : IsStochastic P) (hQ : IsStochastic Q) {rho : Fin n → Real}
    (hrho : IsDensity rho) : IsDensity (evolve Q (evolve P rho)) := by
  rw [evolve_comp]
  exact evolve_isDensity (isStochastic_mul hP hQ) hrho

/- ================================================================
   definition:bk6_symbolic_confidence_field
   ================================================================ -/

/-- A symbolic confidence field on a finite symbolic alphabet: values in
`[0, 1]`, the finite shadow of `mathfrak{C} : M -> [0,1]`. -/
structure ConfidenceField (n : Nat) where
  C : Fin n → Real
  nonneg : ∀ i, 0 ≤ C i
  le_one : ∀ i, C i ≤ 1

/-- The total (density-coupled) confidence `mathfrak{C}_total`. -/
noncomputable def totalConfidence (F : ConfidenceField n) (rho : Fin n → Real) : Real :=
  ∑ i, F.C i * rho i

theorem totalConfidence_nonneg (F : ConfidenceField n) {rho : Fin n → Real}
    (hrho : ∀ i, 0 ≤ rho i) : 0 ≤ totalConfidence F rho :=
  Finset.sum_nonneg fun i _ => mul_nonneg (F.nonneg i) (hrho i)

/-- **Density coupling**: total confidence against a genuine density
never exceeds 1, the finite shadow of
`int_M mathfrak{C}(x) rho(x) dmu_g(x) = mathfrak{C}_total <= 1`. -/
theorem totalConfidence_le_one (F : ConfidenceField n) {rho : Fin n → Real}
    (hrho : IsDensity rho) : totalConfidence F rho ≤ 1 := by
  have hbound : ∀ i : Fin n, F.C i * rho i ≤ rho i :=
    fun i => mul_le_of_le_one_left (hrho.nonneg i) (F.le_one i)
  calc totalConfidence F rho ≤ ∑ i, rho i := Finset.sum_le_sum (fun i _ => hbound i)
    _ = 1 := hrho.sum_one

/- ================================================================
   definition:bk6_symbolic_power, lemma:bk6_power_scaling
   ================================================================ -/

/-- The symbolic power at a point, as a product of its three
nonnegative factors: confidence, confidence-gradient norm, and local
volume. -/
structure SymbolicPowerData where
  confidence : Real
  gradientNorm : Real
  vol : Real
  confidence_nonneg : 0 ≤ confidence
  gradientNorm_nonneg : 0 ≤ gradientNorm
  vol_nonneg : 0 ≤ vol

/-- The symbolic power `mathfrak{P}`. -/
def power (P : SymbolicPowerData) : Real := P.confidence * P.gradientNorm * P.vol

theorem power_nonneg (P : SymbolicPowerData) : 0 ≤ power P :=
  mul_nonneg (mul_nonneg P.confidence_nonneg P.gradientNorm_nonneg) P.vol_nonneg

/-- A homogeneity (fractal scaling) law `f(lam * x) = lam ^ d * f x` for
scale factors `lam > 0`, the honest algebraic content of
`mathfrak{P}(lam x) = lam^(d_f - 1) mathfrak{P}(x)`. -/
structure PowerScaling (d : Real) (f : Real → Real) where
  scaling : ∀ lam x : Real, 0 < lam → f (lam * x) = lam ^ d * f x

/-- Homogeneity composes: scaling by `lam1` then `lam2` equals scaling
by the product `lam1 * lam2`, a genuine consequence of the scaling law
that is not itself one of its defining instances. -/
theorem powerScaling_compose {d : Real} {f : Real → Real} (P : PowerScaling d f)
    {lam1 lam2 x : Real} (h1 : 0 < lam1) (h2 : 0 < lam2) :
    f (lam1 * (lam2 * x)) = (lam1 * lam2) ^ d * f x := by
  rw [P.scaling lam1 (lam2 * x) h1, P.scaling lam2 x h2, Real.mul_rpow h1.le h2.le]
  ring

/- ================================================================
   axiom:bk6_non_commutativity_evolution_reflection
   ================================================================ -/

/-- The commutator of two self-maps of an additive commutative group:
`[D, R](x) = D(R x) - R(D x)`. -/
def commutator {X : Type*} [AddCommGroup X] (D R : X → X) (x : X) : X :=
  D (R x) - R (D x)

/-- The commutator vanishes identically exactly when the two operators
literally commute pointwise. -/
theorem commutator_eq_zero_iff_commute {X : Type*} [AddCommGroup X] (D R : X → X) :
    (∀ x, commutator D R x = 0) ↔ ∀ x, D (R x) = R (D x) := by
  constructor
  · intro h x; exact sub_eq_zero.mp (h x)
  · intro h x; exact sub_eq_zero.mpr (h x)

/-- **A genuinely nonzero commutator**: on `ZMod 4`, drift `D x = x + 1`
and reflection `R x = 2 * x` fail to commute, witnessed at `x = 0` --
the finite, explicit realization of "the commutator magnitude quantifies
emergent potential" being nonzero rather than a vacuous possibility. -/
theorem commutator_witness_ne_zero :
    ∃ x : ZMod 4, commutator (fun y => y + 1) (fun y => 2 * y) x ≠ 0 := by
  refine ⟨0, ?_⟩
  decide

/- ================================================================
   definition:bk8_reflexive_debugging_operator,
   definition:bk8_symbolic_stress_tensor,
   corollary:bk8_symbolic_agents_as_projections
   ================================================================ -/

/-- The four per-step substrates composing the Reflexive Debugging
Operator: detect (diagnostic substrate), project, repair (transformative
substrate), validate (reflective integration layer). -/
structure ReflexiveDebuggingStep (X : Type*) where
  detect : X → X
  project : X → X
  repair : X → X
  validate : X → X

/-- The Reflexive Debugging Operator itself,
`O_debug := Xi_v o Xi_s o Xi_r o Xi_d`. -/
def debugCompose {X : Type*} (S : ReflexiveDebuggingStep X) : X → X :=
  S.validate ∘ S.repair ∘ S.project ∘ S.detect

/-- If every substrate is individually injective, the composed debugging
operator is injective: distinct symbolic states never collide under a
full detect-project-repair-validate cycle. -/
theorem debugCompose_injective {X : Type*} (S : ReflexiveDebuggingStep X)
    (hd : Function.Injective S.detect) (hp : Function.Injective S.project)
    (hr : Function.Injective S.repair) (hv : Function.Injective S.validate) :
    Function.Injective (debugCompose S) :=
  hv.comp (hr.comp (hp.comp hd))

/- ================================================================
   axiom:bk8_coherence_horizon (the Mutually Assured Progress clause)
   ================================================================ -/

/-- Mutually Assured Progress data: a joint free-energy surplus sequence
that grows by at least a fixed positive amount every step -- the
discrete honest kernel of "the joint free energy surplus remains
positive indefinitely", strengthened to genuine unbounded growth. -/
structure MutuallyAssuredProgress where
  surplus : Nat → Real
  delta : Real
  delta_pos : 0 < delta
  growing : ∀ k, surplus (k + 1) ≥ surplus k + delta

/-- Telescoped growth bound, by induction on the number of co-evolution
steps -- the dual of Book8.lean's `metabolicSufficiency_decrease_accum`. -/
theorem mutuallyAssuredProgress_accum (M : MutuallyAssuredProgress) (n : Nat) :
    M.surplus n ≥ M.surplus 0 + (n : Real) * M.delta := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep := M.growing k
      have hcast : ((k + 1 : Nat) : Real) * M.delta = (k : Real) * M.delta + M.delta := by
        push_cast; ring
      rw [hcast]
      linarith

/-- **Mutually assured progress is unbounded**: a surplus growing by a
fixed positive amount every step diverges to infinity -- the discrete
dual of Book8.lean's `metabolicSufficiency_terminates` (which shows a
fixed positive per-step DECREASE forces termination). Long-run co-
evolution viability is genuine, real divergence, not a merely-asserted
"remains positive". -/
theorem mutuallyAssuredProgress_unbounded (M : MutuallyAssuredProgress) :
    Tendsto M.surplus atTop atTop := by
  have h1 : Tendsto (fun k : Nat => (k : Real)) atTop atTop := tendsto_natCast_atTop_atTop
  have h2 : Tendsto (fun k : Nat => (k : Real) * M.delta) atTop atTop :=
    h1.atTop_mul_const M.delta_pos
  have h3 : Tendsto (fun k : Nat => M.surplus 0 + (k : Real) * M.delta) atTop atTop :=
    tendsto_atTop_add_const_left _ _ h2
  exact tendsto_atTop_mono (fun k => mutuallyAssuredProgress_accum M k) h3

/- ================================================================
   definition:bk8_symbolic_hypothesis_set,
   definition:bk8_projective_compression_operator
   ================================================================ -/

/-- **An argmin always exists over a nonempty finite index set**: the
shared honest kernel of the Symbolic Hypothesis Set's implicit
best-hypothesis selection and the Projective Compression Operator's
`arg min_{psi in Pi^{-1}(phi)} freeEnergy(psi)` -- dual to Book8.lean's
`reflectiveSelection_exists` (an argmax over confidence minus loss). -/
theorem exists_argmin {ι : Type*} (H : Finset ι) (hH : H.Nonempty) (f : ι → Real) :
    ∃ h ∈ H, ∀ h' ∈ H, f h ≤ f h' :=
  H.exists_min_image f hH

end ForcingAnalysis.Book68B
