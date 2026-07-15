/-
Newton.lean — the Galilean instance of the common commuting schema
(ForcingKernel/Schema.lean): Newton's second law F = m·a.

Continues the force equations from Lorentz.lean into the classical
regime, with the honesty distributed as follows:

* The KINEMATIC content is stated through `HasDerivAt` chains: a
  trajectory x with velocity field x' and acceleration a at t.
* `galilean_boost_accel`: under a Galilean boost x ↦ x + t•w the velocity
  shifts by w and the acceleration is UNCHANGED — Newton's second law is
  strictly invariant under boosts (equivariance for the trivial action),
  a stronger and cheaper property than the Lorentz instance's, which
  needed the metric η inside the map. Here the metric does not appear:
  the bare force map is equivariant under EVERY continuous linear frame
  map (`newtonForce_equivariant`), and the restriction to O(3) is where
  specific force FIELDS live, not the second law itself. That contrast —
  where the metric sits — is the real structural difference between the
  two instances, visible in the types.
* `accelerated_frame_defect`: leaving the Galilean group by a uniformly
  accelerated frame x ↦ x + t²•w shifts the acceleration by exactly 2w —
  the commutation defect IS the fictitious force −2m•w, and it is nonzero
  whenever w is (`accelerated_frame_defect_ne`). The failed square is
  kept as the negative control; that this defect is locally
  indistinguishable from gravity (equivalence principle) is an
  interpretive remark, not a claim made here.
* The Lorentz → Newton contraction (c → ∞) relating this instance to
  Lorentz.lean is NOT proved here; it is ledger item LPS-O4 with a
  precise closure condition.
-/

import Mathlib
import ForcingKernel.Schema

namespace ForcingAnalysis

/-- Classical 3-vectors, bare index functions as in Lorentz.lean. -/
abbrev NVec : Type := Fin 3 → ℝ

/-- Newton's second law as a map: F = m • a. -/
def newtonForce (m : ℝ) (a : NVec) : NVec := m • a

/-- Galilean boost of a trajectory shifts the velocity by the boost
vector: if x has velocity v at t, then x + s•w has velocity v + w. -/
theorem galilean_boost_velocity {x : ℝ → NVec} {v : NVec} {t : ℝ}
    (hx : HasDerivAt x v t) (w : NVec) :
    HasDerivAt (x + fun s => s • w) (v + w) t := by
  have hw : HasDerivAt (fun s : ℝ => s • w) w t := by
    simpa using (hasDerivAt_id t).smul_const w
  exact hx.add hw

/-- **Galilean invariance of acceleration** (and hence of the force):
boosting shifts the velocity field by the constant w, and the
acceleration at t is exactly the original one. The boosted square
commutes on the nose. -/
theorem galilean_boost_accel {x x' : ℝ → NVec} {a : NVec} {t : ℝ} (w : NVec)
    (hx' : ∀ s, HasDerivAt x (x' s) s) (hx'' : HasDerivAt x' a t) :
    (∀ s, HasDerivAt (x + fun r => r • w) (x' s + w) s) ∧
      HasDerivAt (fun s => x' s + w) a t :=
  ⟨fun s => galilean_boost_velocity (hx' s) w, by simpa using hx''.add_const w⟩

/-- Velocity and acceleration are equivariant under every continuous
linear frame map: differentiation commutes with L. -/
theorem accel_linear_equivariant {x x' : ℝ → NVec} {a : NVec} {t : ℝ}
    (L : NVec →L[ℝ] NVec)
    (hx' : ∀ s, HasDerivAt x (x' s) s) (hx'' : HasDerivAt x' a t) :
    (∀ s, HasDerivAt (fun r => L (x r)) (L (x' s)) s) ∧
      HasDerivAt (fun s => L (x' s)) (L a) t :=
  ⟨fun s => L.hasFDerivAt.comp_hasDerivAt s (hx' s),
   L.hasFDerivAt.comp_hasDerivAt t hx''⟩

/-- The force map intertwines every linear frame map: F(m, L a) = L (F(m, a)). -/
theorem newtonForce_linear_equivariant (m : ℝ) (L : NVec →L[ℝ] NVec) (a : NVec) :
    newtonForce m (L a) = L (newtonForce m a) :=
  (L.map_smul m a).symm

/-- **Newton instance of the schema**: the force map is
`ForcingKernel.Equivariant` for the action of continuous linear frame
maps — the SAME interface as the Lorentz and forcing instances. Note the
group here is all of GL (continuous linear maps): the second law itself
carries no metric; O(3) enters only with specific force fields. -/
theorem newtonForce_equivariant (m : ℝ) :
    ForcingKernel.Equivariant
      (G := NVec →L[ℝ] NVec)
      (fun L a => L a) (fun L f => L f) (newtonForce m) :=
  fun L a => newtonForce_linear_equivariant m L a

/-- **Countermodel / negative control (fictitious force)**: a uniformly
ACCELERATED frame x ↦ x + t²•w — outside the Galilean group — shifts the
acceleration by exactly 2w. The commutation defect is the fictitious
force −2m•w: the failed square is quantitative information, not noise. -/
theorem accelerated_frame_defect {x x' : ℝ → NVec} {a : NVec} {t : ℝ} (w : NVec)
    (hx' : ∀ s, HasDerivAt x (x' s) s) (hx'' : HasDerivAt x' a t) :
    (∀ s, HasDerivAt (x + fun r => (r ^ 2) • w) (x' s + (2 * s) • w) s) ∧
      HasDerivAt (fun s => x' s + (2 * s) • w) (a + (2 : ℝ) • w) t := by
  constructor
  · intro s
    have hsq : HasDerivAt (fun r : ℝ => r ^ 2) (2 * s) s := by
      simpa using hasDerivAt_pow 2 s
    exact (hx' s).add (hsq.smul_const w)
  · have h2 : HasDerivAt (fun s : ℝ => 2 * s) 2 t := by
      simpa using (hasDerivAt_id t).const_mul (2 : ℝ)
    exact hx''.add (h2.smul_const w)

/-- The fictitious defect is nonzero whenever the frame acceleration is:
the square genuinely fails off the group. -/
theorem accelerated_frame_defect_ne {a : NVec} {w : NVec} (hw : w ≠ 0) :
    a + (2 : ℝ) • w ≠ a := by
  intro h
  have h0 : (2 : ℝ) • w = 0 := by
    have := congrArg (fun z => z - a) h
    simpa [add_comm, add_sub_cancel_right] using this
  exact hw (by simpa [smul_eq_zero] using h0)

end ForcingAnalysis
