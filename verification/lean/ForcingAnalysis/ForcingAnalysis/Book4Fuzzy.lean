/-
Book4Fuzzy.lean — observer-relative smoothness, drift/reflection
compatibility, observer locality, and self-authorship (book4 fuzzy
geometry).

Sources (Principia Book 4, verbatim; sha-bound in bindings.json):

  lemma:bk4_local_differentiability_substituted_drift /
  lemma:bk4_observer_relative_smoothness — the substituted drift field
    ũ_*(D) = δ_O u ∘ D ∘ u⁻¹ is observer-differentiable.
  theorem:bk4_compatibility_drift_reflective_operations — the
    drift-reflection operation D∘R induces an observer-differentiable
    field under substitution.
  axiom:bk4_observer_locality — observer kernels have support inside
    B_O × B_O.
  theorem:bk4_self_authorship_and_freedom — the constraint sequence
    L_{n+1} = D_i(L_n, g_n) converges to a fixed-point constraint map
    L_∞ with U(I) = Fix(L_∞).

KERNELS (honest):

  * `substituted_drift_continuous` — the pushforward u_*(D) = u ∘ D ∘ u⁻¹
    is continuous when u, D, u⁻¹ are: observer-relative smoothness is
    inherited from the substitution and the base operator, via
    composition (the differentiable-manifold form stays open).
  * `drift_reflection_continuous` / `substituted_drift_reflection_continuous`
    — the composed drift-reflection operation, and its pushforward,
    stay continuous: compatibility with drift-reflective operations.
  * `local_kernel_vanishes_offdiagonal` — an observer kernel supported
    in B_O × B_O vanishes outside it: locality made operational.
  * `self_authorship_fixed_point` — the constraint-refinement sequence
    converges to a unique fixed-point constraint map (contraction
    form): complete self-authorship as the fixed locus L_∞.
-/

import Mathlib
import Mathlib.Geometry.Manifold.VectorBundle.Tangent
import Mathlib.Geometry.Manifold.VectorBundle.ContMDiffSection

namespace ForcingAnalysis.Book4Fz

open scoped NNReal
open scoped ContDiff
open scoped Manifold

/-! ### Observer-relative smoothness by composition -/

variable {S T : Type*} [TopologicalSpace S] [TopologicalSpace T]

/-- **lemma:bk4_observer_relative_smoothness**: the substituted drift
field u_*(D) = u ∘ D ∘ u⁻¹ is continuous when the substitution u, the
base drift D, and the inverse u⁻¹ are — observer-relative smoothness is
inherited by composition. The differentiable-manifold form stays open. -/
theorem substituted_drift_continuous {u : S → T} {D : S → S} {uinv : T → S}
    (hu : Continuous u) (hD : Continuous D) (huinv : Continuous uinv) :
    Continuous (u ∘ D ∘ uinv) :=
  hu.comp (hD.comp huinv)

/-- **theorem:bk4_compatibility_drift_reflective_operations** (base):
the drift-reflection operation D ∘ R is continuous when both operators
are. -/
theorem drift_reflection_continuous {D R : S → S}
    (hD : Continuous D) (hR : Continuous R) : Continuous (D ∘ R) :=
  hD.comp hR

/-- **theorem:bk4_compatibility_drift_reflective_operations**
(pushforward): the substituted drift-reflection field u_*(D ∘ R) stays
continuous — the observer-relative differentiable structure is
preserved. -/
theorem substituted_drift_reflection_continuous {u : S → T} {D R : S → S}
    {uinv : T → S} (hu : Continuous u) (hD : Continuous D)
    (hR : Continuous R) (huinv : Continuous uinv) :
    Continuous (u ∘ (D ∘ R) ∘ uinv) :=
  hu.comp ((hD.comp hR).comp huinv)

/-! ### Differentiable observer geometry and exact Jacobians -/

variable {E F : Type*}
  [NormedAddCommGroup E] [NormedSpace ℝ E]
  [NormedAddCommGroup F] [NormedSpace ℝ F]

/-- The observer-substituted drift is genuinely Fréchet differentiable when
the chart, drift, and inverse chart are. This upgrades the earlier
topological kernel without assuming a manifold atlas. -/
theorem substituted_drift_differentiable
    {u : E → F} {D : E → E} {uinv : F → E}
    (hu : Differentiable ℝ u) (hD : Differentiable ℝ D)
    (huinv : Differentiable ℝ uinv) :
    Differentiable ℝ (u ∘ D ∘ uinv) :=
  hu.comp (hD.comp huinv)

/-- Exact chain-rule Jacobian for observer substitution:
d(u ∘ D ∘ u⁻¹) = du ∘ dD ∘ du⁻¹ at corresponding points. -/
theorem hasFDerivAt_substituted_drift
    {u : E → F} {D : E → E} {uinv : F → E}
    {U : E →L[ℝ] F} {A : E →L[ℝ] E} {V : F →L[ℝ] E} {y : F}
    (hu : HasFDerivAt u U (D (uinv y)))
    (hD : HasFDerivAt D A (uinv y))
    (huinv : HasFDerivAt uinv V y) :
    HasFDerivAt (u ∘ D ∘ uinv) (U.comp (A.comp V)) y :=
  hu.comp y (hD.comp y huinv)

/-- Exact derivative of the drift-reflection composite. -/
theorem hasFDerivAt_drift_reflection
    {D R : E → E} {A P : E →L[ℝ] E} {x : E}
    (hD : HasFDerivAt D A (R x)) (hR : HasFDerivAt R P x) :
    HasFDerivAt (D ∘ R) (A.comp P) x :=
  hD.comp x hR

/-- The full observer-substituted drift-reflection Jacobian is the ordered
product du ∘ dD ∘ dR ∘ du⁻¹; order is retained rather than commuted. -/
theorem hasFDerivAt_substituted_drift_reflection
    {u : E → F} {D R : E → E} {uinv : F → E}
    {U : E →L[ℝ] F} {A P : E →L[ℝ] E} {V : F →L[ℝ] E} {y : F}
    (hu : HasFDerivAt u U (D (R (uinv y))))
    (hD : HasFDerivAt D A (R (uinv y)))
    (hR : HasFDerivAt R P (uinv y))
    (huinv : HasFDerivAt uinv V y) :
    HasFDerivAt (u ∘ (D ∘ R) ∘ uinv)
      (U.comp (A.comp (P.comp V))) y :=
  hu.comp y ((hD.comp (uinv y) hR).comp y huinv)

/-! ### Native manifold lifts of observer dynamics -/

variable {EM HM M EN HN N : Type*}
  [NormedAddCommGroup EM] [NormedSpace ℝ EM]
  [NormedAddCommGroup EN] [NormedSpace ℝ EN]
  [TopologicalSpace HM] [TopologicalSpace M]
  [TopologicalSpace HN] [TopologicalSpace N]
  {IM : ModelWithCorners ℝ EM HM} {IN : ModelWithCorners ℝ EN HN}
  [ChartedSpace HM M] [ChartedSpace HN N]

/-- Observer substitution lifts from model-space composition to a native
`C^n` map between manifolds. -/
theorem substituted_drift_contMDiff {n : ℕ∞ω}
    {u : M → N} {D : M → M} {uinv : N → M}
    (hu : ContMDiff IM IN n u) (hD : ContMDiff IM IM n D)
    (huinv : ContMDiff IN IM n uinv) :
    ContMDiff IN IN n (u ∘ D ∘ uinv) :=
  hu.comp (hD.comp huinv)

/-- At positive regularity, the lifted substituted drift is genuinely
manifold-differentiable. -/
theorem substituted_drift_mdifferentiable
    {u : M → N} {D : M → M} {uinv : N → M}
    (hu : ContMDiff IM IN 1 u) (hD : ContMDiff IM IM 1 D)
    (huinv : ContMDiff IN IM 1 uinv) :
    MDifferentiable IN IN (u ∘ D ∘ uinv) :=
  (substituted_drift_contMDiff hu hD huinv).mdifferentiable one_ne_zero

/-- The native manifold derivative of observer-substituted drift has the
same ordered three-factor chain rule as its Fréchet representative. -/
theorem mfderiv_substituted_drift
    {u : M → N} {D : M → M} {uinv : N → M} {y : N}
    (hu : MDifferentiableAt IM IN u (D (uinv y)))
    (hD : MDifferentiableAt IM IM D (uinv y))
    (huinv : MDifferentiableAt IN IM uinv y) :
    mfderiv IN IN (u ∘ D ∘ uinv) y =
      ((mfderiv IM IN u (D (uinv y))).comp
        (mfderiv IM IM D (uinv y))).comp
          (mfderiv IN IM uinv y) := by
  rw [mfderiv_comp y hu (hD.comp y huinv), mfderiv_comp y hD huinv]
  rfl
/-- Drift followed by reflection is `C^n` as a native manifold operation. -/
theorem drift_reflection_contMDiff {n : ℕ∞ω} {D R : M → M}
    (hD : ContMDiff IM IM n D) (hR : ContMDiff IM IM n R) :
    ContMDiff IM IM n (D ∘ R) :=
  hD.comp hR

/-- Observer-substituted drift–reflection is `C^n` on the observer
manifold, with no return to ambient-coordinate differentiability. -/
theorem substituted_drift_reflection_contMDiff {n : ℕ∞ω}
    {u : M → N} {D R : M → M} {uinv : N → M}
    (hu : ContMDiff IM IN n u) (hD : ContMDiff IM IM n D)
    (hR : ContMDiff IM IM n R) (huinv : ContMDiff IN IM n uinv) :
    ContMDiff IN IN n (u ∘ (D ∘ R) ∘ uinv) :=
  hu.comp ((hD.comp hR).comp huinv)

/-- The lifted drift–reflection derivative preserves the exact ordered
four-factor chain rule. -/
theorem mfderiv_substituted_drift_reflection
    {u : M → N} {D R : M → M} {uinv : N → M} {y : N}
    (hu : MDifferentiableAt IM IN u (D (R (uinv y))))
    (hD : MDifferentiableAt IM IM D (R (uinv y)))
    (hR : MDifferentiableAt IM IM R (uinv y))
    (huinv : MDifferentiableAt IN IM uinv y) :
    mfderiv IN IN (u ∘ (D ∘ R) ∘ uinv) y =
      ((mfderiv IM IN u (D (R (uinv y)))).comp
        ((mfderiv IM IM D (R (uinv y))).comp
          (mfderiv IM IM R (uinv y)))).comp
            (mfderiv IN IM uinv y) := by
  rw [mfderiv_comp y hu ((hD.comp (uinv y) hR).comp y huinv),
    mfderiv_comp y (hD.comp (uinv y) hR) huinv,
    mfderiv_comp (uinv y) hD hR]
  rfl
/-! ### Native tangent fields and controlled perturbation -/

/-- An observer vector field assigns a native mathlib tangent vector to
every manifold point. The dependent codomain prevents a vector based at one
state from being silently reused at another. -/
structure ObserverVectorField (IM : ModelWithCorners ℝ EM HM) where
  toFun : ∀ x : M, TangentSpace IM x

instance : CoeFun (ObserverVectorField (M := M) IM)
    (fun _ => ∀ x : M, TangentSpace IM x) :=
  ⟨ObserverVectorField.toFun⟩

/-- Apply a perturbation field with an explicit real amplitude. -/
noncomputable def controlledVectorFieldPerturbation (ε : ℝ)
    (V W : ObserverVectorField (M := M) IM) :
    ObserverVectorField (M := M) IM where
  toFun := fun x => V x + ε • W x

/-- Controlled perturbation is operational pointwise: the perturbing tangent
vector is scaled by exactly the declared amplitude. -/
theorem controlledVectorFieldPerturbation_apply (ε : ℝ)
    (V W : ObserverVectorField (M := M) IM) (x : M) :
    controlledVectorFieldPerturbation ε V W x = V x + ε • W x :=
  rfl

/-- Zero perturbation leaves the observer vector field unchanged. -/
theorem controlledVectorFieldPerturbation_zero
    (V W : ObserverVectorField (M := M) IM) :
    controlledVectorFieldPerturbation 0 V W = V := by
  cases V with
  | mk V =>
    cases W with
    | mk W =>
      simp [controlledVectorFieldPerturbation]

/-- Repeated perturbations in the same tangent direction add their
amplitudes; no hidden traversal is introduced between steps. -/
theorem controlledVectorFieldPerturbation_add (ε δ : ℝ)
    (V W : ObserverVectorField (M := M) IM) :
    controlledVectorFieldPerturbation δ
        (controlledVectorFieldPerturbation ε V W) W =
      controlledVectorFieldPerturbation (ε + δ) V W := by
  cases V with
  | mk V =>
    cases W with
    | mk W =>
      simp [controlledVectorFieldPerturbation, add_smul, add_assoc]
/-- A perturbation direction that vanishes at a state leaves the field
unchanged at that state, independently of amplitude. -/
theorem controlledVectorFieldPerturbation_eq_self_of_direction_zero
    (ε : ℝ) (V W : ObserverVectorField (M := M) IM) (x : M)
    (hW : W x = 0) :
    controlledVectorFieldPerturbation ε V W x = V x := by
  simp [controlledVectorFieldPerturbation, hW]

/-- At nonzero amplitude, observing no pointwise change is equivalent to the
perturbation direction itself vanishing there. This makes perturbation
control recognizable rather than imaginary. -/
theorem controlledVectorFieldPerturbation_eq_self_iff
    {ε : ℝ} (hε : ε ≠ 0) (V W : ObserverVectorField (M := M) IM) (x : M) :
    controlledVectorFieldPerturbation ε V W x = V x ↔ W x = 0 := by
  simp [controlledVectorFieldPerturbation, hε]
/-! ### Integral curves of observer vector fields -/

/-- A curve is an integral curve of an observer vector field when it is
manifold-differentiable at every time and its manifold velocity equals the
field at the current state. -/
def IsObserverIntegralCurve
    (V : ObserverVectorField (M := M) IM) (γ : ℝ → M) : Prop :=
  ∀ t, MDifferentiableAt (modelWithCornersSelf ℝ ℝ) IM γ t ∧
    mfderiv (modelWithCornersSelf ℝ ℝ) IM γ t (1 : ℝ) = V (γ t)

/-- Unfold the integral-curve contract at a particular time. -/
theorem isObserverIntegralCurve_iff
    (V : ObserverVectorField (M := M) IM) (γ : ℝ → M) :
    IsObserverIntegralCurve V γ ↔
      ∀ t, MDifferentiableAt (modelWithCornersSelf ℝ ℝ) IM γ t ∧
        mfderiv (modelWithCornersSelf ℝ ℝ) IM γ t (1 : ℝ) = V (γ t) :=
  Iff.rfl

/-- A controlled perturbation preserves an integral curve whenever its
direction vanishes along that curve. -/
theorem IsObserverIntegralCurve.controlledPerturbation_of_direction_zero
    {V W : ObserverVectorField (M := M) IM} {γ : ℝ → M}
    (hγ : IsObserverIntegralCurve V γ) (ε : ℝ)
    (hW : ∀ t, W (γ t) = 0) :
    IsObserverIntegralCurve (controlledVectorFieldPerturbation ε V W) γ := by
  intro t
  refine ⟨(hγ t).1, ?_⟩
  rw [(hγ t).2]
  exact (controlledVectorFieldPerturbation_eq_self_of_direction_zero
    ε V W (γ t) (hW t)).symm

/-- At nonzero amplitude, a curve solves both the original and perturbed
field equations exactly when the perturbation direction vanishes all along
the curve. -/
theorem observerIntegralCurve_perturbation_iff
    {V W : ObserverVectorField (M := M) IM} {γ : ℝ → M}
    (hγ : IsObserverIntegralCurve V γ) {ε : ℝ} (hε : ε ≠ 0) :
    IsObserverIntegralCurve (controlledVectorFieldPerturbation ε V W) γ ↔
      ∀ t, W (γ t) = 0 := by
  constructor
  · intro hpert t
    apply (controlledVectorFieldPerturbation_eq_self_iff hε V W (γ t)).mp
    rw [← (hγ t).2, ← (hpert t).2]
  · exact hγ.controlledPerturbation_of_direction_zero ε
/-! ### Observer flows and reachable perturbations -/

/-- A global observer flow packages an integral curve through every initial
state, identity at time zero, and the directed additive-time composition
law. Because time ranges over all reals, inverse-time laws are consequences
rather than additional assumptions. -/
structure IsObserverFlow
    (V : ObserverVectorField (M := M) IM) (Φ : ℝ → M → M) : Prop where
  integralCurve : ∀ x, IsObserverIntegralCurve V (fun t => Φ t x)
  zero_apply : ∀ x, Φ 0 x = x
  add_apply : ∀ s t x, Φ (s + t) x = Φ s (Φ t x)

/-- Every trajectory selected from an observer flow satisfies the native
manifold integral-curve equation. -/
theorem IsObserverFlow.isObserverIntegralCurve
    {V : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) (x : M) :
    IsObserverIntegralCurve V (fun t => Φ t x) :=
  hΦ.integralCurve x

/-- The time-zero slice of a flow is the identity function. -/
theorem IsObserverFlow.zero_eq_id
    {V : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) : Φ 0 = id := by
  funext x
  exact hΦ.zero_apply x

/-- The additive-time law composes in operational order: first evolve by
`t`, then by `s`. Over all real times this order alone does not create an
irreversible born arrow. -/
theorem IsObserverFlow.add_eq_comp
    {V : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) (s t : ℝ) :
    Φ (s + t) = Φ s ∘ Φ t := by
  funext x
  exact hΦ.add_apply s t x

/-- Negative time is a left inverse for a global real-time flow. -/
theorem IsObserverFlow.neg_comp_self
    {V : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) (t : ℝ) : Φ (-t) ∘ Φ t = id := by
  funext x
  change Φ (-t) (Φ t x) = x
  rw [← hΦ.add_apply (-t) t x, neg_add_cancel, hΦ.zero_apply]

/-- Negative time is also a right inverse for a global real-time flow. -/
theorem IsObserverFlow.self_comp_neg
    {V : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) (t : ℝ) : Φ t ∘ Φ (-t) = id := by
  funext x
  change Φ t (Φ (-t) x) = x
  rw [← hΦ.add_apply t (-t) x, add_neg_cancel, hΦ.zero_apply]

/-- Consequently every time slice of a global real-time observer flow is
bijective. Irreversibility therefore requires forward-only time or extra
recorded state, not merely the directed composition notation. -/
theorem IsObserverFlow.bijective
    {V : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) (t : ℝ) : Function.Bijective (Φ t) := by
  have hleft : Function.LeftInverse (Φ (-t)) (Φ t) := by
    intro x
    rw [← hΦ.add_apply (-t) t x, neg_add_cancel, hΦ.zero_apply]
  have hright : Function.RightInverse (Φ (-t)) (Φ t) := by
    intro x
    rw [← hΦ.add_apply t (-t) x, add_neg_cancel, hΦ.zero_apply]
  exact ⟨hleft.injective, hright.surjective⟩

/-! ### Cross-observer consistency of time -/

/-- Observer `N` consistently represents observer `M`'s evolution when
state transport `χ` intertwines their flows through a clock translation
`τ`. The clocks are not assumed equal. -/
def CrossObserverTimeConsistent {M N : Type*}
    (χ : M → N) (τ : ℝ → ℝ)
    (Φ : ℝ → M → M) (Ψ : ℝ → N → N) : Prop :=
  ∀ t x, χ (Φ t x) = Ψ (τ t) (χ x)

/-- Cross-observer consistency is reflexive with the identity state and
clock translations. -/
theorem crossObserverTimeConsistent_refl {M : Type*}
    (Φ : ℝ → M → M) :
    CrossObserverTimeConsistent id id Φ Φ := by
  intro t x
  rfl

/-- Consistent state and clock translations compose across a third
observer, giving the basic descent law for shared time. -/
theorem CrossObserverTimeConsistent.trans
    {M N P : Type*} {χ : M → N} {η : N → P}
    {τ σ : ℝ → ℝ} {Φ : ℝ → M → M}
    {Ψ : ℝ → N → N} {Ω : ℝ → P → P}
    (hMN : CrossObserverTimeConsistent χ τ Φ Ψ)
    (hNP : CrossObserverTimeConsistent η σ Ψ Ω) :
    CrossObserverTimeConsistent (η ∘ χ) (σ ∘ τ) Φ Ω := by
  intro t x
  exact congrArg η (hMN t x) |>.trans (hNP (τ t) (χ x))

/-- An invertible cross-observer consistency can be read in the reverse
direction. Together with reflexivity and composition, compatible observers
therefore form a concrete groupoid of state-and-clock translations. -/
theorem CrossObserverTimeConsistent.symm
    {M N : Type*} (χ : M ≃ N) (τ : ℝ ≃ ℝ)
    {Φ : ℝ → M → M} {Ψ : ℝ → N → N}
    (h : CrossObserverTimeConsistent χ τ Φ Ψ) :
    CrossObserverTimeConsistent χ.symm τ.symm Ψ Φ := by
  intro t y
  apply χ.injective
  simpa using (h (τ.symm t) (χ.symm y)).symm

/-- If shared states cover the second observer and its flow distinguishes
time parameters, consistency forces both observers to share time zero. -/
theorem CrossObserverTimeConsistent.reparam_zero
    {M N : Type*} {χ : M → N} {τ : ℝ → ℝ}
    {Φ : ℝ → M → M} {Ψ : ℝ → N → N}
    (h : CrossObserverTimeConsistent χ τ Φ Ψ)
    (hχ : Function.Surjective χ)
    (hΦ0 : ∀ x, Φ 0 x = x) (hΨ0 : ∀ y, Ψ 0 y = y)
    (hfaithful : Function.Injective Ψ) : τ 0 = 0 := by
  apply hfaithful
  funext y
  obtain ⟨x, rfl⟩ := hχ y
  rw [← h 0 x, hΦ0, hΨ0]

/-- Under the same shared-state and faithful-clock hypotheses, consistency
forces the clock translation to preserve time addition. -/
theorem CrossObserverTimeConsistent.reparam_add
    {M N : Type*} {χ : M → N} {τ : ℝ → ℝ}
    {Φ : ℝ → M → M} {Ψ : ℝ → N → N}
    (h : CrossObserverTimeConsistent χ τ Φ Ψ)
    (hχ : Function.Surjective χ)
    (hΦadd : ∀ s t x, Φ (s + t) x = Φ s (Φ t x))
    (hΨadd : ∀ s t y, Ψ (s + t) y = Ψ s (Ψ t y))
    (hfaithful : Function.Injective Ψ) (s t : ℝ) :
    τ (s + t) = τ s + τ t := by
  apply hfaithful
  funext y
  obtain ⟨x, rfl⟩ := hχ y
  calc
    Ψ (τ (s + t)) (χ x) = χ (Φ (s + t) x) := (h (s + t) x).symm
    _ = χ (Φ s (Φ t x)) := congrArg χ (hΦadd s t x)
    _ = Ψ (τ s) (χ (Φ t x)) := h s (Φ t x)
    _ = Ψ (τ s) (Ψ (τ t) (χ x)) := congrArg (Ψ (τ s)) (h t x)
    _ = Ψ (τ s + τ t) (χ x) := (hΨadd (τ s) (τ t) (χ x)).symm

/-- A flow of `V` is also a flow of `V + εW` when `W` vanishes at every
state reachable by that flow. -/
theorem IsObserverFlow.controlledPerturbation_of_reachable_zero
    {V W : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) (ε : ℝ)
    (hW : ∀ t x, W (Φ t x) = 0) :
    IsObserverFlow (controlledVectorFieldPerturbation ε V W) Φ where
  integralCurve x :=
    (hΦ.integralCurve x).controlledPerturbation_of_direction_zero ε
      (fun t => hW t x)
  zero_apply := hΦ.zero_apply
  add_apply := hΦ.add_apply

/-- At nonzero amplitude, preserving the complete flow is equivalent to the
perturbation direction vanishing on the entire reachable set. -/
theorem observerFlow_perturbation_iff
    {V W : ObserverVectorField (M := M) IM} {Φ : ℝ → M → M}
    (hΦ : IsObserverFlow V Φ) {ε : ℝ} (hε : ε ≠ 0) :
    IsObserverFlow (controlledVectorFieldPerturbation ε V W) Φ ↔
      ∀ t x, W (Φ t x) = 0 := by
  constructor
  · intro hpert t x
    exact ((observerIntegralCurve_perturbation_iff
      (hΦ.integralCurve x) hε).mp (hpert.integralCurve x)) t
  · exact hΦ.controlledPerturbation_of_reachable_zero ε
/-! ### Chart conjugacy and observer-independent iteration -/

/-- An invertible observer substitution conjugates the substituted drift to
the original drift exactly. -/
theorem substituted_drift_conjugacy
    {u : S → T} {uinv : T → S} (D : S → S)
    (hleft : ∀ x, uinv (u x) = x) (x : S) :
    (u ∘ D ∘ uinv) (u x) = u (D x) := by
  simp [Function.comp_apply, hleft x]

/-- Conjugacy persists through every finite iterate: changing observer chart
does not alter the underlying drift orbit. -/
theorem substituted_drift_iterate_conjugacy
    {u : S → T} {uinv : T → S} (D : S → S)
    (hleft : ∀ x, uinv (u x) = x) (x : S) :
    ∀ n, ((u ∘ D ∘ uinv)^[n]) (u x) = u ((D^[n]) x) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', Function.iterate_succ_apply', ih]
      exact substituted_drift_conjugacy D hleft ((D^[n]) x)

/-! ### Observer tangent charts and overlap compatibility -/

/-- A chart contract sufficient for observer-relative tangent geometry:
the coordinate equivalence has an explicitly certified continuous-linear
derivative at every point, and the inverse chart has the inverse derivative.
This is the local model-space layer beneath a full manifold atlas. -/
structure ObserverTangentChart
    (E F : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] where
  chart : E ≃ F
  tangent : E → E ≃L[ℝ] F
  chart_hasFDerivAt :
    ∀ x, HasFDerivAt chart (tangent x).toContinuousLinearMap x
  inverse_hasFDerivAt :
    ∀ x, HasFDerivAt chart.symm
      (tangent x).symm.toContinuousLinearMap (chart x)

/-- Coordinate change from observer chart c to observer chart d. -/
def observerTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : ObserverTangentChart E F) (d : ObserverTangentChart E G) :
    F → G :=
  d.chart ∘ c.chart.symm

/-- Tangent-vector transport across the overlap of two observer charts. -/
def observerTangentTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : ObserverTangentChart E F) (d : ObserverTangentChart E G)
    (x : E) : F →L[ℝ] G :=
  (d.tangent x).toContinuousLinearMap.comp
    (c.tangent x).symm.toContinuousLinearMap

/-- The transition-map Jacobian is exactly the tangent overlap transport. -/
theorem hasFDerivAt_observerTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : ObserverTangentChart E F) (d : ObserverTangentChart E G)
    (x : E) :
    HasFDerivAt (observerTransition c d)
      (observerTangentTransition c d x) (c.chart x) := by
  have hd : HasFDerivAt d.chart
      (d.tangent x).toContinuousLinearMap (c.chart.symm (c.chart x)) := by
    simpa using d.chart_hasFDerivAt x
  exact hd.comp (c.chart x) (c.inverse_hasFDerivAt x)

/-- Chart transitions satisfy the three-observer cocycle law on overlaps. -/
theorem observerTransition_cocycle
    {E F G H : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    (c : ObserverTangentChart E F) (d : ObserverTangentChart E G)
    (e : ObserverTangentChart E H) (x : E) :
    observerTransition d e (observerTransition c d (c.chart x)) =
      observerTransition c e (c.chart x) := by
  simp [observerTransition, Function.comp_apply]

/-- Tangent transports satisfy the matching linear cocycle: transport from
c to d and then d to e equals direct transport from c to e. -/
theorem observerTangentTransition_cocycle
    {E F G H : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    (c : ObserverTangentChart E F) (d : ObserverTangentChart E G)
    (e : ObserverTangentChart E H) (x : E) :
    (observerTangentTransition d e x).comp
        (observerTangentTransition c d x) =
      observerTangentTransition c e x := by
  ext v
  simp [observerTangentTransition]

/-- Self-transition acts as identity on observer tangent vectors. -/
theorem observerTangentTransition_self
    {E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (c : ObserverTangentChart E F) (x : E) :
    observerTangentTransition c c x = ContinuousLinearMap.id ℝ F := by
  ext v
  simp [observerTangentTransition]

/-! ### Local chart domains and overlap membership -/

/-- A genuinely local observer chart. Forward and inverse functions are
required to invert one another only on their declared source and target;
their tangent equivalence and derivative certificates are likewise indexed
by source membership. -/
structure LocalObserverTangentChart
    (E F : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] where
  source : Set E
  target : Set F
  toFun : E → F
  invFun : F → E
  map_source : Set.MapsTo toFun source target
  map_target : Set.MapsTo invFun target source
  left_inv : Set.LeftInvOn invFun toFun source
  right_inv : Set.RightInvOn invFun toFun target
  tangent : E → E ≃L[ℝ] F
  chart_hasFDerivAt :
    ∀ x, x ∈ source →
      HasFDerivAt toFun (tangent x).toContinuousLinearMap x
  inverse_hasFDerivAt :
    ∀ x, x ∈ source →
      HasFDerivAt invFun
        (tangent x).symm.toContinuousLinearMap (toFun x)

/-- The base-space region on which two local observer charts overlap. -/
def localObserverOverlap
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) : Set E :=
  c.source ∩ d.source

/-- The overlap as seen in the coordinates of the first observer. -/
def localObserverCoordinateOverlap
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) : Set F :=
  c.toFun '' localObserverOverlap c d

/-- Local coordinate transition, meaningful on the declared coordinate
overlap even though represented by globally defined extension functions. -/
def localObserverTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) : F → G :=
  d.toFun ∘ c.invFun

/-- Linear transport of tangent coordinates on a local overlap. -/
def localObserverTangentTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) (x : E) : F →L[ℝ] G :=
  (d.tangent x).toContinuousLinearMap.comp
    (c.tangent x).symm.toContinuousLinearMap

/-- A point in the base overlap has a coordinate representative in the
first chart's coordinate overlap. -/
theorem localObserver_coordinate_mem_overlap
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) {x : E}
    (hx : x ∈ localObserverOverlap c d) :
    c.toFun x ∈ localObserverCoordinateOverlap c d :=
  ⟨x, hx, rfl⟩

/-- Exact coordinate-overlap membership: a coordinate belongs to the
c-to-d overlap iff it is valid in c and its decoded base point belongs to
d's source. -/
theorem localObserverCoordinateOverlap_iff
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) {y : F} :
    y ∈ localObserverCoordinateOverlap c d ↔
      y ∈ c.target ∧ c.invFun y ∈ d.source := by
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact ⟨c.map_source hx.1, by simpa [c.left_inv hx.1] using hx.2⟩
  · rintro ⟨hy, hd⟩
    refine ⟨c.invFun y, ⟨c.map_target hy, hd⟩, ?_⟩
    exact c.right_inv hy

/-- Transitioning an overlap coordinate lands inside the second chart's
declared target. -/
theorem localObserverTransition_mem_target
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) {x : E}
    (hx : x ∈ localObserverOverlap c d) :
    localObserverTransition c d (c.toFun x) ∈ d.target := by
  simpa [localObserverTransition, Function.comp_apply, c.left_inv hx.1]
    using d.map_source hx.2

/-- On an actual overlap point, the derivative of the local coordinate
transition is exactly the declared tangent transport. -/
theorem hasFDerivAt_localObserverTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) {x : E}
    (hx : x ∈ localObserverOverlap c d) :
    HasFDerivAt (localObserverTransition c d)
      (localObserverTangentTransition c d x) (c.toFun x) := by
  have hd : HasFDerivAt d.toFun
      (d.tangent x).toContinuousLinearMap (c.invFun (c.toFun x)) := by
    simpa [c.left_inv hx.1] using d.chart_hasFDerivAt x hx.2
  exact hd.comp (c.toFun x) (c.inverse_hasFDerivAt x hx.1)

/-- Local transitions obey the three-chart cocycle exactly at points in the
triple overlap. -/
theorem localObserverTransition_cocycle
    {E F G H : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G)
    (e : LocalObserverTangentChart E H) {x : E}
    (hx : x ∈ c.source ∩ d.source ∩ e.source) :
    localObserverTransition d e
        (localObserverTransition c d (c.toFun x)) =
      localObserverTransition c e (c.toFun x) := by
  simp [localObserverTransition, Function.comp_apply,
    c.left_inv hx.1.1, d.left_inv hx.1.2]

/-- The tangent transition cocycle holds on the same triple overlap, giving
a well-defined transport contract for the observer-relative tangent bundle. -/
theorem localObserverTangentTransition_cocycle
    {E F G H : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G)
    (e : LocalObserverTangentChart E H) {x : E}
    (_hx : x ∈ c.source ∩ d.source ∩ e.source) :
    (localObserverTangentTransition d e x).comp
        (localObserverTangentTransition c d x) =
      localObserverTangentTransition c e x := by
  ext v
  simp [localObserverTangentTransition]

/-! ### Open observer charts and covering atlases -/

/-- A topological observer tangent chart based on mathlib's native local
homeomorphism. Source and target openness, restricted inverses, and local
continuity are inherited directly from the topology library. -/
structure TopologicalObserverTangentChart
    (E F : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] where
  localHomeomorph : OpenPartialHomeomorph E F
  tangent : E → E ≃L[ℝ] F
  chart_hasFDerivAt :
    ∀ x, x ∈ localHomeomorph.source →
      HasFDerivAt localHomeomorph
        (tangent x).toContinuousLinearMap x
  inverse_hasFDerivAt :
    ∀ x, x ∈ localHomeomorph.source →
      HasFDerivAt localHomeomorph.symm
        (tangent x).symm.toContinuousLinearMap (localHomeomorph x)

/-- Forgetting native topology yields the earlier explicit local chart
contract, so all overlap-membership and tangent-cocycle theorems apply. -/
def TopologicalObserverTangentChart.toLocal
    {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (c : TopologicalObserverTangentChart E F) :
    LocalObserverTangentChart E F where
  source := c.localHomeomorph.source
  target := c.localHomeomorph.target
  toFun := c.localHomeomorph
  invFun := c.localHomeomorph.symm
  map_source := fun _ hx => c.localHomeomorph.map_source hx
  map_target := fun _ hx => c.localHomeomorph.map_target hx
  left_inv := fun _ hx => c.localHomeomorph.left_inv hx
  right_inv := fun _ hx => c.localHomeomorph.right_inv hx
  tangent := c.tangent
  chart_hasFDerivAt := c.chart_hasFDerivAt
  inverse_hasFDerivAt := c.inverse_hasFDerivAt

/-- Pairwise base overlap of native topological observer charts is open. -/
theorem topologicalObserverOverlap_isOpen
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : TopologicalObserverTangentChart E F)
    (d : TopologicalObserverTangentChart E G) :
    IsOpen (localObserverOverlap c.toLocal d.toLocal) :=
  c.localHomeomorph.open_source.inter d.localHomeomorph.open_source

/-- The overlap seen in the first chart's coordinates is open as well. -/
theorem topologicalObserverCoordinateOverlap_isOpen
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : TopologicalObserverTangentChart E F)
    (d : TopologicalObserverTangentChart E G) :
    IsOpen (localObserverCoordinateOverlap c.toLocal d.toLocal) := by
  change IsOpen
    (c.localHomeomorph ''
      (c.localHomeomorph.source ∩ d.localHomeomorph.source))
  exact c.localHomeomorph.isOpen_image_source_inter
    d.localHomeomorph.open_source

/-- A fixed-model observer atlas is a family of topological tangent charts
whose open sources cover the entire state space. -/
structure TopologicalObserverTangentAtlas
    (ι E F : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F] where
  chart : ι → TopologicalObserverTangentChart E F
  covers : ∀ x : E, ∃ i, x ∈ (chart i).localHomeomorph.source

/-- The atlas source family has union equal to the whole observer space. -/
theorem TopologicalObserverTangentAtlas.iUnion_source_eq_univ
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) :
    (⋃ i, (A.chart i).localHomeomorph.source) = Set.univ := by
  apply Set.eq_univ_of_forall
  intro x
  rcases A.covers x with ⟨i, hi⟩
  exact Set.mem_iUnion.mpr ⟨i, hi⟩

/-- Every point has an open chart-source neighborhood from the atlas. -/
theorem TopologicalObserverTangentAtlas.exists_chart_mem_nhds
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) (x : E) :
    ∃ i, (A.chart i).localHomeomorph.source ∈ nhds x := by
  rcases A.covers x with ⟨i, hi⟩
  exact ⟨i, (A.chart i).localHomeomorph.open_source.mem_nhds hi⟩

/-- Any two charts in the atlas inherit open coordinate overlaps. -/
theorem TopologicalObserverTangentAtlas.coordinateOverlap_isOpen
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) (i j : ι) :
    IsOpen (localObserverCoordinateOverlap
      (A.chart i).toLocal (A.chart j).toLocal) :=
  topologicalObserverCoordinateOverlap_isOpen (A.chart i) (A.chart j)

/-! ### Assembly into mathlib's manifold hierarchy -/

/-- Choose, at every observer state, one covering chart from the atlas and
package the entire family as mathlib's native `ChartedSpace`. The definition
is noncomputable only because a preferred chart is selected from the cover. -/
@[implicit_reducible] noncomputable def TopologicalObserverTangentAtlas.toChartedSpace
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) : ChartedSpace F E where
  atlas := Set.range (fun i => (A.chart i).localHomeomorph)
  chartAt := fun x => (A.chart (Classical.choose (A.covers x))).localHomeomorph
  mem_chart_source := fun x => Classical.choose_spec (A.covers x)
  chart_mem_atlas := fun x =>
    ⟨Classical.choose (A.covers x), rfl⟩

/-- The native atlas of the assembled charted space is exactly the supplied
family of observer charts. -/
theorem TopologicalObserverTangentAtlas.atlas_eq_range
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) :
    @atlas F _ E _ A.toChartedSpace =
      Set.range (fun i => (A.chart i).localHomeomorph) :=
  rfl

/-- The preferred mathlib chart selected at a point contains that point in
its open source. This is the covering condition after assembly. -/
theorem TopologicalObserverTangentAtlas.mem_chartAt_source
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) (x : E) :
    x ∈ (@chartAt F _ E _ A.toChartedSpace x).source :=
  Classical.choose_spec (A.covers x)

/-- An assembled observer atlas is a genuine topological manifold in
mathlib (`C^0`, with the boundaryless self-model). Higher `C^n` assembly
requires continuous higher transition derivatives, which is deliberately a
separate contract from the pointwise Jacobians above. -/
theorem TopologicalObserverTangentAtlas.isManifold_zero
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : TopologicalObserverTangentAtlas ι E F) :
    @IsManifold ℝ _ F _ _ F _ (modelWithCornersSelf ℝ F) 0 E _
      A.toChartedSpace := by
  letI : ChartedSpace F E := A.toChartedSpace
  infer_instance
/-- The computed Fréchet derivative of a local coordinate transition is the
same tangent transport already used by the overlap cocycle. -/
theorem fderiv_localObserverTransition
    {E F G : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    [NormedAddCommGroup G] [NormedSpace ℝ G]
    (c : LocalObserverTangentChart E F)
    (d : LocalObserverTangentChart E G) {x : E}
    (hx : x ∈ localObserverOverlap c d) :
    fderiv ℝ (localObserverTransition c d) (c.toFun x) =
      localObserverTangentTransition c d x :=
  (hasFDerivAt_localObserverTransition c d hx).fderiv

/-- Chartwise `C^1` data: both each chart and its inverse are continuously
differentiable wherever the chart is valid. Pairwise transition regularity
will be derived, rather than supplied independently. -/
structure C1ObserverTangentAtlas
    (ι E F : Type*)
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    extends TopologicalObserverTangentAtlas ι E F where
  chart_contDiffAt :
    ∀ i x, x ∈ (toTopologicalObserverTangentAtlas.chart i).localHomeomorph.source →
      ContDiffAt ℝ 1
        (toTopologicalObserverTangentAtlas.chart i).localHomeomorph x
  inverse_contDiffAt :
    ∀ i x, x ∈ (toTopologicalObserverTangentAtlas.chart i).localHomeomorph.source →
      ContDiffAt ℝ 1
        (toTopologicalObserverTangentAtlas.chart i).localHomeomorph.symm
        ((toTopologicalObserverTangentAtlas.chart i).localHomeomorph x)

/-- Chartwise `C^1` regularity forces every coordinate transition to be
`C^1` on its entire open overlap. -/
theorem C1ObserverTangentAtlas.localTransition_contDiffOn
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : C1ObserverTangentAtlas ι E F) (i j : ι) :
    ContDiffOn ℝ 1
      (localObserverTransition
        (A.toTopologicalObserverTangentAtlas.chart i).toLocal
        (A.toTopologicalObserverTangentAtlas.chart j).toLocal)
      (localObserverCoordinateOverlap
        (A.toTopologicalObserverTangentAtlas.chart i).toLocal
        (A.toTopologicalObserverTangentAtlas.chart j).toLocal) := by
  let c := A.toTopologicalObserverTangentAtlas.chart i
  let d := A.toTopologicalObserverTangentAtlas.chart j
  rw [(topologicalObserverCoordinateOverlap_isOpen c d).contDiffOn_iff]
  intro y hy
  have hy' : y ∈ c.localHomeomorph.target ∧
      c.localHomeomorph.symm y ∈ d.localHomeomorph.source :=
    (localObserverCoordinateOverlap_iff c.toLocal d.toLocal).mp hy
  have hcsource : c.localHomeomorph.symm y ∈ c.localHomeomorph.source :=
    c.localHomeomorph.map_target hy'.1
  have hinv : ContDiffAt ℝ 1 c.localHomeomorph.symm y := by
    simpa [c, c.localHomeomorph.right_inv hy'.1] using
      A.inverse_contDiffAt i (c.localHomeomorph.symm y) hcsource
  have hchart : ContDiffAt ℝ 1 d.localHomeomorph
      (c.localHomeomorph.symm y) :=
    A.chart_contDiffAt j (c.localHomeomorph.symm y) hy'.2
  exact hchart.comp y hinv
/-! ### Regular atlases: Jacobians with overlap regularity -/

/-- A `C^n` observer atlas couples the exact pointwise Jacobians carried by
its charts to `ContDiffOn` transition maps on every full chart overlap. Thus
no Jacobian is accepted in isolation from the regular coordinate change it
differentiates. -/
structure ContDiffObserverTangentAtlas
    (n : ℕ∞ω) (ι E F : Type*)
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    extends TopologicalObserverTangentAtlas ι E F where
  transition_contDiffOn :
    ∀ i j,
      ContDiffOn ℝ n
        ((modelWithCornersSelf ℝ F) ∘
          ((toTopologicalObserverTangentAtlas.chart i).localHomeomorph.symm ≫ₕ
            (toTopologicalObserverTangentAtlas.chart j).localHomeomorph) ∘
          (modelWithCornersSelf ℝ F).symm)
        ((modelWithCornersSelf ℝ F).symm ⁻¹'
          (((toTopologicalObserverTangentAtlas.chart i).localHomeomorph.symm ≫ₕ
            (toTopologicalObserverTangentAtlas.chart j).localHomeomorph).source) ∩
          Set.range (modelWithCornersSelf ℝ F))

/-- Build the overlap-regular atlas automatically from chartwise `C^1`
evidence. This is the bridge that prevents transition Jacobians and
transition regularity from becoming separate obligations. -/
noncomputable def C1ObserverTangentAtlas.toContDiffAtlas
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : C1ObserverTangentAtlas ι E F) :
    ContDiffObserverTangentAtlas 1 ι E F where
  toTopologicalObserverTangentAtlas :=
    A.toTopologicalObserverTangentAtlas
  transition_contDiffOn := by
    intro i j
    have hset :
        (A.toTopologicalObserverTangentAtlas.chart i).localHomeomorph.target ∩
          (A.toTopologicalObserverTangentAtlas.chart i).localHomeomorph.symm ⁻¹'
            (A.toTopologicalObserverTangentAtlas.chart j).localHomeomorph.source =
        localObserverCoordinateOverlap
          (A.toTopologicalObserverTangentAtlas.chart i).toLocal
          (A.toTopologicalObserverTangentAtlas.chart j).toLocal := by
      ext y
      rw [localObserverCoordinateOverlap_iff]
      rfl
    simp only [modelWithCornersSelf_coe, modelWithCornersSelf_coe_symm,
      Function.comp_id, Function.id_comp, Set.range_id, Set.preimage_id,
      Set.inter_univ, OpenPartialHomeomorph.trans_source,
      OpenPartialHomeomorph.symm_source]
    rw [hset]
    change ContDiffOn ℝ 1
      (localObserverTransition
        (A.toTopologicalObserverTangentAtlas.chart i).toLocal
        (A.toTopologicalObserverTangentAtlas.chart j).toLocal)
      (localObserverCoordinateOverlap
        (A.toTopologicalObserverTangentAtlas.chart i).toLocal
        (A.toTopologicalObserverTangentAtlas.chart j).toLocal)
    exact A.localTransition_contDiffOn i j
/-- A regular observer atlas assembles into mathlib's genuine `C^n`
manifold structure. The proof consumes the overlap-wide regularity contract
for exactly the charts installed by `toChartedSpace`. -/
theorem ContDiffObserverTangentAtlas.isManifold
    {n : ℕ∞ω} {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : ContDiffObserverTangentAtlas n ι E F) :
    @IsManifold ℝ _ F _ _ F _ (modelWithCornersSelf ℝ F) n E _
      A.toTopologicalObserverTangentAtlas.toChartedSpace := by
  letI : ChartedSpace F E :=
    A.toTopologicalObserverTangentAtlas.toChartedSpace
  apply isManifold_of_contDiffOn
  intro e e' he he'
  rcases he with ⟨i, rfl⟩
  rcases he' with ⟨j, rfl⟩
  exact A.transition_contDiffOn i j

/-- In particular, a `C^1` observer atlas upgrades the assembled space from
topological to continuously differentiable while retaining its certified
transition Jacobians and tangent cocycle. -/
theorem ContDiffObserverTangentAtlas.isManifold_one
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : ContDiffObserverTangentAtlas 1 ι E F) :
    @IsManifold ℝ _ F _ _ F _ (modelWithCornersSelf ℝ F) 1 E _
      A.toTopologicalObserverTangentAtlas.toChartedSpace :=
  A.isManifold
/-- Chartwise `C^1` proofs alone now suffice to construct the mathlib
continuously differentiable manifold; no independent pairwise transition
certificate is required from the engineer. -/
theorem C1ObserverTangentAtlas.isManifold
    {ι E F : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    [NormedAddCommGroup F] [NormedSpace ℝ F]
    (A : C1ObserverTangentAtlas ι E F) :
    @IsManifold ℝ _ F _ _ F _ (modelWithCornersSelf ℝ F) 1 E _
      A.toTopologicalObserverTangentAtlas.toChartedSpace :=
  A.toContDiffAtlas.isManifold_one
/-! ### Observer locality -/

/-- **axiom:bk4_observer_locality**: an observer kernel supported inside
B_O × B_O vanishes outside it — locality made operational: no influence
crosses the observer's boundary. -/
theorem local_kernel_vanishes_offdiagonal {X : Type*} (K : X → X → ℝ)
    (B : Set X) (hsupp : ∀ x y, K x y ≠ 0 → x ∈ B ∧ y ∈ B)
    {x y : X} (hx : x ∉ B) : K x y = 0 := by
  by_contra h
  exact hx (hsupp x y h).1

/-! ### Self-authorship as a fixed-point constraint map -/

variable {X : Type*} [MetricSpace X] [CompleteSpace X] [Nonempty X]

/-- **theorem:bk4_self_authorship_and_freedom**: the constraint-
refinement sequence L_{n+1} = D(L_n) converges to a UNIQUE fixed-point
constraint map L_∞ = Fix(D) when the refinement is a contraction —
complete self-authorship is attaining that fixed locus, and maximal
symbolic freedom coincides with it. -/
theorem self_authorship_fixed_point {D : X → X} {K : ℝ≥0} (hK : K < 1)
    (hD : LipschitzWith K D) :
    ∃! L, D L = L := by
  have hc : ContractingWith K D := ⟨hK, hD⟩
  exact ⟨hc.fixedPoint D, hc.fixedPoint_isFixedPt,
    fun y hy => hc.fixedPoint_unique hy⟩

end ForcingAnalysis.Book4Fz
