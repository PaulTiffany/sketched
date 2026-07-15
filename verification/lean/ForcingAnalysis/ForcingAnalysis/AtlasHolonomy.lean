/-
AtlasHolonomy.lean — curvature as loop defect (the FracturedAtlas
program's first named next layer; the scholium's semantic-holonomy
cluster).

Sources (Principia scholium, verbatim; sha-bound in bindings.json):

  axiom:bk1_semantic_non_integrability — "the meaning carried from one
    context to another is path-dependent: transporting the same local
    meaning between two contexts along two different routes does not in
    general return the same result... the contextual update carries a
    non-vanishing antisymmetric (commutator) component. This is the
    single premise the curvature conclusion rests on."
  lemma:bk1_curvature_semantic_holonomy — parallel transport around the
    infinitesimal rectangle satisfies P Z = Z + ε²κ(X,Y)Z + O(ε³):
    "κ(X,Y)Z is precisely the second-order semantic residue obtained by
    transporting the same local meaning around two different
    infinitesimal routes."
  definition:bk1_symbolic_riemann_tensor / definition:bk1_local_semantic_independence /
  corollary:bk1_non_euclidean_necessity — the tensor, the independence
    it negates, and the necessity corollary.

The discrete honest kernel, per the non-normalized rule (no Christoffel
symbols, no inverses, no infinitesimals — routes compared directly):

  * SEMANTIC TRANSPORT at function level: two contextual updates
    T, U on a meaning fiber. Path-dependence is route disagreement;
    local semantic independence is commutation; and
    `path_dependent_iff_noncommuting` proves the axiom's "equivalently"
    clause — path-dependence IS the nonvanishing commutator, as an iff.
    `semantic_non_integrability_witness` exhibits it (Bool fiber,
    negation vs constant update: reading a context after revising it
    differs from revising after reading).
  * THE ε² LEMMA, exactly (linear transports 1 + ε•A): the two routes
    around the square differ by PRECISELY ε²·(AB − BA) — no O(ε³)
    remainder at all in the linear model (`holonomy_eps_squared`).
    Curvature — the commutator — is the exact second-order route
    residue, and `holonomy_zero_iff_commute` makes the correspondence
    an iff: routes agree at every ε iff the commutator vanishes.
  * NON-EUCLIDEAN NECESSITY, kernel form: a reflexively
    context-sensitive system (one whose updates genuinely fail to
    commute) has nonzero discrete curvature at some square — immediate
    from the iff, which is the point: the corollary's content IS the
    equivalence, and the scholium's proof sketch routes through
    exactly these steps.

Curvature-tensor computations on genuine Riemannian manifolds
(Christoffel symbols, the full κ(X,Y)Z with vector fields) remain
honestly open; this file certifies the loop-residue mechanism those
definitions package.
-/

import Mathlib
import ForcingAnalysis.FracturedAtlas

namespace ForcingAnalysis.Atlas

/-! ### Semantic transport at function level -/

variable {F : Type*}

/-- Path-dependence of two contextual updates (the axiom's clause):
some meaning transported along the two routes returns different
results. -/
def PathDependent (T U : F → F) : Prop :=
  ∃ z, T (U z) ≠ U (T z)

/-- Local semantic independence (definition:bk1_local_semantic_independence,
kernel): the updates commute — route order is semantically invisible. -/
def SemanticallyIndependent (T U : F → F) : Prop :=
  ∀ z, T (U z) = U (T z)

/-- **The axiom's "equivalently", proved**: path-dependence is exactly
the failure of local semantic independence — the nonvanishing
commutator component, as an iff. -/
theorem path_dependent_iff_noncommuting (T U : F → F) :
    PathDependent T U ↔ ¬ SemanticallyIndependent T U := by
  constructor
  · rintro ⟨z, hz⟩ h
    exact hz (h z)
  · intro h
    by_contra hnp
    exact h fun z => by
      by_contra hz
      exact hnp ⟨z, hz⟩

/-- **Semantic non-integrability, witnessed**: on the Boolean meaning
fiber, revision (negation) and collapse-to-true do not commute —
reading a context after revising it differs from revising after
reading. The axiom's content is nonvacuous in the smallest fiber. -/
theorem semantic_non_integrability_witness :
    PathDependent (fun b : Bool => !b) (fun _ : Bool => true) :=
  ⟨true, by decide⟩

/-! ### The ε² holonomy lemma (linear transports) -/

variable {n : ℕ}

open Matrix

/-- Route one around the square: flow along A first, then B
(composition applies the right factor first). -/
def routeAB (ε : ℝ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 + ε • B) * (1 + ε • A)

/-- Route two: B first, then A. -/
def routeBA (ε : ℝ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 + ε • A) * (1 + ε • B)

/-- **The holonomy lemma, exactly** (lemma:bk1_curvature_semantic_holonomy,
linear kernel): the two routes around the ε-square differ by PRECISELY
ε²·(BA − AB). In the linear model the O(ε³) remainder vanishes
identically: curvature — the commutator — is the exact second-order
residue of transporting the same meaning around two different routes. -/
theorem holonomy_eps_squared (ε : ℝ) (A B : Matrix (Fin n) (Fin n) ℝ) :
    routeAB ε A B - routeBA ε A B = (ε ^ 2) • (B * A - A * B) := by
  have expand : ∀ M N : Matrix (Fin n) (Fin n) ℝ,
      (1 + M) * (1 + N) = 1 + N + M + M * N := by
    intro M N
    rw [add_mul, mul_add, mul_add, one_mul, one_mul, mul_one]
    abel
  unfold routeAB routeBA
  rw [expand, expand, smul_mul_assoc, smul_mul_assoc,
    mul_smul_comm, mul_smul_comm, pow_two, ← smul_smul, smul_sub, smul_sub]
  abel

/-- **Flatness iff commuting** (the iff behind non-Euclidean
necessity): the routes agree at every scale iff the transports
commute. One direction is the ε = 1 square; the other is the exact
residue formula. -/
theorem holonomy_zero_iff_commute (A B : Matrix (Fin n) (Fin n) ℝ) :
    (∀ ε : ℝ, routeAB ε A B = routeBA ε A B) ↔ A * B = B * A := by
  constructor
  · intro h
    have h1 := holonomy_eps_squared 1 A B
    rw [h 1, sub_self, one_pow, one_smul] at h1
    exact (sub_eq_zero.mp h1.symm).symm
  · intro hcomm ε
    have h := holonomy_eps_squared ε A B
    rw [show B * A - A * B = 0 from sub_eq_zero.mpr hcomm.symm,
      smul_zero, sub_eq_zero] at h
    exact h

/-- **Non-Euclidean necessity, kernel form**
(corollary:bk1_non_euclidean_necessity): a reflexively
context-sensitive system — one whose two transports genuinely fail to
commute — has nonzero discrete curvature: the routes disagree at every
nonzero scale, with residue exactly ε²·[B,A]. Zero curvature is
impossible for such a system. -/
theorem non_euclidean_necessity {A B : Matrix (Fin n) (Fin n) ℝ}
    (hnc : A * B ≠ B * A) {ε : ℝ} (hε : ε ≠ 0) :
    routeAB ε A B ≠ routeBA ε A B := by
  intro h
  have hres := holonomy_eps_squared ε A B
  rw [h, sub_self] at hres
  have hε2 : (ε ^ 2 : ℝ) ≠ 0 := pow_ne_zero 2 hε
  have hcomm : B * A - A * B = 0 :=
    (smul_eq_zero.mp hres.symm).resolve_left hε2
  exact hnc (sub_eq_zero.mp hcomm).symm

/-- The curvature witness (definition:bk1_symbolic_riemann_tensor made
concrete): the two elementary nilpotents do not commute, so the
symbolic square they span carries genuinely nonzero curvature. -/
theorem curvature_witness :
    (Matrix.single (0 : Fin 2) (1 : Fin 2) (1 : ℝ)) *
        (Matrix.single (1 : Fin 2) (0 : Fin 2) (1 : ℝ)) ≠
      (Matrix.single (1 : Fin 2) (0 : Fin 2) (1 : ℝ)) *
        (Matrix.single (0 : Fin 2) (1 : Fin 2) (1 : ℝ)) := by
  intro h
  have h00 := congrFun (congrFun h 0) 0
  simp [Matrix.mul_apply, Matrix.single] at h00

end ForcingAnalysis.Atlas
