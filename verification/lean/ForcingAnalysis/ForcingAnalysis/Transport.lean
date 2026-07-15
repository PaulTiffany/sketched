/-
Transport.lean — the interface layer of forcing_correspondence_v15, over
mathlib: the Non-identity of Transport Theorem (thm:nonid) and the
Exportability Identity (prop:chi, orthogonal case).

thm:nonid's first claim — bounded projection already breaks identity, and
identity transport holds exactly on the residue subobject — is algebra
about idempotents; prop:chi is Pythagoras for the orthogonal projection.
The paper's oblique caveat ("orthogonality must not be smuggled in") is
visible here as the `InnerProductSpace` + orthogonal-projection
requirements of `exportability_identity`, absent from the idempotent-only
results above it.
-/

import Mathlib

namespace ForcingAnalysis

open scoped RealInnerProductSpace

/-- **Non-identity of transport** (thm:nonid, algebraic core): for an
idempotent channel projector T, a state is transported identically iff it
already lies in the residue subobject im T. -/
theorem transport_identity_iff_residue {R E : Type*} [Ring R]
    [AddCommGroup E] [Module R E]
    (T : E →ₗ[R] E) (hT : ∀ x, T (T x) = T x) (x : E) :
    T x = x ↔ x ∈ LinearMap.range T := by
  constructor
  · intro h
    exact ⟨x, h⟩
  · rintro ⟨y, rfl⟩
    exact hT y

/-- thm:nonid in the metric form of the paper: the projection loss
ε_T(x) = ‖x - Tx‖ vanishes exactly on the residue subobject
(equivalently: zero projection loss is condition (i) of the
identity-transport condition). -/
theorem projection_loss_zero_iff_residue {E : Type*} [NormedAddCommGroup E]
    [Module ℝ E] (T : E →ₗ[ℝ] E) (hT : ∀ x, T (T x) = T x) (x : E) :
    ‖x - T x‖ = 0 ↔ x ∈ LinearMap.range T := by
  rw [norm_eq_zero, sub_eq_zero]
  exact ⟨fun h => (transport_identity_iff_residue T hT x).1 h.symm,
         fun h => ((transport_identity_iff_residue T hT x).2 h).symm⟩

/-- **Exportability identity** (prop:chi, orthogonal case):
‖P_K x‖² + ‖x − P_K x‖² = ‖x‖². Divided by ‖x‖² this is
χ_T(x)² + ε_T(x)² = 1. Requires genuine orthogonality — the
inner-product structure and orthogonal projection are the formal content
of "orthogonality must not be smuggled in". -/
theorem exportability_identity {E : Type*} [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] (K : Submodule ℝ E) [K.HasOrthogonalProjection]
    (x : E) :
    ‖K.starProjection x‖ ^ 2 + ‖x - K.starProjection x‖ ^ 2 = ‖x‖ ^ 2 := by
  have hres : x - K.starProjection x = Kᗮ.starProjection x := by
    rw [sub_eq_iff_eq_add']
    exact (K.starProjection_add_starProjection_orthogonal x).symm
  rw [hres]
  exact (Submodule.norm_sq_eq_add_norm_sq_starProjection x K).symm

/-- **Observer closure is zero projection residue** (prop:zombie, v16).
Identifying the closure defect of an external observer-closure frame with the
projection residue ε_T(x) = ‖x − Tx‖ (the modeling bridge M-Zomb), observer
closure (ε_T = 0) is exactly condition (i) of thm:nonid, x ∈ im T. This is
`projection_loss_zero_iff_residue` re-exposed under the closure name; only the
identification is new. The identity that would globalize a local certificate is
`exportability_identity`, which needs genuine orthogonality. -/
theorem observer_closed_iff_zero_defect {E : Type*} [NormedAddCommGroup E]
    [Module ℝ E] (T : E →ₗ[ℝ] E) (hT : ∀ x, T (T x) = T x) (x : E) :
    ‖x - T x‖ = 0 ↔ x ∈ LinearMap.range T :=
  projection_loss_zero_iff_residue T hT x

/-- A behaviorally competent system with positive closure defect — a *zombie* —
carries off-channel residue x ∉ im T. The defect lives in (id − T)x, while a
finite behavioral trace transports only the exported floor Tx, so it cannot
witness the defect. -/
theorem zombie_off_channel {E : Type*} [NormedAddCommGroup E]
    [Module ℝ E] (T : E →ₗ[ℝ] E) (hT : ∀ x, T (T x) = T x) (x : E)
    (hpos : ‖x - T x‖ ≠ 0) : x ∉ LinearMap.range T := by
  rw [← observer_closed_iff_zero_defect T hT x]; exact hpos

end ForcingAnalysis
