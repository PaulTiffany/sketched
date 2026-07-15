/- 
Book5Thermodynamics.lean - conditional thermodynamic and covenant core.

This module formalizes the algebraic consequences of Book 5's stated laws.
It does not assert that an arbitrary symbolic system satisfies those laws.
Each modeling commitment is a field of a named structure, so the theorem
dependency remains visible in the type.
-/

import Mathlib

namespace ForcingAnalysis.Book5

/-- Observer-resolved thermodynamic data at one condition. -/
structure ThermodynamicSnapshot where
  coherentEnergy : Real
  temperature : Real
  entropy : Real

def freeEnergy (s : ThermodynamicSnapshot) : Real :=
  s.coherentEnergy - s.temperature * s.entropy

def Viable (s : ThermodynamicSnapshot) : Prop :=
  0 < freeEnergy s

theorem viable_iff_positive_free_energy (s : ThermodynamicSnapshot) :
    Viable s <-> 0 < s.coherentEnergy - s.temperature * s.entropy :=
  Iff.rfl

theorem not_viable_of_energy_le_entropic_cost (s : ThermodynamicSnapshot)
    (h : s.coherentEnergy <= s.temperature * s.entropy) :
    Not (Viable s) := by
  unfold Viable freeEnergy
  linarith

theorem viable_of_entropic_cost_lt_energy (s : ThermodynamicSnapshot)
    (h : s.temperature * s.entropy < s.coherentEnergy) :
    Viable s := by
  unfold Viable freeEnergy
  linarith

/-- The closed-system balance law from axiom:bk5_energy_conservation.
The law is data, not a global axiom in Lean. -/
structure ClosedEnergyEntropyBalance where
  energyRate : Real
  entropyRate : Real
  temperature : Real
  balance : energyRate + temperature * entropyRate = 0

theorem energy_rate_eq_neg_entropic_rate
    (b : ClosedEnergyEntropyBalance) :
    b.energyRate = -(b.temperature * b.entropyRate) := by
  linarith [b.balance]

theorem entropy_rate_eq_neg_energy_rate_div
    (b : ClosedEnergyEntropyBalance) (hT : Not (b.temperature = 0)) :
    b.entropyRate = -b.energyRate / b.temperature := by
  rw [eq_div_iff hT]
  nlinarith [b.balance]

/-- Production minus reflective removal. The second-law comparison is an
explicit hypothesis, matching the conditional content of Book 5. -/
structure EntropyBalance where
  production : Real
  reflectiveRemoval : Real
  production_nonneg : 0 <= production
  removal_nonneg : 0 <= reflectiveRemoval
  secondLaw : reflectiveRemoval <= production

def entropyRate (b : EntropyBalance) : Real :=
  b.production - b.reflectiveRemoval

theorem entropy_rate_nonnegative (b : EntropyBalance) :
    0 <= entropyRate b := by
  unfold entropyRate
  linarith [b.secondLaw]

/-- Book 5's fixed-point reading is a calibration law. It is not inferred
from nonnegative production alone. -/
structure ReflectiveEquilibrium (State : Type) where
  balance : State -> EntropyBalance
  fixedPoint : State -> Prop
  fixed_iff_zero_rate :
    forall x, fixedPoint x <-> entropyRate (balance x) = 0

theorem entropy_rate_eq_zero_iff_fixed {State : Type}
    (e : ReflectiveEquilibrium State) (x : State) :
    entropyRate (e.balance x) = 0 <-> e.fixedPoint x :=
  (e.fixed_iff_zero_rate x).symm

/-- Persistence is kept as a separate empirical/modeling law. Positivity
does not become persistence without this bridge. -/
structure PositiveEnergyPersistence (State Interval : Type) where
  holds : State -> Interval -> Prop
  positiveThroughout : State -> Interval -> Prop
  law : forall s i, holds s i <-> positiveThroughout s i

theorem persists_iff_positive_throughout {State Interval : Type}
    (p : PositiveEnergyPersistence State Interval) (s : State) (i : Interval) :
    p.holds s i <-> p.positiveThroughout s i :=
  p.law s i

/-- A scalar version of the covenant stability threshold. Multiplication
avoids silently dividing by a zero or negative coupling eigenvalue. -/
structure CovenantSnapshot where
  stability : Real
  driftA : Real
  driftB : Real
  minCoupling : Real

def CovenantStable (c : CovenantSnapshot) : Prop :=
  c.driftA + c.driftB < c.stability * c.minCoupling

theorem covenant_stable_iff_threshold (c : CovenantSnapshot)
    (hc : 0 < c.minCoupling) :
    CovenantStable c <->
      (c.driftA + c.driftB) / c.minCoupling < c.stability := by
  unfold CovenantStable
  constructor <;> intro h
  · exact (div_lt_iff₀ hc).2 h
  · exact (div_lt_iff₀ hc).1 h

/-- Covenant transitivity with named indirect loss. -/
def DerivedStabilityLowerBound (omegaAB omegaBC loss : Real) : Real :=
  min omegaAB omegaBC - loss

theorem covenant_transitivity_bound
    {omegaAB omegaBC loss omegaAC : Real}
    (h : DerivedStabilityLowerBound omegaAB omegaBC loss <= omegaAC) :
    min omegaAB omegaBC - loss <= omegaAC :=
  h

end ForcingAnalysis.Book5
