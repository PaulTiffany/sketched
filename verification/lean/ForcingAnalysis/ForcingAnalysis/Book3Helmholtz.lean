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

end ForcingAnalysis.Book3Helmholtz
