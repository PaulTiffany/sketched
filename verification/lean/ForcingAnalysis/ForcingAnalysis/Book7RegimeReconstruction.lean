/- Book7RegimeReconstruction.lean — latent conflict, bounded regime estimate,
   and the independent observer reintegration residue. -/
import ForcingAnalysis.Book7QuadraticTrace

namespace ForcingAnalysis.Book7RegimeReconstruction

/-- A finite regime estimate records latent pairwise conflict, its observable
proxy, and a witnessed pair attaining the conservative maximum `ρ̂`.
The maximizing witness avoids treating an unverified numerical maximization as
part of the theorem. -/
structure RegimeEstimate (Pair : Type*) where
  latent : Pair → ℝ
  observed : Pair → ℝ
  criticalPair : Pair
  critical_max : ∀ pair, observed pair ≤ observed criticalPair

/-- The paper's scalar screening statistic: the maximum observed pairwise
conflict, represented by its certified maximizing pair. -/
def RegimeEstimate.rhoHat {Pair : Type*} (R : RegimeEstimate Pair) : ℝ :=
  R.observed R.criticalPair

/-- Uniform observer reconstruction error. -/
def RegimeEstimate.ErrorBound {Pair : Type*}
    (R : RegimeEstimate Pair) (ε : ℝ) : Prop :=
  ∀ pair, |R.observed pair - R.latent pair| ≤ ε

/-- The latent conflict at the critical observed pair lies within the declared
observer error of `ρ̂`. -/
theorem RegimeEstimate.latent_critical_within_error
    {Pair : Type*} (R : RegimeEstimate Pair) {ε : ℝ}
    (herror : R.ErrorBound ε) :
    |R.rhoHat - R.latent R.criticalPair| ≤ ε :=
  herror R.criticalPair

/-- A low-regime routing decision is sound when its margin exceeds observer
error. -/
theorem RegimeEstimate.latent_critical_lt_of_rhoHat_margin
    {Pair : Type*} (R : RegimeEstimate Pair) {ε threshold : ℝ}
    (herror : R.ErrorBound ε) (hmargin : R.rhoHat + ε < threshold) :
    R.latent R.criticalPair < threshold := by
  have habs := herror R.criticalPair
  have hneg : -ε ≤ -|R.rhoHat - R.latent R.criticalPair| := neg_le_neg habs
  have hlower : -ε ≤ R.rhoHat - R.latent R.criticalPair :=
    hneg.trans (neg_abs_le _)
  linarith

/-- A high-regime routing decision is sound when its margin exceeds observer
error. -/
theorem RegimeEstimate.lt_latent_critical_of_margin
    {Pair : Type*} (R : RegimeEstimate Pair) {ε threshold : ℝ}
    (herror : R.ErrorBound ε) (hmargin : threshold < R.rhoHat - ε) :
    threshold < R.latent R.criticalPair := by
  have habs := herror R.criticalPair
  have hupper : R.rhoHat - R.latent R.criticalPair ≤ ε :=
    (le_abs_self (R.rhoHat - R.latent R.criticalPair)).trans habs
  linarith

/-- Screening is not identification: the same `ρ̂` and maximizing certificate
can coexist with different latent conflict geometries. -/
theorem same_rhoHat_does_not_identify_latent :
    ∃ first second : RegimeEstimate Bool,
      first.rhoHat = second.rhoHat ∧ first.latent ≠ second.latent := by
  let observed : Bool → ℝ := fun _ => 1 / 2
  let first : RegimeEstimate Bool := {
    latent := fun _ => 0
    observed := observed
    criticalPair := false
    critical_max := by intro pair; rfl
  }
  let second : RegimeEstimate Bool := {
    latent := fun pair => if pair then 1 else 0
    observed := observed
    criticalPair := false
    critical_max := by intro pair; rfl
  }
  refine ⟨first, second, rfl, ?_⟩
  intro h
  have := congrFun h true
  norm_num [first, second] at this

/-- `ρ_O` belongs to the integration/reintegration interface, not to the
collapse-screening estimator. -/
structure ObserverReintegration (Pair : Type*) where
  regime : RegimeEstimate Pair
  rhoO : ℝ

/-- Even a fully fixed regime estimator does not determine reintegration
residue: collapse screening and bounded integration residue are different
observer-relative channels. -/
theorem regime_does_not_determine_rhoO :
    ∃ first second : ObserverReintegration Bool,
      first.regime = second.regime ∧ first.rhoO ≠ second.rhoO := by
  let regime : RegimeEstimate Bool := {
    latent := fun _ => 0
    observed := fun _ => 0
    criticalPair := false
    critical_max := by intro pair; rfl
  }
  exact ⟨⟨regime, 0⟩, ⟨regime, 1⟩, rfl, by norm_num⟩


/-- Re-express latent and observed conflict through an order isomorphism. This
changes metric coordinates while preserving their complete ordinal content. -/
def RegimeEstimate.reframe {Pair : Type*}
    (R : RegimeEstimate Pair) (e : ℝ ≃o ℝ) : RegimeEstimate Pair where
  latent := fun pair => e (R.latent pair)
  observed := fun pair => e (R.observed pair)
  criticalPair := R.criticalPair
  critical_max := by
    intro pair
    exact e.monotone (R.critical_max pair)

/-- The regime statistic transforms equivariantly under an ordinal reframing. -/
theorem RegimeEstimate.reframe_rhoHat
    {Pair : Type*} (R : RegimeEstimate Pair) (e : ℝ ≃o ℝ) :
    (R.reframe e).rhoHat = e R.rhoHat := rfl

/-- Every observed pair ranking survives an order-isomorphic change of
coordinates. -/
theorem RegimeEstimate.reframe_order_iff
    {Pair : Type*} (R : RegimeEstimate Pair) (e : ℝ ≃o ℝ)
    (first second : Pair) :
    (R.reframe e).observed first ≤ (R.reframe e).observed second ↔
      R.observed first ≤ R.observed second := by
  exact e.le_iff_le

/-- Routing relative to a correspondingly transported threshold is ordinally
invariant; its numerical coordinate is not privileged. -/
theorem RegimeEstimate.reframe_threshold_iff
    {Pair : Type*} (R : RegimeEstimate Pair) (e : ℝ ≃o ℝ) (threshold : ℝ) :
    (R.reframe e).rhoHat < e threshold ↔ R.rhoHat < threshold := by
  rw [R.reframe_rhoHat]
  exact e.lt_iff_lt

/-- Ordinal geometry does not determine metric scale: two regime estimates can
rank every pair identically while assigning different numerical separations. -/
theorem ordinal_agreement_does_not_identify_scale :
    ∃ first second : RegimeEstimate Bool,
      (∀ i j, first.observed i ≤ first.observed j ↔
        second.observed i ≤ second.observed j) ∧
      first.observed ≠ second.observed := by
  let first : RegimeEstimate Bool := {
    latent := fun i => if i then 1 else 0
    observed := fun i => if i then 1 else 0
    criticalPair := true
    critical_max := by intro pair; cases pair <;> norm_num
  }
  let second : RegimeEstimate Bool := {
    latent := fun i => if i then 2 else 0
    observed := fun i => if i then 2 else 0
    criticalPair := true
    critical_max := by intro pair; cases pair <;> norm_num
  }
  refine ⟨first, second, ?_, ?_⟩
  · intro i j
    cases i <;> cases j <;> norm_num [first, second]
  · intro h
    have := congrFun h true
    norm_num [first, second] at this
end ForcingAnalysis.Book7RegimeReconstruction