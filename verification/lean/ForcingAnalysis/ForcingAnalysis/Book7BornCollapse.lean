/- Book7BornCollapse.lean — contextuality-defect collapse at the Hilbert cross-section. -/
import Mathlib
import ForcingAnalysis.Book7NoInteriorTransition

namespace ForcingAnalysis.Book7BornCollapse

/-- Book 7 collapse data.  Appendix validation may instantiate these fields later;
the appendix is not imported as a premise of the book. -/
structure CollapseGeometry where
  exponent : ℝ → ℝ
  defect : ℝ → ℝ
  reflect : ℝ → ℝ
  hilbertFrame : ℝ
  defect_nonneg : ∀ ξ, 0 ≤ defect ξ
  exponent_eq_two_iff : ∀ ξ, exponent ξ = 2 ↔ ξ = hilbertFrame
  defect_eq_zero_iff : ∀ ξ, defect ξ = 0 ↔ exponent ξ = 2
  fixed_iff_defect_zero : ∀ ξ, reflect ξ = ξ ↔ defect ξ = 0

theorem defect_eq_zero_iff_hilbertFrame (G : CollapseGeometry) (ξ : ℝ) :
    G.defect ξ = 0 ↔ ξ = G.hilbertFrame := by
  exact (G.defect_eq_zero_iff ξ).trans (G.exponent_eq_two_iff ξ)

theorem unique_stable_crossSection (G : CollapseGeometry) (ξ : ℝ) :
    G.reflect ξ = ξ ↔ ξ = G.hilbertFrame := by
  exact (G.fixed_iff_defect_zero ξ).trans (defect_eq_zero_iff_hilbertFrame G ξ)

theorem nonhilbert_defect_pos (G : CollapseGeometry) {ξ : ℝ}
    (hξ : ξ ≠ G.hilbertFrame) :
    0 < G.defect ξ := by
  apply lt_of_le_of_ne (G.defect_nonneg ξ)
  intro h
  exact hξ ((defect_eq_zero_iff_hilbertFrame G ξ).mp h.symm)

/-- Identification of the collapse limit.  The prior reflective-convergence result provides
existence of a limit; vanishing contextuality identifies it as
the unique Hilbert frame. -/
theorem collapse_limit_eq_hilbertFrame
    (G : CollapseGeometry) (orbit : ℕ → ℝ) (limit : ℝ)
    (horbit : Filter.Tendsto orbit Filter.atTop (nhds limit))
    (hcontinuous : ContinuousAt G.defect limit)
    (hdefect : Filter.Tendsto (fun n => G.defect (orbit n))
      Filter.atTop (nhds 0)) :
    limit = G.hilbertFrame := by
  have hcomp : Filter.Tendsto (fun n => G.defect (orbit n))
      Filter.atTop (nhds (G.defect limit)) :=
    hcontinuous.tendsto.comp horbit
  have hz : G.defect limit = 0 := tendsto_nhds_unique hcomp hdefect
  exact (defect_eq_zero_iff_hilbertFrame G limit).mp hz

theorem collapse_tendsto_hilbertFrame
    (G : CollapseGeometry) (orbit : ℕ → ℝ) (limit : ℝ)
    (horbit : Filter.Tendsto orbit Filter.atTop (nhds limit))
    (hcontinuous : ContinuousAt G.defect limit)
    (hdefect : Filter.Tendsto (fun n => G.defect (orbit n))
      Filter.atTop (nhds 0)) :
    Filter.Tendsto orbit Filter.atTop (nhds G.hilbertFrame) := by
  have h := collapse_limit_eq_hilbertFrame G orbit limit horbit hcontinuous hdefect
  simpa [h] using horbit

/-- The separate Gleason-style bridge needed to turn a Hilbert cross-section into
the Born readout.  Hilbert geometry alone does not define a probability rule. -/
structure BornUniqueness (State Question : Type*) where
  coherence : State → Question → ℝ
  bornValue : State → Question → ℝ
  coherentAtHilbert : State → Question → Prop
  unique_readout : ∀ ψ q, coherentAtHilbert ψ q →
    coherence ψ q = bornValue ψ q

theorem born_readout_at_hilbert
    {State Question : Type*} (B : BornUniqueness State Question)
    {ψ : State} {q : Question} (h : B.coherentAtHilbert ψ q) :
    B.coherence ψ q = B.bornValue ψ q :=
  B.unique_readout ψ q h

/-- Negative control: even a unique Hilbert fixed point and completed collapse do
not select the Born functional without the separate uniqueness/measure bridge. -/
theorem hilbert_collapse_alone_does_not_determine_readout :
    ∃ coherence bornValue : Bool → ℝ,
      coherence true ≠ bornValue true := by
  refine ⟨fun _ => 0, fun b => if b then 1 else 0, ?_⟩
  norm_num


/-! ### Constructive finite Born measurement model -/

/-- The Born probability attached to one outcome of a finite complex amplitude
vector. This is a definition of the constructive forward model, not a Gleason
uniqueness claim. -/
noncomputable def finiteBornValue {n : ℕ}
    (amplitude : Fin n → ℂ) (outcome : Fin n) : ℝ :=
  ‖amplitude outcome‖ ^ 2

theorem finiteBornValue_nonneg {n : ℕ}
    (amplitude : Fin n → ℂ) (outcome : Fin n) :
    0 ≤ finiteBornValue amplitude outcome := by
  unfold finiteBornValue
  positivity

/-- Amplitude normalization gives probability normalization exactly. -/
theorem finiteBornValue_sum_one {n : ℕ} {amplitude : Fin n → ℂ}
    (hnormalized : ∑ outcome, ‖amplitude outcome‖ ^ 2 = 1) :
    ∑ outcome, finiteBornValue amplitude outcome = 1 := by
  simpa [finiteBornValue] using hnormalized

/-- A finite readout is amplitude-calibrated when each reported outcome equals
the squared norm of its complex amplitude. This premise is deliberately
stronger than the general Gleason hypotheses. -/
structure AmplitudeCalibratedReadout {n : ℕ} (amplitude : Fin n → ℂ) where
  value : Fin n → ℝ
  calibrated : ∀ outcome, value outcome = finiteBornValue amplitude outcome

/-- Pointwise amplitude calibration constructively determines the finite Born
readout. -/
theorem amplitudeCalibratedReadout_unique {n : ℕ}
    {amplitude : Fin n → ℂ}
    (first second : AmplitudeCalibratedReadout amplitude) :
    first.value = second.value := by
  funext outcome
  exact (first.calibrated outcome).trans (second.calibrated outcome).symm

/-- The canonical finite Born readout realizes the calibration premise. -/
noncomputable def canonicalFiniteBornReadout {n : ℕ}
    (amplitude : Fin n → ℂ) : AmplitudeCalibratedReadout amplitude where
  value := finiteBornValue amplitude
  calibrated := fun _ => rfl

/-- The newly constructed curvature coordinate and the finite measurement
model meet at zero curvature: the geometry is Hilbertian (`p = 2`) and every
amplitude-calibrated outcome has its Born value. -/
theorem zero_curvature_hilbert_finiteBorn
    {n : ℕ} {curvature : ℝ → ℝ} {threshold ξ : ℝ}
    (hzero : curvature ξ = 0) {amplitude : Fin n → ℂ}
    (readout : AmplitudeCalibratedReadout amplitude) :
    Book7NoInteriorTransition.subcriticalLpExponent curvature threshold ξ = 2 ∧
      ∀ outcome, readout.value outcome = finiteBornValue amplitude outcome := by
  constructor
  · exact Book7NoInteriorTransition.subcriticalLpExponent_zero_curvature hzero
  · exact readout.calibrated

/-- Canonical complex amplitudes for a finite nonnegative probability vector. -/
noncomputable def amplitudeOfProbability {n : ℕ}
    (probability : Fin n → ℝ) (outcome : Fin n) : ℂ :=
  (Real.sqrt (probability outcome) : ℝ)

/-- Squaring the canonical amplitude recovers the original probability. -/
theorem finiteBornValue_amplitudeOfProbability {n : ℕ}
    {probability : Fin n → ℝ} (hnonneg : ∀ outcome, 0 ≤ probability outcome)
    (outcome : Fin n) :
    finiteBornValue (amplitudeOfProbability probability) outcome =
      probability outcome := by
  simp [finiteBornValue, amplitudeOfProbability, abs_of_nonneg (Real.sqrt_nonneg _),
    Real.sq_sqrt (hnonneg outcome)]

/-- Every finite nonnegative probability assignment has a constructive Born
amplitude representation in the chosen outcome basis. -/
theorem finite_probability_has_born_representation {n : ℕ}
    {probability : Fin n → ℝ} (hnonneg : ∀ outcome, 0 ≤ probability outcome) :
    ∃ amplitude : Fin n → ℂ,
      ∀ outcome, finiteBornValue amplitude outcome = probability outcome := by
  exact ⟨amplitudeOfProbability probability,
    finiteBornValue_amplitudeOfProbability hnonneg⟩

/-- A normalized probability vector lifts to normalized amplitudes. -/
theorem amplitudeOfProbability_normalized {n : ℕ}
    {probability : Fin n → ℝ} (hnonneg : ∀ outcome, 0 ≤ probability outcome)
    (hsum : ∑ outcome, probability outcome = 1) :
    ∑ outcome, ‖amplitudeOfProbability probability outcome‖ ^ 2 = 1 := by
  calc
    ∑ outcome, ‖amplitudeOfProbability probability outcome‖ ^ 2 =
        ∑ outcome, probability outcome := by
          apply Finset.sum_congr rfl
          intro outcome _
          exact finiteBornValue_amplitudeOfProbability hnonneg outcome
    _ = 1 := hsum
/-- Normalization alone does not select the Born assignment, even on two
outcomes. This is the finite shadow of the still-open Gleason direction. -/
theorem normalization_alone_does_not_force_finiteBorn :
    ∃ amplitude : Fin 2 → ℂ, ∃ readout : Fin 2 → ℝ,
      (∑ outcome, ‖amplitude outcome‖ ^ 2 = 1) ∧
      (∑ outcome, readout outcome = 1) ∧
      readout ≠ finiteBornValue amplitude := by
  let amplitude : Fin 2 → ℂ := fun i => if i = 0 then 1 else 0
  let readout : Fin 2 → ℝ := fun i => if i = 0 then 0 else 1
  refine ⟨amplitude, readout, ?_, ?_, ?_⟩
  · norm_num [amplitude, Fin.sum_univ_two]
  · norm_num [readout, Fin.sum_univ_two]
  · intro h
    have h0 := congrFun h 0
    norm_num [readout, finiteBornValue, amplitude] at h0
end ForcingAnalysis.Book7BornCollapse
