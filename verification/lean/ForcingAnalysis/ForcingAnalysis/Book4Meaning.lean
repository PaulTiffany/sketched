/-
Book4Meaning.lean — the finite value-map kernel and dependency audit for
Principia Symbolica Book 4's "Emergence of Meaning" corollary.
-/
import ForcingAnalysis.Book4B

namespace ForcingAnalysis.Book4Meaning

/-- Meaning value as contrast from a supplied free-energy ceiling. -/
def meaningValue {U : Type*} (ceiling : ℝ) (freeEnergy : U → ℝ) (u : U) : ℝ :=
  ceiling - freeEnergy u

theorem meaningValue_nonneg {U : Type*} (ceiling : ℝ) (freeEnergy : U → ℝ)
    (hCeiling : ∀ u, freeEnergy u ≤ ceiling) (u : U) :
    0 ≤ meaningValue ceiling freeEnergy u := by
  unfold meaningValue
  linarith [hCeiling u]

theorem meaningValue_pos_iff {U : Type*} (ceiling : ℝ)
    (freeEnergy : U → ℝ) (u : U) :
    0 < meaningValue ceiling freeEnergy u ↔ freeEnergy u < ceiling := by
  constructor <;> intro h
  · unfold meaningValue at h
    linarith
  · unfold meaningValue
    linarith

/-- The value map is nontrivial exactly when some configuration lies below
the supplied energy ceiling. -/
theorem exists_positive_meaning_iff {U : Type*} (ceiling : ℝ)
    (freeEnergy : U → ℝ) :
    (∃ u, 0 < meaningValue ceiling freeEnergy u) ↔
      ∃ u, freeEnergy u < ceiling := by
  simp only [meaningValue_pos_iff]

/-- Meaning preference reverses free-energy order, as claimed by the source's
"preferential flows" interpretation. -/
theorem meaningValue_strict_preference_iff {U : Type*} (ceiling : ℝ)
    (freeEnergy : U → ℝ) (u v : U) :
    meaningValue ceiling freeEnergy u > meaningValue ceiling freeEnergy v ↔
      freeEnergy u < freeEnergy v := by
  constructor <;> intro h
  · unfold meaningValue at h
    linarith
  · unfold meaningValue
    linarith

/-- The prior freedom-life transition does not, by itself, make an unrelated
free-energy landscape nonconstant. This is the missing bridge in Step 1 of
the printed proof. -/
theorem freedomLifeTransition_does_not_force_nonconstant_energy :
    ∃ _t : Book4B.FreedomLifeTransition,
      ∃ freeEnergy : Bool → ℝ,
        (∀ u, freeEnergy u = 0) ∧ ¬ ∃ u v, freeEnergy u ≠ freeEnergy v := by
  let t : Book4B.FreedomLifeTransition :=
    { Ffree := fun n => (n : ℝ)
      deltaF := 1
      deltaF_pos := by norm_num
      increasing := by
        intro k
        norm_num
      Ffrag := 0
      epsMax := 1
      Ffrag_bounded := by norm_num }
  refine ⟨t, fun _ => 0, ?_, ?_⟩
  · intro u
    rfl
  · rintro ⟨u, v, h⟩
    exact h rfl


/-- An identity-relative energetic domain. Accessibility is part of the data:
a configuration outside an identity's accessible region is not assigned value by
this energetic construction merely because its energy can be evaluated. -/
structure MeaningDomain (U I : Type*) where
  freeEnergy : I → U → ℝ
  accessible : I → U → Prop
  ceiling : I → ℝ
  ceilingAttained : ∀ i, ∃ u, accessible i u ∧ freeEnergy i u = ceiling i
  energy_le_ceiling : ∀ i u, accessible i u → freeEnergy i u ≤ ceiling i
  nontrivial : ∀ i, ∃ u, accessible i u ∧ freeEnergy i u < ceiling i

/-- The source's value map, now retaining its identity argument and its
accessible-domain premise. -/
def identityMeaning {U I : Type*} (D : MeaningDomain U I) (u : U) (i : I) : ℝ :=
  D.ceiling i - D.freeEnergy i u

theorem identityMeaning_nonneg_on_accessible {U I : Type*}
    (D : MeaningDomain U I) {u : U} {i : I} (hu : D.accessible i u) :
    0 ≤ identityMeaning D u i := by
  unfold identityMeaning
  linarith [D.energy_le_ceiling i u hu]

theorem identityMeaning_pos_iff_on_accessible {U I : Type*}
    (D : MeaningDomain U I) {u : U} {i : I} (_hu : D.accessible i u) :
    0 < identityMeaning D u i ↔ D.freeEnergy i u < D.ceiling i := by
  unfold identityMeaning
  constructor <;> intro h <;> linarith

theorem identityMeaning_is_nontrivial {U I : Type*} (D : MeaningDomain U I)
    (i : I) :
    ∃ u, D.accessible i u ∧ 0 < identityMeaning D u i := by
  obtain ⟨u, hu, hlt⟩ := D.nontrivial i
  exact ⟨u, hu, (identityMeaning_pos_iff_on_accessible D hu).2 hlt⟩

theorem identityMeaning_ceiling_witness_has_zero_value {U I : Type*}
    (D : MeaningDomain U I) (i : I) :
    ∃ u, D.accessible i u ∧ identityMeaning D u i = 0 := by
  obtain ⟨u, hu, heq⟩ := D.ceilingAttained i
  refine ⟨u, hu, ?_⟩
  unfold identityMeaning
  linarith

/-- Lower accessible free energy induces greater energetic value. This is an
order theorem, not yet an interpretation, action, or learning theorem. -/
theorem identityMeaning_strict_preference_iff {U I : Type*}
    (D : MeaningDomain U I) (i : I) (u v : U) :
    identityMeaning D u i > identityMeaning D v i ↔
      D.freeEnergy i u < D.freeEnergy i v := by
  unfold identityMeaning
  constructor <;> intro h <;> linarith

/-- A preferential flow certificate keeps descent and convergence separate.
Neither differentiability nor a freedom threshold manufactures these fields. -/
structure PreferentialFlowCertificate {U I : Type*} [PseudoMetricSpace U]
    (D : MeaningDomain U I) (i : I) where
  trajectory : ℕ → U
  accessible : ∀ n, D.accessible i (trajectory n)
  energy_descent : ∀ n,
    D.freeEnergy i (trajectory (n + 1)) ≤ D.freeEnergy i (trajectory n)
  limit : U
  converges : Filter.Tendsto trajectory Filter.atTop (nhds limit)
  limit_local_minimum : IsLocalMin (D.freeEnergy i) limit

/-- Energy descent along a certified preferential flow is exactly monotone
increase of the induced energetic value. -/
theorem preferentialFlow_meaning_nondecreasing {U I : Type*}
    [PseudoMetricSpace U] (D : MeaningDomain U I) (i : I)
    (P : PreferentialFlowCertificate D i) (n : ℕ) :
    identityMeaning D (P.trajectory n) i ≤
      identityMeaning D (P.trajectory (n + 1)) i := by
  unfold identityMeaning
  linarith [P.energy_descent n]
/-- The missing source bridge is explicit data: a freedom/life transition and
an identity-relative, nontrivial accessible energy domain are not identified. -/
structure MeaningGenerationBridge (U I : Type*) where
  transition : Book4B.FreedomLifeTransition
  domain : MeaningDomain U I

/-- Once the bridge is supplied, every represented identity has an accessible
configuration of positive energetic meaning. -/
theorem transition_with_bridge_generates_positive_meaning {U I : Type*}
    (B : MeaningGenerationBridge U I) (i : I) :
    ∃ u, B.domain.accessible i u ∧ 0 < identityMeaning B.domain u i :=
  identityMeaning_is_nontrivial B.domain i

/-- A typed interpretation layer over patterns and individuated identities.
The codomain is deliberately arbitrary: meaning is not definitionally ℝ. -/
structure InterpretiveSystem (U I V A : Type*) where
  interpret : U → I → V
  significant : I → V → Prop
  act : I → V → A

/-- An event is meaningful for an identity when its interpreted value satisfies
that identity's significance predicate. -/
def Meaningful {U I V A : Type*} (S : InterpretiveSystem U I V A)
    (u : U) (i : I) : Prop :=
  S.significant i (S.interpret u i)

/-- Interpretation retains a distinction at an identity. -/
def RetainsDistinction {U I V A : Type*} (S : InterpretiveSystem U I V A)
    (i : I) (u v : U) : Prop :=
  S.interpret u i ≠ S.interpret v i

/-- The retained distinction reaches embodied action. This is stronger than
mere interpretive separation and must not be silently inferred from it. -/
def ActionDistinguishes {U I V A : Type*} (S : InterpretiveSystem U I V A)
    (i : I) (u v : U) : Prop :=
  S.act i (S.interpret u i) ≠ S.act i (S.interpret v i)

/-- A constant action policy can erase a real interpretive distinction. -/
theorem retained_distinction_does_not_force_action_distinction :
    ∃ S : InterpretiveSystem Bool Unit Bool Unit,
      RetainsDistinction S () false true ∧
      ¬ ActionDistinguishes S () false true := by
  let S : InterpretiveSystem Bool Unit Bool Unit :=
    { interpret := fun u _ => u
      significant := fun _ _ => True
      act := fun _ _ => () }
  refine ⟨S, ?_, ?_⟩
  · simp [RetainsDistinction, S]
  · simp [ActionDistinguishes, S]

/-- Even a fixed interpretation map does not decide which interpreted values
matter to an identity; significance is an additional observer-relative layer. -/
theorem value_map_does_not_determine_significance :
    ∃ S T : InterpretiveSystem Unit Unit Unit Unit,
      S.interpret = T.interpret ∧ Meaningful S () () ∧ ¬ Meaningful T () () := by
  let S : InterpretiveSystem Unit Unit Unit Unit :=
    { interpret := fun _ _ => ()
      significant := fun _ _ => True
      act := fun _ _ => () }
  let T : InterpretiveSystem Unit Unit Unit Unit :=
    { interpret := fun _ _ => ()
      significant := fun _ _ => False
      act := fun _ _ => () }
  exact ⟨S, T, rfl, trivial, by simp [Meaningful, T]⟩

end ForcingAnalysis.Book4Meaning
