/- Book7SystemicPower.lean — finite-basin systemic-power kernel. -/
import Mathlib

namespace ForcingAnalysis.Book7SystemicPower

/-- Scalar local power from confidence, gradient magnitude, and effective
symbolic volume, matching the multiplicative integrand in Book 7. -/
def localPower (confidence gradientMagnitude volume : ℝ) : ℝ :=
  confidence * gradientMagnitude * volume

theorem localPower_pos {confidence gradientMagnitude volume : ℝ}
    (hconfidence : 0 < confidence) (hgradient : 0 < gradientMagnitude)
    (hvolume : 0 < volume) :
    0 < localPower confidence gradientMagnitude volume := by
  exact mul_pos (mul_pos hconfidence hgradient) hvolume

/-- A finite regulatory basin with an explicit conditional density. -/
structure FiniteBasin (Index : Type*) [Fintype Index] where
  density : Index → ℝ
  confidence : Index → ℝ
  gradientMagnitude : Index → ℝ
  volume : Index → ℝ

def systemicPower {Index : Type*} [Fintype Index]
    (basin : FiniteBasin Index) : ℝ :=
  ∑ index : Index,
    basin.density index *
      localPower (basin.confidence index)
        (basin.gradientMagnitude index) (basin.volume index)

/-- Positive density, confidence, gradient magnitude, and volume throughout a
nonempty finite basin force strictly positive systemic power. -/
theorem systemicPower_pos {Index : Type*} [Fintype Index] [Nonempty Index]
    (basin : FiniteBasin Index)
    (hdensity : ∀ index, 0 < basin.density index)
    (hconfidence : ∀ index, 0 < basin.confidence index)
    (hgradient : ∀ index, 0 < basin.gradientMagnitude index)
    (hvolume : ∀ index, 0 < basin.volume index) :
    0 < systemicPower basin := by
  unfold systemicPower
  exact Finset.sum_pos
    (fun index _ =>
      mul_pos (hdensity index)
        (localPower_pos (hconfidence index) (hgradient index) (hvolume index)))
    Finset.univ_nonempty

/-- High confidence alone supplies no power when the confidence landscape is
flat: the gradient factor remains a logically necessary premise. -/
theorem high_confidence_alone_does_not_force_power :
    localPower 1 0 1 = 0 := by
  norm_num [localPower]

/-- The norm-valued integrand used by the source forgets gradient orientation. -/
def unorientedLocalPower (confidence directedGradient volume : ℝ) : ℝ :=
  localPower confidence |directedGradient| volume

theorem gradient_reversal_preserves_unoriented_power
    (confidence directedGradient volume : ℝ) :
    unorientedLocalPower confidence (-directedGradient) volume =
      unorientedLocalPower confidence directedGradient volume := by
  simp [unorientedLocalPower]

/-- Concrete countermodel: opposite directed gradients receive identical
positive scalar power, so coherent alignment cannot be inferred from the norm. -/
theorem equal_power_does_not_determine_gradient_orientation :
    unorientedLocalPower 1 (-1) 1 = unorientedLocalPower 1 1 1 ∧
      (-1 : ℝ) ≠ 1 := by
  norm_num [unorientedLocalPower, localPower]

end ForcingAnalysis.Book7SystemicPower
