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
  evolutionaryAdaptation : Prop

def SatisfiesCanonicalStandards (s : CanonicalStandards) : Prop :=
  s.program ∧ s.improvisation ∧ s.compartmentalization ∧ s.energy ∧
  s.regeneration ∧ s.adaptability ∧ s.seclusion ∧ s.selfSustaining ∧
  s.darwinianEvolution ∧ s.order ∧ s.homeostasis ∧ s.growth ∧
  s.reproduction ∧ s.environmentalResponse ∧ s.evolutionaryAdaptation

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
      environmentalResponse := True
      evolutionaryAdaptation := True }
  refine ⟨p, s, p.growth_pos, ?_⟩
  simp [SatisfiesCanonicalStandards, s]

/-! ## Book-3-local operational correspondence -/

/-- Operations needed to interpret a symbolic system as an organism without
borrowing Book 4's later repair machinery. -/
structure SymbolicOrganism (State : Type) where
  current : State
  programStep : State → State
  membrane : Set State
  energy : State → ℝ
  coherence : State → ℝ
  repair : State → State
  reproduce : State → State
  vary : State → State
  hereditary : State → State → Prop
  fitness : State → ℝ
  respond : ℝ → State → State

/-- Inspectable operational evidence for the external life clauses. These are
not aliases for the three scalar persistence inequalities. -/
structure OperationalLifeWitness {State : Type} (O : SymbolicOrganism State) where
  program_changes : O.programStep O.current ≠ O.current
  current_membrane : O.current ∈ O.membrane
  membrane_proper : O.membrane ≠ Set.univ
  energy_pos : 0 < O.energy O.current
  coherence_nonneg : 0 ≤ O.coherence O.current
  repair_improves : O.coherence O.current < O.coherence (O.repair O.current)
  repair_retained : O.repair O.current ∈ O.membrane
  reproduction_hereditary : O.hereditary O.current (O.reproduce O.current)
  variation_hereditary : O.hereditary O.current (O.vary O.current)
  variation_real : O.vary O.current ≠ O.current
  differential_fitness : O.fitness (O.vary O.current) ≠ O.fitness O.current
  responds : ∃ d : ℝ, O.respond d O.current ≠ O.current

/-- Canonical clauses interpreted as concrete properties of one operational
symbolic organism and one persistent-life witness. -/
def operationalStandards {State : Type} (p : ForcingAnalysis.Book3.PersistentLife)
    (O : SymbolicOrganism State) : CanonicalStandards where
  program := O.programStep O.current ≠ O.current
  improvisation := O.programStep O.current ≠ O.current
  compartmentalization := O.current ∈ O.membrane ∧ O.membrane ≠ Set.univ
  energy := 0 < O.energy O.current
  regeneration := O.coherence O.current < O.coherence (O.repair O.current)
  adaptability := ∃ d : ℝ, O.respond d O.current ≠ O.current
  seclusion := O.membrane ≠ Set.univ
  selfSustaining := O.repair O.current ∈ O.membrane
  darwinianEvolution :=
    O.hereditary O.current (O.vary O.current) ∧
    O.vary O.current ≠ O.current ∧
    O.fitness (O.vary O.current) ≠ O.fitness O.current
  order := 0 ≤ O.coherence O.current
  homeostasis := ForcingAnalysis.Book3.Homeostatic p.rmeta p.rmin p.rmax
  growth := 0 < p.growthIncrement
  reproduction := O.hereditary O.current (O.reproduce O.current)
  environmentalResponse := ∃ d : ℝ, O.respond d O.current ≠ O.current
  evolutionaryAdaptation :=
    O.hereditary O.current (O.vary O.current) ∧
    O.vary O.current ≠ O.current ∧
    O.fitness (O.vary O.current) ≠ O.fitness O.current

/-- The correspondence certificate is constructed from Book-3-local operations
and explicit witnesses. No Book 4 repair process is imported or assumed. -/
theorem operational_correspondence
    {State : Type} (p : ForcingAnalysis.Book3.PersistentLife)
    (O : SymbolicOrganism State) (w : OperationalLifeWitness O) :
    LifeCorrespondence p (operationalStandards p O) := by
  refine ⟨?_⟩
  unfold SatisfiesCanonicalStandards operationalStandards
  exact ⟨w.program_changes, w.program_changes,
    ⟨w.current_membrane, w.membrane_proper⟩, w.energy_pos,
    w.repair_improves, w.responds, w.membrane_proper,
    w.repair_retained,
    ⟨w.variation_hereditary, w.variation_real, w.differential_fitness⟩,
    w.coherence_nonneg, p.homeostatic, p.growth_pos,
    w.reproduction_hereditary, w.responds,
    ⟨w.variation_hereditary, w.variation_real, w.differential_fitness⟩⟩

/-! ## Morphological regulation bridge -/

/-- An explicit representation bridge from symbolic coherence to distance from
a target morphology. The target and error functional are retained rather than
identified definitionally with life or freedom. -/
structure MorphologicalRepairBridge {State : Type} (O : SymbolicOrganism State) where
  Form : Type
  formOf : State → Form
  target : Form
  deviation : Form → Form → ℝ
  coherence_eq_neg_deviation_current :
    O.coherence O.current = -deviation (formOf O.current) target
  coherence_eq_neg_deviation_repair :
    O.coherence (O.repair O.current) =
      -deviation (formOf (O.repair O.current)) target

/-- Under the retained representation bridge, improved symbolic coherence is
exactly reduced morphological target error. This is the precise point at which
morphological homeostasis can discharge the regeneration clause. -/
theorem repair_improves_iff_morphological_error_decreases
    {State : Type} (O : SymbolicOrganism State)
    (M : MorphologicalRepairBridge O) :
    O.coherence O.current < O.coherence (O.repair O.current) ↔
      M.deviation (M.formOf (O.repair O.current)) M.target <
        M.deviation (M.formOf O.current) M.target := by
  rw [M.coherence_eq_neg_deviation_current,
    M.coherence_eq_neg_deviation_repair]
  exact neg_lt_neg_iff

/-- Revising a target morphology is separated from merely repairing toward a
fixed target. It supplies material for later self-authorship, but is not itself
identified with Book IX freedom. -/
structure MorphologicalTargetAuthorship {State : Type}
    (O : SymbolicOrganism State) (M : MorphologicalRepairBridge O) where
  reviseTarget : State → M.Form
  revises : reviseTarget O.current ≠ M.target
/-- The declared chemical-to-symbolic reading is an operational structural
translation: self-maintenance is paired with heritable variation and
differential selection. It asserts correspondence, not chemical identity. -/
def SymbolicSubstrateTranslation {State : Type} (O : SymbolicOrganism State) : Prop :=
  O.repair O.current ∈ O.membrane ∧
  O.hereditary O.current (O.vary O.current) ∧
  O.vary O.current ≠ O.current ∧
  O.fitness (O.vary O.current) ≠ O.fitness O.current

/-- The operational witness constructs the substrate-translation bridge rather
than leaving `chemical ↦ symbolic` as an untracked interpretive phrase. -/
theorem operational_substrate_translation
    {State : Type} (O : SymbolicOrganism State) (w : OperationalLifeWitness O) :
    SymbolicSubstrateTranslation O := by
  exact ⟨w.repair_retained, w.variation_hereditary,
    w.variation_real, w.differential_fitness⟩

/-- One Book-3-local certificate realizes the declared substrate translation
and every Koshland, NASA, and textbook clause, including evolutionary
adaptation, for the same operational organism. -/
theorem operational_symbolic_life_realizes_canonical_demarcations
    {State : Type} (p : ForcingAnalysis.Book3.PersistentLife)
    (O : SymbolicOrganism State) (w : OperationalLifeWitness O) :
    SymbolicSubstrateTranslation O ∧
      SatisfiesCanonicalStandards (operationalStandards p O) := by
  exact ⟨operational_substrate_translation O w,
    (operational_correspondence p O w).clauses⟩
/-- Consequently the operational organism satisfies all canonical clauses in
exactly the declared symbolic interpretation. -/
theorem operational_symbolic_life_satisfies_canonical
    {State : Type} (p : ForcingAnalysis.Book3.PersistentLife)
    (O : SymbolicOrganism State) (w : OperationalLifeWitness O) :
    SatisfiesCanonicalStandards (operationalStandards p O) :=
  (operational_correspondence p O w).clauses
end ForcingAnalysis.Book3CanonicalLife
