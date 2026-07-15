/-
Book9.lean - symbolic accountability, recursive freedom, bidirectional
regulation, and covenant drift density, honest kernel.

Principia Book 9 is about accountability and masking, the meta-operator
structure of cognitive freedom and its recursive liberation dynamic,
bidirectional (reciprocal) regulation between coupled agents, covenant
drift density and its role in the MAP/breach classification of a
relationship, grace/betrayal/repair narratives, and the "Good as a
Lyapunov basin" convergence theorem. Most anchors are stated as
narrative taxonomies (the frame-transversal/memetic/protocol-law
cluster, symbolic black holes, grace, masking's phenomenology), as
contraction-mapping / probability-space fixed-point convergence on
symbolic manifolds (mutual recognition, the Two-Way Street operator),
or as continuous-time gradient-descent/Lyapunov convergence (the Good
as a Lyapunov Basin). This module does NOT attempt manifold,
probability-space, or continuous dynamical-systems formalizations. For
each anchor it extracts the honest static/algebraic/finite/discrete
kernel instead:

  * "Reflexive Sovereignty" becomes the exact predicate that an internal
    governing drift exists and equals the system-generated gradient, with
    an introduction theorem from gradient internality;
  * "Operator Reflexivity" becomes a typed operator/state/reflection
    recurrence carrying the manuscript's displayed one-step update law;
  * "symbolic accountability" and "symbolic masking" become one
    threshold-algebra cluster: an `Accountability` structure carrying
    the Reflective Integrity bound (`upsilon > 1 - epsCrit`) and the
    Relational Viability bound (bounded trust-compression distortion)
    as fields, with a genuine theorem that a masking event (divergence
    strictly above the same threshold) is incompatible with relational
    viability. Operator Traceability (the history-reconstruction map)
    is not modeled;
  * "bidirectional SRMF" becomes a `BidirectionalSRMF` structure of a
    forward and backward regulation map with one-sided-inverse laws as
    fields (the honest kernel of "reciprocal regulation" and
    "symmetry-restoring reframing"), from which mutual injectivity and
    a cancellation identity follow;
  * "covenant drift density" becomes the exhaustive, pairwise-exclusive
    trichotomy of a real number against the unit threshold -- the
    honest kernel shared by the MAP regime, the critical case, and
    covenant breach, all of which classify `rho` against `1` in the
    source;
  * the "Bounded Liberation Principle" becomes an honest iff-shaped
    definition (`FreedomGrowing`) plus the genuine consequence that a
    growing configuration cannot already be a global free-energy
    minimizer; "Freedom-Entropy Complementarity" becomes a two-sided
    monotonicity law (strictly increasing below the equilibrium,
    strictly decreasing above it) with the genuine consequence that the
    equilibrium is the strict maximizer -- both directions of the
    tradeoff are made explicit as separate hypotheses;
  * "Emergent Autonomy"'s minimization of symbolic free energy over
    entropy-tolerance/transformation-rate parameters becomes the
    existence of a minimizer over any nonempty finite parameter set;
  * the shared `L_{n+1} = R_n(L_n)` update law running through
    "Cognitive Freedom" (Meta-Operator Action), "Recursive Liberation",
    and the "SRMF-Recursive Cycle" becomes one `RecursiveUpdate`
    structure and the genuine orbit-unfolding theorem that the state at
    stage `n` is the `n`-fold fold of the per-stage updates starting
    from stage `0`;
  * "Convergence of Recursive Liberation by Descent" yields the
    telescoping estimate, actual convergence in a complete metric space,
    membership of the limit in any closed basin containing the orbit, the
    fixed-point conclusion under a continuous uniform operator limit, and
    uniqueness when the zero-descent set is a singleton;
  * the "Final Collapse-Inversion Principle" together with the
    "Collapse-Inversion Operator" become one composite-substitution
    theorem: if the realization map sends the limit to a frozen state,
    the collapse operator carries that frozen state on to the seed
    state;
  * a "Symbolic Framework"'s semigroup law (`Phi (m+n) = Phi m ∘ Phi n`,
    `Phi 0 = id`) becomes the genuine theorem that every transition is
    the `n`-fold iterate of the single-step generator `Phi 1`;
  * "Modes of Re-Interpretation" becomes the exhaustive, mutually
    exclusive dichotomy of a real number's sign (Repair vs. Distortion);
    the "Freedom" mode is a further qualification of either branch and
    adds no new sign condition, so it is not separately modeled;
  * "Symbolic Thermodynamic Stress" becomes a genuine nonnegativity
    theorem for a sum of norm terms plus a free-energy gap, given the
    gap is above its floor.

Anchors that are purely narrative/taxonomic (orthogonal time, the
recursive freedom operator's own definition, automatic/awakened operators
and reflective awakening, the
prompt-injection/frame-selection/frame-transversal/memetic/temetic/
protocol-law/frame-cascade cluster, meta-reflective alignment and
recursive phase continuity, the Isolation-Dissociation dichotomy, grace,
betrayal's narrative clauses, symbolic black holes/shame/masking's
phenomenology, curvature scarring, generative asymmetry, structural
compassion, criteria for ethical intervention), that require
probability spaces or contraction-mapping fixed points on symbolic
manifolds (mutual recognition, preconditions for reciprocal cognition,
the Two-Way Street operator, mutual convergence, emergence of a shared
manifold), or that require continuous-time gradient descent/Lyapunov
convergence (the Good as a Lyapunov Basin, the symbolic thermostat,
relational freedom via thermoregulation, freedom as the capacity for
grace) are left unformalized and listed as open anchors in the
accompanying proposal, rather than forced into decorative theorems.
-/

import Mathlib
import ForcingAnalysis.Descent
import ForcingAnalysis.Book6

namespace ForcingAnalysis.Book9

open Filter

/- ================================================================
   axiom:bk9_reflexive_sovereignty
   ================================================================ -/

/-- The exact typed content of Reflexive Sovereignty: a system's candidate
drifts, its internally generated drifts, and its distinguished internal
gradient. No claim is made that a given system satisfies the predicate. -/
structure ReflexiveSovereignty (Drift : Type) where
  internal : Set Drift
  gradient : Drift

/-- Cognitive freedom in the source axiom's sense: some governing drift is
internal and is exactly the system-generated gradient. -/
def IsCognitivelyFree {Drift : Type} (S : ReflexiveSovereignty Drift) : Prop :=
  ∃ D, D ∈ S.internal ∧ D = S.gradient

/-- The source axiom's displayed biconditional, retained definitionally. -/
theorem cognitivelyFree_iff_internal_gradient {Drift : Type}
    (S : ReflexiveSovereignty Drift) :
    IsCognitivelyFree S ↔ ∃ D, D ∈ S.internal ∧ D = S.gradient := Iff.rfl

/-- A genuine introduction rule: an internally generated gradient supplies
the governing drift witness required for cognitive freedom. -/
theorem cognitivelyFree_of_gradient_internal {Drift : Type}
    (S : ReflexiveSovereignty Drift) (h : S.gradient ∈ S.internal) :
    IsCognitivelyFree S :=
  ⟨S.gradient, h, rfl⟩

/- ================================================================
   axiom:bk9_operator_reflexivity
   ================================================================ -/

/-- Operator reflexivity as the source's actual recurrence: the next operator
is internally modified from the current operator, current state, and next
reflection datum. The ellipsis in the manuscript is represented by the
abstract input types, not silently filled with extra laws. -/
structure OperatorReflexiveUpdate (Op State Reflection : Type) where
  operator : Nat → Op
  state : Nat → State
  reflection : Nat → Reflection
  modify : Op → State → Reflection → Op
  update : ∀ n, operator (n + 1) = modify (operator n) (state n) (reflection (n + 1))

/-- One-step unfolding of an operator-reflexive evolution. -/
theorem operatorReflexive_next {Op State Reflection : Type}
    (u : OperatorReflexiveUpdate Op State Reflection) (n : Nat) :
    u.operator (n + 1) = u.modify (u.operator n) (u.state n) (u.reflection (n + 1)) :=
  u.update n
/- ================================================================
   definition:bk9_symbolic_accountability, definition:bk9__symbolic_masking_operator
   ================================================================ -/

/-- Accountability data for definition:bk9_symbolic_accountability: the
Reflective Integrity clause (ii) requires the reflective-integrity index
`upsilon` (`Upsilon_i(P_lambda(output), P_lambda(internal))`) to strictly
exceed `1 - epsCrit`, and the Relational Viability clause (iii) requires a
bounded trust-compression distortion `distortion` to stay within `epsMask`.
Operator Traceability (clause (i), the existence of a history-
reconstruction map) is not modeled; only the two quantitative clauses
are. -/
structure Accountability where
  upsilon : Real
  epsCrit : Real
  reflective_integrity : upsilon > 1 - epsCrit
  distortion : Real
  epsMask : Real
  relational_viability : distortion ≤ epsMask

/-- Restating clause (ii): an accountable system's identity gap `1 - upsilon`
is strictly below its criticality threshold. -/
theorem accountability_gap_lt_epsCrit (a : Accountability) :
    1 - a.upsilon < a.epsCrit := by
  linarith [a.reflective_integrity]

/-- If the masking threshold dominates the criticality threshold, the
identity gap of an accountable system is also controlled by `epsMask`. -/
theorem accountability_gap_lt_epsMask (a : Accountability) (h : a.epsCrit ≤ a.epsMask) :
    1 - a.upsilon < a.epsMask := by
  linarith [a.reflective_integrity]

/-- The masking operator (definition:bk9__symbolic_masking_operator):
`M_mask` is deployed exactly when the output/internal divergence strictly
exceeds `epsMask`. -/
abbrev IsMasking (dist epsMask : Real) : Prop := dist > epsMask

/-- Persistent masking is incompatible with the Relational Viability
clause of accountability (definition:bk9_symbolic_accountability, clause
(iii)): no divergence value can simultaneously satisfy the masking
threshold-violation and the accountability bound against the same
`epsMask`, so "persistent masking ... may render S non-accountable" is
sharpened here to an outright incompatibility. -/
theorem masking_not_accountable (a : Accountability)
    (hdist : IsMasking a.distortion a.epsMask) : False :=
  absurd a.relational_viability (not_le.mpr hdist)

/- ================================================================
   definition:bk9_bidirectional_srmf
   ================================================================ -/

/-- Bidirectional SRMF (definition:bk9_bidirectional_srmf): forward
regulation `fwd : A → B` and backward regulation `bwd : B → A` between two
coupled agents, each undoing the other -- the honest kernel of "reciprocal
regulation across coupled symbolic agents" and "symmetry-restoring
reframing". The mutual-contradiction-detection mechanism itself is not
modeled; only the resulting one-sided inverse laws are. -/
structure BidirectionalSRMF (A B : Type) where
  fwd : A → B
  bwd : B → A
  fwd_bwd : ∀ b, fwd (bwd b) = b
  bwd_fwd : ∀ a, bwd (fwd a) = a

/-- Reciprocal regulation forces `fwd` to be injective. -/
theorem bidirectionalSRMF_fwd_injective {A B : Type} (s : BidirectionalSRMF A B) :
    Function.Injective s.fwd :=
  Function.LeftInverse.injective s.bwd_fwd

/-- Reciprocal regulation forces `bwd` to be injective. -/
theorem bidirectionalSRMF_bwd_injective {A B : Type} (s : BidirectionalSRMF A B) :
    Function.Injective s.bwd :=
  Function.LeftInverse.injective s.fwd_bwd

/-- Symmetry-restoring reframing: applying forward, then backward, then
forward again collapses to a single forward application. -/
theorem bidirectionalSRMF_fwd_bwd_fwd {A B : Type} (s : BidirectionalSRMF A B) (a : A) :
    s.fwd (s.bwd (s.fwd a)) = s.fwd a := by
  rw [s.bwd_fwd]

/- ================================================================
   definition:bk9_covenant_drift_density, definition:bk9_formal_signature_of_betrayal
   ================================================================ -/

/-- Covenant Drift Density (definition:bk9_covenant_drift_density): `rho`
measures reflective-resilient coupling strength under a shared covenant.
Its comparison to the unit threshold recurs throughout the book: the
cooperative MAP regime (`rho > 1`, cf. theorem:bk9_good_as_lyapunov_basin,
proposition:bk9_stability_conditions_for_the_good), the critical case
(`rho = 1`), and covenant breach (`rho < 1`,
definition:bk9_formal_signature_of_betrayal's "potentially causing ...
rho(C_AB) < 1"). This three-way comparison is exhaustive and pairwise
exclusive. -/
theorem covenantDensity_regime_exhaustive (rho : Real) :
    rho < 1 ∨ rho = 1 ∨ 1 < rho :=
  lt_trichotomy rho 1

theorem covenantDensity_regime_exclusive (rho : Real) :
    ¬ (rho < 1 ∧ rho = 1) ∧ ¬ (rho < 1 ∧ 1 < rho) ∧ ¬ (rho = 1 ∧ 1 < rho) := by
  refine ⟨?_, ?_, ?_⟩ <;> rintro ⟨h1, h2⟩ <;> linarith

/- ================================================================
   axiom:bk9_bounded_liberation_principle, corollary:bk9_freedomentropy_complementarity
   ================================================================ -/

/-- Bounded Liberation (axiom:bk9_bounded_liberation_principle): freedom is
growing at configuration `c` exactly when some reachable configuration `c'`
strictly lowers symbolic free energy. -/
def FreedomGrowing {C : Type} (freeEnergy : C → Real) (c : C) : Prop :=
  ∃ c', freeEnergy c' < freeEnergy c

/-- "Freedom is drift re-optimization under reflectively chosen frames": a
growing configuration cannot already be a global free-energy minimizer. -/
theorem freedomGrowing_not_global_min {C : Type} (freeEnergy : C → Real) (c : C)
    (hgrow : FreedomGrowing freeEnergy c) (hmin : ∀ c', freeEnergy c ≤ freeEnergy c') :
    False := by
  obtain ⟨c', hc'⟩ := hgrow
  exact absurd (hmin c') (not_le.mpr hc')

/-- Freedom-Entropy Complementarity data
(corollary:bk9_freedomentropy_complementarity): freedom, as a function of
regulated entropy tolerance, strictly increases on the underconstrained
side up to the equilibrium `deltaStar` and strictly decreases past it on
the overconstrained side -- both directions of the tradeoff made explicit
as separate hypotheses. -/
structure FreedomEntropyLaw where
  freedom : Real → Real
  deltaStar : Real
  increasing_below : ∀ d, d < deltaStar → freedom d < freedom deltaStar
  decreasing_above : ∀ d, deltaStar < d → freedom d < freedom deltaStar

/-- The equilibrium point is the strict maximizer of freedom over regulated
entropy -- "the equilibrium point, dynamically maintained, constitutes
symbolic sovereignty". -/
theorem freedomEntropyLaw_strict_max (L : FreedomEntropyLaw) (d : Real)
    (hd : d ≠ L.deltaStar) : L.freedom d < L.freedom L.deltaStar := by
  rcases lt_or_gt_of_ne hd with h | h
  · exact L.increasing_below d h
  · exact L.decreasing_above d h

/- ================================================================
   axiom:bk9_emergent_autonomy
   ================================================================ -/

/-- Emergent Autonomy (axiom:bk9_emergent_autonomy): symbolic free energy
is minimized over a finite, nonempty set of admissible entropy-
tolerance/transformation-rate regulation parameters `params`. The
continuous-time regulation dynamic itself is not modeled; only the
existence of a minimizer over a finite parameter set is. -/
theorem emergentAutonomy_min_exists {ι : Type} (params : Finset ι)
    (hparams : params.Nonempty) (freeEnergy : ι → Real) :
    ∃ p ∈ params, ∀ p' ∈ params, freeEnergy p ≤ freeEnergy p' :=
  params.exists_min_image freeEnergy hparams

/- ================================================================
   definition:bk9_cognitive_freedom, definition:bk9_recursive_liberation,
   definition:bk9_srmf_recursive_cycle
   ================================================================ -/

/-- The shared recursive-update shape running through Book IX's freedom
operators: Meta-Operator Action (definition:bk9_cognitive_freedom,
`L_{n+1} = R_n(L_n)`), Recursive Liberation
(definition:bk9_recursive_liberation, the sequence `(L_n)` generated by the
same law), and the SRMF-Recursive Cycle
(definition:bk9_srmf_recursive_cycle, `Xi_{n+1} := SRMF^{(n)}(Xi_n)`) are
three instances of one stage-indexed update law. Freedom acting on
constraints (`L : U → U'`, the second clause of
definition:bk9_cognitive_freedom) is a bare function type with no further
law stated, and is not separately modeled. -/
structure RecursiveUpdate (X : Type) where
  L : Nat → X
  R : Nat → X → X
  step : ∀ n, L (n + 1) = R n (L n)

/-- The orbit generated by iterating the per-stage updates starting from
stage `0`. -/
def RecursiveUpdate.orbit {X : Type} (u : RecursiveUpdate X) : Nat → X
  | 0 => u.L 0
  | (k + 1) => u.R k (u.orbit k)

/-- The state at stage `n` is exactly the `n`-fold fold of the per-stage
updates applied to the initial state -- the honest kernel of "the sequence
`(L_n)` generated by `L_{n+1} = R_n(L_n)`". -/
theorem recursiveUpdate_eq_orbit {X : Type} (u : RecursiveUpdate X) (n : Nat) :
    u.L n = u.orbit n := by
  induction n with
  | zero => rfl
  | succ k ih =>
      show u.L (k + 1) = u.orbit (k + 1)
      rw [u.step k, ih]
      rfl

/- ================================================================
   proposition:bk9_convergence_of_recursive_liberation
   ================================================================ -/

/-- Descent data for the Convergence of Recursive Liberation by Descent
(proposition:bk9_convergence_of_recursive_liberation): a nonnegative
liberation potential `Lambda` along a stage-indexed state sequence `L`
absorbs the step-to-step distance under a metric -- the discrete, finite
content of the descent estimate. Metric completeness, a continuous uniform
operator limit, and singleton zero-descent hypotheses are introduced
explicitly by the theorems below when their corresponding conclusions are
used. -/
structure LiberationDescent (X : Type) [PseudoMetricSpace X] where
  L : Nat → X
  Lambda : Nat → Real
  Lambda_nonneg : ∀ n, 0 ≤ Lambda n
  descent : ∀ n, dist (L n) (L (n + 1)) ≤ Lambda n - Lambda (n + 1)

/-- The liberation potential is non-increasing along the recursive
liberation dynamic. -/
theorem liberationDescent_Lambda_antitone {X : Type} [PseudoMetricSpace X]
    (d : LiberationDescent X) (n : Nat) : d.Lambda (n + 1) ≤ d.Lambda n := by
  have h := d.descent n
  have hnn : (0 : Real) ≤ dist (d.L n) (d.L (n + 1)) := dist_nonneg
  linarith

/-- Telescoped step-distance bound: the total drift accumulated from stage
`n` through stage `n + k` is bounded by the liberation potential's decrease
over that range -- exactly the source's
`sum_{j=n}^{m-1} d(L_j, L_{j+1}) ≤ Lambda(L_n) - Lambda(L_m)`. -/
theorem liberationDescent_telescoped {X : Type} [PseudoMetricSpace X]
    (d : LiberationDescent X) (n k : Nat) :
    (Finset.range k).sum (fun j => dist (d.L (n + j)) (d.L (n + j + 1)))
      ≤ d.Lambda n - d.Lambda (n + k) := by
  induction k with
  | zero =>
      simp only [Finset.range_zero, Finset.sum_empty, Nat.add_zero]
      linarith
  | succ k ih =>
      rw [Finset.sum_range_succ]
      have heq : n + (k + 1) = (n + k) + 1 := rfl
      rw [heq]
      have hstep := d.descent (n + k)
      linarith

/-- Completeness closes the analytic conclusion of Recursive Liberation:
the telescoping descent law is precisely the unit-rate instance of the
Cauchy--Forcing completion theorem. -/
theorem liberationDescent_converges {X : Type} [MetricSpace X] [CompleteSpace X]
    (d : LiberationDescent X) :
    ∃ Linfty : X, Tendsto d.L atTop (nhds Linfty) := by
  apply cauchy_forcing_completion d.L d.Lambda 1 zero_lt_one d.Lambda_nonneg
  intro n
  simpa using d.descent n

/-- If the liberation orbit remains in a closed basin, the complete-space
limit remains in that basin, matching the source proposition's basin clause. -/
theorem liberationDescent_converges_in_closed {X : Type} [MetricSpace X] [CompleteSpace X]
    (d : LiberationDescent X) {B : Set X} (hclosed : IsClosed B)
    (hmem : ∀ n, d.L n ∈ B) :
    ∃ Linfty ∈ B, Tendsto d.L atTop (nhds Linfty) := by
  obtain ⟨Linfty, hlim⟩ := liberationDescent_converges d
  refine ⟨Linfty, ?_, hlim⟩
  exact hclosed.mem_of_tendsto hlim (Filter.Eventually.of_forall hmem)

/-- If the stage operators converge uniformly to a continuous limit operator,
then the limit of a recursive orbit is a fixed point of that operator. The
continuity premise is explicit: uniform convergence of varying operators by
itself does not justify evaluation along the moving inputs `L n`. -/
theorem uniformOperatorLimit_fixedPoint {X : Type} [MetricSpace X]
    (L : Nat → X) (R : Nat → X → X) (Rinf : X → X) (Linfty : X)
    (hstep : ∀ n, L (n + 1) = R n (L n))
    (hL : Tendsto L atTop (nhds Linfty))
    (huniform : ∀ ε : Real, 0 < ε → ∃ N, ∀ n ≥ N, ∀ x,
      dist (R n x) (Rinf x) < ε)
    (hcont : Continuous Rinf) :
    Rinf Linfty = Linfty := by
  apply dist_eq_zero.mp
  by_contra hne
  have hd : 0 < dist (Rinf Linfty) Linfty :=
    lt_of_le_of_ne dist_nonneg (Ne.symm hne)
  let ε := dist (Rinf Linfty) Linfty / 4
  have hε : 0 < ε := div_pos hd (by norm_num)
  have hcomp : Tendsto (fun n => Rinf (L n)) atTop (nhds (Rinf Linfty)) :=
    hcont.continuousAt.tendsto.comp hL
  obtain ⟨N₁, hN₁⟩ := Metric.tendsto_atTop.1 hcomp ε hε
  obtain ⟨N₂, hN₂⟩ := Metric.tendsto_atTop.1 hL ε hε
  obtain ⟨N₃, hN₃⟩ := huniform ε hε
  let n := max (max N₁ N₂) N₃
  have hn1 : N₁ ≤ n := le_trans (le_max_left _ _) (le_max_left _ _)
  have hn2 : N₂ ≤ n := le_trans (le_max_right _ _) (le_max_left _ _)
  have hn3 : N₃ ≤ n := le_max_right _ _
  have ha := hN₁ n hn1
  have hb := hN₃ n hn3 (L n)
  have hc := hN₂ (n + 1) (le_trans hn2 (Nat.le_add_right n 1))
  have htri : dist (Rinf Linfty) Linfty < ε + ε + ε := by
    calc
      dist (Rinf Linfty) Linfty ≤
          dist (Rinf Linfty) (Rinf (L n)) + dist (Rinf (L n)) Linfty :=
        dist_triangle _ _ _
      _ ≤ dist (Rinf Linfty) (Rinf (L n)) +
          (dist (Rinf (L n)) (R n (L n)) + dist (R n (L n)) Linfty) := by
        gcongr
        exact dist_triangle _ _ _
      _ < ε + ε + ε := by
        rw [hstep n] at hc
        have ha' : dist (Rinf Linfty) (Rinf (L n)) < ε := by
          simpa [dist_comm] using ha
        have hb' : dist (Rinf (L n)) (R n (L n)) < ε := by
          simpa [dist_comm] using hb
        linarith [ha', hb', hc]
  dsimp [ε] at htri
  linarith

/-- If the zero-descent set is the singleton `{Lstar}`, any limiting state
proved to have zero descent is uniquely `Lstar`. This isolates exactly the
source proposition's uniqueness premise. -/
theorem limit_eq_of_zeroDescent_singleton {X : Type} {zeroDescent : Set X}
    {Linfty Lstar : X} (hzero : Linfty ∈ zeroDescent)
    (hsingle : zeroDescent = {Lstar}) :
    Linfty = Lstar := by
  rw [hsingle, Set.mem_singleton_iff] at hzero
  exact hzero

/- ================================================================
   Book 3 → Book 6 → Book 9 layered liberation   ================================================================ -/

/-- A recursive liberation path whose states are finite power kernels,
combining Book 9 descent with Book 6 closed internal exchange. Since Book 6
identifies total pair power with Book 3 metabolic rate, this is the typed
three-book interface rather than an independent Book 9 abstraction. -/
structure HomeostaticLiberation (n : Nat) extends
    Book6.ClosedPowerEvolution (Fin n) where
  Lambda : Nat → Real
  Lambda_nonneg : ∀ k, 0 ≤ Lambda k
  descent : ∀ k, dist (power k) (power (k + 1)) ≤ Lambda k - Lambda (k + 1)

/-- Forgetting closed-exchange structure yields the Book 9 liberation
-descent object, so the general convergence theorem applies unchanged. -/
def HomeostaticLiberation.toLiberationDescent {n : Nat}
    (d : HomeostaticLiberation n) :
    LiberationDescent (Fin n → Fin n → Real) where
  L := d.power
  Lambda := d.Lambda
  Lambda_nonneg := d.Lambda_nonneg
  descent := d.descent

/-- The layered liberation path converges by Book 9's descent theorem. -/
theorem homeostaticLiberation_converges {n : Nat}
    (d : HomeostaticLiberation n) :
    ∃ Linfty : Fin n → Fin n → Real,
      Tendsto d.power atTop (nhds Linfty) :=
  liberationDescent_converges d.toLiberationDescent

/-- If its initial metabolic rate lies in a Book 3 homeostatic band, every
finite Book 9 liberation stage remains in that band by Book 6 conservation. -/
theorem homeostaticLiberation_all {n : Nat}
    (d : HomeostaticLiberation n) {rmin rmax : Real}
    (h0 : Book3.Homeostatic (Book3.metabolicRate (d.power 0)) rmin rmax) :
    ∀ k, Book3.Homeostatic (Book3.metabolicRate (d.power k)) rmin rmax :=
  Book6.closedPower_homeostatic_all d.toClosedPowerEvolution h0/- ================================================================
   corollary:bk9_final_collapse_inversion_principle, definition:bk9_collapse_inversion_operator
   ================================================================ -/

/-- The Collapse-Inversion Operator (definition:bk9_collapse_inversion_operator):
a total map from frozen/terminal states to a minimal generative seed
state, packaged with the specific frozen/seed pair it acts on. -/
structure CollapseInversion (C : Type) where
  frozenState : C
  seedState : C
  collapse : C → C
  collapse_frozen : collapse frozenState = seedState

/-- Final Collapse-Inversion Principle
(corollary:bk9_final_collapse_inversion_principle): if the realization map
`Gamma` sends the limiting freedom operator `Linfty` to the frozen state,
the collapse-inversion operator carries that same frozen state on to the
seed state. -/
theorem finalCollapseInversion {L C : Type} (ci : CollapseInversion C) (Gamma : L → C)
    (Linfty : L) (hfrozen : Gamma Linfty = ci.frozenState) :
    ci.collapse (Gamma Linfty) = ci.seedState := by
  rw [hfrozen]
  exact ci.collapse_frozen

/- ================================================================
   definition:bk9_symbolic_framework
   ================================================================ -/

/-- Symbolic Framework (definition:bk9_symbolic_framework): a `Nat`-indexed
family of admissible lawful transitions on `S`, closed under composition
(`Phi (m + n) = Phi m ∘ Phi n`) with `Phi 0 = id`. Only the discrete
(`Nat`-indexed) semigroup law is modeled; continuous-time indexing is
not. -/
structure SymbolicFramework (S : Type) where
  Phi : Nat → S → S
  Phi_zero : Phi 0 = id
  Phi_add : ∀ m n, Phi (m + n) = Phi m ∘ Phi n

/-- Every lawful transition is the `n`-fold self-composition of the
single-step transition `Phi 1` -- "the closed family of all its iterated
transformations" reduces to iterating one generator. -/
theorem symbolicFramework_iterate {S : Type} (f : SymbolicFramework S) (n : Nat) :
    f.Phi n = (f.Phi 1)^[n] := by
  induction n with
  | zero => rw [f.Phi_zero, Function.iterate_zero]
  | succ k ih => rw [f.Phi_add k 1, ih, Function.iterate_succ]

/- ================================================================
   proposition:bk9_modes_of_re_interpretation
   ================================================================ -/

/-- Modes of Re-Interpretation (proposition:bk9_modes_of_re_interpretation):
classifying a re-interpretation event by the sign of its free-energy
change `deltaF`. "Repair" (`deltaF ≤ 0`) and "Distortion" (`deltaF > 0`)
are the two branches used elsewhere in the definition; the "Freedom"
branch is a further qualification of either (guided by the awakened
operator) and adds no new sign condition, so it is not separately
modeled. -/
theorem reinterpretation_dichotomy_exhaustive (deltaF : Real) :
    deltaF ≤ 0 ∨ 0 < deltaF := by
  rcases lt_or_ge 0 deltaF with h | h
  · exact Or.inr h
  · exact Or.inl h

theorem reinterpretation_dichotomy_exclusive {deltaF : Real} (h : deltaF ≤ 0) :
    ¬ (0 < deltaF) :=
  not_lt.mpr h

/- ================================================================
   definition:bk9_symbolic_thermodynamic_stress
   ================================================================ -/

/-- Symbolic Thermodynamic Stress data
(definition:bk9_symbolic_thermodynamic_stress): the four drift/curvature
norm terms are genuinely nonnegative (norms), and the free-energy term is
recorded as a gap `freeEnergy - freeEnergyMin`. -/
structure ThermodynamicStress where
  driftA : Real
  driftB : Real
  driftMismatch : Real
  curvatureGrad : Real
  driftA_nonneg : 0 ≤ driftA
  driftB_nonneg : 0 ≤ driftB
  driftMismatch_nonneg : 0 ≤ driftMismatch
  curvatureGrad_nonneg : 0 ≤ curvatureGrad
  freeEnergy : Real
  freeEnergyMin : Real
  freeEnergy_above_min : freeEnergyMin ≤ freeEnergy

/-- The total symbolic thermodynamic stress `Sigma_AB` is nonnegative
whenever the dyad's joint free energy sits at or above its floor. -/
theorem thermodynamicStress_nonneg (t : ThermodynamicStress) :
    0 ≤ t.driftA + t.driftB + t.driftMismatch + t.curvatureGrad
          + (t.freeEnergy - t.freeEnergyMin) := by
  have h : 0 ≤ t.freeEnergy - t.freeEnergyMin := by linarith [t.freeEnergy_above_min]
  linarith [t.driftA_nonneg, t.driftB_nonneg, t.driftMismatch_nonneg, t.curvatureGrad_nonneg]

end ForcingAnalysis.Book9
