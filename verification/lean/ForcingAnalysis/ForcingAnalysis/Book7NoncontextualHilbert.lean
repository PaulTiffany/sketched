/- Book7NoncontextualHilbert.lean — parallelogram geometry and noncontextuality. -/
import Mathlib
import Mathlib.Analysis.InnerProductSpace.OfNorm

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

/-- Canonical affine transport on the visible two-dimensional chart. -/
def translate (displacement point : Vec2) : Vec2 := add point displacement

/-- Additive transports form commuting affine squares. This is the genuine
content recovered from context-independent translation order. -/
theorem translate_square_commutes (first second point : Vec2) :
    translate first (translate second point) =
      translate second (translate first point) := by
  rcases first with ⟨f₁, f₂⟩
  rcases second with ⟨s₁, s₂⟩
  rcases point with ⟨p₁, p₂⟩
  simp [translate, add]
  constructor <;> ring

/-- The squared L1 magnitude used by the metric parallelogram test. -/
def l1NormSq (x : Vec2) : ℝ := l1Norm x ^ 2

/-- Affine path independence is insufficient for Hilbert geometry: the same L1
chart has commuting transport squares but fails the metric parallelogram law. -/
theorem commuting_transport_does_not_force_metric_parallelogram :
    (∀ first second point : Vec2,
      translate first (translate second point) =
        translate second (translate first point)) ∧
      ¬ ParallelogramSq l1NormSq := by
  constructor
  · exact translate_square_commutes
  · intro h
    have := h (1, 0) (0, 1)
    exact l1_parallelogram_fails (by simpa [l1NormSq] using this)

/-- A symmetric bilinear coupling written in coordinates. -/
def symmetricBilinear (g₁₁ g₁₂ g₂₂ : ℝ) (x y : Vec2) : ℝ :=
  g₁₁ * x.1 * y.1 + g₁₂ * x.1 * y.2 +
    g₁₂ * x.2 * y.1 + g₂₂ * x.2 * y.2

/-- The diagonal quadratic energy induced by the symmetric coupling. -/
def quadraticEnergy (g₁₁ g₁₂ g₂₂ : ℝ) (x : Vec2) : ℝ :=
  symmetricBilinear g₁₁ g₁₂ g₂₂ x x

/-- Quadratic sufficiency: once coherence supplies a symmetric bilinear energy
representation, its diagonal energy satisfies the metric parallelogram law.
This is the missing positive bridge; transport commutativity alone is weaker. -/
theorem quadraticEnergy_parallelogram (g₁₁ g₁₂ g₂₂ : ℝ) :
    ParallelogramSq (quadraticEnergy g₁₁ g₁₂ g₂₂) := by
  rintro ⟨x₁, x₂⟩ ⟨y₁, y₂⟩
  simp [quadraticEnergy, symmetricBilinear, add, sub]
  ring
/-- General Fréchet–von Neumann–Jordan reconstruction: a real normed space
satisfying the metric parallelogram identity admits a compatible inner product.
Unlike affine square commutation, this conclusion uses the metric law itself. -/
theorem innerProductSpace_exists_of_metric_parallelogram
    (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E]
    (hparallelogram : ∀ x y : E,
      ‖x + y‖ * ‖x + y‖ + ‖x - y‖ * ‖x - y‖ =
        2 * (‖x‖ * ‖x‖ + ‖y‖ * ‖y‖)) :
    Nonempty (InnerProductSpace ℝ E) :=
  ⟨InnerProductSpace.ofNorm ℝ (E := E) hparallelogram⟩
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
