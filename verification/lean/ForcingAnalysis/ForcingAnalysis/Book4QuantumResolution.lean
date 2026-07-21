/-
Book4QuantumResolution.lean — constructive bridge from a reduced quantum
state and an observer response kernel to an observer-induced pullback metric.
-/
import ForcingAnalysis.Book4QuantumMeasurement

namespace ForcingAnalysis.Book4QuantumResolution

open ForcingAnalysis.Book4QuantumMeasurement

/-- The diagonal readout weight of a reduced observer operator. This is the
commuting sector visible to a basis-indexed resolution response. -/
def reducedReadoutWeight {O : Type*} (ρ : Matrix O O ℂ) (o : O) : ℝ :=
  (ρ o o).re

/-- A quantum resolution certificate separates the reduced state, which
weights observer channels, from the response kernel, which maps tangent
directions into those channels. -/
structure QuantumResolutionCertificate (V O : Type*) [Fintype O] where
  reducedState : Matrix O O ℂ
  responseKernel : V → O → ℝ
  diagonal_nonneg : ∀ o, 0 ≤ reducedReadoutWeight reducedState o
  diagonal_normalized : ∑ o, reducedReadoutWeight reducedState o = 1

/-- The observer metric constructed as the weighted pullback of the Euclidean
readout metric along the resolution response. -/
def inducedMetric {V O : Type*} [Fintype O]
    (C : QuantumResolutionCertificate V O) (v w : V) : ℝ :=
  ∑ o, reducedReadoutWeight C.reducedState o *
    C.responseKernel v o * C.responseKernel w o

theorem inducedMetric_symmetric {V O : Type*} [Fintype O]
    (C : QuantumResolutionCertificate V O) (v w : V) :
    inducedMetric C v w = inducedMetric C w v := by
  unfold inducedMetric
  apply Finset.sum_congr rfl
  intro o _
  ring

theorem inducedMetric_diagonal_nonneg {V O : Type*} [Fintype O]
    (C : QuantumResolutionCertificate V O) (v : V) :
    0 ≤ inducedMetric C v v := by
  unfold inducedMetric
  apply Finset.sum_nonneg
  intro o _
  nlinarith [C.diagonal_nonneg o, sq_nonneg (C.responseKernel v o)]

/-- Zero response is invisible in the induced metric. -/
theorem inducedMetric_zero_of_response_zero {V O : Type*} [Fintype O]
    (C : QuantumResolutionCertificate V O) (v : V)
    (hzero : ∀ o, C.responseKernel v o = 0) :
    inducedMetric C v v = 0 := by
  simp [inducedMetric, hzero]

/-- A strictly positive-weight channel detects every direction on which the
response is nonzero. -/
theorem inducedMetric_diagonal_pos_of_channel {V O : Type*} [Fintype O]
    (C : QuantumResolutionCertificate V O) (v : V) (o : O)
    (hweight : 0 < reducedReadoutWeight C.reducedState o)
    (hresponse : C.responseKernel v o ≠ 0) :
    0 < inducedMetric C v v := by
  unfold inducedMetric
  apply Finset.sum_pos'
  · intro i _
    nlinarith [C.diagonal_nonneg i, sq_nonneg (C.responseKernel v i)]
  · refine ⟨o, Finset.mem_univ o, ?_⟩
    nlinarith [sq_pos_of_ne_zero hresponse]

/-- The certificate constructs, rather than merely postulates, the metric
readout once both quantum weights and the resolution response are supplied. -/
theorem quantum_resolution_constructs_observer_metric
    {V O : Type*} [Fintype O]
    (C : QuantumResolutionCertificate V O) :
    ∃ g : V → V → ℝ,
      (∀ v w, g v w = g w v) ∧ (∀ v, 0 ≤ g v v) := by
  refine ⟨inducedMetric C, inducedMetric_symmetric C, ?_⟩
  exact inducedMetric_diagonal_nonneg C

/-- The reduced state cannot identify the resolution kernel. The same
one-channel state supports both a blind response and a detecting response,
which induce different metrics. -/
theorem reduced_state_does_not_determine_resolution_kernel :
    ∃ C₀ C₁ : QuantumResolutionCertificate Unit Unit,
      C₀.reducedState = C₁.reducedState ∧
      inducedMetric C₀ () () ≠ inducedMetric C₁ () () := by
  let ρ : Matrix Unit Unit ℂ := fun _ _ => 1
  let C₀ : QuantumResolutionCertificate Unit Unit :=
    { reducedState := ρ
      responseKernel := fun _ _ => 0
      diagonal_nonneg := by intro o; norm_num [reducedReadoutWeight, ρ]
      diagonal_normalized := by norm_num [reducedReadoutWeight, ρ] }
  let C₁ : QuantumResolutionCertificate Unit Unit :=
    { reducedState := ρ
      responseKernel := fun _ _ => 1
      diagonal_nonneg := by intro o; norm_num [reducedReadoutWeight, ρ]
      diagonal_normalized := by norm_num [reducedReadoutWeight, ρ] }
  refine ⟨C₀, C₁, rfl, ?_⟩
  norm_num [inducedMetric, reducedReadoutWeight, C₀, C₁, ρ]

end ForcingAnalysis.Book4QuantumResolution
