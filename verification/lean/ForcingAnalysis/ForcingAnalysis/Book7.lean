/-
Book7.lean - symbolic power/uncertainty, controlled refinement, reflective
stabilization, and the Hilbert-Banach bridge, honest kernel.

Principia Book 7 states most of its content on the space of symbolic state
densities prob(M) over a symbolic manifold M, with Wasserstein-2 metrics,
free-energy functionals defined by integrals, general Banach fixed-point
theorems, and finally a quantum-foundational Gleason/Born-rule collapse.
The infinite-dimensional Wasserstein and quantum apparatus is not modeled here;
the complete-metric contraction specialization is modeled through Book 4. For each anchor this module extracts the honest finite/real
kernel instead:

  * "Systemic Symbolic Power" / "Symbolic Uncertainty" are defined by
    manifold integrals and a Wasserstein/KL divergence -- not modeled. Their
    stated involutive duality (recursion operator R_n(id) != id but
    R_2n(id) = id, and Sigma_P/Sigma_U forming an involutive pair) is
    extracted as the honest algebra of an involutive map: applying it twice
    returns the input, an explicit non-fixed-point witness (the swap on
    `Bool`) shows a single application need not, and an involution can be
    inverted by itself;
  * the controlled symbolic refinement recurrence and its deadband
    stabilization theorem are the strongest honest content of the book: the
    residual recurrence e_(n+1) = e_n + w_(n+1) - k * dz_tau(e_n) is
    formalized exactly as stated (with the deadzone function dz_tau spelled
    out algebraically), and four consequences are proved directly from it --
    contraction toward the band while outside it, invariance of the
    "ultimate bound" region tau + W/k once entered, strict decrease of the
    residual (hence ascent of the confidence S_n = exp(-lambda|e_n|)) while
    outside that region, and a geometric decay bound in the undisturbed
    (W = 0) case, which is the discrete substitute for the source's
    log-formula finite hitting time. The self-correction criterion's
    positive half (bounded gain, bounded disturbance controls the ultimate
    bound) and its stated failure half (as gain vanishes or disturbance
    diverges, the bound is unbounded) are both proved, the failure half as
    explicit unbounded-family countermodels rather than a limit claim;
  * "Convergence Potential" (free energy bounded below) and "Caristi Descent
    of Reflection" (each reflective step pays for its displacement) are kept
    as fields of one structure, `CaristiDescent`, rather than as axioms; the
    summable-increments / bounded-total-displacement conclusion of the
    Reflective Convergence theorem is proved from those fields by
    telescoping, exactly as Book 8 did for metabolic sufficiency. The
    geometric-rate corollary is proved as a direct induction. The claim that
    the orbit-limit operator is idempotent is derived, not posited, from the
    two hypotheses actually used to state it (its image lands in Fix(reflect)
    and it agrees with the identity there) -- the honest reconstruction of
    "idempotence is a consequence of free-energy descent, not an independent
    posit." The full Wasserstein-Cauchy convergence to an actual limit point,
    and the closed-graph / fixed-point half of the theorem, require
    Wasserstein-space construction on prob(M) is not attempted, but Book 4's
    complete-metric contraction now canonically constructs this orbit-limit
    structure and proves convergence to its selected value;
  * the Two-Way Street theorems (mutual modeling operators forming a
    contraction on a product space) are given their genuine finite content:
    if the two cross maps are Lipschitz with constants kappa_A, kappa_B, the
    induced product map is Lipschitz with constant max(kappa_A, kappa_B) on
    the sup-product pseudometric, and a one-step contraction-to-a-known-
    fixed-point bound is proved for a general Lipschitz map with a posited
    fixed point. Book 4 now supplies the general complete-metric Banach
    fixed-point interface; this local product-pseudometric result remains the
    finite estimate that would feed a metric specialization;
  * the frame-temperature/exponent correspondence's uniqueness clause
    reduces honestly to injectivity of a strictly antitone real function; the
    Hilbert-Banach Bridge's Banach-versus-Hilbert regime comparison is given
    its genuine two-coordinate instance (the L^1 and L^2 norms on R^2 bound
    each other within a factor of sqrt 2); and the coarse-grained convexity
    lemma is given its honest p = 2 (Hilbert) cross-section as strict
    midpoint convexity of x |-> x^2. The general L^p interpolation
    inequality, the existence of the emergent exponent p(epsilon, B, S), and
    everything downstream of it in the quantum/Gleason cluster (contextuality
    defect, non-contextuality, the Born rule) are not attempted.

Anchors that are purely narrative or taxonomic (the observer-resonance/
decency-potential/symbolic-horizon cluster, meta-reflective drift and
symbolic time, the two-way flow operator, the SRV/SRMF-constrained-observer
definitions), that depend on an unstated referenced hypothesis (the "channel
floors" assumption behind the PISU uncertainty-principle theorem is
referenced but its text is not in this packet), that require actual
manifold/measure-theoretic integrals or Wasserstein geometry (Sigma_P,
Sigma_U, the free-energy functional's own definition, the reflective
integration limit lemma), that require additional genuine topology beyond the complete-metric contraction
case (the reciprocity domain's structural properties,
the time-varying/adiabatic tracking corollaries), or that require Hilbert
space / Gleason's-theorem quantum foundations (contextuality defect,
non-contextuality, Born collapse) are left unformalized and listed as open
anchors in the accompanying proposal, rather than forced into decorative
theorems.
-/

import Mathlib
import ForcingAnalysis.ScholiumA
import ForcingAnalysis.ScholiumDynamics
import ForcingAnalysis.Book4A

namespace ForcingAnalysis.Book7

noncomputable section

/- ================================================================
   lemma:bk7_involutive_dual_symmetry, proposition:bk7_power_uncertainty_duality
   ================================================================ -/

/-- The duality is invertible by itself: if `U` is obtained from `P` by an
involutive map `f` (proposition:bk7_power_uncertainty_duality's stated
correlation, realized algebraically), applying `f` again recovers `P`. -/
theorem dualityRecovers {X : Type} (f : X → X) (hf : Function.Involutive f)
    (P U : X) (hU : U = f P) : f U = P := by
  rw [hU]
  exact hf P

/-- lemma:bk7_involutive_dual_symmetry's headline equation
`R_2n(id) = id` but `R_n(id) != id`, witnessed on `Bool`: the swap map is
involutive (double application is the identity) while a single application
moves every point away from itself. This shows the "only under complete
recursive cycles" clause is non-vacuous rather than empty. -/
theorem involutive_pair_witness (b : Bool) :
    (fun x : Bool => !x) b ≠ b ∧ (fun x : Bool => !x) ((fun x : Bool => !x) b) = b := by
  cases b <;> decide

/- ================================================================
   definition:bk7_adaptive_refinement_recurrence,
   theorem:bk7_adaptive_refinement_deadband_stabilization,
   corollary:bk7_self_correction_criterion
   ================================================================ -/

/-- The deadzone function of definition:bk7_adaptive_refinement_recurrence,
`dz_tau(e) := sign(e) * max(|e| - tau, 0)`, spelled out without a `sign`
function: this expression agrees with the stated formula on every sign of
`e` (checked by `dz_zero_of_le` and the two branches of
`dz_contraction_bound`). -/
def dz (tau e : ℝ) : ℝ := max (e - tau) 0 - max (-e - tau) 0

/-- Inside the resolution deadband the controller is inactive:
`dz_tau(e) = 0` whenever `|e| <= tau`. -/
theorem dz_zero_of_le (tau e : ℝ) (h : |e| ≤ tau) : dz tau e = 0 := by
  obtain ⟨h1, h2⟩ := abs_le.mp h
  have hmax1 : max (e - tau) 0 = 0 := max_eq_right (by linarith)
  have hmax2 : max (-e - tau) 0 = 0 := max_eq_right (by linarith)
  unfold dz
  rw [hmax1, hmax2]
  ring

/-- The scalar contraction inequality underlying part (i) of
theorem:bk7_adaptive_refinement_deadband_stabilization, proved directly from
the deadzone controller step `e' = e + w - k * dz_tau(e)`, for a residual
`e` currently outside the deadband. -/
theorem dz_contraction_bound (tau k W e w : ℝ) (htau : 0 ≤ tau) (hk0 : 0 < k)
    (hk1 : k ≤ 1) (hw : |w| ≤ W) (hout : tau < |e|) :
    |e + w - k * dz tau e| ≤ (1 - k) * |e| + k * tau + W := by
  rcases lt_or_ge 0 e with he | he
  · have habs : |e| = e := abs_of_nonneg he.le
    have hout' : tau < e := by rwa [habs] at hout
    have hmax1 : max (e - tau) 0 = e - tau := max_eq_left (by linarith)
    have hmax2 : max (-e - tau) 0 = 0 := max_eq_right (by linarith)
    have hdz : dz tau e = e - tau := by unfold dz; rw [hmax1, hmax2]; ring
    rw [hdz, habs]
    have heq : e + w - k * (e - tau) = (1 - k) * e + k * tau + w := by ring
    rw [heq]
    have hnn : 0 ≤ (1 - k) * e + k * tau := by nlinarith
    calc |(1 - k) * e + k * tau + w| ≤ |(1 - k) * e + k * tau| + |w| := abs_add_le _ _
      _ = (1 - k) * e + k * tau + |w| := by rw [abs_of_nonneg hnn]
      _ ≤ (1 - k) * e + k * tau + W := by linarith
  · have habs : |e| = -e := abs_of_nonpos he
    have hout' : tau < -e := by rwa [habs] at hout
    have hmax1 : max (e - tau) 0 = 0 := max_eq_right (by linarith)
    have hmax2 : max (-e - tau) 0 = -e - tau := max_eq_left (by linarith)
    have hdz : dz tau e = e + tau := by unfold dz; rw [hmax1, hmax2]; ring
    rw [hdz, habs]
    have heq : e + w - k * (e + tau) = (1 - k) * e - k * tau + w := by ring
    rw [heq]
    have hnp : (1 - k) * e - k * tau ≤ 0 := by nlinarith
    calc |(1 - k) * e - k * tau + w| ≤ |(1 - k) * e - k * tau| + |w| := abs_add_le _ _
      _ = -((1 - k) * e - k * tau) + |w| := by rw [abs_of_nonpos hnp]
      _ = (1 - k) * (-e) + k * tau + |w| := by ring
      _ ≤ (1 - k) * (-e) + k * tau + W := by linarith

/-- The controlled symbolic refinement recurrence of
definition:bk7_adaptive_refinement_recurrence, packaged as a structure: the
residual sequence `e`, the disturbance sequence `w` driving the
baseline-balanced net input, the constant gain `k`, deadband `tau`, and
disturbance bound `W`, together with the exact per-step law
`e_(n+1) = e_n + w_(n+1) - k * dz_tau(e_n)`. -/
structure DeadbandController where
  tau : ℝ
  tau_nonneg : 0 ≤ tau
  k : ℝ
  k_pos : 0 < k
  k_le_one : k ≤ 1
  W : ℝ
  W_nonneg : 0 ≤ W
  e : Nat → ℝ
  w : Nat → ℝ
  w_bound : ∀ n, |w (n + 1)| ≤ W
  recurrence : ∀ n, e (n + 1) = e n + w (n + 1) - k * dz tau (e n)

/-- The ultimate bound `tau + W/k` of part (ii) of
theorem:bk7_adaptive_refinement_deadband_stabilization. -/
def DeadbandController.ultimateBound (d : DeadbandController) : ℝ :=
  d.tau + d.W / d.k

/-- Part (i), Contraction toward the band: whenever the residual is outside
the deadband, one controller step obeys the stated contraction bound. -/
theorem deadband_contraction (d : DeadbandController) (n : Nat)
    (hout : d.tau < |d.e n|) :
    |d.e (n + 1)| ≤ (1 - d.k) * |d.e n| + d.k * d.tau + d.W := by
  rw [d.recurrence n]
  exact dz_contraction_bound d.tau d.k d.W (d.e n) (d.w (n + 1)) d.tau_nonneg
    d.k_pos d.k_le_one (d.w_bound n) hout

/-- Part (ii), Ultimate bound, in invariant form: once the residual is
within `tau + W/k` of the deadband it stays there. This is the discrete
"stays inside once entered" content behind the source's `limsup` claim. -/
theorem deadband_region_invariant (d : DeadbandController) (n : Nat)
    (hin : |d.e n| ≤ d.ultimateBound) : |d.e (n + 1)| ≤ d.ultimateBound := by
  have hk_ne : d.k ≠ 0 := d.k_pos.ne'
  have hin' : d.k * |d.e n| ≤ d.k * d.tau + d.W := by
    have h2 : |d.e n| - d.tau ≤ d.W / d.k := by
      have := d.ultimateBound
      unfold DeadbandController.ultimateBound at hin
      linarith
    have h3 : (|d.e n| - d.tau) * d.k ≤ d.W := (le_div_iff₀ d.k_pos).mp h2
    nlinarith [h3]
  have hgoal : d.k * |d.e (n + 1)| ≤ d.k * d.tau + d.W := by
    rcases lt_or_ge d.tau (|d.e n|) with houtcase | hincase
    · have hc := deadband_contraction d n houtcase
      have hstep : d.k * |d.e (n + 1)| ≤
          d.k * ((1 - d.k) * |d.e n| + d.k * d.tau + d.W) :=
        mul_le_mul_of_nonneg_left hc d.k_pos.le
      have hprod : (1 - d.k) * (d.k * |d.e n|) ≤ (1 - d.k) * (d.k * d.tau + d.W) :=
        mul_le_mul_of_nonneg_left hin' (by linarith [d.k_le_one])
      nlinarith [hstep, hprod]
    · have hdz0 : dz d.tau (d.e n) = 0 := dz_zero_of_le d.tau (d.e n) hincase
      have hrec := d.recurrence n
      rw [hdz0, mul_zero, sub_zero] at hrec
      rw [hrec]
      have habs : |d.e n + d.w (n + 1)| ≤ |d.e n| + |d.w (n + 1)| := abs_add_le _ _
      have hw := d.w_bound n
      have p1 : d.k * |d.e n + d.w (n + 1)| ≤ d.k * (|d.e n| + |d.w (n + 1)|) :=
        mul_le_mul_of_nonneg_left habs d.k_pos.le
      have p2 : d.k * |d.e n| ≤ d.k * d.tau :=
        mul_le_mul_of_nonneg_left hincase d.k_pos.le
      have p3 : d.k * |d.w (n + 1)| ≤ d.k * d.W :=
        mul_le_mul_of_nonneg_left hw d.k_pos.le
      have p4 : d.k * d.W ≤ d.W := by nlinarith [d.k_le_one, d.W_nonneg]
      nlinarith [p1, p2, p3, p4]
  have hstep2 : |d.e (n + 1)| - d.tau ≤ d.W / d.k := by
    rw [le_div_iff₀ d.k_pos]
    nlinarith [hgoal]
  unfold DeadbandController.ultimateBound
  linarith

/-- Part (iv) content, strict form: outside the ultimate-bound region a
controller step strictly shrinks the residual. -/
theorem deadband_strict_decrease (d : DeadbandController) (n : Nat)
    (hout : d.ultimateBound < |d.e n|) : |d.e (n + 1)| < |d.e n| := by
  have hWk_nonneg : 0 ≤ d.W / d.k := div_nonneg d.W_nonneg d.k_pos.le
  have htau_le : d.tau ≤ d.ultimateBound := by
    unfold DeadbandController.ultimateBound; linarith
  have htauout : d.tau < |d.e n| := lt_of_le_of_lt htau_le hout
  have hc := deadband_contraction d n htauout
  have h2 : d.tau + d.W / d.k < |d.e n| := by
    unfold DeadbandController.ultimateBound at hout; exact hout
  have h3 : (d.tau + d.W / d.k) * d.k < |d.e n| * d.k :=
    mul_lt_mul_of_pos_right h2 d.k_pos
  have hkne : d.k ≠ 0 := d.k_pos.ne'
  have h4 : (d.tau + d.W / d.k) * d.k = d.k * d.tau + d.W := by
    field_simp
  nlinarith [hc, h3, h4]

/-- Part (iv), Confidence ascent: the confidence `S_n = exp(-lambda |e_n|)`
strictly increases while the residual is outside the ultimate-bound
region. -/
theorem deadband_confidence_ascent (d : DeadbandController) (lam : ℝ)
    (hlam : 0 < lam) (n : Nat) (hout : d.ultimateBound < |d.e n|) :
    Real.exp (-(lam * |d.e n|)) < Real.exp (-(lam * |d.e (n + 1)|)) := by
  have hdec := deadband_strict_decrease d n hout
  have h := mul_lt_mul_of_pos_left hdec hlam
  exact Real.exp_lt_exp.mpr (by linarith)

/-- Part (iii), the discrete substitute for the log-formula finite hitting
time: in the undisturbed case `W = 0`, the gap `|e_n| - tau` decays
geometrically at rate `1 - k`. -/
theorem deadband_geometric_decay (d : DeadbandController) (hW0 : d.W = 0)
    (n : Nat) : |d.e n| - d.tau ≤ (1 - d.k) ^ n * (|d.e 0| - d.tau) := by
  induction n with
  | zero => simp
  | succ m ih =>
      have hstep : |d.e (m + 1)| - d.tau ≤ (1 - d.k) * (|d.e m| - d.tau) := by
        rcases lt_or_ge d.tau (|d.e m|) with houtcase | hincase
        · have hc := deadband_contraction d m houtcase
          rw [hW0] at hc
          nlinarith [hc]
        · have hdz0 : dz d.tau (d.e m) = 0 := dz_zero_of_le d.tau (d.e m) hincase
          have hrec := d.recurrence m
          rw [hdz0, mul_zero, sub_zero] at hrec
          have hwb := d.w_bound m
          rw [hW0] at hwb
          have hw0 : d.w (m + 1) = 0 := abs_eq_zero.mp (le_antisymm hwb (abs_nonneg _))
          rw [hw0, add_zero] at hrec
          rw [hrec]
          have hxle0 : |d.e m| - d.tau ≤ 0 := by linarith
          nlinarith [hxle0, d.k_pos.le]
      have hscale : (1 - d.k) * (|d.e m| - d.tau) ≤
          (1 - d.k) * ((1 - d.k) ^ m * (|d.e 0| - d.tau)) :=
        mul_le_mul_of_nonneg_left ih (by linarith [d.k_le_one])
      calc |d.e (m + 1)| - d.tau ≤ (1 - d.k) * (|d.e m| - d.tau) := hstep
        _ ≤ (1 - d.k) * ((1 - d.k) ^ m * (|d.e 0| - d.tau)) := hscale
        _ = (1 - d.k) ^ (m + 1) * (|d.e 0| - d.tau) := by ring

/-- corollary:bk7_self_correction_criterion, the positive half: as long as
the reflective gain stays bounded away from zero (`k >= kmin > 0`) and the
disturbance stays bounded (`W <= Wmax`), the ultimate bound is controlled
uniformly. -/
theorem selfCorrection_succeeds (tau k kmin W Wmax : ℝ)
    (hkmin : 0 < kmin) (hk : kmin ≤ k) (hW : W ≤ Wmax)
    (hWmax : 0 ≤ Wmax) : tau + W / k ≤ tau + Wmax / kmin := by
  have hk_pos : 0 < k := lt_of_lt_of_le hkmin hk
  have key : W / k ≤ Wmax / kmin := by
    rw [div_le_div_iff₀ hk_pos hkmin]
    exact mul_le_mul hW hk hkmin.le hWmax
  linarith

/-- corollary:bk7_self_correction_criterion, the failure half (i):
as the reflective gain is taken arbitrarily small, the ultimate bound is
unbounded -- an explicit countermodel to any uniform stabilization claim
once the disturbance `W` is genuinely present. -/
theorem selfCorrection_fails_as_gain_vanishes (tau W : ℝ) (htau : 0 ≤ tau)
    (hW : 0 < W) (n : Nat) :
    ∃ k : ℝ, 0 < k ∧ k ≤ 1 ∧ (n : ℝ) ≤ tau + W / k := by
  refine ⟨W / (n + 1 + W), by positivity, ?_, ?_⟩
  · rw [div_le_one (by linarith)]
    linarith
  · have hden : (0:ℝ) < n + 1 + W := by positivity
    have hk_ne : W / (n + 1 + W) ≠ 0 := by positivity
    have heq : W / (W / (n + 1 + W)) = n + 1 + W := by
      rw [div_div_eq_mul_div, div_eq_iff (by positivity)]
      ring
    rw [heq]
    linarith

/-- corollary:bk7_self_correction_criterion, the failure half (ii): as the
drift disturbance is taken arbitrarily large (at any fixed positive gain),
the ultimate bound is unbounded. -/
theorem selfCorrection_fails_as_disturbance_grows (tau k : ℝ) (htau : 0 ≤ tau)
    (hk : 0 < k) (M : ℝ) : ∃ W : ℝ, 0 ≤ W ∧ M < tau + W / k := by
  refine ⟨k * (|M| + 1), by positivity, ?_⟩
  have heq : k * (|M| + 1) / k = |M| + 1 := by field_simp
  rw [heq]
  have h1 : M ≤ |M| := le_abs_self M
  linarith

/- ================================================================
   axiom:bk7_convergence_potential, axiom:bk7_caristi_descent_for_reflection,
   theorem:bk7_reflective_convergence_to_stable_identity,
   corollary:bk7_observer_converges, corollary:bk7_geometric_convergence_rate
   ================================================================ -/

/-- The Caristi descent data of theorem:bk7_reflective_convergence_to_stable_
identity(i): a free-energy sequence bounded below
(axiom:bk7_convergence_potential) together with a nonnegative displacement
sequence for which every step pays for its own displacement in free energy
(axiom:bk7_caristi_descent_for_reflection), kept as structure fields rather
than axioms. corollary:bk7_observer_converges's content is exactly that the
canonical reflective operator instantiates these two fields; no further
hypothesis is needed once a `CaristiDescent` value is given. -/
structure CaristiDescent where
  freeEnergy : Nat → ℝ
  Fmin : ℝ
  bounded_below : ∀ n, Fmin ≤ freeEnergy n
  displacement : Nat → ℝ
  displacement_nonneg : ∀ n, 0 ≤ displacement n
  descent_pays : ∀ n, displacement n ≤ freeEnergy n - freeEnergy (n + 1)

/-- Telescoped displacement bound against the free-energy drop. -/
theorem caristiDescent_sum_le_energy_drop (c : CaristiDescent) (n : Nat) :
    ∑ i ∈ Finset.range n, c.displacement i ≤ c.freeEnergy 0 - c.freeEnergy n := by
  induction n with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ]
      have h := c.descent_pays m
      linarith

/-- theorem:bk7_reflective_convergence_to_stable_identity's summable-
increments conclusion, in its honest finite/discrete form: the total
displacement up to any step is bounded by the total free energy available
to spend, `freeEnergy 0 - Fmin`. This is the exact analogue of Book 8's
`metabolicSufficiency_decrease_accum` telescoping bound. Actual `W_2`-Cauchy
convergence to a limit point requires completeness of `(prob(M), W_2)`,
which is not modeled. -/
theorem caristiDescent_total_displacement_bound (c : CaristiDescent) (n : Nat) :
    ∑ i ∈ Finset.range n, c.displacement i ≤ c.freeEnergy 0 - c.Fmin := by
  have h1 := caristiDescent_sum_le_energy_drop c n
  have h2 := c.bounded_below n
  linarith

/-- corollary:bk7_geometric_convergence_rate: if the free-energy gap
contracts geometrically at rate `q` (the source's `q in (0,1)`; only
`0 <= q` is needed for this direction), then the gap after `n` steps is
bounded by `q^n` times the initial gap, proved directly by induction rather
than by invoking a general convergence-rate theorem. -/
theorem geometric_gap_decay (g : Nat → ℝ) (q : ℝ) (hq0 : 0 ≤ q)
    (hg : ∀ n, g (n + 1) ≤ q * g n) (n : Nat) : g n ≤ q ^ n * g 0 := by
  induction n with
  | zero => simp
  | succ m ih =>
      calc g (m + 1) ≤ q * g m := hg m
        _ ≤ q * (q ^ m * g 0) := mul_le_mul_of_nonneg_left ih hq0
        _ = q ^ (m + 1) * g 0 := by ring

/-- proposition:bk7_stabilization_as_orbit_limit: idempotence of the
orbit-limit operator `R`, derived (not posited) from the two hypotheses
actually used to state it: `R`'s image lands in `Fix(reflect)`, and `R`
agrees with the identity on `Fix(reflect)`. This is the honest
reconstruction of "idempotence is a consequence of free-energy descent, not
an independent posit." -/
structure OrbitLimit (X : Type) where
  reflect : X → X
  R : X → X
  image_fixed : ∀ x, reflect (R x) = R x
  fixes_fixed_points : ∀ y, reflect y = y → R y = y

theorem orbitLimit_idempotent {X : Type} (o : OrbitLimit X) (x : X) :
    o.R (o.R x) = o.R x :=
  o.fixes_fixed_points (o.R x) (o.image_fixed x)

/-- A Book 7 orbit-limit that is represented by a linear map supplies the
Scholium's reflective linear projection; idempotence is derived from the
orbit-limit laws rather than assumed again. -/
def OrbitLimit.asLinearProjection
    {W : Type} [AddCommGroup W] [Module ℝ W]
    (o : OrbitLimit W) (Rlin : W →ₗ[ℝ] W)
    (hlin : ∀ x, Rlin x = o.R x) :
    ScholiumDyn.ReflectiveLinearProjection W where
  P := Rlin
  idempotent := by
    ext x
    simp only [LinearMap.comp_apply]
    rw [hlin (Rlin x), hlin x, orbitLimit_idempotent o]

/-- Consequently every vector at a linear Book 7 orbit-limit splits into its
stable image component and transverse kernel residual. -/
theorem orbitLimit_linear_image_kernel_split
    {W : Type} [AddCommGroup W] [Module ℝ W]
    (o : OrbitLimit W) (Rlin : W →ₗ[ℝ] W)
    (hlin : ∀ x, Rlin x = o.R x) (x : W) :
    ∃ y z, x = y + z ∧ Rlin y = y ∧ Rlin z = 0 :=
  (o.asLinearProjection Rlin hlin).exists_image_kernel_decomposition x

/-- More generally, differentiability of the idempotent orbit-limit at one
of its image points derives the same tangent image/kernel splitting without
requiring the whole nonlinear limit operator to be linear. -/
theorem orbitLimit_derivative_image_kernel_split
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (o : OrbitLimit W) (P : W →L[ℝ] W) (x v : W)
    (hderiv : HasFDerivAt o.R P (o.R x)) :
    ∃ y z, v = y + z ∧ P y = y ∧ P z = 0 :=
  ScholiumDyn.ReflectiveLinearProjection.derivative_image_kernel_decomposition
    o.R P (o.R x) v (orbitLimit_idempotent o x)
    (orbitLimit_idempotent o) hderiv

/-- At every differentiable Book 7 orbit-limit fixed point, reflection and
drift assemble into the Scholium's complete Jacobian
`J = (P - I) + α dD`, while the reflection derivative is simultaneously
proved idempotent. -/
theorem orbitLimit_completeJacobian
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (o : OrbitLimit W) (D : W → W) (P A : W →L[ℝ] W)
    (α : ℝ) (x : W)
    (hR : HasFDerivAt o.R P (o.R x))
    (hD : HasFDerivAt D A (o.R x)) :
    HasFDerivAt (ScholiumDyn.combinedVectorField o.R D α)
      (ScholiumDyn.combinedJacobian P A α) (o.R x) ∧ P.comp P = P :=
  ScholiumDyn.completeJacobian_at_reflective_fixed
    o.R D P A α (o.R x) (orbitLimit_idempotent o x)
    (orbitLimit_idempotent o) hR hD

/-- The tangent directions of the Book 7 orbit-limit fixed locus are exactly
the vectors fixed by the derivative projection. -/
theorem orbitLimit_fixedLocusVelocity_iff
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (o : OrbitLimit W) (P : W →L[ℝ] W) (x v : W)
    (hR : HasFDerivAt o.R P (o.R x)) :
    ScholiumDyn.IsFixedLocusVelocity o.R (o.R x) v ↔ P v = v :=
  ScholiumDyn.fixedLocusVelocity_iff_derivative_fixed
    o.R P (o.R x) v (orbitLimit_idempotent o x)
    (orbitLimit_idempotent o) hR

/-- Quantitative Book 7 transverse stability: below the unit perturbation
margin, every nonzero kernel direction contracts under one complete
linearized Euler step. -/
theorem orbitLimit_transverse_contracts
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (P A : W →L[ℝ] W) (α : ℝ) (hsmall : |α| * ‖A‖ < 1)
    {v : W} (hv : P v = 0) (hv0 : v ≠ 0) :
    ‖ScholiumDyn.combinedEulerLinearization P A α v‖ < ‖v‖ :=
  ScholiumDyn.combinedEulerLinearization_transverse_contracts
    P A α hsmall hv hv0

/-- Full Book 7 transverse stability package.  Differentiability of the
orbit-limit derives the projection law; invariant differentiated drift then
keeps every iterate transverse, supplies the geometric envelope, and forces
the complete linearized orbit to converge to zero. -/
theorem orbitLimit_transverse_iterates_tendsto_zero
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (o : OrbitLimit W) (P A : W →L[ℝ] W) (α : ℝ) (x : W)
    (hR : HasFDerivAt o.R P (o.R x))
    (hinv : ScholiumDyn.PreservesTransverseKernel P A)
    (hsmall : |α| * ‖A‖ < 1) {v : W} (hv : P v = 0) :
    P.comp P = P ∧
      (∀ n, ‖(ScholiumDyn.combinedEulerLinearization P A α)^[n] v‖ ≤
        (|α| * ‖A‖) ^ n * ‖v‖) ∧
      Filter.Tendsto
        (fun n => (ScholiumDyn.combinedEulerLinearization P A α)^[n] v)
        Filter.atTop (nhds 0) := by
  refine ⟨ScholiumDyn.hasFDerivAt_idempotent_at_fixed
      o.R P (o.R x) (orbitLimit_idempotent o x)
      (orbitLimit_idempotent o) hR, ?_, ?_⟩
  · exact ScholiumDyn.norm_combinedEulerLinearization_iterate_le
      P A α hinv hv
  · exact ScholiumDyn.combinedEulerLinearization_iterate_tendsto_zero
      P A α hinv hsmall hv

/-- Book 7 transverse spectral stability for real eigenmodes: the orbit-limit
derivative is a projection, and every nonzero transverse eigenmode of the
complete Euler linearization has eigenvalue strictly inside the unit disk. -/
theorem orbitLimit_transverse_eigenvalue_stable
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (o : OrbitLimit W) (P A : W →L[ℝ] W) (α μ : ℝ) (x : W)
    (hR : HasFDerivAt o.R P (o.R x)) (hsmall : |α| * ‖A‖ < 1)
    {v : W} (hv : P v = 0) (hv0 : v ≠ 0)
    (heigen : ScholiumDyn.combinedEulerLinearization P A α v = μ • v) :
    P.comp P = P ∧ |μ| < 1 :=
  ⟨ScholiumDyn.hasFDerivAt_idempotent_at_fixed
      o.R P (o.R x) (orbitLimit_idempotent o x)
      (orbitLimit_idempotent o) hR,
    ScholiumDyn.transverse_eigenvalue_abs_lt_one
      P A α μ hsmall hv hv0 heigen⟩

/-- Continuous-time Book 7 eigenmode stability.  A real transverse eigenvalue
of the complete Jacobian lies below the negative perturbation margin, and its
explicit exponential mode converges to zero. -/
theorem orbitLimit_transverse_jacobian_eigenmode_stable
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W]
    (o : OrbitLimit W) (P A : W →L[ℝ] W) (α ν : ℝ) (x : W)
    (hR : HasFDerivAt o.R P (o.R x)) (hsmall : |α| * ‖A‖ < 1)
    {v : W} (hv : P v = 0) (hv0 : v ≠ 0)
    (heigen : ScholiumDyn.combinedJacobian P A α v = ν • v) :
    P.comp P = P ∧ ν ≤ -(1 - |α| * ‖A‖) ∧ ν < 0 ∧
      Filter.Tendsto (fun t : ℝ => Real.exp (t * ν) • v)
        Filter.atTop (nhds 0) := by
  refine ⟨ScholiumDyn.hasFDerivAt_idempotent_at_fixed
      o.R P (o.R x) (orbitLimit_idempotent o x)
      (orbitLimit_idempotent o) hR, ?_, ?_, ?_⟩
  · exact ScholiumDyn.transverse_jacobian_eigenvalue_le_negative_margin
      P A α ν hv hv0 heigen
  · exact ScholiumDyn.transverse_jacobian_eigenvalue_neg
      P A α ν hsmall hv hv0 heigen
  · exact ScholiumDyn.transverse_jacobian_eigenmode_tendsto_zero
      P A α ν hsmall hv hv0 heigen

/-- Book 7 receives the full continuous-time bounded-operator semigroup
generated by the complete Jacobian, together with the projection law derived
from orbit-limit idempotence. -/
theorem orbitLimit_completeJacobian_semigroup
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W] [CompleteSpace W]
    (o : OrbitLimit W) (P A : W →L[ℝ] W) (α : ℝ) (x : W)
    (hR : HasFDerivAt o.R P (o.R x)) :
    P.comp P = P ∧
      ScholiumDyn.jacobianSemigroup P A α 0 = ContinuousLinearMap.id ℝ W ∧
      (∀ s t, ScholiumDyn.jacobianSemigroup P A α (s + t) =
        ScholiumDyn.jacobianSemigroup P A α s *
          ScholiumDyn.jacobianSemigroup P A α t) ∧
      (∀ t, HasDerivAt (ScholiumDyn.jacobianSemigroup P A α)
        (ScholiumDyn.jacobianSemigroup P A α t *
          ScholiumDyn.combinedJacobian P A α) t) := by
  refine ⟨ScholiumDyn.hasFDerivAt_idempotent_at_fixed
      o.R P (o.R x) (orbitLimit_idempotent o x)
      (orbitLimit_idempotent o) hR, ?_, ?_, ?_⟩
  · exact ScholiumDyn.jacobianSemigroup_zero P A α
  · exact ScholiumDyn.jacobianSemigroup_add P A α
  · exact ScholiumDyn.hasDerivAt_jacobianSemigroup P A α

/-- The full Book 7 semigroup acts by the scalar exponential on every real
transverse Jacobian eigenvector and its orbit converges to zero below the
perturbation margin. -/
theorem orbitLimit_semigroup_transverse_eigenmode_tendsto_zero
    {W : Type} [NormedAddCommGroup W] [NormedSpace ℝ W] [CompleteSpace W]
    (o : OrbitLimit W) (P A : W →L[ℝ] W) (α ν : ℝ) (x : W)
    (hR : HasFDerivAt o.R P (o.R x)) (hsmall : |α| * ‖A‖ < 1)
    {v : W} (hv : P v = 0) (hv0 : v ≠ 0)
    (heigen : ScholiumDyn.combinedJacobian P A α v = ν • v) :
    P.comp P = P ∧
      (∀ t, ScholiumDyn.jacobianSemigroup P A α t v =
        Real.exp (t * ν) • v) ∧
      Filter.Tendsto
        (fun t : ℝ => ScholiumDyn.jacobianSemigroup P A α t v)
        Filter.atTop (nhds 0) := by
  refine ⟨ScholiumDyn.hasFDerivAt_idempotent_at_fixed
      o.R P (o.R x) (orbitLimit_idempotent o x)
      (orbitLimit_idempotent o) hR, ?_, ?_⟩
  · intro t
    exact ScholiumDyn.jacobianSemigroup_apply_eigen
      P A α ν t heigen
  · exact ScholiumDyn.jacobianSemigroup_eigenmode_tendsto_zero
      P A α ν hsmall hv hv0 heigen

/-- Apply reflection to the visible coordinate while appending its observer
trace in the Scholium's reflective state space. -/
def OrbitLimit.recordedReflect {X : Type} (o : OrbitLimit X)
    (newTraces : ℕ) (s : ScholiumDyn.ReflectiveState X) :
    ScholiumDyn.ReflectiveState X where
  base := o.reflect s.base
  traces := s.traces + newTraces

/-- A Book 7 reflective fixed point can remain fixed in its visible coordinate
while strict trace production advances the full observer-state. This is the
Scholium → Book 7 form of the observer-relative arrow of time. -/
theorem orbitLimit_base_fixed_but_recorded
    {X : Type} (o : OrbitLimit X) (x : X) (history : ℕ)
    {newTraces : ℕ} (htrace : 0 < newTraces) :
    let s : ScholiumDyn.ReflectiveState X := ⟨o.R x, history⟩
    (o.recordedReflect newTraces s).base = s.base ∧
      o.recordedReflect newTraces s ≠ s := by
  dsimp
  constructor
  · exact o.image_fixed x
  · intro h
    have ht := congrArg ScholiumDyn.ReflectiveState.traces h
    unfold OrbitLimit.recordedReflect at ht
    simp only at ht
    omega

/-- Book 4 → Book 7: a contraction refinement on a nonempty complete metric
space canonically realizes Book 7's orbit-limit structure. Its limit operator
sends every starting state to Book 4's unique TTPR fixed point. -/
noncomputable def contractionRefinementOrbitLimit {X : Type} [MetricSpace X]
    [CompleteSpace X] [Nonempty X] (c : Book4A.ContractionRefinement X) : OrbitLimit X where
  reflect := c.R
  R := fun _ => c.ttprLimit
  image_fixed := fun _ => c.ttprLimit_fixed
  fixes_fixed_points := fun y hy => (c.fixed_eq_ttprLimit (s := y) hy).symm

/-- The canonical Book 7 orbit-limit is an actual orbit limit: every finite
Book 4 refinement trajectory converges to the value selected by its Book 7
limit operator. -/
theorem tendsto_refinement_to_orbitLimit {X : Type} [MetricSpace X]
    [CompleteSpace X] [Nonempty X] (c : Book4A.ContractionRefinement X) (x : X) :
    Filter.Tendsto (fun n => c.R^[n] x) Filter.atTop
      (nhds ((contractionRefinementOrbitLimit c).R x)) := by
  simpa [contractionRefinementOrbitLimit] using c.tendsto_iterate_ttprLimit x

/-- Scholium → Book 4 → Book 7: an orbit-limit image is fixed by Book 7's
reflection; Book 4 therefore keeps it fixed through every finite recursive
self-reference iterate; the Scholium's fixed-point inheritance transports
that stability through any representation with a left inverse. -/
theorem orbitLimit_iterate_fixed_under_representation
    (o : OrbitLimit Real) (f finv : Real → Real)
    (hleft : ∀ y, finv (f y) = y) (x : Real) (n : Nat) :
    f (Book4A.selfReferenceIterate o.reflect n (finv (f (o.R x)))) = f (o.R x) := by
  have hiter : Book4A.selfReferenceIterate o.reflect n (o.R x) = o.R x :=
    Book4A.selfReference_fixed_point o.reflect (o.R x) (o.image_fixed x) n
  exact ScholiumA.fixedPointInheritance f (Book4A.selfReferenceIterate o.reflect n)
    finv hleft hiter
/- ================================================================
   definition:bk7_interactive_drift_reflection_pair,
   definition:bk7_reflective_interaction_operator_,
   theorem:bk7_two_way_street_convergence, theorem:bk7_two_way_street_fixed_point,
   corollary:bk7_stability_near_reciprocity
   ================================================================ -/

/-- The product pseudometric of definition:bk7_interactive_drift_reflection_
pair, `d_P((x,y),(x',y')) := max(d_A(x,x'), d_B(y,y'))`. -/
def prodDist {A B : Type} [PseudoMetricSpace A] [PseudoMetricSpace B]
    (p q : A × B) : ℝ := max (dist p.1 q.1) (dist p.2 q.2)

/-- theorem:bk7_two_way_street_convergence / theorem:bk7_two_way_street_
fixed_point's contraction estimate: if the two cross maps of
definition:bk7_reflective_interaction_operator_ (equivalently the mutual
modeling operators `phi_H, phi_M` of definition:bk7_mutual_modeling_
operators) are Lipschitz with constants `kA, kB`, the joint reflective
interaction operator `Phi(x,y) = (fA y, fB x)` is Lipschitz on the product
with constant `max kA kB`. Below this estimate is packaged through Book 4's
contraction interface; for nonempty complete metric factors and a maximum
constant strictly between zero and one, it yields existence, uniqueness,
and convergence to the reciprocal fixed pair. -/
theorem product_contraction {A B : Type} [PseudoMetricSpace A] [PseudoMetricSpace B]
    (fA : B → A) (fB : A → B) (kA kB : ℝ) (hkA : 0 ≤ kA) (hkB : 0 ≤ kB)
    (hA : ∀ y y', dist (fA y) (fA y') ≤ kA * dist y y')
    (hB : ∀ x x', dist (fB x) (fB x') ≤ kB * dist x x')
    (p q : A × B) :
    prodDist (fA p.2, fB p.1) (fA q.2, fB q.1) ≤ max kA kB * prodDist p q := by
  have hpq_nonneg : 0 ≤ prodDist p q := le_trans dist_nonneg (le_max_left _ _)
  have s2 : dist p.2 q.2 ≤ prodDist p q := le_max_right _ _
  have s1 : dist p.1 q.1 ≤ prodDist p q := le_max_left _ _
  show max (dist (fA p.2) (fA q.2)) (dist (fB p.1) (fB q.1)) ≤ max kA kB * prodDist p q
  apply max_le
  · have h1 := hA p.2 q.2
    have step1 : kA * dist p.2 q.2 ≤ kA * prodDist p q :=
      mul_le_mul_of_nonneg_left s2 hkA
    have step2 : kA * prodDist p q ≤ max kA kB * prodDist p q :=
      mul_le_mul_of_nonneg_right (le_max_left kA kB) hpq_nonneg
    linarith
  · have h1 := hB p.1 q.1
    have step1 : kB * dist p.1 q.1 ≤ kB * prodDist p q :=
      mul_le_mul_of_nonneg_left s1 hkB
    have step2 : kB * prodDist p q ≤ max kA kB * prodDist p q :=
      mul_le_mul_of_nonneg_right (le_max_right kA kB) hpq_nonneg
    linarith

/-- Book 4 → Book 7: the mutual-reflection operator is a Book 4 contraction
refinement whenever its maximum cross-Lipschitz constant lies strictly
between zero and one. The standard product metric is exactly `prodDist`. -/
def mutualRefinement {A B : Type} [MetricSpace A] [MetricSpace B]
    (fA : B → A) (fB : A → B) (kA kB : ℝ)
    (hkA : 0 ≤ kA) (hkB : 0 ≤ kB) (hkpos : 0 < max kA kB)
    (hklt : max kA kB < 1)
    (hA : ∀ y y', dist (fA y) (fA y') ≤ kA * dist y y')
    (hB : ∀ x x', dist (fB x) (fB x') ≤ kB * dist x x') :
    Book4A.ContractionRefinement (A × B) where
  R := fun p => (fA p.2, fB p.1)
  kappa := max kA kB
  kappa_pos := hkpos
  kappa_lt_one := hklt
  contract := fun p q => product_contraction fA fB kA kB hkA hkB hA hB p q

/-- The unique reciprocal state selected by mutual reflection. -/
noncomputable def mutualLimit {A B : Type} [MetricSpace A] [MetricSpace B]
    [CompleteSpace A] [CompleteSpace B] [Nonempty A] [Nonempty B]
    (fA : B → A) (fB : A → B) (kA kB : ℝ)
    (hkA : 0 ≤ kA) (hkB : 0 ≤ kB) (hkpos : 0 < max kA kB)
    (hklt : max kA kB < 1)
    (hA : ∀ y y', dist (fA y) (fA y') ≤ kA * dist y y')
    (hB : ∀ x x', dist (fB x) (fB x') ≤ kB * dist x x') : A × B :=
  (mutualRefinement fA fB kA kB hkA hkB hkpos hklt hA hB).ttprLimit

/-- The mutual limit is a genuine reciprocal pair. -/
theorem mutualLimit_fixed {A B : Type} [MetricSpace A] [MetricSpace B]
    [CompleteSpace A] [CompleteSpace B] [Nonempty A] [Nonempty B]
    (fA : B → A) (fB : A → B) (kA kB : ℝ)
    (hkA : 0 ≤ kA) (hkB : 0 ≤ kB) (hkpos : 0 < max kA kB)
    (hklt : max kA kB < 1)
    (hA : ∀ y y', dist (fA y) (fA y') ≤ kA * dist y y')
    (hB : ∀ x x', dist (fB x) (fB x') ≤ kB * dist x x') :
    let z := mutualLimit fA fB kA kB hkA hkB hkpos hklt hA hB
    fA z.2 = z.1 ∧ fB z.1 = z.2 := by
  let c := mutualRefinement fA fB kA kB hkA hkB hkpos hklt hA hB
  have hfix := c.ttprLimit_fixed
  change (fA c.ttprLimit.2, fB c.ttprLimit.1) = c.ttprLimit at hfix
  exact ⟨congrArg Prod.fst hfix, congrArg Prod.snd hfix⟩

/-- Any reciprocal pair equals the mutual limit. -/
theorem reciprocalPair_unique {A B : Type} [MetricSpace A] [MetricSpace B]
    [CompleteSpace A] [CompleteSpace B] [Nonempty A] [Nonempty B]
    (fA : B → A) (fB : A → B) (kA kB : ℝ)
    (hkA : 0 ≤ kA) (hkB : 0 ≤ kB) (hkpos : 0 < max kA kB)
    (hklt : max kA kB < 1)
    (hA : ∀ y y', dist (fA y) (fA y') ≤ kA * dist y y')
    (hB : ∀ x x', dist (fB x) (fB x') ≤ kB * dist x x')
    (p : A × B) (hpA : fA p.2 = p.1) (hpB : fB p.1 = p.2) :
    p = mutualLimit fA fB kA kB hkA hkB hkpos hklt hA hB := by
  let c := mutualRefinement fA fB kA kB hkA hkB hkpos hklt hA hB
  apply c.fixed_eq_ttprLimit
  exact Prod.ext hpA hpB

/-- Every joint mutual-reflection trajectory converges to the unique
reciprocal pair. -/
theorem tendsto_mutualRefinement {A B : Type} [MetricSpace A] [MetricSpace B]
    [CompleteSpace A] [CompleteSpace B] [Nonempty A] [Nonempty B]
    (fA : B → A) (fB : A → B) (kA kB : ℝ)
    (hkA : 0 ≤ kA) (hkB : 0 ≤ kB) (hkpos : 0 < max kA kB)
    (hklt : max kA kB < 1)
    (hA : ∀ y y', dist (fA y) (fA y') ≤ kA * dist y y')
    (hB : ∀ x x', dist (fB x) (fB x') ≤ kB * dist x x') (p : A × B) :
    Filter.Tendsto
      (fun n => (fun q : A × B => (fA q.2, fB q.1))^[n] p)
      Filter.atTop (nhds (mutualLimit fA fB kA kB hkA hkB hkpos hklt hA hB)) :=
  (mutualRefinement fA fB kA kB hkA hkB hkpos hklt hA hB).tendsto_iterate_ttprLimit p

/-- corollary:bk7_stability_near_reciprocity's one-step content: if `Phi` is
Lipschitz with constant `kappa < 1` and `fixedPt` is a genuine fixed point of
`Phi`, then one application of `Phi` shrinks the distance to `fixedPt` by at
least the factor `kappa`. The existence of `fixedPt` itself is a hypothesis
here, not derived. -/
structure ContractionToFixedPoint (X : Type) [PseudoMetricSpace X] where
  Phi : X → X
  kappa : ℝ
  kappa_nonneg : 0 ≤ kappa
  kappa_lt_one : kappa < 1
  fixedPt : X
  isFixed : Phi fixedPt = fixedPt
  lipschitz : ∀ x y, dist (Phi x) (Phi y) ≤ kappa * dist x y

theorem contraction_step {X : Type} [PseudoMetricSpace X]
    (c : ContractionToFixedPoint X) (x : X) :
    dist (c.Phi x) c.fixedPt ≤ c.kappa * dist x c.fixedPt := by
  have h := c.lipschitz x c.fixedPt
  rwa [c.isFixed] at h

/- ================================================================
   lemma:bk7_frame_temperature_exponent_correspondence,
   theorem:bk7_hilbert_banach_bridge, lemma:bk7_coarsegrained_convexity
   ================================================================ -/

/-- lemma:bk7_frame_temperature_exponent_correspondence's uniqueness clause
("there is a unique xi* with p(xi*) = 2"): a strictly antitone real function
is injective, so any two points where it takes the same value coincide. The
existence half (from the stated limits at 0 and infinity, via the
intermediate value theorem) and the explicit construction of `p` from the
frame-temperature quotient are not modeled. -/
theorem exponent_uniqueness {p : ℝ → ℝ} (hp : StrictAnti p) {xi1 xi2 : ℝ}
    (h1 : p xi1 = 2) (h2 : p xi2 = 2) : xi1 = xi2 :=
  hp.injective (h1.trans h2.symm)

/-- theorem:bk7_hilbert_banach_bridge's Banach-versus-Hilbert regime
comparison, in its honest two-coordinate instance: the `L^1` norm
`|a| + |b|` and the `L^2` (Hilbert) norm `sqrt(a^2+b^2)` on `R^2` bound each
other within a factor of `sqrt 2`, the finite-dimensional shadow of part (i)
of the theorem (the interpolation/norm-comparison inequality between the
`p = 1` and `p = 2` cross-sections). The general `L^p` interpolation
inequality on `L^p(M_epsilon, mu_g)` is not modeled. -/
theorem l1_l2_comparison (a b : ℝ) :
    Real.sqrt (a ^ 2 + b ^ 2) ≤ |a| + |b| ∧
      |a| + |b| ≤ Real.sqrt 2 * Real.sqrt (a ^ 2 + b ^ 2) := by
  have habs_nonneg : (0:ℝ) ≤ |a| + |b| := by positivity
  constructor
  · have hsq : a ^ 2 + b ^ 2 ≤ (|a| + |b|) ^ 2 := by nlinarith [sq_abs a, sq_abs b, abs_nonneg a, abs_nonneg b]
    calc Real.sqrt (a ^ 2 + b ^ 2) ≤ Real.sqrt ((|a| + |b|) ^ 2) := Real.sqrt_le_sqrt hsq
      _ = |a| + |b| := Real.sqrt_sq habs_nonneg
  · have key : (|a| + |b|) ^ 2 ≤ 2 * (a ^ 2 + b ^ 2) := by
      nlinarith [sq_nonneg (|a| - |b|), sq_abs a, sq_abs b]
    calc |a| + |b| = Real.sqrt ((|a| + |b|) ^ 2) := (Real.sqrt_sq habs_nonneg).symm
      _ ≤ Real.sqrt (2 * (a ^ 2 + b ^ 2)) := Real.sqrt_le_sqrt key
      _ = Real.sqrt 2 * Real.sqrt (a ^ 2 + b ^ 2) := Real.sqrt_mul (by norm_num) _

/-- lemma:bk7_coarsegrained_convexity's Hilbert cross-section (`p = 2`):
strict midpoint convexity of `x |-> x^2`. The general strict convexity for
every `p in (1, infinity)`, and the underlying coarse-grained error-field
functional it is stated for, are not modeled. -/
theorem square_strictly_convex_midpoint (x y : ℝ) (hxy : x ≠ y) :
    ((x + y) / 2) ^ 2 < (x ^ 2 + y ^ 2) / 2 := by
  have hne : x - y ≠ 0 := sub_ne_zero.mpr hxy
  nlinarith [sq_pos_of_ne_zero hne]

end

end ForcingAnalysis.Book7
