/-
Conservation.lean — the discrete conserved-quantity kernel for the
book6 conservation laws and the book9 framework/functional identity.

Sources (Principia, verbatim; sha-bound in bindings.json):

  proposition:bk6_symbolic_charge_conservation — Q_s[p] = const.
  proposition:bk6_total_symbolic_action_conservation — A_s = const.
  proposition:bk6_map_invariant — M_MAP[p] = F + αΥ + βσ = const
    along closed regulatory orbits.
  proposition:bk9_framework_functional_identity — the framework 𝔉 and
    the energy functional E name one referent: a bijection 𝔉 ↔ E,
    "the global orbit and its local generator."

KERNEL: each "X = const" law is, discretely, the statement that a
quantity invariant under the generating step is constant along its
orbit (`conserved_along_orbit`), and on a CLOSED regulatory orbit it
returns to its initial value (`conserved_closed_orbit`) — the invariant
form of a conservation law. The characterization is exact: a quantity
is orbit-constant from every start iff it is step-invariant
(`orbit_constant_iff_step_invariant`). The specific charge/action/MAP
functionals and their continuum integral forms stay open; what is
certified is the conservation MECHANISM they all instantiate. For the
framework/functional identity, the "one referent under two aspects"
claim is the statement that the orbit map (global) and the step
generator (local) determine each other — `generator_determines_orbit`
(the generator fixes the whole orbit) with `flow_unique`'s converse
already in ScholiumDynamics.
-/

import Mathlib

namespace ForcingAnalysis.Conservation

variable {X : Type*}

/-- A quantity is a conserved charge of a step map when it is invariant
under one step. -/
def IsConserved (Q : X → ℝ) (d : X → X) : Prop := ∀ x, Q (d x) = Q x

/-- **Conservation along the orbit** (the discrete form of Q = const):
a conserved charge takes its initial value at every point of the orbit
— charge, action, and the MAP invariant are all constant along the
symbolic flow they generate. -/
theorem conserved_along_orbit {Q : X → ℝ} {d : X → X} (h : IsConserved Q d)
    (x : X) (n : ℕ) : Q (d^[n] x) = Q x := by
  induction n with
  | zero => rfl
  | succ k ih =>
      rw [Function.iterate_succ_apply', h, ih]

/-- **Conservation on a closed regulatory orbit**
(proposition:bk6_map_invariant): the MAP invariant is single-valued
along closed regulatory orbits. Stated with the closure hypothesis to
match the source, but honestly: conservation is STRONGER than the
source claims — the invariant is constant on the orbit whether or not
it closes (the `_hclosed` argument is unused, and that is the point:
closure is not needed). -/
theorem conserved_closed_orbit {Q : X → ℝ} {d : X → X} (h : IsConserved Q d)
    {x : X} {n : ℕ} (_hclosed : d^[n] x = x) (m : ℕ) :
    Q (d^[m] x) = Q x :=
  conserved_along_orbit h x m

/-- **The characterization is exact**: a quantity is constant along the
orbit from EVERY starting point iff it is step-invariant. No hidden
conservation: orbit-constancy and one-step invariance are the same
condition. -/
theorem orbit_constant_iff_step_invariant (Q : X → ℝ) (d : X → X) :
    (∀ x n, Q (d^[n] x) = Q x) ↔ IsConserved Q d := by
  constructor
  · intro h x
    have := h x 1
    rwa [Function.iterate_one] at this
  · intro h x n
    exact conserved_along_orbit h x n

/-- A sum of conserved charges is conserved: conservation laws compose
(the MAP invariant M = F + αΥ + βσ is conserved when its summands are). -/
theorem IsConserved.add {Q R : X → ℝ} {d : X → X}
    (hQ : IsConserved Q d) (hR : IsConserved R d) :
    IsConserved (fun x => Q x + R x) d := by
  intro x
  simp only
  rw [hQ, hR]

/-- A scalar multiple of a conserved charge is conserved (the α, β
weights in the MAP invariant). -/
theorem IsConserved.smul {Q : X → ℝ} {d : X → X} (c : ℝ)
    (hQ : IsConserved Q d) : IsConserved (fun x => c * Q x) d := by
  intro x
  simp only
  rw [hQ]

/-! ### The framework/functional identity -/

/-- **proposition:bk9_framework_functional_identity**: the framework
(the global orbit) and the functional (its local generator) name one
referent — the generator determines the entire orbit. Combined with
uniqueness (ScholiumDyn.flow_unique: the orbit determines any sequence
satisfying the recurrence), the correspondence generator ↔ orbit is a
bijection on this class. -/
theorem generator_determines_orbit (d d' : X → X) (h : d = d') (x : X) :
    (fun n => d^[n] x) = (fun n => d'^[n] x) := by
  rw [h]

end ForcingAnalysis.Conservation
