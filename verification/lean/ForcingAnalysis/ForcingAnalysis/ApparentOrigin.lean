/-
ApparentOrigin.lean — the observer-quotient mechanism of Apparent-Origin
Cosmology, and the conditionality of the Moloch hedge on a real floor.

Source (read verbatim, read-only, from C:/src/observer_cosmology): the
AOC canonical proof spine defines the observer quotient q_ε(u) =
max(u, ε) (and its smooth softplus form) and proves the mechanism in
the simplest setting: "A process with no ontological beginning in u can
acquire an apparent origin in q_ε(u)." Canonical slogan: boundary of
reconstruction, not beginning of being.

Scope honesty, per the source repo's own forbidden-simplifications
list: NOTHING here is a cosmology claim. The false bottom proving "a
deeper physical universe below the Big Bang" is explicitly forbidden
language; what is proved is the OBSERVER-QUOTIENT MECHANISM — that
bounded reconstruction manufactures apparent origins — and its
consequences for instrumentation and for this repo's own safety
theorems. The theorems:

  * `apparent_origin_floor` / `sub_band_compressed` /
    `above_band_faithful` — the canonical quotient: everything below
    the resolution floor is compressed to ONE apparent origin, while
    above-band structure is preserved exactly. The instrumentable band
    is faithful in band and blind below it.
  * `unbounded_depth_acquires_origin` — the source's mechanism, proved:
    states of arbitrary depth all sit AT the apparent origin. Seeing a
    bottom is a theorem about the quotient, not about u.
  * `tested_floor_ge` + `class_floor_not_universal` — the composer
    theorem: the floor of any tested subclass of instruments only
    upper-bounds the floor of the full class; the double-bass witness
    makes it strict. An instrumentable band is not a universal one.
  * `sub_band_energy_bounded_of_finite` — the safety assumption, NAMED:
    with finitely many modes each below resolution, total sub-band
    energy is bounded by n·ε². The bound is purchased by the finiteness
    hypothesis and by nothing else.
  * `false_bottom_energy` — and without it: for every ε and every M
    there is a configuration invisible at first order (every mode
    strictly sub-band) whose energy exceeds M. Observationally the
    quotient of this configuration is indistinguishable from silence.
  * `concert_effect` — second-order observability: coherent sub-band
    components, each individually invisible, produce an aggregate
    exceeding any in-band threshold. The glass breaks: ensemble
    observables can witness what no single-mode observation can.
  * `destructive_hiding` — the honest limit of concert effects:
    cancelling sub-band content is invisible to the aggregate too.
    Coherence is a genuine HYPOTHESIS of second-order detection, not a
    free lunch; incoherent depth hides from both orders.
  * `false_bottom_voids_hedge` — the teeth, turned on ourselves: the
    Moloch hedge (SRMFHelix.moloch_hedge) forbids perpetual fixed-rate
    work ON A FLOORED POTENTIAL. Here is a Gödel-safe cycle on an
    unfloored potential doing fixed-rate work forever, satisfying every
    other law. The floor hypothesis is the entire guarantee: a loop
    with access to an unbounded sub-band reservoir is not bounded by
    any budget argument that assumed the apparent bottom was real.
    Assuming a bottom that is not there voids the safety theorem —
    machine-checked.
-/

import Mathlib
import ForcingAnalysis.SRMFHelix

namespace ForcingAnalysis.AOC

noncomputable section

/-- The canonical AOC observer quotient: reconstruction saturates at
the resolution floor ε. -/
def quotient (ε u : ℝ) : ℝ := max u ε

/-- The quotient has a bottom at ε regardless of u: the apparent
origin exists by construction of the observer, not by property of the
process. -/
theorem apparent_origin_floor (ε u : ℝ) : ε ≤ quotient ε u :=
  le_max_right u ε

/-- All sub-threshold depth is compressed to the SAME apparent origin:
two states of arbitrarily different depth are identified. -/
theorem sub_band_compressed {ε u u' : ℝ} (h : u ≤ ε) (h' : u' ≤ ε) :
    quotient ε u = quotient ε u' := by
  unfold quotient
  rw [max_eq_right h, max_eq_right h']

/-- Above the floor the quotient is faithful: in-band structure is
preserved exactly. The instrumentable band really is instrumentable. -/
theorem above_band_faithful {ε u : ℝ} (h : ε ≤ u) : quotient ε u = u :=
  max_eq_left h

/-- **The AOC mechanism** (the source's toy-model claim, proved): a
process unbounded below in u — no ontological beginning — has every
arbitrarily deep state sitting AT the apparent origin of its quotient.
Seeing a bottom is a fact about the reconstruction, not about u. -/
theorem unbounded_depth_acquires_origin (ε M : ℝ) :
    ∃ u < M, quotient ε u = ε := by
  refine ⟨min M ε - 1, ?_, ?_⟩
  · calc min M ε - 1 < min M ε := by linarith
      _ ≤ M := min_le_left M ε
  · apply max_eq_right
    calc min M ε - 1 ≤ ε - 1 := by
          have := min_le_right M ε
          linarith
      _ ≤ ε := by linarith

/-- **The composer theorem**: the lowest note of any TESTED subclass of
instruments only upper-bounds the lowest note of the full class. -/
theorem tested_floor_ge {s t : Finset ℝ} (hsub : s ⊆ t)
    (hs : s.Nonempty) (ht : t.Nonempty) :
    t.min' ht ≤ s.min' hs :=
  Finset.min'_le t _ (hsub (s.min'_mem hs))

/-- The double-bass witness: strictness is real. The in-class floor is
1; the full class contains 0. An instrumentable band is not a universal
instrumentable band. -/
theorem class_floor_not_universal :
    ∃ (s t : Finset ℝ) (hs : s.Nonempty) (ht : t.Nonempty),
      s ⊆ t ∧ t.min' ht < s.min' hs := by
  refine ⟨{1}, {0, 1}, ⟨1, by simp⟩, ⟨0, by simp⟩, by
    intro x hx
    simp at hx
    simp [hx], ?_⟩
  norm_num

/-- **The safety assumption, named**: with FINITELY many modes each
strictly below resolution, total sub-band energy is bounded by n·ε².
The bound comes from the finiteness hypothesis and nothing else. -/
theorem sub_band_energy_bounded_of_finite {n : ℕ} {ε : ℝ}
    (x : Fin n → ℝ) (hx : ∀ i, |x i| < ε) :
    ∑ i, x i ^ 2 ≤ n * ε ^ 2 := by
  have hbound : ∀ i, x i ^ 2 ≤ ε ^ 2 := by
    intro i
    have h := hx i
    nlinarith [abs_nonneg (x i), sq_abs (x i)]
  calc ∑ i, x i ^ 2 ≤ ∑ _i : Fin n, ε ^ 2 :=
        Finset.sum_le_sum fun i _ => hbound i
    _ = n * ε ^ 2 := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
          nsmul_eq_mul]

/-- **The false bottom, energetically**: drop the finiteness assumption
and for every resolution ε and every bound M there is a configuration
invisible at first order — every mode strictly sub-band, its quotient
indistinguishable from silence — whose total energy exceeds M. Just
because you see a bottom does not mean there is one. -/
theorem false_bottom_energy {ε : ℝ} (hε : 0 < ε) (M : ℝ) :
    ∃ (k : ℕ) (x : Fin k → ℝ),
      (∀ i, |x i| < ε) ∧ M ≤ ∑ i, x i ^ 2 := by
  obtain ⟨k, hk⟩ := exists_nat_gt (4 * M / ε ^ 2)
  refine ⟨k, fun _ => ε / 2, fun i => ?_, ?_⟩
  · rw [abs_of_pos (by linarith)]
    linarith
  · have hsum : ∑ _i : Fin k, (ε / 2) ^ 2 = k * (ε ^ 2 / 4) := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
        nsmul_eq_mul]
      ring
    rw [hsum]
    have h2 : 4 * M / ε ^ 2 * (ε ^ 2 / 4) = M := by
      field_simp
    calc M = 4 * M / ε ^ 2 * (ε ^ 2 / 4) := h2.symm
      _ ≤ k * (ε ^ 2 / 4) :=
          mul_le_mul_of_nonneg_right hk.le (by positivity)

/-- **The concert effect** (second-order observability): coherent
sub-band components, each individually invisible, produce an aggregate
exceeding any in-band threshold. Ensemble observables witness what no
single-mode observation can — the glass breaks. -/
theorem concert_effect {ε : ℝ} (hε : 0 < ε) (T : ℝ) :
    ∃ (k : ℕ) (x : Fin k → ℝ),
      (∀ i, |x i| < ε) ∧ T ≤ ∑ i, x i := by
  obtain ⟨k, hk⟩ := exists_nat_gt (2 * T / ε)
  refine ⟨k, fun _ => ε / 2, fun i => ?_, ?_⟩
  · rw [abs_of_pos (by linarith)]
    linarith
  · have hsum : ∑ _i : Fin k, ε / 2 = k * (ε / 2) := by
      rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
        nsmul_eq_mul]
    rw [hsum]
    have h2 : 2 * T / ε * (ε / 2) = T := by
      field_simp
    calc T = 2 * T / ε * (ε / 2) := h2.symm
      _ ≤ k * (ε / 2) := mul_le_mul_of_nonneg_right hk.le (by positivity)

/-- **The honest limit of concert effects**: cancelling sub-band
content is invisible to the aggregate too. Coherence is a genuine
hypothesis of second-order detection; incoherent depth hides from both
orders. -/
theorem destructive_hiding {ε : ℝ} (hε : 0 < ε) :
    ∃ x : Fin 2 → ℝ,
      (∀ i, |x i| < ε) ∧ x ≠ 0 ∧ ∑ i, x i = 0 := by
  refine ⟨![ε / 2, -(ε / 2)], ?_, ?_, ?_⟩
  · intro i
    fin_cases i
    · show |ε / 2| < ε
      rw [abs_of_pos (by linarith)]
      linarith
    · show |-(ε / 2)| < ε
      rw [abs_neg, abs_of_pos (by linarith)]
      linarith
  · intro h
    have h0 := congrFun h 0
    simp at h0
    linarith
  · rw [Fin.sum_univ_two]
    show ε / 2 + -(ε / 2) = 0
    ring

/-- **Second order is faithful for existence**: the energy observable
detects content completely — zero aggregate energy iff literally
nothing there. Unlike the linear (first-order) aggregate, which
`destructive_hiding` fools, the quadratic observable cannot be
cancelled. Interpretability of a black box CAN know THAT something is
computed below the probe band. -/
theorem second_order_detects_existence {n : ℕ} (x : Fin n → ℝ) :
    ∑ i, x i ^ 2 = 0 ↔ x = 0 := by
  constructor
  · intro h
    funext i
    have hall := (Finset.sum_eq_zero_iff_of_nonneg
      (fun j _ => sq_nonneg (x j))).mp h i (Finset.mem_univ i)
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hall
  · intro h
    rw [h]
    simp

/-- **Second order forgets identity**: two genuinely different
configurations with identical energy at every order-2 aggregate. The
energy observable knows THAT, never WHAT — existence without
semantics. -/
theorem second_order_forgets_identity :
    ∃ x y : Fin 2 → ℝ, x ≠ y ∧ ∑ i, x i ^ 2 = ∑ i, y i ^ 2 := by
  refine ⟨![1, 0], ![-1, 0], ?_, ?_⟩
  · intro h
    have h0 := congrFun h 0
    simp at h0
    linarith
  · rw [Fin.sum_univ_two, Fin.sum_univ_two]
    norm_num

/-- **The false bottom voids the hedge** (the quantum-loop fear,
machine-checked): the Moloch hedge forbids perpetual fixed-rate work ON
A FLOORED POTENTIAL. Here is a Gödel-safe cycle — satisfying descent
and strict-descent-off-fixed-points, every law the hedge asks — on an
UNFLOORED potential, doing work exactly 1 at every step forever. The
floor hypothesis is the entire guarantee: a loop with access to an
unbounded reservoir beneath the apparent bottom is not bounded by any
budget argument that assumed the bottom was real. -/
theorem false_bottom_voids_hedge :
    ∃ G : SRMF.GodelSafeCycle ℝ, ∀ (x : ℝ) (n : ℕ),
      G.potential (G.step^[n + 1] x) = G.potential (G.step^[n] x) - 1 := by
  refine ⟨⟨fun x => x - 1, id, fun y => by simp, fun y hy => by
    simp only [id]
    have : y - 1 ≠ y := hy
    linarith [lt_of_le_of_ne (by linarith : y - 1 ≤ y) this]⟩, ?_⟩
  intro x n
  simp only [id]
  rw [Function.iterate_succ_apply']

end

end ForcingAnalysis.AOC
