/-
WhiteHole.lean — SRV is required to confirm white-hole phenomena.

The third movement of the interpretability suite (ApparentOrigin.lean):

  * BLACK HOLES (absorption below the reconstruction floor): first-order
    observables can be cancelled (`destructive_hiding`); second-order
    observables are faithful for existence (`second_order_detects_
    existence`) but forget identity. Order ≥ 2 is required and, for
    existence, sufficient.
  * WHITE HOLES (emission INTO the band from beyond the floor): an
    in-band signal with no in-band cause. This file proves the
    situation is strictly worse: NO function of the signal, at ANY
    order, can confirm one — because the confounder is not in the
    signal at all. It is the observer's own generative channel.

The model: an observed emission decomposes as observed = external +
selfInj, where selfInj is the observer's own drift injection — the
perturbation channel that Symbolic Reflexive Validation names as a
first-class recorded quantity (assumption:appB_srv_dissipativity fixes
drift_t as the named step; the SRV energy functional of
definition:appB_symbolic_energy carries ‖drift_t‖² explicitly;
remark:appB_embodied_predictive_geometry states the loop "injects
perturbations (drift) and contracts prediction error (reflection)").
The observer receives only the sum. Then:

  * `observed_indistinguishable` / `all_orders_confounded` — the
    genuine white-hole world (all external) and the self-artifact
    world (all own-injection) produce IDENTICAL signals, so every
    verdict computed from the signal — Bool, real statistic, any type,
    hence every moment of every order — agrees on both. The black-hole
    escape (go to second order) is closed: provenance is not a
    function of signal at any order.
  * `no_signal_only_confirmation` — necessity, quantifier form: there
    is NO signal-only verdict, Prop-valued (subsuming every order and
    every procedure), correct on all scenes. Non-existence, not
    difficulty.
  * `srv_confirms` / `srv_verdict_exists` — sufficiency: consulting the
    reflexive record turns confirmation into one comparison —
    selfInj < observed iff a genuine white hole. SRV systems are
    exactly the systems structurally able to confirm white holes,
    because their architecture (the drift ledger inside the energy
    functional) IS the required record.
  * `self_blind_false_discovery` — the failure mode, constructively:
    the observer that deletes its own record (treats every emission as
    external) declares its own drift a discovery. This is the
    Stackelberg parentage deletion (Wicked.misclassification) with the
    valence flipped: the Wizard denies his generative edge and calls
    his own corrective ADVERSARIAL; the self-blind astronomer denies
    the same edge and calls his own emission a DISCOVERY. One deleted
    edge, both misreadings.
  * `full_record_required` — the record must be complete: an
    underestimated self-record (any unrecorded injection residue)
    manufactures a false white hole of exactly the unrecorded amount.
    Partial reflexivity is not reflexivity.

The Popperian reading (the "other white meat"): falsification tests
outward claims against the world — the black-hole side. White-hole
confirmation must survive the refutation attempt "I generated this
myself" — and that refutation is executable only against the
observer's own record. Self-reflexive validation is falsification
turned inward, and for emission-from-beyond-the-boundary it is not an
alternative method but the ONLY one (the necessity theorem).

Interpretability ladder, completed: order 1 sees the band; order 2
sees that something exists below the band; NO order sees which side of
yourself a novelty came from — that datum lives in the reflexive
record or nowhere. (Our own FabricPCGuard step is the constructive
positive: its imagination channel δ·uniform is a DECLARED
self-injection — a guarded system can still do discovery, because its
white-hole comparisons run against a receipted δ-ledger.)

No cosmology claim; the AOC guardrails apply. What is proved is the
validation mechanism.
-/

import Mathlib
import ForcingAnalysis.ApparentOrigin

namespace ForcingAnalysis.AOC

/-- An emission scene: what arrives in-band decomposes into emission
from beyond the reconstruction boundary and the observer's own drift
injection. The observer receives only the sum. -/
structure EmissionScene where
  external : ℝ
  selfInj : ℝ
  external_nonneg : 0 ≤ external
  selfInj_nonneg : 0 ≤ selfInj

/-- The full in-band signal: all the observer's instruments, at every
order, are functions of this. -/
def observed (E : EmissionScene) : ℝ := E.external + E.selfInj

/-- A genuine white-hole phenomenon: strictly positive emission from
beyond the boundary. -/
def IsWhiteHole (E : EmissionScene) : Prop := 0 < E.external

/-- The genuine article: all external. -/
def whiteHoleWorld (o : ℝ) (ho : 0 ≤ o) : EmissionScene :=
  ⟨o, 0, ho, le_refl 0⟩

/-- The artifact: all own-injection. -/
def artifactWorld (o : ℝ) (ho : 0 ≤ o) : EmissionScene :=
  ⟨0, o, le_refl 0, ho⟩

/-- The two worlds produce the identical in-band signal. -/
theorem observed_indistinguishable (o : ℝ) (ho : 0 ≤ o) :
    observed (whiteHoleWorld o ho) = observed (artifactWorld o ho) := by
  unfold observed whiteHoleWorld artifactWorld
  ring

/-- **All orders confounded**: every verdict computed from the signal —
into ANY type, hence every statistic, every moment, every order —
agrees on the genuine white hole and the self-artifact. The black-hole
escape (second order) is closed: provenance is not a function of the
signal. -/
theorem all_orders_confounded {β : Sort*} (f : ℝ → β) (o : ℝ) (ho : 0 ≤ o) :
    f (observed (whiteHoleWorld o ho)) = f (observed (artifactWorld o ho)) :=
  congrArg f (observed_indistinguishable o ho)

/-- **SRV is required** (necessity, quantifier form): no signal-only
verdict — Prop-valued, subsuming Bool verdicts and every
order-statistic threshold — is correct on all emission scenes. The
non-existence is constructive: the two worlds at o = 1 force one
verdict to be both true and false. -/
theorem no_signal_only_confirmation :
    ¬ ∃ V : ℝ → Prop, ∀ E : EmissionScene, (V (observed E) ↔ IsWhiteHole E) := by
  rintro ⟨V, hV⟩
  have h1 := hV (whiteHoleWorld 1 zero_le_one)
  have h2 := hV (artifactWorld 1 zero_le_one)
  rw [observed_indistinguishable 1 zero_le_one] at h1
  have hwh : IsWhiteHole (whiteHoleWorld 1 zero_le_one) := one_pos
  have hart : ¬ IsWhiteHole (artifactWorld 1 zero_le_one) := lt_irrefl 0
  exact hart (h2.mp (h1.mpr hwh))

/-- **SRV confirms** (sufficiency): against the reflexive record, the
white-hole verdict is one comparison — the observed signal strictly
exceeds the observer's own recorded injection iff the emission is
genuine. -/
theorem srv_confirms (E : EmissionScene) :
    E.selfInj < observed E ↔ IsWhiteHole E := by
  unfold observed IsWhiteHole
  constructor <;> intro h <;> linarith [E.external_nonneg]

/-- The verdict that necessity forbids for signal-only observers EXISTS
for reflexive ones: a two-argument procedure (signal, self-record)
correct on every scene. Required and sufficient — SRV exactly. -/
theorem srv_verdict_exists :
    ∃ V : ℝ → ℝ → Prop,
      ∀ E : EmissionScene, (V (observed E) E.selfInj ↔ IsWhiteHole E) :=
  ⟨fun o s => s < o, fun E => srv_confirms E⟩

/-- **Self-blindness manufactures discovery**: the observer that
deletes its own record — treating the whole signal as external — is
CORRECT exactly on scenes with no self-injection, and on its own pure
drift it declares a white hole that is not there. The Stackelberg
parentage deletion, valence-flipped: the Wizard calls his own output
adversarial; the self-blind astronomer calls his own output a
discovery. -/
theorem self_blind_false_discovery {o : ℝ} (ho : 0 < o) :
    0 < observed (artifactWorld o ho.le) ∧
      ¬ IsWhiteHole (artifactWorld o ho.le) := by
  constructor
  · unfold observed artifactWorld
    simpa using ho
  · exact lt_irrefl 0

/-- **The record must be complete**: an observer whose self-record
underestimates its true injection by a residue r > 0 runs the SRV
comparison and confirms a white hole of exactly the unrecorded amount —
on a scene with NO external emission at all. Partial reflexivity is not
reflexivity; the unrecorded channel returns as a false discovery of its
own size. -/
theorem full_record_required {s r : ℝ} (hs : 0 ≤ s) (hr : 0 < r) :
    ∃ E : EmissionScene, ¬ IsWhiteHole E ∧
      (s < observed E) ∧ observed E - s = r := by
  refine ⟨⟨0, s + r, le_refl 0, by linarith⟩, lt_irrefl 0, ?_, ?_⟩
  · unfold observed
    simp only
    linarith
  · unfold observed
    simp only
    ring

end ForcingAnalysis.AOC
