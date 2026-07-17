import Mathlib
import ForcingAnalysis.Book2H

namespace ForcingAnalysis.Book2Response
noncomputable section
open Finset ForcingAnalysis.Book2
variable {n : ℕ} [NeZero n]

def responsePartition (β : ℝ) (H B : Fin n → ℝ) (h : ℝ) : ℝ :=
  ∑ i, Real.exp (-β * H i + h * (β * B i))

def responseNumerator (β : ℝ) (H A B : Fin n → ℝ) (h : ℝ) : ℝ :=
  ∑ i, Real.exp (-β * H i + h * (β * B i)) * A i

def perturbedExpectation (β : ℝ) (H A B : Fin n → ℝ) (h : ℝ) : ℝ :=
  responseNumerator β H A B h / responsePartition β H B h

def covariance (ρ : Fin n → ℝ) (A B : Fin n → ℝ) : ℝ :=
  (∑ i, ρ i * (A i * B i)) - (∑ i, ρ i * A i) * (∑ i, ρ i * B i)

omit [NeZero n] in
private theorem exponent_hasDerivAt (β : ℝ) (H B : Fin n → ℝ) (h : ℝ) (i : Fin n) :
    HasDerivAt (fun u : ℝ => -β * H i + u * (β * B i)) (β * B i) h := by
  simpa using ((hasDerivAt_id h).mul_const (β * B i)).const_add (-β * H i)

omit [NeZero n] in
private theorem responseNumerator_hasDerivAt (β : ℝ) (H A B : Fin n → ℝ) (h : ℝ) :
    HasDerivAt (fun u => responseNumerator β H A B u)
      (∑ i, Real.exp (-β * H i + h * (β * B i)) * (β * B i) * A i) h := by
  unfold responseNumerator
  refine HasDerivAt.fun_sum fun i _ => ?_
  have he : HasDerivAt (fun u : ℝ => Real.exp (-β * H i + u * (β * B i)))
      (Real.exp (-β * H i + h * (β * B i)) * (β * B i)) h :=
    (exponent_hasDerivAt β H B h i).exp
  simpa [mul_assoc] using he.mul_const (A i)

omit [NeZero n] in
private theorem responsePartition_hasDerivAt (β : ℝ) (H B : Fin n → ℝ) (h : ℝ) :
    HasDerivAt (fun u => responsePartition β H B u)
      (∑ i, Real.exp (-β * H i + h * (β * B i)) * (β * B i)) h := by
  unfold responsePartition
  refine HasDerivAt.fun_sum fun i _ => ?_
  exact (exponent_hasDerivAt β H B h i).exp

/-- Finite static Kubo identity: the first-order response to H_h = H - hB
is beta times the equilibrium covariance. This is the finite kernel of
`theorem:bk2_symbolic_fluctuation_dissipation_relation`; no differentiable
time semigroup is asserted. -/
theorem fluctuation_response_hasDerivAt (β : ℝ) (H A B : Fin n → ℝ) :
    HasDerivAt (perturbedExpectation β H A B)
      (β * covariance (gibbs β H) A B) 0 := by
  have hn := responseNumerator_hasDerivAt β H A B 0
  have hz := responsePartition_hasDerivAt β H B 0
  have hz0 : responsePartition β H B 0 ≠ 0 := by
    simpa [responsePartition, partition] using (partition_pos β H).ne'
  have hq := hn.div hz hz0
  change HasDerivAt
    ((fun u => responseNumerator β H A B u) / fun u => responsePartition β H B u)
    (β * covariance (gibbs β H) A B) 0
  apply hq.congr_deriv
  simp only [responseNumerator, responsePartition, partition, covariance, gibbs,
    zero_mul, add_zero]
  simp_rw [div_mul_eq_mul_div]
  rw [← Finset.sum_div, ← Finset.sum_div, ← Finset.sum_div]
  have hAB : (∑ x, Real.exp (-β * H x) * (β * B x) * A x) =
      β * ∑ x, Real.exp (-β * H x) * (A x * B x) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x _
    ring
  have hB : (∑ x, Real.exp (-β * H x) * (β * B x)) =
      β * ∑ x, Real.exp (-β * H x) * B x := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro x _
    ring
  rw [hAB, hB]
  field_simp [partition_pos β H |>.ne']

end
end ForcingAnalysis.Book2Response