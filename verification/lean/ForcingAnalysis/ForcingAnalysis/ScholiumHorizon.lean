/-
ScholiumHorizon.lean — horizon-crossing conservation and drift-field
emergence (the scholium's horizon cluster, finite kernels).

Sources (Principia scholium, verbatim; sha-bound):

  lemma:bk1_horizon_crossing_conservation — for complementary horizons,
    ∫_{H₁} ρ + ∫_{H₂} 𝓗ρ = const. FINITE KERNEL, exact
    (`crossing_conservation`): a crossing operator whose rows exit
    fully into the complementary horizon transports the H₁-mass
    without loss — the crossed mass equals the source mass, so the
    conserved total is an identity, not an approximation. The
    manifold integral form stays open.
  theorem:bk1_emergence_of_drift_field /
  definition:bk1_proto_drift_field — the drift field as the stabilized
    limit of proto-drift fields through the colimit.
    KERNEL (`drift_field_unique`): pointwise-converging stage fields
    determine their limit field UNIQUELY — any two stabilized limits
    agree everywhere (tendsto uniqueness, fieldwise). Existence is the
    convergence hypothesis (as in the source, where the axioms grant
    it); smoothness and the ordinal colimit stay open.

The dual-horizon postulate itself (axiom:bk1_dual_horizon_postulate —
cognition emerges at the intersection of a generative and a dissipative
horizon) is NOT re-proved here: its certified kernel already exists as
AxiomataPrima.two_channel_sustained (both channels jointly sustain)
with no_drift_no_novelty / pure_drift_dissolves as the two
single-horizon failure controls; the coverage map row records that
correspondence.
-/

import Mathlib

namespace ForcingAnalysis.ScholiumHzn

open Filter

variable {n : ℕ}

/-- **Horizon-crossing conservation, finite and exact**
(lemma:bk1_horizon_crossing_conservation): if the crossing operator's
rows exit fully into the complementary horizon (∑_{j ∉ H} P i j = 1 on
H), then the crossed mass equals the source mass — the total
∑_{H} ρ + ∑_{Hᶜ} 𝓗ρ is conserved as an identity. -/
theorem crossing_conservation (H : Finset (Fin n))
    (P : Matrix (Fin n) (Fin n) ℝ) (ρ : Fin n → ℝ)
    (hexit : ∀ i ∈ H, ∑ j ∈ Hᶜ, P i j = 1) :
    ∑ j ∈ Hᶜ, ∑ i ∈ H, ρ i * P i j = ∑ i ∈ H, ρ i := by
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i hi => ?_
  rw [← Finset.mul_sum, hexit i hi, mul_one]

variable {M : Type*} {k : ℕ}

/-- **Drift-field emergence, uniqueness kernel**
(theorem:bk1_emergence_of_drift_field): pointwise-converging proto-drift
stage fields determine their stabilized limit UNIQUELY — any two limit
fields agree at every point and component. Existence is the convergence
hypothesis (the source's axioms grant it); smoothness and the ordinal
colimit stay open. -/
theorem drift_field_unique (Dproto : ℕ → M → Fin k → ℝ)
    (D D' : M → Fin k → ℝ)
    (hD : ∀ p i, Tendsto (fun l => Dproto l p i) atTop (nhds (D p i)))
    (hD' : ∀ p i, Tendsto (fun l => Dproto l p i) atTop (nhds (D' p i))) :
    D = D' := by
  funext p i
  exact tendsto_nhds_unique (hD p i) (hD' p i)

end ForcingAnalysis.ScholiumHzn
