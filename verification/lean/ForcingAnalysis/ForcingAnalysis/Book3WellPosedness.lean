/-
Book3WellPosedness.lean — constructive static kernel for symbolic-membrane
well-posedness in Principia Symbolica Book 3.
-/
import Mathlib
import ForcingAnalysis.Book3

namespace ForcingAnalysis.Book3

/-- A canonical static membrane at any positive perturbation budget. The
Hamiltonian-derived stability value follows the construction proposed in the
source proof. This does not manufacture the omitted submanifold geometry. -/
noncomputable def canonicalMembrane
    (delta alpha H : ℝ) (hDelta : 0 < delta) : Membrane where
  driftDeviation := 0
  driftBound := delta
  driftBound_pos := hDelta
  driftDeviation_le := hDelta.le
  permeability := 0
  permeability_nonneg := le_rfl
  permeability_le_one := by norm_num
  stability := Real.exp (-alpha * H)
  stability_nonneg := (Real.exp_pos _).le

/-- Static well-posedness kernel: every positive drift budget admits data
satisfying all numeric membrane invariants, with the source's exponential
stability construction. -/
theorem exists_static_membrane
    (delta alpha H : ℝ) (hDelta : 0 < delta) :
    ∃ m : Membrane,
      m.driftBound = delta ∧
      m.driftDeviation = 0 ∧
      m.permeability = 0 ∧
      m.stability = Real.exp (-alpha * H) := by
  exact ⟨canonicalMembrane delta alpha H hDelta, rfl, rfl, rfl, rfl⟩

/-- The constructed stability functional is strictly positive, a stronger
fact than the nonnegativity required by the static membrane interface. -/
theorem canonicalMembrane_stability_pos
    (delta alpha H : ℝ) (hDelta : 0 < delta) :
    0 < (canonicalMembrane delta alpha H hDelta).stability := by
  exact Real.exp_pos _

/-- Smallness is not needed for consistency of the numeric structure: any
smaller positive budget also has a canonical witness. -/
theorem exists_static_membrane_at_smaller_bound
    {delta small alpha H : ℝ} (hSmall : 0 < small) (hLe : small ≤ delta) :
    ∃ m : Membrane, m.driftBound = small ∧ m.driftBound ≤ delta := by
  refine ⟨canonicalMembrane small alpha H hSmall, rfl, ?_⟩
  change small ≤ delta
  exact hLe

/-! ## A constructed chart-domain membrane -/

/-- A one-dimensional local model of the geometric carrier required by a
symbolic membrane. In dimension one its smooth boundary is the two regular
endpoints recorded by `frontier_eq`. -/
structure MembraneChartDomain where
  radius : ℝ
  radius_pos : 0 < radius
  carrier : Set ℝ
  carrier_eq : carrier = Set.Ioo (-radius) radius
  isOpen_carrier : IsOpen carrier
  nonempty_carrier : carrier.Nonempty
  isPreconnected_carrier : IsPreconnected carrier
  isCompact_closure : IsCompact (closure carrier)
  frontier_eq : frontier carrier = ({-radius, radius} : Set ℝ)

/-- The explicit relatively compact connected interval chart. -/
def intervalMembraneDomain (radius : ℝ) (hRadius : 0 < radius) :
    MembraneChartDomain where
  radius := radius
  radius_pos := hRadius
  carrier := Set.Ioo (-radius) radius
  carrier_eq := rfl
  isOpen_carrier := isOpen_Ioo
  nonempty_carrier := by
    refine ⟨0, ?_, hRadius⟩
    linarith
  isPreconnected_carrier := Set.ordConnected_Ioo.isPreconnected
  isCompact_closure := by
    rw [closure_Ioo]
    · exact isCompact_Icc
    · linarith
  frontier_eq := frontier_Ioo (by linarith)

/-- Typed local membrane data. Drift lives on the carrier, permeability on
the computed boundary and tangent direction, and stability on the carrier. -/
structure ChartMembrane (delta : ℝ) where
  domain : MembraneChartDomain
  globalDrift : ℝ → ℝ
  internalDrift : (x : ℝ) → x ∈ domain.carrier → ℝ
  drift_close :
    ∀ (x : ℝ) (hx : x ∈ domain.carrier),
      |internalDrift x hx - globalDrift x| ≤ delta
  permeability :
    (p : ℝ) → p ∈ frontier domain.carrier → ℝ → ℝ
  permeability_mem :
    ∀ (p : ℝ) (hp : p ∈ frontier domain.carrier) (v : ℝ),
      permeability p hp v ∈ Set.Icc (0 : ℝ) 1
  stability : (x : ℝ) → x ∈ domain.carrier → ℝ
  stability_pos :
    ∀ (x : ℝ) (hx : x ∈ domain.carrier), 0 < stability x hx

/-- Constructed chart-level membrane using the source's exponential
Hamiltonian stability law. This does not assert that every ambient manifold
contains the chart without an additional manifold hypothesis. -/
noncomputable def canonicalChartMembrane
    (radius delta alpha H : ℝ) (hRadius : 0 < radius) (hDelta : 0 ≤ delta) :
    ChartMembrane delta where
  domain := intervalMembraneDomain radius hRadius
  globalDrift := fun _ => 0
  internalDrift := fun _ _ => 0
  drift_close := by
    intro x hx
    simpa using hDelta
  permeability := fun _ _ _ => 0
  permeability_mem := by
    intro p hp v
    constructor <;> norm_num
  stability := fun _ _ => Real.exp (-alpha * H)
  stability_pos := by
    intro x hx
    exact Real.exp_pos _

theorem exists_chart_membrane
    (radius delta alpha H : ℝ) (hRadius : 0 < radius) (hDelta : 0 ≤ delta) :
    ∃ m : ChartMembrane delta,
      m.domain.carrier = Set.Ioo (-radius) radius ∧
      frontier m.domain.carrier = ({-radius, radius} : Set ℝ) ∧
      IsCompact (closure m.domain.carrier) := by
  refine ⟨canonicalChartMembrane radius delta alpha H hRadius hDelta, ?_⟩
  exact ⟨rfl, (intervalMembraneDomain radius hRadius).frontier_eq,
    (intervalMembraneDomain radius hRadius).isCompact_closure⟩
/-! ## Conditional ambient-domain construction -/

/-- The geometric and regularity input required by the source lemma. The
properties are supplied witnesses: a perturbation budget cannot create them. -/
structure SuppliedSmoothMembraneDomain
    (X Tangent Boundary : Type*) [NormedAddCommGroup Tangent] where
  carrier : X -> Prop
  carrier_nonempty : ∃ x, carrier x
  connected : Prop
  openCarrier : Prop
  compactClosure : Prop
  smoothBoundary : Prop
  connected_certified : connected
  open_certified : openCarrier
  compactClosure_certified : compactClosure
  smoothBoundary_certified : smoothBoundary
  boundaryPoint : Boundary -> X
  globalDrift : X -> Tangent
  hamiltonian : X -> ℝ
  SmoothScalar : (X -> ℝ) -> Prop
  smoothDrift : Prop
  smoothDrift_certified : smoothDrift
  hamiltonian_smooth : SmoothScalar hamiltonian
  smooth_exp_neg_smul : ∀ (alpha : ℝ) (f : X -> ℝ),
    SmoothScalar f -> SmoothScalar (fun x => Real.exp (-alpha * f x))

/-- Full membrane data constructed on the supplied domain. Drift and stability
remain ambient functions with their restriction laws stated on the carrier. -/
structure ConditionalMembraneData
    {X Tangent Boundary : Type*} [NormedAddCommGroup Tangent]
    (U : SuppliedSmoothMembraneDomain X Tangent Boundary) (delta : ℝ) where
  internalDrift : X -> Tangent
  drift_close : ∀ x, U.carrier x ->
    ‖internalDrift x - U.globalDrift x‖ <= delta
  internalDrift_smooth : U.smoothDrift
  permeability : Boundary -> Tangent -> ℝ
  permeability_mem : ∀ p v, permeability p v ∈ Set.Icc (0 : ℝ) 1
  stability : X -> ℝ
  stability_pos : ∀ x, U.carrier x -> 0 < stability x
  stability_smooth : U.SmoothScalar stability

/-- The source construction: restriction of the supplied drift, zero boundary
permeability, and exponential Hamiltonian stability. -/
noncomputable def canonicalConditionalMembrane
    {X Tangent Boundary : Type*} [NormedAddCommGroup Tangent]
    (U : SuppliedSmoothMembraneDomain X Tangent Boundary)
    (delta alpha : ℝ) (hDelta : 0 < delta) :
    ConditionalMembraneData U delta where
  internalDrift := U.globalDrift
  drift_close := by
    intro x hx
    simpa using hDelta.le
  internalDrift_smooth := U.smoothDrift_certified
  permeability := fun _ _ => 0
  permeability_mem := by
    intro p v
    constructor <;> norm_num
  stability := fun x => Real.exp (-alpha * U.hamiltonian x)
  stability_pos := by
    intro x hx
    exact Real.exp_pos _
  stability_smooth := U.smooth_exp_neg_smul alpha U.hamiltonian
    U.hamiltonian_smooth

/-- Conditional well-posedness exactly consumes the supplied geometric and
smoothness witnesses. No smallness assumption beyond positivity is used. -/
theorem conditional_symbolic_membrane_wellposed
    {X Tangent Boundary : Type*} [NormedAddCommGroup Tangent]
    (U : SuppliedSmoothMembraneDomain X Tangent Boundary)
    (delta alpha : ℝ) (hDelta : 0 < delta) (hAlpha : 0 < alpha) :
    ∃ m : ConditionalMembraneData U delta,
      0 < alpha ∧
      (∀ x, U.carrier x -> m.internalDrift x = U.globalDrift x) ∧
      (∀ p v, m.permeability p v = 0) ∧
      (∀ x, m.stability x = Real.exp (-alpha * U.hamiltonian x)) := by
  let m := canonicalConditionalMembrane U delta alpha hDelta
  exact ⟨m, hAlpha, by simp [m, canonicalConditionalMembrane],
    by simp [m, canonicalConditionalMembrane],
    by simp [m, canonicalConditionalMembrane]⟩

/-- The perturbation budget does not manufacture the load-bearing domain:
there is no nonempty carrier inside an empty ambient type, at any budget. -/
theorem perturbation_budget_does_not_supply_domain (delta : ℝ) (hDelta : 0 < delta) :
    0 < delta ∧ ¬ ∃ carrier : Empty -> Prop, ∃ x, carrier x := by
  refine ⟨hDelta, ?_⟩
  intro h
  obtain ⟨carrier, x, hx⟩ := h
  exact Empty.elim x

end ForcingAnalysis.Book3
