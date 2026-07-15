/-
Book4D.lean - Principia Book 4, unmapped remainder (second half): SRMF cycles,
integrative expansion, chart-convergence material, honest kernel.

This slice of Book IV is dominated by three families: (1) an "individuated
symbolic identity / autonomy / self-authorship" cluster stated over wholly
unconstrained abstract types (action spaces, goal spaces, decision operators
with no further axioms), (2) a long observer-relative differential-geometry
development (fuzzy substitution, O-differentiability, chart convergence,
covariant derivatives, Stokes/divergence/curl/Helmholtz identities, gauge and
holographic "dictionaries"), and (3) physics/ML/category-theory *readings* of
the observer-induced metric (quantum measurement, statistical mechanics,
metric learning, holographic entanglement, categorical equivalence) that add
interpretive gloss without new formal content. This module extracts the
honest kernel from families (1)-(2) and skips (3) outright:

  * "fuzzy symbolic substitution" / "tilda-substitution" / the "validity of
    tilda-substitution" commutator bound all reduce to the SAME scalar law:
    a nonnegative discrepancy bounded strictly by an observer resolution
    threshold, whence the threshold is positive; composing two such bounded
    substitutions bounds the composite by the sum of thresholds;
  * "O-differentiability" (stated twice, as a linear bound and as a ratio
    bound) becomes one `ODifferentiableAt` predicate on `Real → Real`, with
    the two source phrasings proved *equivalent* (dividing/multiplying a
    strict inequality by a positive `t` is order-preserving), plus concrete
    witnesses (the identity and constant maps satisfy it for every
    threshold) and a monotonicity theorem in the resolution threshold --
    the honest kernel of "the perceived differentiable structure depends on
    the observer's resolution" and of the classical case being the strictest
    (smallest-threshold) instance;
  * "convergence of symbolic drift" drops the transfinite/ordinal indexing
    (not modeled) and keeps its honest discrete/countable kernel: a
    nonnegative real sequence contracting geometrically at a fixed rate
    `r < 1` tends to `0` -- proved via `tendsto_pow_atTop_nhds_zero_of_abs_lt_one`
    and a squeeze;
  * the "observer-induced metric" and its positivity/symmetry properties
    become the corresponding real-number facts about the bilinear pairing
    `(v, w) ↦ K v * K w` (the honest 1-dimensional kernel of `⟨Kv, Kw⟩_g`);
    coordinate rescaling is modeled by the pullback kernel `K_a(x)=K(x/a)`,
    and the metric is proved exactly invariant on correspondingly rescaled
    vectors for every nonzero scale;
  * "chart convergence yields an observer-relative differentiable structure"
    (stated twice, as the Fuzzy Symbolic Geometry Theorem and its restated
    form) is re-read over `ForcingAnalysis.FracturedAtlas`'s `ChartComplex`,
    exactly per the license: `Glued` is consumed as a named hypothesis
    exactly where the source's proof consumes chart compatibility, giving a
    single consistent geometry;
  * "smoothness as an epistemic phenomenon" (different observers may
    perceive different differentiable structures on the same underlying
    system) becomes the dual-horizon fracture instance already proved in
    `FracturedAtlas`: the SAME underlying carrier, two charts, no single
    reconciling geometry;
  * the "Chain Rule for Fuzzy Compositions" bound is kept as a structure
    field (the stated Frobenius-norm inequality), from which the honest
    consequence is drawn: at the unbounded-observer idealization
    (`epsO = 0`) the coupling tensor is forced to vanish, i.e. the composite
    fuzzy Jacobian collapses to the exact classical chain rule -- the same
    limiting-classical-geometry content claimed narratively elsewhere;
  * the large family of "observer rule = classical rule + observer
    correction term" identities (fuzzy exponential/logarithmic/Jacobian
    rules, fuzzy divergence/vector-field/integral-operator/covariant
    derivative, the Fuzzy Fundamental Theorem of Calculus, Symbolic Stokes,
    the Fuzzy Divergence/Curl Theorems, and the Fuzzy Helmholtz
    Decomposition) all share ONE honest algebraic kernel, extending Book
    VIII's `frameResidual` pattern to an arbitrary additive group: a
    defining equation `observerValue = classicalValue + correction` makes
    "the correction vanishes" and "the observer rule collapses to the
    classical rule" logically equivalent. This is proved once, generically,
    and instantiated (in the accompanying proposal, not by repeated
    boilerplate here) at each of those anchors' own three quantities.

Left open: the individuated-identity/autonomy/self-authorship/proto-vitality
cluster (unconstrained abstract types, no computable law); the substituted
drift field's own defining formula (no independent property beyond what
O-differentiability already covers); every physics/ML/holography *reading*
of the observer-induced metric (quantum measurement, field-theory
regularization, statistical mechanics, metric learning, information
curvature, holographic emergence) -- interpretive gloss, not new formal
content; the existential-neighborhood lemmas on local differentiability and
observer-relative smoothness (unspecified filtration structure); drift-
reflection compatibility, the epistemic differential operator, the fuzzy
affine connection and the geodesic-failure curvature built on it (genuine
differential geometry beyond a chart complex's pseudometric), categorical
equivalence of observer-relative structures and the classical-geometry limit
of that equivalence (category theory, no concrete content); the
multiplicative-error-to-curvature theorem (a curvature 2-form on the
symbolic tangent bundle); the observer/geometry co-evolution ODE system; the
symbolic-space, induced-area-element, gauge dictionary, Wilson-loop, and
symbolic quantum-geometry anchors (bundles of unconstrained components, pure
naming correspondences, or path-ordered functional integrals -- no
independent equation to formalize).
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas
import ForcingAnalysis.Book4A
import ForcingAnalysis.Book4C
import ForcingAnalysis.ScholiumDynamics
import ForcingAnalysis.ScholiumC
import ForcingAnalysis.AtlasHolonomy

namespace ForcingAnalysis.Book4D

open ForcingAnalysis.Atlas

/- ================================================================
   definition:bk4_fuzzy_symbolic_substitution, definition:bk4_tilda_substitution,
   corollary:bk4_validity_of_tilda_substit
   ================================================================ -/

/-- The common scalar law underlying the fuzzy symbolic substitution
(definition:bk4_fuzzy_symbolic_substitution), the tilda-substitution
(definition:bk4_tilda_substitution), and the tilda-substitution validity
commutator bound (corollary:bk4_validity_of_tilda_substit): a nonnegative
discrepancy `diff` (the observer-differenced displacement, or the
differentiation-commutator norm) is bounded strictly by an observer
resolution threshold `eps`. Only this scalar bound is modeled; the map `u`
itself, the observer's differencing family `δ^n_O`, and the symbolic
tangent-space structure are not. -/
structure FuzzySubstitutionBound where
  diff : Real
  diff_nonneg : 0 ≤ diff
  eps : Real
  diff_lt_eps : diff < eps

/-- A discrepancy strictly below a nonnegative threshold forces the
threshold to be positive. -/
theorem fuzzySubstitutionBound_eps_pos (b : FuzzySubstitutionBound) : 0 < b.eps :=
  lt_of_le_of_lt b.diff_nonneg b.diff_lt_eps

/-- Composing two observer-bounded substitutions (e.g. an inner and an outer
tilda-substitution) bounds the combined discrepancy by the sum of the
individual resolution thresholds -- the honest triangle-inequality content
of "calculations performed in the fuzzy manifold are consistent with the
underlying symbolic space up to the observer's resolution threshold" under
composition. -/
theorem fuzzySubstitutionBound_compose (b1 b2 : FuzzySubstitutionBound) :
    b1.diff + b2.diff < b1.eps + b2.eps :=
  add_lt_add b1.diff_lt_eps b2.diff_lt_eps

/- ================================================================
   definition:bk4_observer_differentiable_, definition:bk4_observer_valid_different
   ================================================================ -/

/-- `O`-differentiability of a real-valued map at a point `p`, specialized
to a single scalar direction (the symbolic tangent space `T_p M` is not
modeled): there is a slope `L` and a window `(0, T)` on which the linear
approximation error stays strictly below `t` times the observer's
resolution threshold `eps`. This is the shared honest kernel of both
definition:bk4_observer_differentiable_ (the linear-bound phrasing) and
definition:bk4_observer_valid_different (the ratio/limit phrasing); the
equivalence of the two phrasings is proved below. -/
def ODifferentiableAt (f : Real → Real) (p L eps : Real) : Prop :=
  0 < eps ∧ ∃ T > 0, ∀ t : Real, 0 < t → t < T → |f (p + t) - f p - t * L| < t * eps

/-- definition:bk4_observer_valid_different states the same bound as a
ratio tending below the threshold rather than as a linear inequality;
dividing (resp. multiplying) a strict inequality by `t > 0` is
order-preserving, so the two phrasings agree exactly. -/
theorem odifferentiableAt_iff_ratio_form (f : Real → Real) (p L eps : Real) (heps : 0 < eps) :
    ODifferentiableAt f p L eps ↔
      ∃ T > 0, ∀ t : Real, 0 < t → t < T →
        |f (p + t) - f p - t * L| / t < eps := by
  unfold ODifferentiableAt
  constructor
  · rintro ⟨_, T, hT, hbound⟩
    refine ⟨T, hT, fun t ht htT => ?_⟩
    have h' : |f (p + t) - f p - t * L| < eps * t := by
      rw [mul_comm eps t]; exact hbound t ht htT
    exact (div_lt_iff₀ ht).mpr h'
  · rintro ⟨T, hT, hbound⟩
    refine ⟨heps, T, hT, fun t ht htT => ?_⟩
    have h' := (div_lt_iff₀ ht).mp (hbound t ht htT)
    rwa [mul_comm eps t] at h'

/-- The identity map is `O`-differentiable at every point, with slope `1`,
for every resolution threshold: a concrete witness that the definition is
non-vacuous. -/
theorem identity_odifferentiableAt (p eps : Real) (heps : 0 < eps) :
    ODifferentiableAt (fun x => x) p 1 eps := by
  refine ⟨heps, 1, one_pos, fun t ht _ => ?_⟩
  have heq : (p + t) - p - t * 1 = 0 := by ring
  rw [heq, abs_zero]
  exact mul_pos ht heps

/-- A constant map is `O`-differentiable at every point, with slope `0`,
for every resolution threshold. -/
theorem const_odifferentiableAt (c p eps : Real) (heps : 0 < eps) :
    ODifferentiableAt (fun _ => c) p 0 eps := by
  refine ⟨heps, 1, one_pos, fun t ht _ => ?_⟩
  have heq : c - c - t * 0 = 0 := by ring
  rw [heq, abs_zero]
  exact mul_pos ht heps

/-- Monotonicity of `O`-differentiability in the resolution threshold: a
coarser (larger `eps`) observer accepts everything a finer observer does.
This is the honest kernel of corollary:bk4_smoothness_as_epistemic_phenomenon's
claim that the perceived differentiable structure depends on the observer's
resolution threshold, and that the classical (`eps → 0`) case is the
strictest instance rather than a distinguished ontological one. -/
theorem odifferentiableAt_mono_eps {f : Real → Real} {p L eps eps' : Real}
    (h : ODifferentiableAt f p L eps) (hle : eps ≤ eps') :
    ODifferentiableAt f p L eps' := by
  obtain ⟨heps, T, hT, hbound⟩ := h
  refine ⟨lt_of_lt_of_le heps hle, T, hT, fun t ht htT => ?_⟩
  have h1 := hbound t ht htT
  have h2 : t * eps ≤ t * eps' := mul_le_mul_of_nonneg_left hle (le_of_lt ht)
  exact lt_of_lt_of_le h1 h2
/- ================================================================
   Exact observer-corrected differential calculus
   ================================================================ -/

/-- An observer derivative is an actual derivative decomposed into a
classical slope and an observer correction. The sum is certified by
Mathlib's derivative predicate rather than merely postulated. -/
structure ObserverDerivativeAt (f : ℝ → ℝ) (x : ℝ) where
  classicalSlope : ℝ
  correction : ℝ
  hasDerivAt : HasDerivAt f (classicalSlope + correction) x

namespace ObserverDerivativeAt

def actualSlope {f : ℝ → ℝ} {x : ℝ} (D : ObserverDerivativeAt f x) : ℝ :=
  D.classicalSlope + D.correction

theorem correction_eq_zero_iff_actual_eq_classical {f : ℝ → ℝ} {x : ℝ}
    (D : ObserverDerivativeAt f x) :
    D.correction = 0 ↔ D.actualSlope = D.classicalSlope := by
  simp [actualSlope]

def add {f g : ℝ → ℝ} {x : ℝ} (Df : ObserverDerivativeAt f x)
    (Dg : ObserverDerivativeAt g x) : ObserverDerivativeAt (fun y => f y + g y) x where
  classicalSlope := Df.classicalSlope + Dg.classicalSlope
  correction := Df.correction + Dg.correction
  hasDerivAt := by
    convert Df.hasDerivAt.add Dg.hasDerivAt using 1 <;> first | rfl | ring

def mul {f g : ℝ → ℝ} {x : ℝ} (Df : ObserverDerivativeAt f x)
    (Dg : ObserverDerivativeAt g x) : ObserverDerivativeAt (fun y => f y * g y) x where
  classicalSlope := Df.classicalSlope * g x + f x * Dg.classicalSlope
  correction := Df.correction * g x + f x * Dg.correction
  hasDerivAt := by
    convert Df.hasDerivAt.mul Dg.hasDerivAt using 1 <;> first | rfl | ring

/-- Chain corrections include the fuzzy cross term: outer correction times
inner correction. -/
def comp {f g : ℝ → ℝ} {x : ℝ} (Dg : ObserverDerivativeAt g (f x))
    (Df : ObserverDerivativeAt f x) : ObserverDerivativeAt (fun y => g (f y)) x where
  classicalSlope := Dg.classicalSlope * Df.classicalSlope
  correction := Dg.classicalSlope * Df.correction +
    Dg.correction * Df.classicalSlope + Dg.correction * Df.correction
  hasDerivAt := by
    convert Dg.hasDerivAt.comp x Df.hasDerivAt using 1 <;> first | rfl | ring

def pow {f : ℝ → ℝ} {x : ℝ} (Df : ObserverDerivativeAt f x) (n : ℕ) :
    ObserverDerivativeAt (fun y => f y ^ n) x where
  classicalSlope := (n : ℝ) * f x ^ (n - 1) * Df.classicalSlope
  correction := (n : ℝ) * f x ^ (n - 1) * Df.correction
  hasDerivAt := by
    convert Df.hasDerivAt.pow n using 1 <;> first | rfl | ring

noncomputable def div {f g : ℝ → ℝ} {x : ℝ} (Df : ObserverDerivativeAt f x)
    (Dg : ObserverDerivativeAt g x) (hg : g x ≠ 0) :
    ObserverDerivativeAt (fun y => f y / g y) x where
  classicalSlope :=
    (Df.classicalSlope * g x - f x * Dg.classicalSlope) / g x ^ 2
  correction :=
    (Df.correction * g x - f x * Dg.correction) / g x ^ 2
  hasDerivAt := by
    convert Df.hasDerivAt.div Dg.hasDerivAt hg using 1 <;> first | rfl | ring

/-- A classical derivative embeds with no observer correction. -/
def ofClassical {f : ℝ → ℝ} {x L : ℝ} (h : HasDerivAt f L x) :
    ObserverDerivativeAt f x where
  classicalSlope := L
  correction := 0
  hasDerivAt := by simpa using h

/-- The actual slope is intrinsic: two decompositions for the same function
at the same point cannot disagree about the derivative they certify. -/
theorem actualSlope_eq {f : ℝ → ℝ} {x : ℝ} (D E : ObserverDerivativeAt f x) :
    D.actualSlope = E.actualSlope := by
  exact D.hasDerivAt.unique E.hasDerivAt

/-- Once the reference classical slope is fixed, the correction is unique.
Thus the decomposition has no hidden correction-level ambiguity. -/
theorem correction_eq_of_classicalSlope_eq {f : ℝ → ℝ} {x : ℝ}
    (D E : ObserverDerivativeAt f x) (hclassical : D.classicalSlope = E.classicalSlope) :
    D.correction = E.correction := by
  have hactual := actualSlope_eq D E
  simp only [actualSlope] at hactual
  linarith

@[simp] theorem add_correction {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x) :
    (Df.add Dg).correction = Df.correction + Dg.correction := rfl

@[simp] theorem mul_correction {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x) :
    (Df.mul Dg).correction = Df.correction * g x + f x * Dg.correction := rfl

@[simp] theorem comp_correction {f g : ℝ → ℝ} {x : ℝ}
    (Dg : ObserverDerivativeAt g (f x)) (Df : ObserverDerivativeAt f x) :
    (Dg.comp Df).correction = Dg.classicalSlope * Df.correction +
      Dg.correction * Df.classicalSlope + Dg.correction * Df.correction := rfl

@[simp] theorem pow_correction {f : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (n : ℕ) :
    (Df.pow n).correction = (n : ℝ) * f x ^ (n - 1) * Df.correction := rfl

@[simp] theorem div_correction {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x) (hg : g x ≠ 0) :
    (Df.div Dg hg).correction =
      (Df.correction * g x - f x * Dg.correction) / g x ^ 2 := rfl

/-- Classical inputs remain classical under every algebraic rule. -/
theorem add_correction_eq_zero {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x)
    (hf : Df.correction = 0) (hg : Dg.correction = 0) :
    (Df.add Dg).correction = 0 := by simp [hf, hg]

theorem mul_correction_eq_zero {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x)
    (hf : Df.correction = 0) (hg : Dg.correction = 0) :
    (Df.mul Dg).correction = 0 := by simp [hf, hg]

theorem comp_correction_eq_zero {f g : ℝ → ℝ} {x : ℝ}
    (Dg : ObserverDerivativeAt g (f x)) (Df : ObserverDerivativeAt f x)
    (hg : Dg.correction = 0) (hf : Df.correction = 0) :
    (Dg.comp Df).correction = 0 := by simp [hg, hf]

theorem pow_correction_eq_zero {f : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (n : ℕ) (hf : Df.correction = 0) :
    (Df.pow n).correction = 0 := by simp [hf]

theorem div_correction_eq_zero {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x)
    (hdenom : g x ≠ 0) (hf : Df.correction = 0) (hg : Dg.correction = 0) :
    (Df.div Dg hdenom).correction = 0 := by simp [hf, hg]

/-- The exact sum correction satisfies the expected additive error budget. -/
theorem abs_add_correction_le {f g : ℝ → ℝ} {x : ℝ}
    (Df : ObserverDerivativeAt f x) (Dg : ObserverDerivativeAt g x) :
    |(Df.add Dg).correction| ≤ |Df.correction| + |Dg.correction| := by
  simpa using abs_add_le Df.correction Dg.correction

/-- The exact chain correction yields a concrete three-term error budget,
including the quadratic cross term absent from a purely linear envelope. -/
theorem abs_comp_correction_le {f g : ℝ → ℝ} {x : ℝ}
    (Dg : ObserverDerivativeAt g (f x)) (Df : ObserverDerivativeAt f x) :
    |(Dg.comp Df).correction| ≤
      |Dg.classicalSlope| * |Df.correction| +
      |Dg.correction| * |Df.classicalSlope| +
      |Dg.correction| * |Df.correction| := by
  rw [comp_correction]
  calc
    |Dg.classicalSlope * Df.correction + Dg.correction * Df.classicalSlope +
        Dg.correction * Df.correction| ≤
      |Dg.classicalSlope * Df.correction| +
        |Dg.correction * Df.classicalSlope| +
        |Dg.correction * Df.correction| := by
          exact (abs_add_le _ _).trans (add_le_add (abs_add_le _ _) (le_refl _))
    _ = _ := by simp [abs_mul]

/- ================================================================
   Operational perturbation control
   ================================================================ -/

/-- A derivative correction is operationally controlled at budget `ε` when
the budget is admissible and the correction magnitude fits inside it. -/
def CorrectionControlled {f : ℝ → ℝ} {x : ℝ} (D : ObserverDerivativeAt f x)
    (ε : ℝ) : Prop := 0 ≤ ε ∧ |D.correction| ≤ ε

theorem correctionControlled_mono {f : ℝ → ℝ} {x ε ε' : ℝ}
    {D : ObserverDerivativeAt f x} (h : CorrectionControlled D ε) (hε : ε ≤ ε') :
    CorrectionControlled D ε' := by
  exact ⟨h.1.trans hε, h.2.trans hε⟩

theorem ofClassical_controlled {f : ℝ → ℝ} {x L ε : ℝ}
    (h : HasDerivAt f L x) (hε : 0 ≤ ε) :
    CorrectionControlled (ofClassical h) ε := by
  constructor
  · exact hε
  · simpa [ofClassical] using hε

/-- Operational sum: reserve the sum of the two input budgets. -/
theorem add_controlled {f g : ℝ → ℝ} {x εf εg : ℝ}
    {Df : ObserverDerivativeAt f x} {Dg : ObserverDerivativeAt g x}
    (hf : CorrectionControlled Df εf) (hg : CorrectionControlled Dg εg) :
    CorrectionControlled (Df.add Dg) (εf + εg) := by
  refine ⟨add_nonneg hf.1 hg.1, ?_⟩
  exact (abs_add_correction_le Df Dg).trans (add_le_add hf.2 hg.2)

/-- Operational product: perturbation is amplified by the magnitude of the
opposite factor, exactly as in the product rule. -/
theorem mul_controlled {f g : ℝ → ℝ} {x εf εg : ℝ}
    {Df : ObserverDerivativeAt f x} {Dg : ObserverDerivativeAt g x}
    (hf : CorrectionControlled Df εf) (hg : CorrectionControlled Dg εg) :
    CorrectionControlled (Df.mul Dg) (εf * |g x| + |f x| * εg) := by
  refine ⟨add_nonneg (mul_nonneg hf.1 (abs_nonneg _))
    (mul_nonneg (abs_nonneg _) hg.1), ?_⟩
  rw [mul_correction]
  calc
    |Df.correction * g x + f x * Dg.correction| ≤
        |Df.correction * g x| + |f x * Dg.correction| := abs_add_le _ _
    _ = |Df.correction| * |g x| + |f x| * |Dg.correction| := by simp [abs_mul]
    _ ≤ εf * |g x| + |f x| * εg :=
      add_le_add (mul_le_mul_of_nonneg_right hf.2 (abs_nonneg _))
        (mul_le_mul_of_nonneg_left hg.2 (abs_nonneg _))

/-- Operational chain rule. The final term is the interaction budget: two
small perturbations can multiply, so it must be tracked explicitly. -/
theorem comp_controlled {f g : ℝ → ℝ} {x εf εg : ℝ}
    {Dg : ObserverDerivativeAt g (f x)} {Df : ObserverDerivativeAt f x}
    (hg : CorrectionControlled Dg εg) (hf : CorrectionControlled Df εf) :
    CorrectionControlled (Dg.comp Df)
      (|Dg.classicalSlope| * εf + εg * |Df.classicalSlope| + εg * εf) := by
  refine ⟨add_nonneg
    (add_nonneg (mul_nonneg (abs_nonneg _) hf.1)
      (mul_nonneg hg.1 (abs_nonneg _)))
    (mul_nonneg hg.1 hf.1), ?_⟩
  apply (abs_comp_correction_le Dg Df).trans
  exact add_le_add
    (add_le_add
      (mul_le_mul_of_nonneg_left hf.2 (abs_nonneg _))
      (mul_le_mul_of_nonneg_right hg.2 (abs_nonneg _)))
    (mul_le_mul hg.2 hf.2 (abs_nonneg _) hg.1)

/-- Operational power rule: the classical power sensitivity scales the
input perturbation budget. -/
theorem pow_controlled {f : ℝ → ℝ} {x ε : ℝ}
    {Df : ObserverDerivativeAt f x} (h : CorrectionControlled Df ε) (n : ℕ) :
    CorrectionControlled (Df.pow n) (|(n : ℝ) * f x ^ (n - 1)| * ε) := by
  refine ⟨mul_nonneg (abs_nonneg _) h.1, ?_⟩
  rw [pow_correction]
  calc
    |(n : ℝ) * f x ^ (n - 1) * Df.correction| =
        |(n : ℝ) * f x ^ (n - 1)| * |Df.correction| := abs_mul _ _
    _ ≤ |(n : ℝ) * f x ^ (n - 1)| * ε :=
      mul_le_mul_of_nonneg_left h.2 (abs_nonneg _)

/-- Operational quotient rule: denominator proximity to zero visibly
amplifies the required correction budget. -/
theorem div_controlled {f g : ℝ → ℝ} {x εf εg : ℝ}
    {Df : ObserverDerivativeAt f x} {Dg : ObserverDerivativeAt g x}
    (hdenom : g x ≠ 0) (hf : CorrectionControlled Df εf)
    (hg : CorrectionControlled Dg εg) :
    CorrectionControlled (Df.div Dg hdenom)
      ((εf * |g x| + |f x| * εg) / |g x| ^ 2) := by
  have hsq : 0 < |g x| ^ 2 := sq_pos_of_ne_zero (abs_ne_zero.mpr hdenom)
  refine ⟨div_nonneg (add_nonneg (mul_nonneg hf.1 (abs_nonneg _))
    (mul_nonneg (abs_nonneg _) hg.1)) hsq.le, ?_⟩
  rw [div_correction, abs_div, abs_pow]
  apply div_le_div_of_nonneg_right _ hsq.le
  calc
    |Df.correction * g x - f x * Dg.correction| ≤
      |Df.correction * g x| + |f x * Dg.correction| := by
        simpa [sub_eq_add_neg] using
          (abs_add_le (Df.correction * g x) (-(f x * Dg.correction)))
    _ = |Df.correction| * |g x| + |f x| * |Dg.correction| := by simp [abs_mul]
    _ ≤ εf * |g x| + |f x| * εg :=
      add_le_add (mul_le_mul_of_nonneg_right hf.2 (abs_nonneg _))
        (mul_le_mul_of_nonneg_left hg.2 (abs_nonneg _))

/- ================================================================
   Executable mutation / cosmic-ray gate
   ================================================================ -/

/-- A proposed mutation of the observer correction. `delta` is what a
mutation engine (for example mutmut or cosmic-ray) attempts to inject;
`budget` is the maximum total correction allowed by the operational run. -/
structure PerturbationRequest {f : ℝ → ℝ} {x : ℝ}
    (D : ObserverDerivativeAt f x) where
  delta : ℝ
  budget : ℝ

/-- Budget remaining after accounting for the correction already present. -/
def PerturbationRequest.headroom {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D) : ℝ :=
  r.budget - |D.correction|

/-- Conservative admission policy: the baseline is controlled and the
mutation magnitude fits wholly inside the remaining headroom. This triangle-
inequality policy is deliberately sign-independent, so cancellation cannot
be used to smuggle a large mutation through the gate. -/
def PerturbationRequest.Admissible {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D) : Prop :=
  CorrectionControlled D r.budget ∧ |r.delta| ≤ r.headroom

noncomputable instance {f : ℝ → ℝ} {x : ℝ} {D : ObserverDerivativeAt f x}
    (r : PerturbationRequest D) : Decidable r.Admissible := Classical.propDecidable _

/-- Executable admission gate suitable for a mutation harness. -/
noncomputable def PerturbationRequest.gate {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D) : Bool :=
  decide r.Admissible

@[simp] theorem PerturbationRequest.gate_eq_true_iff {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D) :
    r.gate = true ↔ r.Admissible := by simp [PerturbationRequest.gate]

@[simp] theorem PerturbationRequest.gate_eq_false_iff {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D) :
    r.gate = false ↔ ¬ r.Admissible := by simp [PerturbationRequest.gate]

/-- Soundness of the gate: every admitted mutation leaves the perturbed
correction inside the declared total budget. -/
theorem PerturbationRequest.admissible_applied_le_budget {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D)
    (h : r.Admissible) : |D.correction + r.delta| ≤ r.budget := by
  calc
    |D.correction + r.delta| ≤ |D.correction| + |r.delta| := abs_add_le _ _
    _ ≤ |D.correction| + r.headroom := add_le_add (le_refl _) h.2
    _ = r.budget := by simp [PerturbationRequest.headroom]

/-- A cosmic-ray mutation that exceeds remaining headroom is killed by the
gate, independently of its sign or any accidental numerical cancellation. -/
theorem PerturbationRequest.cosmicRay_rejected {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D)
    (hlarge : r.headroom < |r.delta|) : r.gate = false := by
  rw [PerturbationRequest.gate_eq_false_iff]
  intro h
  exact (not_lt_of_ge h.2) hlarge

/-- Zero-budget mode is a true control run: both the existing correction and
any admitted mutation are forced to vanish. -/
theorem PerturbationRequest.zero_budget_inert {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r : PerturbationRequest D)
    (hzero : r.budget = 0) (h : r.Admissible) :
    D.correction = 0 ∧ r.delta = 0 := by
  have hcabs : |D.correction| = 0 := le_antisymm (by simpa [hzero] using h.1.2) (abs_nonneg _)
  have hc : D.correction = 0 := abs_eq_zero.mp hcabs
  have hdle : |r.delta| ≤ 0 := by
    simpa [PerturbationRequest.headroom, hzero, hc] using h.2
  have hdabs : |r.delta| = 0 := le_antisymm hdle (abs_nonneg _)
  exact ⟨hc, abs_eq_zero.mp hdabs⟩

/-- Rejection is monotone in mutation magnitude: once a ray is too large,
any still-larger ray is rejected as well. -/
theorem PerturbationRequest.rejection_mono {f : ℝ → ℝ} {x : ℝ}
    {D : ObserverDerivativeAt f x} (r₁ r₂ : PerturbationRequest D)
    (hbudget : r₂.budget = r₁.budget)
    (hlarge : r₁.headroom < |r₁.delta|)
    (hmag : |r₁.delta| ≤ |r₂.delta|) : r₂.gate = false := by
  apply PerturbationRequest.cosmicRay_rejected
  have hheadroom : r₂.headroom = r₁.headroom := by
    simp [PerturbationRequest.headroom, hbudget]
  rw [hheadroom]
  exact hlarge.trans_le hmag

/-- Kernel-computable adapter for mutation tools. External mutation engines
should emit rational certificates; unlike arbitrary real comparison, this
gate reduces by computation. -/
structure RationalPerturbationCertificate where
  baseline : ℚ
  delta : ℚ
  budget : ℚ

def RationalPerturbationCertificate.Admissible
    (r : RationalPerturbationCertificate) : Prop :=
  0 ≤ r.budget ∧ |r.baseline| ≤ r.budget ∧
    |r.delta| ≤ r.budget - |r.baseline|

instance (r : RationalPerturbationCertificate) : Decidable r.Admissible := by
  unfold RationalPerturbationCertificate.Admissible
  infer_instance

def RationalPerturbationCertificate.gate
    (r : RationalPerturbationCertificate) : Bool := decide r.Admissible

@[simp] theorem RationalPerturbationCertificate.gate_eq_true_iff
    (r : RationalPerturbationCertificate) : r.gate = true ↔ r.Admissible := by
  simp [RationalPerturbationCertificate.gate]

/-- A rational certificate accepted by the executable gate proves the same
total-budget safety property used by the real-valued calculus. -/
theorem RationalPerturbationCertificate.admissible_applied_le_budget
    (r : RationalPerturbationCertificate) (h : r.Admissible) :
    |r.baseline + r.delta| ≤ r.budget := by
  calc
    |r.baseline + r.delta| ≤ |r.baseline| + |r.delta| := abs_add_le _ _
    _ ≤ |r.baseline| + (r.budget - |r.baseline|) := add_le_add (le_refl _) h.2.2
    _ = r.budget := by ring

/-- Casting an accepted executable certificate to reals preserves its safety
claim, providing the boundary between a mutation runner and the analytic API. -/
theorem RationalPerturbationCertificate.real_sound
    (r : RationalPerturbationCertificate) (h : r.Admissible) :
    |(r.baseline : ℝ) + (r.delta : ℝ)| ≤ (r.budget : ℝ) := by
  exact_mod_cast r.admissible_applied_le_budget h

end ObserverDerivativeAt

/- ================================================================
   Layer 1 for TTDC/TTIE/TTCS/TTPR: certified fuzzy operators
   ================================================================ -/

/-- A real-valued operational fuzzy operator. Its action, pointwise
observer derivative, and admitted correction budget are packaged together;
there is no untracked map that later SRMF code can compose accidentally. -/
structure FuzzyOperator where
  map : ℝ → ℝ
  derivative : ∀ x, ObserverDerivativeAt map x
  budget : ℝ → ℝ
  controlled : ∀ x, ObserverDerivativeAt.CorrectionControlled (derivative x) (budget x)

namespace FuzzyOperator

/-- The identity phase is classical and consumes no perturbation budget. -/
noncomputable def identity : FuzzyOperator where
  map := id
  derivative x := ObserverDerivativeAt.ofClassical (hasDerivAt_id x)
  budget := fun _ => 0
  controlled x := ObserverDerivativeAt.ofClassical_controlled (hasDerivAt_id x) le_rfl

/-- Forward composition, read `first` and then `next`. Its budget is not an
extra hypothesis: it is calculated by the already-proved operational fuzzy
chain rule, including the interaction term. -/
noncomputable def forwardThen (first next : FuzzyOperator) : FuzzyOperator where
  map := fun x => next.map (first.map x)
  derivative x := (next.derivative (first.map x)).comp (first.derivative x)
  budget x :=
    |(next.derivative (first.map x)).classicalSlope| * first.budget x +
    next.budget (first.map x) * |(first.derivative x).classicalSlope| +
    next.budget (first.map x) * first.budget x
  controlled x := ObserverDerivativeAt.comp_controlled
    (next.controlled (first.map x)) (first.controlled x)

@[simp] theorem identity_map (x : ℝ) : identity.map x = x := rfl

@[simp] theorem forwardThen_map (first next : FuzzyOperator) (x : ℝ) :
    (first.forwardThen next).map x = next.map (first.map x) := rfl

/-- Forward execution is associative. This is deliberately stated first at
the observable map layer; budget reassociation is not silently quotiented. -/
theorem forwardThen_assoc_map (a b c : FuzzyOperator) :
    ((a.forwardThen b).forwardThen c).map = (a.forwardThen (b.forwardThen c)).map := rfl

@[simp] theorem identity_forwardThen_map (F : FuzzyOperator) :
    (identity.forwardThen F).map = F.map := by rfl

@[simp] theorem forwardThen_identity_map (F : FuzzyOperator) :
    (F.forwardThen identity).map = F.map := by rfl

/-- Reverse execution is additional proof-relevant data, never inferred by
reading a forward pipeline backward. -/
structure Reversible (F : FuzzyOperator) where
  inverse : FuzzyOperator
  left_inverse : Function.LeftInverse inverse.map F.map
  right_inverse : Function.RightInverse inverse.map F.map

/-- A certified reverse really returns every output to its source. -/
theorem Reversible.backward_after_forward {F : FuzzyOperator}
    (R : Reversible F) (x : ℝ) : R.inverse.map (F.map x) = x :=
  R.left_inverse x

/-- Likewise forward-after-backward is identity, ruling out one-sided
pseudo-inverses as a model of reverse time. -/
theorem Reversible.forward_after_backward {F : FuzzyOperator}
    (R : Reversible F) (x : ℝ) : F.map (R.inverse.map x) = x :=
  R.right_inverse x

/-- Reversibility composes contravariantly: the reverse of `first` then
`next` executes the reverse of `next` before the reverse of `first`. -/
noncomputable def Reversible.forwardThen {first next : FuzzyOperator}
    (Rf : Reversible first) (Rn : Reversible next) : Reversible (first.forwardThen next) where
  inverse := Rn.inverse.forwardThen Rf.inverse
  left_inverse x := by
    simp only [forwardThen_map]
    rw [Rn.left_inverse, Rf.left_inverse]
  right_inverse x := by
    simp only [forwardThen_map]
    rw [Rf.right_inverse, Rn.right_inverse]

end FuzzyOperator

/- ================================================================
   Layer 2: phase programs and sustainable-emergence certification
   ================================================================ -/

/-- Operational phase names only. The constructors classify operators; they
do not prohibit any execution order and do not themselves assert SRMF. -/
inductive EmergencePhase where
  | ttdc
  | ttie
  | ttcs
  | ttpr
  deriving DecidableEq, Repr

/-- A candidate family supplies one certified fuzzy operator per phase. The
phase-specific semantic contracts will be layered onto these fields later. -/
structure EmergenceOperatorFamily where
  ttdc : FuzzyOperator
  ttie : FuzzyOperator
  ttcs : FuzzyOperator
  ttpr : FuzzyOperator

namespace EmergenceOperatorFamily

/-- Phase lookup is total; therefore arbitrary phase programs remain
operationally executable even when they are not recognized as SRMF. -/
def select (Q : EmergenceOperatorFamily) : EmergencePhase → FuzzyOperator
  | .ttdc => Q.ttdc
  | .ttie => Q.ttie
  | .ttcs => Q.ttcs
  | .ttpr => Q.ttpr

/-- Execute phases exactly in the listed direction. No ordering constraint is
hidden in this evaluator. -/
def execute (Q : EmergenceOperatorFamily) : List EmergencePhase → ℝ → ℝ
  | [], x => x
  | p :: ps, x => execute Q ps ((Q.select p).map x)

@[simp] theorem execute_nil (Q : EmergenceOperatorFamily) (x : ℝ) :
    Q.execute [] x = x := rfl

@[simp] theorem execute_cons (Q : EmergenceOperatorFamily)
    (p : EmergencePhase) (ps : List EmergencePhase) (x : ℝ) :
    Q.execute (p :: ps) x = Q.execute ps ((Q.select p).map x) := rfl

/-- The intended sustainable-emergence orientation, represented as data
rather than imposed on the evaluator. -/
def canonicalOrder : List EmergencePhase :=
  [.ttdc, .ttie, .ttcs, .ttpr]

/-- Recognition is a classification judgment, not executability. -/
def RecognizedOrder (order : List EmergencePhase) : Prop :=
  order = canonicalOrder

@[simp] theorem canonicalOrder_recognized : RecognizedOrder canonicalOrder := rfl

/-- A deliberately out-of-order program still executes; this equation
records its actual operational meaning. -/
theorem swapped_middle_executes (Q : EmergenceOperatorFamily) (x : ℝ) :
    Q.execute [.ttdc, .ttcs, .ttie, .ttpr] x =
      Q.ttpr.map (Q.ttie.map (Q.ttcs.map (Q.ttdc.map x))) := rfl

/-- The same program is not recognized as the canonical SRMF orientation. -/
theorem swapped_middle_unrecognized :
    ¬ RecognizedOrder [.ttdc, .ttcs, .ttie, .ttpr] := by
  simp [RecognizedOrder, canonicalOrder]

/-- One whole-program step, available for canonical and noncanonical orders
alike. -/
def programMap (Q : EmergenceOperatorFamily) (order : List EmergencePhase) :
    ℝ → ℝ := Q.execute order

/-- Sustainability at a seed means that every repeated whole-program pass
stays inside one finite bound. This is deliberately independent of
recognition. -/
def SustainableAt (Q : EmergenceOperatorFamily) (order : List EmergencePhase)
    (seed : ℝ) : Prop :=
  ∃ B : ℝ, 0 ≤ B ∧ ∀ n : ℕ, |(Q.programMap order)^[n] seed| ≤ B

/-- Emergence excludes the vacuous identity-at-the-seed loop. -/
def EmergentAt (Q : EmergenceOperatorFamily) (order : List EmergencePhase)
    (seed : ℝ) : Prop := Q.programMap order seed ≠ seed

/-- SRMF certification combines, without conflating, recognition,
sustainability, and nontrivial emergence. Merely cycling is insufficient. -/
structure SRMFCertificate (Q : EmergenceOperatorFamily) (order : List EmergencePhase)
    (seed : ℝ) : Prop where
  recognized : RecognizedOrder order
  sustainable : SustainableAt Q order seed
  emergent : EmergentAt Q order seed

/-- Every SRMF-certified program is executable, but its sustainable and
emergent obligations remain explicit proof fields. -/
theorem SRMFCertificate.exists_output {Q : EmergenceOperatorFamily}
    {order : List EmergencePhase} {seed : ℝ} (_C : SRMFCertificate Q order seed) :
    ∃ output : ℝ, Q.execute order seed = output :=
  ⟨Q.execute order seed, rfl⟩

/-- Recognition alone cannot establish SRMF: a canonical identity quartet is
recognized but fails the nontrivial-emergence requirement at every seed. -/
noncomputable def identityFamily : EmergenceOperatorFamily where
  ttdc := FuzzyOperator.identity
  ttie := FuzzyOperator.identity
  ttcs := FuzzyOperator.identity
  ttpr := FuzzyOperator.identity

@[simp] theorem identityFamily_canonical_exec (x : ℝ) :
    identityFamily.execute canonicalOrder x = x := rfl

 theorem identityFamily_not_emergent (x : ℝ) :
    ¬ EmergentAt identityFamily canonicalOrder x := by
  simp [EmergentAt, programMap]

end EmergenceOperatorFamily

/- ================================================================
   Layer 3a: TTDC certification as an explicit staging decision
   ================================================================ -/

/-- TTDC has two operational outcomes. `abstain` is a genuine decision,
not a failed or missing execution; `stage` authorizes the contracted map. -/
inductive StagingDecision where
  | abstain
  | stage
  deriving DecidableEq, Repr

/-- A TTDC operator packages an admission contract with a decidable staging
boundary. If the input meets the contract, executing the fuzzy operator is
proved to establish the declared postcondition. If it does not, TTDC holds
the input fixed. This keeps the decision to stage separate from the later
TTIE expansion and from TTPR's metric contraction. -/
structure CertifiedTTDC where
  operator : FuzzyOperator
  contract : ℝ → Prop
  contractDecidable : ∀ x, Decidable (contract x)
  postcondition : ℝ → Prop
  stage_sound : ∀ x, contract x → postcondition (operator.map x)

namespace CertifiedTTDC

/-- The admission contract decides whether TTDC stages or abstains. -/
def decision (T : CertifiedTTDC) (x : ℝ) : StagingDecision :=
  @ite StagingDecision (T.contract x) (T.contractDecidable x)
    .stage .abstain

/-- TTDC executes only an authorized stage. Abstention is operationally
inert, so merely presenting a state cannot mutate it. -/
def execute (T : CertifiedTTDC) (x : ℝ) : ℝ :=
  match T.decision x with
  | .stage => T.operator.map x
  | .abstain => x

theorem decision_eq_stage_iff (T : CertifiedTTDC) (x : ℝ) :
    T.decision x = .stage ↔ T.contract x := by
  simp [decision]

theorem decision_eq_abstain_iff (T : CertifiedTTDC) (x : ℝ) :
    T.decision x = .abstain ↔ ¬ T.contract x := by
  simp [decision]

theorem execute_of_contract (T : CertifiedTTDC) (x : ℝ)
    (h : T.contract x) : T.execute x = T.operator.map x := by
  simp [execute, decision, h]

theorem execute_of_not_contract (T : CertifiedTTDC) (x : ℝ)
    (h : ¬ T.contract x) : T.execute x = x := by
  simp [execute, decision, h]

/-- Every admitted stage establishes the postcondition promised by its
contract. -/
theorem execute_satisfies_postcondition (T : CertifiedTTDC) (x : ℝ)
    (h : T.contract x) : T.postcondition (T.execute x) := by
  rw [T.execute_of_contract x h]
  exact T.stage_sound x h

/-- TTDC cannot both stage and abstain on the same input. -/
theorem stage_ne_abstain (T : CertifiedTTDC) (x : ℝ) :
    ¬ (T.decision x = .stage ∧ T.decision x = .abstain) := by
  rintro ⟨hs, ha⟩
  exact StagingDecision.noConfusion (hs.symm.trans ha)

/-- Execute TTDC on the visible coordinate while recording the observer's
decision in the Scholium's history-bearing state. -/
def recordedExecute (T : CertifiedTTDC) (newTraces : ℕ)
    (s : ScholiumDyn.ReflectiveState ℝ) : ScholiumDyn.ReflectiveState ℝ where
  base := T.execute s.base
  traces := s.traces + newTraces

/-- A recorded TTDC decision is fully stationary exactly when its visible
execution is stationary and it writes no new trace. -/
theorem recordedExecute_eq_iff (T : CertifiedTTDC) (newTraces : ℕ)
    (s : ScholiumDyn.ReflectiveState ℝ) :
    T.recordedExecute newTraces s = s ↔
      T.execute s.base = s.base ∧ newTraces = 0 := by
  constructor
  · intro h
    have hb := congrArg ScholiumDyn.ReflectiveState.base h
    have ht := congrArg ScholiumDyn.ReflectiveState.traces h
    exact ⟨hb, by
      unfold recordedExecute at ht
      simp only at ht
      omega⟩
  · rintro ⟨hb, rfl⟩
    rcases s with ⟨base, traces⟩
    simp [recordedExecute] at hb ⊢
    exact hb

/-- TTDC abstention is inert on the visible state, but a positively recorded
decision still advances the full observer-state in time. -/
theorem abstention_base_inert_but_recorded
    (T : CertifiedTTDC) (x : ℝ) (hx : ¬ T.contract x)
    {newTraces : ℕ} (htrace : 0 < newTraces) (history : ℕ) :
    let s : ScholiumDyn.ReflectiveState ℝ := ⟨x, history⟩
    (T.recordedExecute newTraces s).base = s.base ∧
      T.recordedExecute newTraces s ≠ s := by
  dsimp
  constructor
  · exact T.execute_of_not_contract x hx
  · intro h
    have hs := (T.recordedExecute_eq_iff newTraces ⟨x, history⟩).mp h
    omega

/-- Install a phase-specific TTDC certificate without altering the later
three operator slots. -/
def install (T : CertifiedTTDC) (Q : EmergenceOperatorFamily) :
    EmergenceOperatorFamily where
  ttdc := T.operator
  ttie := Q.ttie
  ttcs := Q.ttcs
  ttpr := Q.ttpr

@[simp] theorem install_ttdc (T : CertifiedTTDC) (Q : EmergenceOperatorFamily) :
    (T.install Q).ttdc = T.operator := rfl

end CertifiedTTDC

/- ================================================================
   Layer 3b: TTPR certification from the existing contraction kernel
   ================================================================ -/

/-- A TTPR operator is not merely tagged `ttpr`: its fuzzy execution map is
proved to satisfy Book 4's refinement-contraction axiom. This wrapper joins
operational perturbation control to the established convergence layer. -/
structure CertifiedTTPR where
  operator : FuzzyOperator
  kappa : ℝ
  kappa_pos : 0 < kappa
  kappa_lt_one : kappa < 1
  contract : ∀ x y, dist (operator.map x) (operator.map y) ≤ kappa * dist x y

namespace CertifiedTTPR

def refinement (T : CertifiedTTPR) : Book4A.ContractionRefinement ℝ where
  R := T.operator.map
  kappa := T.kappa
  kappa_pos := T.kappa_pos
  kappa_lt_one := T.kappa_lt_one
  contract := T.contract

noncomputable def limit (T : CertifiedTTPR) : ℝ := T.refinement.ttprLimit

theorem limit_fixed (T : CertifiedTTPR) : T.operator.map T.limit = T.limit :=
  T.refinement.ttprLimit_fixed

theorem fixed_eq_limit (T : CertifiedTTPR) {x : ℝ}
    (hx : T.operator.map x = x) : x = T.limit :=
  T.refinement.fixed_eq_ttprLimit hx

/-- Every operational TTPR trajectory converges to its unique identity. -/
theorem tendsto_iterate_limit (T : CertifiedTTPR) (x : ℝ) :
    Filter.Tendsto (fun n => T.operator.map^[n] x)
      Filter.atTop (nhds T.limit) :=
  T.refinement.tendsto_iterate_ttprLimit x

/-- Quantitative convergence remains available at the operational layer. -/
theorem iterate_dist_limit_le (T : CertifiedTTPR) (n : ℕ) (x : ℝ) :
    dist (T.operator.map^[n] x) T.limit ≤
      T.kappa ^ n * dist x T.limit := by
  have h := Book4A.contractionRefinement_iterate T.refinement n x T.limit
  change dist (T.operator.map^[n] x) (T.operator.map^[n] T.limit) ≤
    T.kappa ^ n * dist x T.limit at h
  rw [Function.iterate_fixed T.limit_fixed n] at h
  exact h

/-- Install only the certified refinement phase; no claim about the other
three phase contracts or SRMF sustainability is introduced. -/
def install (T : CertifiedTTPR) (Q : EmergenceOperatorFamily) :
    EmergenceOperatorFamily where
  ttdc := Q.ttdc
  ttie := Q.ttie
  ttcs := Q.ttcs
  ttpr := T.operator

@[simp] theorem install_ttpr (T : CertifiedTTPR) (Q : EmergenceOperatorFamily) :
    (T.install Q).ttpr = T.operator := rfl

end CertifiedTTPR

/- ================================================================
   Layer 3b: TTCS certification from finite coherence sampling
   ================================================================ -/

/-- A TTCS operator is operationally fuzzy and is exactly realized as the
average of a nonempty finite coherence sample at every input. Pointwise
sample bounds provide its stable coherence corridor. -/
structure CertifiedTTCS where
  operator : FuzzyOperator
  sampleCount : ℕ
  sampleCount_pos : 0 < sampleCount
  sample : ℝ → Fin sampleCount → ℝ
  lower : ℝ
  upper : ℝ
  lower_le_sample : ∀ x i, lower ≤ sample x i
  sample_le_upper : ∀ x i, sample x i ≤ upper
  output_eq_average : ∀ x,
    operator.map x = (∑ i, sample x i) / (sampleCount : ℝ)

namespace CertifiedTTCS

/-- Every TTCS output remains above its declared coherence floor. -/
theorem lower_le_output (T : CertifiedTTCS) (x : ℝ) :
    T.lower ≤ T.operator.map x := by
  rw [T.output_eq_average]
  exact Book4C.ttcs_sample_average_ge T.sampleCount_pos (T.sample x) T.lower
    (T.lower_le_sample x)

/-- Every TTCS output remains below its declared stability ceiling. -/
theorem output_le_upper (T : CertifiedTTCS) (x : ℝ) :
    T.operator.map x ≤ T.upper := by
  rw [T.output_eq_average]
  exact Book4C.ttcs_sample_average_le T.sampleCount_pos (T.sample x) T.upper
    (T.sample_le_upper x)

/-- The TTCS corridor is nonempty, derived rather than separately assumed. -/
theorem lower_le_upper (T : CertifiedTTCS) : T.lower ≤ T.upper := by
  exact (T.lower_le_output 0).trans (T.output_le_upper 0)

/-- One TTCS application lands in the closed coherence corridor. -/
theorem output_mem_Icc (T : CertifiedTTCS) (x : ℝ) :
    T.operator.map x ∈ Set.Icc T.lower T.upper :=
  ⟨T.lower_le_output x, T.output_le_upper x⟩

/-- Once TTCS has run at least once, every subsequent repeated TTCS state
remains in the coherence corridor, independent of the starting state. -/
theorem iterate_succ_mem_Icc (T : CertifiedTTCS) (n : ℕ) (x : ℝ) :
    T.operator.map^[n + 1] x ∈ Set.Icc T.lower T.upper := by
  rw [Function.iterate_succ_apply']
  exact T.output_mem_Icc _

/-- The sampling realization cannot be silently changed while retaining the
same certified operator output: any alternative sample family with the same
pointwise average produces the same observation. -/
theorem output_eq_of_average_eq (T : CertifiedTTCS)
    (other : ℝ → Fin T.sampleCount → ℝ)
    (havg : ∀ x, (∑ i, other x i) / (T.sampleCount : ℝ) =
      (∑ i, T.sample x i) / (T.sampleCount : ℝ)) (x : ℝ) :
    T.operator.map x = (∑ i, other x i) / (T.sampleCount : ℝ) := by
  rw [T.output_eq_average, havg]

/-- Install only the certified sampling phase. -/
def install (T : CertifiedTTCS) (Q : EmergenceOperatorFamily) :
    EmergenceOperatorFamily where
  ttdc := Q.ttdc
  ttie := Q.ttie
  ttcs := T.operator
  ttpr := Q.ttpr

@[simp] theorem install_ttcs (T : CertifiedTTCS) (Q : EmergenceOperatorFamily) :
    (T.install Q).ttcs = T.operator := rfl

/-- Constant observations are reproduced exactly: TTCS aggregates evidence;
it does not manufacture expansion from a uniform sample. -/
theorem output_eq_of_sample_constant (T : CertifiedTTCS) (x c : ℝ)
    (hconst : ∀ i, T.sample x i = c) : T.operator.map x = c := by
  rw [T.output_eq_average]
  simp_rw [hconst]
  simp [T.sampleCount_pos.ne']

/-- TTCS is invariant under reindexing of the same finite evidence. Sample
order carries no directional or expansion semantics. -/
theorem output_reindex (T : CertifiedTTCS) (x : ℝ)
    (e : Equiv.Perm (Fin T.sampleCount)) :
    T.operator.map x =
      (∑ i, T.sample x (e i)) / (T.sampleCount : ℝ) := by
  rw [T.output_eq_average]
  congr 1
  exact (Fintype.sum_equiv e (fun i => T.sample x (e i))
    (fun i => T.sample x i) (fun _ => rfl)).symm

/-- Samplewise perturbation control: if every reading changes by at most
`ε`, its aggregate changes by at most `ε`. This is the operational robustness
law expected of sampling, distinct from TTIE's expansion envelope. -/
theorem alternative_average_dist_le (T : CertifiedTTCS) (x : ℝ)
    (other : Fin T.sampleCount → ℝ) (ε : ℝ) (_hε : 0 ≤ ε)
    (hpoint : ∀ i, |other i - T.sample x i| ≤ ε) :
    |(∑ i, other i) / (T.sampleCount : ℝ) - T.operator.map x| ≤ ε := by
  rw [T.output_eq_average]
  have hn : (0 : ℝ) < T.sampleCount := by exact_mod_cast T.sampleCount_pos
  have hsum : |∑ i, (other i - T.sample x i)| ≤ (T.sampleCount : ℝ) * ε := by
    calc
      |∑ i, (other i - T.sample x i)| ≤
          ∑ i, |other i - T.sample x i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i : Fin T.sampleCount, ε := Finset.sum_le_sum fun i _ => hpoint i
      _ = (T.sampleCount : ℝ) * ε := by simp [Finset.card_univ]
  have heq : (∑ i, other i) / (T.sampleCount : ℝ) -
      (∑ i, T.sample x i) / (T.sampleCount : ℝ) =
      (∑ i, (other i - T.sample x i)) / (T.sampleCount : ℝ) := by
    rw [Finset.sum_sub_distrib]
    ring
  rw [heq, abs_div, abs_of_pos hn]
  exact (div_le_iff₀ hn).2 (by simpa [mul_comm] using hsum)

/-- The certified TTCS output is therefore stable under any alternative
sampling implementation satisfying the same pointwise perturbation budget. -/
theorem alternative_output_dist_le (T : CertifiedTTCS) (x : ℝ)
    (other : Fin T.sampleCount → ℝ) (otherOutput ε : ℝ)
    (hout : otherOutput = (∑ i, other i) / (T.sampleCount : ℝ))
    (hε : 0 ≤ ε) (hpoint : ∀ i, |other i - T.sample x i| ≤ ε) :
    |otherOutput - T.operator.map x| ≤ ε := by
  rw [hout]
  exact T.alternative_average_dist_le x other ε hε hpoint

end CertifiedTTCS

/- ================================================================
   Layer 3c: TTIE certification as accessible-envelope expansion
   ================================================================ -/

/-- TTIE is a directional expansion of accessible states, not a sampling
average. A certified operator advances a nested envelope, genuinely enlarges
it at some stage, and obeys the Principia expansion-speed bound. -/
structure CertifiedTTIE where
  operator : FuzzyOperator
  envelope : ℕ → Set ℝ
  envelope_mono : Monotone envelope
  seed : ℝ
  seed_mem : seed ∈ envelope 0
  advances : ∀ n x, x ∈ envelope n → operator.map x ∈ envelope (n + 1)
  expansion : Book4C.TTIEExpansionBound
  expansion_nonneg : 0 ≤ expansion.vExp
  step_dist_le : ∀ x, dist (operator.map x) x ≤ expansion.vExp
  genuine_expansion : ∃ n, envelope n ⊂ envelope (n + 1)

namespace CertifiedTTIE

/-- Any state admitted to TTIE's initial envelope remains accessible at
the corresponding stage under every forward iterate. This generalized form
is what an earlier phase's imagination bridge consumes. -/
theorem iterate_mem_envelope_of_mem (T : CertifiedTTIE) {x : ℝ}
    (hx : x ∈ T.envelope 0) (n : ℕ) :
    T.operator.map^[n] x ∈ T.envelope n := by
  induction n with
  | zero => simpa using hx
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      simpa [Nat.add_comm] using T.advances n _ ih

/-- Every forward TTIE iterate of its distinguished seed is certified
accessible at its corresponding expansion stage. -/
theorem iterate_mem_envelope (T : CertifiedTTIE) (n : ℕ) :
    T.operator.map^[n] T.seed ∈ T.envelope n :=
  T.iterate_mem_envelope_of_mem T.seed_mem n

/-- TTIE's per-step expansion never outruns symbolic coherence speed. -/
theorem step_dist_le_coherenceSpeed (T : CertifiedTTIE) (x : ℝ) :
    dist (T.operator.map x) x ≤ T.expansion.cs :=
  T.step_dist_le x |>.trans (Book4C.ttieExpansionBound_le_cs T.expansion)

/-- Genuine envelope growth supplies a newly accessible state. This is the
set-level novelty that conservative TTCS averaging does not assert. -/
theorem exists_newly_accessible (T : CertifiedTTIE) :
    ∃ n x, x ∈ T.envelope (n + 1) ∧ x ∉ T.envelope n := by
  rcases T.genuine_expansion with ⟨n, hstrict⟩
  rcases Set.ssubset_iff_exists.1 hstrict with ⟨_, x, hx, hnot⟩
  exact ⟨n, x, hx, hnot⟩

/-- The total TTIE-accessible region is the union of its finite expansion
stages. -/
def accessibleLimit (T : CertifiedTTIE) : Set ℝ := ⋃ n, T.envelope n

theorem envelope_subset_accessibleLimit (T : CertifiedTTIE) (n : ℕ) :
    T.envelope n ⊆ T.accessibleLimit := Set.subset_iUnion T.envelope n

/-- Every reachable iterate belongs to the total accessible region. -/
theorem iterate_mem_accessibleLimit (T : CertifiedTTIE) (n : ℕ) :
    T.operator.map^[n] T.seed ∈ T.accessibleLimit :=
  T.envelope_subset_accessibleLimit n (T.iterate_mem_envelope n)

/-- The accessible limit is the least region containing every TTIE stage. -/
theorem accessibleLimit_least (T : CertifiedTTIE) {V : Set ℝ}
    (hV : ∀ n, T.envelope n ⊆ V) : T.accessibleLimit ⊆ V :=
  Set.iUnion_subset hV

/-- Strict expansion means the accessible limit properly extends at least
one earlier stage. -/
theorem exists_envelope_ssubset_accessibleLimit (T : CertifiedTTIE) :
    ∃ n, T.envelope n ⊂ T.accessibleLimit := by
  rcases T.genuine_expansion with ⟨n, hstrict⟩
  exact ⟨n, hstrict.trans_le (T.envelope_subset_accessibleLimit (n + 1))⟩

/-- Install only the certified expansion phase. -/
def install (T : CertifiedTTIE) (Q : EmergenceOperatorFamily) :
    EmergenceOperatorFamily where
  ttdc := Q.ttdc
  ttie := T.operator
  ttcs := Q.ttcs
  ttpr := Q.ttpr

@[simp] theorem install_ttie (T : CertifiedTTIE) (Q : EmergenceOperatorFamily) :
    (T.install Q).ttie = T.operator := rfl

end CertifiedTTIE

/- ================================================================
   Layer 4a: directional imagination bridge from TTDC into TTIE
   ================================================================ -/

/-- The first imagination bridge is compatibility evidence between already
certified phases. It says that every state satisfying TTDC's promised
postcondition is admissible to TTIE's initial accessibility envelope. It
does not execute either phase, infer a reverse bridge, or claim that the
resulting larger cycle is sustainable. -/
structure TTDCToTTIEImagination
    (D : CertifiedTTDC) (E : CertifiedTTIE) : Prop where
  postcondition_enters :
    ∀ y, D.postcondition y → y ∈ E.envelope 0

namespace TTDCToTTIEImagination

/-- A TTDC output crosses the bridge only with evidence that TTDC chose to
stage it. -/
theorem staged_output_mem_initial
    {D : CertifiedTTDC} {E : CertifiedTTIE}
    (B : TTDCToTTIEImagination D E) (x : ℝ) (hx : D.contract x) :
    D.execute x ∈ E.envelope 0 :=
  B.postcondition_enters _ (D.execute_satisfies_postcondition x hx)

/-- Once the staged result crosses into TTIE, every subsequent expansion
iterate occupies its correctly indexed accessibility envelope. -/
theorem staged_then_ttie_iterate_mem_envelope
    {D : CertifiedTTDC} {E : CertifiedTTIE}
    (B : TTDCToTTIEImagination D E) (x : ℝ) (hx : D.contract x) (n : ℕ) :
    E.operator.map^[n] (D.execute x) ∈ E.envelope n :=
  E.iterate_mem_envelope_of_mem (B.staged_output_mem_initial x hx) n

/-- The complete staged-then-expanded trajectory lies in TTIE's accessible
limit. -/
theorem staged_then_ttie_iterate_mem_accessibleLimit
    {D : CertifiedTTDC} {E : CertifiedTTIE}
    (B : TTDCToTTIEImagination D E) (x : ℝ) (hx : D.contract x) (n : ℕ) :
    E.operator.map^[n] (D.execute x) ∈ E.accessibleLimit :=
  E.envelope_subset_accessibleLimit n
    (B.staged_then_ttie_iterate_mem_envelope x hx n)

end TTDCToTTIEImagination

/- ================================================================
   Layer 4b: directional imagination bridge from TTIE into TTCS
   ================================================================ -/

/-- At a declared TTIE stage, the next imagination bridge certifies that
TTCS's finite observations are selected from the region TTIE has actually
made accessible. Accessibility alone does not manufacture this witness:
the sample-trace obligation is explicit. -/
structure TTIEToTTCSImagination
    (E : CertifiedTTIE) (S : CertifiedTTCS) (stage : ℕ) : Prop where
  samples_accessible :
    ∀ x, x ∈ E.envelope stage → ∀ i, S.sample x i ∈ E.accessibleLimit

namespace TTIEToTTCSImagination

/-- Every observation selected from an admitted TTIE trajectory is traceable
to TTIE's accessible limit. -/
theorem selected_samples_accessible
    {E : CertifiedTTIE} {S : CertifiedTTCS} {stage : ℕ}
    (B : TTIEToTTCSImagination E S stage) {x : ℝ}
    (hx : x ∈ E.envelope 0) (i : Fin S.sampleCount) :
    S.sample (E.operator.map^[stage] x) i ∈ E.accessibleLimit :=
  B.samples_accessible _ (E.iterate_mem_envelope_of_mem hx stage) i

/-- The bridge carries genuinely nonempty evidence because a certified TTCS
sample family has positive cardinality. -/
theorem exists_accessible_sample
    {E : CertifiedTTIE} {S : CertifiedTTCS} {stage : ℕ}
    (B : TTIEToTTCSImagination E S stage) {x : ℝ}
    (hx : x ∈ E.envelope 0) :
    ∃ i : Fin S.sampleCount,
      S.sample (E.operator.map^[stage] x) i ∈ E.accessibleLimit := by
  let i : Fin S.sampleCount := ⟨0, S.sampleCount_pos⟩
  exact ⟨i, B.selected_samples_accessible hx i⟩

/-- Sampling the expanded state lands in TTCS's conservative corridor. The
claim is about the TTCS output, not about further expansion. -/
theorem expanded_then_sampled_mem_Icc
    {E : CertifiedTTIE} {S : CertifiedTTCS} {stage : ℕ}
    (_B : TTIEToTTCSImagination E S stage) (x : ℝ) :
    S.operator.map (E.operator.map^[stage] x) ∈ Set.Icc S.lower S.upper :=
  S.output_mem_Icc _

end TTIEToTTCSImagination

/- ================================================================
   Layer 4c: directional imagination bridge from TTCS into TTPR
   ================================================================ -/

/-- The TTCS-to-TTPR bridge requires refinement to preserve the coherence
corridor established by finite sampling. Global convergence of TTPR alone
does not imply this local sustainability property, so it remains an explicit
compatibility obligation. -/
structure TTCSToTTPRImagination
    (S : CertifiedTTCS) (R : CertifiedTTPR) : Prop where
  refinement_preserves_corridor :
    ∀ y, y ∈ Set.Icc S.lower S.upper →
      R.operator.map y ∈ Set.Icc S.lower S.upper

namespace TTCSToTTPRImagination

/-- Starting from a TTCS output, every finite TTPR refinement remains inside
the sampling phase's coherence corridor. -/
theorem refinement_iterate_mem_Icc
    {S : CertifiedTTCS} {R : CertifiedTTPR}
    (B : TTCSToTTPRImagination S R) (x : ℝ) (n : ℕ) :
    R.operator.map^[n] (S.operator.map x) ∈ Set.Icc S.lower S.upper := by
  induction n with
  | zero => simpa using S.output_mem_Icc x
  | succ n ih =>
      rw [Function.iterate_succ_apply']
      exact B.refinement_preserves_corridor _ ih

/-- The same corridor-preserving refinement trajectory converges to TTPR's
unique fixed identity. -/
theorem tendsto_refinement_from_sample
    {S : CertifiedTTCS} {R : CertifiedTTPR}
    (_B : TTCSToTTPRImagination S R) (x : ℝ) :
    Filter.Tendsto
      (fun n => R.operator.map^[n] (S.operator.map x))
      Filter.atTop (nhds R.limit) :=
  R.tendsto_iterate_limit _

/-- Because the TTCS corridor is closed, the TTPR identity selected from a
sampled start remains in that corridor. -/
theorem limit_mem_Icc
    {S : CertifiedTTCS} {R : CertifiedTTPR}
    (B : TTCSToTTPRImagination S R) (x : ℝ) :
    R.limit ∈ Set.Icc S.lower S.upper := by
  exact isClosed_Icc.mem_of_tendsto
    (B.tendsto_refinement_from_sample x)
    (Filter.Eventually.of_forall (B.refinement_iterate_mem_Icc x))

end TTCSToTTPRImagination

/- ================================================================
   Layer 4d: canonical return from TTPR to TTDC's staging decision
   ================================================================ -/

namespace TTPRToTTDCImagination

/-- In the scalar kernel, the state returned around the horn is exactly the
TTPR fixed identity; no unproved equality or reverse traversal is inserted. -/
noncomputable def returnState (R : CertifiedTTPR) : ℝ := R.limit

@[simp] theorem returnState_eq_limit (R : CertifiedTTPR) :
    returnState R = R.limit := rfl

/-- Returning around the horn does not pre-decide TTDC. Its contract makes
the next outcome exhaustive: either the returned identity stages and meets
TTDC's postcondition, or TTDC abstains and leaves it unchanged. -/
theorem stage_or_abstain
    (R : CertifiedTTPR) (D : CertifiedTTDC) :
    (D.decision (returnState R) = .stage ∧
      D.postcondition (D.execute (returnState R))) ∨
    (D.decision (returnState R) = .abstain ∧
      D.execute (returnState R) = returnState R) := by
  by_cases h : D.contract (returnState R)
  · left
    exact ⟨(D.decision_eq_stage_iff _).2 h,
      D.execute_satisfies_postcondition _ h⟩
  · right
    exact ⟨(D.decision_eq_abstain_iff _).2 h,
      D.execute_of_not_contract _ h⟩

/-- If the returned TTPR identity is not admitted, both neighboring phases
are inert there: TTPR fixes it and TTDC abstains without mutation. -/
theorem abstaining_return_is_fixed
    (R : CertifiedTTPR) (D : CertifiedTTDC)
    (h : ¬ D.contract (returnState R)) :
    R.operator.map (returnState R) = returnState R ∧
      D.execute (returnState R) = returnState R := by
  exact ⟨R.limit_fixed, D.execute_of_not_contract _ h⟩

end TTPRToTTDCImagination

/- ================================================================
   Layer 4e: one-pass imagination horn
   ================================================================ -/

/-- A complete scalar imagination horn bundles the three nontrivial
compatibility witnesses in their recognized direction. The final TTPR-to-
TTDC return is canonical and remains subject to TTDC's fresh decision. This
certificate supports one traced pass; it does not assert sustainability of
indefinite repetition. -/
structure ImaginationHorn
    (D : CertifiedTTDC) (E : CertifiedTTIE)
    (S : CertifiedTTCS) (R : CertifiedTTPR) (stage : ℕ) : Prop where
  ttdc_to_ttie : TTDCToTTIEImagination D E
  ttie_to_ttcs : TTIEToTTCSImagination E S stage
  ttcs_to_ttpr : TTCSToTTPRImagination S R

namespace ImaginationHorn

/-- Every finite TTCS observation in a contracted one-pass horn is traced
back to TTIE's accessible region. -/
theorem staged_sample_accessible
    {D : CertifiedTTDC} {E : CertifiedTTIE}
    {S : CertifiedTTCS} {R : CertifiedTTPR} {stage : ℕ}
    (H : ImaginationHorn D E S R stage) (x : ℝ)
    (hx : D.contract x) (i : Fin S.sampleCount) :
    S.sample (E.operator.map^[stage] (D.execute x)) i ∈ E.accessibleLimit :=
  H.ttie_to_ttcs.selected_samples_accessible
    (H.ttdc_to_ttie.staged_output_mem_initial x hx) i

/-- After the traced TTDC, TTIE, and TTCS steps, every finite TTPR
refinement remains inside the TTCS coherence corridor. -/
theorem one_pass_refinement_mem_Icc
    {D : CertifiedTTDC} {E : CertifiedTTIE}
    {S : CertifiedTTCS} {R : CertifiedTTPR} {stage : ℕ}
    (H : ImaginationHorn D E S R stage) (x : ℝ) (_hx : D.contract x)
    (n : ℕ) :
    R.operator.map^[n]
      (S.operator.map (E.operator.map^[stage] (D.execute x))) ∈
        Set.Icc S.lower S.upper :=
  H.ttcs_to_ttpr.refinement_iterate_mem_Icc _ n

/-- The same fully traced one-pass trajectory converges to TTPR's unique
identity. This is convergence of the pass, not a proof that repeated horn
passes are sustainable or nontrivially emergent. -/
theorem one_pass_tendsto_limit
    {D : CertifiedTTDC} {E : CertifiedTTIE}
    {S : CertifiedTTCS} {R : CertifiedTTPR} {stage : ℕ}
    (H : ImaginationHorn D E S R stage) (x : ℝ) (_hx : D.contract x) :
    Filter.Tendsto
      (fun n => R.operator.map^[n]
        (S.operator.map (E.operator.map^[stage] (D.execute x))))
      Filter.atTop (nhds R.limit) :=
  H.ttcs_to_ttpr.tendsto_refinement_from_sample _

end ImaginationHorn

/- ================================================================
   lemma:bk4_convergence_of_symbolic_drift
   ================================================================ -/

/-- The honest discrete kernel of lemma:bk4_convergence_of_symbolic_drift,
dropping the transfinite/ordinal indexing (not modeled): a nonnegative real
sequence of successive operator-differences that contracts geometrically at
a fixed rate `r < 1` at every step tends to `0`. This is the countable
convergence content of "the transfinite sequence of drift operators
converges to `D_Ω` in the observer topology" once the per-step contraction
hypothesis is read as a genuine geometric decay rate. -/
theorem symbolicDrift_geometric_contraction_tendsto_zero
    (a : Nat → Real) (r : Real) (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hnonneg : ∀ n, 0 ≤ a n) (hstep : ∀ n, a (n + 1) ≤ r * a n) :
    Filter.Tendsto a Filter.atTop (nhds 0) := by
  have hbound : ∀ n, a n ≤ a 0 * r ^ n := by
    intro n
    induction n with
    | zero => simp
    | succ k ih =>
        calc a (k + 1) ≤ r * a k := hstep k
        _ ≤ r * (a 0 * r ^ k) := mul_le_mul_of_nonneg_left ih hr0
        _ = a 0 * r ^ (k + 1) := by ring
  have hgeom : Filter.Tendsto (fun n => a 0 * r ^ n) Filter.atTop (nhds 0) := by
    have h1 : Filter.Tendsto (fun n : Nat => r ^ n) Filter.atTop (nhds 0) :=
      tendsto_pow_atTop_nhds_zero_of_abs_lt_one (by rwa [abs_of_nonneg hr0])
    simpa using h1.const_mul (a 0)
  exact squeeze_zero hnonneg hbound hgeom

/- ================================================================
   definition:bk4_observer_metric, lemma:bk4_observer_metric_properties
   ================================================================ -/

/-- The honest 1-dimensional kernel of the observer-induced metric
`g_O(p)(v, w) := ⟨K_O v, K_O w⟩_{g(p)}` (definition:bk4_observer_metric): the
bilinear pairing of a resolution kernel `K` applied to each argument. The
manifold, tangent-bundle, and inner-product-space structure are not
modeled; only the resulting real-valued pairing and its algebraic
properties are. -/
def observerMetric (K : Real → Real) (v w : Real) : Real := K v * K w

/-- Positivity (lemma:bk4_observer_metric_properties, clause 1, the
inequality half). -/
theorem observerMetric_self_nonneg (K : Real → Real) (v : Real) :
    0 ≤ observerMetric K v v := by
  unfold observerMetric; exact mul_self_nonneg _

/-- Positivity (lemma:bk4_observer_metric_properties, clause 1, the
equality-case half): `g_O(v,v) = 0` iff `K_O v = 0`. -/
theorem observerMetric_self_eq_zero_iff (K : Real → Real) (v : Real) :
    observerMetric K v v = 0 ↔ K v = 0 := by
  unfold observerMetric; exact mul_self_eq_zero

/-- Symmetry (lemma:bk4_observer_metric_properties, clause 2). -/
theorem observerMetric_symm (K : Real → Real) (v w : Real) :
    observerMetric K v w = observerMetric K w v := by
  unfold observerMetric; exact mul_comm _ _

/-- Pull a resolution kernel back along the coordinate rescaling `x ↦ a*x`.
Thus the rescaled kernel reads a new-coordinate vector by first returning it
to the original coordinate. -/
noncomputable def rescaleKernel (a : Real) (K : Real → Real) : Real → Real :=
  fun x => K (x / a)

/-- Coordinate rescaling composes multiplicatively at the kernel level. -/
theorem rescaleKernel_mul (a b : Real) (K : Real → Real) :
    rescaleKernel a (rescaleKernel b K) = rescaleKernel (a * b) K := by
  funext x
  simp [rescaleKernel, div_div]

/-- Scale invariance (lemma:bk4_observer_metric_properties, clause 3): when
the kernel is pulled back along a nonzero coordinate rescaling, the metric
on the correspondingly rescaled vectors is exactly unchanged. -/
theorem observerMetric_rescale_invariant (K : Real → Real) (a v w : Real)
    (ha : a ≠ 0) :
    observerMetric (rescaleKernel a K) (a * v) (a * w) =
      observerMetric K v w := by
  simp [observerMetric, rescaleKernel, ha]

/- ================================================================
   theorem:bk4_fuzzy_symbolic_geometry_theorem,
   theorem:bk4_restated_fuzzy_symbolic_geometry_theorem,
   corollary:bk4_smoothness_as_epistemic_phenomenon
   ================================================================ -/

/-- Chart convergence yields an observer-relative differentiable structure
(the shared consequence-2 content of theorem:bk4_fuzzy_symbolic_geometry_theorem
and theorem:bk4_restated_fuzzy_symbolic_geometry_theorem), re-read per the
`FracturedAtlas` license: the "chart representations converge" hypothesis
becomes `Glued C`, a NAMED hypothesis consumed exactly where the source's
proof consumes chart compatibility, and pair-covering assembles a single
consistent geometry from it. -/
theorem chart_glued_yields_single_geometry {X : Type*} {C : ChartComplex X}
    (hG : Glued C) (hCov : PairCovers C) :
    ∃ D : X → X → Real, Consistent C D :=
  consistent_of_glued hG hCov

/-- The iff-strengthening of the same content: a single observer-relative
geometry exists exactly when the chart complex is glued (given
pair-covering) -- the precise sense in which "the original symbolic system
admits an observer-relative [resp. pulled-back `C^k`] differentiable
structure" in both theorem statements. -/
theorem chart_geometry_exists_iff_glued {X : Type*} {C : ChartComplex X}
    (hCov : PairCovers C) :
    (∃ D : X → X → Real, Consistent C D) ↔ Glued C :=
  single_geometry_iff_glued hCov

/-- corollary:bk4_smoothness_as_epistemic_phenomenon's claim that different
observers may perceive different differentiable structures on the same
underlying symbolic system is exactly the dual-horizon fracture instance:
the same carrier (the depth line), two charts (identity vs. resolution-
quotient coordinates), and -- for any positive resolution floor -- no single
reconciling geometry. -/
theorem dual_horizon_no_single_smoothness {eps : Real} (heps : 0 < eps) :
    ¬ ∃ D : Real → Real → Real, Consistent (dualHorizon eps) D :=
  no_single_geometry_for_dual_horizon heps

/- ================================================================
   corollary:bk4_fuzzy_multivariable_chain, corollary:bk4_emergence_of_classical_ge
   ================================================================ -/

/-- The stated Frobenius-norm bound of corollary:bk4_fuzzy_multivariable_chain,
kept as a structure field (the Jacobians of `f` and `g` and the coupling
tensor's norm are not independently modeled; only the stated inequality
relating them to the observer's resolution threshold is). -/
structure JacobianChainBound where
  epsO : Real
  epsO_nonneg : 0 ≤ epsO
  jacF : Real
  jacF_nonneg : 0 ≤ jacF
  jacG : Real
  jacG_nonneg : 0 ≤ jacG
  tNorm : Real
  tNorm_nonneg : 0 ≤ tNorm
  tNorm_bound : tNorm ≤ epsO ^ ((3 : Real) / 2) * Real.sqrt (jacF ^ 2 + jacG ^ 2)

/-- At the unbounded-observer idealization (`epsO = 0`), the coupling tensor
is forced to vanish: the composite fuzzy Jacobian collapses to the exact
classical chain rule. This is the honest algebraic kernel shared by
corollary:bk4_fuzzy_multivariable_chain and the classical-geometry limit
claimed narratively in corollary:bk4_emergence_of_classical_ge. -/
theorem jacobianChain_idealized_forces_zero_tensor (b : JacobianChainBound)
    (h0 : b.epsO = 0) : b.tNorm = 0 := by
  have hz : b.epsO ^ ((3 : Real) / 2) = 0 := by
    rw [h0]; exact Real.zero_rpow (by norm_num)
  have hbound := b.tNorm_bound
  rw [hz, zero_mul] at hbound
  linarith [b.tNorm_nonneg]

/- ================================================================
   theorem:bk4_fuzzy_exponential_rule, theorem:bk4_fuzzy_logarithmic_rule,
   theorem:bk4_fuzzy_jacobian, theorem:bk4_fuzzy_divergence,
   definition:bk4_symbolic_vector_field, definition:bk4_fuzzy_vector_field,
   definition:bk4_fuzzy_integral_operator, definition:bk4_symbolic_memory_distortion,
   theorem:bk4_fuzzy_fundamental, definition:bk4_symbolic_holonomy_term,
   definition:bk4_symbolic_covariant, theorem:bk4_symbolic_stokes,
   definition:bk4_fuzzy_divergence_operator, definition:bk4_fuzzy_curl_operator,
   theorem:bk4_fuzzy_divergence_theorem, theorem:bk4_fuzzy_curl_theorem,
   theorem:bk4_fuzzy_helmholtz_decomposition
   ================================================================ -/

/-- The one honest kernel shared by every "observer rule = classical rule +
observer correction term" identity in this book (the exponential,
logarithmic, Jacobian, divergence, Lie-derivative/vector-field, integral,
covariant-derivative, Stokes, divergence-theorem, curl-theorem, and
Helmholtz-decomposition anchors listed above, and the Fuzzy Fundamental
Theorem of Calculus's two clauses), extending Book VIII's `frameResidual`
pattern from real-valued functions to an arbitrary additive group so that it
applies uniformly whether the "classical value" and "correction" live in
`ℝ`, `ℂ` (the curl operator's `i A_O ∧ ω_V` term), or a space of matrices
(the Jacobian's correction matrix): given the anchor's own defining equation
`observerValue = classicalValue + correction`, the correction term vanishes
exactly when the observer rule collapses to the classical rule. Each
anchor's own three quantities are what its stated equation names; no
separate boilerplate theorem is needed per anchor once they are read as
instances of this one equivalence. -/
theorem observer_correction_zero_iff_classical {M : Type*} [AddGroup M]
    (observerValue classicalValue correction : M)
    (heq : observerValue = classicalValue + correction) :
    correction = 0 ↔ observerValue = classicalValue := by
  constructor
  · intro h
    rw [heq, h, add_zero]
  · intro h
    have hc : classicalValue + correction = classicalValue + 0 := by
      rw [add_zero, ← heq, h]
    exact add_left_cancel hc

/- ================================================================
   theorem:bk4_multiplication_to_curvature
   ================================================================ -/

abbrev CrossErrorMatrix := Matrix (Fin 2) (Fin 2) ℝ

/-- A scalar multiplicative cross-error as an upper elementary transport. -/
def crossErrorTransport (c : ℝ) : CrossErrorMatrix :=
  Matrix.single 0 1 c

/-- The lower elementary context transport paired with a cross-error. -/
def contextTransport : CrossErrorMatrix :=
  Matrix.single 1 0 1

/-- A nonzero cross-error produces genuinely noncommuting transports. -/
theorem crossErrorTransport_noncommute {c : ℝ} (hc : c ≠ 0) :
    crossErrorTransport c * contextTransport ≠
      contextTransport * crossErrorTransport c := by
  intro h
  have h00 := congrFun (congrFun h 0) 0
  apply hc
  simpa [crossErrorTransport, contextTransport, Matrix.mul_apply,
    Matrix.single] using h00

/-- **theorem:bk4_multiplication_to_curvature**, discrete positive kernel:
a nonzero contextual cross-difference generates explicit noncommuting
transports and therefore nonzero holonomy at every nonzero scale. This
proves the cross-error-to-curvature arrow; it does not assert that the
Scholium's emergence premises alone supply the cross-error. -/
theorem contextual_crossError_induces_curvature
    (U : ℝ → ℝ → ℝ) {ξ χ ε : ℝ}
    (hcross : ForcingAnalysis.ScholiumC.crossTerm U ξ χ ≠ 0)
    (hε : ε ≠ 0) :
    ForcingAnalysis.Atlas.routeAB ε
        (crossErrorTransport (ForcingAnalysis.ScholiumC.crossTerm U ξ χ))
        contextTransport ≠
      ForcingAnalysis.Atlas.routeBA ε
        (crossErrorTransport (ForcingAnalysis.ScholiumC.crossTerm U ξ χ))
        contextTransport :=
  ForcingAnalysis.Atlas.non_euclidean_necessity
    (crossErrorTransport_noncommute hcross) hε
/-- Vanishing contextual cross-difference is equivalent to additive
separability into independent state and context contributions. -/
theorem crossTerm_zero_iff_additively_separable
    {V Ctx W : Type*} [AddCommGroup V] [AddCommGroup Ctx] [AddCommGroup W]
    (U : V → Ctx → W) :
    (∀ ξ χ, ForcingAnalysis.ScholiumC.crossTerm U ξ χ = 0) ↔
      ∃ f : V → W, ∃ g : Ctx → W,
        U = fun ξ χ => f ξ + g χ := by
  constructor
  · intro h
    refine ⟨fun ξ => U ξ 0, fun χ => U 0 χ - U 0 0, ?_⟩
    funext ξ χ
    have hξχ := h ξ χ
    dsimp [ForcingAnalysis.ScholiumC.crossTerm] at hξχ ⊢
    rw [← sub_eq_zero]
    abel_nf at hξχ ⊢
    exact hξχ
  · rintro ⟨f, g, rfl⟩ ξ χ
    exact ForcingAnalysis.ScholiumC.crossTerm_separable_eq_zero f g ξ χ

/-- Contextual structural growth, read as failure of additive separation,
is exactly the existence of a nonzero multiplicative cross-error. -/
theorem nonseparable_iff_exists_crossError
    {V Ctx W : Type*} [AddCommGroup V] [AddCommGroup Ctx] [AddCommGroup W]
    (U : V → Ctx → W) :
    (¬ ∃ f : V → W, ∃ g : Ctx → W,
        U = fun ξ χ => f ξ + g χ) ↔
      ∃ ξ χ, ForcingAnalysis.ScholiumC.crossTerm U ξ χ ≠ 0 := by
  constructor
  · intro hnonsep
    by_contra hcross
    push Not at hcross
    exact hnonsep ((crossTerm_zero_iff_additively_separable U).mp hcross)
  · rintro ⟨ξ, χ, hcross⟩ ⟨f, g, rfl⟩
    exact hcross
      (ForcingAnalysis.ScholiumC.crossTerm_separable_eq_zero f g ξ χ)

/-- Full typed Book 4 bridge: a contextually nonseparable real update has
some nonzero cross-error, which generates nonzero holonomy at every nonzero
scale. This replaces the source's unconnected dimension inequality by the
precise structural-growth property actually consumed by the proof. -/
theorem contextualStructuralGrowth_induces_curvature
    (U : ℝ → ℝ → ℝ) {ε : ℝ}
    (hgrowth : ¬ ∃ f : ℝ → ℝ, ∃ g : ℝ → ℝ,
      U = fun ξ χ => f ξ + g χ)
    (hε : ε ≠ 0) :
    ∃ ξ χ,
      ForcingAnalysis.Atlas.routeAB ε
          (crossErrorTransport (ForcingAnalysis.ScholiumC.crossTerm U ξ χ))
          contextTransport ≠
        ForcingAnalysis.Atlas.routeBA ε
          (crossErrorTransport (ForcingAnalysis.ScholiumC.crossTerm U ξ χ))
          contextTransport := by
  obtain ⟨ξ, χ, hcross⟩ :=
    (nonseparable_iff_exists_crossError U).mp hgrowth
  exact ⟨ξ, χ, contextual_crossError_induces_curvature U hcross hε⟩
end ForcingAnalysis.Book4D
