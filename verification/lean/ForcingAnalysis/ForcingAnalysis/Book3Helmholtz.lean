/-
Book3Helmholtz.lean — finite-dimensional orthogonal-decomposition kernel for
the refinement-field Helmholtz claim in Principia Symbolica Book 3.
-/
import Mathlib

namespace ForcingAnalysis.Book3Helmholtz

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E]

/-- The integrative component is orthogonal projection onto the chosen
finite-dimensional gradient-like subspace. -/
noncomputable def integrativeComponent (G : Submodule ℝ E) (v : E) : E :=
  G.starProjection v

/-- The differentiative component is the residual orthogonal to the chosen
gradient-like subspace. -/
noncomputable def differentiativeComponent (G : Submodule ℝ E) (v : E) : E :=
  v - integrativeComponent G v

/-- Exact reconstruction into integrative, differentiative, and zero
harmonic components. -/
theorem finite_helmholtz_reconstruction (G : Submodule ℝ E) (v : E) :
    v = integrativeComponent G v + differentiativeComponent G v + 0 := by
  simp [integrativeComponent, differentiativeComponent]

theorem integrativeComponent_mem (G : Submodule ℝ E) (v : E) :
    integrativeComponent G v ∈ G := by
  exact G.starProjection_apply_mem v

theorem differentiativeComponent_mem_orthogonal (G : Submodule ℝ E) (v : E) :
    differentiativeComponent G v ∈ Gᗮ := by
  exact G.sub_starProjection_mem_orthogonal v

/-- The two retained components are orthogonal, making the split identifiable
rather than an arbitrary additive factorization. -/
theorem components_inner_eq_zero (G : Submodule ℝ E) (v : E) :
    inner ℝ (integrativeComponent G v) (differentiativeComponent G v) = 0 := by
  exact (differentiativeComponent_mem_orthogonal G v)
    (integrativeComponent G v) (integrativeComponent_mem G v)

/-- Uniqueness of the two-component split relative to the selected
gradient-like subspace. -/
theorem finite_helmholtz_unique (G : Submodule ℝ E) (v g c : E)
    (hg : g ∈ G) (hc : c ∈ Gᗮ) (hv : v = g + c) :
    integrativeComponent G v = g ∧ differentiativeComponent G v = c := by
  have hproj : G.starProjection v = g :=
    G.eq_starProjection_of_mem_orthogonal' hg hc hv
  constructor
  · exact hproj
  · unfold differentiativeComponent integrativeComponent
    rw [hproj, hv]
    abel

/-! ## Three-sector finite Hodge model -/

/-- Finite-dimensional Hodge data retain distinct exact and coexact sectors.
The inclusion is the algebraic form of their orthogonality. -/
structure FiniteHodgeData (E : Type*) [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] where
  exact : Submodule ℝ E
  coexact : Submodule ℝ E
  coexact_le_exact_orthogonal : coexact ≤ exactᗮ

namespace FiniteHodgeData

variable (D : FiniteHodgeData E)

/-- The harmonic sector is orthogonal to both exact and coexact sectors. -/
noncomputable def harmonic : Submodule ℝ E := D.exactᗮ ⊓ D.coexactᗮ

noncomputable def exactComponent (v : E) : E := D.exact.starProjection v

noncomputable def exactResidual (v : E) : E := v - D.exactComponent v

/-- The coexact projection is taken after removing the exact component. -/
noncomputable def coexactComponent (v : E) : E :=
  D.coexact.starProjection (D.exactResidual v)

/-- What remains after both projections is the harmonic component. -/
noncomputable def harmonicComponent (v : E) : E :=
  D.exactResidual v - D.coexactComponent v

theorem reconstruction (v : E) :
    v = D.exactComponent v + D.coexactComponent v + D.harmonicComponent v := by
  simp [harmonicComponent, exactResidual]

theorem exactComponent_mem (v : E) : D.exactComponent v ∈ D.exact := by
  exact D.exact.starProjection_apply_mem v

theorem exactResidual_mem (v : E) : D.exactResidual v ∈ D.exactᗮ := by
  exact D.exact.sub_starProjection_mem_orthogonal v

theorem coexactComponent_mem (v : E) : D.coexactComponent v ∈ D.coexact := by
  exact D.coexact.starProjection_apply_mem (D.exactResidual v)

theorem coexactComponent_mem_exact_orthogonal (v : E) :
    D.coexactComponent v ∈ D.exactᗮ :=
  D.coexact_le_exact_orthogonal (D.coexactComponent_mem v)

theorem harmonicComponent_mem (v : E) :
    D.harmonicComponent v ∈ D.harmonic := by
  constructor
  · exact D.exactᗮ.sub_mem (D.exactResidual_mem v)
      (D.coexactComponent_mem_exact_orthogonal v)
  · exact D.coexact.sub_starProjection_mem_orthogonal (D.exactResidual v)

theorem exact_coexact_inner_eq_zero (v : E) :
    inner ℝ (D.exactComponent v) (D.coexactComponent v) = 0 := by
  exact (D.coexactComponent_mem_exact_orthogonal v)
    (D.exactComponent v) (D.exactComponent_mem v)

theorem exact_harmonic_inner_eq_zero (v : E) :
    inner ℝ (D.exactComponent v) (D.harmonicComponent v) = 0 := by
  exact (D.harmonicComponent_mem v).1
    (D.exactComponent v) (D.exactComponent_mem v)

theorem coexact_harmonic_inner_eq_zero (v : E) :
    inner ℝ (D.coexactComponent v) (D.harmonicComponent v) = 0 := by
  exact (D.harmonicComponent_mem v).2
    (D.coexactComponent v) (D.coexactComponent_mem v)

/-- The harmonic sector is not definitionally erased: when the exact and
coexact sectors are both bottom, all of the field is harmonic. -/
theorem harmonicComponent_eq_self_of_exact_eq_bot_of_coexact_eq_bot
    (v : E) (hExact : D.exact = ⊥) (hCoexact : D.coexact = ⊥) :
    D.harmonicComponent v = v := by
  simp [harmonicComponent, coexactComponent, exactResidual,
    exactComponent, hExact, hCoexact]

/-- A concrete counterexample to the earlier zero-harmonic flattening. -/
theorem nonzero_harmonic_component_exists [Nontrivial E] :
    ∃ (D : FiniteHodgeData E) (v : E), D.harmonicComponent v ≠ 0 := by
  let D0 : FiniteHodgeData E := {
    exact := ⊥
    coexact := ⊥
    coexact_le_exact_orthogonal := by simp
  }
  obtain ⟨v, hv⟩ := exists_ne (0 : E)
  refine ⟨D0, v, ?_⟩
  rw [D0.harmonicComponent_eq_self_of_exact_eq_bot_of_coexact_eq_bot v rfl rfl]
  exact hv

end FiniteHodgeData

/-! ## Global, operational Hodge certificate -/

/-- The global theorem is retained as a certificate over the intended
membrane. Its geometric hypotheses are explicit and cannot be inferred from a
finite projection model. -/
structure MembraneHodgeHypotheses (M : Type*) where
  compact : Prop
  connected : Prop
  oriented : Prop
  smoothRiemannian : Prop
  boundaryless : Prop
  compact_certified : compact
  connected_certified : connected
  oriented_certified : oriented
  smoothRiemannian_certified : smoothRiemannian
  boundaryless_certified : boundaryless

/-- A typed Hodge--Helmholtz certificate for one refinement field. `E` is the
Hilbert space of square-integrable one-form representatives and `H1` is the
observer's supplied first de Rham cohomology model. -/
structure GlobalHodgeCertificate
    (M E H1 : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [AddCommGroup H1] [Module ℝ H1] where
  membrane : MembraneHodgeHypotheses M
  refinementField : E
  exactSector : Submodule ℝ E
  coexactSector : Submodule ℝ E
  harmonicSector : Submodule ℝ E
  exactPart : E
  coexactPart : E
  harmonicPart : E
  exact_mem : exactPart ∈ exactSector
  coexact_mem : coexactPart ∈ coexactSector
  harmonic_mem : harmonicPart ∈ harmonicSector
  reconstruction : refinementField = exactPart + coexactPart + harmonicPart
  exact_coexact_orthogonal : inner ℝ exactPart coexactPart = 0
  exact_harmonic_orthogonal : inner ℝ exactPart harmonicPart = 0
  coexact_harmonic_orthogonal : inner ℝ coexactPart harmonicPart = 0
  decomposition_unique : ∀ e c h : E,
    e ∈ exactSector -> c ∈ coexactSector -> h ∈ harmonicSector ->
    refinementField = e + c + h ->
    e = exactPart ∧ c = coexactPart ∧ h = harmonicPart
  cohomologyClass : E →ₗ[ℝ] H1
  harmonic_class_faithful : ∀ h : E, h ∈ harmonicSector ->
    (cohomologyClass h = 0 <-> h = 0)

namespace GlobalHodgeCertificate

variable {M E H1 : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [AddCommGroup H1] [Module ℝ H1]
  (C : GlobalHodgeCertificate M E H1)

/-- The certificate exposes the source theorem's three sectors without
flattening the harmonic remainder into the rotational channel. -/
theorem components :
    C.refinementField = C.exactPart + C.coexactPart + C.harmonicPart ∧
    C.exactPart ∈ C.exactSector ∧ C.coexactPart ∈ C.coexactSector ∧
    C.harmonicPart ∈ C.harmonicSector :=
  ⟨C.reconstruction, C.exact_mem, C.coexact_mem, C.harmonic_mem⟩

/-- Pairwise orthogonality makes squared refinement energy additive across the
three operational channels. -/
theorem refinement_energy_decomposes :
    ‖C.refinementField‖ ^ 2 =
      ‖C.exactPart‖ ^ 2 + ‖C.coexactPart‖ ^ 2 + ‖C.harmonicPart‖ ^ 2 := by
  rw [C.reconstruction]
  have hsum : inner ℝ (C.exactPart + C.coexactPart) C.harmonicPart = 0 := by
    simp [inner_add_left, C.exact_harmonic_orthogonal,
      C.coexact_harmonic_orthogonal]
  calc
    ‖C.exactPart + C.coexactPart + C.harmonicPart‖ ^ 2 =
        ‖C.exactPart + C.coexactPart‖ ^ 2 + ‖C.harmonicPart‖ ^ 2 := by
      simpa [pow_two] using
        (norm_add_sq_eq_norm_sq_add_norm_sq_real hsum)
    _ = ‖C.exactPart‖ ^ 2 + ‖C.coexactPart‖ ^ 2 +
        ‖C.harmonicPart‖ ^ 2 := by
      have hpair : ‖C.exactPart + C.coexactPart‖ ^ 2 =
          ‖C.exactPart‖ ^ 2 + ‖C.coexactPart‖ ^ 2 := by
        simpa [pow_two] using
          (norm_add_sq_eq_norm_sq_add_norm_sq_real
            C.exact_coexact_orthogonal)
      rw [hpair]

/-- Trivial first cohomology kills the harmonic component, but not by
fiat: the conclusion passes through the supplied faithful class map. -/
theorem harmonic_eq_zero_of_subsingleton_cohomology [Subsingleton H1] :
    C.harmonicPart = 0 := by
  have hf : C.harmonicPart ∈ C.harmonicSector ->
      (C.cohomologyClass C.harmonicPart = 0 <-> C.harmonicPart = 0) :=
    C.harmonic_class_faithful C.harmonicPart
  have hclass := hf C.harmonic_mem
  apply hclass.mp
  exact Subsingleton.elim _ _

/-- Any linear operational readout (including a sonification) preserves the
three-channel reconstruction. Sound may expose the split; it does not create
or certify the Hodge hypotheses. -/
theorem operational_readout_reconstructs
    {Signal : Type*} [AddCommMonoid Signal] [Module ℝ Signal]
    (readout : E →ₗ[ℝ] Signal) :
    readout C.refinementField =
      readout C.exactPart + readout C.coexactPart + readout C.harmonicPart := by
  rw [C.reconstruction, map_add, map_add]

/-- A family of instruments may expose the same decomposition through sound,
light, temperature, pressure, or another carrier. No carrier is privileged by
the Hodge certificate. -/
theorem multimodal_readout_reconstructs
    {Carrier Signal : Type*} [AddCommMonoid Signal] [Module ℝ Signal]
    (readout : Carrier -> E →ₗ[ℝ] Signal) (carrier : Carrier) :
    readout carrier C.refinementField =
      readout carrier C.exactPart + readout carrier C.coexactPart +
        readout carrier C.harmonicPart :=
  C.operational_readout_reconstructs (readout carrier)

/-- A faithful instrument detects nonzero harmonic residue. This is the extra
premise needed to pass from an internal sector to an observed wave or sensor
signal. -/
theorem faithful_readout_detects_harmonic
    {Signal : Type*} [AddCommMonoid Signal] [Module ℝ Signal]
    (readout : E →ₗ[ℝ] Signal) (hfaithful : Function.Injective readout)
    (hNonzero : C.harmonicPart ≠ 0) :
    readout C.harmonicPart ≠ 0 := by
  intro hzero
  have : readout C.harmonicPart = readout 0 := by simpa using hzero
  exact hNonzero (hfaithful this)

end GlobalHodgeCertificate

/-- An unfaithful instrument can erase a real harmonic channel: the zero
readout sees no residue even when the underlying harmonic component is one. -/
theorem unfaithful_readout_can_erase_harmonic :
    let readout : ℝ →ₗ[ℝ] ℝ := 0
    readout 1 = 0 := by
  rfl

/-- A two-channel readout cannot generally erase the harmonic sector: the
identity readout detects a nonzero supplied harmonic component exactly. -/
theorem harmonic_channel_can_be_operationally_detected :
    ∃ (C : GlobalHodgeCertificate Unit ℝ ℝ),
      (LinearMap.id : ℝ →ₗ[ℝ] ℝ) C.harmonicPart != 0 := by
  let membrane : MembraneHodgeHypotheses Unit := {
    compact := True, connected := True, oriented := True,
    smoothRiemannian := True, boundaryless := True,
    compact_certified := trivial, connected_certified := trivial,
    oriented_certified := trivial, smoothRiemannian_certified := trivial,
    boundaryless_certified := trivial }
  let C : GlobalHodgeCertificate Unit ℝ ℝ := {
    membrane := membrane
    refinementField := 1
    exactSector := ⊥
    coexactSector := ⊥
    harmonicSector := ⊤
    exactPart := 0
    coexactPart := 0
    harmonicPart := 1
    exact_mem := by simp
    coexact_mem := by simp
    harmonic_mem := by simp
    reconstruction := by norm_num
    exact_coexact_orthogonal := by norm_num
    exact_harmonic_orthogonal := by norm_num
    coexact_harmonic_orthogonal := by norm_num
    decomposition_unique := by
      intro e c h he hc hh hsum
      simp only [Submodule.mem_bot] at he hc
      subst e
      subst c
      norm_num at hsum ⊢
      exact hsum.symm
    cohomologyClass := LinearMap.id
    harmonic_class_faithful := by simp }
  exact ⟨C, by norm_num⟩

end ForcingAnalysis.Book3Helmholtz
