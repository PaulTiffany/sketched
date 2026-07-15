/-
ScholiumC.lean - Principia Scholium Symbolicum, unmapped remainder (first
half), honest kernel.

This slice covers the Book I cluster on the category of structures, the
proto-symbolic colimit, observer horizons/signatures, the constitutive
bootstrap, the symbolic manifold/drift/connection/curvature apparatus, and
the linear-vs-quadratic coupling necessity argument. Most anchors are
stated over an ordinal-indexed diagram in a cocomplete category (`catS`),
a Riemannian symbolic manifold `(M, g)` with Levi-Civita connection and
Riemann curvature tensor, parallel transport and holonomy, or Hilbert-space
unitary evolution with tensor-product entanglement. This module does NOT
attempt ordinal-indexed colimit, curvature-tensor, parallel-transport, or
Hilbert-space formalizations. For each anchor it extracts the honest
static/algebraic/finite kernel instead, or (per the FracturedAtlas license)
re-reads chart-comparison content over a certified chart complex:

  * "the colimit `P := lim P_λ` satisfies the universal property of
    colimits in `catS`" (proto-symbolic space + its universality lemma)
    becomes the honest Type-level kernel of a categorical colimit: for any
    relation-respecting family into a target, the quotient by that relation
    (via `Quot`) carries a unique induced map -- exactly what "colimits in
    `Type` are quotients of coproducts" means algebraically, stripped of the
    ordinal-indexed diagram and its transition maps;
  * "observer-relative bounded approximation of the identity" becomes an
    existence witness: any operator killing the zero vector admits `id`
    itself as an `ε`-bounded approximation for any nonnegative bound
    `ε` -- an honesty gap against the source's "non-trivial" qualifier,
    noted rather than hidden, exactly as `id` is the trivial case excluded
    by that qualifier;
  * "the effective horizon signature `Σ_O(U) ⊆ {+,-}`" becomes a genuine
    two-valued indicator set with proved full/empty extremes;
  * "the stabilized image of `R_stab` lies in `Fix(R_stab)`" (used inside
    the constitutive bootstrap's proof) becomes the general fact that an
    idempotent map's range is exactly its fixed-point set;
  * "the symbolic coherence velocity is the supremum ... provides a
    fundamental limit on symbolic propagation speed" becomes the general
    least-upper-bound property of `sSup` on a bounded-above set of reals;
  * "the symbolic manifold `(M,g)`" (per the FracturedAtlas license) becomes
    existence *and* uniqueness of "the" chart-consistent metric over a
    glued, pair-covering chart complex -- the honest cash-value of the
    definite article "the metric tensor `g`";
  * "the minimal local representation capable of carrying contextual
    emergence contains a bilinear, hence quadratic, coupling term"
    (quadratic structure necessity) and its converse ("purely linear
    dynamics preclude the contextual coupling", linear insufficiency)
    become one connected pair: a discrete cross-difference operator on the
    residual update that is nonzero at some point iff it is nonzero as a
    function, and that vanishes identically whenever the update is
    additively separable in state and context -- the finite-difference
    surrogate for the source's mixed second *derivative*, not a
    formalization of the derivative itself;
  * "the dual horizon necessity theorem"'s binding/coupled case, together
    with the "binding special case" clause of bounded reflexive emergence,
    the horizon characterization's stabilization-flux clause, and the
    horizon duality principle, all cash out to the same scalar fact: a
    product of two nonnegative fluxes exceeding a positive threshold forces
    both fluxes strictly positive;
  * "the Newtonian Category Error"'s access function `α` with
    `α(O) ⊊ O` becomes the general fact that a non-surjective self-map
    always misses some point of its domain -- the honest kernel of
    "some state is inaccessible to the observer".

Anchors that are purely categorical/narrative (the category of structures
itself, the observer gradient, observable gradation, the operators-as-
bounded-approximations proposition depending on an undefined notion,
pre-geometric nature, symbolic primacy, emergence events, the dual horizon
postulate, semantic non-integrability as a bare premise, the symbolic
category/reflexive-update-map/linear-reflexive-map cluster, feature maps,
horizon structures, the metric/coupling-matrix identification, Newtonian
incompleteness's ill-typed accessibility clause, the quantum category error
and symbolic-quantum incompatibility, the thermodynamics/necessity theorem
mixing curvature with dimension growth, symbolic primacy, and the SRMF /
SRMF-energy pair requiring vector-calculus and Dirichlet-energy integrals),
that require genuine Riemannian curvature, connection, or parallel-transport
machinery (the drift field, observer horizon structure, symbolic hypothesis,
the contradiction resolution principle, the symbolic connection and Riemann
tensor themselves, local semantic independence, curvature-as-holonomy,
curvature-and-semantic-entanglement, the curvature-projection-residue
corollary, resolution cost, symbolic-emergence-and-curvature, and the
dimensional-bounds-on-emergence and non-Euclidean-necessity corollaries),
are left unformalized and listed as open anchors in the accompanying
proposal, rather than forced into decorative theorems.
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas

namespace ForcingAnalysis.ScholiumC

/- ================================================================
   definition:bk1_proto_symbolic_space, lemma:bk1_universality_of_proto_symbolic_space,
   definition:bk1_directed_system_of_emergence
   ================================================================ -/

/-- The honest Type-level kernel of "the colimit `P` satisfies the
universal property of colimits in `catS`" (lemma:bk1_universality_of_proto_symbolic_space,
definition:bk1_proto_symbolic_space): given any relation `r` on the stage
carrier `ι` (the honest stand-in for the directed system's compatibility
relation, definition:bk1_directed_system_of_emergence, stripped of its
ordinal indexing and transition maps) and any family `g` into a target `Q`
that respects `r`, there is a *unique* map out of the quotient `Quot r`
agreeing with `g` on every stage -- exactly the mediating morphism the
source's universal property demands, and exactly what "colimits in `Type`
are quotients" means algebraically. -/
theorem colimit_universal_property {ι Q : Type*} (r : ι → ι → Prop) (g : ι → Q)
    (hg : ∀ i j, r i j → g i = g j) :
    ∃! h : Quot r → Q, ∀ i, h (Quot.mk r i) = g i := by
  refine ⟨Quot.lift g hg, fun i => rfl, ?_⟩
  intro h' hh'
  funext q
  induction q using Quot.ind with
  | _ i => rw [hh' i]

/-- A concrete directed tower of emergent stages. Unlike the quotient-only
kernel above, this records the transition maps and their identity and
composition laws explicitly. -/
structure DirectedStageSystem where
  carrier : ℕ → Type*
  transition : ∀ {m n}, m ≤ n → carrier m → carrier n
  transition_id : ∀ n (x : carrier n), transition (le_refl n) x = x
  transition_comp : ∀ {l m n} (hlm : l ≤ m) (hmn : m ≤ n) (x : carrier l),
    transition (hlm.trans hmn) x = transition hmn (transition hlm x)

namespace DirectedStageSystem

abbrev Point (D : DirectedStageSystem) := Σ n, D.carrier n

def Compatible (D : DirectedStageSystem) (x y : D.Point) : Prop :=
  ∃ k, ∃ hx : x.1 ≤ k, ∃ hy : y.1 ≤ k,
    D.transition hx x.2 = D.transition hy y.2

abbrev Colimit (D : DirectedStageSystem) := Quot D.Compatible

def injection (D : DirectedStageSystem) (n : ℕ) : D.carrier n → D.Colimit :=
  fun x => Quot.mk D.Compatible ⟨n, x⟩

theorem injection_transition (D : DirectedStageSystem) {m n : ℕ} (hmn : m ≤ n)
    (x : D.carrier m) : D.injection n (D.transition hmn x) = D.injection m x := by
  apply Quot.sound
  refine ⟨n, le_rfl, hmn, ?_⟩
  rw [D.transition_id]

structure Cocone (D : DirectedStageSystem) (Q : Type*) where
  leg : ∀ n, D.carrier n → Q
  naturality : ∀ {m n} (hmn : m ≤ n) (x : D.carrier m),
    leg n (D.transition hmn x) = leg m x

def Cocone.desc {D : DirectedStageSystem} {Q : Type*} (C : D.Cocone Q) :
    D.Colimit → Q :=
  Quot.lift (fun x => C.leg x.1 x.2) (by
    intro x y hxy
    rcases hxy with ⟨k, hx, hy, hEq⟩
    rw [← C.naturality hx x.2, ← C.naturality hy y.2, hEq])

theorem Cocone.desc_injection {D : DirectedStageSystem} {Q : Type*}
    (C : D.Cocone Q) (n : ℕ) (x : D.carrier n) :
    C.desc (D.injection n x) = C.leg n x := rfl

theorem directed_colimit_universal_property {D : DirectedStageSystem} {Q : Type*}
    (C : D.Cocone Q) :
    ∃! h : D.Colimit → Q, ∀ n x, h (D.injection n x) = C.leg n x := by
  refine ⟨C.desc, C.desc_injection, ?_⟩
  intro h hh
  funext q
  induction q using Quot.ind with
  | _ x => exact hh x.1 x.2

end DirectedStageSystem

/- ================================================================
   proposition:bk1_observer_relative_bounded_approximation
   ================================================================ -/

/-- The existence claim of proposition:bk1_observer_relative_bounded_approximation:
any operator `K` killing the zero vector admits a bounded approximation
`Φ` of the identity for any nonnegative pointwise bound `ε`. Taking
`Φ = id` witnesses it, since `K (Φ s - s) = K 0 = 0`. This is the trivial
case the source explicitly excludes with its "non-trivial" qualifier
(dropped here, an honesty gap noted rather than hidden): the identity map
is exactly the approximation the proposition asks to be nontrivial. -/
theorem exists_bounded_approx {V : Type*} [NormedAddCommGroup V] (K : V → V)
    (hK0 : K 0 = 0) (eps : V → ℝ) (heps : ∀ s, 0 ≤ eps s) :
    ∃ Φ : V → V, ∀ s : V, ‖K (Φ s - s)‖ ≤ eps s := by
  refine ⟨id, fun s => ?_⟩
  have hz : (id s - s : V) = 0 := by simp
  rw [hz, hK0, norm_zero]
  exact heps s

/- ================================================================
   definition:bk1_effective_horizon_signature
   ================================================================ -/

/-- The effective horizon signature (definition:bk1_effective_horizon_signature),
modeled directly on a single generative/dissipative curvature-flux pair
`(G, C)` (the "binding" reading of the definition, dropping the
existential quantification over multiple horizon components): `true`
(the `+` sign) is present iff the generative flux is positive, `false`
(the `-` sign) is present iff the dissipative flux is positive. -/
def EffectiveSignature (G C : ℝ) : Set Bool
  | true => 0 < G
  | false => 0 < C

/-- Both signs are present exactly when both fluxes are positive: the
signature is the full two-element set. -/
theorem effectiveSignature_full {G C : ℝ} (hG : 0 < G) (hC : 0 < C) :
    EffectiveSignature G C = Set.univ := by
  ext b
  cases b
  · show (0 < C) ↔ True
    exact iff_of_true hC trivial
  · show (0 < G) ↔ True
    exact iff_of_true hG trivial

/-- Neither sign is present when both fluxes vanish or are negative: the
signature is empty. -/
theorem effectiveSignature_empty {G C : ℝ} (hG : G ≤ 0) (hC : C ≤ 0) :
    EffectiveSignature G C = ∅ := by
  ext b
  cases b
  · show (0 < C) ↔ False
    exact iff_of_false (not_lt.mpr hC) not_false
  · show (0 < G) ↔ False
    exact iff_of_false (not_lt.mpr hG) not_false

/- ================================================================
   theorem:bk1_dual_horizon_necessity_theorem, definition:bk1_bounded_reflexive_emergence,
   lemma:bk1_horizon_characterization, corollary:bk1_horizon_duality_principle
   ================================================================ -/

/-- The "binding, coupled case" data shared by theorem:bk1_dual_horizon_necessity_theorem's
converse, the product-flux clause of definition:bk1_bounded_reflexive_emergence
(`ΔΦ_O = G_O(H_G) C_O(H_D)` in the binding special case), the
stabilization-flux clause of lemma:bk1_horizon_characterization, and
corollary:bk1_horizon_duality_principle's "opposing horizon principles":
two nonnegative curvature fluxes whose product meets a positive
emergence threshold. -/
structure DualHorizonBinding where
  G : ℝ
  C : ℝ
  tau : ℝ
  G_nonneg : 0 ≤ G
  C_nonneg : 0 ≤ C
  tau_pos : 0 < tau
  binding : tau ≤ G * C

/-- **The binding case forces both horizons strictly present**: a product
of nonnegative fluxes meeting a positive threshold forces each flux
strictly positive -- `Σ_O(U) = {+,-}` with `G_O(H_G) > 0` and
`C_O(H_D) > 0`, the conclusion shared across all four anchors above. -/
theorem dualHorizonBinding_both_pos (d : DualHorizonBinding) : 0 < d.G ∧ 0 < d.C := by
  have hGC : 0 < d.G * d.C := lt_of_lt_of_le d.tau_pos d.binding
  have hG0 : d.G ≠ 0 := by
    intro h
    rw [h, zero_mul] at hGC
    exact lt_irrefl 0 hGC
  have hC0 : d.C ≠ 0 := by
    intro h
    rw [h, mul_zero] at hGC
    exact lt_irrefl 0 hGC
  exact ⟨lt_of_le_of_ne d.G_nonneg (Ne.symm hG0), lt_of_le_of_ne d.C_nonneg (Ne.symm hC0)⟩

/- ================================================================
   theorem:bk1_constitutive_bootstrap
   ================================================================ -/

/-- The fixed-point sublemma consumed by theorem:bk1_constitutive_bootstrap's
proof ("the stabilized image of `R_stab` lies in `Fix(R_stab)`"): for any
idempotent stabilization map `R`, its range is *exactly* its fixed-point
set, not merely contained in it. The maximal self-reflective substructure
and the observer-extraction triple built on top of this fact are not
modeled. -/
theorem idempotent_image_eq_fixedPoints {X : Type*} (R : X → X)
    (hR : ∀ x, R (R x) = R x) : Set.range R = {x | R x = x} := by
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    exact hR y
  · intro hx
    exact ⟨x, hx⟩

/- ================================================================
   definition:bk1_symbolic_manifold
   ================================================================ -/

/-- The FracturedAtlas reading of definition:bk1_symbolic_manifold: "the"
metric tensor `g` of the symbolic manifold, when it exists, is *unique* --
any two chart-consistent global metrics on a pair-covering chart complex
must agree everywhere, since every pair of points is forced to the same
value by some shared chart. This is the honest cash-value of the definite
article "the" in "equipped with a Riemannian metric tensor `g`": existence
is `ForcingAnalysis.Atlas.consistent_of_glued`; this is its uniqueness
partner. -/
theorem consistent_unique {X : Type*} {C : ForcingAnalysis.Atlas.ChartComplex X}
    (hCov : ForcingAnalysis.Atlas.PairCovers C) {D₁ D₂ : X → X → ℝ}
    (h₁ : ForcingAnalysis.Atlas.Consistent C D₁)
    (h₂ : ForcingAnalysis.Atlas.Consistent C D₂) : D₁ = D₂ := by
  funext x y
  obtain ⟨i, hx, hy⟩ := hCov x y
  rw [h₁ i x hx y hy, h₂ i x hx y hy]

/- ================================================================
   theorem:bk1_quadratic_structure_necessity, corollary:bk1_linear_insufficiency
   ================================================================ -/

/-- The discrete cross-difference of a residual update `U`, the honest
finite-difference surrogate for the mixed second *derivative*
`D_ξD_χ U(0,0)` of theorem:bk1_quadratic_structure_necessity -- not a
formalization of the derivative itself. -/
def crossTerm {V Ctx W : Type*} [AddCommGroup V] [AddCommGroup Ctx] [AddCommGroup W]
    (U : V → Ctx → W) (ξ : V) (χ : Ctx) : W :=
  U ξ χ - U ξ 0 - U 0 χ + U 0 0

/-- **Quadratic structure necessity, the honest kernel**: the residual
update is "contextual at the origin" (some instance of the cross-difference
is nonzero) exactly when the cross-difference *is* a nonzero function --
so nonseparability is exactly the existence of a nonzero bilinear-shaped
coupling term `crossTerm U`, matching "the minimal local representation
... contains a bilinear, hence quadratic, coupling term". -/
theorem crossTerm_ne_zero_exists {V Ctx W : Type*} [AddCommGroup V] [AddCommGroup Ctx]
    [AddCommGroup W] (U : V → Ctx → W) :
    (∃ ξ χ, crossTerm U ξ χ ≠ 0) ↔ crossTerm U ≠ fun _ _ => (0 : W) := by
  constructor
  · rintro ⟨ξ, χ, hne⟩ heq
    exact hne (by simp [heq])
  · intro hne
    by_contra h
    apply hne
    funext ξ χ
    by_contra hζ
    exact h ⟨ξ, χ, hζ⟩

/-- **Linear insufficiency, the honest kernel**: an additively separable
update (the honest reading of "purely linear dynamics reduce to superposed
independent modes") has *identically zero* cross-difference -- separable
updates can never supply the nonzero coupling term of `crossTerm_ne_zero_exists`,
matching "linear symbolic systems cannot support genuine emergence". -/
theorem crossTerm_separable_eq_zero {V Ctx W : Type*} [AddCommGroup V] [AddCommGroup Ctx]
    [AddCommGroup W] (f : V → W) (g : Ctx → W) (ξ : V) (χ : Ctx) :
    crossTerm (fun ξ' χ' => f ξ' + g χ') ξ χ = 0 := by
  dsimp only [crossTerm]
  abel

/- ================================================================
   definition:bk1_symbolic_coherence_velocity
   ================================================================ -/

/-- The symbolic coherence velocity (definition:bk1_symbolic_coherence_velocity)
as the supremum of a set of coherence-gradient magnitudes; the coherence
field space `M_coh` and the local gradient construction are not modeled,
only the resulting real number. -/
noncomputable def coherenceVelocity (S : Set ℝ) : ℝ := sSup S

/-- **The fundamental speed limit**: every element of a bounded-above
coherence-gradient set is dominated by the coherence velocity -- the
honest content of "this value ... provides a fundamental limit on symbolic
propagation speed". -/
theorem le_coherenceVelocity {S : Set ℝ} (hbdd : BddAbove S) {x : ℝ} (hx : x ∈ S) :
    x ≤ coherenceVelocity S :=
  le_csSup hbdd hx

/- ================================================================
   definition:bk1_newtonian_category_error
   ================================================================ -/

/-- The honest kernel of definition:bk1_newtonian_category_error's access
clause "`α(O) ⊊ O`": a non-surjective access function always misses some
state -- the direct set-theoretic content of "bounded observer logic",
independent of the manifold-smoothness framing the source wraps around it. -/
theorem exists_inaccessible_of_not_surjective {X : Type*} (α : X → X)
    (h : ¬ Function.Surjective α) : ∃ x : X, x ∉ Set.range α := by
  simp only [Function.Surjective, not_forall] at h
  obtain ⟨b, hb⟩ := h
  refine ⟨b, ?_⟩
  rintro ⟨a, ha⟩
  exact hb ⟨a, ha⟩

end ForcingAnalysis.ScholiumC
