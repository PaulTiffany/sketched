/- Book4AssembledConnection.lean — pointwise connection gluing and transport. -/
import ForcingAnalysis.Book4Fuzzy
import ForcingAnalysis.Book4FuzzyConnection

namespace ForcingAnalysis.Book4AssembledConnection

variable {ι E : Type*} [Fintype ι] [DecidableEq ι]
  [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- Point-dependent local affine coefficients together with a finite partition
of unity. This is actual gluing data, not merely a family of charts. -/
structure PartitionedConnection (ι E : Type*) [Fintype ι] [DecidableEq ι]
    [NormedAddCommGroup E] [NormedSpace ℝ E] where
  localNabla : ι → E → E →L[ℝ] E →L[ℝ] E
  weight : ι → E → ℝ
  weight_nonneg : ∀ i x, 0 ≤ weight i x
  weight_sum_one : ∀ x, ∑ i, weight i x = 1

/-- Assemble the global connection coefficient at a point. -/
noncomputable def globalNablaAt (g : PartitionedConnection ι E) (x : E) :
    E →L[ℝ] E →L[ℝ] E :=
  ∑ i, g.weight i x • g.localNabla i x

theorem globalNablaAt_apply (g : PartitionedConnection ι E) (x X Y : E) :
    globalNablaAt g x X Y = ∑ i, g.weight i x • g.localNabla i x X Y := by
  simp [globalNablaAt]

/-- Agreement of all active local coefficients glues to the same global value. -/
theorem globalNablaAt_eq_of_local_eq (g : PartitionedConnection ι E)
    (x X Y value : E) (hlocal : ∀ i, g.localNabla i x X Y = value) :
    globalNablaAt g x X Y = value := by
  rw [globalNablaAt_apply]
  simp_rw [hlocal]
  rw [← Finset.sum_smul]
  simp [g.weight_sum_one x]

/-- Zero-bracket torsion of the assembled pointwise connection. -/
noncomputable def assembledTorsionAt
    (g : PartitionedConnection ι E) (x X Y : E) : E :=
  globalNablaAt g x X Y - globalNablaAt g x Y X

/-- Local symmetry glues to global torsion-freeness at every point. -/
theorem assembledTorsionAt_eq_zero_of_local_symmetric
    (g : PartitionedConnection ι E)
    (hsymm : ∀ i x X Y, g.localNabla i x X Y = g.localNabla i x Y X)
    (x X Y : E) : assembledTorsionAt g x X Y = 0 := by
  have h : globalNablaAt g x X Y = globalNablaAt g x Y X := by
    simp only [globalNablaAt_apply]
    apply Finset.sum_congr rfl
    intro i hi
    rw [hsymm i x X Y]
  simp [assembledTorsionAt, h]

/-- Second-order overlap data for affine coefficients. The correction term is
the Hessian contribution in the Christoffel transformation law; retaining it
prevents Jacobian-only transport from masquerading as connection transport. -/
structure AffineOverlapCertificate (g : PartitionedConnection ι E) where
  jacobian : ι → ι → E → E →L[ℝ] E
  hessianCorrection : ι → ι → E → E →L[ℝ] E →L[ℝ] E
  jacobian_refl : ∀ i x, jacobian i i x = ContinuousLinearMap.id ℝ E
  jacobian_cocycle : ∀ i j k x,
    jacobian j k x ∘L jacobian i j x = jacobian i k x
  coefficient_law : ∀ i j x X Y,
    g.localNabla j x (jacobian i j x X) (jacobian i j x Y) =
      jacobian i j x (g.localNabla i x X Y) +
        hessianCorrection i j x X Y

/-- Consume the second-order overlap certificate: the Hessian correction is
part of affine connection transport, not optional metadata. -/
theorem certified_coefficient_transformation
    (g : PartitionedConnection ι E) (c : AffineOverlapCertificate g)
    (i j : ι) (x X Y : E) :
    g.localNabla j x (c.jacobian i j x X) (c.jacobian i j x Y) =
      c.jacobian i j x (g.localNabla i x X Y) +
        c.hessianCorrection i j x X Y :=
  c.coefficient_law i j x X Y

/-- Certified Jacobians compose coherently on triple overlaps. -/
theorem certified_jacobian_cocycle
    (g : PartitionedConnection ι E) (c : AffineOverlapCertificate g)
    (i j k : ι) (x : E) :
    c.jacobian j k x ∘L c.jacobian i j x = c.jacobian i k x :=
  c.jacobian_cocycle i j k x
/-- One explicit Euler transport step at a path position. -/
noncomputable def transportStep (g : PartitionedConnection ι E)
    (dt : ℝ) (position velocity : E) : E →L[ℝ] E :=
  ContinuousLinearMap.id ℝ E - dt • globalNablaAt g position velocity

/-- A finite computable path retains ordered duration, position, and velocity
segments. -/
abbrev TransportSegment (E : Type*) := ℝ × (E × E)

noncomputable def discreteParallelTransport (g : PartitionedConnection ι E) :
    List (TransportSegment E) → E →L[ℝ] E
  | [] => ContinuousLinearMap.id ℝ E
  | segment :: rest =>
      discreteParallelTransport g rest ∘L
        transportStep g segment.1 segment.2.1 segment.2.2

@[simp] theorem discreteParallelTransport_nil (g : PartitionedConnection ι E) :
    discreteParallelTransport g [] = ContinuousLinearMap.id ℝ E := rfl

@[simp] theorem discreteParallelTransport_cons (g : PartitionedConnection ι E)
    (segment : TransportSegment E) (rest : List (TransportSegment E)) :
    discreteParallelTransport g (segment :: rest) =
      discreteParallelTransport g rest ∘L
        transportStep g segment.1 segment.2.1 segment.2.2 := rfl

/-- Concatenation is ordered composition, so path order is not flattened. -/
theorem discreteParallelTransport_append (g : PartitionedConnection ι E)
    (first second : List (TransportSegment E)) :
    discreteParallelTransport g (first ++ second) =
      discreteParallelTransport g second ∘L discreteParallelTransport g first := by
  induction first with
  | nil => simp
  | cons segment rest ih =>
      simp only [List.cons_append, discreteParallelTransport_cons, ih]
      rfl

/-- A one-chart partition constructs an assembled connection for every
point-dependent continuous bilinear coefficient. -/
noncomputable def singletonConnection
    (nabla : E → E →L[ℝ] E →L[ℝ] E) : PartitionedConnection Unit E where
  localNabla _ := nabla
  weight _ _ := 1
  weight_nonneg := by intro i x; norm_num
  weight_sum_one := by intro x; simp

theorem singleton_globalNablaAt
    (nabla : E → E →L[ℝ] E →L[ℝ] E) (x : E) :
    globalNablaAt (singletonConnection nabla) x = nabla x := by
  ext X Y
  simp [globalNablaAt, singletonConnection]

/-! ## Observer-floor analytic transport -/

/-- Regularity is certified only after an observer has applied a positive
resolution floor.  The raw path is retained, but the connection ODE consumes
the floor-smoothed position and velocity. -/
structure ObserverFloorRegularity
    (Observer : Type*) (g : PartitionedConnection ι E) where
  observer : Observer
  resolutionFloor : ℝ
  floor_pos : 0 < resolutionFloor
  smoothing : Observer -> ℝ -> E -> E
  rawPosition : ℝ -> E
  rawVelocity : ℝ -> E
  observedPosition : ℝ -> E
  observedVelocity : ℝ -> E
  position_is_smoothed : ∀ t,
    observedPosition t = smoothing observer resolutionFloor (rawPosition t)
  velocity_is_smoothed : ∀ t,
    observedVelocity t = smoothing observer resolutionFloor (rawVelocity t)
  position_smooth : ContDiff ℝ 1 observedPosition
  velocity_smooth : ContDiff ℝ 1 observedVelocity

namespace ObserverFloorRegularity

variable {Observer : Type*} {g : PartitionedConnection ι E}

/-- The coefficient field used by transport is the assembled connection
sampled on the observer-smoothed path. -/
noncomputable def coefficient (R : ObserverFloorRegularity Observer g)
    (t : ℝ) : E →L[ℝ] E :=
  globalNablaAt g (R.observedPosition t) (R.observedVelocity t)

theorem coefficient_uses_observer_floor
    (R : ObserverFloorRegularity Observer g) (t : ℝ) :
    R.coefficient t =
      globalNablaAt g
        (R.smoothing R.observer R.resolutionFloor (R.rawPosition t))
        (R.smoothing R.observer R.resolutionFloor (R.rawVelocity t)) := by
  rw [coefficient, R.position_is_smoothed t, R.velocity_is_smoothed t]

end ObserverFloorRegularity

/-- Analytic parallel transport is not manufactured by finite Euler steps.
It is an explicit certificate over an observer-floor regularization. Existence,
uniqueness, and effective approximation remain separate supplied witnesses. -/
structure EffectiveParallelTransportCertificate
    (Observer : Type*) (g : PartitionedConnection ι E) where
  regularity : ObserverFloorRegularity Observer g
  initialTime : ℝ
  initialVector : E
  trajectory : ℝ -> E
  initial_condition : trajectory initialTime = initialVector
  transport_ode : ∀ t, HasDerivAt trajectory
    (-regularity.coefficient t (trajectory t)) t
  unique_solution : ∀ candidate : ℝ -> E,
    candidate initialTime = initialVector ->
    (∀ t, HasDerivAt candidate
      (-regularity.coefficient t (candidate t)) t) ->
    candidate = trajectory
  resolution : ℕ -> ℝ
  approximation : ℕ -> E
  admissible : ℕ -> Prop
  admissible_iff_floor : ∀ n,
    admissible n <-> regularity.resolutionFloor <= resolution n
  eventually_admissible : ∀ᶠ n in Filter.atTop, admissible n
  errorBound : ℕ -> ℝ
  errorBound_nonneg : ∀ n, 0 <= errorBound n
  observed_error_le : ∀ n, admissible n ->
    ‖regularity.smoothing regularity.observer regularity.resolutionFloor
        (approximation n) -
      regularity.smoothing regularity.observer regularity.resolutionFloor
        (trajectory 1)‖ <= errorBound n
  errorBound_tendsto_zero : Filter.Tendsto errorBound Filter.atTop (nhds 0)

namespace EffectiveParallelTransportCertificate

variable {Observer : Type*} {g : PartitionedConnection ι E}
  (C : EffectiveParallelTransportCertificate Observer g)

/-- The certified trajectory solves the assembled connection equation along
exactly the observer-smoothed coefficient field. -/
theorem solves_observer_floor_transport (t : ℝ) :
    HasDerivAt C.trajectory
      (-C.regularity.coefficient t (C.trajectory t)) t :=
  C.transport_ode t

/-- Uniqueness is consumed as evidence, not inferred from the word smooth. -/
theorem eq_certified_trajectory
    (candidate : ℝ -> E)
    (hinit : candidate C.initialTime = C.initialVector)
    (hode : ∀ t, HasDerivAt candidate
      (-C.regularity.coefficient t (candidate t)) t) :
    candidate = C.trajectory :=
  C.unique_solution candidate hinit hode

/-- Effective convergence is observer-relative: only the floor-smoothed
endpoint error is claimed to vanish. -/
theorem observed_endpoint_error_tendsto_zero :
    Filter.Tendsto
      (fun n => ‖C.regularity.smoothing C.regularity.observer
        C.regularity.resolutionFloor (C.approximation n) -
        C.regularity.smoothing C.regularity.observer
          C.regularity.resolutionFloor (C.trajectory 1)‖)
      Filter.atTop (nhds 0) := by
  have hbound_zero := C.errorBound_tendsto_zero
  rw [Metric.tendsto_atTop] at hbound_zero ⊢
  intro epsilon hepsilon
  obtain ⟨N1, hN1⟩ := hbound_zero epsilon hepsilon
  obtain ⟨N2, hN2⟩ := Filter.eventually_atTop.1 C.eventually_admissible
  refine ⟨max N1 N2, fun n hn => ?_⟩
  have hadmissible : C.admissible n :=
    hN2 n (le_trans (le_max_right N1 N2) hn)
  have hbound := hN1 n (le_trans (le_max_left N1 N2) hn)
  have hbound_lt : C.errorBound n < epsilon := by
    simpa [Real.dist_eq, abs_of_nonneg (C.errorBound_nonneg n)] using hbound
  have herr := C.observed_error_le n hadmissible
  have hlt := lt_of_le_of_lt herr hbound_lt
  simpa [Real.dist_eq, abs_of_nonneg (norm_nonneg _)] using hlt

/-- The approximation therefore converges after the observer-floor map. -/
theorem observed_endpoint_tendsto :
    Filter.Tendsto
      (fun n => C.regularity.smoothing C.regularity.observer
        C.regularity.resolutionFloor (C.approximation n))
      Filter.atTop
      (nhds (C.regularity.smoothing C.regularity.observer
        C.regularity.resolutionFloor (C.trajectory 1))) := by
  exact tendsto_iff_norm_sub_tendsto_zero.2
    C.observed_endpoint_error_tendsto_zero

end EffectiveParallelTransportCertificate

/-- A positive floor is substantive observer data: two floor-indexed smoothing
maps can expose different states of the same raw path. -/
theorem observer_floor_can_change_visible_path :
    let smoothing : Unit -> ℝ -> ℝ -> ℝ := fun _ floor x => floor * x
    smoothing () 1 1 != smoothing () 2 1 := by
  norm_num

/-- The finite construction does not silently claim an analytic ODE limit:
different step sizes can produce different transports. -/
theorem step_size_matters :
    let g : PartitionedConnection Unit ℝ := singletonConnection
      (fun _ => ContinuousLinearMap.lsmul ℝ ℝ)
    transportStep g 0 0 1 1 ≠ transportStep g 1 0 1 1 := by
  dsimp [transportStep, singletonConnection, globalNablaAt]
  norm_num

end ForcingAnalysis.Book4AssembledConnection