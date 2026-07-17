/- Book5ShadeTransfer.lean — shade transport and golden radial-step kernel. -/
import ForcingAnalysis.Book4A
import ForcingAnalysis.Book5Reciprocity

namespace ForcingAnalysis.Book5ShadeTransfer

/-- Exact preservation of radius preserves every shade normalization. -/
theorem shade_preserved_of_radius_preserved {Radius Shade : Type*}
    (shade : Radius → Shade) {radius transferredRadius : Radius}
    (h : transferredRadius = radius) :
    shade transferredRadius = shade radius := by
  rw [h]

/-- Preserving radial order is weaker than preserving radial values and hence
does not by itself preserve shade. -/
theorem radial_order_alone_does_not_preserve_shade :
    ∃ transfer : ℕ → ℕ, StrictMono transfer ∧ transfer 1 ≠ 1 := by
  refine ⟨fun radius => radius + 1, ?_, by norm_num⟩
  intro first second h
  exact Nat.add_lt_add_right h 1

/-- On the golden spiral, the logarithm of the radius increases by exactly
`log φ` at every discrete mode transition. -/
theorem golden_logRadius_step (r0 : ℝ) (hr0 : 0 < r0) (n : ℕ) :
    Real.log (Book4A.spiralMagnitude Book4A.goldenRatio r0 (n + 1)) -
      Real.log (Book4A.spiralMagnitude Book4A.goldenRatio r0 n) =
        Real.log Book4A.goldenRatio := by
  have hcurrent : 0 < Book4A.spiralMagnitude Book4A.goldenRatio r0 n := by
    simp only [Book4A.spiralMagnitude]
    exact mul_pos (pow_pos Book4A.goldenRatio_pos n) hr0
  rw [Book4A.spiralMagnitude_recurrence]
  rw [Real.log_mul Book4A.goldenRatio_pos.ne' hcurrent.ne']
  ring

/-- A standard bounded shade normalization. -/
noncomputable def normalizedShade (reference radius : ℝ) : ℝ :=
  radius / (radius + reference)

/-- Multiplicative radius steps do not remain multiplicative shade steps after
bounded normalization: doubling radius from one to two does not double shade. -/
theorem normalized_shade_is_not_multiplicative :
    normalizedShade 1 2 ≠ 2 * normalizedShade 1 1 := by
  norm_num [normalizedShade]

/-- Balanced reciprocity selects the golden radial growth rate. -/
theorem balanced_reciprocity_paints_golden_rate :
    Book5.reciprocityRate 1 = Real.goldenRatio :=
  Book5.reciprocityRate_one

/-- At zero reciprocal weight the spectral growth rate is one, so the radial
coordinate has no multiplicative growth. -/
theorem extraction_has_unit_radial_rate :
    Book5.reciprocityRate 0 = 1 :=
  Book5.reciprocityRate_zero

end ForcingAnalysis.Book5ShadeTransfer
