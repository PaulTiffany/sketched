/-
Lorentz.lean — the physics instance of the common commuting schema
(ForcingKernel/Schema.lean): Lorentz covariance of the four-force map

    K^μ = q F^{μν} u_ν .

This is the canonical, fully settled instance: no new physics is claimed.
Representation choices, and where the honesty lives:

* Index conventions are carried by the metric explicitly. `F` is the
  COVARIANT field tensor F_{μν} (an antisymmetric matrix); `u` is the
  contravariant four-velocity; index raising is left-multiplication by
  η, so `lorentzForce q F u = q • (η * F).mulVec u` is literally
  q η^{μα} F_{αν} u^ν.
* η² = 1, so the covariant transformation F ↦ (Λ⁻¹)ᵀ F Λ⁻¹ can be
  written inverse-free for Lorentz Λ as `actF Λ F = (ηΛη) F (ηΛᵀη)`
  (for Lorentz Λ, Λ⁻¹ = ηΛᵀη). The definition is total in Λ; for
  non-Lorentz Λ it is the η-twisted congruence — exactly the map the
  numeric negative control perturbs.
* Preservation (`lorentzForce_equivariant`) is unconditional in (F, u)
  and needs only the Lorentz condition ΛᵀηΛ = η. Its content is that
  the Lorentz condition IS the commutation certificate.
* Reflection (`lorentzForce_reflects`) is CONDITIONAL: it needs
  nondegeneracy (IsUnit Λ.det), and `zero_map_equivariant_not_lorentz`
  is the machine-checked countermodel showing that hypothesis is not
  removable — the zero map is equivariant and not Lorentz. The
  preservation/reflection asymmetry of the Field–Frontier transduction
  is thereby visible in the physics instance too, in the types.
* Reflection comes in two strengths. `lorentzForce_reflects_antisym`
  (LPS-O1, closed): equivariance quantified over ANTISYMMETRIC F only —
  physical field tensors — still reflects the Lorentz condition. The
  proof rearranges the hypothesis into F · (M − 1) = 0 for every
  antisymmetric F, with M = ηΛᵀηΛ, and kills every row of M − 1 with
  the probes E_ij − E_ji; the step consuming "dimension ≥ 2" is
  `exists_ne j` (Nontrivial (Fin 4)). `antisym_reflection_fails_dim1`
  is the degenerate countercase: with one index every antisymmetric
  tensor vanishes, the hypothesis is vacuous, and a non-Lorentz
  invertible map commutes — the dimensional hypothesis is real.
  `lorentzForce_reflects` (all F) is now a corollary. No conformal
  ambiguity survives: cΛ for c² ≠ 1 is invertible and non-Lorentz, so
  reflection itself rules it out (the force map has odd degree in the
  frame, so the scalings do not cancel).
* `actF_antisymm`: the action preserves antisymmetry for EVERY Λ, so
  the physical subspace is respected even off the Lorentz group — the
  negative control stays inside field-tensor space.

The domains are not identified: the forcing instance consumes
`RelationallyCommutes` (partial, one-sided, Prop-valued); this instance
consumes `Equivariant` (total, group-indexed, on-the-nose equality).
Same interface, different semantics, both from ForcingKernel/Schema.lean.
-/

import Mathlib
import ForcingKernel.Schema

namespace ForcingAnalysis

open Matrix

/-- Minkowski vectors, as bare index functions (component honesty over
abstraction: the transport maps are explicit matrix actions). -/
abbrev Mink : Type := Fin 4 → ℝ

/-- 4×4 real matrices: frame maps and (covariant) field tensors. -/
abbrev MinkMat : Type := Matrix (Fin 4) (Fin 4) ℝ

/-- The Minkowski metric η = diag(1,−1,−1,−1), signature (+,−,−,−). -/
def minkEta : MinkMat := Matrix.diagonal ![1, -1, -1, -1]

@[simp] theorem minkEta_transpose : minkEtaᵀ = minkEta :=
  Matrix.diagonal_transpose _

/-- η is an involution: η² = 1. This is what lets every inverse in the
covariant transformation law be written explicitly. -/
@[simp] theorem minkEta_mul_minkEta : minkEta * minkEta = 1 := by
  rw [minkEta, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
  congr 1
  funext i
  fin_cases i <;> norm_num

theorem minkEta_cancel (X : MinkMat) : minkEta * (minkEta * X) = X := by
  rw [← mul_assoc, minkEta_mul_minkEta, one_mul]

/-- The Lorentz condition ΛᵀηΛ = η (metric preservation). -/
def IsLorentz (Λ : MinkMat) : Prop := Λᵀ * minkEta * Λ = minkEta

/-- A (covariant) electromagnetic field tensor is antisymmetric. -/
def IsFieldTensor (F : MinkMat) : Prop := Fᵀ = -F

/-- Covariant transport of the field tensor. For Lorentz Λ this equals
the textbook F ↦ (Λ⁻¹)ᵀ F Λ⁻¹, because then Λ⁻¹ = ηΛᵀη; the formula is
total in Λ and is the map the negative control perturbs. -/
def actF (Λ F : MinkMat) : MinkMat :=
  minkEta * Λ * minkEta * F * (minkEta * Λᵀ * minkEta)

/-- The four-force map K^μ = q F^{μν} u_ν = q η^{μα} F_{αν} u^ν. -/
def lorentzForce (q : ℝ) (F : MinkMat) (u : Mink) : Mink :=
  q • (minkEta * F).mulVec u

/-- `actF` preserves antisymmetry for EVERY frame map Λ, Lorentz or not:
the physical subspace of field tensors is respected even by the broken
transports used as negative controls. -/
theorem actF_antisymm {Λ F : MinkMat} (hF : IsFieldTensor F) :
    IsFieldTensor (actF Λ F) := by
  unfold IsFieldTensor at hF ⊢
  simp [actF, Matrix.transpose_mul, hF, mul_assoc]

/-- The matrix core of preservation: over the Lorentz condition, raising
an index of the transported tensor and composing with transported input
is transport composed with the untransported force matrix. -/
theorem actF_core {Λ : MinkMat} (h : IsLorentz Λ) (F : MinkMat) :
    minkEta * actF Λ F * Λ = Λ * (minkEta * F) := by
  have h' : Λᵀ * (minkEta * Λ) = minkEta := by
    rw [← mul_assoc]; exact h
  simp only [actF, mul_assoc, h', minkEta_mul_minkEta, mul_one]
  rw [minkEta_cancel]

/-- **Lorentz-force covariance, pointwise form**: computing the
four-force and then changing frames agrees with changing frames first
(field by the covariant law, velocity by Λ) and computing after —
Λ K(F, u) = K(Λ·F, Λu). The Lorentz condition is the only hypothesis. -/
theorem lorentzForce_covariant {Λ : MinkMat} (h : IsLorentz Λ)
    (q : ℝ) (F : MinkMat) (u : Mink) :
    lorentzForce q (actF Λ F) (Λ.mulVec u) = Λ.mulVec (lorentzForce q F u) := by
  unfold lorentzForce
  rw [Matrix.mulVec_smul]
  congr 1
  rw [Matrix.mulVec_mulVec, Matrix.mulVec_mulVec, actF_core h F]

/-- **Lorentz-force equivariance** (schema form): the four-force map is
`ForcingKernel.Equivariant` — the SAME interface the forcing instance
consumes relationally — for the Lorentz-group action on (field, velocity)
pairs and on forces. The physics and the forcing are not identified;
they instantiate one commuting schema with different semantics. -/
theorem lorentzForce_equivariant (q : ℝ) :
    ForcingKernel.Equivariant
      (G := {Λ : MinkMat // IsLorentz Λ})
      (fun Λ p => (actF Λ.1 p.1, Λ.1.mulVec p.2))
      (fun Λ v => Λ.1.mulVec v)
      (fun p : MinkMat × Mink => lorentzForce q p.1 p.2) :=
  fun Λ p => lorentzForce_covariant Λ.2 q p.1 p.2

/-- Two matrices computing the same linear map are equal (probe with the
standard basis vectors). -/
private theorem eq_of_mulVec_eq {A B : MinkMat}
    (hAB : ∀ u, A.mulVec u = B.mulVec u) : A = B := by
  ext i j
  have hj := congrFun (hAB (Pi.single j 1)) i
  simpa [Matrix.mulVec_single] using hj

/-- Row i of E_ij · N is row j of N. -/
private theorem stdBasis_mul_apply_same (N : MinkMat) (i j l : Fin 4) :
    (Matrix.single i j (1 : ℝ) * N) i l = N j l := by
  rw [Matrix.mul_apply, Finset.sum_eq_single j]
  · simp [Matrix.single]
  · intro k _ hk
    simp [Matrix.single, Ne.symm hk]
  · intro hj
    exact absurd (Finset.mem_univ j) hj

/-- Rows of E_ab · N other than a are zero. -/
private theorem stdBasis_mul_apply_ne (N : MinkMat) {a : Fin 4} (b : Fin 4)
    {i : Fin 4} (hai : a ≠ i) (l : Fin 4) :
    (Matrix.single a b (1 : ℝ) * N) i l = 0 := by
  rw [Matrix.mul_apply]
  apply Finset.sum_eq_zero
  intro k _
  simp [Matrix.single, hai]

/-- The elementary probes E_ij − E_ji are antisymmetric — genuine (if
elementary) field tensors. -/
private theorem probe_isFieldTensor {i j : Fin 4} :
    IsFieldTensor
      (Matrix.single i j (1 : ℝ) - Matrix.single j i 1) := by
  unfold IsFieldTensor
  ext a b
  simp [Matrix.single, Matrix.transpose_apply, Matrix.neg_apply, and_comm]

/-- **Reflection over physical fields** (closes ledger LPS-O1):
equivariance quantified over ANTISYMMETRIC field tensors alone, plus
nondegeneracy, already forces the Lorentz condition. The hypothesis is
rearranged into F · (M − 1) = 0 for every antisymmetric F, where
M = ηΛᵀηΛ; the probes E_ij − E_ji then kill every row of M − 1.
Dimension ≥ 2 is consumed exactly once — `exists_ne j` — and is not
removable (`antisym_reflection_fails_dim1`); nondegeneracy is not either
(`zero_map_equivariant_not_lorentz`). Conformal check: no scalar
ambiguity survives, since cΛ for c² ≠ 1 is invertible and non-Lorentz,
so by THIS theorem it cannot commute over antisymmetric fields. -/
theorem lorentzForce_reflects_antisym {Λ : MinkMat} (hdet : IsUnit Λ.det)
    (h : ∀ F, IsFieldTensor F → ∀ u,
        lorentzForce 1 (actF Λ F) (Λ.mulVec u)
          = Λ.mulVec (lorentzForce 1 F u)) :
    IsLorentz Λ := by
  have hinv : Λ⁻¹ * Λ = 1 := Matrix.nonsing_inv_mul Λ hdet
  set M : MinkMat := minkEta * (Λᵀ * (minkEta * Λ)) with hMdef
  -- each antisymmetric F yields F · M = F
  have key : ∀ F, IsFieldTensor F → F * M = F := by
    intro F hF
    have hmat : minkEta * actF Λ F * Λ = Λ * (minkEta * F) := by
      apply eq_of_mulVec_eq
      intro u
      have hu := h F hF u
      simpa only [lorentzForce, one_smul, Matrix.mulVec_mulVec] using hu
    have hexp : Λ * (minkEta * (F * M)) = Λ * (minkEta * F) := by
      calc Λ * (minkEta * (F * M))
          = minkEta * actF Λ F * Λ := by
            simp only [hMdef, actF, mul_assoc, minkEta_cancel]
        _ = Λ * (minkEta * F) := hmat
    have hcanc : minkEta * (F * M) = minkEta * F := by
      have := congrArg (fun X => Λ⁻¹ * X) hexp
      simpa [← mul_assoc, hinv] using this
    have := congrArg (fun X => minkEta * X) hcanc
    simpa [minkEta_cancel] using this
  -- the probes kill every row of M − 1 (dimension ≥ 2 consumed here)
  have hrows : ∀ j l, (M - 1) j l = 0 := by
    intro j l
    obtain ⟨i, hij⟩ := exists_ne j
    have hzero :
        (Matrix.single i j (1 : ℝ) - Matrix.single j i 1)
          * (M - 1) = 0 := by
      rw [Matrix.mul_sub, mul_one, key _ (probe_isFieldTensor (i := i) (j := j)),
        sub_self]
    have hentry := congrFun (congrFun hzero i) l
    rw [Matrix.sub_mul] at hentry
    simp only [Matrix.sub_apply, Matrix.zero_apply] at hentry
    rw [stdBasis_mul_apply_same, stdBasis_mul_apply_ne _ i (Ne.symm hij),
      sub_zero] at hentry
    exact hentry
  have hM1 : M = 1 := by
    have hsub : M - 1 = 0 := by
      ext j l
      simpa using hrows j l
    exact sub_eq_zero.mp hsub
  have hfin : Λᵀ * (minkEta * Λ) = minkEta := by
    have := congrArg (fun X => minkEta * X) hM1
    simpa [hMdef, minkEta_cancel] using this
  unfold IsLorentz
  rw [mul_assoc]
  exact hfin

/-- **Reflection, all fields** (corollary): the original weaker form —
equivariance over ALL F (antisymmetric or not) plus nondegeneracy forces
the Lorentz condition. Now a restriction of
`lorentzForce_reflects_antisym`. -/
theorem lorentzForce_reflects {Λ : MinkMat} (hdet : IsUnit Λ.det)
    (h : ∀ F u, lorentzForce 1 (actF Λ F) (Λ.mulVec u)
        = Λ.mulVec (lorentzForce 1 F u)) :
    IsLorentz Λ :=
  lorentzForce_reflects_antisym hdet (fun F _ u => h F u)

/-- **Degenerate countercase (dimension one)**: with a single index every
antisymmetric tensor vanishes, so antisym-equivariance is vacuous and
reflects nothing. Here η collapses to 1, `actF` to Λ F Λᵀ, the force to
F·u; the doubling map is invertible, commutes over all antisymmetric F,
and is not metric-preserving. This is why
`lorentzForce_reflects_antisym` genuinely consumes dimension ≥ 2. -/
theorem antisym_reflection_fails_dim1 :
    ∃ Λ : Matrix (Fin 1) (Fin 1) ℝ, IsUnit Λ.det ∧
      (∀ F : Matrix (Fin 1) (Fin 1) ℝ, Fᵀ = -F → ∀ u : Fin 1 → ℝ,
        (Λ * F * Λᵀ).mulVec (Λ.mulVec u) = Λ.mulVec (F.mulVec u)) ∧
      Λᵀ * Λ ≠ 1 := by
  refine ⟨(2 : ℝ) • 1, ?_, ?_, ?_⟩
  · simp
  · intro F hF u
    have h00 : F 0 0 = 0 := by
      have h := congrFun (congrFun hF 0) 0
      simp [Matrix.transpose_apply, Matrix.neg_apply] at h
      linarith
    have hF0 : F = 0 := by
      ext a b
      have ha : a = 0 := Subsingleton.elim a 0
      have hb : b = 0 := Subsingleton.elim b 0
      simp [ha, hb, h00]
    rw [hF0]
    simp
  · intro hcontra
    have h := congrFun (congrFun hcontra 0) 0
    simp [Matrix.mul_apply, Matrix.smul_apply, Matrix.one_apply] at h
    norm_num at h

/-- **Countermodel**: reflection genuinely needs nondegeneracy. The zero
frame map makes the square commute for every q, F, u, and is not
Lorentz. This is the physics-side analogue of the forcing side's
preservation/reflection asymmetry — the extra hypothesis is real. -/
theorem zero_map_equivariant_not_lorentz :
    ¬ IsLorentz (0 : MinkMat) ∧
      ∀ (q : ℝ) (F : MinkMat) (u : Mink),
        lorentzForce q (actF 0 F) ((0 : MinkMat).mulVec u)
          = (0 : MinkMat).mulVec (lorentzForce q F u) := by
  constructor
  · intro h
    have h00 := congrFun (congrFun h 0) 0
    simp [minkEta, Matrix.diagonal] at h00
  · intro q F u
    simp [actF, lorentzForce]

end ForcingAnalysis
