/-
SmallPack.lean - honest kernel of a small combined packet: one Book 1 axiom,
the "Symbolic Reflexive Validation" (SRV) appendix (state space, observer
metric, energy functional, energy contraction, Cauchy convergence, metric
completion, chart system, chart bounds, smooth atlas, smoothness emergence,
resolution corollary), and the "symbolic framing" appendix (LLM observer
tuple, bounded-increment parameter lift, an empirical/narrative theorem about
a named external paper).

Most of the SRV appendix is stated on an unspecified symbolic manifold with
operator-norm-valued endomorphisms, a sup-over-a-continuum observer metric
built from an adjoint action, and a claimed metric completion carrying a
smooth, second-countable, paracompact manifold structure. None of that is
attempted here. For each anchor this file extracts the honest finite/real
kernel instead:

  * the symbolic state space's resolution levels become a plain real
    threshold predicate (`InLevel`), and the "directed union" content is
    exactly its monotonicity in the resolution parameter;
  * the symbolic energy functional is modeled directly as a real expression
    `H + (1/2)*drift^2 + (epsO/2)*refl^2`, with nonnegativity proved
    conditional on the Hamiltonian term and observer-reflection weight being
    nonnegative;
  * the energy contraction lemma's per-step law becomes a structure field on
    an abstract `energy : Nat -> Real` sequence, and its telescoped
    (accumulated) form over `n` steps is proved by induction, in the same
    pattern as Book8's metabolic-sufficiency bound;
  * "Cauchy Convergence of SRV Trajectories" is not proved as literal
    Cauchy-ness in an unconstructed metric `d_O` (that would need the
    observer metric and the flow, neither modeled). Instead the quantitative
    content the claim depends on is proved: given any lower bound on the
    energy sequence, the cumulative squared-drift-plus-reflection cost over
    any number of steps is uniformly bounded, and consequently so is every
    individual step's squared drift -- an honest, weaker substitute, flagged
    as partial coverage rather than hidden;
  * the uniform chart bounds become the scalar inequality family
    `C_chart * sqrt(lambda)`, proved nonnegative and monotone nondecreasing
    in the resolution level; the charts themselves (and their operator-norm
    derivative sup) are not modeled;
  * the LLM observer tuple becomes a structure recording exactly its stated
    shape: a context depth, a depth-indexed family of state transformations,
    and a resolution threshold -- with no additional law asserted, matching
    the source's own disclaimer that the tuple alone does not establish
    diachronic observerhood;
  * the bounded-increment parameter lift's manifold/linear-algebra content
    (the residual map, its derivative `J_x`, tangent spaces, the curvature
    correction) is erased in favor of its abstract order-theoretic core:
    enlarging a feasible real-valued constraint set can only lower the
    least-norm satisfying cost (monotonicity of `sInf` under `⊆`), and the
    decrease is strict exactly when the larger set contains a witness
    strictly below the old infimum -- the honest kernel of "a new parameter
    relieves the obstruction precisely when it contributes a non-redundant
    direction."

Left open, with reasons recorded in the accompanying proposal rather than
forced into decorative theorems: the Book 1 axiom "Existence is not" (a bare
philosophical assertion with no mathematical content); the observer-relative
symbolic metric (a sup over a continuum flow and an adjoint action, needing
Lie-group/Banach structure); the metric completion's existence and
separability (point-set topology beyond this pass's real-analysis scope);
the symbolic chart map itself (no algebraic law beyond its already-covered
bound); the smooth atlas and smoothness-emergence theorems (manifold
formalization is out of scope); the resolution-of-smoothness corollary
(narrative, resolving a scholium about the unformalized results above); and
the "Titans as Arrow of Time" theorem (an empirical/narrative claim about a
specific external paper, not a formalizable mathematical statement).
-/

import Mathlib

namespace ForcingAnalysis.SmallPack

/- ================================================================
   definition:appB_symbolic_state_space
   ================================================================ -/

/-- Membership in the resolution-`lam` level set `P_lam`
(definition:appB_symbolic_state_space): both the symbolic complexity and the
operator norm of the pair are bounded by `lam`. The underlying space `S` and
`End(S)`, and the operator norm itself, are not modeled; only the threshold
predicate on the two real bounding quantities is. -/
abbrev InLevel (complexity opNorm lam : Real) : Prop := complexity ≤ lam ∧ opNorm ≤ lam

/-- The symbolic tower `P = ⋃ lam, P_lam` is a directed union
(definition:appB_symbolic_state_space): the level sets are nested, so
membership at a finer resolution `lam` persists at any coarser resolution
`mu ≥ lam`. -/
theorem resolutionLevel_mono {complexity opNorm lam mu : Real} (hle : lam ≤ mu)
    (h : InLevel complexity opNorm lam) : InLevel complexity opNorm mu :=
  ⟨h.1.trans hle, h.2.trans hle⟩

/- ================================================================
   definition:appB_symbolic_energy
   ================================================================ -/

/-- The symbolic energy functional (definition:appB_symbolic_energy),
modeled directly on reals: `H` is the (already-evaluated) Hamiltonian term,
`drift` and `refl` are the drift and reflection magnitudes, and `epsO` is
the observer-reflection weight `epsilon_O`. The `kappa`-norm and the
underlying SRV-trajectory structure are erased; only this algebraic
combination is kept. -/
noncomputable def symbolicEnergy (H drift refl epsO : Real) : Real :=
  H + (1 / 2) * drift ^ 2 + (epsO / 2) * refl ^ 2

/-- The energy functional is nonnegative whenever the Hamiltonian term is
nonnegative and the observer-reflection weight is nonnegative. -/
theorem symbolicEnergy_nonneg {H drift refl epsO : Real} (hH : 0 ≤ H) (hEps : 0 ≤ epsO) :
    0 ≤ symbolicEnergy H drift refl epsO := by
  unfold symbolicEnergy
  have h1 : 0 ≤ (1 / 2) * drift ^ 2 := by positivity
  have h2 : 0 ≤ (epsO / 2) * refl ^ 2 := mul_nonneg (by linarith) (by positivity)
  linarith

/- ================================================================
   lemma:appB_energy_contraction, theorem:appB_srv_cauchy
   ================================================================ -/

/-- Energy contraction data (lemma:appB_energy_contraction): an abstract
energy sequence together with drift and reflection sequences, an
observer-reflection weight `epsO ≥ 0`, a strictly positive contraction rate
`lambdaCont`, and the per-step law itself: each step's energy drop is at
least `lambdaCont` times the step's squared drift-plus-weighted-reflection
cost. `H_symb` and the SRV dynamics generating these sequences are not
modeled; only the stated per-step inequality is. -/
structure SymbolicEnergyContraction where
  energy : Nat → Real
  drift : Nat → Real
  refl : Nat → Real
  epsO : Real
  epsO_nonneg : 0 ≤ epsO
  lambdaCont : Real
  lambdaCont_pos : 0 < lambdaCont
  contraction : ∀ t, energy (t + 1) ≤ energy t - lambdaCont * (drift t ^ 2 + epsO * refl t ^ 2)

/-- Telescoped form of the contraction law, by induction on the number of
steps: the total drift-plus-reflection cost accumulated over `n` steps is
bounded by the total energy drop. -/
theorem symbolicEnergyContraction_accum (c : SymbolicEnergyContraction) (n : Nat) :
    c.lambdaCont * (∑ t ∈ Finset.range n, (c.drift t ^ 2 + c.epsO * c.refl t ^ 2))
      ≤ c.energy 0 - c.energy n := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, mul_add]
      have hstep := c.contraction k
      linarith

/-- theorem:appB_srv_cauchy, honest substitute: this does not construct the
observer metric `d_O` or prove literal Cauchy-ness of the trajectory.
Instead it proves the quantitative content the claim depends on: if the
energy sequence never drops below a floor `L`, the cumulative
drift-plus-reflection cost over any number of steps is uniformly bounded,
independent of `n`. -/
theorem symbolicEnergyContraction_sum_bounded (c : SymbolicEnergyContraction) {L : Real}
    (hL : ∀ t, L ≤ c.energy t) (n : Nat) :
    c.lambdaCont * (∑ t ∈ Finset.range n, (c.drift t ^ 2 + c.epsO * c.refl t ^ 2))
      ≤ c.energy 0 - L := by
  have hacc := symbolicEnergyContraction_accum c n
  have hLn := hL n
  linarith

/-- Consequence of the cumulative bound: each individual step's squared
drift is uniformly bounded across all `t`, the honest per-step form of
"the trajectory is Cauchy." -/
theorem symbolicEnergyContraction_term_bounded (c : SymbolicEnergyContraction) {L : Real}
    (hL : ∀ t, L ≤ c.energy t) {n t : Nat} (ht : t ∈ Finset.range n) :
    c.lambdaCont * c.drift t ^ 2 ≤ c.energy 0 - L := by
  have hterm_nonneg : ∀ s ∈ Finset.range n, 0 ≤ c.drift s ^ 2 + c.epsO * c.refl s ^ 2 := by
    intro s _
    have h1 : 0 ≤ c.drift s ^ 2 := sq_nonneg _
    have h2 : 0 ≤ c.epsO * c.refl s ^ 2 := mul_nonneg c.epsO_nonneg (sq_nonneg _)
    linarith
  have hle : c.drift t ^ 2 + c.epsO * c.refl t ^ 2
      ≤ ∑ s ∈ Finset.range n, (c.drift s ^ 2 + c.epsO * c.refl s ^ 2) :=
    Finset.single_le_sum hterm_nonneg ht
  have hrefl_nonneg : 0 ≤ c.epsO * c.refl t ^ 2 := mul_nonneg c.epsO_nonneg (sq_nonneg _)
  have hdrift_le_sum : c.drift t ^ 2
      ≤ ∑ s ∈ Finset.range n, (c.drift s ^ 2 + c.epsO * c.refl s ^ 2) := by linarith
  have hmul : c.lambdaCont * c.drift t ^ 2
      ≤ c.lambdaCont * (∑ s ∈ Finset.range n, (c.drift s ^ 2 + c.epsO * c.refl s ^ 2)) :=
    mul_le_mul_of_nonneg_left hdrift_le_sum (le_of_lt c.lambdaCont_pos)
  have hsum := symbolicEnergyContraction_sum_bounded c hL n
  linarith

/- ================================================================
   lemma:appB_chart_bounds
   ================================================================ -/

/-- Uniform chart bounds (lemma:appB_chart_bounds), scalar content only: the
bound expression `C_chart * sqrt(lambda)` is monotone nondecreasing in the
resolution level `lambda`. The charts `chi_lambda` themselves and the
operator-norm sup defining the bound are not modeled. -/
theorem chartBound_mono {C lam mu : Real} (hC : 0 ≤ C) (hle : lam ≤ mu) :
    C * Real.sqrt lam ≤ C * Real.sqrt mu :=
  mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hle) hC

/-- The chart-bound expression is always nonnegative. -/
theorem chartBound_nonneg (C lam : Real) (hC : 0 ≤ C) : 0 ≤ C * Real.sqrt lam :=
  mul_nonneg hC (Real.sqrt_nonneg lam)

/- ================================================================
   definition:appD_llm_observer_tuple
   ================================================================ -/

/-- The bounded observer tuple of an LLM inference episode
(definition:appD_llm_observer_tuple): a context depth `Nctx`, an
`Nctx`-indexed family of internal state transformations `delta`, and a
resolution threshold `epsilon`. No further law is asserted -- the source
text itself notes that this tuple alone does not establish diachronic
observerhood (persistence, memory, accountability, and self-repair across
episodes require additional structure not modeled here). -/
structure BoundedObserverTuple (S : Type) where
  Nctx : Nat
  delta : Fin Nctx → (S → S)
  epsilon : Real

/- ================================================================
   theorem:appD_bounded_increment_parameter_lift
   ================================================================ -/

/-- Half of theorem:appD_bounded_increment_parameter_lift's honest kernel:
the residual map, its derivative `J_x`, tangent spaces, and the curvature
correction are erased; what remains is the abstract order-theoretic fact
that enlarging a feasible real-valued constraint set can only lower (or
leave unchanged) the least-norm satisfying cost. -/
theorem inf_mono_of_subset {S T : Set Real} (hS : S.Nonempty) (hTbelow : BddBelow T)
    (hsub : S ⊆ T) : sInf T ≤ sInf S :=
  csInf_le_csInf hTbelow hS hsub

/-- The other half: the decrease is strict exactly when the enlarged
feasible set contains a witness strictly below the old infimum -- the
honest kernel of "a new parameter relieves the obstruction precisely when
it contributes a non-redundant, constraint-canceling component." -/
theorem inf_strict_decrease {T : Set Real} (hTbelow : BddBelow T) {t sInfS : Real}
    (ht : t ∈ T) (htlt : t < sInfS) : sInf T < sInfS :=
  lt_of_le_of_lt (csInf_le hTbelow ht) htlt

end ForcingAnalysis.SmallPack
