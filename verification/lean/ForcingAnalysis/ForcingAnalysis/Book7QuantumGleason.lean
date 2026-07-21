/- Book7QuantumGleason.lean — phase-faithful complex quadratic readouts. -/
import ForcingAnalysis.Book7QuadraticTrace
import ForcingAnalysis.Book4QuantumResolution

namespace ForcingAnalysis.Book7QuantumGleason

open Book4QuantumMeasurement

/-- Complex operator expectations scale by `star a * a = |a|²`, not by the
real-quadratic coefficient `a²`. This is the phase-faithful quantum law. -/
theorem vectorExpectation_smul
    {O : Type*} [Fintype O]
    (a : ℂ) (ψ : O → ℂ) (ρ : Matrix O O ℂ) :
    vectorExpectation (a • ψ) ρ =
      (star a * a) * vectorExpectation ψ ρ := by
  classical
  simp [vectorExpectation, Finset.mul_sum,
    mul_comm, mul_left_comm, mul_assoc]

/-- Global phase is operationally invisible to every operator expectation. -/
theorem vectorExpectation_globalPhase
    {O : Type*} [Fintype O]
    {u : ℂ} (hphase : star u * u = 1)
    (ψ : O → ℂ) (ρ : Matrix O O ℂ) :
    vectorExpectation (u • ψ) ρ = vectorExpectation ψ ρ := by
  rw [vectorExpectation_smul, hphase, one_mul]

/-- The real `a²` scaling law is not the quantum law: multiplication by `i`
has unit modulus although its ordinary square is `-1`. -/
theorem complex_phase_refutes_real_degreeTwo :
    star (Complex.I) * Complex.I ≠ Complex.I * Complex.I := by
  norm_num

/-- A complex projective readout exposes the phase-faithful homogeneity law
required upstream of a Hermitian/Gleason reconstruction. -/
structure QuantumRayReadout (State : Type*) [AddCommMonoid State]
    [Module ℂ State] where
  value : State → ℂ
  scale : ∀ (a : ℂ) (ψ : State),
    value (a • ψ) = (star a * a) * value ψ

/-- Every finite operator expectation is a phase-faithful quantum ray
readout. No Hermiticity, positivity, or frame normalization is inferred here. -/
def operatorQuantumRayReadout
    {O : Type*} [Fintype O] (ρ : Matrix O O ℂ) :
    QuantumRayReadout (O → ℂ) where
  value := fun ψ => vectorExpectation ψ ρ
  scale := fun a ψ => vectorExpectation_smul a ψ ρ

/-- The constructed operator readout is invariant under every certified global
phase. -/
theorem operatorQuantumRayReadout_globalPhase
    {O : Type*} [Fintype O] (ρ : Matrix O O ℂ)
    {u : ℂ} (hphase : star u * u = 1) (ψ : O → ℂ) :
    (operatorQuantumRayReadout ρ).value (u • ψ) =
      (operatorQuantumRayReadout ρ).value ψ := by
  exact vectorExpectation_globalPhase hphase ψ ρ


/-- Exact phase-faithful reconstruction data. The cross term is conjugate-linear
in its first input, linear in its second, Hermitian under exchange, and has the
observed ray readout on its diagonal. The observer-boundary results below show
that arbitrary resolved data do not reconstruct these laws, while legitimate
richer pure-state data preserve them through forward lowering. -/
structure HermitianReadoutCertificate (State : Type*) [AddCommMonoid State]
    [Module ℂ State] where
  value : State → ℂ
  cross : State → State → ℂ
  cross_add_left : ∀ x x' y,
    cross (x + x') y = cross x y + cross x' y
  cross_smul_left : ∀ (a : ℂ) x y,
    cross (a • x) y = star a • cross x y
  cross_add_right : ∀ x y y',
    cross x (y + y') = cross x y + cross x y'
  cross_smul_right : ∀ (a : ℂ) x y,
    cross x (a • y) = a • cross x y
  hermitian : ∀ x y, star (cross x y) = cross y x
  diagonal : ∀ x, cross x x = value x

/-- The explicit cross laws construct a genuine Mathlib complex
sesquilinear form. -/
def HermitianReadoutCertificate.toSesquilinear
    {State : Type*} [AddCommMonoid State] [Module ℂ State]
    (certificate : HermitianReadoutCertificate State) :
    State →ₗ⋆[ℂ] State →ₗ[ℂ] ℂ :=
  LinearMap.mk₂'ₛₗ (starRingEnd ℂ) (RingHom.id ℂ)
    certificate.cross certificate.cross_add_left
    certificate.cross_smul_left certificate.cross_add_right
    certificate.cross_smul_right

@[simp]
theorem HermitianReadoutCertificate.toSesquilinear_apply
    {State : Type*} [AddCommMonoid State] [Module ℂ State]
    (certificate : HermitianReadoutCertificate State) (x y : State) :
    certificate.toSesquilinear x y = certificate.cross x y :=
  rfl

/-- The constructed sesquilinear form is Hermitian. -/
theorem HermitianReadoutCertificate.toSesquilinear_isSymm
    {State : Type*} [AddCommMonoid State] [Module ℂ State]
    (certificate : HermitianReadoutCertificate State) :
    certificate.toSesquilinear.IsSymm := by
  exact ⟨certificate.hermitian⟩

/-- The constructed Hermitian form recovers the complete readout on its
diagonal. -/
theorem HermitianReadoutCertificate.toSesquilinear_diagonal
    {State : Type*} [AddCommMonoid State] [Module ℂ State]
    (certificate : HermitianReadoutCertificate State) (x : State) :
    certificate.toSesquilinear x x = certificate.value x :=
  certificate.diagonal x

/-- The Hermitian certificate itself forces the correct quantum modulus-squared
scaling on the observed diagonal. -/
theorem HermitianReadoutCertificate.value_smul
    {State : Type*} [AddCommMonoid State] [Module ℂ State]
    (certificate : HermitianReadoutCertificate State)
    (a : ℂ) (x : State) :
    certificate.value (a • x) =
      (star a * a) * certificate.value x := by
  rw [← certificate.diagonal (a • x)]
  rw [certificate.cross_smul_left, certificate.cross_smul_right]
  rw [certificate.diagonal]
  simp [smul_eq_mul, mul_assoc]

/-- The dashed Hermitian reconstruction closes once the explicit cross laws
are supplied: a genuine Hermitian sesquilinear form exists and represents the
readout diagonally. -/
theorem hermitian_reconstruction_from_certificate
    {State : Type*} [AddCommMonoid State] [Module ℂ State]
    (certificate : HermitianReadoutCertificate State) :
    ∃ B : State →ₗ⋆[ℂ] State →ₗ[ℂ] ℂ,
      B.IsSymm ∧ ∀ x, B x x = certificate.value x := by
  exact ⟨certificate.toSesquilinear,
    certificate.toSesquilinear_isSymm,
    certificate.toSesquilinear_diagonal⟩

/-- The operator-level pure-state construction is Hermitian before any observer
resolution is chosen. -/
theorem pureStateDensity_isHermitian {O : Type*} (ψ : O → ℂ) :
    (pureStateDensity ψ).IsHermitian := by
  apply Matrix.IsHermitian.ext
  intro i j
  simp [pureStateDensity, mul_comm]

/-- Forward lowering from a normalized operator-level pure state into the
existing observer-resolution certificate. The response kernel is observer
data; the upstream density supplies the resolved diagonal weights. -/
noncomputable def pureStateToResolution
    {V O : Type*} [Fintype O]
    (ψ : O → ℂ) (response : V → O → ℝ)
    (hnormalized : ∑ o, Complex.normSq (ψ o) = 1) :
    Book4QuantumResolution.QuantumResolutionCertificate V O where
  reducedState := pureStateDensity ψ
  responseKernel := response
  diagonal_nonneg := by
    intro o
    simpa [Book4QuantumResolution.reducedReadoutWeight, pureStateDensity,
      Complex.normSq_apply] using Complex.normSq_nonneg (ψ o)
  diagonal_normalized := by
    simpa [Book4QuantumResolution.reducedReadoutWeight, pureStateDensity,
      Complex.normSq_apply] using hnormalized

/-- The forward lowering retains the richer source's Hermiticity even though
that invariant is not recoverable from an arbitrary lowered certificate. -/
theorem pureStateToResolution_reducedState_isHermitian
    {V O : Type*} [Fintype O]
    (ψ : O → ℂ) (response : V → O → ℝ)
    (hnormalized : ∑ o, Complex.normSq (ψ o) = 1) :
    (pureStateToResolution ψ response hnormalized).reducedState.IsHermitian :=
  pureStateDensity_isHermitian ψ

/-- Global phase is forgotten by the operator-level density lowering. -/
theorem pureStateDensity_globalPhase
    {O : Type*} (ψ : O → ℂ) {u : ℂ} (hphase : star u * u = 1) :
    pureStateDensity (u • ψ) = pureStateDensity ψ := by
  funext i j
  change u * ψ i * star (u * ψ j) = ψ i * star (ψ j)
  rw [star_mul]
  calc
    u * ψ i * (star (ψ j) * star u) =
        (star u * u) * (ψ i * star (ψ j)) := by ring
    _ = ψ i * star (ψ j) := by rw [hphase, one_mul]

/-- Extensional equality for the observer-resolution record; its remaining
fields are proofs of properties of the retained matrix and response. -/
theorem quantumResolutionCertificate_ext
    {V O : Type*} [Fintype O]
    {C D : Book4QuantumResolution.QuantumResolutionCertificate V O}
    (hstate : C.reducedState = D.reducedState)
    (hresponse : C.responseKernel = D.responseKernel) : C = D := by
  cases C
  cases D
  cases hstate
  cases hresponse
  rfl
/-- Global phase produces the same actual observer-resolution certificate when
the observer response is held fixed. The proof fields are propositionally
irrelevant; the retained matrix and response data coincide. -/
theorem pureStateToResolution_globalPhase
    {V O : Type*} [Fintype O]
    (ψ : O → ℂ) (response : V → O → ℝ)
    {u : ℂ} (hphase : star u * u = 1)
    (hnormalized : ∑ o, Complex.normSq (ψ o) = 1)
    (hnormalizedPhase : ∑ o, Complex.normSq ((u • ψ) o) = 1) :
    pureStateToResolution (u • ψ) response hnormalizedPhase =
      pureStateToResolution ψ response hnormalized := by
  apply quantumResolutionCertificate_ext
  · exact pureStateDensity_globalPhase ψ hphase
  · rfl
/-- Concrete non-injectivity of the lowering: two distinct normalized source
vectors related by global sign have exactly the same lowered density. -/
theorem pureState_lowering_not_injective :
    ∃ first second : Fin 1 → ℂ,
      first ≠ second ∧
      (∑ o, ‖first o‖ ^ 2 = 1) ∧
      (∑ o, ‖second o‖ ^ 2 = 1) ∧
      pureStateDensity first = pureStateDensity second := by
  let first : Fin 1 → ℂ := fun _ => 1
  let second : Fin 1 → ℂ := fun _ => -1
  refine ⟨first, second, ?_, by simp [first], by simp [second], ?_⟩
  · intro h
    have h0 := congrFun h 0
    norm_num [first, second] at h0
  · funext i j
    fin_cases i
    fin_cases j
    norm_num [pureStateDensity, first, second]
/-- The sesquilinear cross term already carried by a finite operator matrix. -/
def operatorCross {O : Type*} [Fintype O]
    (ρ : Matrix O O ℂ) (x y : O → ℂ) : ℂ :=
  ∑ i, ∑ j, star (x i) * ρ i j * y j

/-- The nearest richer source object in the lake is the quantum-resolution
certificate: it already carries a finite complex operator. When that very
operator satisfies the matrix equation forced by Hermitian exchange, its
readout constructs the existing Hermitian certificate directly. -/
def quantumResolutionHermitianReadoutCertificate
    {V O : Type*} [Fintype O]
    (C : Book4QuantumResolution.QuantumResolutionCertificate V O)
    (hHermitian : C.reducedState.IsHermitian) :
    HermitianReadoutCertificate (O → ℂ) where
  value := fun x => vectorExpectation x C.reducedState
  cross := operatorCross C.reducedState
  cross_add_left := by
    intro x x' y
    simp [operatorCross, Finset.sum_add_distrib, add_mul]
  cross_smul_left := by
    intro a x y
    simp [operatorCross, Finset.mul_sum, mul_assoc]
  cross_add_right := by
    intro x y y'
    simp [operatorCross, Finset.sum_add_distrib, mul_add]
  cross_smul_right := by
    intro a x y
    simp only [operatorCross, Pi.smul_apply, smul_eq_mul]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    ring
  hermitian := by
    intro x y
    change (starRingEnd ℂ) (∑ i, ∑ j,
      star (x i) * C.reducedState i j * y j) = _
    calc
      (starRingEnd ℂ) (∑ i, ∑ j,
          star (x i) * C.reducedState i j * y j) =
          ∑ i, ∑ j, star (y j) * star (C.reducedState i j) * x i := by
            rw [map_sum]
            apply Finset.sum_congr rfl
            intro i hi
            rw [map_sum]
            apply Finset.sum_congr rfl
            intro j hj
            rw [map_mul, map_mul]
            change star (star (x i)) * star (C.reducedState i j) * star (y j) = _
            rw [star_star]
            ring
      _ =
          ∑ i, ∑ j, star (y j) * C.reducedState j i * x i := by
            apply Finset.sum_congr rfl
            intro i hi
            apply Finset.sum_congr rfl
            intro j hj
            have hij : star (C.reducedState i j) = C.reducedState j i :=
              hHermitian.apply j i
            rw [hij]
      _ = ∑ j, ∑ i, star (y j) * C.reducedState j i * x i :=
        Finset.sum_comm
      _ = ∑ i, ∑ j, star (y i) * C.reducedState i j * x j := rfl
  diagonal := by
    intro x
    rfl

/-- Retrying the single implication on the richer existing source object:
the matrix Hermiticity equation is sufficient to inhabit the exact existing
reconstruction certificate, with no intermediate Gleason-axiom package. -/
theorem quantumResolution_to_hermitian_certificate
    {V O : Type*} [Fintype O]
    (C : Book4QuantumResolution.QuantumResolutionCertificate V O)
    (hHermitian : C.reducedState.IsHermitian) :
    ∃ certificate : HermitianReadoutCertificate (O → ℂ),
      ∀ x, certificate.value x = vectorExpectation x C.reducedState := by
  exact ⟨quantumResolutionHermitianReadoutCertificate C hHermitian, fun _ => rfl⟩
/-- The legitimate richer source follows the forward chain into the existing
Hermitian reconstruction certificate and then into observer resolution. -/
theorem pureState_forward_chain
    {V O : Type*} [Fintype O]
    (ψ : O → ℂ) (response : V → O → ℝ)
    (hnormalized : ∑ o, Complex.normSq (ψ o) = 1) :
    ∃ certificate : HermitianReadoutCertificate (O → ℂ),
      ∀ x, certificate.value x = vectorExpectation x (pureStateDensity ψ) := by
  let resolved := pureStateToResolution ψ response hnormalized
  simpa [resolved, pureStateToResolution] using
    quantumResolution_to_hermitian_certificate resolved
      (pureStateToResolution_reducedState_isHermitian ψ response hnormalized)

/-- The quantum-resolution source contract itself does not enforce the matrix
equation used above. Its diagonal constraints admit a non-Hermitian reduced
state whose vector expectation is not real, hence cannot be any Hermitian
diagonal. -/
theorem quantumResolution_without_matrixHermiticity_does_not_supply_certificate :
    ∃ C : Book4QuantumResolution.QuantumResolutionCertificate Unit (Fin 2),
      ¬ ∃ certificate : HermitianReadoutCertificate (Fin 2 → ℂ),
        ∀ x, certificate.value x = vectorExpectation x C.reducedState := by
  let ρ : Matrix (Fin 2) (Fin 2) ℂ := fun i j =>
    if i = 0 ∧ j = 0 then 1 else if i = 0 ∧ j = 1 then 1 else 0
  let C : Book4QuantumResolution.QuantumResolutionCertificate Unit (Fin 2) := {
    reducedState := ρ
    responseKernel := fun _ _ => 0
    diagonal_nonneg := by
      intro i
      fin_cases i <;> norm_num [Book4QuantumResolution.reducedReadoutWeight, ρ]
    diagonal_normalized := by
      norm_num [Book4QuantumResolution.reducedReadoutWeight, ρ, Fin.sum_univ_two]
  }
  refine ⟨C, ?_⟩
  rintro ⟨certificate, hvalue⟩
  let ψ : Fin 2 → ℂ := fun i => if i = 0 then 1 else Complex.I
  have hself := certificate.hermitian ψ ψ
  rw [certificate.diagonal] at hself
  rw [hvalue] at hself
  norm_num [vectorExpectation, C, ρ, ψ, Fin.sum_univ_two] at hself
  have him := congrArg Complex.im hself
  norm_num at him
/-- Exact provenance result for the remaining premise: the current upstream
quantum-resolution contract does not force its reduced state to be Hermitian.
This is derived from the preserved non-Hermitian witness and the proved fact
that Hermiticity would construct the forbidden certificate. -/
theorem quantumResolution_does_not_force_reducedState_isHermitian :
    ∃ C : Book4QuantumResolution.QuantumResolutionCertificate Unit (Fin 2),
      ¬ C.reducedState.IsHermitian := by
  obtain ⟨C, hnoCertificate⟩ :=
    quantumResolution_without_matrixHermiticity_does_not_supply_certificate
  refine ⟨C, ?_⟩
  intro hHermitian
  exact hnoCertificate ⟨quantumResolutionHermitianReadoutCertificate C hHermitian,
    fun _ => rfl⟩
/-- A fully covered, normalized, noncontextual frame system admitted by the
existing coherence type. Each frame exposes its own singleton outcome. -/
noncomputable def singletonConstantFrameSystem :
    Book7FrameMeasure.FrameReadoutSystem ℂ ℂ where
  outcomes := fun frame => {frame}
  value := fun _ _ => 1
  covered := by
    intro outcome
    exact ⟨outcome, by simp⟩
  nonnegative := by
    intro frame outcome hmember
    norm_num
  normalized := by
    intro frame
    simp
  noncontextual := by
    intro first second outcome hfirst hsecond
    rfl

/-- The present complete-frame coherence structure does not determine the
Hermitian certificate. It admits a normalized, covered, noncontextual system
whose glued readout is constantly one, whereas every Hermitian diagonal must
vanish at the zero vector. Thus no term of the requested bridge type can be
constructed from the existing structure alone. -/
theorem completeFrameCoherence_does_not_supply_hermitian_certificate :
    ¬ ∃ certificate : HermitianReadoutCertificate ℂ,
      ∀ x, certificate.value x =
        (singletonConstantFrameSystem.globalValue x : ℂ) := by
  rintro ⟨certificate, hvalue⟩
  have hzero : certificate.value (0 : ℂ) = 0 := by
    have hscale := certificate.value_smul (0 : ℂ) (1 : ℂ)
    simpa using hscale
  have hglobal :
      (singletonConstantFrameSystem.globalValue (0 : ℂ) : ℂ) = 1 := by
    rw [singletonConstantFrameSystem.globalValue_eq_local
      (frame := (0 : ℂ)) (outcome := (0 : ℂ)) (by simp [singletonConstantFrameSystem])]
    simp [singletonConstantFrameSystem]
  rw [hvalue, hglobal] at hzero
  exact one_ne_zero hzero

end ForcingAnalysis.Book7QuantumGleason
