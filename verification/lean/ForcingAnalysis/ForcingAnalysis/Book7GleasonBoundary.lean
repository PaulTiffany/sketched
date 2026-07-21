/- Book7GleasonBoundary.lean — the genuine rank-two Gleason obstruction. -/
import Mathlib

namespace ForcingAnalysis.Book7GleasonBoundary

abbrev Vec2 := ℝ × ℝ

/-- Quarter-turn giving the orthogonal companion of a real two-vector. -/
def quarterTurn (x : Vec2) : Vec2 := (-x.2, x.1)

/-- Quartic projective denominator. -/
def quarticDenominator (x : Vec2) : ℝ := x.1 ^ 4 + x.2 ^ 4

/-- A non-Born frame function on the real projective line. -/
noncomputable def quarticFrameValue (x : Vec2) : ℝ :=
  x.1 ^ 4 / quarticDenominator x

/-- Away from the zero vector the quartic denominator is strictly positive. -/
theorem quarticDenominator_pos {x : Vec2} (hx : x ≠ 0) :
    0 < quarticDenominator x := by
  rcases x with ⟨a, b⟩
  unfold quarticDenominator
  by_cases ha : a = 0
  · have hb : b ≠ 0 := by
      intro hb
      apply hx
      simp [ha, hb]
    have hb4 : 0 < b ^ 4 := by positivity
    nlinarith [sq_nonneg (a ^ 2)]
  · have ha4 : 0 < a ^ 4 := by positivity
    nlinarith [sq_nonneg (b ^ 2)]

/-- The quartic frame value is nonnegative. -/
theorem quarticFrameValue_nonnegative (x : Vec2) :
    0 ≤ quarticFrameValue x := by
  unfold quarticFrameValue quarticDenominator
  positivity

/-- It is a ray function: nonzero rescaling does not alter its value. -/
theorem quarticFrameValue_smul {a : ℝ} (ha : a ≠ 0) (x : Vec2) :
    quarticFrameValue (a • x) = quarticFrameValue x := by
  rcases x with ⟨u, v⟩
  unfold quarticFrameValue quarticDenominator
  simp only [smul_eq_mul, Prod.smul_mk]
  have ha4 : a ^ 4 ≠ 0 := pow_ne_zero 4 ha
  field_simp

/-- Every nonzero orthogonal pair is normalized exactly, despite the function
not being quadratic. -/
theorem quartic_orthogonal_pair_normalized {x : Vec2} (hx : x ≠ 0) :
    quarticFrameValue x + quarticFrameValue (quarterTurn x) = 1 := by
  have hden : quarticDenominator x ≠ 0 := ne_of_gt (quarticDenominator_pos hx)
  rcases x with ⟨a, b⟩
  change a ^ 4 / (a ^ 4 + b ^ 4) +
    (-b) ^ 4 / ((-b) ^ 4 + a ^ 4) = 1
  have hden' : a ^ 4 + b ^ 4 ≠ 0 := by
    simpa [quarticDenominator] using hden
  rw [show (-b) ^ 4 = b ^ 4 by ring, add_comm (b ^ 4) (a ^ 4)]
  field_simp [hden']

/-- Every real quadratic form satisfies the parallelogram identity. -/
theorem quadraticForm_parallelogram
    {E : Type*} [AddCommGroup E] [Module ℝ E]
    (Q : QuadraticForm ℝ E) (x y : E) :
    Q (x + y) + Q (x - y) = 2 * Q x + 2 * Q y := by
  rw [QuadraticMap.map_add Q x y]
  rw [show x - y = x + (-y) by abel]
  rw [QuadraticMap.map_add Q x (-y)]
  simp
  ring

/-- The quartic frame function cannot be represented by any quadratic form.
Thus nonnegativity, ray invariance, and normalization on every orthogonal pair
do not imply the Born/quadratic conclusion at frame rank two. -/
theorem quartic_frame_function_is_not_quadratic :
    ¬ ∃ Q : QuadraticForm ℝ Vec2, ∀ x, Q x = quarticFrameValue x := by
  rintro ⟨Q, hQ⟩
  have hpar := quadraticForm_parallelogram Q (1, 0) (0, 1)
  rw [hQ, hQ, hQ, hQ] at hpar
  norm_num [quarticFrameValue, quarticDenominator] at hpar

/-- Explicit rank-two Gleason boundary. -/
theorem rank_two_frame_axioms_do_not_force_born :
    (∀ x : Vec2, 0 ≤ quarticFrameValue x) ∧
    (∀ x : Vec2, x ≠ 0 →
      quarticFrameValue x + quarticFrameValue (quarterTurn x) = 1) ∧
    (∀ a : ℝ, a ≠ 0 → ∀ x : Vec2,
      quarticFrameValue (a • x) = quarticFrameValue x) ∧
    ¬ ∃ Q : QuadraticForm ℝ Vec2, ∀ x, Q x = quarticFrameValue x := by
  exact ⟨quarticFrameValue_nonnegative,
    fun _ hx => quartic_orthogonal_pair_normalized hx,
    fun _ ha _ => quarticFrameValue_smul ha _,
    quartic_frame_function_is_not_quadratic⟩

end ForcingAnalysis.Book7GleasonBoundary
