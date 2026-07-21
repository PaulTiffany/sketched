/-
Book5AlignmentDynamics.lean — temporal reconstruction of reflective drift
alignment in Principia Symbolica Book 5.
-/
import Mathlib
import ForcingAnalysis.Book5Alignment
import ForcingAnalysis.Book5EnhancedDuality

namespace ForcingAnalysis.Book5AlignmentDynamics

open Filter
open scoped Topology

/-- Residual misalignment after `n` mutually reflective updates. -/
def alignmentError (q initialError : ℝ) (n : ℕ) : ℝ := q ^ n * initialError

/-- Realized free-energy contribution: the stable covenant margin diminished by
current alignment error. -/
def realizedContribution (c : Book5.CovenantSnapshot)
    (q initialError : ℝ) (n : ℕ) : ℝ :=
  Book5.driftReflectionContribution c - |alignmentError q initialError n|

/-- The update is genuinely recursive rather than a static renaming. -/
theorem alignmentError_succ (q initialError : ℝ) (n : ℕ) :
    alignmentError q initialError (n + 1) = q * alignmentError q initialError n := by
  simp [alignmentError, pow_succ]
  ring

/-- Contractive mutual reflection drives residual alignment error to zero. -/
theorem alignmentError_tendsto_zero {q initialError : ℝ} (hq : |q| < 1) :
    Tendsto (alignmentError q initialError) atTop (𝓝 0) := by
  have hp := tendsto_pow_atTop_nhds_zero_of_abs_lt_one hq
  change Tendsto (fun n : ℕ => q ^ n * initialError) atTop (𝓝 0)
  simpa using hp.mul_const initialError

/-- The realized contribution converges to the full covenant stability margin. -/
theorem realizedContribution_tendsto_margin
    (c : Book5.CovenantSnapshot) {q initialError : ℝ} (hq : |q| < 1) :
    Tendsto (realizedContribution c q initialError) atTop
      (𝓝 (Book5.driftReflectionContribution c)) := by
  have he := alignmentError_tendsto_zero (initialError := initialError) hq
  have ha : Tendsto (fun n => |alignmentError q initialError n|) atTop (𝓝 0) := by
    simpa using he.abs
  change Tendsto (fun n => Book5.driftReflectionContribution c -
    |alignmentError q initialError n|) atTop
      (𝓝 (Book5.driftReflectionContribution c))
  simpa using tendsto_const_nhds.sub ha

/-- A stable covenant and contractive reflection imply eventual positive
free-energy contribution. This recovers the temporal content of alignment. -/
theorem eventually_realizedContribution_pos
    (c : Book5.CovenantSnapshot) (hStable : Book5.CovenantStable c)
    {q initialError : ℝ} (hq : |q| < 1) :
    ∀ᶠ n in atTop, 0 < realizedContribution c q initialError n := by
  have hMargin : 0 < Book5.driftReflectionContribution c :=
    Book5.reflective_drift_alignment_positive c hStable
  exact Tendsto.eventually_const_lt hMargin
    (realizedContribution_tendsto_margin c hq)

/-- The instantaneous deficit is exactly the remaining alignment magnitude,
so no sign or convergence information is hidden in a custom proxy. -/
theorem margin_sub_realizedContribution
    (c : Book5.CovenantSnapshot) (q initialError : ℝ) (n : ℕ) :
    Book5.driftReflectionContribution c - realizedContribution c q initialError n =
      |alignmentError q initialError n| := by
  simp [realizedContribution]

/-! ## End-to-end MAP alignment certificate -/

/-- The source proposition requires two distinct numerical judgments and a
separate temporal law: MAP classification uses the fixed critical threshold,
whereas positive restoration uses the drift-relative covenant margin. -/
structure ReflectiveAlignmentCertificate where
  coupling : ℝ
  critical : ℝ
  polarity : ℝ
  mapStrong : critical < coupling
  mapPositive : 0 < polarity
  covenant : Book5.CovenantSnapshot
  polarity_eq_stability : polarity = covenant.stability
  coupling_eq_minCoupling : coupling = covenant.minCoupling
  stableMargin : Book5.CovenantStable covenant
  gain : ℝ
  initialError : ℝ
  gain_contracts : |gain| < 1

namespace ReflectiveAlignmentCertificate

/-- One retained certificate realizes the MAP label, strict drift-relative
restoration margin, convergence of residual error, convergence to that margin,
and eventual positive aligned contribution. -/
theorem realizes_reflective_drift_alignment
    (C : ReflectiveAlignmentCertificate) :
    Book5EnhancedDuality.classify C.coupling C.critical C.polarity = .map ∧
      0 < Book5.driftReflectionContribution C.covenant ∧
      Tendsto (alignmentError C.gain C.initialError) atTop (𝓝 0) ∧
      Tendsto (realizedContribution C.covenant C.gain C.initialError) atTop
        (𝓝 (Book5.driftReflectionContribution C.covenant)) ∧
      ∀ᶠ n in atTop,
        0 < realizedContribution C.covenant C.gain C.initialError n := by
  exact ⟨Book5EnhancedDuality.classify_map C.mapStrong C.mapPositive,
    Book5.reflective_drift_alignment_positive C.covenant C.stableMargin,
    alignmentError_tendsto_zero C.gain_contracts,
    realizedContribution_tendsto_margin C.covenant C.gain_contracts,
    eventually_realizedContribution_pos C.covenant C.stableMargin
      C.gain_contracts⟩

end ReflectiveAlignmentCertificate
/-- Static MAP labels do not force convergence: at unit feedback gain the
alignment error can persist forever. -/
theorem positive_margin_without_contraction_does_not_align :
    ∃ (c : Book5.CovenantSnapshot) (initialError : ℝ),
      Book5.CovenantStable c ∧
      (∀ n, alignmentError 1 initialError n = initialError) ∧ initialError ≠ 0 := by
  refine ⟨{ stability := 2, driftA := 0, driftB := 0, minCoupling := 1 }, 1,
    ?_, ?_, by norm_num⟩
  · norm_num [Book5.CovenantStable]
  · intro n
    simp [alignmentError]

end ForcingAnalysis.Book5AlignmentDynamics