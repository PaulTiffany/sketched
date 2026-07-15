/-
Book5MAP.lean — Mutually Assured Progress: the conditional
convergence/game/threshold kernel of Book 5's covenant theory.

Scope, stated honestly: this file machine-checks the parts of the MAP
cluster that are theorems about real sequences, two-player games, and
threshold arithmetic. The membrane semantics (metabolic exchange,
drift-regulated reflection, symbolic temperature as physical claim)
remains modeling/interpretive material and is NOT certified here.

Sources (Principia atlas, transcribed 2026-07-11; bindings in
verification/bindings.json):

  definition:bk5_symbolic_covenant — the covenant tuple
    {T_AB, T_BA, R_A, R_B, Ω} with Ω ∈ ℝ sign-carrying
    (`SymbolicCovenant`), and its MAD dual with inverted reflection
    polarity and negated stability (`SymbolicCovenant.dual`). The dual
    is an involution; coupling STRENGTH is blind to it while stability
    flips sign (`dual_couplingStrength`, `dual_stability`) — which is
    exactly why the dichotomy is sign-sensitive, not strength-sensitive.
  definition:bk5_mutually_assured_progress — MAP as a positive-limit
    condition on the joint surplus sequence (`MAP`).
  theorem:bk5_map_equilibrium — the convergence kernel: a positive
    limit forces eventual indefinite viability, jointly for both
    membranes (`map_eventually_viable`, `map_joint_eventually_viable`).
    The threshold hypothesis (κ_crit) enters through the contraction
    instance below, not as a global assumption.
  axiom:bk5_reflective_equilibrium_stability_flux — in the scalar
    relaxation model, a contractive coupled ratio |r| < 1 with positive
    carrying level yields MAP (`contraction_map`): the axiom's
    "bounded spectral radius ⇒ stable viability", instantiated.
  proposition:bk5_map_mad_dichotomy — in the linear exchange model the
    sign of Ω decides eventual viability vs eventual collapse, and the
    MAD trajectory IS the polarity reflection of the MAP one
    (`covenant_map_viable`, `covenant_mad_collapse`,
    `dual_surplus_reflect`); the two verdicts are exclusive
    (`viable_collapsed_exclusive`).
  definition:bk5_map_nash_point — no-unilateral-improvement
    configuration (`IsMAPNash`). The assurance-game witness: mutual
    reflection AND the defection trap are BOTH Nash points, with
    cooperation strictly payoff-dominant (`cooperation_nash`,
    `defection_nash`, `cooperation_dominates`) — MAP is an equilibrium
    one must choose, not an inevitability.
  theorem:bk5_map_mad_critical_temperature — the threshold conversion:
    the spectral criterion ρ < T_s·η_min/‖d‖_max holds iff the symbolic
    temperature exceeds the explicit critical value ρ·‖d‖_max/η_min
    (`spectral_iff_thermal`), and the feasibility region is monotone in
    T_s (`lambdaCrit_mono`). The phase-transition/fixed-point reading
    is not certified.
-/

import Mathlib
import ForcingAnalysis.Book5

namespace ForcingAnalysis.Book5

noncomputable section

open Filter Topology

/-! ### The covenant and its MAD dual -/

/-- The symbolic covenant tuple (definition:bk5_symbolic_covenant):
transfer operators as bare maps, reflection strategies and stability as
sign-carrying reals. -/
structure SymbolicCovenant (A B : Type*) where
  transferAB : A → B
  transferBA : B → A
  reflectA : ℝ
  reflectB : ℝ
  /-- Ω_AB: net stabilizing (> 0) or destabilizing (< 0) effect. -/
  stability : ℝ

variable {A B : Type*}

/-- Scalar coupling strength: |R_A ⊗ R_B| in the rank-one scalar case. -/
def couplingStrength (c : SymbolicCovenant A B) : ℝ :=
  |c.reflectA| * |c.reflectB|

/-- The MAD dual (proposition:bk5_map_mad_dichotomy): inverted
reflection polarity, negated stability, same transfer channels. -/
def SymbolicCovenant.dual (c : SymbolicCovenant A B) : SymbolicCovenant A B :=
  { c with reflectA := -c.reflectA, reflectB := -c.reflectB,
           stability := -c.stability }

theorem dual_dual (c : SymbolicCovenant A B) : c.dual.dual = c := by
  simp [SymbolicCovenant.dual]

/-- Coupling strength is blind to polarity inversion… -/
theorem dual_couplingStrength (c : SymbolicCovenant A B) :
    couplingStrength c.dual = couplingStrength c := by
  simp [couplingStrength, SymbolicCovenant.dual]

/-- …while stability flips sign: the dichotomy is sign-sensitive, not
strength-sensitive. -/
theorem dual_stability (c : SymbolicCovenant A B) :
    c.dual.stability = -c.stability := rfl

/-! ### MAP as a limit condition, and the equilibrium kernel -/

/-- definition:bk5_mutually_assured_progress — the joint surplus
sequence converges to a strictly positive limit. -/
def MAP (F : ℕ → ℝ) : Prop :=
  ∃ L, 0 < L ∧ Tendsto F atTop (nhds L)

/-- Eventual viability: from some interaction step on, the surplus is
positive (the conclusion shape of theorem:bk5_map_equilibrium). -/
def EventuallyViable (F : ℕ → ℝ) : Prop :=
  ∃ n₀, ∀ n > n₀, 0 < F n

/-- Eventual collapse: from some step on, the surplus is negative. -/
def EventuallyCollapsed (F : ℕ → ℝ) : Prop :=
  ∃ n₀, ∀ n > n₀, F n < 0

/-- **MAP Equilibrium, convergence kernel**
(theorem:bk5_map_equilibrium): a positive limit forces eventual
indefinite viability. -/
theorem map_eventually_viable {F : ℕ → ℝ} (h : MAP F) :
    EventuallyViable F := by
  obtain ⟨L, hL, hT⟩ := h
  have hev : ∀ᶠ n in atTop, 0 < F n := hT.eventually (eventually_gt_nhds hL)
  obtain ⟨n₀, hn₀⟩ := eventually_atTop.mp hev
  exact ⟨n₀, fun n hn => hn₀ n hn.le⟩

/-- Both membranes together: joint MAP gives one shared horizon n₀ past
which BOTH surpluses stay positive. -/
theorem map_joint_eventually_viable {FA FB : ℕ → ℝ}
    (hA : MAP FA) (hB : MAP FB) :
    ∃ n₀, ∀ n > n₀, 0 < FA n ∧ 0 < FB n := by
  obtain ⟨a, ha⟩ := map_eventually_viable hA
  obtain ⟨b, hb⟩ := map_eventually_viable hB
  exact ⟨max a b, fun n hn =>
    ⟨ha n (lt_of_le_of_lt (le_max_left a b) hn),
     hb n (lt_of_le_of_lt (le_max_right a b) hn)⟩⟩

/-- Viability and collapse verdicts are exclusive. -/
theorem viable_collapsed_exclusive {F : ℕ → ℝ}
    (h : EventuallyViable F) : ¬ EventuallyCollapsed F := by
  rintro ⟨m, hm⟩
  obtain ⟨n₀, hn₀⟩ := h
  have h₁ := hn₀ (max n₀ m + 1) (by omega)
  have h₂ := hm (max n₀ m + 1) (by omega)
  linarith

/-! ### The contraction instance (Reflective Equilibrium Stability) -/

/-- Scalar relaxation model: the surplus relaxes toward carrying level L
with coupled ratio r (the scalar stand-in for ρ(𝓒_AB)). -/
def relaxedSurplus (L F0 r : ℝ) (n : ℕ) : ℝ := L + (F0 - L) * r ^ n

/-- **Bounded spectral radius ⇒ MAP**
(axiom:bk5_reflective_equilibrium_stability_flux, scalar instance): a
contractive coupled ratio and a positive carrying level give MAP,
whatever the starting surplus. -/
theorem contraction_map {L r : ℝ} (F0 : ℝ) (hL : 0 < L) (hr : |r| < 1) :
    MAP (relaxedSurplus L F0 r) := by
  refine ⟨L, hL, ?_⟩
  unfold relaxedSurplus
  have hpow : Tendsto (fun n : ℕ => r ^ n) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr
  simpa using tendsto_const_nhds.add (tendsto_const_nhds.mul hpow)

/-! ### The MAP-MAD dichotomy in the linear exchange model -/

/-- Linear exchange model: each interaction step adds Ω·g to the
surplus, g > 0 the (polarity-blind) coupling gain. -/
def covenantSurplus (c : SymbolicCovenant A B) (F0 g : ℝ) (n : ℕ) : ℝ :=
  F0 + n * (c.stability * g)

/-- The MAD trajectory is the exact polarity reflection of the MAP one:
running the dual covenant from the reflected start reproduces the
original surplus with all signs inverted. -/
theorem dual_surplus_reflect (c : SymbolicCovenant A B) (F0 g : ℝ) (n : ℕ) :
    covenantSurplus c.dual F0 g n = -(covenantSurplus c (-F0) g n) := by
  simp [covenantSurplus, SymbolicCovenant.dual]
  ring

/-- **MAP half of the dichotomy** (proposition:bk5_map_mad_dichotomy):
positive stability makes the linear surplus eventually viable from any
start. -/
theorem covenant_map_viable (c : SymbolicCovenant A B) {g : ℝ} (F0 : ℝ)
    (hΩ : 0 < c.stability) (hg : 0 < g) :
    EventuallyViable (covenantSurplus c F0 g) := by
  have hpos : 0 < c.stability * g := mul_pos hΩ hg
  obtain ⟨n₀, hn₀⟩ := exists_nat_gt (max 0 (-F0) / (c.stability * g))
  refine ⟨n₀, fun n hn => ?_⟩
  have hcast : (n₀ : ℝ) < (n : ℝ) := Nat.cast_lt.mpr hn
  have h₁ : max 0 (-F0) < (n₀ : ℝ) * (c.stability * g) :=
    (div_lt_iff₀ hpos).mp hn₀
  have h₂ : (n₀ : ℝ) * (c.stability * g) < n * (c.stability * g) := by
    exact mul_lt_mul_of_pos_right hcast hpos
  have h₃ : -F0 ≤ max 0 (-F0) := le_max_right _ _
  unfold covenantSurplus
  linarith

/-- **MAD half of the dichotomy**: negative stability collapses the
linear surplus from any start — proved by reflecting the MAP half
through the dual, not by a second argument. -/
theorem covenant_mad_collapse (c : SymbolicCovenant A B) {g : ℝ} (F0 : ℝ)
    (hΩ : c.stability < 0) (hg : 0 < g) :
    EventuallyCollapsed (covenantSurplus c F0 g) := by
  have hdual : 0 < c.dual.stability := by
    simpa [dual_stability] using neg_pos.mpr hΩ
  obtain ⟨n₀, hn₀⟩ := covenant_map_viable c.dual (-F0) hdual hg
  refine ⟨n₀, fun n hn => ?_⟩
  have h := hn₀ n hn
  have hrefl := dual_surplus_reflect c (-F0) g n
  simp only [neg_neg] at hrefl
  -- 0 < dual surplus = -(original surplus)
  rw [hrefl] at h
  linarith

/-! ### The MAP Nash point and the assurance game -/

/-- definition:bk5_map_nash_point — neither membrane can unilaterally
improve its payoff by changing reflection strategy. -/
def IsMAPNash {SA SB : Type*} (payA payB : SA → SB → ℝ)
    (a : SA) (b : SB) : Prop :=
  (∀ a', payA a' b ≤ payA a b) ∧ (∀ b', payB a b' ≤ payB a b)

/-- The assurance game on Boolean reflection strategies: matched
cooperation pays 1, the matched trap pays 0, mismatch pays −1. -/
def assurancePay (a b : Bool) : ℝ :=
  if a = b then (if a then 1 else 0) else -1

/-- Mutual reflection is a MAP Nash point… -/
theorem cooperation_nash :
    IsMAPNash assurancePay (fun a b => assurancePay b a) true true := by
  constructor
  · intro a'; cases a' <;> norm_num [assurancePay]
  · intro b'; cases b' <;> norm_num [assurancePay]

/-- …but so is the defection trap: no unilateral step leaves it. -/
theorem defection_nash :
    IsMAPNash assurancePay (fun a b => assurancePay b a) false false := by
  constructor
  · intro a'; cases a' <;> norm_num [assurancePay]
  · intro b'; cases b' <;> norm_num [assurancePay]

/-- Cooperation strictly payoff-dominates the trap: MAP is an
equilibrium one must CHOOSE — the game alone does not force it. -/
theorem cooperation_dominates :
    assurancePay false false < assurancePay true true := by
  norm_num [assurancePay]

/-! ### The critical temperature conversion -/

/-- λ_crit of axiom:bk5_reflective_equilibrium_stability_flux:
T_s · min{η_A, η_B} / max{‖d_A‖, ‖d_B‖}. -/
def lambdaCrit (Ts etaMin dMax : ℝ) : ℝ := Ts * etaMin / dMax

/-- The explicit thermal threshold of
theorem:bk5_map_mad_critical_temperature, solved for T_s:
T_s^crit = ρ · max‖d‖ / min η. -/
def criticalTemp (rho etaMin dMax : ℝ) : ℝ := rho * dMax / etaMin

/-- **The spectral criterion IS a thermal threshold**
(theorem:bk5_map_mad_critical_temperature, conversion kernel): for
positive coherence density and drift norm, ρ < λ_crit(T_s) holds
exactly when T_s exceeds the explicit critical temperature. -/
theorem spectral_iff_thermal {rho Ts etaMin dMax : ℝ}
    (heta : 0 < etaMin) (hd : 0 < dMax) :
    rho < lambdaCrit Ts etaMin dMax ↔ criticalTemp rho etaMin dMax < Ts := by
  unfold lambdaCrit criticalTemp
  rw [lt_div_iff₀ hd, div_lt_iff₀ heta]

/-- Feasibility is monotone in symbolic temperature: warming never
shrinks the stable region (for positive densities/drifts). -/
theorem lambdaCrit_mono {Ts₁ Ts₂ etaMin dMax : ℝ}
    (heta : 0 < etaMin) (hd : 0 < dMax) (h : Ts₁ ≤ Ts₂) :
    lambdaCrit Ts₁ etaMin dMax ≤ lambdaCrit Ts₂ etaMin dMax := by
  unfold lambdaCrit
  gcongr

end

end ForcingAnalysis.Book5
