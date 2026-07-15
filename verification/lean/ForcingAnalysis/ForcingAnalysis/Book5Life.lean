/-
Book5Life.lean - coherence budgets and explicitly bridged life criteria.

Drift/reflection balance cancels one contribution to an energy budget; it does
not make energy, or its derivative, zero by itself. Free-energy persistence,
symbolic life, and metabolic regulation are likewise kept as separate
predicates. Any implication between them is supplied by a named model law.
-/

import ForcingAnalysis.Book5SpectralDecomposition

namespace ForcingAnalysis.Book5

noncomputable section

structure CoherenceBudget where
  driftRate : Real
  reflectionRate : Real
  externalRate : Real
  energyRate : Real
  budget : energyRate = externalRate + (driftRate - reflectionRate)

def CoherenceBudget.Stabilized (B : CoherenceBudget) : Prop :=
  B.driftRate = B.reflectionRate

def CoherenceBudget.Closed (B : CoherenceBudget) : Prop :=
  B.externalRate = 0

theorem stabilized_energy_rate_eq_external
    (B : CoherenceBudget) (hStable : B.Stabilized) :
    B.energyRate = B.externalRate := by
  rw [B.budget, hStable, sub_self, add_zero]

theorem closed_stabilized_energy_rate_zero
    (B : CoherenceBudget) (hClosed : B.Closed) (hStable : B.Stabilized) :
    B.energyRate = 0 := by
  rw [stabilized_energy_rate_eq_external B hStable, hClosed]

theorem stabilized_conservation_iff_closed
    (B : CoherenceBudget) (hStable : B.Stabilized) :
    B.energyRate = 0 <-> B.Closed := by
  rw [stabilized_energy_rate_eq_external B hStable]
  rfl

theorem balance_alone_does_not_force_conservation :
    exists B : CoherenceBudget, B.Stabilized /\ B.energyRate != 0 := by
  refine ⟨⟨1, 1, 1, 1, by norm_num⟩, ?_⟩
  norm_num [CoherenceBudget.Stabilized]

variable {Membrane Flux Time Metabolism : Type*}

structure LifeInterface where
  admissibleFlux : Flux -> Prop
  inPersistenceInterval : Time -> Prop
  freeEnergy : Membrane -> Flux -> Time -> Real
  exhibitsLife : Membrane -> Prop
  regulates : Metabolism -> Membrane -> Prop

def LifeInterface.PositivePersistence
    (L : LifeInterface (Membrane := Membrane) (Flux := Flux)
      (Time := Time) (Metabolism := Metabolism)) (M : Membrane) : Prop :=
  exists flux, L.admissibleFlux flux /\
    forall t, L.inPersistenceInterval t -> 0 < L.freeEnergy M flux t

structure LifeLaw
    (L : LifeInterface (Membrane := Membrane) (Flux := Flux)
      (Time := Time) (Metabolism := Metabolism)) : Prop where
  life_iff_positive_persistence :
    forall M, L.exhibitsLife M <-> L.PositivePersistence M

structure MetabolicPersistenceLaw
    (L : LifeInterface (Membrane := Membrane) (Flux := Flux)
      (Time := Time) (Metabolism := Metabolism)) : Prop where
  metabolism_of_life :
    forall M, L.exhibitsLife M -> exists metabolism, L.regulates metabolism M

theorem symbolic_life_criterion
    (L : LifeInterface (Membrane := Membrane) (Flux := Flux)
      (Time := Time) (Metabolism := Metabolism))
    (law : LifeLaw L) (M : Membrane) :
    L.exhibitsLife M <->
      exists flux, L.admissibleFlux flux /\
        forall t, L.inPersistenceInterval t -> 0 < L.freeEnergy M flux t :=
  law.life_iff_positive_persistence M

theorem metabolic_necessity
    (L : LifeInterface (Membrane := Membrane) (Flux := Flux)
      (Time := Time) (Metabolism := Metabolism))
    (law : MetabolicPersistenceLaw L) {M : Membrane}
    (hLife : L.exhibitsLife M) :
    exists metabolism, L.regulates metabolism M :=
  law.metabolism_of_life M hLife

theorem positive_persistence_has_metabolism
    (L : LifeInterface (Membrane := Membrane) (Flux := Flux)
      (Time := Time) (Metabolism := Metabolism))
    (lifeLaw : LifeLaw L) (metabolicLaw : MetabolicPersistenceLaw L)
    {M : Membrane} (hPositive : L.PositivePersistence M) :
    exists metabolism, L.regulates metabolism M := by
  apply metabolicLaw.metabolism_of_life M
  exact (lifeLaw.life_iff_positive_persistence M).mpr hPositive

theorem agreement_on_positive_persistence_does_not_supply_life_law :
    exists (positive lifeA lifeB : Unit -> Prop),
      (forall M, lifeA M <-> lifeB M) /\
      Not (forall M, lifeA M <-> positive M) := by
  exact ⟨fun _ => True, fun _ => False, fun _ => False,
    fun _ => Iff.rfl, by simp⟩

end

end ForcingAnalysis.Book5
