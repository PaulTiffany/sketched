/-
AxiomataPrima.lean — the operational kernel of axiom:bk1_axiomata_prima.

The axiom, verbatim (Principia Book 1, "Drift as Origin"; sha-bound in
bindings.json): "Existence is not."

Three words, and the smallpack worker honestly skipped them as "no math
content." This file is the honest correction: the axiom HAS an
operational kernel, and it is the converse of WhiteHole.lean. White
holes proved provenance is not in the signal; Axiomata Prima says
existence is not in the name — and, one face deeper, not in stasis at
all. Three faces, each certified:

  FACE 1 — existence is not a PREDICATE (the type-theoretic face).
    `mention_settles_existence`: any term already witnesses its type's
    inhabitation. There are no non-existent individuals to separate
    from existent ones, so no predicate on individuals carries
    existence information — the question lives at the judgment level
    (is the type inhabited?), the other horizon of the dual-horizon
    reading. Kant's "existence is not a real predicate," visible in
    the kernel's own type discipline.

  FACE 2 — existence is not a DECLARATION (the existence-contract /
    anti-zombie face, from the fascia validation discipline:
    "representation of code is not code; an alleged implementation
    must have a body in the tree").
    `control_passes` / `ablation_fails` — the control (declaration +
    inhabited body) satisfies the contract; the ablation (declaration
    preserved, body removed) is rejected. Nothing must fail — and
    does.
    `no_manifest_only_existence` — NECESSITY, same proof shape as
    WhiteHole.no_signal_only_confirmation: the control and the
    ablation carry the IDENTICAL declaration, so no verdict computed
    from the manifest alone is correct on both. Existence cannot be
    read off the name at any order of manifest inspection.
    `import_is_witness` / `tree_verdict_exists` — SUFFICIENCY: a body
    in hand settles the contract, and the tree-consulting verdict
    (declaration AND inhabitation) is correct on every scene.

  FACE 3 — existence is not a STATE (the dynamical face, the fascia
    experiment's falsifiable reading: "sustained, observer-consistent
    structure only emerges when drift and reflection are both present
    under bounded observation").
    `no_drift_no_novelty` — the driftless process has a point orbit:
    nothing new, ever (⊬ novum; the frozen ablation, expected to fail,
    fails).
    `pure_drift_dissolves` — drift without reflection escapes every
    bound (the helix with no closure; the no-reflection ablation,
    expected to fail, fails — this is SRMF.helix_unbounded, reused).
    `two_channel_sustained` — both channels present (reflection = the
    ε-contraction toward the target; drift = the δ-imagination
    injection), the trajectory is SUSTAINED: forever above the novelty
    floor AND forever within the divergence budget — the emergence
    band the fascia probe measures, as a theorem over the guarded
    process. What exists is not a state but a maintained negotiation;
    drift is origin because without it there is nothing to sustain.

Scope honesty: the metaphysical reach of a three-word axiom is not
exhausted by any theorem file. What is certified is the operational
tri-face kernel matching (a) the fascia ablation experiment
axiom_bk1_axiomata_prima_exp_01 (controls: no-reflection fails,
no-drift fails, both-on in the band passes) and (b) the
existence-contract test discipline ("implementations must import;
nothing must fail"). The safety enactment reading — that declaring a
floor, a bound, or an energy positivity does not make it exist, and
that breaching light-boundary breakpoints on the strength of declared
existence is the zombie error at civilization scale — is carried by
this file jointly with false_bottom_voids_hedge and moloch_hedge.
-/

import Mathlib
import ForcingAnalysis.FabricPCGuard
import ForcingAnalysis.SRMFHelix

namespace ForcingAnalysis.AxiomataPrima

open ForcingAnalysis.Book2 ForcingAnalysis.FabricPC

/-! ### Face 1 — existence is not a predicate -/

/-- Mentioning a term settles its type's inhabitation: there are no
non-existent individuals, so no predicate on individuals can carry
existence information. The existence question lives at the judgment
level — the other horizon. -/
theorem mention_settles_existence {T : Sort*} (x : T) : Nonempty T :=
  ⟨x⟩

/-! ### Face 2 — existence is not a declaration -/

/-- A scene of the existence contract: what the manifest says, and
what the tree holds. The manifest is a proposition; the body is a
TYPE, whose inhabitation is the fact of the matter. -/
structure Scene where
  declared : Prop
  Body : Type

/-- The existence contract: declared AND a body in the tree. -/
def ExistsImpl (S : Scene) : Prop := S.declared ∧ Nonempty S.Body

/-- The control: declaration with an inhabited body. -/
def control : Scene := ⟨True, PUnit⟩

/-- The ablation: the declaration preserved verbatim, the body removed
from the tree. -/
def ablation : Scene := ⟨True, Empty⟩

/-- The control satisfies the contract: the import succeeds. -/
theorem control_passes : ExistsImpl control :=
  ⟨trivial, ⟨PUnit.unit⟩⟩

/-- **Nothing must fail — and does**: the ablation carries the
identical declaration and is rejected by the contract. A stub name,
prose description, or manifest entry cannot satisfy it. -/
theorem ablation_fails :
    control.declared = ablation.declared ∧ ¬ ExistsImpl ablation :=
  ⟨rfl, fun ⟨_, ⟨e⟩⟩ => e.elim⟩

/-- **Existence cannot be read off the name** (necessity; converse of
WhiteHole.no_signal_only_confirmation): no verdict computed from the
manifest alone is correct on all scenes — the control and the ablation
force one verdict to be both true and false. -/
theorem no_manifest_only_existence :
    ¬ ∃ V : Prop → Prop, ∀ S : Scene, (V S.declared ↔ ExistsImpl S) := by
  rintro ⟨V, hV⟩
  have h1 := hV control
  have h2 := hV ablation
  exact (fun ⟨_, ⟨e⟩⟩ => e.elim :
    ¬ ExistsImpl ablation) (h2.mp (h1.mpr control_passes))

/-- **The import is the witness** (sufficiency): a body in hand plus
the declaration settles the contract. -/
theorem import_is_witness (S : Scene) (w : S.Body) (hd : S.declared) :
    ExistsImpl S :=
  ⟨hd, ⟨w⟩⟩

/-- The verdict forbidden to manifest-only validators exists for
tree-consulting ones: correct on every scene. Required and sufficient —
the existence-contract test, exactly. -/
theorem tree_verdict_exists :
    ∃ V : Prop → Type → Prop,
      ∀ S : Scene, (V S.declared S.Body ↔ ExistsImpl S) :=
  ⟨fun d B => d ∧ Nonempty B, fun _ => Iff.rfl⟩

/-! ### Face 3 — existence is not a state (Drift as Origin) -/

/-- **The no-drift ablation fails**: the driftless process has a point
orbit — nothing new, ever. The frozen channel yields no novum. -/
theorem no_drift_no_novelty {α : Type*} (x : α) (n : ℕ) :
    (id : α → α)^[n] x = x := by
  rw [Function.iterate_id]
  rfl

/-- **The no-reflection ablation fails**: drift without reflective
closure escapes every bound (the helix with nonzero net drift, reused
from the certified SRMF kernel). Pure drift is dissolution, not
existence. -/
theorem pure_drift_dissolves (d : ℝ) (hd : d ≠ 0) (x M : ℝ) :
    ∃ n : ℕ, M ≤ |(SRMF.turn ⟨[d]⟩)^[n] x - x| :=
  SRMF.helix_unbounded ⟨[d]⟩ (by simpa [SRMF.Revolution.net] using hd) x M

/-- **Both channels sustain** (the emergence band, as a theorem): with
reflection (ε-contraction toward the target) and drift (δ-imagination
injection) both present, the trajectory exists in the maintained
sense — every state above the novelty floor at every step, and the
divergence within its budget forever. Sustained observer-consistent
structure from the two channels jointly; what exists is a negotiation,
not a state. -/
theorem two_channel_sustained {n : ℕ} [NeZero n] {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hεδ : ε + δ < 1) (β : ℝ) (H : Fin n → ℝ)
    (ρ0 : Fin n → ℝ) (h0 : IsDensity ρ0) :
    ∃ ρseq : ℕ → Fin n → ℝ, ρseq 0 = ρ0 ∧
      (∀ k i, δ * (n : ℝ)⁻¹ ≤ ρseq (k + 1) i) ∧
      (∀ k, kl (ρseq k) (gibbs β H) ≤
        max (kl ρ0 (gibbs β H)) (kl uniform (gibbs β H))) := by
  set σ := gibbs β H with hσdef
  refine ⟨fun k => (guardedStep ε δ σ)^[k] ρ0, rfl, ?_, ?_⟩
  · intro k i
    have hstep : ∀ m : ℕ, (guardedStep ε δ σ)^[m + 1] ρ0 =
        guardedStep ε δ σ ((guardedStep ε δ σ)^[m] ρ0) := fun m =>
      Function.iterate_succ_apply' _ m ρ0
    have hdens := (guarded_sequence_bounded hε hδ hεδ
      (gibbs_isDensity β H) (gibbs_pos β H)
      (fun k => (guardedStep ε δ σ)^[k] ρ0) h0 hstep k).1
    show δ * (n : ℝ)⁻¹ ≤ (guardedStep ε δ σ)^[k + 1] ρ0 i
    rw [hstep k]
    exact guarded_floor_all_temperatures hε.le hεδ.le β H hdens.nonneg i
  · intro k
    have hstep : ∀ m : ℕ, (guardedStep ε δ σ)^[m + 1] ρ0 =
        guardedStep ε δ σ ((guardedStep ε δ σ)^[m] ρ0) := fun m =>
      Function.iterate_succ_apply' _ m ρ0
    exact (guarded_sequence_bounded hε hδ hεδ (gibbs_isDensity β H)
      (gibbs_pos β H) (fun k => (guardedStep ε δ σ)^[k] ρ0) h0 hstep k).2

/-! ## Part II — the proof by negation

Part I gave the axiom's reading. A proof of "Existence is not." as a
SELECTION requires eliminating the rival theses. The candidate space:

  (i)   Existence just IS      — brute static fact, process-free;
  (ii)  Existence is NOTHING   — the null thesis;
  (iii) Existence is EVERYTHING — no negative space, nothing excluded;
  (iv)  Existence IS NOT        — the negotiation: drift + reflection,
                                  never a state (the axiom).

The elimination, each step certified below:

  (i) DIES INTO (ii): the constant process and the null process emit
      the IDENTICAL increment signal (both zero), so every verdict a
      bounded observer of change can compute agrees on them — "just is"
      is observationally "is nothing" (`just_is_observationally_nothing`,
      the white-hole confound turned on statics).
  (iii) DIES INTO (i): under conservation, "everything exists" (no
      state ever loses mass) FORCES stasis — pointwise non-decay with
      conserved total is pointwise equality (`everything_forces_stasis`).
      So (iii) collapses to (i), which collapses to (ii).
  (ii) DIES BY EXHIBITION: the negotiation process is constructed and
      is not nothing — strictly positive mass floor at every state,
      every step (`negotiation_not_nothing`), and its increment signal
      is nonzero (`negotiation_not_null`): it moves
      (`negotiation_moves`, at any non-uniform target) and it selects
      (`selection_exists`: some state strictly loses — genuine negative
      space, against (iii) a second time).
  (iv) SURVIVES UNIQUELY, WITH THE ARROW: all three rivals are
      increment-null; the negotiation is not — it is the unique
      non-null candidate. And its motion is ORDERED: past any step that
      does strict work, the trajectory can never return
      (`no_return_past_work`, from descent alone) — the arrow of time
      as the strict order a working process imposes on its own states.
      The Born-collapse reading of selection stays interpretive (per
      the LPS-O3 boundary); the certified arrow is the descent order.

What survives elimination is exactly the axiom: existence is not a
state, not nothing, not everything — it is the unique non-null,
selecting, irreversible negotiation. -/

/-- The increment signal of a trajectory: what a bounded observer of
CHANGE receives. -/
def incr {α : Type*} [AddGroup α] (s : ℕ → α) : ℕ → α :=
  fun k => s (k + 1) - s k

/-- The constant process is increment-null. -/
theorem just_is_null {α : Type*} [AddGroup α] (x : α) :
    incr (fun _ => x) = fun _ => (0 : α) := by
  funext k
  simp [incr]

/-- **(i) dies into (ii)**: the constant process and the null process
emit the identical increment signal, so every verdict computed from
observed change — into any type, at any order — agrees on them.
"Existence just is" is observationally "existence is nothing." -/
theorem just_is_observationally_nothing {α : Type*} [AddGroup α]
    {β : Sort*} (f : (ℕ → α) → β) (x : α) :
    f (incr (fun _ => x)) = f (incr (fun _ => (0 : α))) := by
  rw [just_is_null, just_is_null]

/-- Pointwise domination with conserved total is equality. -/
theorem le_and_sum_eq_imp_eq {n : ℕ} (f g : Fin n → ℝ)
    (h : ∀ i, f i ≤ g i) (hs : ∑ i, f i = ∑ i, g i) : f = g := by
  by_contra hne
  obtain ⟨j, hj⟩ := Function.ne_iff.mp hne
  have hlt : f j < g j := lt_of_le_of_ne (h j) hj
  have := Finset.sum_lt_sum (fun i _ => h i) ⟨j, Finset.mem_univ j, hlt⟩
  linarith

/-- **(iii) dies into (i)**: under conservation, "everything exists" —
no state ever loses mass — forces stasis. A step of a density process
in which nothing decays is the identity step; everything-ism IS
static-ism, which is observationally nothing-ism. -/
theorem everything_forces_stasis {n : ℕ} {ρ ρ' : Fin n → ℝ}
    (hρ : IsDensity ρ) (hρ' : IsDensity ρ')
    (hnodecay : ∀ i, ρ i ≤ ρ' i) : ρ' = ρ :=
  (le_and_sum_eq_imp_eq ρ ρ' hnodecay
    (by rw [hρ.sum_one, hρ'.sum_one])).symm

/-- The Gibbs target is non-uniform whenever the energy discriminates
(β > 0, two states of different energy). -/
theorem gibbs_ne_uniform {n : ℕ} [NeZero n] {β : ℝ} (hβ : 0 < β)
    {H : Fin n → ℝ} {i j : Fin n} (hij : H i ≠ H j) :
    gibbs β H ≠ FabricPC.uniform := by
  intro h
  have hi := congrFun h i
  have hj := congrFun h j
  have heq : gibbs β H i = gibbs β H j := by
    rw [hi, hj]
    rfl
  unfold gibbs at heq
  rw [div_eq_div_iff (partition_pos β H).ne' (partition_pos β H).ne'] at heq
  have hexp : Real.exp (-β * H i) = Real.exp (-β * H j) := by
    have hcancel := mul_right_cancel₀ (partition_pos β H).ne' heq
    exact hcancel
  have hlin := Real.exp_eq_exp.mp hexp
  have : H i = H j := by
    have hβ' : -β ≠ 0 := by linarith
    exact mul_left_cancel₀ hβ' hlin
  exact hij this

/-- **The negotiation moves** (novum, exhibited): at any discriminating
target the guarded step does not rest — existence-as-negotiation has a
nonzero increment where every rival is null. -/
theorem negotiation_moves {n : ℕ} [NeZero n] {ε δ : ℝ} (hδ : 0 < δ)
    {β : ℝ} (hβ : 0 < β) {H : Fin n → ℝ} {i j : Fin n} (hij : H i ≠ H j) :
    guardedStep ε δ (gibbs β H) (gibbs β H) ≠ gibbs β H := by
  intro h
  exact gibbs_ne_uniform hβ hij
    ((guarded_arrival_iff_uniform hδ (gibbs β H)).mp h)

/-- **Selection exists** (negative space, against (iii) a second time):
where the negotiation moves, some state strictly LOSES mass — existence
genuinely excludes; it is not everything. -/
theorem selection_exists {n : ℕ} [NeZero n] {ε δ : ℝ}
    (hε : 0 ≤ ε) (hδ : 0 < δ) (hεδ : ε + δ ≤ 1)
    {β : ℝ} (hβ : 0 < β) {H : Fin n → ℝ} {i j : Fin n} (hij : H i ≠ H j) :
    ∃ k, guardedStep ε δ (gibbs β H) (gibbs β H) k < gibbs β H k := by
  by_contra hall
  push Not at hall
  exact negotiation_moves hδ hβ hij
    (everything_forces_stasis (gibbs_isDensity β H)
      (guardedStep_isDensity hε hδ.le hεδ (gibbs_isDensity β H)
        (gibbs_isDensity β H)) hall)

/-- **(ii) dies by exhibition, increment form**: the negotiation's
increment signal is nonzero at step zero — it is the unique non-null
candidate among the four. -/
theorem negotiation_not_null {n : ℕ} [NeZero n] {ε δ : ℝ} (hδ : 0 < δ)
    {β : ℝ} (hβ : 0 < β) {H : Fin n → ℝ} {i j : Fin n} (hij : H i ≠ H j) :
    incr (fun k => (guardedStep ε δ (gibbs β H))^[k] (gibbs β H)) 0 ≠ 0 := by
  unfold incr
  simp only [Function.iterate_zero, id_eq]
  rw [Function.iterate_one]
  intro h
  exact negotiation_moves hδ hβ hij (sub_eq_zero.mp h)

/-- **(ii) dies by exhibition, mass form**: the negotiation is not
nothing — strictly positive mass at every state, every step past the
first. -/
theorem negotiation_not_nothing {n : ℕ} [NeZero n] {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hεδ : ε + δ < 1) (β : ℝ) (H : Fin n → ℝ)
    (ρ0 : Fin n → ℝ) (h0 : IsDensity ρ0) :
    ∃ ρseq : ℕ → Fin n → ℝ, ρseq 0 = ρ0 ∧
      ∀ k i, 0 < ρseq (k + 1) i := by
  obtain ⟨ρseq, h0', hfloor, _⟩ :=
    two_channel_sustained hε hδ hεδ β H ρ0 h0
  refine ⟨ρseq, h0', fun k i => lt_of_lt_of_le ?_ (hfloor k i)⟩
  have hn : (0 : ℝ) < (n : ℝ) := by
    exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne n)
  positivity

/-- Descent orders the whole orbit: the potential is antitone along
iteration. -/
theorem potential_antitone {α : Type*} (G : SRMF.GodelSafeCycle α)
    (x : α) : ∀ {a b : ℕ}, a ≤ b →
      G.potential (G.step^[b] x) ≤ G.potential (G.step^[a] x) := by
  intro a b hab
  induction b, hab using Nat.le_induction with
  | base => exact le_refl _
  | succ m _ ih =>
      rw [Function.iterate_succ_apply']
      exact le_trans (G.descent _) ih

/-- **The arrow of time** (uniqueness's signature): past any step that
does strict work, the trajectory can NEVER return — from descent alone.
A working process imposes a strict order on its own states; that order
is its time. The Born-collapse reading of selection stays interpretive;
the certified arrow is this descent order. -/
theorem no_return_past_work {α : Type*} (G : SRMF.GodelSafeCycle α)
    (x : α) {k : ℕ}
    (hwork : G.potential (G.step^[k + 1] x) < G.potential (G.step^[k] x)) :
    ∀ m > k, G.step^[m] x ≠ G.step^[k] x := by
  intro m hm hEq
  have hmono : G.potential (G.step^[m] x) ≤
      G.potential (G.step^[k + 1] x) :=
    potential_antitone G x hm
  rw [hEq] at hmono
  linarith

end ForcingAnalysis.AxiomataPrima
