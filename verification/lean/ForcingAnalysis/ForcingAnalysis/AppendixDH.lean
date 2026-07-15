/-
AppendixDH.lean - Dual Horizon appendix (frame space, bounded discernibility,
orthogonal/sigma additivity), honest kernel.

Appendix "Dual Horizon" is stated on symbolic manifolds with a metric, drift
and reflection vector fields, divergence integrals against an observer
measure, a finite-dimensional Hilbert space `Horizon` of projectors
`Proj(Horizon)` with an observer coherence functional valued in `[0,1]`, and
several asymptotic (limit-of-sequence / operator-norm / Banach-space)
golden-ratio claims. This module does NOT attempt manifolds, divergence
integrals, Hilbert-space operator theory, or asymptotic limits. For each
anchor it extracts the honest finite/algebraic kernel instead:

  * the "generative/stabilizing horizon flux" pair and the "bounded
    reflexive emergence" threshold become one connected real-number
    sandwich: `kappa * m <= deltaPhi <= Lambda * m` for `m := min G C`,
    with sufficiency, necessity, and a tight-case biconditional proved
    directly, and "Dual Horizon Necessity" (`G > 0` and `C > 0`) derived as
    the genuine consequence of the necessity direction -- this is the proof
    "by Emergence Domination" route the source offers as Proof II; the
    source's alternative "Proof I, from Bounded Observability alone" is not
    modeled since that assumption is not stated in the packet with enough
    precision to formalize;
  * the frame space `F_Obs subseteq Proj(Horizon)`, the coherence functional
    `C_Obs`, and the finite observer token space become one finite
    combinatorial model: a `TokenResolution` assigning each token to exactly
    one frame index (replacing "the collapse map applied to a complete
    orthogonal frame" with a resolving function), from which orthogonal
    token separation and coarse-graining-as-union become genuine theorems
    (not axioms) about `Finset.filter`/`Finset.biUnion`;
  * the observer coherence budget's finite additivity becomes a
    `CoherenceBudget` structure with a proved extension from the binary
    additivity law to arbitrary finite disjoint families (by induction),
    giving orthogonal additivity (PS-C3, now a theorem rather than a
    corollary of an axiom) and the boundedness axiom PS-C1 as a proved
    consequence of nonnegativity plus additivity, rather than a separate
    postulate; the remark that finite orthogonal additivity is already all
    the "countable additivity" a finite-dimensional Horizon can ask for
    (lemma:appC_sigma_additivity) is realized directly: the conservation
    corollary below sums over `Finset.univ` for a `Fintype` index, i.e. over
    every family a finite-dimensional space can present;
  * the Axiom of Memory and the Fundamental Irreversibility/Arrow-of-Time
    pair become a `MemoryAct` structure carrying a strictly increasing
    natural-number order parameter on the history component, from which
    "history changes on every act" and "no return to an earlier history" are
    proved as theorems (upgrading the source's axiom to a derived fact of
    the monotone-order model);
  * the Symbolic Potential `V(C) = (1/2)(C - 1/C)^2` is kept exactly, with
    its nonnegativity and its zero-locus (`C = 1`) proved;
  * the golden-ratio cluster (Lagrangian equilibrium, sustainable growth,
    the growth operator's eigenvector, entropy/curvature minimization, flow
    stability, the unified fixed point) is reframed from limits of sequences
    / operator norms to the algebraic fixed-point inequality
    `theta >= 1 + 1/theta` that the source itself uses verbatim for the
    curvature-parameter theorem: sustainability, minimality of `phi` among
    sustainable rates, minimality of the entropy/curvature functional at
    `phi`, the stability bound `1/phi^2 < 1`, and the unified fixed-point
    biconditional are all proved from this algebraic reframing -- an honesty
    gap against the source's asymptotic phrasing, noted here rather than
    hidden;
  * the growth operator `G(x,y) = (x+y,x)` and the two-step closure are kept
    as a pair-valued map, with `(phi,1)` exhibited as an honest eigenvector
    (`G(phi,1) = phi . (phi,1)`) and the operator's action on consecutive
    terms of any two-step-closure sequence proved directly -- replacing the
    matrix-power/spectral-radius argument (skipped, see below);
  * the `phi`-stable region's contraction clause becomes a genuine geometric
    decay bound on `Metric.infDist` to a set `M` under repeated application
    of a contracting update map, dropping the invariance clause and the
    curvature inner-product clause (no operator `K_t` is modeled) and
    replacing the "exists a neighborhood `U`" trapping condition with a
    global contraction hypothesis.

Anchors left open (listed in the accompanying proposal with reasons): the
observer-visible system and its horizon-flux divergence integrals (needs a
symbolic manifold and measure theory beyond finite sums); the frame space
and coherence functional as literal subsets of `Proj(Horizon)` (folded into
the finite combinatorial model above instead of formalized as stated);
PS-C2/C4/C5/C6 and PS-C3' (unitary covariance, ray invariance,
resolution-limited distinguishability, pure-state calibration,
frame-independence of the token budget) and the observer-relative Born
Rule with its qubit/mixed-state corollaries (all genuinely Hilbert-space/
quantum content); unitary invariance of the measure family; the reflective
state space as a literal product type (folded into `MemoryAct` instead);
the Lagrangian-equilibrium and spectral-radius convergence theorems, the
bounded observation frame, the complexity measure, the frame curvature
operator, and the Banach space of curvature flows (Hilbert space, limits,
and operator norms, explicitly out of scope); the Fibonacci matrix-power
identity and the 2x2-minimality proposition (matrix-power/narrative
content not attempted); the symbolic modality / modal transference cluster
(a five-tuple narrative structure whose one concrete payload, the
transferred golden-ratio invariant, is already covered by the fixed-point
cluster above).
-/

import Mathlib

namespace ForcingAnalysis.AppendixDH

noncomputable section

/- ================================================================
   definition:appC_lagrangian_potential, definition:appC_sustainable_growth_rate,
   theorem:appC_phi_min_growth, definition:appC_complexity_entropy_tradeof,
   theorem:appC_phi_minimized_entropy_per_complexity,
   definition:appC_symbolic_curvature_function,
   theorem:appC_phi_minimal_curvature_parameter,
   definition:appC_symbolic_flow_stability, lemma:appC_stability_phi_flow,
   theorem:appC_unified_recursive_fixed_point
   ================================================================ -/

/-- The golden ratio, `phi = (1 + sqrt 5) / 2`. -/
def phi : Real := (1 + Real.sqrt 5) / 2

/-- The defining quadratic identity `phi * phi = phi + 1`. -/
theorem phi_sq : phi * phi = phi + 1 := by
  have h5 : Real.sqrt 5 * Real.sqrt 5 = 5 := Real.mul_self_sqrt (by norm_num)
  unfold phi
  field_simp
  nlinarith [h5]

theorem phi_gt_one : 1 < phi := by
  have h5 : Real.sqrt 5 * Real.sqrt 5 = 5 := Real.mul_self_sqrt (by norm_num)
  have hnn : 0 ≤ Real.sqrt 5 := Real.sqrt_nonneg 5
  have h2 : 2 < Real.sqrt 5 := by nlinarith [h5, hnn]
  unfold phi
  linarith

theorem phi_pos : 0 < phi := lt_trans one_pos phi_gt_one

/-- `phi` is its own reciprocal-plus-one fixed point: `1 + 1/phi = phi`
(theorem:appC_unified_recursive_fixed_point's equation, specialized to `phi`
via definition:appC_lagrangian_potential's drift--reflection balance). -/
theorem phi_fixed_point : 1 + 1 / phi = phi := by
  have hne : phi ≠ 0 := ne_of_gt phi_pos
  field_simp
  linarith [phi_sq]

/-- A growth rate `theta` is sustainable (definition:appC_sustainable_growth_rate,
reframed algebraically: the source's asymptotic-ratio condition is replaced by
the fixed-point inequality theorem:appC_phi_minimal_curvature_parameter states
verbatim, `theta >= 1 + 1/theta`) if it is positive and dominates its own
reflective retention term. -/
def Sustainable (theta : Real) : Prop := 0 < theta ∧ 1 + 1 / theta ≤ theta

/-- `phi` is sustainable, with equality (the minimal balanced closure). -/
theorem sustainable_phi : Sustainable phi :=
  ⟨phi_pos, le_of_eq phi_fixed_point⟩

/-- theorem:appC_phi_min_growth (algebraic reframing): `phi` is the least
sustainable growth rate. -/
theorem sustainable_ge_phi (theta : Real) (h : Sustainable theta) : phi ≤ theta := by
  obtain ⟨hpos, hle⟩ := h
  by_contra hcon
  push Not at hcon
  have hexpand : theta * (1 + 1 / theta) = theta + 1 := by
    field_simp
  have hmul : theta + 1 ≤ theta * theta := by
    have hm := mul_le_mul_of_nonneg_left hle (le_of_lt hpos)
    rwa [hexpand] at hm
  have hsum_pos : 0 < theta + phi - 1 := by linarith [phi_gt_one]
  have hfactor : (theta - phi) * (theta + phi - 1) = theta * theta - theta - 1 := by
    linear_combination -phi_sq
  have hneg : (theta - phi) * (theta + phi - 1) < 0 :=
    mul_neg_of_neg_of_pos (by linarith) hsum_pos
  linarith [hfactor, hneg, hmul]

/-- The symbolic curvature / entropy-per-complexity functional
(definition:appC_symbolic_curvature_function and
definition:appC_complexity_entropy_tradeof are the same formula stated
twice). -/
def kappa (theta : Real) : Real := theta + 1 / theta

/-- theorem:appC_phi_minimized_entropy_per_complexity /
theorem:appC_phi_minimal_curvature_parameter (the same theorem, stated
twice): `phi` minimizes `kappa` among sustainable rates. -/
theorem kappa_min_at_phi (theta : Real) (h : Sustainable theta) :
    kappa phi ≤ kappa theta := by
  have hpos := h.1
  have hge : phi ≤ theta := sustainable_ge_phi theta h
  have hprod_pos : 0 < theta * phi := mul_pos hpos phi_pos
  have hge1 : 1 < theta * phi := by nlinarith [hge, phi_gt_one, hpos]
  have hfrac_lt : 1 / (theta * phi) < 1 := by
    rw [div_lt_one hprod_pos]
    exact hge1
  have hdiff_nonneg : 0 ≤ (theta - phi) * (1 - 1 / (theta * phi)) :=
    mul_nonneg (by linarith [hge]) (by linarith [hfrac_lt])
  have hne1 : theta ≠ 0 := ne_of_gt hpos
  have hne2 : phi ≠ 0 := ne_of_gt phi_pos
  have key : theta + 1 / theta - (phi + 1 / phi)
      = (theta - phi) * (1 - 1 / (theta * phi)) := by
    field_simp
    ring
  unfold kappa
  linarith [key, hdiff_nonneg]

/-- definition:appC_symbolic_flow_stability / lemma:appC_stability_phi_flow:
the stability condition `|d/dtheta (1+1/theta)|` at `theta = phi` is
`1/phi^2`, and it is strictly below `1`. -/
theorem stability_phi_flow : 1 / (phi * phi) < 1 := by
  rw [div_lt_one (mul_pos phi_pos phi_pos)]
  nlinarith [phi_gt_one, phi_pos]

/-- theorem:appC_unified_recursive_fixed_point: among positive reals, `phi`
is the unique fixed point of `lam = 1 + 1/lam`. -/
theorem fixed_point_iff_phi (lam : Real) (hlam : 0 < lam) :
    1 + 1 / lam = lam ↔ lam = phi := by
  constructor
  · intro h
    have hSus : Sustainable lam := ⟨hlam, le_of_eq h⟩
    have h1 : phi ≤ lam := sustainable_ge_phi lam hSus
    have heq2 : lam * lam = lam + 1 := by
      have hne : lam ≠ 0 := ne_of_gt hlam
      field_simp at h
      linarith [h]
    have hfactor : (lam - phi) * (lam + phi - 1) = 0 := by
      linear_combination heq2 - phi_sq
    have hsum_pos : 0 < lam + phi - 1 := by linarith [phi_gt_one, hlam]
    have hzero : lam - phi = 0 := by
      rcases mul_eq_zero.mp hfactor with h' | h'
      · exact h'
      · exact absurd h' (ne_of_gt hsum_pos)
    linarith [hzero]
  · intro h
    rw [h]
    exact phi_fixed_point

/-- The symbolic potential of definition:appC_lagrangian_potential. -/
def V (C : Real) : Real := (1 / 2) * (C - 1 / C) ^ 2

theorem V_nonneg (C : Real) : 0 ≤ V C := by
  unfold V
  positivity

theorem V_eq_zero_iff (C : Real) (hC : 0 < C) : V C = 0 ↔ C = 1 := by
  unfold V
  have hne : C ≠ 0 := ne_of_gt hC
  constructor
  · intro h
    have h2 : (C - 1 / C) ^ 2 = 0 := by linarith [h]
    have h3 : C - 1 / C = 0 := by
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h2
    field_simp at h3
    nlinarith [h3]
  · intro h
    subst h
    norm_num

/- ================================================================
   definition:appC_complexity_growth_operator,
   lemma:appC_matrix_representation_symbolic_operators,
   theorem:appC_phi_eigenvalue_recursive_emergence,
   definition:appC_symbolic_operator_assumptions
   ================================================================ -/

/-- The balanced complexity growth operator on two-step symbolic state pairs
(definition:appC_complexity_growth_operator), kept as a pair-valued map
rather than a `2x2` matrix. -/
def Gop (p : Real × Real) : Real × Real := (p.1 + p.2, p.1)

/-- theorem:appC_phi_eigenvalue_recursive_emergence: `(phi, 1)` is an honest
eigenvector of `Gop` with eigenvalue `phi`, replacing the
Perron--Frobenius/matrix-norm argument the source gives. -/
theorem Gop_phi_eigen : Gop (phi, 1) = (phi * phi, phi) := by
  show (phi + 1, phi) = (phi * phi, phi)
  rw [phi_sq]

/-- lemma:appC_matrix_representation_symbolic_operators /
definition:appC_symbolic_operator_assumptions: `Gop` advances one step of any
two-step-closure sequence. -/
theorem Gop_step (s : Nat → Real) (hrec : ∀ n, s (n + 2) = s (n + 1) + s n)
    (n : Nat) : Gop (s (n + 1), s n) = (s (n + 2), s (n + 1)) := by
  show (s (n + 1) + s n, s (n + 1)) = (s (n + 2), s (n + 1))
  rw [hrec n]

/- ================================================================
   definition:appC_observer_token_space, lemma:appC_orthogonal_token_separation,
   lemma:appC_coarse_graining_tokens, definition:appC_observer_coherence_budget,
   theorem:appC_orthogonal_additivity, axiom:appC_psc1, axiom:appC_psc3,
   lemma:appC_sigma_additivity
   ================================================================ -/

/-- The observer's collapse/refinement map (definition:appC_observer_token_space)
realized as a resolving function from a finite token type `tau` to the finite
frame-index type `iota`: each observer-resolvable token realizes the outcome
of exactly one frame element `Pi_i`. This replaces the abstract
`Proj(Horizon)`/discernibility apparatus with the one fact that survives it
in a finite combinatorial model: tokens partition by resolved index. -/
structure TokenResolution (iota tau : Type) [Fintype tau] [DecidableEq iota] where
  resolve : tau → iota

variable {iota tau : Type} [Fintype tau] [DecidableEq iota] [DecidableEq tau]

/-- `T_Obs(Pi_i)`: the tokens resolving to frame index `i`. -/
def TokenResolution.tokensOf (r : TokenResolution iota tau) (i : iota) : Finset tau :=
  Finset.univ.filter (fun t => r.resolve t = i)

/-- `T_Obs` of a coarse-grained projector obtained by unioning the frame
elements indexed by `s`. -/
def TokenResolution.tokensOfSet (r : TokenResolution iota tau) (s : Finset iota) :
    Finset tau :=
  Finset.univ.filter (fun t => r.resolve t ∈ s)

/-- lemma:appC_coarse_graining_tokens: coarse-graining tokens is exactly the
union of the individual token sets. -/
theorem tokensOfSet_eq_biUnion (r : TokenResolution iota tau) (s : Finset iota) :
    r.tokensOfSet s = s.biUnion r.tokensOf := by
  ext t
  simp only [TokenResolution.tokensOfSet, TokenResolution.tokensOf, Finset.mem_filter,
    Finset.mem_univ, true_and, Finset.mem_biUnion]
  constructor
  · intro h
    exact ⟨r.resolve t, h, rfl⟩
  · rintro ⟨i, _, hti⟩
    rwa [hti]

omit [DecidableEq tau] in
/-- lemma:appC_orthogonal_token_separation: tokens resolving to distinct
frame indices are disjoint. -/
theorem orthogonal_token_separation (r : TokenResolution iota tau) {i j : iota}
    (hij : i ≠ j) : Disjoint (r.tokensOf i) (r.tokensOf j) := by
  rw [Finset.disjoint_left]
  intro t hti htj
  simp only [TokenResolution.tokensOf, Finset.mem_filter, Finset.mem_univ, true_and] at hti htj
  exact hij (hti.symm.trans htj)

/-- The observer's finite coherence budget (definition:appC_observer_coherence_budget):
a `[0,1]`-normalized, finitely additive assignment of coherence weight to
subsets of the observer's admissible token set `full`. -/
structure CoherenceBudget (tau : Type) [Fintype tau] [DecidableEq tau] where
  full : Finset tau
  mu : Finset tau → Real
  mu_nonneg : ∀ A, 0 ≤ mu A
  mu_empty : mu ∅ = 0
  mu_full : mu full = 1
  finitely_additive : ∀ A B : Finset tau, A ⊆ full → B ⊆ full → Disjoint A B →
    mu (A ∪ B) = mu A + mu B

variable {tau' : Type} [Fintype tau'] [DecidableEq tau']

/-- PS-C1 (Boundedness), derived: `mu` never exceeds `1` on subsets of the
admissible token set, as a consequence of nonnegativity and finite
additivity rather than a separate postulate. -/
theorem mu_le_one (b : CoherenceBudget tau') (A : Finset tau') (hA : A ⊆ b.full) :
    b.mu A ≤ 1 := by
  have hsub : b.full \ A ⊆ b.full := Finset.sdiff_subset
  have hdisj : Disjoint A (b.full \ A) := by
    rw [Finset.disjoint_left]
    intro t htA htdiff
    exact (Finset.mem_sdiff.mp htdiff).2 htA
  have hunion : A ∪ (b.full \ A) = b.full := by
    ext x
    simp only [Finset.mem_union, Finset.mem_sdiff]
    constructor
    · rintro (hx | ⟨hx, _⟩)
      · exact hA hx
      · exact hx
    · intro hx
      by_cases h : x ∈ A
      · exact Or.inl h
      · exact Or.inr ⟨hx, h⟩
  have hadd := b.finitely_additive A (b.full \ A) hA hsub hdisj
  rw [hunion] at hadd
  have hnn := b.mu_nonneg (b.full \ A)
  linarith [hadd, hnn, b.mu_full]

/-- Finite additivity extends from the binary law to any finite pairwise
disjoint family, by induction on the indexing `Finset`. This is the honest
generalization step behind theorem:appC_orthogonal_additivity. -/
theorem mu_biUnion_eq_sum {iota' : Type} [DecidableEq iota'] (b : CoherenceBudget tau')
    (s : Finset iota') (T : iota' → Finset tau') (hsub : ∀ i ∈ s, T i ⊆ b.full)
    (hdisj : ∀ i ∈ s, ∀ j ∈ s, i ≠ j → Disjoint (T i) (T j)) :
    b.mu (s.biUnion T) = ∑ i ∈ s, b.mu (T i) := by
  induction s using Finset.induction with
  | empty => simp [b.mu_empty]
  | insert a s ha ih =>
      have hsub' : ∀ i ∈ s, T i ⊆ b.full := fun i hi => hsub i (Finset.mem_insert_of_mem hi)
      have hdisj' : ∀ i ∈ s, ∀ j ∈ s, i ≠ j → Disjoint (T i) (T j) := fun i hi j hj hij =>
        hdisj i (Finset.mem_insert_of_mem hi) j (Finset.mem_insert_of_mem hj) hij
      have ihs := ih hsub' hdisj'
      have hTa_sub : T a ⊆ b.full := hsub a (Finset.mem_insert_self a s)
      have hUnion_sub : s.biUnion T ⊆ b.full := by
        intro x hx
        obtain ⟨i, hi, hxi⟩ := Finset.mem_biUnion.mp hx
        exact hsub' i hi hxi
      have hTa_disj : Disjoint (T a) (s.biUnion T) := by
        rw [Finset.disjoint_left]
        intro x hxa hxs
        obtain ⟨i, hi, hxi⟩ := Finset.mem_biUnion.mp hxs
        have hai : a ≠ i := fun h => ha (h ▸ hi)
        exact (Finset.disjoint_left.mp (hdisj a (Finset.mem_insert_self a s) i
          (Finset.mem_insert_of_mem hi) hai)) hxa hxi
      rw [Finset.biUnion_insert, b.finitely_additive (T a) (s.biUnion T) hTa_sub hUnion_sub hTa_disj,
        ihs, Finset.sum_insert ha]

/-- theorem:appC_orthogonal_additivity: the coherence budget is additive
over any finite mutually orthogonal family, realized via the token
resolution model. -/
theorem orthogonal_additivity {iota' : Type} [DecidableEq iota']
    (r : TokenResolution iota' tau') (b : CoherenceBudget tau')
    (hfull : ∀ i, r.tokensOf i ⊆ b.full) (s : Finset iota') :
    b.mu (r.tokensOfSet s) = ∑ i ∈ s, b.mu (r.tokensOf i) := by
  rw [tokensOfSet_eq_biUnion]
  exact mu_biUnion_eq_sum b s r.tokensOf (fun i _ => hfull i)
    (fun i _ j _ hij => orthogonal_token_separation r hij)

/-- PS-C3 (Conservation of interpretive budget), derived: if every token is
accounted for by the frame (`tokensOfSet Finset.univ = full`), the budget
sums to `1` across the whole frame -- and since `iota'` here is a `Fintype`,
this already covers "every orthogonal family" a finite-dimensional `Horizon`
can present (lemma:appC_sigma_additivity's finite-dimensional
countable-additivity remark). -/
theorem mu_conservation {iota' : Type} [Fintype iota'] [DecidableEq iota']
    (r : TokenResolution iota' tau') (b : CoherenceBudget tau')
    (hfull : ∀ i, r.tokensOf i ⊆ b.full)
    (hcover : r.tokensOfSet Finset.univ = b.full) :
    ∑ i, b.mu (r.tokensOf i) = 1 := by
  have h := orthogonal_additivity r b hfull Finset.univ
  rw [hcover, b.mu_full] at h
  linarith [h]

/- ================================================================
   definition:appC_reflective_state_space, axiom:appC_axiom_of_memory,
   theorem:appC_fundamental_irreversibility_final,
   corollary:appC_emergence_of_time_arrow_final
   ================================================================ -/

/-- A bounded observer's reflective dynamics on the reflective state space
`X x H` (definition:appC_reflective_state_space, `X` the base symbolic
manifold and `H` the space of observer histories): each `step` carries a
strictly increasing `order` on the history component (the trace-count
`N(H)` of corollary:appC_emergence_of_time_arrow_final) and a strictly
positive metabolic `cost` (the `Delta F_mem` of axiom:appC_axiom_of_memory). -/
structure MemoryAct (X H : Type) where
  step : X × H → X × H
  order : H → Nat
  order_strict_mono : ∀ s, order s.2 < order (step s).2
  cost : X × H → Real
  cost_pos : ∀ s, 0 < cost s

/-- The Axiom of Memory's conclusion, `H_{t1} != H_{t0}`, recovered as a
theorem from the strictly increasing order parameter rather than postulated
directly. -/
theorem memoryAct_hist_changes {X H : Type} (m : MemoryAct X H) (s : X × H) :
    (m.step s).2 ≠ s.2 := by
  intro h
  have hlt := m.order_strict_mono s
  rw [h] at hlt
  exact lt_irrefl _ hlt

/-- theorem:appC_fundamental_irreversibility_final: every observed act
incurs a strictly positive, non-recoverable metabolic cost. -/
theorem memoryAct_irreversible {X H : Type} (m : MemoryAct X H) (s : X × H) :
    0 < m.cost s :=
  m.cost_pos s

theorem memoryAct_order_iterate {X H : Type} (m : MemoryAct X H) (s : X × H) (n : Nat) :
    m.order s.2 + n ≤ m.order ((m.step^[n] s)).2 := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hnext : m.order (m.step^[k] s).2 < m.order (m.step^[k + 1] s).2 := by
        rw [Function.iterate_succ_apply']
        exact m.order_strict_mono (m.step^[k] s)
      omega

/-- corollary:appC_emergence_of_time_arrow_final: along any nontrivial
observed path the history never returns to an earlier value -- the honest
finite/discrete kernel of the induced directed order. -/
theorem memoryAct_no_return {X H : Type} (m : MemoryAct X H) (s : X × H) (n : Nat)
    (hn : 0 < n) : (m.step^[n] s).2 ≠ s.2 := by
  intro h
  have hiter := memoryAct_order_iterate m s n
  rw [h] at hiter
  omega

/- ================================================================
   definition:appC_bounded_reflexive_emergence,
   theorem:appC_dual_horizon_signature, theorem:appC_dual_horizon_biconditional
   ================================================================ -/

/-- The observer-visible flux data of the Dual Horizon theorems: generative
flux `G`, stabilizing flux `C`, the emergence sandwich constants `kappa,
Lambda` (Emergence Domination/Coupling), and the observed emergence gain
`deltaPhi`, subject to the sandwich `kappa * min G C <= deltaPhi <= Lambda *
min G C` (theorem:appC_dual_horizon_biconditional). -/
structure DualHorizonBalance where
  G : Real
  C : Real
  kappa : Real
  Lambda : Real
  kappa_pos : 0 < kappa
  Lambda_pos : 0 < Lambda
  deltaPhi : Real
  sandwich_lower : kappa * min G C ≤ deltaPhi
  sandwich_upper : deltaPhi ≤ Lambda * min G C

/-- `m := min(G_Obs, C_Obs)`, the shared-domain flux minimum. -/
def DualHorizonBalance.m (d : DualHorizonBalance) : Real := min d.G d.C

/-- Sufficiency: `m >= tauE / kappa` forces `deltaPhi >= tauE`. -/
theorem dualHorizon_sufficiency (d : DualHorizonBalance) (tauE : Real)
    (h : tauE / d.kappa ≤ d.m) : tauE ≤ d.deltaPhi := by
  unfold DualHorizonBalance.m at h
  have h1 : tauE ≤ min d.G d.C * d.kappa := (div_le_iff₀ d.kappa_pos).mp h
  have h2 : min d.G d.C * d.kappa = d.kappa * min d.G d.C := mul_comm _ _
  linarith [d.sandwich_lower, h1, h2]

/-- Necessity: `deltaPhi >= tauE` forces `m >= tauE / Lambda`. -/
theorem dualHorizon_necessity (d : DualHorizonBalance) (tauE : Real)
    (h : tauE ≤ d.deltaPhi) : tauE / d.Lambda ≤ d.m := by
  unfold DualHorizonBalance.m
  have h1 : tauE ≤ d.Lambda * min d.G d.C := le_trans h d.sandwich_upper
  rw [div_le_iff₀ d.Lambda_pos]
  have h2 : d.Lambda * min d.G d.C = min d.G d.C * d.Lambda := mul_comm _ _
  linarith [h1, h2]

theorem dualHorizon_necessity_pos (d : DualHorizonBalance) (tauE : Real)
    (htau : 0 < tauE) (h : tauE ≤ d.deltaPhi) : 0 < d.m := by
  have h1 := dualHorizon_necessity d tauE h
  have h2 : 0 < tauE / d.Lambda := div_pos htau d.Lambda_pos
  linarith [h1, h2]

/-- In the tight-bookkeeping case `kappa = Lambda`, sufficiency and
necessity collapse to an exact biconditional. -/
theorem dualHorizon_tight_biconditional (d : DualHorizonBalance) (tauE : Real)
    (htight : d.kappa = d.Lambda) : tauE ≤ d.deltaPhi ↔ tauE / d.kappa ≤ d.m := by
  constructor
  · intro h
    have := dualHorizon_necessity d tauE h
    rwa [htight]
  · intro h
    exact dualHorizon_sufficiency d tauE h

/-- theorem:appC_dual_horizon_signature (Proof II, from Emergence
Domination): bounded reflexive emergence (definition:appC_bounded_reflexive_emergence,
`deltaPhi >= tauE > 0`) forces both the generative and the stabilizing flux
to be strictly positive on the shared domain. -/
theorem dual_horizon_signature (d : DualHorizonBalance) (tauE : Real) (htau : 0 < tauE)
    (h : tauE ≤ d.deltaPhi) : 0 < d.G ∧ 0 < d.C := by
  have hm := dualHorizon_necessity_pos d tauE htau h
  unfold DualHorizonBalance.m at hm
  exact lt_min_iff.mp hm

/- ================================================================
   definition:appC_phi_stable_region, lemma:appC_geodesic_convergence
   ================================================================ -/

/-- A `phi`-stable region's contraction clause (definition:appC_phi_stable_region,
clause (iii)): repeated application of the update map `Phi` shrinks distance
to `M` by a fixed factor `q < 1`. The invariance clause (i), the curvature
inner-product clause (ii), and the "exists a neighborhood `U`" qualifier of
(iii) are dropped -- no curvature operator is modeled, and the contraction is
kept global rather than local to an unspecified neighborhood. -/
structure PhiStableRegion (X : Type) [PseudoMetricSpace X] where
  M : Set X
  Phi : X → X
  q : Real
  q_nonneg : 0 ≤ q
  q_lt_one : q < 1
  contraction : ∀ x, Metric.infDist (Phi x) M ≤ q * Metric.infDist x M

/-- lemma:appC_geodesic_convergence: an observer trajectory under repeated
`Phi` shrinks its distance to `M` geometrically. -/
theorem geodesic_convergence {X : Type} [PseudoMetricSpace X] (r : PhiStableRegion X)
    (x : Nat → X) (hx : ∀ n, x (n + 1) = r.Phi (x n)) (n : Nat) :
    Metric.infDist (x n) r.M ≤ r.q ^ n * Metric.infDist (x 0) r.M := by
  induction n with
  | zero => simp
  | succ k ih =>
      have hstep : Metric.infDist (x (k + 1)) r.M ≤ r.q * Metric.infDist (x k) r.M := by
        rw [hx k]
        exact r.contraction (x k)
      have hmono : r.q * Metric.infDist (x k) r.M ≤ r.q * (r.q ^ k * Metric.infDist (x 0) r.M) :=
        mul_le_mul_of_nonneg_left ih r.q_nonneg
      calc Metric.infDist (x (k + 1)) r.M
          ≤ r.q * Metric.infDist (x k) r.M := hstep
        _ ≤ r.q * (r.q ^ k * Metric.infDist (x 0) r.M) := hmono
        _ = r.q ^ (k + 1) * Metric.infDist (x 0) r.M := by ring

end

end ForcingAnalysis.AppendixDH
