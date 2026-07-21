/- Book7QuadraticTrace.lean — transport from a supplied quadratic witness to
   the finite trace representation used by the Born/Gleason boundary. -/
import ForcingAnalysis.Book4QuantumMeasurement
import ForcingAnalysis.Book7FrameMeasure

namespace ForcingAnalysis.Book7QuadraticTrace

open Book4QuantumMeasurement
open Book7FrameMeasure

/-- The quadratic value of a vector against an operator is already a trace
value: `⟨ψ, ρψ⟩ = Tr(|ψ⟩⟨ψ| ρ)`. This transports the Scholium's quadratic
geometry to Book VII's trace language; it does not construct `ρ`. -/
theorem quadratic_eq_trace_pureStateDensity_mul
    {O : Type*} [Fintype O] [DecidableEq O]
    (ψ : O → ℂ) (ρ : Matrix O O ℂ) :
    vectorExpectation ψ ρ = Matrix.trace (pureStateDensity ψ * ρ) := by
  exact (trace_pureStateDensity_mul ψ ρ).symm

/-- A supplied quadratic representation of a glued global frame measure
transports pointwise to a trace representation. The remaining Gleason step is
existence of `ρ` from weaker non-contextual measure hypotheses. -/
theorem FrameReadoutSystem.globalValue_eq_trace_of_quadratic
    {Frame O : Type*} [Fintype O] [DecidableEq O]
    (system : FrameReadoutSystem Frame O)
    (ray : O → O → ℂ) (ρ : Matrix O O ℂ)
    (hquadratic : ∀ outcome,
      (system.globalValue outcome : ℂ) = vectorExpectation (ray outcome) ρ) :
    ∀ outcome,
      (system.globalValue outcome : ℂ) =
        Matrix.trace (pureStateDensity (ray outcome) * ρ) := by
  intro outcome
  rw [hquadratic outcome]
  exact quadratic_eq_trace_pureStateDensity_mul (ray outcome) ρ

/-- Non-contextual gluing cannot manufacture the missing quadratic witness. -/
theorem gluing_requires_quadratic_existence_bridge :
    ∃ (system : FrameReadoutSystem Bool (Fin 2)) (amplitude : Fin 2 → ℂ),
      system.globalValue ≠ Book7BornCollapse.finiteBornValue amplitude :=
  noncontextual_gluing_alone_does_not_force_born

end ForcingAnalysis.Book7QuadraticTrace