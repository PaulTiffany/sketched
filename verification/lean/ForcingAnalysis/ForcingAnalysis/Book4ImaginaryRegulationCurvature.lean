import Mathlib

/-!
The interaction kernel between imagination, embodied regulation, curvature,
and helical accumulation.

This is an authorial clarification, not a source-attested Principia theorem.
It formalizes only the conditional bridge:

  imagination/regulation order defect -> nonzero reintegration residue.

Imagination by itself need not produce that defect. A recurring oriented
residue produces forward displacement only when an accumulation law is
supplied; it does not by itself select a golden spiral.
-/

namespace ForcingAnalysis.Book4ImaginaryRegulationCurvature

/-- An imaginary proposal and the embodiment's regulatory return map. -/
structure Interface (State : Type*) where
  imagine : State → State
  regulate : State → State

/-- Imagination is operationally nontrivial at some state. -/
def ImaginationActive {State : Type*} (I : Interface State) : Prop :=
  ∃ x, I.imagine x ≠ x

/-- Reintegration is order-sensitive: imagine-then-regulate differs from
regulate-then-imagine. This is the discrete commutator/holonomy witness. -/
def HasReintegrationResidue {State : Type*} (I : Interface State) : Prop :=
  ∃ x, I.regulate (I.imagine x) ≠ I.imagine (I.regulate x)

theorem reintegrationResidue_iff_noncommuting {State : Type*}
    (I : Interface State) :
    HasReintegrationResidue I ↔ I.regulate ∘ I.imagine ≠ I.imagine ∘ I.regulate := by
  constructor
  · rintro ⟨x, hx⟩ heq
    exact hx (congrFun heq x)
  · intro hneq
    by_contra hnone
    apply hneq
    funext x
    by_contra hx
    exact hnone ⟨x, hx⟩

/-- A nonzero reintegration residue entails a genuinely active imaginary
step; an identity imagination map commutes with every regulator. -/
theorem residue_implies_imaginationActive {State : Type*}
    (I : Interface State) (h : HasReintegrationResidue I) :
    ImaginationActive I := by
  by_contra hinactive
  rcases h with ⟨x, hx⟩
  have himagine (y : State) : I.imagine y = y := by
    by_contra hy
    exact hinactive ⟨y, hy⟩
  exact hx (by rw [himagine x, himagine (I.regulate x)])

/-- Imagination alone need not create curvature: Boolean negation is an
active imaginary variation, but it commutes with identity regulation. -/
theorem imagination_alone_does_not_force_residue :
    ∃ I : Interface Bool, ImaginationActive I ∧ ¬ HasReintegrationResidue I := by
  let I : Interface Bool := ⟨not, id⟩
  refine ⟨I, ⟨false, by decide⟩, ?_⟩
  simp [HasReintegrationResidue, I]

/-- Curvature data external to the imagination/regulation interface does not
identify an imaginary process. -/
structure CurvedInterface (State : Type*) extends Interface State where
  externalCurvature : Prop

theorem curvature_alone_does_not_force_imagination :
    ∃ I : CurvedInterface Unit,
      I.externalCurvature ∧ ¬ ImaginationActive I.toInterface := by
  let I : CurvedInterface Unit := ⟨⟨id, id⟩, True⟩
  exact ⟨I, trivial, by simp [ImaginationActive, I]⟩

/-- The additive reintegration defect at one embodied state. It compares the
same imaginary proposal and regulatory return in opposite operational orders. -/
def reintegrationDefect {State : Type*} [AddGroup State]
    (I : Interface State) (x : State) : State :=
  I.regulate (I.imagine x) - I.imagine (I.regulate x)

/-- The nonnegative cost of an imaginary traversal at one state. This is an
operational curvature-cost candidate, not yet a geometric curvature scalar. -/
def imaginaryTraversalCost {State : Type*} [NormedAddCommGroup State]
    (I : Interface State) (x : State) : Real :=
  norm (reintegrationDefect I x)

theorem imaginaryTraversalCost_nonneg {State : Type*}
    [NormedAddCommGroup State] (I : Interface State) (x : State) :
    0 <= imaginaryTraversalCost I x :=
  norm_nonneg _

/-- Traversal is free exactly when the two operational orders reintegrate to
the same state. Thus imagination may be active while its realized curvature
cost is zero. -/
theorem imaginaryTraversalCost_eq_zero_iff {State : Type*}
    [NormedAddCommGroup State] (I : Interface State) (x : State) :
    imaginaryTraversalCost I x = 0 <->
      I.regulate (I.imagine x) = I.imagine (I.regulate x) := by
  simp [imaginaryTraversalCost, reintegrationDefect, sub_eq_zero]

/-- Positive traversal cost is exactly a pointwise reintegration residue. -/
theorem imaginaryTraversalCost_pos_iff {State : Type*}
    [NormedAddCommGroup State] (I : Interface State) (x : State) :
    0 < imaginaryTraversalCost I x <->
      Not (I.regulate (I.imagine x) = I.imagine (I.regulate x)) := by
  simp [imaginaryTraversalCost, reintegrationDefect, sub_eq_zero]
/-- Observer-accessible material weight: how strongly realization resists a
latent traversal at each embodied state. The word "gravity" is operational
here; no Einstein equation or physical mass identity is asserted. -/
structure MaterialGravity (State : Type*) where
  weight : State -> Real
  weight_nonneg : forall x, 0 <= weight x

/-- Materially weighted imaginary-traversal cost. Residue supplies the phase
mismatch; material gravity supplies the price of realizing that mismatch. -/
def weightedTraversalCost {State : Type*} [NormedAddCommGroup State]
    (G : MaterialGravity State) (I : Interface State) (x : State) : Real :=
  G.weight x * imaginaryTraversalCost I x

theorem weightedTraversalCost_nonneg {State : Type*}
    [NormedAddCommGroup State] (G : MaterialGravity State)
    (I : Interface State) (x : State) :
    0 <= weightedTraversalCost G I x :=
  mul_nonneg (G.weight_nonneg x) (imaginaryTraversalCost_nonneg I x)

/-- Curvature cost is positive exactly when material weight is positive and
the imaginary traversal leaves a reintegration residue. -/
theorem weightedTraversalCost_pos_iff {State : Type*}
    [NormedAddCommGroup State] (G : MaterialGravity State)
    (I : Interface State) (x : State) :
    0 < weightedTraversalCost G I x <->
      And (0 < G.weight x)
        (Not (I.regulate (I.imagine x) = I.imagine (I.regulate x))) := by
  rw [weightedTraversalCost, mul_pos_iff]
  constructor
  · intro h
    rcases h with h | h
    · exact And.intro h.1 ((imaginaryTraversalCost_pos_iff I x).mp h.2)
    · exact False.elim ((not_lt_of_ge (G.weight_nonneg x)) h.1)
  · intro h
    exact Or.inl (And.intro h.1 ((imaginaryTraversalCost_pos_iff I x).mpr h.2))

/-- With the same traversal residue, increasing material weight cannot lower
the realized curvature cost. -/
theorem weightedTraversalCost_mono_gravity {State : Type*}
    [NormedAddCommGroup State] (G1 G2 : MaterialGravity State)
    (I : Interface State) (x : State) (hweight : G1.weight x <= G2.weight x) :
    weightedTraversalCost G1 I x <= weightedTraversalCost G2 I x := by
  exact mul_le_mul_of_nonneg_right hweight (imaginaryTraversalCost_nonneg I x)

/-- A weightless material channel charges no curvature cost even if the latent
traversal is noncommuting. This blocks identification of residue with cost. -/
theorem zero_gravity_zero_cost {State : Type*} [NormedAddCommGroup State]
    (I : Interface State) (x : State) :
    weightedTraversalCost
      { weight := fun _ => 0, weight_nonneg := fun _ => le_rfl } I x = 0 := by
  simp [weightedTraversalCost]
/-- Identifying geometric/observer curvature with materially weighted traversal
cost requires an explicit bridge. The certificate prevents the attractive
interpretation from being installed merely because both quantities are
nonnegative. -/
structure CurvatureCostCertificate (State : Type*) [NormedAddCommGroup State]
    (I : Interface State) where
  gravity : MaterialGravity State
  curvature : State -> Real
  curvature_eq_cost : forall x,
    curvature x = weightedTraversalCost gravity I x

theorem CurvatureCostCertificate.curvature_nonneg {State : Type*}
    [NormedAddCommGroup State] {I : Interface State}
    (C : CurvatureCostCertificate State I) (x : State) :
    0 <= C.curvature x := by
  rw [C.curvature_eq_cost]
  exact weightedTraversalCost_nonneg C.gravity I x

/-- Under the explicit bridge, positive curvature cost is exactly the meeting
of positive material gravity and a noncommuting imaginary traversal. -/
theorem CurvatureCostCertificate.curvature_pos_iff {State : Type*}
    [NormedAddCommGroup State] {I : Interface State}
    (C : CurvatureCostCertificate State I) (x : State) :
    0 < C.curvature x <->
      And (0 < C.gravity.weight x)
        (Not (I.regulate (I.imagine x) = I.imagine (I.regulate x))) := by
  rw [C.curvature_eq_cost]
  exact weightedTraversalCost_pos_iff C.gravity I x

/-- Free reintegration forces zero curvature cost for every material weight.
The converse needs positive gravity and is supplied by `curvature_pos_iff`. -/
theorem CurvatureCostCertificate.curvature_zero_of_free_reintegration
    {State : Type*} [NormedAddCommGroup State] {I : Interface State}
    (C : CurvatureCostCertificate State I) (x : State)
    (hfree : I.regulate (I.imagine x) = I.imagine (I.regulate x)) :
    C.curvature x = 0 := by
  rw [C.curvature_eq_cost, weightedTraversalCost]
  simp [imaginaryTraversalCost_eq_zero_iff I x, hfree]
/-- Active imagination can still be cost-free: negation commutes with identity
regulation, so the traversal-cost interpretation preserves the earlier
non-identification countermodel. -/
theorem active_imagination_can_have_zero_traversalCost :
    Exists fun I : Interface Real =>
      And (ImaginationActive I) (forall x, imaginaryTraversalCost I x = 0) := by
  refine Exists.intro { imagine := fun x => -x, regulate := id } ?_
  constructor
  · exact Exists.intro 1 (by norm_num)
  · intro x
    simp [imaginaryTraversalCost, reintegrationDefect]
/-- An embodied regulatory surface: the imagined alternative is unreal,
changes the selected action, and returns inside the body's admitted boundary.
This is a control interface, not a metaphysical definition of consciousness. -/
structure EmbodiedRegulation (Simulation Action : Type*) where
  imagined : Simulation
  realized : Simulation → Prop
  withImagination : Action
  withoutImagination : Action
  authorized : Action → Prop

def OperationalImaginaryControl {Simulation Action : Type*}
    (E : EmbodiedRegulation Simulation Action) : Prop :=
  ¬ E.realized E.imagined ∧
    E.withImagination ≠ E.withoutImagination ∧
    E.authorized E.withImagination

theorem operationalControl_components {Simulation Action : Type*}
    {E : EmbodiedRegulation Simulation Action}
    (h : OperationalImaginaryControl E) :
    ¬ E.realized E.imagined ∧
      E.withImagination ≠ E.withoutImagination ∧
      E.authorized E.withImagination := h

/-- Constant oriented residue accumulated once per SRMF revolution. -/
def accumulatedResidue (x₀ residue : ℝ) (n : ℕ) : ℝ :=
  x₀ + n * residue

theorem accumulatedResidue_succ (x₀ residue : ℝ) (n : ℕ) :
    accumulatedResidue x₀ residue (n + 1) =
      accumulatedResidue x₀ residue n + residue := by
  simp [accumulatedResidue]
  ring

/-- Positive oriented residue produces strict forward motion. -/
theorem accumulatedResidue_strictMono {x₀ residue : ℝ} (hresidue : 0 < residue) :
    StrictMono (accumulatedResidue x₀ residue) := by
  intro m n hmn
  simp only [accumulatedResidue]
  have hcast : (m : ℝ) < n := Nat.cast_lt.mpr hmn
  nlinarith

/-- A positive recurring residue prevents a later revolution from returning
to the initial embodied state. -/
theorem accumulatedResidue_ne_initial {x₀ residue : ℝ}
    (hresidue : 0 < residue) {n : ℕ} (hn : 0 < n) :
    accumulatedResidue x₀ residue n ≠ x₀ := by
  have hpos : 0 < (n : ℝ) * residue := mul_pos (Nat.cast_pos.mpr hn) hresidue
  simp [accumulatedResidue, ne_of_gt hpos]

end ForcingAnalysis.Book4ImaginaryRegulationCurvature
