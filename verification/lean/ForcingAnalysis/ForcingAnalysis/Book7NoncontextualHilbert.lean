/- Book7NoncontextualHilbert.lean — parallelogram geometry and noncontextuality. -/
import Mathlib

namespace ForcingAnalysis.Book7NoncontextualHilbert

abbrev Vec2 := ℝ × ℝ

def add (x y : Vec2) : Vec2 := (x.1 + y.1, x.2 + y.2)
def sub (x y : Vec2) : Vec2 := (x.1 - y.1, x.2 - y.2)

def l1Norm (x : Vec2) : ℝ := |x.1| + |x.2|
def l2NormSq (x : Vec2) : ℝ := x.1 ^ 2 + x.2 ^ 2

def ParallelogramSq (normSq : Vec2 → ℝ) : Prop :=
  ∀ x y, normSq (add x y) + normSq (sub x y) =
    2 * normSq x + 2 * normSq y

/-- The squared Euclidean norm satisfies the parallelogram identity on every
pair of two-dimensional vectors. -/
theorem l2_parallelogram : ParallelogramSq l2NormSq := by
  rintro ⟨x₁, x₂⟩ ⟨y₁, y₂⟩
  simp [l2NormSq, add, sub]
  ring

/-- The L1 cross-section fails the parallelogram identity already on the two
coordinate basis vectors. -/
theorem l1_parallelogram_fails :
    l1Norm (add (1, 0) (0, 1)) ^ 2 +
        l1Norm (sub (1, 0) (0, 1)) ^ 2 ≠
      2 * l1Norm (1, 0) ^ 2 + 2 * l1Norm (0, 1) ^ 2 := by
  norm_num [l1Norm, add, sub]

/-- Once the two source bridges are supplied, noncontextuality is available
exactly at exponent two. -/
theorem noncontextual_iff_hilbert_crossSection
    (Noncontextual HasParallelogram : ℝ → Prop)
    (coherenceBridge : ∀ p, Noncontextual p ↔ HasParallelogram p)
    (lpGeometryBridge : ∀ p, HasParallelogram p ↔ p = 2)
    (p : ℝ) :
    Noncontextual p ↔ p = 2 := by
  exact (coherenceBridge p).trans (lpGeometryBridge p)

/-- Hilbertian geometry alone cannot determine an otherwise unconstrained
coherence functional; the coherence-to-geometry bridge is logically needed. -/
theorem hilbert_geometry_alone_does_not_force_noncontextuality :
    ∃ Noncontextual : ℝ → Prop, ¬ Noncontextual 2 := by
  exact ⟨fun _ => False, by simp⟩

end ForcingAnalysis.Book7NoncontextualHilbert
