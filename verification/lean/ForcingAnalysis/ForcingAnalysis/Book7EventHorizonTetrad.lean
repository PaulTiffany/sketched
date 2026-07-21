/- Book7EventHorizonTetrad.lean — finite BH/WH tetrad reconstruction. -/
import ForcingAnalysis.Book7NoncontextualHilbert

namespace ForcingAnalysis.Book7EventHorizonTetrad

/-- Black-hole-like structure and white-hole-like novelty are the two endpoint
labels used on each axis of the Event Horizon tetrad. -/
inductive HorizonState where
  | bh
  | wh
  deriving DecidableEq, Repr

/-- The Boolean coordinate of one horizon state. -/
def coordinate : HorizonState → ℝ
  | .bh => 0
  | .wh => 1

abbrev Quadrant := HorizonState × HorizonState

/-- Mixed input/output coefficient: the discrete cross-difference of all four
quadrant values. -/
def mixedCoefficient (field : Quadrant → ℝ) : ℝ :=
  field (.wh, .wh) - field (.wh, .bh) -
    field (.bh, .wh) + field (.bh, .bh)

/-- The canonical affine-bilinear polynomial reconstructed from the four
quadrant values. -/
def reconstructedValue (field : Quadrant → ℝ)
    (input output : HorizonState) : ℝ :=
  field (.bh, .bh) +
  (field (.wh, .bh) - field (.bh, .bh)) * coordinate input +
  (field (.bh, .wh) - field (.bh, .bh)) * coordinate output +
  mixedCoefficient field * coordinate input * coordinate output

/-- Exhaustive tetrad reconstruction: the affine-bilinear polynomial recovers
every value on all four BH/WH input-output corners. -/
theorem reconstructedValue_eq
    (field : Quadrant → ℝ) (input output : HorizonState) :
    reconstructedValue field input output = field (input, output) := by
  cases input <;> cases output
  · simp [reconstructedValue, mixedCoefficient, coordinate]
  · simp [reconstructedValue, mixedCoefficient, coordinate]
  · simp [reconstructedValue, mixedCoefficient, coordinate]
  · simp [reconstructedValue, mixedCoefficient, coordinate]
    ring

/-- Additive separability means there is no input-output interaction term. -/
def AdditivelySeparable (field : Quadrant → ℝ) : Prop :=
  ∃ base inputEffect outputEffect : ℝ,
    ∀ input output,
      field (input, output) = base +
        inputEffect * coordinate input + outputEffect * coordinate output

/-- On the exhaustive tetrad, vanishing mixed residue is exactly additive
separability. -/
theorem mixedCoefficient_eq_zero_iff_separable (field : Quadrant → ℝ) :
    mixedCoefficient field = 0 ↔ AdditivelySeparable field := by
  constructor
  · intro hmixed
    refine ⟨field (.bh, .bh),
      field (.wh, .bh) - field (.bh, .bh),
      field (.bh, .wh) - field (.bh, .bh), ?_⟩
    intro input output
    rw [← reconstructedValue_eq field input output]
    simp [reconstructedValue, hmixed]
  · rintro ⟨base, inputEffect, outputEffect, hfield⟩
    simp [mixedCoefficient, hfield, coordinate]

/-- A nonzero mixed coefficient is therefore an explicit finite witness that
the quadrant field cannot be decomposed into independent input and output
contributions. -/
theorem nonzero_mixedCoefficient_iff_nonseparable (field : Quadrant → ℝ) :
    mixedCoefficient field ≠ 0 ↔ ¬ AdditivelySeparable field := by
  exact not_congr (mixedCoefficient_eq_zero_iff_separable field)

/-- Tetrad reconstruction always supplies an affine-bilinear interaction
coordinate, but this alone cannot force a metric parallelogram law: the L1
countermodel remains available. -/
theorem tetrad_reconstruction_does_not_force_hilbert_metric :
    (∀ field : Quadrant → ℝ, ∀ input output,
      reconstructedValue field input output = field (input, output)) ∧
    ¬ Book7NoncontextualHilbert.ParallelogramSq
      Book7NoncontextualHilbert.l1NormSq := by
  constructor
  · exact reconstructedValue_eq
  · exact Book7NoncontextualHilbert.commuting_transport_does_not_force_metric_parallelogram.2

end ForcingAnalysis.Book7EventHorizonTetrad