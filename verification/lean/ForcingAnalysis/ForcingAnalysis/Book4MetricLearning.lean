/-
Book4MetricLearning.lean — gradient-step kernel and premise audit for machine
learning of the observer metric in Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4MetricLearning

/-- Scalar parameter shadow of a metric-learning gradient step. -/
def gradientStep (theta eta gradient : ℝ) : ℝ :=
  theta - eta * gradient

/-- With nonzero learning rate, a gradient step is stationary exactly at a
critical point. -/
theorem gradientStep_eq_self_iff {theta eta gradient : ℝ} (hEta : eta ≠ 0) :
    gradientStep theta eta gradient = theta ↔ gradient = 0 := by
  unfold gradientStep
  constructor
  · intro h
    apply (mul_eq_zero.mp (by linarith : eta * gradient = 0)).resolve_left hEta
  · rintro rfl
    ring

/-- For the quadratic local loss L(theta)=theta², a step size strictly between
zero and one gives strict descent away from the optimum. -/
theorem quadratic_gradient_step_decreases
    {theta eta : ℝ} (hTheta : theta ≠ 0) (hEtaPos : 0 < eta) (hEtaLt : eta < 1) :
    (gradientStep theta eta (2 * theta)) ^ 2 < theta ^ 2 := by
  unfold gradientStep
  have hThetaSq : 0 < theta ^ 2 := sq_pos_of_ne_zero hTheta
  have hFactor : (1 - 2 * eta) ^ 2 < 1 := by nlinarith [mul_pos hEtaPos (sub_pos.mpr hEtaLt)]
  nlinarith [mul_lt_mul_of_pos_right hFactor hThetaSq]

/-- Differentiability alone does not make an arbitrary positive learning rate
a descent method: an oversized quadratic step increases loss. -/
theorem differentiability_alone_does_not_guarantee_descent :
    let theta : ℝ := 1
    let eta : ℝ := 2
    (gradientStep theta eta (2 * theta)) ^ 2 > theta ^ 2 := by
  norm_num [gradientStep]

/- ================================================================
   Deep realization: validity, descent, convergence, identifiability
   ================================================================ -/

/-- A log-parameter gives a positive scalar metric coefficient. This is the
one-dimensional positive-definite model; matrix-valued SPD retractions remain
a later analytic layer. -/
noncomputable def positiveMetric (logParameter : ℝ) : ℝ :=
  Real.exp logParameter

theorem positiveMetric_pos (logParameter : ℝ) :
    0 < positiveMetric logParameter :=
  Real.exp_pos logParameter

/-- Quadratic parameter-space risk around a supplied realizable target. -/
def metricLoss (target parameter : ℝ) : ℝ :=
  (parameter - target) ^ 2

/-- The exact gradient of `metricLoss target` in its scalar parameter. -/
def metricLossGradient (target parameter : ℝ) : ℝ :=
  2 * (parameter - target)

/-- One gradient update for the realizable quadratic model. -/
def metricLearningStep (target eta parameter : ℝ) : ℝ :=
  gradientStep parameter eta (metricLossGradient target parameter)

/-- A step size in `(0,1)` strictly decreases loss away from the target. -/
theorem metricLearningStep_strict_descent
    {target eta parameter : ℝ} (hParameter : parameter ≠ target)
    (hEtaPos : 0 < eta) (hEtaLt : eta < 1) :
    metricLoss target (metricLearningStep target eta parameter) <
      metricLoss target parameter := by
  have hError : parameter - target ≠ 0 := sub_ne_zero.mpr hParameter
  unfold metricLoss metricLearningStep metricLossGradient
  convert quadratic_gradient_step_decreases
    (theta := parameter - target) (eta := eta) hError hEtaPos hEtaLt using 1
  all_goals simp [gradientStep]
  all_goals ring

/-- Closed form of the recursive learning trajectory. -/
def learnedParameter (target eta initial : ℝ) (n : ℕ) : ℝ :=
  target + (1 - 2 * eta) ^ n * (initial - target)

theorem learnedParameter_zero (target eta initial : ℝ) :
    learnedParameter target eta initial 0 = initial := by
  simp [learnedParameter]

theorem learnedParameter_succ (target eta initial : ℝ) (n : ℕ) :
    learnedParameter target eta initial (n + 1) =
      metricLearningStep target eta (learnedParameter target eta initial n) := by
  simp [learnedParameter, metricLearningStep, metricLossGradient,
    gradientStep, pow_succ]
  ring

/-- The log-parameterized metric remains positive at every learning step; no
unconstrained scalar update can cross the positive-definite boundary. -/
theorem learnedMetric_positive (target eta initial : ℝ) (n : ℕ) :
    0 < positiveMetric (learnedParameter target eta initial n) :=
  positiveMetric_pos _

/-- Under the same step-size regime, the full recursive trajectory converges to
the supplied target parameter. -/
theorem learnedParameter_tendsto_target
    {target eta initial : ℝ} (hEtaPos : 0 < eta) (hEtaLt : eta < 1) :
    Filter.Tendsto (learnedParameter target eta initial)
      Filter.atTop (nhds target) := by
  have hFactor : |1 - 2 * eta| < 1 := by
    rw [abs_lt]
    constructor <;> linarith
  have hpow : Filter.Tendsto (fun n : ℕ => (1 - 2 * eta) ^ n)
      Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hFactor
  have hscaled := hpow.mul_const (initial - target)
  change Filter.Tendsto
    (fun n : ℕ => target + (1 - 2 * eta) ^ n * (initial - target))
    Filter.atTop (nhds target)
  simpa using tendsto_const_nhds.add hscaled

/-- An observation model identifies parameters only when its readout is
injective. This premise is distinct from descent and convergence. -/
structure IdentifiableReadout (Observation : Type*) where
  readout : ℝ → Observation
  injective : Function.Injective readout

theorem target_identified_from_equal_readout
    {Observation : Type*} (R : IdentifiableReadout Observation)
    {candidate target : ℝ} (h : R.readout candidate = R.readout target) :
    candidate = target :=
  R.injective h

/-- The positive scalar metric parameterization itself is identifiable: equal
metric coefficients imply equal log-parameters. -/
theorem positiveMetric_injective : Function.Injective positiveMetric := by
  intro a b h
  exact Real.exp_injective h

/-- A complete scalar metric-learning certificate keeps the four bridges
visible: validity, step-size control, realizable target, and identifiability. -/
structure MetricLearningCertificate (Observation : Type*) where
  target : ℝ
  eta : ℝ
  initial : ℝ
  eta_pos : 0 < eta
  eta_lt_one : eta < 1
  observation : IdentifiableReadout Observation

/-- The certificate yields validity of every learned metric and convergence of
its parameter trajectory. Identification still uses the supplied injective
readout rather than being inferred from convergence alone. -/
theorem certified_metric_learning
    {Observation : Type*} (C : MetricLearningCertificate Observation) :
    (∀ n, 0 < positiveMetric (learnedParameter C.target C.eta C.initial n)) ∧
    Filter.Tendsto (learnedParameter C.target C.eta C.initial)
      Filter.atTop (nhds C.target) :=
  ⟨learnedMetric_positive C.target C.eta C.initial,
    learnedParameter_tendsto_target C.eta_pos C.eta_lt_one⟩
end ForcingAnalysis.Book4MetricLearning
