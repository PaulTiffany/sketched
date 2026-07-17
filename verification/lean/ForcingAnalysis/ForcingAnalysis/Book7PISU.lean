/- Book7PISU.lean — coherence-window allocation uncertainty bound. -/
import Mathlib

namespace ForcingAnalysis.Book7PISU

/-- AM–GM for the two positive channel allocations, stated in the exact form
used by the PISU derivation. -/
theorem two_sqrt_product_le_sum {identitySamples curvatureSamples : ℝ}
    (hidentity : 0 ≤ identitySamples) (hcurvature : 0 ≤ curvatureSamples) :
    2 * √(identitySamples * curvatureSamples) ≤
      identitySamples + curvatureSamples := by
  rw [Real.sqrt_mul hidentity]
  have hsquare : 0 ≤ (√identitySamples - √curvatureSamples) ^ 2 := sq_nonneg _
  have hi := Real.sq_sqrt hidentity
  have hk := Real.sq_sqrt hcurvature
  nlinarith

/-- The allocation kernel: a product floor proportional to inverse geometric
mean, combined with a total sample budget, yields the factor-two PISU floor. -/
theorem allocation_uncertainty_bound
    {identitySamples curvatureSamples maxSamples channelScale uncertaintyProduct : ℝ}
    (hidentity : 0 < identitySamples) (hcurvature : 0 < curvatureSamples)
    (hmax : 0 < maxSamples)
    (hbudget : identitySamples + curvatureSamples ≤ maxSamples)
    (hscale : 0 ≤ channelScale)
    (hfloor : channelScale / √(identitySamples * curvatureSamples) ≤
      uncertaintyProduct) :
    2 * channelScale / maxSamples ≤ uncertaintyProduct := by
  have hsqrt : 0 < √(identitySamples * curvatureSamples) :=
    Real.sqrt_pos.2 (mul_pos hidentity hcurvature)
  have hamgm := two_sqrt_product_le_sum
    (le_of_lt hidentity) (le_of_lt hcurvature)
  have hwindow : 2 * √(identitySamples * curvatureSamples) ≤ maxSamples :=
    le_trans hamgm hbudget
  have hscaled :
      2 * channelScale * √(identitySamples * curvatureSamples) ≤
        channelScale * maxSamples := by
    nlinarith [mul_le_mul_of_nonneg_left hwindow hscale]
  have hcompare :
      2 * channelScale / maxSamples ≤
        channelScale / √(identitySamples * curvatureSamples) := by
    exact (div_le_div_iff₀ hmax hsqrt).2 hscaled
  exact le_trans hcompare hfloor

/-- Exact source scaling after substituting the coherence-window budget
`Nmax = bandwidth * resolution / drift`. -/
theorem pisu_derived_bound
    {identitySamples curvatureSamples rootChannelProduct resolution
      drift bandwidth uncertaintyProduct : ℝ}
    (hidentity : 0 < identitySamples) (hcurvature : 0 < curvatureSamples)
    (hroot : 0 ≤ rootChannelProduct) (hresolution : 0 < resolution)
    (hdrift : 0 < drift) (hbandwidth : 0 < bandwidth)
    (hbudget : identitySamples + curvatureSamples ≤
      bandwidth * resolution / drift)
    (hfloor : rootChannelProduct * resolution ^ 2 /
        √(identitySamples * curvatureSamples) ≤ uncertaintyProduct) :
    2 * rootChannelProduct * (drift / bandwidth) * resolution ≤
      uncertaintyProduct := by
  have hmax : 0 < bandwidth * resolution / drift :=
    div_pos (mul_pos hbandwidth hresolution) hdrift
  have h := allocation_uncertainty_bound hidentity hcurvature hmax hbudget
    (mul_nonneg hroot (sq_nonneg resolution)) hfloor
  have hrewrite :
      2 * (rootChannelProduct * resolution ^ 2) /
          (bandwidth * resolution / drift) =
        2 * rootChannelProduct * (drift / bandwidth) * resolution := by
    field_simp
  rwa [hrewrite] at h

/-- The AM–GM allocation bound is sharp at the balanced split. -/
theorem balanced_allocation_saturates_amgm {samples : ℝ} (hsamples : 0 ≤ samples) :
    2 * √(samples * samples) = samples + samples := by
  rw [show samples * samples = samples ^ 2 by ring,
    Real.sqrt_sq_eq_abs, abs_of_nonneg hsamples]
  ring

end ForcingAnalysis.Book7PISU
