/-
Book8Freedom.lean — the rank-surjectivity kernel of symbolic freedom,
and the discrete absorbing-ball kernel of SR-triplet boundedness.

Sources (Principia Book 8, verbatim; sha-bound in bindings.json):

  definition:bk8_volitional_projection_operator — the volitional
    projection operator Π_vol : M_S → A_S maps symbolic states into an
    action manifold, each point a viable intervention.
  theorem:bk8_freedom_emergence_criterion — "freedom emerges in S when
    rank(Π_vol) = dim(viability domain), i.e. all viable directions of
    drift are modulated by reflective symbolic control."
  theorem:bk8_freedom_via_meta_metabolic_control — the SAME criterion,
    restricted to the meta-parameter space: rank(Π_vol restricted to
    Ω_MP, O_debug) = dim(viability domain^{meta-parameters}).

KERNEL: for a linear map between finite-dimensional spaces, having
full rank onto the codomain is EXACTLY surjectivity
(`freedom_emergence_iff_surjective`). The second theorem is not a new
law — it is the FIRST theorem instantiated at the domain-restricted map
Φ.domRestrict Ω (`meta_metabolic_freedom_iff_surjective`), making the
scholium's two "freedom" theorems literally the same kernel applied
twice, exactly as Book2Temperature reused Book2's Gibbs machinery.
`freedom_can_fail` witnesses the failure side is nonvacuous: a concrete
rank-deficient endomorphism of ℝ² is not surjective.

  definition:bk8_sr_triplet / axiom:bk8_surface_energy_dynamics —
    the SR-triplet (I, M, C) evolves under coupled dynamics with
    Lipschitz f, L.
  proposition:bk8_genetic_symbolic_resonance ("Boundedness") — if the
    forcing terms are bounded and f, L are globally Lipschitz, the
    trajectory (I, M, C) remains bounded.

KERNEL: the discrete absorbing-ball bound. A step map satisfying the
AFFINE CONTRACTION estimate |step x| ≤ κ|x| + B with κ < 1 (the
discrete shadow of "globally Lipschitz with bounded forcing on a
dissipative system") drives every orbit into, and keeps it inside, the
ball of radius max(|x₀|, B/(1−κ)) forever (`contraction_orbit_bounded`)
— the trajectory is bounded uniformly in time, not merely growing
linearly. This is the honest discrete analogue: turning "Lipschitz" into
a genuine growth-controlling contraction constant is the modeling step
the anchor leaves implicit; the continuous ℝ³ ODE form (existence via
Picard–Lindelöf, the specific coupled system) stays open. Reuses
ScholiumDyn.flowOrbit for the orbit itself — the SR-triplet's evolution
IS a discrete flow in the sense already certified there.
-/

import Mathlib
import ForcingAnalysis.ScholiumDynamics

namespace ForcingAnalysis.Book8Freedom

open ForcingAnalysis.ScholiumDyn

/-! ### Freedom emergence: rank onto the codomain is surjectivity -/

variable {V W : Type*} [AddCommGroup V] [Module ℝ V]
  [AddCommGroup W] [Module ℝ W] [FiniteDimensional ℝ W]

/-- **Freedom Emergence Criterion, kernel form**: a linear map achieves
full rank onto its target EXACTLY when it is surjective — "all viable
directions are modulated by reflective symbolic control" is
surjectivity, stated without metaphor. -/
theorem freedom_emergence_iff_surjective (Φ : V →ₗ[ℝ] W) :
    Module.finrank ℝ (LinearMap.range Φ) = Module.finrank ℝ W ↔
      Function.Surjective Φ := by
  rw [← LinearMap.range_eq_top]
  constructor
  · intro h
    exact Submodule.eq_top_of_finrank_eq h
  · intro h
    rw [h, finrank_top]

/-- **Freedom via Meta-Metabolic Control**: the SAME criterion, applied
to the volitional operator restricted to the meta-parameter subspace
Ω_MP. The scholium's second freedom theorem is the first, instantiated
at the domain-restricted map — one kernel, two anchors. -/
theorem meta_metabolic_freedom_iff_surjective (Φ : V →ₗ[ℝ] W)
    (Ω : Submodule ℝ V) :
    Module.finrank ℝ (LinearMap.range (Φ.domRestrict Ω)) =
        Module.finrank ℝ W ↔
      Function.Surjective (Φ.domRestrict Ω) :=
  freedom_emergence_iff_surjective (Φ.domRestrict Ω)

/-- The coordinate projection (x, y) ↦ (x, 0) on ℝ² — a concrete
volitional operator with an unmodulated viable direction. -/
def coordProj : (ℝ × ℝ) →ₗ[ℝ] (ℝ × ℝ) where
  toFun p := (p.1, 0)
  map_add' _ _ := by simp
  map_smul' _ _ := by simp

/-- **Freedom can fail** (the failure side, witnessed): `coordProj` is
not surjective. -/
theorem freedom_can_fail : ¬ Function.Surjective coordProj := by
  intro h
  obtain ⟨⟨x, y⟩, hxy⟩ := h (0, 1)
  simp only [coordProj, LinearMap.coe_mk, AddHom.coe_mk] at hxy
  exact absurd (congrArg Prod.snd hxy) (by norm_num)

/-! ### SR-triplet boundedness: the discrete absorbing ball -/

/-- **SR boundedness, discrete absorbing-ball kernel**
(proposition:bk8_genetic_symbolic_resonance): a step map satisfying the
affine contraction estimate |step x| ≤ κ|x| + B with κ < 1 keeps every
orbit inside the ball of radius max(|x₀|, B/(1−κ)) FOREVER — bounded
uniformly in time. The SR-triplet's flow is `ScholiumDyn.flowOrbit`;
Lipschitz-with-bounded-forcing becomes the contraction estimate here. -/
theorem contraction_orbit_bounded {step : ℝ → ℝ} {κ B : ℝ}
    (hκ0 : 0 ≤ κ) (hκ1 : κ < 1)
    (hstep : ∀ x, |step x| ≤ κ * |x| + B) (x0 : ℝ) (n : ℕ) :
    |flowOrbit step x0 n| ≤ max |x0| (B / (1 - κ)) := by
  set M := max |x0| (B / (1 - κ)) with hM
  have h1mκ : 0 < 1 - κ := by linarith
  have hMB : B / (1 - κ) ≤ M := le_max_right _ _
  have hBκM : B ≤ M * (1 - κ) := by
    rw [div_le_iff₀ h1mκ] at hMB
    linarith
  induction n with
  | zero => exact le_max_left _ _
  | succ k ih =>
      have hrec : flowOrbit step x0 (k + 1) = step (flowOrbit step x0 k) := by
        simp only [flowOrbit, Function.iterate_succ_apply']
      rw [hrec]
      calc |step (flowOrbit step x0 k)|
          ≤ κ * |flowOrbit step x0 k| + B := hstep _
        _ ≤ κ * M + B := by nlinarith [ih]
        _ ≤ M := by nlinarith [hBκM]

end ForcingAnalysis.Book8Freedom
