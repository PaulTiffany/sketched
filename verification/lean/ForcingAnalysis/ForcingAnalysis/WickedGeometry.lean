/-
WickedGeometry.lean — the finite kernel of atlas fracture, Stackelberg
parentage, and grace flow.

Source: Paul Tiffany, "The Wicked Prior as a Bounded-Observer Manifold:
Atlas Fracture, Stackelberg Parentage, and Grace-Flow Repair" (2025),
read verbatim (read-only) from C:/Users/paulc/projects/wicked-geometry
(main.tex + README-FOR-LLMS.md). This is the entry point of the manifold
track: instead of assuming atlases glue (as every classical manifold
library does), the FRACTURE is formalized as first-class data — the
defect-zero case is the classical special case, per the repo-wide
non-normalized-forms rule.

What is certified here (finite/scalar kernels, in the paper's order):

  * RESOLUTION TRUNCATION as a named map (`truncate`): outer projection
    kills structure below the resolution floor ε. Its "what it forgets"
    theorem is `FracturePair`/`id_transition_distortion`: a pair the
    outer chart identifies while the inner metric separates by Δ forces
    distortion ≥ Δ on the identity transition — flattening, measured.
  * ATLAS FRACTURE (the paper's inf-over-transitions form, finitized):
    `no_low_distortion_transition` — if the outer chart's diameter is
    D_out and some pair has inner separation ≥ D_out + δ, then EVERY
    transition map suffers distortion ≥ δ. The infimum clause holds
    universally, not just for one ψ.
  * CURVATURE BLOW-UP (‖Ric‖ ≳ K/ε²): `stress_blowup` — for every
    stress level M there is a floor ε₀ > 0 below which K/ε² exceeds M.
    Explicit ε-management, no filter machinery: the collapse ε → 0
    forces unbounded stress.
  * STACKELBERG PARENTAGE (the generative paradox): a three-vertex
    carrier (leader ⇒ world ⇒ follower). `parentage_path` — the
    follower is reachable from the leader, π_F ∈ Ancestors-closure of
    π_L. `denial_breaks_ancestry` — deleting the leader's OWN
    generative edge is exactly what makes the corrective look
    parentless. `misclassification` packages the lemma: the adversarial
    label is correct in the edge-deleted model and wrong in the full
    one; labeling π_F adversarial ≡ denying an edge the leader owns.
  * REPAIRED OBJECTIVE: `repair_changes_optimum` — two states the outer
    metric cannot distinguish (equal L_out — the flattening again) are
    strictly separated by the dual-horizon objective L_out + λ·L_in for
    every λ > 0: inner truth as signal, not noise.
  * GRACE FLOW (P3/P4 kernels): `GraceFlow` carries cadence-bounded
    steps and coupling-proportional descent as structure fields.
    `grace_gradual` (P3): n steps move stress at most n·cadence — no
    single-jump repair. `grace_geometric` + `grace_tendsto_zero` (P4,
    positive half): positive coupling gives geometric stress decay to
    zero. `zero_coupling_stalls` (P4, negative half): an explicit
    coupling-zero flow satisfying every law whose stress never moves —
    convergence genuinely depends on coupling.

Not certified: the Riemannian/Ricci-flow forms themselves, the
embedding-curvature estimator (empirical, validated by V-Baum in the
source repo), the categorical-equivalence reconciliation, and P1/P2/
P5/P6 (empirical protocols). The bk9 grace/Lyapunov anchors state the
same flow skeleton on the Principia side; see the bindings.
-/

import Mathlib

namespace ForcingAnalysis.Wicked

noncomputable section

/-! ### Resolution truncation and what it forgets -/

variable {α : Type*}

/-- Outer projection at resolution floor ε: structure below the floor
is truncated to indistinguishability. A NAMED map, per the
non-normalized-forms rule — the collapse is data, not convention. -/
def truncate (ε : ℝ) (d : α → α → ℝ) : α → α → ℝ :=
  fun x y => if d x y < ε then 0 else d x y

/-- A fracture pair: the outer metric sees the pair below the floor
(so truncation identifies it) while the inner metric separates it by Δ. -/
def FracturePair (ε Δ : ℝ) (gout gin : α → α → ℝ) (x y : α) : Prop :=
  gout x y < ε ∧ Δ ≤ gin x y

/-- **What truncation forgets**: at a fracture pair, the identity
transition map suffers distortion at least Δ — the inner separation the
outer chart flattened away is exactly the transition defect. -/
theorem id_transition_distortion {ε Δ : ℝ} {gout gin : α → α → ℝ}
    {x y : α} (h : FracturePair ε Δ gout gin x y) (hΔ : 0 ≤ Δ) :
    Δ ≤ |truncate ε gout x y - gin x y| := by
  have htrunc : truncate ε gout x y = 0 := by
    simp [truncate, h.1]
  rw [htrunc, zero_sub, abs_neg, abs_of_nonneg (le_trans hΔ h.2)]
  exact h.2

/-- **Atlas fracture, finitized** (the paper's inf-over-transitions
clause): if the outer chart has diameter D_out and some pair has inner
separation ≥ D_out + δ, then EVERY transition map ψ suffers distortion
≥ δ at that pair — no low-distortion transition exists. -/
theorem no_low_distortion_transition {gout gin : α → α → ℝ}
    {Dout δ : ℝ} (hbound : ∀ a b, gout a b ≤ Dout)
    {x y : α} (hsep : Dout + δ ≤ gin x y) (ψ : α → α) :
    δ ≤ |gout (ψ x) (ψ y) - gin x y| := by
  have h1 : gout (ψ x) (ψ y) ≤ Dout := hbound _ _
  have h2 : gin x y - gout (ψ x) (ψ y) ≥ δ := by linarith
  calc δ ≤ gin x y - gout (ψ x) (ψ y) := h2
    _ ≤ |gin x y - gout (ψ x) (ψ y)| := le_abs_self _
    _ = |gout (ψ x) (ψ y) - gin x y| := abs_sub_comm _ _

/-! ### Curvature blow-up under resolution collapse -/

/-- **‖Ric‖ ≳ K/ε², made explicit**: for every stress level M there is
a resolution floor ε₀ > 0 below which the stress K/ε² exceeds M. The
collapse ε → 0 forces unbounded curvature stress — raw ε-management,
no filter machinery. -/
theorem stress_blowup {K : ℝ} (hK : 0 < K) (M : ℝ) :
    ∃ ε₀ > 0, ∀ ε : ℝ, 0 < ε → ε ≤ ε₀ → M ≤ K / ε ^ 2 := by
  have hMp : (0 : ℝ) < max M 1 := lt_of_lt_of_le one_pos (le_max_right M 1)
  refine ⟨Real.sqrt (K / max M 1), Real.sqrt_pos.mpr (div_pos hK hMp),
    fun ε hε hεle => ?_⟩
  have hε2 : ε ^ 2 ≤ K / max M 1 := by
    calc ε ^ 2 ≤ Real.sqrt (K / max M 1) ^ 2 := by
          exact pow_le_pow_left₀ hε.le hεle 2
      _ = K / max M 1 := Real.sq_sqrt (div_pos hK hMp).le
  rw [le_div_iff₀ (by positivity)]
  calc M * ε ^ 2 ≤ max M 1 * (K / max M 1) := by
        exact mul_le_mul (le_max_left M 1) hε2 (by positivity) hMp.le
    _ = K := by field_simp

/-! ### The Stackelberg parentage paradox -/

/-- The three-vertex Stackelberg carrier: the leader's policy, the
world it generates, the follower it induces. -/
inductive Agent where
  | leader | world | follower
  deriving DecidableEq, BEq, Repr

open Agent

abbrev SEdges := List (Agent × Agent)

/-- Fuel-bounded reachability on the tiny carrier. -/
def sreach : Nat → SEdges → Agent → Agent → Bool
  | 0, _, a, b => a == b
  | n + 1, E, a, b =>
      a == b || E.any fun e => e.1 == a && sreach n E e.2 b

/-- The full generative model: π_L generates E, E induces π_F. -/
def generativeModel : SEdges := [(leader, world), (world, follower)]

/-- The denial model: the leader's OWN generative edge deleted. -/
def denialModel : SEdges := [(world, follower)]

/-- The adversarial label: the follower is judged parentless — not in
the ancestry closure of the leader. -/
def AdversarialLabel (E : SEdges) : Prop :=
  sreach 3 E leader follower = false

instance (E : SEdges) : Decidable (AdversarialLabel E) := by
  unfold AdversarialLabel
  infer_instance

/-- **Parentage**: in the full model the follower IS in the leader's
ancestry closure — π_L ⇒ E ⇒ π_F. -/
theorem parentage_path : sreach 3 generativeModel leader follower = true := by
  decide

/-- **Denial breaks ancestry**: deleting the generative edge is exactly
what orphans the corrective. -/
theorem denial_breaks_ancestry :
    sreach 3 denialModel leader follower = false := by decide

/-- **The misclassification lemma, carrier form**: the adversarial
label holds in the denial model and fails in the generative one —
labeling π_F adversarial is equivalent to denying an edge the leader
itself owns. -/
theorem misclassification :
    AdversarialLabel denialModel ∧ ¬ AdversarialLabel generativeModel := by
  refine ⟨by decide, by decide⟩

/-- **The repaired objective separates what the outer metric flattens**:
two states with EQUAL outer loss (outer-indistinguishable) but strictly
different inner loss are strictly ordered by L_out + λ·L_in for every
λ > 0 — inner-horizon truth as signal, not noise. -/
theorem repair_changes_optimum {σ : Type*} {Lout Lin : σ → ℝ} {s s' : σ}
    {lam : ℝ} (hlam : 0 < lam) (hout : Lout s' = Lout s)
    (hin : Lin s' < Lin s) :
    Lout s' + lam * Lin s' < Lout s + lam * Lin s := by
  have := mul_lt_mul_of_pos_left hin hlam
  linarith

/-! ### Grace flow: P3 gradualness, P4 coupling-dependent convergence -/

/-- The grace-flow kernel: stress with cadence-bounded steps (the
adaptive cadence φ(τ)) and coupling-proportional descent, all as
structure fields. Identity preservation is carried as a named
commitment. -/
structure GraceFlow where
  stress : Nat → ℝ
  stress_nonneg : ∀ t, 0 ≤ stress t
  cadence : ℝ
  cadence_nonneg : 0 ≤ cadence
  /-- P3: no single repair step jumps more than the cadence. -/
  gradual : ∀ t, |stress (t + 1) - stress t| ≤ cadence
  coupling : ℝ
  coupling_nonneg : 0 ≤ coupling
  coupling_le_one : coupling ≤ 1
  /-- Repair removes at least a coupling-fraction of current stress. -/
  descent : ∀ t, stress (t + 1) ≤ stress t - coupling * stress t
  /-- Reconciliation without erasing identity: a named commitment,
  kept as data rather than smoothed away. -/
  identityPreserved : Prop
  identity_holds : identityPreserved

/-- **P3, gradualness**: n repair steps move stress at most n·cadence —
grace is a flow, not a jump. -/
theorem grace_gradual (G : GraceFlow) (n : Nat) :
    |G.stress n - G.stress 0| ≤ n * G.cadence := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep := G.gradual k
      have htri : |G.stress (k + 1) - G.stress 0| ≤
          |G.stress (k + 1) - G.stress k| + |G.stress k - G.stress 0| :=
        abs_sub_le _ _ _
      have hcast : ((k + 1 : Nat) : ℝ) * G.cadence =
          (k : ℝ) * G.cadence + G.cadence := by push_cast; ring
      rw [hcast]
      linarith

/-- **P4, positive half — geometric decay**: stress after n steps is at
most (1 − coupling)ⁿ times the initial stress. -/
theorem grace_geometric (G : GraceFlow) (n : Nat) :
    G.stress n ≤ (1 - G.coupling) ^ n * G.stress 0 := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hdesc := G.descent k
      have hfac : (0 : ℝ) ≤ 1 - G.coupling := by
        linarith [G.coupling_le_one]
      calc G.stress (k + 1) ≤ G.stress k - G.coupling * G.stress k := hdesc
        _ = (1 - G.coupling) * G.stress k := by ring
        _ ≤ (1 - G.coupling) * ((1 - G.coupling) ^ k * G.stress 0) :=
            mul_le_mul_of_nonneg_left ih hfac
        _ = (1 - G.coupling) ^ (k + 1) * G.stress 0 := by ring

/-- **P4, positive half — convergence**: positive coupling drives
stress to zero. -/
theorem grace_tendsto_zero (G : GraceFlow) (hc : 0 < G.coupling) :
    Filter.Tendsto G.stress Filter.atTop (nhds 0) := by
  have hfac0 : (0 : ℝ) ≤ 1 - G.coupling := by linarith [G.coupling_le_one]
  have hfac1 : |1 - G.coupling| < 1 := by
    rw [abs_of_nonneg hfac0]
    linarith
  have hpow : Filter.Tendsto (fun n : Nat => (1 - G.coupling) ^ n * G.stress 0)
      Filter.atTop (nhds 0) := by
    have := (tendsto_pow_atTop_nhds_zero_of_abs_lt_one hfac1).mul_const
      (G.stress 0)
    simpa using this
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds hpow
    G.stress_nonneg (grace_geometric G)

/-- **P4, negative half — the stall**: an explicit coupling-zero flow
satisfying every law whose stress never moves. Convergence genuinely
depends on coupling; the laws alone do not force repair. -/
def stalledFlow : GraceFlow where
  stress := fun _ => 1
  stress_nonneg := fun _ => by norm_num
  cadence := 0
  cadence_nonneg := le_refl 0
  gradual := fun _ => by norm_num
  coupling := 0
  coupling_nonneg := le_refl 0
  coupling_le_one := by norm_num
  descent := fun _ => by norm_num
  identityPreserved := True
  identity_holds := trivial

theorem zero_coupling_stalls : ∀ t, stalledFlow.stress t = 1 :=
  fun _ => rfl

end

end ForcingAnalysis.Wicked
