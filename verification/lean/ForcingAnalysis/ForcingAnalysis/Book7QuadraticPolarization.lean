/- Book7QuadraticPolarization.lean — canonical bilinear recovery from quadratic data. -/
import Mathlib

namespace ForcingAnalysis.Book7QuadraticPolarization

/-- A genuine real quadratic readout canonically determines a symmetric
bilinear coupling whose diagonal recovers the readout exactly. This removes
the earlier coordinate restriction; it does not derive quadraticity from
noncontextual frame gluing. -/
theorem quadraticForm_has_symmetric_bilinear_representation
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (Q : QuadraticForm ℝ E) :
    ∃ B : LinearMap.BilinForm ℝ E,
      (∀ x y, B x y = B y x) ∧ (∀ x, B x x = Q x) := by
  refine ⟨QuadraticMap.associated Q, ?_, ?_⟩
  · exact QuadraticMap.associated_isSymm ℝ Q
  · exact QuadraticMap.associated_eq_self_apply ℝ Q

/-- Nonnegative quadratic data induce a positive-semidefinite diagonal on the
canonical symmetric bilinear representation. -/
theorem associated_diagonal_nonnegative
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (Q : QuadraticForm ℝ E) (hnonnegative : ∀ x, 0 ≤ Q x) :
    ∀ x, 0 ≤ QuadraticMap.associated Q x x := by
  intro x
  rw [QuadraticMap.associated_eq_self_apply ℝ Q]
  exact hnonnegative x

/-- Mere nonnegativity does not manufacture quadratic structure: absolute
value is nonnegative, but its linear scaling contradicts quadratic scaling. -/
theorem nonnegative_readout_does_not_force_quadratic :
    (∀ x : ℝ, 0 ≤ |x|) ∧
      ¬ ∃ Q : QuadraticForm ℝ ℝ, ∀ x, Q x = |x| := by
  constructor
  · exact fun x => abs_nonneg x
  · rintro ⟨Q, hQ⟩
    have hscale := Q.map_smul (2 : ℝ) (1 : ℝ)
    rw [hQ, hQ] at hscale
    norm_num at hscale


/-- The exact algebraic laws a scalar readout must satisfy to construct a real
quadratic form. These are the remaining targets for a Gleason-style derivation
from frame coherence; they are not consequences of nonnegativity alone. -/
structure QuadraticReadoutLaws (E : Type*) [AddCommGroup E] [Module ℝ E] where
  value : E → ℝ
  degreeTwo : ∀ (a : ℝ) (x : E),
    value (a • x) = (a * a) • value x
  polar_add_left : ∀ x x' y : E,
    QuadraticMap.polar value (x + x') y =
      QuadraticMap.polar value x y + QuadraticMap.polar value x' y
  polar_smul_left : ∀ (a : ℝ) (x y : E),
    QuadraticMap.polar value (a • x) y =
      a • QuadraticMap.polar value x y

/-- The certificate laws construct a genuine Mathlib quadratic form. -/
def QuadraticReadoutLaws.toQuadraticForm
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (certificate : QuadraticReadoutLaws E) : QuadraticForm ℝ E :=
  QuadraticMap.ofPolar certificate.value certificate.degreeTwo
    certificate.polar_add_left certificate.polar_smul_left

@[simp]
theorem QuadraticReadoutLaws.toQuadraticForm_apply
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (certificate : QuadraticReadoutLaws E) (x : E) :
    certificate.toQuadraticForm x = certificate.value x :=
  rfl

/-- Conversely, every quadratic form exposes exactly the certificate laws. -/
def QuadraticReadoutLaws.ofQuadraticForm
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (Q : QuadraticForm ℝ E) : QuadraticReadoutLaws E where
  value := Q
  degreeTwo := Q.map_smul
  polar_add_left := Q.polar_add_left
  polar_smul_left := Q.polar_smul_left

/-- The certificate-to-form-to-certificate round trip preserves every readout
value. -/
theorem QuadraticReadoutLaws.roundtrip_value
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (certificate : QuadraticReadoutLaws E) :
    (QuadraticReadoutLaws.ofQuadraticForm certificate.toQuadraticForm).value =
      certificate.value := by
  rfl

/-- Once the explicit readout laws are certified, symmetric bilinear
representation follows constructively and coordinate-free. -/
theorem certified_readout_has_symmetric_bilinear_representation
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (certificate : QuadraticReadoutLaws E) :
    ∃ B : LinearMap.BilinForm ℝ E,
      (∀ x y, B x y = B y x) ∧
      (∀ x, B x x = certificate.value x) := by
  simpa using
    quadraticForm_has_symmetric_bilinear_representation
      certificate.toQuadraticForm

end ForcingAnalysis.Book7QuadraticPolarization
