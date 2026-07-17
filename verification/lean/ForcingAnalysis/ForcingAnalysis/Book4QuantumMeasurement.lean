/-
Book4QuantumMeasurement.lean — finite partial-trace and observer-support
kernel for Principia Symbolica Book 4's quantum measurement interpretation.
-/
import Mathlib

namespace ForcingAnalysis.Book4QuantumMeasurement

/-- Diagonal finite partial trace over environmental degrees of freedom. -/
def partialTraceDiagonal {O E : Type*} [Fintype E]
    (density observable : O → E → ℝ) (observer : O) : ℝ :=
  ∑ environment, density observer environment * observable observer environment

/-- Full finite joint expectation of a diagonal observable. -/
def jointExpectation {O E : Type*} [Fintype O] [Fintype E]
    (density observable : O → E → ℝ) : ℝ :=
  ∑ observer, ∑ environment,
    density observer environment * observable observer environment

/-- Partial trace is exact regrouping, not an additional physical law. -/
theorem jointExpectation_eq_sum_partialTrace {O E : Type*}
    [Fintype O] [Fintype E] (density observable : O → E → ℝ) :
    jointExpectation density observable =
      ∑ observer, partialTraceDiagonal density observable observer := by
  rfl

theorem jointExpectation_nonneg {O E : Type*} [Fintype O] [Fintype E]
    (density observable : O → E → ℝ)
    (hDensity : ∀ o e, 0 ≤ density o e)
    (hObservable : ∀ o e, 0 ≤ observable o e) :
    0 ≤ jointExpectation density observable := by
  unfold jointExpectation
  exact Finset.sum_nonneg fun o _ =>
    Finset.sum_nonneg fun e _ => mul_nonneg (hDensity o e) (hObservable o e)

/-- Joint density supported on one observer state with environmental weights. -/
def pureObserverDensity {O E : Type*} [DecidableEq O]
    (observer₀ : O) (environmentWeight : E → ℝ) : O → E → ℝ :=
  fun observer environment =>
    if observer = observer₀ then environmentWeight environment else 0

/-- Under the explicit single-observer support premise, the full joint
expectation reduces to that observer's environmentally averaged value. -/
theorem jointExpectation_pureObserver {O E : Type*}
    [Fintype O] [Fintype E] [DecidableEq O]
    (observer₀ : O) (environmentWeight : E → ℝ) (observable : O → E → ℝ) :
    jointExpectation (pureObserverDensity observer₀ environmentWeight) observable =
      ∑ environment, environmentWeight environment * observable observer₀ environment := by
  classical
  simp [jointExpectation, pureObserverDensity]

/-- Without the support/factorization premise, a joint expectation need not
equal the partial-trace value at a chosen observer state. -/
theorem joint_state_does_not_reduce_to_arbitrary_observer :
    let density : Bool → Unit → ℝ := fun observer _ => if observer then 1 else 0
    let observable : Bool → Unit → ℝ := fun observer _ => if observer then 2 else 1
    jointExpectation density observable ≠
      partialTraceDiagonal density observable false := by
  norm_num [jointExpectation, partialTraceDiagonal]

end ForcingAnalysis.Book4QuantumMeasurement
