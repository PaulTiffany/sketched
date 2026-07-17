/- AppendixCurvatureFlows.lean — completeness and closed Lipschitz bounds. -/
import Mathlib

namespace ForcingAnalysis.AppendixCurvatureFlows

open Filter

/-- Bounded continuous flows into a complete normed space form a complete
metric space under the uniform norm. -/
theorem boundedContinuousFlow_cauchy_converges
    {Time E : Type*} [TopologicalSpace Time]
    [NormedAddCommGroup E] [CompleteSpace E]
    (flow : ℕ → BoundedContinuousFunction Time E) (hflow : CauchySeq flow) :
    ∃ limit : BoundedContinuousFunction Time E, Tendsto flow atTop (nhds limit) :=
  cauchySeq_tendsto_of_complete hflow

/-- A common Lipschitz bound is closed under pointwise convergence. This is the
limit-passage step needed for the admissible curvature-flow class. -/
theorem pointwise_limit_preserves_lipschitz_bound
    {Time E : Type*} [PseudoMetricSpace Time] [PseudoMetricSpace E]
    (flow : ℕ → Time → E) (limit : Time → E) (C : ℝ)
    (hlimit : ∀ t, Tendsto (fun n => flow n t) atTop (nhds (limit t)))
    (hbound : ∀ n s t, dist (flow n s) (flow n t) ≤ C * dist s t) :
    ∀ s t, dist (limit s) (limit t) ≤ C * dist s t := by
  intro s t
  have hdist : Tendsto (fun n => dist (flow n s) (flow n t)) atTop
      (nhds (dist (limit s) (limit t))) :=
    (hlimit s).dist (hlimit t)
  exact le_of_tendsto hdist (Filter.Eventually.of_forall fun n => hbound n s t)

/-- The observer-specific bound C₁*δ is just the preceding closed bound with
that constant substituted. -/
theorem observer_bound_closed_under_pointwise_limit
    {Time E : Type*} [PseudoMetricSpace Time] [PseudoMetricSpace E]
    (flow : ℕ → Time → E) (limit : Time → E) (C₁ δ : ℝ)
    (hlimit : ∀ t, Tendsto (fun n => flow n t) atTop (nhds (limit t)))
    (hbound : ∀ n s t,
      dist (flow n s) (flow n t) ≤ (C₁ * δ) * dist s t) :
    ∀ s t, dist (limit s) (limit t) ≤ (C₁ * δ) * dist s t :=
  pointwise_limit_preserves_lipschitz_bound flow limit (C₁ * δ) hlimit hbound

/-- Pointwise convergence without a common Lipschitz bound does not preserve
any proposed finite bound. -/
theorem pointwise_convergence_alone_does_not_preserve_bound :
    ∃ (flow : ℕ → ℝ → ℝ) (limit : ℝ → ℝ),
      (∀ t, Tendsto (fun n => flow n t) atTop (nhds (limit t))) ∧
        ¬ ∀ s t, dist (limit s) (limit t) ≤ 0 * dist s t := by
  refine ⟨fun _ t => t, id, ?_, ?_⟩
  · intro t
    exact tendsto_const_nhds
  · intro h
    have h01 := h 0 1
    norm_num at h01

end ForcingAnalysis.AppendixCurvatureFlows
