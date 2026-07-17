/-
Book3CanonicalLife.lean — typed correspondence boundary for the canonical-life
claim in Principia Symbolica Book 3.
-/
import Mathlib
import ForcingAnalysis.Book3

namespace ForcingAnalysis.Book3CanonicalLife

/-- The externally named life clauses, kept as propositions rather than
silently identifying them with Book 3's three persistence fields. -/
structure CanonicalStandards where
  program : Prop
  improvisation : Prop
  compartmentalization : Prop
  energy : Prop
  regeneration : Prop
  adaptability : Prop
  seclusion : Prop
  selfSustaining : Prop
  darwinianEvolution : Prop
  order : Prop
  homeostasis : Prop
  growth : Prop
  reproduction : Prop
  environmentalResponse : Prop

def SatisfiesCanonicalStandards (s : CanonicalStandards) : Prop :=
  s.program ∧ s.improvisation ∧ s.compartmentalization ∧ s.energy ∧
  s.regeneration ∧ s.adaptability ∧ s.seclusion ∧ s.selfSustaining ∧
  s.darwinianEvolution ∧ s.order ∧ s.homeostasis ∧ s.growth ∧
  s.reproduction ∧ s.environmentalResponse

/-- A correspondence is explicit evidence connecting a persistent symbolic
system to every externally named clause. -/
structure LifeCorrespondence
    (p : ForcingAnalysis.Book3.PersistentLife) (s : CanonicalStandards) where
  clauses : SatisfiesCanonicalStandards s

theorem persistentLife_satisfies_canonical
    (_p : ForcingAnalysis.Book3.PersistentLife) (s : CanonicalStandards)
    (bridge : LifeCorrespondence _p s) : SatisfiesCanonicalStandards s :=
  bridge.clauses

/-- The three persistence fields alone cannot entail arbitrary external
standards. A concrete persistent-life witness coexists with a deliberately
false regeneration clause. -/
theorem persistence_alone_does_not_supply_correspondence :
    ∃ (p : ForcingAnalysis.Book3.PersistentLife) (s : CanonicalStandards),
      0 < p.growthIncrement ∧ ¬ SatisfiesCanonicalStandards s := by
  let p : ForcingAnalysis.Book3.PersistentLife :=
    { rmeta := 1
      rmin := 0
      rmax := 2
      homeostatic := by constructor <;> norm_num
      growthIncrement := 1
      growth_pos := by norm_num
      kappaSymb := 1
      kappaFloor := 1
      kappaFloor_pos := by norm_num
      kappa_above_floor := le_rfl }
  let s : CanonicalStandards :=
    { program := True
      improvisation := True
      compartmentalization := True
      energy := True
      regeneration := False
      adaptability := True
      seclusion := True
      selfSustaining := True
      darwinianEvolution := True
      order := True
      homeostasis := True
      growth := True
      reproduction := True
      environmentalResponse := True }
  refine ⟨p, s, p.growth_pos, ?_⟩
  simp [SatisfiesCanonicalStandards, s]

end ForcingAnalysis.Book3CanonicalLife
