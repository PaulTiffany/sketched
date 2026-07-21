/- Book6ThermodynamicMutation.lean — finite constrained-MEPP kernel. -/
import Mathlib

namespace ForcingAnalysis.Book6ThermodynamicMutation

/-- A finite reflective-entropy constraint carves the feasible mutation states
out of an available population. -/
noncomputable def feasibleStates {State : Type*} [DecidableEq State]
    (available : Finset State) (reflectedEntropy : State → ℝ)
    (criticalEntropy : ℝ) : Finset State :=
  available.filter fun state => reflectedEntropy state ≤ criticalEntropy

theorem mem_feasibleStates_iff {State : Type*} [DecidableEq State]
    {available : Finset State} {reflectedEntropy : State → ℝ}
    {criticalEntropy : ℝ} {state : State} :
    state ∈ feasibleStates available reflectedEntropy criticalEntropy ↔
      state ∈ available ∧ reflectedEntropy state ≤ criticalEntropy := by
  simp [feasibleStates]

/-- A constrained MEPP certificate consists of feasibility and maximal entropy
production among all feasible states. -/
structure IsConstrainedMEPP {State : Type*} [DecidableEq State]
    (feasible : Finset State) (entropyProduction : State → ℝ)
    (selected : State) : Prop where
  selected_mem : selected ∈ feasible
  maximal : ∀ candidate ∈ feasible,
    entropyProduction candidate ≤ entropyProduction selected

/-- Every nonempty finite reflectively feasible set admits a maximum-entropy-
production state. -/
theorem exists_constrained_mepp {State : Type*} [DecidableEq State]
    (feasible : Finset State) (entropyProduction : State → ℝ)
    (hfeasible : feasible.Nonempty) :
    ∃ selected, IsConstrainedMEPP feasible entropyProduction selected := by
  obtain ⟨selected, hselected, hmax⟩ :=
    feasible.exists_max_image entropyProduction hfeasible
  exact ⟨selected, hselected, fun candidate hcandidate => hmax candidate hcandidate⟩

/-- Equality of production and dissipation at one equilibrium state does not
show that state maximizes entropy production over the feasible population. -/
theorem equilibrium_balance_alone_does_not_imply_mepp :
    let feasible : Finset Bool := {false, true}
    let production : Bool → ℝ := fun state => if state then 1 else 0
    let dissipation : Bool → ℝ := fun _ => 0
    production false = dissipation false ∧
      ¬ IsConstrainedMEPP feasible production false := by
  dsimp
  constructor
  · rfl
  · intro certificate
    have h := certificate.maximal true (by simp)
    norm_num at h


/-- An explicit dynamics-to-optimizer bridge for MEPP. -/
structure MEPPSelectionLaw {State : Type*} [DecidableEq State]
    (feasible : Finset State) (entropyProduction : State → ℝ) where
  trajectory : ℕ → State
  selected : State
  selected_mepp : IsConstrainedMEPP feasible entropyProduction selected
  eventually_selected : ∀ᶠ n in Filter.atTop, trajectory n = selected

namespace MEPPSelectionLaw

/-- The supplied selection dynamics converges to its constrained maximizer. -/
theorem trajectory_tendsto {State : Type*} [DecidableEq State]
    [TopologicalSpace State] [DiscreteTopology State]
    {feasible : Finset State} {entropyProduction : State → ℝ}
    (L : MEPPSelectionLaw feasible entropyProduction) :
    Filter.Tendsto L.trajectory Filter.atTop (nhds L.selected) := by
  exact Filter.Tendsto.congr' (Filter.EventuallyEq.symm L.eventually_selected) tendsto_const_nhds

end MEPPSelectionLaw

/-- Maximizer existence does not manufacture a dynamics selecting it. -/
theorem argmax_exists_without_selection_dynamics :
    let feasible : Finset Bool := {false, true}
    let production : Bool → ℝ := fun state => if state then 1 else 0
    (∃ selected, IsConstrainedMEPP feasible production selected) ∧
      ¬ Filter.Tendsto (fun _ : ℕ => false) Filter.atTop (nhds true) := by
  dsimp
  constructor
  · exact exists_constrained_mepp _ _ (by simp)
  · intro hselect
    have hstay : Filter.Tendsto (fun _ : ℕ => false) Filter.atTop (nhds false) :=
      tendsto_const_nhds
    have : false = true := tendsto_nhds_unique hstay hselect
    exact Bool.noConfusion this

end ForcingAnalysis.Book6ThermodynamicMutation
