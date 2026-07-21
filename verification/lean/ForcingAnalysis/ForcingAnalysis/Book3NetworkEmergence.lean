/-
Book3NetworkEmergence.lean — constructor and premise audit for symbolic-network
emergence in Principia Symbolica Book 3.
-/
import Mathlib
import ForcingAnalysis.Book3

namespace ForcingAnalysis.Book3

/-- Once compressed nodes, conceptual-bridge edges, and a nonnegative
stability value are supplied, they assemble into a symbolic network. -/
def assembleSymbolicNetwork {n : ℕ} {Sigma : Type}
    (nodes : Fin n → Sigma) (edge : Fin n → Fin n → Prop)
    (stability : ℝ) (hStability : 0 ≤ stability) : SymbolicNetwork n Sigma where
  nodes := nodes
  edge := edge
  globalStability := stability
  globalStability_nonneg := hStability

theorem assembled_network_stability_pos {n : ℕ} {Sigma : Type}
    (nodes : Fin n → Sigma) (edge : Fin n → Fin n → Prop)
    (stability : ℝ) (hStability : 0 < stability) :
    0 < (assembleSymbolicNetwork nodes edge stability hStability.le).globalStability :=
  hStability

/-- A positive growth increment alone cannot generate a network: with a
nonempty node index and an empty compression codomain, no nodes can exist. -/
theorem growth_alone_does_not_generate_network :
    0 < (1 : ℝ) ∧ ¬ Nonempty (SymbolicNetwork 1 Empty) := by
  constructor
  · norm_num
  · rintro ⟨N⟩
    exact Empty.elim (N.nodes 0)

/-! ## Operational network-emergence process -/

/-- A sustained-growth trace records the evolving knowledge value rather than
collapsing growth to one positive scalar. -/
structure SustainedGrowthTrace where
  knowledge : ℕ → ℝ
  grows : ∀ t, knowledge t < knowledge (t + 1)

/-- The additional mechanism that turns a growth trace into a network.
Region selection, compression, bridge recognition, and stability evaluation
remain separate fields because none is determined by positive growth alone. -/
structure NetworkEmergenceProcess (n : ℕ) (X Sigma : Type) where
  trace : SustainedGrowthTrace
  stage : ℕ
  selectedRegion : Fin n → Set X
  compression : CompressionOperator X Sigma
  bridge : Sigma → Sigma → Prop
  selectedEdge : Fin n → Fin n → Prop
  selectedEdge_bridge :
    ∀ i j, selectedEdge i j →
      bridge (compression (selectedRegion i)) (compression (selectedRegion j))
  stabilityAt : ℕ → ℝ
  nodeCoherenceFloor : ℝ
  nodeCoherenceFloor_pos : 0 < nodeCoherenceFloor
  stability_ge_floor : nodeCoherenceFloor ≤ stabilityAt stage
  stability_nonneg : 0 ≤ stabilityAt stage

/-- Execute the supplied emergence mechanism at its selected stage. -/
def runNetworkEmergence {n : ℕ} {X Sigma : Type}
    (P : NetworkEmergenceProcess n X Sigma) : SymbolicNetwork n Sigma :=
  assembleSymbolicNetwork
    (fun i => P.compression (P.selectedRegion i))
    P.selectedEdge
    (P.stabilityAt P.stage)
    P.stability_nonneg

@[simp] theorem runNetworkEmergence_nodes {n : ℕ} {X Sigma : Type}
    (P : NetworkEmergenceProcess n X Sigma) (i : Fin n) :
    (runNetworkEmergence P).nodes i = P.compression (P.selectedRegion i) := rfl

@[simp] theorem runNetworkEmergence_edges {n : ℕ} {X Sigma : Type}
    (P : NetworkEmergenceProcess n X Sigma) (i j : Fin n) :
    (runNetworkEmergence P).edge i j ↔ P.selectedEdge i j := Iff.rfl

theorem runNetworkEmergence_edge_has_bridge {n : ℕ} {X Sigma : Type}
    (P : NetworkEmergenceProcess n X Sigma) {i j : Fin n}
    (hEdge : (runNetworkEmergence P).edge i j) :
    P.bridge ((runNetworkEmergence P).nodes i)
      ((runNetworkEmergence P).nodes j) := by
  exact P.selectedEdge_bridge i j hEdge

@[simp] theorem runNetworkEmergence_stability {n : ℕ} {X Sigma : Type}
    (P : NetworkEmergenceProcess n X Sigma) :
    (runNetworkEmergence P).globalStability = P.stabilityAt P.stage := rfl

theorem runNetworkEmergence_stability_pos {n : ℕ} {X Sigma : Type}
    (P : NetworkEmergenceProcess n X Sigma)
    (hPos : 0 < P.stabilityAt P.stage) :
    0 < (runNetworkEmergence P).globalStability := hPos

/-- The supplied positive node-coherence floor forces strictly positive global
network stability. -/
theorem runNetworkEmergence_stability_pos_from_floor
    {n : ℕ} {X Sigma : Type} (P : NetworkEmergenceProcess n X Sigma) :
    0 < (runNetworkEmergence P).globalStability := by
  rw [runNetworkEmergence_stability]
  exact lt_of_lt_of_le P.nodeCoherenceFloor_pos P.stability_ge_floor

/-- Execution realizes all source-level assembly clauses together: compressed
nodes, bridge-backed selected edges, and strict global stability. -/
theorem runNetworkEmergence_realizes_assembly
    {n : ℕ} {X Sigma : Type} (P : NetworkEmergenceProcess n X Sigma) :
    (∀ i : Fin n,
      (runNetworkEmergence P).nodes i =
        P.compression (P.selectedRegion i)) ∧
    (∀ i j : Fin n, (runNetworkEmergence P).edge i j →
      P.bridge ((runNetworkEmergence P).nodes i)
        ((runNetworkEmergence P).nodes j)) ∧
    0 < (runNetworkEmergence P).globalStability := by
  exact ⟨fun i => runNetworkEmergence_nodes P i,
    fun _i _j hEdge => runNetworkEmergence_edge_has_bridge P hEdge,
    runNetworkEmergence_stability_pos_from_floor P⟩
/-- The same sustained-growth trace can feed different compression policies
and therefore different networks. Growth does not identify the router. -/
theorem same_growth_allows_distinct_nodes :
    ∃ (T : SustainedGrowthTrace)
      (P Q : NetworkEmergenceProcess 1 Unit Bool),
      P.trace = T ∧ Q.trace = T ∧
      (runNetworkEmergence P).nodes 0 ≠ (runNetworkEmergence Q).nodes 0 := by
  let T : SustainedGrowthTrace := {
    knowledge := fun t => t
    grows := by intro t; exact_mod_cast Nat.lt_succ_self t
  }
  let P : NetworkEmergenceProcess 1 Unit Bool := {
    trace := T
    stage := 0
    selectedRegion := fun _ => Set.univ
    compression := fun _ => false
    bridge := fun _ _ => True
    selectedEdge := fun _ _ => False
    selectedEdge_bridge := by simp
    stabilityAt := fun _ => 1
    nodeCoherenceFloor := 1
    nodeCoherenceFloor_pos := by norm_num
    stability_ge_floor := le_rfl
    stability_nonneg := by norm_num
  }
  let Q : NetworkEmergenceProcess 1 Unit Bool := {
    trace := T
    stage := 0
    selectedRegion := fun _ => Set.univ
    compression := fun _ => true
    bridge := fun _ _ => True
    selectedEdge := fun _ _ => False
    selectedEdge_bridge := by simp
    stabilityAt := fun _ => 1
    nodeCoherenceFloor := 1
    nodeCoherenceFloor_pos := by norm_num
    stability_ge_floor := le_rfl
    stability_nonneg := by norm_num
  }
  exact ⟨T, P, Q, rfl, rfl, by decide⟩
end ForcingAnalysis.Book3
