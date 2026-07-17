/-
Book4B.lean - repair/freedom/autonomy arithmetic and fuzzy-derivative error
scaling, honest kernel.

SCOPE NOTE: the assignment brief for this slice named "Ising covenant",
"imagination as imaginary traversal", "test-time integrative expansion", and
"SRMF" as the expected topics. The actual packet handed to this worker
(book4b_packet.md, 81 anchors) contains none of those terms or anything
answering to them; it instead covers (a) symbolic-identity fragmentation,
repair, and self-healing, (b) individuation, constraint domains, freedom,
autonomy, and self-authorship, and (c) an "observer-relative fuzzy calculus"
extending classical differentiation/integration rules (chain/product/
quotient/sum/power rules, gradient, Jacobian, Stokes, gauge theory, Wilson
loops, Helmholtz decomposition) on Riemannian/Banach symbolic manifolds. This
file formalizes the honest kernel of THAT packet's content; the topic labels
in the brief could not be honored since no matching material exists in the
source anchors. This is flagged for the lead rather than silently
substituted.

Of the packet actually supplied, the overwhelming majority of anchors are
manifold-, Hilbert/Banach-, or PDE-flavored (observer-induced metrics and
their Riemann curvature, differentiable-structure/chart-convergence theorems,
the fuzzy Fundamental Theorem of Calculus and its holonomy corrections,
symbolic Stokes/gauge-dictionary/Wilson-loop/quantum-geometry material, and
fuzzy divergence/curl/Helmholtz decomposition on manifolds) or are narrative/
taxonomic (the three-clause definitions of individuation, autonomy, proto-
vitality; the "emergence of meaning" corollary's citation to Piaget) or
require genuine transfinite/limit convergence (constraint-map fixed points,
self-authorship's limiting sequence). None of these are attempted here; they
are listed as open anchors in the accompanying proposal.

What IS honestly formalizable from this packet, and is formalized below:

  * "Fragmentation Cascade"'s propagation-probability formula
    `1 - exp(-β κ)` becomes a genuine real-valued threshold law: the
    probability lies in `[0, 1)` and is strictly increasing in the coupling
    integral, for any fixed positive `β`;
  * "Repair Process" (and the reflexive-composition narrative wrapped around
    it in "Recursive Self-Healing") becomes a finite/discrete fragmentation-
    measure sequence that decreases by a fixed positive amount at every
    repair step, together with the telescoping accumulation bound and
    step-count termination theorem this forces -- the same finite kernel
    shape as the metabolic-sufficiency pair in Book8, applied here to a
    decreasing symbolic-fragmentation measure instead of free energy;
  * "Reflective Reentry" and "Conditions for Self-Healing" both reduce to
    the same threshold-transitivity shape (`x` exceeding a bound that itself
    exceeds a critical value forces `x` past the critical value), proved as
    two direct instances;
  * "Repair Capacity"'s upper bound `1 - 1/(n_max + 1)` becomes a genuine
    real sequence: always in `[0, 1)` and strictly increasing in `n_max`;
  * "Symbolic Flow Freedom" and the "Freedom Criterion" become a two-clause
    predicate (reflection-fixed image, plus an explicit escape from the
    initial constraint domain) together with an explicit countermodel
    showing the identity flow can never supply the escape clause, so freedom
    is a genuinely non-vacuous condition on the flow;
  * "Autonomy-Freedom Relation" / "Goal-Directed Autonomy Enables Freedom"
    become the direct existential transfer: exhibiting a decision/goal
    composite satisfying flow freedom is exactly exhibiting a free flow
    (only the stated direction is proved; the converse would need an
    unstated surjectivity assumption on the decision/goal maps);
  * "Symbolic Freedom Measure" becomes a genuine `[0, 1]`-valued ratio law
    from three real hypotheses (entropy nonnegativity and monotonicity);
  * "Constraint Liberation" reduces, once the transfinite fixed-point
    machinery is stripped, to the honest finite/order-theoretic residue: a
    monotone (non-decreasing) sequence of constraint domains that changes
    somewhere is a strict superset of its starting domain;
  * "Freedom-Life Connection"'s derivative condition `dF_free/dt > 0`
    becomes its discrete analogue: a sequence increasing by a fixed positive
    amount at every step, which is thereby strictly monotone and admits the
    same telescoping accumulation bound as the repair-process case;
  * the shared "error term" schema running through the "Fuzzy Chain/Product/
    Quotient/Sum/Power Rule" theorems and the "Existence of Observer-Valid
    Derivatives" theorem -- in every case an error bounded by `ε` (or `ε²`)
    times nonnegative norm factors -- becomes two genuine monotonicity laws:
    such a bound is nondecreasing in `ε`, linearly for the chain/sum-rule
    shape and quadratically for the product/quotient/power-rule shape. The
    "Fuzzy Quotient Rule"'s resolution floor additionally admits a concrete
    lower bound beyond the shared schema;
  * the "Fuzzy Gradient Operator"'s partial-derivative bound `M_f / ε_O`
    gives the converse honest fact: for a fixed nonzero bound `M_f`, this
    quantity is strictly *decreasing* as the observer's resolution
    threshold `ε_O` grows -- an explicit antitone counterpoint to the
    monotone-in-`ε` error laws above;
  * "Gradient Stability Under Observer Perturbations" becomes the bound's
    honest corollary when two observers share a resolution: the gradient
    discrepancy is then bounded by the quadratic correction term alone.

Anchors whose only quantitative content is an unspecified correction term
with no stated inequality (the Fuzzy Exponential and Logarithmic Rules), or
whose stated law only restates already-covered chain/product/sum
error-scaling in words alongside two non-quantitative claims (the "Algebraic
Properties of the Fuzzy Derivative" proposition's frame-dependence and
approximate-vanishing clauses), are covered only partially, as noted in the
accompanying proposal.
-/

import Mathlib
import ForcingAnalysis.ScholiumC
import ForcingAnalysis.ScholiumDynamics

namespace ForcingAnalysis.Book4B

/- ================================================================
   lemma:bk4_fragmentation_cascade
   ================================================================ -/

/-- The propagation-probability formula of lemma:bk4_fragmentation_cascade,
`1 - exp(-β κ)`, stripped of the manifold-valued curvature integral `κ`
(which is kept here as an arbitrary nonnegative real, the honest residue of
"the coupling integral is a nonnegative accumulation of symbolic
curvature"). -/
noncomputable def cascadeProb (β κ : ℝ) : ℝ := 1 - Real.exp (-(β * κ))

/-- The propagation probability is never negative. -/
theorem cascadeProb_nonneg {β κ : ℝ} (hβ : 0 ≤ β) (hκ : 0 ≤ κ) :
    0 ≤ cascadeProb β κ := by
  unfold cascadeProb
  have h1 : -(β * κ) ≤ 0 := by nlinarith
  have h2 : Real.exp (-(β * κ)) ≤ Real.exp 0 := Real.exp_le_exp.mpr h1
  rw [Real.exp_zero] at h2
  linarith

/-- The propagation probability never reaches certainty, for any scaling
constant and coupling integral: `exp` is always strictly positive. -/
theorem cascadeProb_lt_one (β κ : ℝ) : cascadeProb β κ < 1 := by
  unfold cascadeProb
  have h := Real.exp_pos (-(β * κ))
  linarith

/-- The propagation probability is strictly increasing in the coupling
integral, for any fixed positive scaling constant `β` -- the honest content
of "fragmentation propagates more readily as the coupling between regions
strengthens." -/
theorem cascadeProb_strictMono {β : ℝ} (hβ : 0 < β) {κ1 κ2 : ℝ} (h : κ1 < κ2) :
    cascadeProb β κ1 < cascadeProb β κ2 := by
  unfold cascadeProb
  have h1 : -(β * κ2) < -(β * κ1) := by nlinarith
  have h2 : Real.exp (-(β * κ2)) < Real.exp (-(β * κ1)) := Real.exp_lt_exp.mpr h1
  linarith

/- ================================================================
   definition:bk4_repair_process, definition:bk4_recursive_self_healing
   ================================================================ -/

/-- A repair sufficiency law (definition:bk4_repair_process, and the
reflexive-composition wrapper around it in
definition:bk4_recursive_self_healing): a fragmentation measure, indexed by
repair step, that is always nonnegative and strictly decreases by a fixed
positive amount at every step. The specific self-reference/persistence
operator composition of recursive self-healing is not modeled; only the
monotone-decrease law any such repair process must obey is. -/
structure RepairSufficiency where
  frag : Nat → Real
  frag_nonneg : ∀ k, 0 ≤ frag k
  deltaF : Real
  deltaF_pos : 0 < deltaF
  decreasing : ∀ k, frag (k + 1) ≤ frag k - deltaF

/-- Telescoped decrease bound, by induction on the number of repair steps. -/
theorem repairSufficiency_decrease_accum (r : RepairSufficiency) (n : Nat) :
    r.frag n ≤ r.frag 0 - (n : Real) * r.deltaF := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep := r.decreasing k
      have hcast : ((k + 1 : Nat) : Real) * r.deltaF = (k : Real) * r.deltaF + r.deltaF := by
        push_cast; ring
      rw [hcast]
      linarith

/-- A nonnegative fragmentation measure that decreases by a fixed positive
amount every step cannot keep decreasing forever: repair sufficiency forces
termination within a computable number of steps. -/
theorem repairSufficiency_terminates (r : RepairSufficiency) (n : Nat)
    (hn : r.frag 0 < (n : Real) * r.deltaF) : False := by
  have hacc := repairSufficiency_decrease_accum r n
  have hnn := r.frag_nonneg n
  linarith

/- ================================================================
   theorem:bk4_reflective_reentry, theorem:bk4_conditions_for_self_healing
   ================================================================ -/

/-- The threshold-transitivity content of theorem:bk4_reflective_reentry: a
recovery threshold strictly above the critical value, met or exceeded by the
reflective overlap, forces the overlap itself strictly above the critical
value. -/
theorem recovery_threshold_exceeds_crit {epsCrit eta overlap : Real}
    (heta : eta > epsCrit) (hoverlap : overlap ≥ eta) : overlap > epsCrit := by
  linarith

/-- The same threshold-transitivity shape, instantiated at
theorem:bk4_conditions_for_self_healing's core-region coherence clause: a
core error strictly below the critical error, together with core coherence
exceeding `1` minus the core error, forces coherence past `1` minus the
critical error. -/
theorem coreCoherence_exceeds_crit {epsCore epsCrit x : Real}
    (h : epsCore < epsCrit) (hx : x > 1 - epsCore) : x > 1 - epsCrit := by
  linarith

/- ================================================================
   definition:bk4_repair_capacity, lemma:bk4_upper_bound_on_repair_capacit
   ================================================================ -/

/-- The upper-bound expression of lemma:bk4_upper_bound_on_repair_capacit,
`1 - 1/(n_max + 1)`, as a function of the recursive depth capacity alone. -/
noncomputable def repairCapacityBound (n : Nat) : Real := 1 - 1 / ((n : Real) + 1)

theorem repairCapacityBound_nonneg (n : Nat) : 0 ≤ repairCapacityBound n := by
  unfold repairCapacityBound
  have hpos : (0 : Real) < (n : Real) + 1 := by positivity
  have hn : (0 : Real) ≤ (n : Real) := Nat.cast_nonneg n
  rw [le_sub_iff_add_le, zero_add, div_le_one hpos]
  linarith

theorem repairCapacityBound_lt_one (n : Nat) : repairCapacityBound n < 1 := by
  unfold repairCapacityBound
  have h : 0 < 1 / ((n : Real) + 1) := by positivity
  linarith

/-- Greater recursive depth capacity strictly raises the repair-capacity
ceiling. -/
theorem repairCapacityBound_strictMono {m n : Nat} (h : m < n) :
    repairCapacityBound m < repairCapacityBound n := by
  unfold repairCapacityBound
  have hm : (0 : Real) < (m : Real) + 1 := by positivity
  have hn : (0 : Real) < (n : Real) + 1 := by positivity
  have hlt : (m : Real) + 1 < (n : Real) + 1 := by
    have hc : (m : Real) < (n : Real) := by exact_mod_cast h
    linarith
  rw [sub_lt_sub_iff_left, div_lt_div_iff₀ hn hm]
  linarith

/-- A symbolic identity's repair capacity (definition:bk4_repair_capacity),
kept as a structure field bounded by the ceiling above rather than derived
from the `sup` over repair processes (no topology on the space of repair
processes is modeled). -/
structure RepairCapacity where
  C : Real
  nMax : Nat
  bound : C ≤ repairCapacityBound nMax

theorem repairCapacity_lt_one (r : RepairCapacity) : r.C < 1 :=
  lt_of_le_of_lt r.bound (repairCapacityBound_lt_one r.nMax)

/- ================================================================
   definition:bk4_symbolic_flow_freedom, theorem:bk4_freedom_criterion
   ================================================================ -/

/-- A symbolic flow `Φ` exhibits freedom relative to reflection operator `R`,
carrier state `Ψ`, and initial constraint domain `U0`
(definition:bk4_symbolic_flow_freedom) exactly when it (1) lands on a fixed
point of the reflection operator and (2) sends some point of `U0` outside
`U0`. -/
def SymbolicFlowFreedom {X : Type} (Φ R : X → X) (Ψ : X) (U0 : Set X) : Prop :=
  R (Φ Ψ) = Φ Ψ ∧ ∃ x ∈ U0, Φ x ∉ U0

/-- theorem:bk4_freedom_criterion: a symbolic identity expresses freedom
exactly when some symbolic flow exhibits flow freedom. -/
def SymbolicFreedom {X : Type} (R : X → X) (Ψ : X) (U0 : Set X) : Prop :=
  ∃ Φ : X → X, SymbolicFlowFreedom Φ R Ψ U0

theorem symbolicFreedom_of_flowFreedom {X : Type} {Φ R : X → X} {Ψ : X} {U0 : Set X}
    (h : SymbolicFlowFreedom Φ R Ψ U0) : SymbolicFreedom R Ψ U0 :=
  ⟨Φ, h⟩

/-- Freedom retains both source clauses. It cannot be weakened to escape
alone or to coherence alone: every witness preserves the carrier through
reflection while also crossing the initial constraint boundary. -/
theorem symbolicFreedom_components {X : Type} {R : X → X} {Ψ : X} {U0 : Set X}
    (h : SymbolicFreedom R Ψ U0) :
    ∃ Φ : X → X,
      R (Φ Ψ) = Φ Ψ ∧ ∃ x ∈ U0, Φ x ∉ U0 := by
  exact h

/-- The identity flow can never supply the escape clause of flow freedom,
for any initial domain: an explicit witness that flow freedom's second
condition is a genuine (non-vacuous) constraint on the flow, not
automatically satisfied by every reflection-fixed flow. -/
theorem id_has_no_escape {X : Type} (U0 : Set X) :
    ¬ ∃ x ∈ U0, (id : X → X) x ∉ U0 := by
  rintro ⟨x, hx, hx'⟩
  exact hx' hx

/-- Coherence alone does not imply freedom. On a one-state carrier the
identity flow is reflection-fixed, but there is no boundary it can cross. -/
theorem coherence_alone_does_not_force_freedom :
    ∃ (R Φ : Unit → Unit) (Ψ : Unit) (U0 : Set Unit),
      R (Φ Ψ) = Φ Ψ ∧ ¬ SymbolicFlowFreedom Φ R Ψ U0 := by
  refine ⟨id, id, (), Set.univ, rfl, ?_⟩
  simp [SymbolicFlowFreedom]

/-- Boundary crossing alone does not imply freedom. A Boolean flip exits
the singleton initial domain, but a second flip used as reflection rejects
the resulting state rather than fixing it. -/
theorem escape_alone_does_not_force_freedom :
    ∃ (R Φ : Bool → Bool) (Ψ : Bool) (U0 : Set Bool),
      (∃ x ∈ U0, Φ x ∉ U0) ∧ ¬ SymbolicFlowFreedom Φ R Ψ U0 := by
  let flip : Bool → Bool := fun b => !b
  let U0 : Set Bool := {false}
  refine ⟨flip, flip, false, U0, ?_, ?_⟩
  · exact ⟨false, by simp [U0], by simp [U0, flip]⟩
  · simp [SymbolicFlowFreedom, flip]

/-- The manuscript's explicit "not the absence of constraint" claim has a
concrete model: the initial domain is a proper singleton, yet a
coherence-preserving Boolean flow crosses its boundary. -/
theorem freedom_with_nontrivial_initial_constraint :
    ∃ (R Φ : Bool → Bool) (Ψ : Bool) (U0 : Set Bool),
      U0 ≠ Set.univ ∧ SymbolicFlowFreedom Φ R Ψ U0 := by
  let flip : Bool → Bool := fun b => !b
  let U0 : Set Bool := {false}
  refine ⟨id, flip, false, U0, ?_, ?_⟩
  · simp [U0, Set.ext_iff]
  · refine ⟨rfl, false, by simp [U0], ?_⟩
    simp [U0, flip]

/- ================================================================
   lemma:bk4_autonomy_freedom_relation,
   proposition:bk4_autonomy_implies_freedom
   ================================================================ -/

/-- The provable direction of lemma:bk4_autonomy_freedom_relation and
proposition:bk4_autonomy_implies_freedom: if the decision/goal composite
`D(G(·, e), g)` built from a chosen goal `g` and environment `e` exhibits
flow freedom, then the identity exhibits symbolic freedom. (The converse
direction of the lemma -- that freedom forces the existence of such `g, e`
-- is not modeled, since it would require an unstated surjectivity
assumption on `D, G`.) -/
theorem autonomy_implies_freedom {X A : Type} (D G : X → A → X) (R : X → X)
    (Ψ : X) (U0 : Set X) (g e : A)
    (hff : SymbolicFlowFreedom (fun x => D (G x e) g) R Ψ U0) :
    SymbolicFreedom R Ψ U0 :=
  ⟨fun x => D (G x e) g, hff⟩

/- ================================================================
   definition:bk4_symbolic_freedom_measure
   ================================================================ -/

/-- The freedom-measure law of definition:bk4_symbolic_freedom_measure,
`(H(U_∞) - H(U_0)) / H(U_∞)`, kept as a structure with the entropy
nonnegativity/monotonicity hypotheses the ratio needs to be well-behaved. -/
structure SymbolicFreedomMeasure where
  H0 : Real
  Hinf : Real
  H0_nonneg : 0 ≤ H0
  Hinf_pos : 0 < Hinf
  mono : H0 ≤ Hinf

noncomputable def SymbolicFreedomMeasure.value (m : SymbolicFreedomMeasure) : Real :=
  (m.Hinf - m.H0) / m.Hinf

theorem freedomMeasure_nonneg (m : SymbolicFreedomMeasure) : 0 ≤ m.value := by
  unfold SymbolicFreedomMeasure.value
  have h : 0 ≤ m.Hinf - m.H0 := by linarith [m.mono]
  exact div_nonneg h m.Hinf_pos.le

theorem freedomMeasure_le_one (m : SymbolicFreedomMeasure) : m.value ≤ 1 := by
  unfold SymbolicFreedomMeasure.value
  rw [div_le_one m.Hinf_pos]
  linarith [m.H0_nonneg]

/- ================================================================
   definition:bk4_constraint_domain, theorem:bk4_recursive_constraint_libera
   ================================================================ -/

/-- The honest finite/order-theoretic residue of
theorem:bk4_recursive_constraint_libera once the transfinite fixed-point
convergence of the constraint-map sequence is stripped away
(definition:bk4_constraint_domain supplies the domains `U n`): a monotone
(non-decreasing) sequence of constraint domains that ever changes is
thereby a strict superset of where it started. -/
theorem constraintDomain_strict_growth {X : Type} {U : Nat → Set X}
    (hmono : Monotone U) {n : Nat} (hgrow : U n ≠ U 0) :
    U 0 ⊂ U n :=
  lt_of_le_of_ne (hmono (Nat.zero_le n)) (Ne.symm hgrow)

/-- The finite-stage limit domain is the union of every constraint domain.
This is an order-theoretic colimit, not an asserted metric or transfinite
limit of the unmodeled constraint maps. -/
def constraintLimit {X : Type} (U : Nat → Set X) : Set X := ⋃ n, U n

theorem mem_constraintLimit_iff {X : Type} {U : Nat → Set X} {x : X} :
    x ∈ constraintLimit U ↔ ∃ n, x ∈ U n := by
  simp [constraintLimit]

/-- Every finite stage embeds in the limit domain. -/
theorem constraintDomain_subset_limit {X : Type} (U : Nat → Set X) (n : Nat) :
    U n ⊆ constraintLimit U :=
  Set.subset_iUnion U n

/-- The limit is the least domain containing every finite stage. -/
theorem constraintLimit_least {X : Type} {U : Nat → Set X} {V : Set X}
    (hV : ∀ n, U n ⊆ V) :
    constraintLimit U ⊆ V := by
  exact Set.iUnion_subset hV

/-- Scholium → Book 4: nested constraint domains form an explicit directed
stage system, with inclusions as transition maps. -/
def constraintDirectedSystem {X : Type} (U : ℕ → Set X) (hmono : Monotone U) :
    ScholiumC.DirectedStageSystem where
  carrier n := U n
  transition hmn x := ⟨x.1, hmono hmn x.2⟩
  transition_id _ _ := rfl
  transition_comp _ _ _ := rfl

/-- The ordinary union receives the canonical cocone from the Scholium
directed system of constraint domains. -/
def constraintLimitCocone {X : Type} (U : ℕ → Set X) (hmono : Monotone U) :
    (constraintDirectedSystem U hmono).Cocone (constraintLimit U) where
  leg n x := ⟨x.1, constraintDomain_subset_limit U n x.2⟩
  naturality _ _ := rfl

/-- Hence the Scholium stage colimit has a unique interpretation in Book 4's
union-limit, agreeing with the inclusion of every finite constraint stage. -/
theorem constraintDirectedSystem_universal {X : Type} (U : ℕ → Set X)
    (hmono : Monotone U) :
    ∃! h : (constraintDirectedSystem U hmono).Colimit → constraintLimit U,
      ∀ n x, h ((constraintDirectedSystem U hmono).injection n x) =
        (constraintLimitCocone U hmono).leg n x :=
  ScholiumC.DirectedStageSystem.directed_colimit_universal_property
    (constraintLimitCocone U hmono)

/-- A monotone sequence has the same limit after discarding its first stage:
the order-theoretic limit is invariant under the successor shift. -/
theorem constraintLimit_tail_eq {X : Type} {U : Nat → Set X}
    (hmono : Monotone U) :
    constraintLimit (fun n => U (n + 1)) = constraintLimit U := by
  apply Set.Subset.antisymm
  · exact constraintLimit_least (fun n => constraintDomain_subset_limit U (n + 1))
  · apply constraintLimit_least
    intro n
    exact fun x hx => Set.mem_iUnion.2 ⟨n, hmono (Nat.le_add_right n 1) hx⟩

/-- If any finite stage genuinely grows, the constructed limit is a strict
extension of the initial constraint domain. -/
theorem constraintLimit_strict_growth {X : Type} {U : Nat → Set X}
    (hmono : Monotone U) {n : Nat} (hgrow : U n ≠ U 0) :
    U 0 ⊂ constraintLimit U :=
  (constraintDomain_strict_growth hmono hgrow).trans_le
    (constraintDomain_subset_limit U n)

/-- The finite constraint domain generated by the Scholium's discrete flow:
all orbit points reached in at most `n` steps. -/
def orbitConstraintDomain {X : Type} (d : X → X) (x : X) (n : Nat) : Set X :=
  {y | ∃ k ≤ n, ScholiumDyn.flowOrbit d x k = y}

theorem orbitConstraintDomain_mono {X : Type} (d : X → X) (x : X) :
    Monotone (orbitConstraintDomain d x) := by
  intro m n hmn y
  rintro ⟨k, hk, rfl⟩
  exact ⟨k, le_trans hk hmn, rfl⟩

/-- Scholium → Book 4: the union-limit of the finite reachable domains is
exactly the range of the Scholium flow orbit. -/
theorem orbitConstraintLimit_eq_range {X : Type} (d : X → X) (x : X) :
    constraintLimit (orbitConstraintDomain d x) =
      Set.range (ScholiumDyn.flowOrbit d x) := by
  ext y
  constructor
  · rw [mem_constraintLimit_iff]
    rintro ⟨n, k, _hk, hky⟩
    exact ⟨k, hky⟩
  · rintro ⟨k, rfl⟩
    rw [mem_constraintLimit_iff]
    exact ⟨k, k, le_rfl, rfl⟩
/- ================================================================
   Transfinite constraint-map convergence
   ================================================================ -/

/-- An ordinal-indexed iteration of an otherwise arbitrary monotone
constraint map. Successors apply the map; genuine limit ordinals take the
union of all earlier stages. Starting from `⊥` exposes the standard
least-fixed-point traversal rather than baking a candidate limit into the
data. -/
structure TransfiniteConstraintIteration (X : Type) where
  map : Set X →o Set X
  stage : Ordinal → Set X
  stage_zero : stage 0 = ⊥
  stage_succ : ∀ α, stage (Order.succ α) = map (stage α)
  stage_limit : ∀ limitOrd, Order.IsSuccLimit limitOrd →
    stage limitOrd = ⋃ β : Set.Iio limitOrd, stage β.1

/-- The Knaster--Tarski target of any monotone constraint map. -/
def TransfiniteConstraintIteration.leastFixedPoint {X : Type}
    (T : TransfiniteConstraintIteration X) : Set X :=
  T.map.lfp

/-- Every unspecified monotone constraint map has a certified least fixed
point, independently of whether a particular ordinal traversal reaches it. -/
theorem transfiniteConstraint_leastFixedPoint_fixed {X : Type}
    (T : TransfiniteConstraintIteration X) :
    T.map T.leastFixedPoint = T.leastFixedPoint :=
  T.map.map_lfp

/-- The target is below every other fixed constraint domain. -/
theorem transfiniteConstraint_leastFixedPoint_le {X : Type}
    (T : TransfiniteConstraintIteration X) {V : Set X}
    (hV : T.map V = V) :
    T.leastFixedPoint ⊆ V :=
  T.map.lfp_le_fixed hV

/-- Every stage of the bottom-started ordinal iteration lies below every
fixed point. This is the standard leastness invariant, now derived by
ordinal limit induction from the successor and union-limit laws. -/
theorem transfiniteConstraint_stage_le_fixed {X : Type}
    (T : TransfiniteConstraintIteration X) {V : Set X}
    (hV : T.map V = V) (α : Ordinal) :
    T.stage α ⊆ V := by
  induction α using Ordinal.limitRecOn with
  | zero =>
      rw [T.stage_zero]
      exact bot_le
  | add_one α ih =>
      rw [← Order.succ_eq_add_one, T.stage_succ]
      exact (T.map.monotone ih).trans hV.le
  | limit α hlimit ih =>
      rw [T.stage_limit α hlimit]
      exact Set.iUnion_subset fun β => ih β.1 β.2

/-- Eventual constancy from an ordinal stage onward. -/
def TransfiniteConstraintIteration.StabilizesAt {X : Type}
    (T : TransfiniteConstraintIteration X) (κ : Ordinal) : Prop :=
  ∀ β, κ ≤ β → T.stage β = T.stage κ

/-- Any stabilized ordinal stage is a genuine fixed point of the constraint
map; this is the convergence-to-fixed-point implication. -/
theorem transfiniteConstraint_stabilized_fixed {X : Type}
    (T : TransfiniteConstraintIteration X) {κ : Ordinal}
    (hstab : T.StabilizesAt κ) :
    T.map (T.stage κ) = T.stage κ := by
  rw [← T.stage_succ κ]
  exact hstab (Order.succ κ) (Order.le_succ κ)

/-- A stabilized bottom-started transfinite traversal has converged exactly
to the least fixed point. No separate leastness premise remains: it follows
from ordinal induction above. -/
theorem transfiniteConstraint_stabilized_eq_lfp {X : Type}
    (T : TransfiniteConstraintIteration X) {κ : Ordinal}
    (hstab : T.StabilizesAt κ) :
    T.stage κ = T.leastFixedPoint := by
  apply Set.Subset.antisymm
  · exact transfiniteConstraint_stage_le_fixed T T.map.map_lfp κ
  · exact T.map.lfp_le_fixed (transfiniteConstraint_stabilized_fixed T hstab)

/-- A sufficiently large well-ordered index forces an inflationary monotone
constraint iteration to revisit a stage. Monotonicity then turns that
repetition into a genuine fixed point. This is the cardinal-size argument
that supplies stabilization rather than assuming it. -/
theorem transfiniteIterate_exists_fixed_of_card_lt
    {X J : Type} [LinearOrder J] [OrderBot J] [SuccOrder J] [WellFoundedLT J]
    (F : Set X →o Set X) (hinfl : ∀ U, U ⊆ F U)
    (hcard : Cardinal.mk (Set X) < Cardinal.mk J) :
    ∃ j : J,
      F (transfiniteIterate F j (⊥ : Set X)) =
        transfiniteIterate F j (⊥ : Set X) := by
  let stage : J → Set X := fun j => transfiniteIterate F j (⊥ : Set X)
  have hnot : ¬ Function.Injective stage := by
    intro hinj
    exact (not_le_of_gt hcard) (Cardinal.mk_le_of_injective hinj)
  obtain ⟨j₁, j₂, hj, heq⟩ :
      ∃ j₁ j₂ : J, j₁ < j₂ ∧ stage j₁ = stage j₂ := by
    grind [Function.Injective]
  have hj₁ : ¬ IsMax j₁ := not_isMax_iff.mpr ⟨j₂, hj⟩
  have hmono : Monotone stage :=
    monotone_transfiniteIterate F (⊥ : Set X) hinfl
  have hsucc : stage (Order.succ j₁) = F (stage j₁) :=
    transfiniteIterate_succ F (⊥ : Set X) j₁ hj₁
  refine ⟨j₁, Set.Subset.antisymm ?_ (hinfl (stage j₁))⟩
  rw [← hsucc]
  exact (hmono (Order.succ_le_of_lt hj)).trans heq.symm.le

/-- Every standard bottom-started transfinite iterate lies below every fixed
point of the monotone map. -/
theorem transfiniteIterate_le_fixed
    {X J : Type} [LinearOrder J] [OrderBot J] [SuccOrder J] [WellFoundedLT J]
    (F : Set X →o Set X) {V : Set X} (hV : F V = V) (j : J) :
    transfiniteIterate F j (⊥ : Set X) ⊆ V := by
  induction j using SuccOrder.limitRecOn with
  | isMin j hj =>
      obtain rfl := hj.eq_bot
      rw [transfiniteIterate_bot]
      exact bot_le
  | succ j hj ih =>
      rw [transfiniteIterate_succ F (⊥ : Set X) j hj]
      exact (F.monotone ih).trans hV.le
  | isSuccLimit j hj ih =>
      rw [transfiniteIterate_limit F (⊥ : Set X) j hj]
      exact iSup_le fun β => ih β.1 β.2

/-- Any fixed stage attained by the standard bottom-started traversal is
necessarily the least fixed point. -/
theorem transfiniteIterate_fixed_stage_eq_lfp
    {X J : Type} [LinearOrder J] [OrderBot J] [SuccOrder J] [WellFoundedLT J]
    (F : Set X →o Set X) {j : J}
    (hfix : F (transfiniteIterate F j (⊥ : Set X)) =
      transfiniteIterate F j (⊥ : Set X)) :
    transfiniteIterate F j (⊥ : Set X) = F.lfp := by
  apply Set.Subset.antisymm
  · exact transfiniteIterate_le_fixed F F.map_lfp j
  · exact F.lfp_le_fixed hfix

/-- Once a bottom-started inflationary transfinite iteration reaches a fixed
stage, every later stage is equal to it. -/
theorem transfiniteIterate_eventually_constant_of_fixed
    {X J : Type} [LinearOrder J] [OrderBot J] [SuccOrder J] [WellFoundedLT J]
    (F : Set X →o Set X) (hinfl : ∀ U, U ⊆ F U) {j : J}
    (hfix : F (transfiniteIterate F j (⊥ : Set X)) =
      transfiniteIterate F j (⊥ : Set X)) :
    ∀ k ≥ j,
      transfiniteIterate F k (⊥ : Set X) =
        transfiniteIterate F j (⊥ : Set X) := by
  intro k hjk
  have hmono : Monotone (fun k : J => transfiniteIterate F k (⊥ : Set X)) :=
    monotone_transfiniteIterate F (⊥ : Set X) hinfl
  have hj_lfp := transfiniteIterate_fixed_stage_eq_lfp F hfix
  apply Set.Subset.antisymm
  · calc
      transfiniteIterate F k (⊥ : Set X) ⊆ F.lfp :=
        transfiniteIterate_le_fixed F F.map_lfp k
      _ = transfiniteIterate F j (⊥ : Set X) := hj_lfp.symm
  · exact hmono hjk

/-- Cardinally large indexing now yields full eventual convergence, not
merely one isolated fixed stage. -/
theorem transfiniteIterate_eventually_constant_of_card_lt
    {X J : Type} [LinearOrder J] [OrderBot J] [SuccOrder J] [WellFoundedLT J]
    (F : Set X →o Set X) (hinfl : ∀ U, U ⊆ F U)
    (hcard : Cardinal.mk (Set X) < Cardinal.mk J) :
    ∃ j : J,
      F (transfiniteIterate F j (⊥ : Set X)) =
        transfiniteIterate F j (⊥ : Set X) ∧
      ∀ k ≥ j,
        transfiniteIterate F k (⊥ : Set X) =
          transfiniteIterate F j (⊥ : Set X) := by
  obtain ⟨j, hfix⟩ := transfiniteIterate_exists_fixed_of_card_lt F hinfl hcard
  exact ⟨j, hfix, transfiniteIterate_eventually_constant_of_fixed F hinfl hfix⟩

/- ================================================================
   theorem:bk4_freedom_life_connection   ================================================================ -/

/-- The discrete analogue of theorem:bk4_freedom_life_connection's
derivative condition `dF_free/dt > 0` together with its bounded-fragmentation
clause: a freedom-measure sequence that increases by a fixed positive amount
at every step, alongside a (static) fragmentation bound below the maximum
tolerated value. Only the increase law is used below; the fragmentation
bound is retained as the honest record of the theorem's second clause. -/
structure FreedomLifeTransition where
  Ffree : Nat → Real
  deltaF : Real
  deltaF_pos : 0 < deltaF
  increasing : ∀ k, Ffree (k + 1) ≥ Ffree k + deltaF
  Ffrag : Real
  epsMax : Real
  Ffrag_bounded : Ffrag < epsMax

theorem freedomLife_succ_lt (t : FreedomLifeTransition) (k : Nat) :
    t.Ffree k < t.Ffree (k + 1) := by
  have h := t.increasing k
  linarith [t.deltaF_pos]

/-- The freedom-measure sequence of a freedom-life transition is strictly
increasing at every step, hence (by `strictMono_nat_of_lt_succ`) strictly
monotone overall. -/
theorem freedomLife_strictMono (t : FreedomLifeTransition) : StrictMono t.Ffree :=
  strictMono_nat_of_lt_succ (freedomLife_succ_lt t)

/-- Telescoped increase bound, mirroring the repair-sufficiency accumulation
bound above but for a strictly increasing quantity. -/
theorem freedomLife_increase_accum (t : FreedomLifeTransition) (n : Nat) :
    t.Ffree n ≥ t.Ffree 0 + (n : Real) * t.deltaF := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep := t.increasing k
      have hcast : ((k + 1 : Nat) : Real) * t.deltaF = (k : Real) * t.deltaF + t.deltaF := by
        push_cast; ring
      rw [hcast]
      linarith

/- ================================================================
   theorem:bk4_fuzzy_chain_rule, theorem:bk4_fuzzy_sum_rule,
   theorem:bk4_fuzzy_product_rule, theorem:bk4_fuzzy_quotient_rule,
   theorem:bk4_fuzzy_power_rule,
   theorem:bk4_existence_observer_valid_derivatives,
   proposition:bk4_fuzzy_deriv_algebra
   ================================================================ -/

/-- The shared error-scaling schema running through the Fuzzy Chain and Sum
Rule theorems (and the linear-in-`ε` consequence bounds of "Existence of
Observer-Valid Derivatives"): an error bound of the form `ε * A * B`, for
nonnegative norm factors `A, B`, is nondecreasing as the observer's
resolution threshold `ε` grows. -/
theorem boundedErrorTerm_mono_linear {normA normB : Real} (hA : 0 ≤ normA) (hB : 0 ≤ normB)
    {eps1 eps2 : Real} (heps : eps1 ≤ eps2) :
    eps1 * normA * normB ≤ eps2 * normA * normB := by
  have h1 : eps1 * normA ≤ eps2 * normA := mul_le_mul_of_nonneg_right heps hA
  exact mul_le_mul_of_nonneg_right h1 hB

/-- The shared error-scaling schema running through the Fuzzy Product,
Quotient, and Power Rule theorems: an error bound of the form `ε² * A * B`,
for nonnegative norm factors `A, B` and nonnegative `ε`, is likewise
nondecreasing in `ε`. -/
theorem boundedErrorTerm_mono_quadratic {normA normB : Real} (hA : 0 ≤ normA) (hB : 0 ≤ normB)
    {eps1 eps2 : Real} (heps1 : 0 ≤ eps1) (heps : eps1 ≤ eps2) :
    eps1 ^ 2 * normA * normB ≤ eps2 ^ 2 * normA * normB := by
  have hsq : eps1 ^ 2 ≤ eps2 ^ 2 := by nlinarith
  have h1 : eps1 ^ 2 * normA ≤ eps2 ^ 2 * normA := mul_le_mul_of_nonneg_right hsq hA
  exact mul_le_mul_of_nonneg_right h1 hB

/-- The Fuzzy Quotient Rule's Observer Resolution Floor,
`ξ_O = ε² (1 + ‖L_g‖² / D)` for positive denominator `D`, is always at least
`ε²`: the honest algebraic content of the floor being a *regularizing*
correction rather than a diminishing one. -/
theorem quotientFloor_ge_eps_sq {eps normLg denomPos : Real} (hdenom : 0 < denomPos) :
    eps ^ 2 ≤ eps ^ 2 * (1 + normLg ^ 2 / denomPos) := by
  have h1 : 0 ≤ normLg ^ 2 / denomPos := div_nonneg (sq_nonneg normLg) hdenom.le
  have h2 : 0 ≤ eps ^ 2 * (normLg ^ 2 / denomPos) := mul_nonneg (sq_nonneg eps) h1
  have h3 : eps ^ 2 * (1 + normLg ^ 2 / denomPos) = eps ^ 2 + eps ^ 2 * (normLg ^ 2 / denomPos) := by
    ring
  linarith

/- ================================================================
   definition:bk4_fuzzy_gradient, lemma:bk4_gradient_stability
   ================================================================ -/

/-- The Fuzzy Gradient Operator's partial-derivative bound `M_f / ε_O`
(definition:bk4_fuzzy_gradient) moves the opposite way from the error-scaling
laws above: for a fixed positive symbolic bound `M_f`, it is strictly
*decreasing* as the observer's resolution threshold grows -- finer-grained
observation (smaller `ε`) forces a looser bound on the partial derivatives,
not a tighter one. -/
theorem fuzzyGradient_bound_antitone {Mf : Real} (hMf : 0 < Mf) {eps1 eps2 : Real}
    (h1 : 0 < eps1) (h2 : eps1 < eps2) :
    Mf / eps2 < Mf / eps1 :=
  div_lt_div_of_pos_left hMf h1 h2

/-- The bound structure underlying lemma:bk4_gradient_stability:
`‖∇_O1 f - ∇_O2 f‖ ≤ L_f |ε1 - ε2| + (\text{quadratic correction})`, kept as
a structure with the nonnegativity hypotheses the bound needs. -/
structure GradientStabilityBound where
  Lf : Real
  eps1 : Real
  eps2 : Real
  quadTerm : Real
  gradDiff : Real
  Lf_nonneg : 0 ≤ Lf
  quadTerm_nonneg : 0 ≤ quadTerm
  gradDiff_nonneg : 0 ≤ gradDiff
  bound : gradDiff ≤ Lf * |eps1 - eps2| + quadTerm

/-- When two observers share the same resolution threshold, the gradient
discrepancy is bounded by the quadratic correction term alone -- the honest
corollary of gradient stability once the Lipschitz term vanishes. -/
theorem gradientStability_same_resolution (g : GradientStabilityBound)
    (heq : g.eps1 = g.eps2) : g.gradDiff ≤ g.quadTerm := by
  have h := g.bound
  rw [heq, sub_self, abs_zero, mul_zero, zero_add] at h
  exact h

end ForcingAnalysis.Book4B
