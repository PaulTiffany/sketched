/-
Book3.lean - symbiotic membranes / symbolic life, honest kernel.

Principia Book 3 is stated on Riemannian manifolds with PDE dynamics:
drift fields on submanifolds, boundary permeability, manifold integrals of
symbolic probability densities, and curl/divergence of a refinement vector
field. This module does NOT attempt manifold formalizations. For each
anchor it extracts the honest static/algebraic/finite-discrete kernel
instead: numeric threshold structures, triangle-inequality bounds, finite
sums over `Fin n`, and telescoping/induction arguments on sequences indexed
by `Nat`. Every modeling commitment (a stated "law", threshold, or rate
equation) is kept as an explicit field of a named structure, never as a
Lean `axiom`.

Anchors that are a taxonomy/citation list, a purely descriptive process
account with no standalone formula, or a semantic correspondence claim
(canonical life standards, the PDE-level refinement/Helmholtz material,
autopoiesis "in response to experience", the closed-loop "can form" claim)
are left unformalized rather than forced into decorative theorems; they are
listed as open anchors in the accompanying proposal.
-/

import Mathlib

namespace ForcingAnalysis.Book3

/- ================================================================
   definition:bk3_symbolic_membrane
   ================================================================ -/

/-- The static numeric skeleton of a symbolic membrane
(definition:bk3_symbolic_membrane): a drift-deviation bound, a boundary
permeability value in `[0,1]`, and a nonnegative stability functional
value. The submanifold structure itself (connectedness, compactness,
smooth boundary) is not modeled. -/
structure Membrane where
  driftDeviation : Real
  driftBound : Real
  driftBound_pos : 0 < driftBound
  driftDeviation_le : driftDeviation <= driftBound
  permeability : Real
  permeability_nonneg : 0 <= permeability
  permeability_le_one : permeability <= 1
  stability : Real
  stability_nonneg : 0 <= stability

theorem membrane_complement_permeability_mem (m : Membrane) :
    0 <= 1 - m.permeability ∧ 1 - m.permeability <= 1 := by
  constructor
  · linarith [m.permeability_le_one]
  · linarith [m.permeability_nonneg]

/- ================================================================
   definition:bk3_membrane_thermodynamics
   ================================================================ -/

/-- Membrane thermodynamic snapshot (definition:bk3_membrane_thermodynamics),
restricted to the energy/entropy/temperature/free-energy algebra; the
underlying manifold integrals defining `E_i`, `S_i` are not modeled. -/
structure MembraneThermo where
  energy : Real
  temperature : Real
  entropy : Real

def membraneFreeEnergy (t : MembraneThermo) : Real :=
  t.energy - t.temperature * t.entropy

def MembraneViable (t : MembraneThermo) : Prop :=
  0 < membraneFreeEnergy t

theorem membrane_viable_iff (t : MembraneThermo) :
    MembraneViable t <-> 0 < t.energy - t.temperature * t.entropy :=
  Iff.rfl

/- ================================================================
   theorem:bk3_membrane_stability_criteria
   ================================================================ -/

/-- The three stability conditions of theorem:bk3_membrane_stability_criteria,
kept as explicit hypotheses rather than derived facts: an (opaque)
free-energy local-minimum witness, an (opaque) no-unstable-fixed-point
witness, and a permeability threshold for outward flow. -/
structure StabilityConditions (m : Membrane) where
  freeEnergyLocalMin : Prop
  freeEnergyLocalMin_holds : freeEnergyLocalMin
  noUnstableFixedPoints : Prop
  noUnstableFixedPoints_holds : noUnstableFixedPoints
  threshold : Real
  threshold_lt_one : threshold < 1
  permeability_below_threshold : m.permeability < threshold

def MembraneStable (m : Membrane) (c : StabilityConditions m) : Prop :=
  c.freeEnergyLocalMin ∧ c.noUnstableFixedPoints ∧ m.permeability < c.threshold

theorem membrane_stable_of_conditions (m : Membrane) (c : StabilityConditions m) :
    MembraneStable m c :=
  ⟨c.freeEnergyLocalMin_holds, c.noUnstableFixedPoints_holds, c.permeability_below_threshold⟩

theorem membrane_stable_permeability_lt_one (m : Membrane) (c : StabilityConditions m) :
    m.permeability < 1 :=
  lt_trans c.permeability_below_threshold c.threshold_lt_one

/- ================================================================
   definition:bk3_coupling_map, definition:bk3_induced_coupling_energy
   ================================================================ -/

/-- Coupling map data (definition:bk3_coupling_map), restricted to the
symmetry and boundedness clauses; the sensitivity clause (nonvanishing
gradients on a dense open subset) requires manifold differential structure
and is not modeled. -/
structure CouplingMap where
  Phi : Real -> Real -> Real
  bound : Real
  bound_pos : 0 < bound
  symmetric : forall x y, Phi x y = Phi y x
  bounded : forall x y, |Phi x y| <= bound

/-- Induced coupling energy (definition:bk3_induced_coupling_energy). -/
def couplingEnergy (lam target phi : Real) : Real :=
  lam * (phi - target) ^ 2

theorem couplingEnergy_nonneg (lam target phi : Real) (hlam : 0 <= lam) :
    0 <= couplingEnergy lam target phi :=
  mul_nonneg hlam (sq_nonneg _)

/- ================================================================
   theorem:bk3_couplinginduced_drift_modification
   ================================================================ -/

/-- The coupling-induced drift correction
(theorem:bk3_couplinginduced_drift_modification), kept as a scalar model:
the correction term is bounded, and the modified drift differs from the
bare drift by at most `eta` times that bound. -/
structure CoupledDrift where
  drift : Real
  eta : Real
  eta_pos : 0 < eta
  correction : Real
  correctionBound : Real
  correctionBound_nonneg : 0 <= correctionBound
  correction_le : |correction| <= correctionBound

def coupledDrift (c : CoupledDrift) : Real :=
  c.drift - c.eta * c.correction

theorem coupled_drift_deviation_bound (c : CoupledDrift) :
    |coupledDrift c - c.drift| <= c.eta * c.correctionBound := by
  have heq : coupledDrift c - c.drift = -(c.eta * c.correction) := by
    unfold coupledDrift; ring
  rw [heq, abs_neg, abs_mul, abs_of_pos c.eta_pos]
  exact mul_le_mul_of_nonneg_left c.correction_le c.eta_pos.le

/- ================================================================
   definition:bk3_symbolic_symbiosis, lemma:bk3_symbiotic_stability_conditions
   ================================================================ -/

/-- Symbiosis conditions (definition:bk3_symbolic_symbiosis), each condition
kept as an explicit hypothesis field rather than derived. -/
structure SymbiosisConditions where
  stabilityCoupledI : Real
  stabilityIsolatedI : Real
  stabilityCoupledJ : Real
  stabilityIsolatedJ : Real
  mutualInfo : Real
  driftPerturbation : Real
  driftResponse : Real
  stability_enhance_i : stabilityIsolatedI < stabilityCoupledI
  stability_enhance_j : stabilityIsolatedJ < stabilityCoupledJ
  info_positive : 0 < mutualInfo
  drift_compensation : |driftPerturbation + driftResponse| < |driftPerturbation|

def InSymbiosis (s : SymbiosisConditions) : Prop :=
  s.stabilityIsolatedI < s.stabilityCoupledI ∧
  s.stabilityIsolatedJ < s.stabilityCoupledJ ∧
  0 < s.mutualInfo ∧
  |s.driftPerturbation + s.driftResponse| < |s.driftPerturbation|

theorem in_symbiosis_of_conditions (s : SymbiosisConditions) : InSymbiosis s :=
  ⟨s.stability_enhance_i, s.stability_enhance_j, s.info_positive, s.drift_compensation⟩

theorem symbiosis_drift_perturbation_ne_zero (s : SymbiosisConditions) :
    s.driftPerturbation ≠ 0 := by
  intro h
  have hc := s.drift_compensation
  rw [h, zero_add, abs_zero] at hc
  exact absurd hc (not_lt.mpr (abs_nonneg _))

/-- Symbiotic stability threshold (lemma:bk3_symbiotic_stability_conditions),
kept as the scalar threshold algebra: `lambda` exceeding the max of the two
named bounds implies it clears each side of the enhancement inequality
`delta^2 < 4 * eta * info * lambda`. -/
structure SymbioticThreshold where
  deltaI : Real
  deltaJ : Real
  etaI : Real
  etaJ : Real
  infoGradI : Real
  infoGradJ : Real
  etaI_pos : 0 < etaI
  etaJ_pos : 0 < etaJ
  infoGradI_pos : 0 < infoGradI
  infoGradJ_pos : 0 < infoGradJ
  lam : Real
  lam_gt_max :
    lam > max (deltaI ^ 2 / (4 * etaI * infoGradI)) (deltaJ ^ 2 / (4 * etaJ * infoGradJ))

theorem symbiotic_threshold_clears_i (t : SymbioticThreshold) :
    t.deltaI ^ 2 < 4 * t.etaI * t.infoGradI * t.lam := by
  have hden : 0 < 4 * t.etaI * t.infoGradI :=
    mul_pos (mul_pos (by norm_num) t.etaI_pos) t.infoGradI_pos
  have hlt : t.deltaI ^ 2 / (4 * t.etaI * t.infoGradI) < t.lam :=
    lt_of_le_of_lt (le_max_left _ _) t.lam_gt_max
  have h2 := (div_lt_iff₀ hden).1 hlt
  calc t.deltaI ^ 2 < t.lam * (4 * t.etaI * t.infoGradI) := h2
    _ = 4 * t.etaI * t.infoGradI * t.lam := by ring

theorem symbiotic_threshold_clears_j (t : SymbioticThreshold) :
    t.deltaJ ^ 2 < 4 * t.etaJ * t.infoGradJ * t.lam := by
  have hden : 0 < 4 * t.etaJ * t.infoGradJ :=
    mul_pos (mul_pos (by norm_num) t.etaJ_pos) t.infoGradJ_pos
  have hlt : t.deltaJ ^ 2 / (4 * t.etaJ * t.infoGradJ) < t.lam :=
    lt_of_le_of_lt (le_max_right _ _) t.lam_gt_max
  have h2 := (div_lt_iff₀ hden).1 hlt
  calc t.deltaJ ^ 2 < t.lam * (4 * t.etaJ * t.infoGradJ) := h2
    _ = 4 * t.etaJ * t.infoGradJ * t.lam := by ring

/- ================================================================
   definition:bk3_reflexive_encoding, theorem:bk3_cyclic_reflexive_encodings
   ================================================================ -/

/-- Bounded-distortion and information-preservation clauses of a reflexive
encoding (definition:bk3_reflexive_encoding). The "stability preservation
up to a scaling factor" clause is an approximate equality (not a strict
inequality) and is not formalized. -/
structure ReflexiveEncoding (X : Type) [PseudoMetricSpace X] where
  roundTrip : X -> X
  epsilon : Real
  epsilon_nonneg : 0 <= epsilon
  distortion_bound : forall x, dist (roundTrip x) x <= epsilon
  totalEntropy : Real
  conditionalEntropy : Real
  kappa : Real
  kappa_pos : 0 < kappa
  info_gap : conditionalEntropy < totalEntropy - kappa

theorem reflexive_encoding_information_strictly_preserved {X : Type} [PseudoMetricSpace X]
    (e : ReflexiveEncoding X) :
    e.conditionalEntropy < e.totalEntropy := by
  linarith [e.info_gap, e.kappa_pos]

/-- Telescoped round-trip distortion (theorem:bk3_cyclic_reflexive_encodings):
composing `n` reflexive encodings around a cycle, so that the composition is
a self-map of the first membrane, accumulates at most the sum of the
individual distortion bounds. Proved by induction using the metric triangle
inequality; this is the same computation whether or not the chain happens
to close into a cycle. -/
theorem cyclic_distortion_bound {X : Type} [PseudoMetricSpace X]
    (p : Nat -> X) (eps : Nat -> Real)
    (hstep : forall i, dist (p i) (p (i + 1)) <= eps i) (n : Nat) :
    dist (p 0) (p n) <= ∑ i ∈ Finset.range n, eps i := by
  induction n with
  | zero => simp
  | succ k ih =>
      have htri : dist (p 0) (p (k + 1)) <= dist (p 0) (p k) + dist (p k) (p (k + 1)) :=
        dist_triangle _ _ _
      have hsum : (∑ i ∈ Finset.range (k + 1), eps i) = (∑ i ∈ Finset.range k, eps i) + eps k :=
        Finset.sum_range_succ eps k
      rw [hsum]
      have hk := hstep k
      linarith

/- ================================================================
   definition:bk3_conceptual_bridge,
   lemma:bk3_reflexive_encodings_generate_conceptual_bridges
   ================================================================ -/

/-- Approximate-invertibility clause of a conceptual bridge
(definition:bk3_conceptual_bridge): only round-trip distortion bounds in
both directions are modeled; "structure preservation" and "semantic
consistency" are descriptive clauses without a standalone formal target
here. -/
structure BoundedRoundTrip (X Y : Type) [PseudoMetricSpace X] [PseudoMetricSpace Y] where
  f12 : X -> Y
  f21 : Y -> X
  epsXY : Real
  epsYX : Real
  epsXY_nonneg : 0 <= epsXY
  epsYX_nonneg : 0 <= epsYX
  boundXY : forall x, dist (f21 (f12 x)) x <= epsXY
  boundYX : forall y, dist (f12 (f21 y)) y <= epsYX

/-- Reflexive encodings whose round trips are bounded in both directions
directly assemble into a conceptual bridge
(lemma:bk3_reflexive_encodings_generate_conceptual_bridges). -/
theorem reflexive_pair_generates_bridge {X Y : Type}
    [PseudoMetricSpace X] [PseudoMetricSpace Y]
    (f12 : X -> Y) (f21 : Y -> X) (epsXY epsYX : Real)
    (hXY_nonneg : 0 <= epsXY) (hYX_nonneg : 0 <= epsYX)
    (hXY : forall x, dist (f21 (f12 x)) x <= epsXY)
    (hYX : forall y, dist (f12 (f21 y)) y <= epsYX) :
    Nonempty (BoundedRoundTrip X Y) :=
  ⟨⟨f12, f21, epsXY, epsYX, hXY_nonneg, hYX_nonneg, hXY, hYX⟩⟩

/- ================================================================
   definition:bk3_symbiotic_curvature,
   theorem:bk3_properties_of_symbiotic_curvature
   ================================================================ -/

/-- Symbiotic curvature (definition:bk3_symbiotic_curvature) over a finite
system of `n` membranes: the average, over membranes, of the
coupled/isolated stability ratio scaled by one plus `gamma` times the total
mutual information with the other membranes. -/
noncomputable def symbioticCurvature (n : Nat) (Scoupled Sisolated : Fin n -> Real)
    (info : Fin n -> Fin n -> Real) (gamma : Real) : Real :=
  (1 / (n : Real)) * ∑ i, (Scoupled i / Sisolated i) *
    (1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j)

theorem symbioticCurvature_pos {n : Nat} (hn : 0 < n)
    (Scoupled Sisolated : Fin n -> Real) (info : Fin n -> Fin n -> Real) (gamma : Real)
    (hS : forall i, 0 < Scoupled i) (hSiso : forall i, 0 < Sisolated i)
    (hinfo : forall i j, 0 <= info i j) (hgamma : 0 <= gamma) :
    0 < symbioticCurvature n Scoupled Sisolated info gamma := by
  haveI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  have hnpos : (0:Real) < (n:Real) := by exact_mod_cast hn
  unfold symbioticCurvature
  have hpos_inv : 0 < 1 / (n:Real) := div_pos one_pos hnpos
  apply mul_pos hpos_inv
  apply Finset.sum_pos
  · intro i _
    have hsum_nonneg : 0 <= ∑ j ∈ Finset.univ.erase i, info i j :=
      Finset.sum_nonneg (fun j _ => hinfo i j)
    have hratio_pos : 0 < Scoupled i / Sisolated i := div_pos (hS i) (hSiso i)
    have hfactor_pos : 0 < 1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j := by
      have := mul_nonneg hgamma hsum_nonneg
      linarith
    exact mul_pos hratio_pos hfactor_pos
  · exact Finset.univ_nonempty

theorem symbioticCurvature_gt_one {n : Nat} (hn : 0 < n)
    (Scoupled Sisolated : Fin n -> Real) (info : Fin n -> Fin n -> Real) (gamma : Real)
    (hSiso : forall i, 0 < Sisolated i)
    (hEnhance : forall i, Sisolated i < Scoupled i)
    (hinfo : forall i j, 0 <= info i j) (hgamma : 0 <= gamma) :
    1 < symbioticCurvature n Scoupled Sisolated info gamma := by
  haveI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn
  have hnpos : (0:Real) < (n:Real) := by exact_mod_cast hn
  have hpos_inv : 0 < 1 / (n:Real) := div_pos one_pos hnpos
  have hterm_gt : forall i, (1:Real) < (Scoupled i / Sisolated i) *
      (1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j) := by
    intro i
    have hratio_gt : 1 < Scoupled i / Sisolated i := by
      rw [lt_div_iff₀ (hSiso i)]
      linarith [hEnhance i]
    have hsum_nonneg : 0 <= ∑ j ∈ Finset.univ.erase i, info i j :=
      Finset.sum_nonneg (fun j _ => hinfo i j)
    have hratio_pos : 0 < Scoupled i / Sisolated i := lt_trans one_pos hratio_gt
    have hfactor_ge : (1:Real) <= 1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j := by
      have := mul_nonneg hgamma hsum_nonneg
      linarith
    have hstep := le_mul_of_one_le_right hratio_pos.le hfactor_ge
    exact lt_of_lt_of_le hratio_gt hstep
  have hsum_gt : (∑ _i : Fin n, (1:Real)) < ∑ i, (Scoupled i / Sisolated i) *
      (1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j) :=
    Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty (fun i _ => hterm_gt i)
  have hconst : (∑ _i : Fin n, (1:Real)) = (n:Real) := by
    simp
  rw [hconst] at hsum_gt
  unfold symbioticCurvature
  calc (1:Real) = (n:Real) * (1/(n:Real)) := by field_simp
    _ < (∑ i, (Scoupled i / Sisolated i) *
        (1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j)) * (1/(n:Real)) :=
        mul_lt_mul_of_pos_right hsum_gt hpos_inv
    _ = (1/(n:Real)) * ∑ i, (Scoupled i / Sisolated i) *
        (1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j) := by ring

theorem symbioticCurvature_mono_info {n : Nat}
    (Scoupled Sisolated : Fin n -> Real) (info info' : Fin n -> Fin n -> Real) (gamma : Real)
    (hSiso : forall i, 0 < Sisolated i) (hScoupled : forall i, 0 <= Scoupled i)
    (hgamma : 0 <= gamma) (hle : forall i j, info i j <= info' i j) :
    symbioticCurvature n Scoupled Sisolated info gamma <=
      symbioticCurvature n Scoupled Sisolated info' gamma := by
  unfold symbioticCurvature
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Finset.sum_le_sum
  intro i _
  have hratio_nonneg : 0 <= Scoupled i / Sisolated i := div_nonneg (hScoupled i) (hSiso i).le
  have hsum_le : ∑ j ∈ Finset.univ.erase i, info i j <= ∑ j ∈ Finset.univ.erase i, info' i j :=
    Finset.sum_le_sum (fun j _ => hle i j)
  have hfactor_le : (1 + gamma * ∑ j ∈ Finset.univ.erase i, info i j) <=
      (1 + gamma * ∑ j ∈ Finset.univ.erase i, info' i j) := by
    have := mul_le_mul_of_nonneg_left hsum_le hgamma
    linarith
  exact mul_le_mul_of_nonneg_left hfactor_le hratio_nonneg

/-- The abstract convex-combination fact underlying subadditivity
(clause 4 of theorem:bk3_properties_of_symbiotic_curvature): a weighted
average of two reals with nonnegative weights summing to 1 never exceeds
their max. This is the mediant-style core of "curvature of a disjoint
union is a weighted average of the two groups' curvatures, hence bounded
by their max"; the full derivation from the sum-over-two-disjoint-
index-sets curvature formula is not carried out here. -/
theorem weighted_avg_le_max (a b x y : Real) (ha : 0 <= a) (hb : 0 <= b)
    (hab : a + b = 1) :
    a * x + b * y <= max x y := by
  rcases le_total x y with h | h
  · rw [max_eq_right h]
    have hxy : a * x <= a * y := mul_le_mul_of_nonneg_left h ha
    have hb' : b = 1 - a := by linarith
    rw [hb']
    nlinarith [hxy]
  · rw [max_eq_left h]
    have hyx : b * y <= b * x := mul_le_mul_of_nonneg_left h hb
    have ha' : a = 1 - b := by linarith
    rw [ha']
    nlinarith [hyx]

/- ================================================================
   definition:bk3_perturbation_response_function,
   theorem:bk3_symbiotic_curvature_and_resilience
   ================================================================ -/

/-- Perturbation response ratio (definition:bk3_perturbation_response_function). -/
noncomputable def perturbationResponse (deltaS delta : Real) : Real := deltaS / delta

/-- Resilience bound is antitone in symbiotic curvature
(theorem:bk3_symbiotic_curvature_and_resilience): the honest static kernel
of "higher curvature correlates with enhanced resilience" is that the
bound `C / kappa_symb` is a decreasing function of `kappa_symb` for fixed
`C > 0`. The limiting behaviour of `R(delta,t)` as `t -> infinity` is not
modeled. -/
theorem resilience_bound_antitone {C kappa1 kappa2 : Real}
    (hC : 0 < C) (hk1 : 0 < kappa1) (hk : kappa1 <= kappa2) :
    C / kappa2 <= C / kappa1 := by
  have hk2 : 0 < kappa2 := lt_of_lt_of_le hk1 hk
  rw [div_le_div_iff₀ hk2 hk1]
  exact mul_le_mul_of_nonneg_left hk hC.le

/- ================================================================
   theorem:bk3_evolution_of_symbolic_knowledge,
   corollary:bk3_integrated_knowledge_structure,
   theorem:bk3_conditions_sustained_symbolic_growth
   ================================================================ -/

/-- Knowledge rate law (theorem:bk3_evolution_of_symbolic_knowledge), kept as
data: the rate equation `dK/dr = I' - D' + R` is a modeling commitment, not
a derived fact. -/
structure KnowledgeRateLaw where
  dK : Real
  integrationRate : Real
  differentiationRate : Real
  higherOrder : Real
  rateLaw : dK = integrationRate - differentiationRate + higherOrder

theorem integration_rate_eq (k : KnowledgeRateLaw) :
    k.integrationRate = k.dK + k.differentiationRate - k.higherOrder := by
  linarith [k.rateLaw]

/-- Discrete telescoping analogue of corollary:bk3_integrated_knowledge_structure:
if the knowledge structure advances by increment `Delta i` at each
refinement step `i`, the accumulated value after `n` steps is the initial
value plus the sum of increments. Proved by induction; the discrete
analogue of the fundamental theorem of calculus used in the continuous
statement. -/
theorem knowledge_structure_telescopes (K Delta : Nat -> Real)
    (hstep : forall i, K (i + 1) = K i + Delta i) (n : Nat) :
    K n = K 0 + ∑ i ∈ Finset.range n, Delta i := by
  induction n with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, hstep k, ih]
      ring

/-- Sustained growth window condition
(theorem:bk3_conditions_sustained_symbolic_growth): if the net
integration-minus-differentiation increments sum to a positive value over
a window of length `T` starting at `r0`, the accumulated knowledge
structure strictly increases across that window. -/
theorem sustained_growth_window (K Delta : Nat -> Real)
    (hstep : forall i, K (i + 1) = K i + Delta i)
    (r0 T : Nat)
    (hgrowth : 0 < ∑ i ∈ Finset.range T, Delta (r0 + i)) :
    K r0 < K (r0 + T) := by
  have hshift : forall n, K (r0 + n) = K r0 + ∑ i ∈ Finset.range n, Delta (r0 + i) := by
    intro n
    induction n with
    | zero => simp
    | succ k ih =>
        rw [Finset.sum_range_succ]
        have hrw : r0 + (k + 1) = (r0 + k) + 1 := by ring
        rw [hrw, hstep (r0 + k), ih]
        ring
  rw [hshift T]
  linarith [hgrowth]

/- ================================================================
   definition:bk3_compressed_relational_structure,
   definition:bk3_symbolic_network
   ================================================================ -/

/-- Compression operator scaffold (definition:bk3_compressed_relational_structure):
a map from subsets of the membrane to a space of compressed structures. No
theorem content beyond the type; the topological/dynamical preservation
properties are not modeled. -/
def CompressionOperator (X Sigma : Type) := Set X -> Sigma

/-- Symbolic network scaffold (definition:bk3_symbolic_network): a finite
structure of compressed nodes with edges and a nonnegative global stability
functional. -/
structure SymbolicNetwork (n : Nat) (Sigma : Type) where
  nodes : Fin n -> Sigma
  edge : Fin n -> Fin n -> Prop
  globalStability : Real
  globalStability_nonneg : 0 <= globalStability

/- ================================================================
   definition:bk3_symbolic_metabolic_rate
   ================================================================ -/

/-- Discrete finite analogue of the symbolic metabolic rate
(definition:bk3_symbolic_metabolic_rate): a finite sum of nonnegative flux
contributions indexed by membrane pairs, replacing the continuous double
integral over the manifold measure. -/
def metabolicRate {n : Nat} (flux : Fin n -> Fin n -> Real) : Real :=
  ∑ i, ∑ j, flux i j

theorem metabolicRate_nonneg {n : Nat} (flux : Fin n -> Fin n -> Real)
    (hflux : forall i j, 0 <= flux i j) :
    0 <= metabolicRate flux := by
  unfold metabolicRate
  apply Finset.sum_nonneg
  intro i _
  apply Finset.sum_nonneg
  intro j _
  exact hflux i j

/- ================================================================
   definition:bk3_symbolic_homeostasis, theorem:bk3_homeostatic_reflexes
   ================================================================ -/

/-- Homeostatic operating band (definition:bk3_symbolic_homeostasis). -/
def Homeostatic (rmeta rmin rmax : Real) : Prop :=
  rmin <= rmeta ∧ rmeta <= rmax

theorem homeostatic_band_nonempty {rmeta rmin rmax : Real}
    (h : Homeostatic rmeta rmin rmax) : rmin <= rmax :=
  le_trans h.1 h.2

/-- Lipschitz metabolic response (theorem:bk3_homeostatic_reflexes): the
derivative bound `|dR_meta/dDelta| <= C` is kept as a Lipschitz condition
on the response function, from which a two-sided deviation bound from a
baseline follows. -/
structure LipschitzMetabolicResponse where
  response : Real -> Real
  C : Real
  C_nonneg : 0 <= C
  lipschitz : forall d1 d2, |response d2 - response d1| <= C * |d2 - d1|

theorem metabolic_response_deviation_bound (r : LipschitzMetabolicResponse) (delta : Real) :
    r.response 0 - r.C * |delta| <= r.response delta ∧
      r.response delta <= r.response 0 + r.C * |delta| := by
  have h := r.lipschitz 0 delta
  simp only [sub_zero] at h
  have hab := abs_le.mp h
  constructor
  · linarith [hab.1]
  · linarith [hab.2]

/- ================================================================
   theorem:bk3_criteria_persistent_symbolic_life
   ================================================================ -/

/-- Persistent symbolic life criteria
(theorem:bk3_criteria_persistent_symbolic_life), assembled from the three
already-formalized conditions: a homeostatic metabolic rate, a positive
growth increment over some window, and symbiotic curvature bounded away
from zero. -/
structure PersistentLife where
  rmeta : Real
  rmin : Real
  rmax : Real
  homeostatic : Homeostatic rmeta rmin rmax
  growthIncrement : Real
  growth_pos : 0 < growthIncrement
  kappaSymb : Real
  kappaFloor : Real
  kappaFloor_pos : 0 < kappaFloor
  kappa_above_floor : kappaFloor <= kappaSymb

theorem persistentLife_kappa_pos (p : PersistentLife) : 0 < p.kappaSymb :=
  lt_of_lt_of_le p.kappaFloor_pos p.kappa_above_floor

theorem persistentLife_rmin_le_rmax (p : PersistentLife) : p.rmin <= p.rmax :=
  homeostatic_band_nonempty p.homeostatic

end ForcingAnalysis.Book3
