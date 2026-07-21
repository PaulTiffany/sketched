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


/-! ### Type-correct finite-dimensional operator reconstruction -/

/-- Environmental partial trace of an operator on `O ⊗ E`, represented in a
fixed finite product basis. Unlike `partialTraceDiagonal`, this retains the
observer off-diagonal entries. -/
def partialTraceEnvironment {O E : Type*} [Fintype E]
    (X : Matrix (O × E) (O × E) ℂ) : Matrix O O ℂ :=
  fun o o' => ∑ e, X (o, e) (o', e)

/-- Lift an observer operator to the joint space as `B ⊗ I_E`. -/
def liftObserverOperator {O E : Type*} [DecidableEq E]
    (B : Matrix O O ℂ) : Matrix (O × E) (O × E) ℂ :=
  fun x y => if x.2 = y.2 then B x.1 y.1 else 0

/-- The joint expectation `Tr(ρ A)`. -/
def jointMatrixExpectation {O E : Type*} [Fintype O] [Fintype E]
    [DecidableEq O] [DecidableEq E]
    (ρ A : Matrix (O × E) (O × E) ℂ) : ℂ :=
  Matrix.trace (ρ * A)

/-- Partial trace preserves the trace of an arbitrary joint operator. -/
theorem trace_partialTraceEnvironment {O E : Type*}
    [Fintype O] [Fintype E] [DecidableEq O] [DecidableEq E]
    (X : Matrix (O × E) (O × E) ℂ) :
    Matrix.trace (partialTraceEnvironment X) = Matrix.trace X := by
  classical
  simp [Matrix.trace, partialTraceEnvironment, Fintype.sum_prod_type]

/-- The reduced-state identity for every joint operator and every local
observer observable. Correlation and mixedness are allowed: purity is not a
premise of this theorem. -/
theorem jointExpectation_local_eq_reduced {O E : Type*}
    [Fintype O] [Fintype E] [DecidableEq O] [DecidableEq E]
    (ρ : Matrix (O × E) (O × E) ℂ) (B : Matrix O O ℂ) :
    jointMatrixExpectation ρ (liftObserverOperator B) =
      Matrix.trace (partialTraceEnvironment ρ * B) := by
  classical
  simp [jointMatrixExpectation, Matrix.trace, Matrix.mul_apply,
    liftObserverOperator, partialTraceEnvironment, Fintype.sum_prod_type, Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro o _
  rw [Finset.sum_comm]

/-- Density operator of a supplied observer vector in a fixed basis. -/
def pureStateDensity {O : Type*} (ψ : O → ℂ) : Matrix O O ℂ :=
  fun i j => ψ i * star (ψ j)

/-- Vector-state expectation in coordinates. -/
def vectorExpectation {O : Type*} [Fintype O]
    (ψ : O → ℂ) (B : Matrix O O ℂ) : ℂ :=
  ∑ i, ∑ j, star (ψ i) * B i j * ψ j

/-- The trace expectation of a pure-state density is the usual bra-ket
expectation. This is where the source's vector formula legitimately enters. -/
theorem trace_pureStateDensity_mul {O : Type*}
    [Fintype O] [DecidableEq O] (ψ : O → ℂ) (B : Matrix O O ℂ) :
    Matrix.trace (pureStateDensity ψ * B) = vectorExpectation ψ B := by
  classical
  simp [Matrix.trace, Matrix.mul_apply, pureStateDensity, vectorExpectation]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring_nf

/-- A typed bridge from the quantum reduction to the observer-induced metric.
The equality is evidence supplied by the physical model; partial trace alone
does not manufacture it. -/
structure QuantumObserverMetricCertificate
    (P V O E : Type*) [Fintype O] [Fintype E]
    [DecidableEq O] [DecidableEq E] where
  jointDensity : Matrix (O × E) (O × E) ℂ
  metricOperator : P → V → V → Matrix O O ℂ
  observerMetric : P → V → V → ℂ
  metric_eq_reduced_expectation : ∀ p v w,
    observerMetric p v w =
      Matrix.trace
        (partialTraceEnvironment jointDensity * metricOperator p v w)

/-- The certificate exposes the reduced expectation claimed by the repaired
source, without identifying an arbitrary joint state with a pure observer. -/
theorem observerMetric_eq_reduced {P V O E : Type*}
    [Fintype O] [Fintype E] [DecidableEq O] [DecidableEq E]
    (C : QuantumObserverMetricCertificate P V O E) (p : P) (v w : V) :
    C.observerMetric p v w =
      Matrix.trace
        (partialTraceEnvironment C.jointDensity * C.metricOperator p v w) :=
  C.metric_eq_reduced_expectation p v w

end ForcingAnalysis.Book4QuantumMeasurement
