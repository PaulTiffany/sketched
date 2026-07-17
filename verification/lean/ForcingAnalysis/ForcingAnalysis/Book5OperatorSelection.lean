/- Book5OperatorSelection.lean — source-bound SRMF operator-selection kernel. -/
import Mathlib

namespace ForcingAnalysis.Book5OperatorSelection

/-- A selected operator is admissible and minimizes process free energy over
the supplied finite operator inventory. -/
structure SelectsProcessMinimizer {Operator : Type*} [DecidableEq Operator]
    (available : Finset Operator) (processFreeEnergy : Operator → ℝ)
    (selected : Operator) : Prop where
  selected_mem : selected ∈ available
  minimal : ∀ candidate ∈ available,
    processFreeEnergy selected ≤ processFreeEnergy candidate

/-- A nonempty finite operator inventory always has a process-free-energy
minimizer. This is the executable finite core of the printed argmin. -/
theorem exists_process_minimizer {Operator : Type*} [DecidableEq Operator]
    (available : Finset Operator) (processFreeEnergy : Operator → ℝ)
    (havailable : available.Nonempty) :
    ∃ selected, SelectsProcessMinimizer available processFreeEnergy selected := by
  obtain ⟨selected, hselected, hmin⟩ :=
    available.exists_min_image processFreeEnergy havailable
  exact ⟨selected, hselected, fun candidate hcandidate => hmin candidate hcandidate⟩

/-- Certified SRMF selection cannot have greater process free energy than any
available incumbent. -/
theorem selected_le_incumbent {Operator : Type*} [DecidableEq Operator]
    {available : Finset Operator} {processFreeEnergy : Operator → ℝ}
    {selected incumbent : Operator}
    (selection : SelectsProcessMinimizer available processFreeEnergy selected)
    (hincumbent : incumbent ∈ available) :
    processFreeEnergy selected ≤ processFreeEnergy incumbent :=
  selection.minimal incumbent hincumbent

/-- If an available candidate is strictly cheaper than the incumbent, a
certified minimizer cannot select that incumbent. -/
theorem rejects_strictly_suboptimal_incumbent {Operator : Type*}
    [DecidableEq Operator] {available : Finset Operator}
    {processFreeEnergy : Operator → ℝ} {selected incumbent better : Operator}
    (selection : SelectsProcessMinimizer available processFreeEnergy selected)
    (hbetter : better ∈ available)
    (hstrict : processFreeEnergy better < processFreeEnergy incumbent) :
    selected ≠ incumbent := by
  intro h
  subst selected
  exact (not_lt_of_ge (selection.minimal better hbetter)) hstrict

/-- Viability alone does not entail process-free-energy minimization: a viable
system may select the more expensive member of its available inventory. -/
theorem viability_alone_does_not_force_operator_argmin :
    let available : Finset Bool := {false, true}
    let processFreeEnergy : Bool → ℝ := fun operator => if operator then 1 else 0
    let viable : Bool → Prop := fun _ => True
    viable true ∧ true ∈ available ∧
      ¬ SelectsProcessMinimizer available processFreeEnergy true := by
  dsimp
  constructor
  · trivial
  constructor
  · simp
  · intro selection
    have h := selection.minimal false (by simp)
    norm_num at h

end ForcingAnalysis.Book5OperatorSelection
