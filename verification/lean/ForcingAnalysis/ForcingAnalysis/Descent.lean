/-
Descent.lean — the metric/analytic layer of forcing_correspondence_v15,
over mathlib: the Cauchy–Forcing Completion Lemma (lem:cauchy) and the
Order–Metric Compatibility Lemma (lem:ordmet).

Hypothesis accounting (matching the paper's ledger):
* the residual-instability potential V and the descent constant κ are the
  (M)/(C) inputs — here explicit hypotheses;
* hypothesis (c) of lem:cauchy ("d_O comparable to the embedding norm",
  added in v15 after the audit found it hidden in the v14 proof) is
  discharged by stating the lemma directly in the observer metric space;
* completeness of the observer completion \bar P_O is the [CompleteSpace]
  instance (Principia interface, M).
-/

import Mathlib

namespace ForcingAnalysis

open Filter

/-- **Cauchy–Forcing Completion** (lem:cauchy): a nonnegative Lyapunov
potential with linear descent rate forces absolutely summable increments,
hence convergence of the trajectory in the (complete) observer space.
Note the v14 monotonicity hypothesis (a) is implied by (b) + κ > 0. -/
theorem cauchy_forcing_completion {X : Type*} [MetricSpace X] [CompleteSpace X]
    (z : ℕ → X) (V : ℕ → ℝ) (κ : ℝ) (hκ : 0 < κ)
    (hV0 : ∀ n, 0 ≤ V n)
    (hdesc : ∀ n, κ * dist (z n) (z (n + 1)) ≤ V n - V (n + 1)) :
    ∃ x : X, Tendsto z atTop (nhds x) := by
  -- telescoping: the V-differences are nonnegative with partial sums ≤ V 0
  have hterm : ∀ n, 0 ≤ V n - V (n + 1) := fun n =>
    le_trans (mul_nonneg hκ.le dist_nonneg) (hdesc n)
  have htel : Summable (fun n => V n - V (n + 1)) := by
    apply summable_of_sum_range_le (c := V 0) hterm
    intro n
    rw [Finset.sum_range_sub' V]
    linarith [hV0 n]
  -- increments are dominated by the summable V-differences (scaled)
  have hd : ∀ n, dist (z n) (z (n + 1)) ≤ (V n - V (n + 1)) / κ := by
    intro n
    rw [le_div_iff₀ hκ, mul_comm]
    exact hdesc n
  have hcauchy : CauchySeq z :=
    cauchySeq_of_dist_le_of_summable _ hd (htel.div_const κ)
  exact cauchySeq_tendsto_of_complete hcauchy

/-- **Order–Metric Compatibility** (lem:ordmet): if the trajectory is
eventually inside a d_O-closed stabilized region (postulate M-Cl is the
`IsClosed` hypothesis) and converges, the limit lies in the region. The
persistence input (M-Pers) is the `hmem` eventuality — supplied upstream
by the order-side argument of the kernel. -/
theorem order_metric_compatibility {X : Type*} [MetricSpace X]
    {z : ℕ → X} {x : X} {S : Set X}
    (hclosed : IsClosed S) (N : ℕ) (hmem : ∀ n, N ≤ n → z n ∈ S)
    (hlim : Tendsto z atTop (nhds x)) : x ∈ S :=
  hclosed.mem_of_tendsto hlim (eventually_atTop.2 ⟨N, hmem⟩)

end ForcingAnalysis
