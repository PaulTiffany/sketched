/-
ScholiumB.lean - cross-book meta-commentary (second half of the Principia
atlas slice), honest kernel.

This packet's 68 anchors are almost entirely meta-commentary tying Book I's
symbolic-manifold/Hilbert-space/Fokker-Planck apparatus together: Riemannian
colimit-manifold construction from a stage tower, Wasserstein/Fisher-Rao
information geometry, symbolic Fokker-Planck/H-theorem/least-action, a
cosmological symbolization functor into Lorentzian causal-thermodynamic data,
Hilbert-space (in)compatibility, curvature-tensor emergence theorems, and a
"certified transport" bookkeeping definition over an unspecified vocabulary.
None of that is honestly formalizable at this kernel's level (no manifolds,
no Hilbert/Banach spaces, no PDEs, no measure theory beyond finite sums), so
the overwhelming majority of anchors are left open and listed in the
accompanying proposal rather than forced into decorative theorems.

Five families ARE honestly formalizable once the geometric dressing is
stripped:

  * definition:bk1_reflexive_encoding_depth's recursive scheme
    `reflect_0(sigma) = sigma`, `reflect_n(sigma) = F[reflect_{n-1}(sigma)]`
    is exactly `Function.iterate` under another name: `reflexiveIterate`
    is defined by the same two recursion equations and shown to agree with
    `F^[n]`, plus the expected additivity law.

  * The irony triple (theorem:bk1_symbolic_irony_requires_curvature,
    theorem:bk1_operational_irony_requires_reflexive_curvature,
    theorem:bk1_operational_irony_requires_imagination) all have the same
    honest shape: encoding irony implies a conjunction of side conditions
    (reflexive depth >= 2 and nonzero curvature; nonzero imaginative
    distance). Kept as a structure of laws (`IronyCapacity`, generalizing
    definition:bk1_operational_irony's "operationally encodes irony"
    predicate) with the two implications as fields, the honest content is
    their contrapositives: shallow-or-flat architectures, and real-only
    architectures, cannot encode irony. The two curvature-flavored source
    anchors are proved by the SAME Lean theorem, noted at the binding.

  * theorem:bk1_emergence_of_reflection_operator's stated idempotence
    `R_stab^2 = R_stab` and corollary:bk1_fixed_point's fixed-locus claim
    are pure algebra once the colimit-existence machinery producing
    `R_stab` is erased: for ANY idempotent self-map, every point of its
    image is a fixed point, so the fixed locus is nonempty whenever the
    image is. This is exactly the two-line argument given in the source
    proofs, with the manifold/colimit existence argument (not modeled)
    dropped.

  * theorem:bk1_variational_principle / corollary:bk1_equilibrium_distribution
    assert a Gibbs form `rho_eq(x) = Z^{-1} e^{-beta H(x)}` on a symbolic
    manifold with a measure-theoretic partition function. The honest
    finite-discrete kernel is the ordinary finite Gibbs/Boltzmann
    distribution over a nonempty finite index type: positivity,
    normalization (sum to 1), and the monotonicity law that lower energy
    receives no less probability -- the finite-sum analogue of the
    manifold integral, with no measure theory beyond `Finset.sum`.

  * definition:bk1_minimal_linear_ps_model is already fully finite-
    dimensional and explicit (2x2 real matrices as maps on `Real x Real`),
    and theorem:bk1_nonvacuity_minimal_linear_ps_model's three claims
    (collapse is not the identity, drift and stabilization do not commute,
    the connection has nonzero curvature) are concrete witness
    computations, formalized directly and unconditionally.

Left open (with reasons in the proposal's open_anchors): the Hilbert-space
incompatibility lemma and the curvature/non-Euclidean-space/Symbolic-Primacy
cluster; the SRMF/energy-functional/paradox-triggered-emergence/shared-
boundary-paradox/emergence-operator cluster (narrative fixed-point-in-a-
membrane claims with no scalar content); the entire colimit-manifold
construction cluster (symbolic smoothness through completeness-of-distance,
15 anchors) other than the idempotence fact extracted above; the symbolic
Hamiltonian/entropy/Fokker-Planck/H-theorem/least-action/information-
geometry/Wasserstein cluster other than the finite Gibbs form extracted
above; the phase-transition genericity theorem and its imagination corollary
(spectral-coupling hypotheses referencing an external trichotomy); the local
stability lemma (C^1 ODE/spectral); the fluctuation-dissipation relation;
the cosmological symbolization functor and dual-horizon cosmogenesis
cluster; the horizon-crossing/dual-horizon-unification cluster; the
certified-transport bookkeeping cluster (unspecified vocabulary data, no
scalar law to extract).
-/
import Mathlib

namespace ForcingAnalysis.ScholiumB

/- ================================================================
   definition:bk1_reflexive_encoding_depth
   ================================================================ -/

/-- The reflexive iteration scheme of definition:bk1_reflexive_encoding_depth:
`reflexiveIterate F 0 x = x` (direct representation) and
`reflexiveIterate F (n+1) x = F (reflexiveIterate F n x)` (higher-order
reflection). The divergence-sign "irony" selection predicate on top of this
recursion is not modeled; only the recursive scheme itself is. -/
def reflexiveIterate {X : Type} (F : X → X) : Nat → X → X
  | 0, x => x
  | n + 1, x => F (reflexiveIterate F n x)

/-- The recursive scheme of definition:bk1_reflexive_encoding_depth agrees
with ordinary function iteration. -/
theorem reflexiveIterate_eq_iterate {X : Type} (F : X → X) (n : Nat) (x : X) :
    reflexiveIterate F n x = F^[n] x := by
  induction n with
  | zero => rfl
  | succ k ih =>
      show F (reflexiveIterate F k x) = F^[k + 1] x
      rw [ih, Function.iterate_succ_apply']

/-- Reflexive depths compose additively: reflecting `m` further steps past
depth `n` is the same as reflecting to depth `m + n` directly. -/
theorem reflexiveIterate_add {X : Type} (F : X → X) (m n : Nat) (x : X) :
    reflexiveIterate F (m + n) x = reflexiveIterate F m (reflexiveIterate F n x) := by
  simp only [reflexiveIterate_eq_iterate, Function.iterate_add_apply]

/- ================================================================
   definition:bk1_operational_irony,
   theorem:bk1_symbolic_irony_requires_curvature,
   theorem:bk1_operational_irony_requires_reflexive_curvature,
   theorem:bk1_operational_irony_requires_imagination
   ================================================================ -/

/-- The shared law behind the irony triple: an architecture's capacity to
operationally encode irony (definition:bk1_operational_irony's "single
representation jointly resolving two opposed layers, both recoverable")
forces both a reflexive-depth lower bound and nonzero curvature
(theorem:bk1_operational_irony_requires_reflexive_curvature, and its
symbolic-curvature-only special case
theorem:bk1_symbolic_irony_requires_curvature), and forces nonzero
imaginative displacement
(theorem:bk1_operational_irony_requires_imagination). Only the stated
implications are kept as data; the definitions of depth, curvature and
imaginative distance themselves are not modeled beyond these scalar/natural
witnesses. -/
structure IronyCapacity where
  encodesIrony : Prop
  depth : Nat
  curvature : Real
  imaginaryDistance : Real
  irony_needs_depth_and_curvature : encodesIrony → 2 ≤ depth ∧ curvature ≠ 0
  irony_needs_imagination : encodesIrony → imaginaryDistance ≠ 0

/-- Contrapositive of theorem:bk1_operational_irony_requires_reflexive_curvature
(and, in the flat case, theorem:bk1_symbolic_irony_requires_curvature): an
architecture limited to first-order representation (depth < 2) or to flat
representation (zero curvature) cannot operationally encode irony. -/
theorem no_irony_of_shallow_or_flat (I : IronyCapacity)
    (h : I.depth < 2 ∨ I.curvature = 0) : ¬ I.encodesIrony := by
  intro hIrony
  obtain ⟨hd, hc⟩ := I.irony_needs_depth_and_curvature hIrony
  rcases h with hlt | hz
  · omega
  · exact hc hz

/-- Contrapositive of theorem:bk1_operational_irony_requires_imagination: an
architecture restricted to real-only symbolic distance cannot operationally
encode irony. -/
theorem no_irony_of_real_only (I : IronyCapacity)
    (h : I.imaginaryDistance = 0) : ¬ I.encodesIrony := fun hIrony =>
  I.irony_needs_imagination hIrony h

/- ================================================================
   theorem:bk1_emergence_of_reflection_operator, corollary:bk1_fixed_point
   ================================================================ -/

/-- A self-map is idempotent (theorem:bk1_emergence_of_reflection_operator's
`R_stab^2 = R_stab`) when applying it twice agrees with applying it once. -/
abbrev IsIdempotent {X : Type} (f : X → X) : Prop := ∀ x, f (f x) = f x

/-- Every point in the image of an idempotent map is already a fixed point
-- exactly the argument of corollary:bk1_fixed_point's proof
("`y = R_stab(x)`, so `R_stab(y) = R_stab(R_stab(x)) = R_stab(x) = y`"),
with the colimit-existence construction of `R_stab` itself erased. -/
theorem idempotent_fixes_image {X : Type} {f : X → X} (hf : IsIdempotent f)
    {y : X} (hy : y ∈ Set.range f) : f y = y := by
  obtain ⟨x, hx⟩ := hy
  rw [← hx]
  exact hf x

/-- corollary:bk1_fixed_point's headline claim: the fixed locus of an
idempotent map is nonempty whenever its image is nonempty. -/
theorem idempotent_fixLocus_nonempty {X : Type} {f : X → X} (hf : IsIdempotent f)
    (h : (Set.range f).Nonempty) : ∃ x, f x = x := by
  obtain ⟨y, hy⟩ := h
  exact ⟨y, idempotent_fixes_image hf hy⟩

/- ================================================================
   theorem:bk1_variational_principle, corollary:bk1_equilibrium_distribution
   ================================================================ -/

/-- The Gibbs weight of corollary:bk1_equilibrium_distribution's
`rho_eq(x) proportional to e^{-beta H(x)}`, over a finite index type standing
in for the symbolic manifold `M` (the measure `d mu_g` is replaced by a
finite sum). -/
noncomputable def gibbsWeight {ι : Type} (H : ι → Real) (β : Real) (i : ι) : Real :=
  Real.exp (-β * H i)

theorem gibbsWeight_pos {ι : Type} (H : ι → Real) (β : Real) (i : ι) :
    0 < gibbsWeight H β i :=
  Real.exp_pos _

/-- The finite partition function `Z`, the discrete analogue of
`Z = int_M e^{-beta H(x)} d mu_g(x)`. -/
noncomputable def gibbsZ {ι : Type} [Fintype ι] (H : ι → Real) (β : Real) : Real :=
  ∑ i, gibbsWeight H β i

theorem gibbsZ_pos {ι : Type} [Fintype ι] [Nonempty ι] (H : ι → Real) (β : Real) :
    0 < gibbsZ H β := by
  unfold gibbsZ
  exact Finset.sum_pos (fun i _ => gibbsWeight_pos H β i) Finset.univ_nonempty

/-- The equilibrium distribution of corollary:bk1_equilibrium_distribution,
`rho_eq(x) = Z^{-1} e^{-beta H(x)}`, over a finite index type. -/
noncomputable def gibbsProb {ι : Type} [Fintype ι] (H : ι → Real) (β : Real) (i : ι) : Real :=
  gibbsWeight H β i / gibbsZ H β

theorem gibbsProb_pos {ι : Type} [Fintype ι] [Nonempty ι] (H : ι → Real) (β : Real) (i : ι) :
    0 < gibbsProb H β i :=
  div_pos (gibbsWeight_pos H β i) (gibbsZ_pos H β)

/-- The equilibrium distribution is a genuine probability distribution
(the normalization constraint `int_M rho d mu_g = 1` of
definition:bk1_symbolic_probabilty_density, at the finite-sum level). -/
theorem gibbsProb_sum_eq_one {ι : Type} [Fintype ι] [Nonempty ι] (H : ι → Real) (β : Real) :
    ∑ i, gibbsProb H β i = 1 := by
  unfold gibbsProb
  rw [← Finset.sum_div]
  exact div_self (gibbsZ_pos H β).ne'

/-- The Boltzmann law underlying theorem:bk1_variational_principle's free-
energy minimization: at positive inverse temperature, states of lower
symbolic-Hamiltonian energy receive no less equilibrium weight. -/
theorem gibbsProb_antitone {ι : Type} [Fintype ι] [Nonempty ι] (H : ι → Real) (β : Real)
    (hβ : 0 < β) {i j : ι} (hij : H i ≤ H j) :
    gibbsProb H β j ≤ gibbsProb H β i := by
  have hZ : 0 < gibbsZ H β := gibbsZ_pos H β
  have hexp : gibbsWeight H β j ≤ gibbsWeight H β i := by
    unfold gibbsWeight
    apply Real.exp_le_exp.mpr
    nlinarith
  unfold gibbsProb
  gcongr

/- ================================================================
   definition:bk1_minimal_linear_ps_model,
   theorem:bk1_nonvacuity_minimal_linear_ps_model
   ================================================================ -/

/-- The state-level collapse `C = P` of
definition:bk1_minimal_linear_ps_model's minimal linear PS-model witness,
with `u` the observer-visible coordinate and `v` the hidden phase
coordinate: `P(u, v) = (u, 0)`. -/
noncomputable def minimalPS_projection (x : Real × Real) : Real × Real := (x.1, 0)

/-- The drift field `D(x) = J x` of the minimal linear PS-model witness,
with `J` the standard rotation matrix. -/
noncomputable def minimalPS_drift (x : Real × Real) : Real × Real := (-x.2, x.1)

/-- The connection coefficient `A_u` of the minimal linear PS-model witness. -/
noncomputable def minimalPS_connU (x : Real × Real) : Real × Real := (x.2, 0)

/-- The connection coefficient `A_v` of the minimal linear PS-model witness. -/
noncomputable def minimalPS_connV (x : Real × Real) : Real × Real := (0, x.1)

/-- theorem:bk1_nonvacuity_minimal_linear_ps_model, clause 1: the collapse
`P` is not the identity. -/
theorem minimalPS_collapse_ne_id : ∃ x : Real × Real, minimalPS_projection x ≠ x := by
  refine ⟨(0, 1), ?_⟩
  norm_num [minimalPS_projection, Prod.ext_iff]

/-- theorem:bk1_nonvacuity_minimal_linear_ps_model, clause 2: drift and
stabilization do not commute. -/
theorem minimalPS_drift_reflection_noncommute :
    ∃ x : Real × Real, minimalPS_drift (minimalPS_projection x)
      ≠ minimalPS_projection (minimalPS_drift x) := by
  refine ⟨(0, 1), ?_⟩
  norm_num [minimalPS_projection, minimalPS_drift, Prod.ext_iff]

/-- theorem:bk1_nonvacuity_minimal_linear_ps_model, clause 3: the symbolic
connection has nonzero curvature, witnessed by the noncommuting connection
coefficients `A_u`, `A_v`. -/
theorem minimalPS_connection_curvature_nonzero :
    ∃ x : Real × Real, minimalPS_connU (minimalPS_connV x)
      ≠ minimalPS_connV (minimalPS_connU x) := by
  refine ⟨(1, 0), ?_⟩
  norm_num [minimalPS_connU, minimalPS_connV, Prod.ext_iff]

end ForcingAnalysis.ScholiumB
