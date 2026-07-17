/- Book7LpRegression.lean — observer-relative free energy and finite Lp regression. -/
import Mathlib

namespace ForcingAnalysis.Book7LpRegression

variable {ι H : Type*} [Fintype ι]

/-- The finite manifest residual vector seen by an observer. -/
def residual (observed predicted : ι → ℝ) : ι → ℝ :=
  fun i => observed i - predicted i

/-- The p-th-power finite Lp regression objective from the displayed source equation. -/
def lpPower (p : ℕ) (v : ι → ℝ) : ℝ :=
  ∑ i, |v i| ^ p

def regressionLoss (p : ℕ) (observed predicted : ι → ℝ) : ℝ :=
  lpPower p (residual observed predicted)

theorem regressionLoss_eq_sum (p : ℕ) (observed predicted : ι → ℝ) :
    regressionLoss p observed predicted = ∑ i, |observed i - predicted i| ^ p := by
  rfl

/-- A feasible point globally minimizes an objective on the observer's available basin. -/
def MinimizesOn (feasible : H → Prop) (objective : H → ℝ) (model : H) : Prop :=
  feasible model ∧ ∀ candidate, feasible candidate → objective model ≤ objective candidate

/-- The missing statistical bridge: on feasible models, free energy is a positive
affine rescaling of the manifest Lp loss.  Positive affine rescaling preserves order. -/
structure AffineLpRepresentation
    (feasible : H → Prop) (freeEnergy loss : H → ℝ) where
  scale : ℝ
  offset : ℝ
  scale_pos : 0 < scale
  represents : ∀ model, feasible model →
    freeEnergy model = scale * loss model + offset

theorem order_equiv_of_affineLp
    {feasible : H → Prop} {freeEnergy loss : H → ℝ}
    (bridge : AffineLpRepresentation feasible freeEnergy loss)
    {a b : H} (ha : feasible a) (hb : feasible b) :
    freeEnergy a ≤ freeEnergy b ↔ loss a ≤ loss b := by
  rw [bridge.represents a ha, bridge.represents b hb]
  constructor
  · intro h
    nlinarith [bridge.scale_pos]
  · intro h
    nlinarith [bridge.scale_pos]

/-- Source-faithful conditional kernel: once the observer/free-energy objective is
identified with a positive affine Lp objective, their argmin predicates coincide. -/
theorem freeEnergy_minimization_iff_lp_regression
    {feasible : H → Prop} {freeEnergy loss : H → ℝ}
    (bridge : AffineLpRepresentation feasible freeEnergy loss) (model : H) :
    MinimizesOn feasible freeEnergy model ↔ MinimizesOn feasible loss model := by
  constructor
  · rintro ⟨hm, hmin⟩
    refine ⟨hm, fun candidate hc => ?_⟩
    exact (order_equiv_of_affineLp bridge hm hc).mp (hmin candidate hc)
  · rintro ⟨hm, hmin⟩
    refine ⟨hm, fun candidate hc => ?_⟩
    exact (order_equiv_of_affineLp bridge hm hc).mpr (hmin candidate hc)

/-- A Book 7 reflective trace: the orbit is generated internally by reflection.
Appendix B may validate such an orbit downstream, but is not a premise here. -/
structure ReflectiveTrace (H : Type*) where
  reflect : H → H
  state : ℕ → H
  follows : ∀ n, state (n + 1) = reflect (state n)

/-- The operational representation law needed only along one witnessed orbit. -/
structure TraceAffineLpRepresentation
    (trace : ReflectiveTrace H) (freeEnergy loss : H → ℝ) where
  scale : ℝ
  offset : ℝ
  scale_pos : 0 < scale
  represents : ∀ n,
    freeEnergy (trace.state n) = scale * loss (trace.state n) + offset

theorem trace_order_equiv
    {trace : ReflectiveTrace H} {freeEnergy loss : H → ℝ}
    (bridge : TraceAffineLpRepresentation trace freeEnergy loss) (m n : ℕ) :
    freeEnergy (trace.state m) ≤ freeEnergy (trace.state n) ↔
      loss (trace.state m) ≤ loss (trace.state n) := by
  rw [bridge.represents m, bridge.represents n]
  constructor <;> intro h <;> nlinarith [bridge.scale_pos]

/-- Every represented reflective descent step is exactly a loss descent step. -/
theorem trace_step_descent_iff
    {trace : ReflectiveTrace H} {freeEnergy loss : H → ℝ}
    (bridge : TraceAffineLpRepresentation trace freeEnergy loss) (n : ℕ) :
    freeEnergy (trace.state (n + 1)) ≤ freeEnergy (trace.state n) ↔
      loss (trace.state (n + 1)) ≤ loss (trace.state n) :=
  trace_order_equiv bridge (n + 1) n

/-- A minimizer among the actually visited states is preserved in both directions. -/
theorem trace_minimizer_iff
    {trace : ReflectiveTrace H} {freeEnergy loss : H → ℝ}
    (bridge : TraceAffineLpRepresentation trace freeEnergy loss) (n : ℕ) :
    (∀ m, freeEnergy (trace.state n) ≤ freeEnergy (trace.state m)) ↔
      (∀ m, loss (trace.state n) ≤ loss (trace.state m)) := by
  constructor <;> intro h m
  · exact (trace_order_equiv bridge n m).mp (h m)
  · exact (trace_order_equiv bridge n m).mpr (h m)
/- Boundedness and a descending reflective step do not manufacture the statistical
representation.  Both models below have identical manifest residual loss, while
their free energies differ, so no positive affine Lp bridge can exist. -/
def twoModelEnergy : Bool → ℝ
  | false => 0
  | true => 1

def zeroLoss (_ : Bool) : ℝ := 0

def descendToFalse (_ : Bool) : Bool := false

theorem twoModelEnergy_bounded_below (model : Bool) :
    0 ≤ twoModelEnergy model := by
  cases model <;> simp [twoModelEnergy]

theorem descendToFalse_nonincreasing (model : Bool) :
    twoModelEnergy (descendToFalse model) ≤ twoModelEnergy model := by
  cases model <;> simp [descendToFalse, twoModelEnergy]

theorem bounded_descent_does_not_force_lp_representation :
    ¬ Nonempty (AffineLpRepresentation
      (fun _ : Bool => True) twoModelEnergy zeroLoss) := by
  rintro ⟨bridge⟩
  have hfalse := bridge.represents false trivial
  have htrue := bridge.represents true trivial
  simp [twoModelEnergy, zeroLoss] at hfalse htrue
  linarith

end ForcingAnalysis.Book7LpRegression
