/-
Book4ObserverGeometry.lean — coupled-update and stabilization kernel for
observer–geometry co-evolution in Principia Symbolica Book 4.
-/
import Mathlib
import Mathlib.Analysis.ODE.ExistUnique

namespace ForcingAnalysis.Book4ObserverGeometry

/-- A discrete coupled observer/geometry evolution law. Each update consumes
both current components, making the feedback dependence explicit. -/
structure CoupledSystem (Observer Geometry : Type*) where
  observerUpdate : Observer → Geometry → Observer
  geometryUpdate : Geometry → Observer → Geometry

def step {Observer Geometry : Type*} (sys : CoupledSystem Observer Geometry)
    (state : Observer × Geometry) : Observer × Geometry :=
  (sys.observerUpdate state.1 state.2,
   sys.geometryUpdate state.2 state.1)

def RecursivelyStabilized {Observer Geometry : Type*}
    (sys : CoupledSystem Observer Geometry) (state : Observer × Geometry) : Prop :=
  step sys state = state

theorem recursivelyStabilized_iff {Observer Geometry : Type*}
    (sys : CoupledSystem Observer Geometry) (state : Observer × Geometry) :
    RecursivelyStabilized sys state ↔
      sys.observerUpdate state.1 state.2 = state.1 ∧
      sys.geometryUpdate state.2 state.1 = state.2 := by
  simp [RecursivelyStabilized, step, Prod.ext_iff]

/-- For any observer/geometry state there exists a genuinely coupled interface
with that state stabilized: the identity feedback system. -/
theorem exists_recursively_stabilized_system
    {Observer Geometry : Type*} (state : Observer × Geometry) :
    ∃ sys : CoupledSystem Observer Geometry, RecursivelyStabilized sys state := by
  refine ⟨{ observerUpdate := fun observer _ => observer
            geometryUpdate := fun geometry _ => geometry }, ?_⟩
  rfl

/-- Smooth-looking coupled evolution does not imply stabilization. The affine
translation system advances both coordinates forever. -/
def driftingSystem : CoupledSystem ℝ ℝ where
  observerUpdate := fun observer _ => observer + 1
  geometryUpdate := fun geometry _ => geometry + 1

theorem driftingSystem_has_no_stabilized_state :
    ¬ ∃ state : ℝ × ℝ, RecursivelyStabilized driftingSystem state := by
  rintro ⟨state, h⟩
  have hObserver := (recursivelyStabilized_iff driftingSystem state).1 h |>.1
  simp [driftingSystem] at hObserver

/-! ### Continuous-time co-evolution kernel -/

/-- A coupled continuous-time vector field. Both component velocities consume
both components of the current observer--geometry state. -/
structure CoupledVectorField (Observer Geometry : Type*) where
  observerVelocity : Observer → Geometry → Observer
  geometryVelocity : Geometry → Observer → Geometry

/-- The product-space vector field determined by the coupled components. -/
def vectorField {Observer Geometry : Type*}
    (sys : CoupledVectorField Observer Geometry)
    (state : Observer × Geometry) : Observer × Geometry :=
  (sys.observerVelocity state.1 state.2,
   sys.geometryVelocity state.2 state.1)

/-- Continuous recursive stabilization is joint equilibrium of the coupled
vector field, not merely existence of a local trajectory. -/
def JointEquilibrium {Observer Geometry : Type*}
    [Zero Observer] [Zero Geometry]
    (sys : CoupledVectorField Observer Geometry)
    (state : Observer × Geometry) : Prop :=
  vectorField sys state = 0

 theorem jointEquilibrium_iff {Observer Geometry : Type*}
    [Zero Observer] [Zero Geometry]
    (sys : CoupledVectorField Observer Geometry)
    (state : Observer × Geometry) :
    JointEquilibrium sys state ↔
      sys.observerVelocity state.1 state.2 = 0 ∧
      sys.geometryVelocity state.2 state.1 = 0 := by
  simp [JointEquilibrium, vectorField, Prod.ext_iff]

/-- The constant path through a supplied joint equilibrium. -/
def constantTrajectory {State : Type*} (state : State) : ℝ → State :=
  fun _ => state

/-- A supplied joint equilibrium yields an actual constant solution of the
coupled differential equation. This is weaker than attraction and does not
claim that a joint equilibrium follows from local Lipschitz regularity. -/
theorem equilibrium_constantTrajectory_solves
    {Observer Geometry : Type*}
    [NormedAddCommGroup Observer] [NormedSpace ℝ Observer]
    [NormedAddCommGroup Geometry] [NormedSpace ℝ Geometry]
    (sys : CoupledVectorField Observer Geometry)
    (state : Observer × Geometry) (hEq : JointEquilibrium sys state) (t : ℝ) :
    HasDerivAt (fun _ : ℝ => state) (vectorField sys state) t := by
  change vectorField sys state = 0 at hEq
  rw [hEq]
  exact hasDerivAt_const (x := t) (c := state)

/-- A locally Lipschitz coupled field supplies the quantitative certificate
required by Picard--Lindelöf after shrinking to a closed spatial ball and a
compatible positive time interval. -/
theorem exists_picardLindelof_certificate_of_locallyLipschitz
    {Observer Geometry : Type*}
    [NormedAddCommGroup Observer] [NormedSpace ℝ Observer]
    [NormedAddCommGroup Geometry] [NormedSpace ℝ Geometry]
    (sys : CoupledVectorField Observer Geometry)
    (hlocal : LocallyLipschitz (vectorField sys))
    (state : Observer × Geometry) :
    ∃ (ε : ℝ) (hε : 0 < ε) (a L K : NNReal),
      ∀ t₀ : ℝ, IsPicardLindelof (fun _ => vectorField sys)
        (tmin := t₀ - ε) (tmax := t₀ + ε)
        ⟨t₀, by simp [le_of_lt hε]⟩ state a 0 L K := by
  obtain ⟨K, s, hs, hLip⟩ := hlocal state
  obtain ⟨radius, hradius : 0 < radius, hball⟩ := Metric.mem_nhds_iff.mp hs
  set bound := K * radius + ‖vectorField sys state‖ + 1 with hbound
  have hbound_pos : 0 < bound := by positivity
  have hnorm (x : Observer × Geometry)
      (hx : x ∈ Metric.closedBall state (radius / 2)) :
      ‖vectorField sys x‖ ≤ bound := by
    rw [hbound]
    calc
      ‖vectorField sys x‖ ≤
          ‖vectorField sys x - vectorField sys state‖ +
            ‖vectorField sys state‖ := norm_le_norm_sub_add _ _
      _ ≤ K * ‖x - state‖ + ‖vectorField sys state‖ := by
        gcongr
        apply hLip.norm_sub_le _ (mem_of_mem_nhds hs)
        apply Set.Subset.trans _ hball hx
        exact Metric.closedBall_subset_ball (half_lt_self hradius)
      _ ≤ K * radius + ‖vectorField sys state‖ := by
        gcongr
        rw [← mem_closedBall_iff_norm]
        exact Metric.closedBall_subset_closedBall
          (half_le_self (le_of_lt hradius)) hx
      _ ≤ bound := le_add_of_nonneg_right zero_le_one
  let ε := radius / bound / 2 / 2
  have hε : 0 < ε := by positivity
  let spatialRadius : NNReal := ⟨radius / 2, (half_pos hradius).le⟩
  let velocityBound : NNReal := ⟨bound, hbound_pos.le⟩
  refine ⟨ε, hε, spatialRadius, velocityBound, K, ?_⟩
  intro t₀
  have hSpatial : (spatialRadius : ℝ) = radius / 2 := rfl
  have hVelocity : (velocityBound : ℝ) = bound := rfl
  apply IsPicardLindelof.of_time_independent
    (fun x hx => by
      change dist x state ≤ (spatialRadius : ℝ) at hx
      change ‖vectorField sys x‖ ≤ (velocityBound : ℝ)
      rw [hSpatial] at hx
      rw [hVelocity]
      exact hnorm x hx)
    (hLip.mono (Set.Subset.trans
      (Metric.closedBall_subset_ball (half_lt_self hradius)) hball))
  change (velocityBound : ℝ) *
      max ((t₀ + ε) - t₀) (t₀ - (t₀ - ε)) ≤
      (spatialRadius : ℝ) - 0
  rw [hVelocity, hSpatial]
  simp [ε, field]

/-- Source-level local evolution theorem: on finite-dimensional observer and
geometry spaces, local Lipschitz regularity of the coupled field yields a
positive interval and a trajectory through every supplied initial state. -/
theorem locallyLipschitz_finiteDimensional_local_existence
    {Observer Geometry : Type*}
    [NormedAddCommGroup Observer] [NormedSpace ℝ Observer]
    [NormedAddCommGroup Geometry] [NormedSpace ℝ Geometry]
    [FiniteDimensional ℝ Observer] [FiniteDimensional ℝ Geometry]
    (sys : CoupledVectorField Observer Geometry)
    (hlocal : LocallyLipschitz (vectorField sys))
    (state : Observer × Geometry) (t₀ : ℝ) :
    ∃ ε : ℝ, 0 < ε ∧ ∃ trajectory : ℝ → Observer × Geometry,
      trajectory t₀ = state ∧
      ∀ t ∈ Set.Ioo (t₀ - ε) (t₀ + ε),
        HasDerivAt trajectory (vectorField sys (trajectory t)) t := by
  letI : CompleteSpace Observer := FiniteDimensional.complete ℝ Observer
  letI : CompleteSpace Geometry := FiniteDimensional.complete ℝ Geometry
  obtain ⟨ε, hε, a, L, K, hPL⟩ :=
    exists_picardLindelof_certificate_of_locallyLipschitz sys hlocal state
  have hcert := hPL t₀
  obtain ⟨trajectory, hinit, hsol⟩ :=
    hcert.exists_eq_forall_mem_Icc_hasDerivWithinAt₀
  refine ⟨ε, hε, trajectory, hinit, ?_⟩
  intro t ht
  exact (hsol t (Set.Ioo_subset_Icc_self ht)).hasDerivAt
    (Icc_mem_nhds ht.1 ht.2)
/-- Actual Picard--Lindelöf local existence for the coupled product field.
The certificate records the spatial Lipschitz bound, time continuity, norm
bound, and interval/radius compatibility used by mathlib's theorem. -/
theorem picardLindelof_local_existence
    {Observer Geometry : Type*}
    [NormedAddCommGroup Observer] [NormedSpace ℝ Observer]
    [NormedAddCommGroup Geometry] [NormedSpace ℝ Geometry]
    [CompleteSpace Observer] [CompleteSpace Geometry]
    (sys : CoupledVectorField Observer Geometry)
    {tmin tmax : ℝ} (t₀ : Set.Icc tmin tmax)
    (state : Observer × Geometry) {a L K : NNReal}
    (hPL : IsPicardLindelof (fun _ => vectorField sys)
      t₀ state a 0 L K) :
    ∃ trajectory : ℝ → Observer × Geometry,
      trajectory t₀ = state ∧
      ∀ t ∈ Set.Icc tmin tmax,
        HasDerivWithinAt trajectory
          (vectorField sys (trajectory t)) (Set.Icc tmin tmax) t := by
  exact hPL.exists_eq_forall_mem_Icc_hasDerivWithinAt₀

/-- Picard--Lindelöf uniqueness on the certified interval for two solutions
that stay in the spatial ball covered by the local Lipschitz certificate. -/
theorem picardLindelof_local_uniqueness
    {Observer Geometry : Type*}
    [NormedAddCommGroup Observer] [NormedSpace ℝ Observer]
    [NormedAddCommGroup Geometry] [NormedSpace ℝ Geometry]
    (sys : CoupledVectorField Observer Geometry)
    {tmin tmax : ℝ} (t₀ : Set.Icc tmin tmax)
    (state : Observer × Geometry) {a L K : NNReal}
    (hPL : IsPicardLindelof (fun _ => vectorField sys)
      t₀ state a 0 L K)
    (ht₀ : (t₀ : ℝ) ∈ Set.Ioo tmin tmax)
    {trajectory₁ trajectory₂ : ℝ → Observer × Geometry}
    (hcont₁ : ContinuousOn trajectory₁ (Set.Icc tmin tmax))
    (hsol₁ : ∀ t ∈ Set.Ioo tmin tmax,
      HasDerivAt trajectory₁ (vectorField sys (trajectory₁ t)) t)
    (hball₁ : ∀ t ∈ Set.Ioo tmin tmax,
      trajectory₁ t ∈ Metric.closedBall state a)
    (hcont₂ : ContinuousOn trajectory₂ (Set.Icc tmin tmax))
    (hsol₂ : ∀ t ∈ Set.Ioo tmin tmax,
      HasDerivAt trajectory₂ (vectorField sys (trajectory₂ t)) t)
    (hball₂ : ∀ t ∈ Set.Ioo tmin tmax,
      trajectory₂ t ∈ Metric.closedBall state a)
    (hinit : trajectory₁ t₀ = trajectory₂ t₀) :
    Set.EqOn trajectory₁ trajectory₂ (Set.Icc tmin tmax) := by
  exact ODE_solution_unique_of_mem_Icc
    (fun t ht => hPL.lipschitzOnWith t (Set.Ioo_subset_Icc_self ht))
    ht₀ hcont₁ hsol₁ hball₁ hcont₂ hsol₂ hball₂ hinit
/-- Quantitative attraction data for a coupled observer--geometry trajectory.
The certificate does not follow from local well-posedness: it separately names
an equilibrium, a nonnegative joint error, and a strict geometric rate. -/
structure CoupledAttractionCertificate (Observer Geometry : Type*) where
  trajectory : ℕ → Observer × Geometry
  equilibrium : Observer × Geometry
  jointError : Observer × Geometry → ℝ
  rate : ℝ
  rate_nonneg : 0 ≤ rate
  rate_lt_one : rate < 1
  error_nonneg : ∀ state, 0 ≤ jointError state
  contracts : ∀ n, jointError (trajectory (n + 1)) ≤
    rate * jointError (trajectory n)

/-- A supplied coupled contraction certificate forces the joint observer--
geometry error to vanish. This is the attraction machinery deliberately kept
separate from Picard--Lindelöf local existence. -/
theorem CoupledAttractionCertificate.jointError_tendsto_zero
    {Observer Geometry : Type*}
    (C : CoupledAttractionCertificate Observer Geometry) :
    Filter.Tendsto (fun n => C.jointError (C.trajectory n))
      Filter.atTop (nhds 0) := by
  have hbound : ∀ n, C.jointError (C.trajectory n) ≤
      C.jointError (C.trajectory 0) * C.rate ^ n := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
        calc
          C.jointError (C.trajectory (n + 1)) ≤
              C.rate * C.jointError (C.trajectory n) := C.contracts n
          _ ≤ C.rate * (C.jointError (C.trajectory 0) * C.rate ^ n) :=
              mul_le_mul_of_nonneg_left ih C.rate_nonneg
          _ = C.jointError (C.trajectory 0) * C.rate ^ (n + 1) := by ring
  have hrate : Filter.Tendsto (fun n : ℕ => C.rate ^ n)
      Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one
      (by rw [abs_of_nonneg C.rate_nonneg]; exact C.rate_lt_one)
  have hupper : Filter.Tendsto
      (fun n : ℕ => C.jointError (C.trajectory 0) * C.rate ^ n)
      Filter.atTop (nhds 0) := by
    simpa using hrate.const_mul (C.jointError (C.trajectory 0))
  exact squeeze_zero (fun n => C.error_nonneg (C.trajectory n)) hbound hupper
/-- Regular continuous evolution alone still need not supply equilibrium: the
constant nonzero product vector field has no zero. -/
def translatingVectorField : CoupledVectorField ℝ ℝ where
  observerVelocity := fun _ _ => 1
  geometryVelocity := fun _ _ => 1

 theorem translatingVectorField_has_no_jointEquilibrium :
    ¬ ∃ state : ℝ × ℝ, JointEquilibrium translatingVectorField state := by
  rintro ⟨state, h⟩
  have hObserver :=
    (jointEquilibrium_iff translatingVectorField state).1 h |>.1
  norm_num [translatingVectorField] at hObserver
end ForcingAnalysis.Book4ObserverGeometry
