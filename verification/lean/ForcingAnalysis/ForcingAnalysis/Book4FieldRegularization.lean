/-
Book4FieldRegularization.lean — an explicit observer-cutoff kernel for the
field-theory regularization claim in Principia Symbolica Book 4.
-/
import Mathlib

namespace ForcingAnalysis.Book4FieldRegularization

/-- A hard observer cutoff: momentum modes above `cutoff` are unavailable. -/
def cutoffMode (cutoff momentum : ℕ) (amplitude : ℝ) : ℝ :=
  if momentum ≤ cutoff then amplitude else 0

theorem cutoffMode_eq_self {cutoff momentum : ℕ} {amplitude : ℝ}
    (h : momentum ≤ cutoff) :
    cutoffMode cutoff momentum amplitude = amplitude := by
  simp [cutoffMode, h]

theorem cutoffMode_eq_zero {cutoff momentum : ℕ} {amplitude : ℝ}
    (h : cutoff < momentum) :
    cutoffMode cutoff momentum amplitude = 0 := by
  simp [cutoffMode, Nat.not_le_of_gt h]

theorem cutoffMode_abs_le (cutoff momentum : ℕ) (amplitude : ℝ) :
    |cutoffMode cutoff momentum amplitude| ≤ |amplitude| := by
  by_cases h : momentum ≤ cutoff
  · simp [cutoffMode, h]
  · simp [cutoffMode, h]

/-- A finite perturbative insertion is a product of its cutoff modes. -/
def perturbativeInsertion {order : ℕ} (cutoff : ℕ)
    (momentum : Fin order → ℕ) (amplitude : Fin order → ℝ) : ℝ :=
  ∏ i, cutoffMode cutoff (momentum i) (amplitude i)

/-- Any unresolved internal momentum kills the corresponding finite-order
insertion exactly. -/
theorem perturbativeInsertion_eq_zero_of_high_mode {order cutoff : ℕ}
    (momentum : Fin order → ℕ) (amplitude : Fin order → ℝ)
    (i : Fin order) (hi : cutoff < momentum i) :
    perturbativeInsertion cutoff momentum amplitude = 0 := by
  unfold perturbativeInsertion
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  exact cutoffMode_eq_zero hi

/-- The observer-accessible band has exactly `cutoff + 1` natural momentum
labels, hence every sum explicitly restricted to it is finite. -/
theorem accessibleBand_card (cutoff : ℕ) :
    (Finset.range (cutoff + 1)).card = cutoff + 1 := by
  simp

/-- Merely naming a positive resolution scale supplies no cutoff law: the
constant multiplier leaves every momentum mode unsuppressed. -/
theorem resolution_scale_alone_does_not_force_suppression :
    ∃ (kernel : ℕ → ℝ), ∀ momentum, kernel momentum ≠ 0 := by
  refine ⟨fun _ => 1, ?_⟩
  intro momentum
  norm_num

/- ================================================================
   Operator-level field regularization
   ================================================================ -/

/-- A certified compactly supported Fourier multiplier. The passband and
stopband laws are data; a positive resolution number alone cannot supply them. -/
structure ObserverCutoffKernel where
  cutoff : ℕ
  multiplier : ℕ → ℝ
  passband : ∀ p, p ≤ cutoff → multiplier p = 1
  stopband : ∀ p, cutoff < p → multiplier p = 0

/-- Apply the observer kernel to an entire momentum-space field. -/
def regularizeField (K : ObserverCutoffKernel) (field : ℕ → ℝ) : ℕ → ℝ :=
  fun p => K.multiplier p * field p

theorem regularizeField_passband (K : ObserverCutoffKernel) (field : ℕ → ℝ)
    {p : ℕ} (hp : p ≤ K.cutoff) :
    regularizeField K field p = field p := by
  simp [regularizeField, K.passband p hp]

theorem regularizeField_stopband (K : ObserverCutoffKernel) (field : ℕ → ℝ)
    {p : ℕ} (hp : K.cutoff < p) :
    regularizeField K field p = 0 := by
  simp [regularizeField, K.stopband p hp]

/-- Field regularization is additive. -/
theorem regularizeField_add (K : ObserverCutoffKernel) (f g : ℕ → ℝ) :
    regularizeField K (fun p => f p + g p) =
      fun p => regularizeField K f p + regularizeField K g p := by
  funext p
  simp [regularizeField, mul_add]

/-- Field regularization commutes with scalar multiplication. -/
theorem regularizeField_smul (K : ObserverCutoffKernel) (a : ℝ) (f : ℕ → ℝ) :
    regularizeField K (fun p => a * f p) =
      fun p => a * regularizeField K f p := by
  funext p
  simp [regularizeField]
  ring

/-- A hard observer cutoff is a projection: applying it twice changes nothing. -/
theorem regularizeField_idempotent (K : ObserverCutoffKernel) (field : ℕ → ℝ) :
    regularizeField K (regularizeField K field) = regularizeField K field := by
  funext p
  by_cases hp : p ≤ K.cutoff
  · simp [regularizeField, K.passband p hp]
  · have hp' : K.cutoff < p := Nat.lt_of_not_ge hp
    simp [regularizeField, K.stopband p hp']

/-- Every regularized field is compactly supported in the accessible natural
momentum band. -/
theorem regularized_support_bounded (K : ObserverCutoffKernel) (field : ℕ → ℝ) :
    Function.support (regularizeField K field) ⊆
      {p | p ≤ K.cutoff} := by
  intro p hp
  by_contra hle
  have hgt : K.cutoff < p := Nat.lt_of_not_ge hle
  exact hp (regularizeField_stopband K field hgt)

/-- Internal momentum assignments for a fixed perturbative order range only
over the observer-accessible band. -/
abbrev AccessibleAssignment (K : ObserverCutoffKernel) (order : ℕ) :=
  Fin order → Fin (K.cutoff + 1)

/-- A fixed-order diagram has a finite, explicitly counted assignment space. -/
theorem accessibleAssignment_card (K : ObserverCutoffKernel) (order : ℕ) :
    Fintype.card (AccessibleAssignment K order) = (K.cutoff + 1) ^ order := by
  simp [AccessibleAssignment]

/-- A fixed-order regularized diagram is a finite sum over accessible internal
momenta. -/
def fixedOrderDiagram (K : ObserverCutoffKernel) (order : ℕ)
    (integrand : AccessibleAssignment K order → ℝ) : ℝ :=
  ∑ assignment, integrand assignment

/-- The empty-order diagram has exactly its unique empty assignment. -/
theorem fixedOrderDiagram_zero (K : ObserverCutoffKernel)
    (integrand : AccessibleAssignment K 0 → ℝ) :
    fixedOrderDiagram K 0 integrand = integrand (fun i => Fin.elim0 i) := by
  simp [fixedOrderDiagram]
  apply congrArg integrand
  funext i
  exact Fin.elim0 i

/-- Diagram-by-diagram finiteness does not establish convergence or a uniform
bound of the all-orders perturbation series. Unit finite coefficients have
unbounded partial sums. -/
theorem fixed_orders_do_not_force_all_orders_control :
    let coefficient : ℕ → ℝ := fun _ => 1
    ∀ bound : ℝ, ∃ order : ℕ,
      bound < ∑ n ∈ Finset.range order, coefficient n := by
  dsimp
  intro bound
  obtain ⟨order, horder⟩ := exists_nat_gt bound
  refine ⟨order, ?_⟩
  simpa using horder
end ForcingAnalysis.Book4FieldRegularization
