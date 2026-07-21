import ForcingAnalysis.Book4Gauge

/-!
# Book 4: global Wilson continuation and exact ordered refinements

This module closes the local-to-global algebra of Wilson transport without
identifying exact transport increments with a numerical Euler scheme.
-/

namespace ForcingAnalysis.Book4WilsonGlobal

open Set

/-- A finite SRV-style continuation trace. Local transport charts cover the
whole parameter interval and agree wherever they overlap. -/
structure WilsonContinuationTrace
    (Chart G : Type*) [Fintype Chart] [Nonempty Chart] where
  left : Chart → ℝ
  right : Chart → ℝ
  localTransport : Chart → ℝ → G
  outside : G
  covers : ∀ t ∈ Set.Icc (0 : ℝ) 1,
    ∃ i, t ∈ Set.Icc (left i) (right i)
  overlap_unique : ∀ (i j : Chart) (t : ℝ),
    t ∈ Set.Icc (left i) (right i) →
    t ∈ Set.Icc (left j) (right j) →
    localTransport i t = localTransport j t

namespace WilsonContinuationTrace

variable {Chart G : Type*} [Fintype Chart] [Nonempty Chart]
  (T : WilsonContinuationTrace Chart G)

noncomputable def chartAt (t : ℝ) (ht : t ∈ Set.Icc (0 : ℝ) 1) : Chart :=
  Classical.choose (T.covers t ht)

theorem chartAt_mem (t : ℝ) (ht : t ∈ Set.Icc (0 : ℝ) 1) :
    t ∈ Set.Icc (T.left (T.chartAt t ht)) (T.right (T.chartAt t ht)) :=
  Classical.choose_spec (T.covers t ht)

/-- The glued global transport, with the group identity outside `[0,1]`. -/
noncomputable def globalTransport (t : ℝ) : G :=
  if ht : t ∈ Set.Icc (0 : ℝ) 1 then T.localTransport (T.chartAt t ht) t else T.outside

/-- The global transport agrees with every local chart containing the point;
choice of chart is therefore observationally irrelevant. -/
theorem globalTransport_eq_local
    (i : Chart) (t : ℝ) (ht : t ∈ Set.Icc (0 : ℝ) 1)
    (hi : t ∈ Set.Icc (T.left i) (T.right i)) :
    T.globalTransport t = T.localTransport i t := by
  rw [globalTransport, dif_pos ht]
  exact T.overlap_unique (T.chartAt t ht) i t (T.chartAt_mem t ht) hi

/-- Global holonomy is the glued endpoint relative to the glued initial
transport. For the source normalization `U(0)=I`, this is simply `U(1)`. -/
noncomputable def globalHolonomy [Group G] : G :=
  T.globalTransport 1 * (T.globalTransport 0)⁻¹

theorem globalHolonomy_eq_endpoint_of_initial_eq_one [Group G]
    (h0 : T.globalTransport 0 = 1) :
    T.globalHolonomy = T.globalTransport 1 := by
  simp [globalHolonomy, h0]

end WilsonContinuationTrace

/-! ## Picard-certified continuation charts -/

/-- A continuation cover whose local functions are the actual trajectories
selected by Picard--Lindelöf certificates for one shared coefficient field. -/
structure AnalyticWilsonContinuationTrace
    (Chart A : Type*) [Fintype Chart] [Nonempty Chart]
    [NormedRing A] [NormedAlgebra ℝ A] [CompleteSpace A]
    (coefficient : ℝ → A) where
  left : Chart → ℝ
  right : Chart → ℝ
  localCertificate : ∀ i,
    Book4Gauge.WilsonTransportCertificate A coefficient (left i) (right i)
  covers : ∀ t ∈ Set.Icc (0 : ℝ) 1,
    ∃ i, t ∈ Set.Icc (left i) (right i)
  overlap_unique : ∀ (i j : Chart) (t : ℝ),
    t ∈ Set.Icc (left i) (right i) →
    t ∈ Set.Icc (left j) (right j) →
    (localCertificate i).trajectory t = (localCertificate j).trajectory t

namespace AnalyticWilsonContinuationTrace

variable {Chart A : Type*} [Fintype Chart] [Nonempty Chart]
  [NormedRing A] [NormedAlgebra ℝ A] [CompleteSpace A]
  {coefficient : ℝ → A}
  (T : AnalyticWilsonContinuationTrace Chart A coefficient)

/-- Forgetting analytic evidence yields the gluable continuation trace. -/
noncomputable def toContinuationTrace : WilsonContinuationTrace Chart A where
  left := T.left
  right := T.right
  localTransport := fun i => (T.localCertificate i).trajectory
  outside := 1
  covers := T.covers
  overlap_unique := T.overlap_unique

/-- The glued transport agrees with each certified Picard trajectory on its
chart. -/
theorem globalTransport_eq_certified_trajectory
    (i : Chart) (t : ℝ) (ht : t ∈ Set.Icc (0 : ℝ) 1)
    (hi : t ∈ Set.Icc (T.left i) (T.right i)) :
    (toContinuationTrace T).globalTransport t =
      (T.localCertificate i).trajectory t :=
  (toContinuationTrace T).globalTransport_eq_local i t ht hi

/-- Every local chart in the continuation trace satisfies the shared Wilson
transport ODE on its certified interval. -/
theorem local_trajectory_hasDerivWithinAt
    (i : Chart) (t : ℝ) (ht : t ∈ Set.Icc (T.left i) (T.right i)) :
    HasDerivWithinAt (T.localCertificate i).trajectory
      (Book4Gauge.wilsonTransportField coefficient t
        ((T.localCertificate i).trajectory t))
      (Set.Icc (T.left i) (T.right i)) t :=
  (T.localCertificate i).trajectory_hasDerivWithinAt t ht

end AnalyticWilsonContinuationTrace
/-- Exact transport increments, listed latest-first so noncommutative
multiplication composes in chronological action order. -/
def reverseOrderedIncrements {G : Type*} [Group G]
    (u : ℕ → G) : ℕ → List G
  | 0 => []
  | n + 1 => (u (n + 1) * (u n)⁻¹) :: reverseOrderedIncrements u n

/-- Exact increments telescope without any commutativity assumption. -/
theorem reverseOrderedIncrements_prod {G : Type*} [Group G]
    (u : ℕ → G) (n : ℕ) :
    (reverseOrderedIncrements u n).prod = u n * (u 0)⁻¹ := by
  induction n with
  | zero => simp [reverseOrderedIncrements]
  | succ n ih =>
      simp only [reverseOrderedIncrements, List.prod_cons, ih]
      group

/-- Any partition whose sampled endpoints are the global endpoints therefore
has exact ordered transport equal to global holonomy. This is product
integration using exact segment transports, not an Euler approximation. -/
theorem exact_partition_transport_eq_holonomy
    {G : Type*} [Group G] (u : ℕ → G) (n : ℕ)
    (hstart : u 0 = 1) (hend : u n = u (n + 1)) :
    (reverseOrderedIncrements u n).prod = u (n + 1) := by
  rw [reverseOrderedIncrements_prod, hstart, inv_one, mul_one, hend]

/-- The Wilson observable in a declared finite-dimensional representation is
the trace of holonomy. The trace map is explicit data. -/
def wilsonObservable {G Scalar : Type*}
    (trace : G → Scalar) (holonomy : G) : Scalar := trace holonomy

theorem wilsonObservable_eq_trace {G Scalar : Type*}
    (trace : G → Scalar) (holonomy : G) :
    wilsonObservable trace holonomy = trace holonomy := rfl

/-- A symbolic boundary observable acquires a Wilson representation only from
an explicit compatibility witness. -/
theorem symbolic_loop_has_wilson_representation
    {SymbolicLoop G Scalar : Type*}
    (symbolicObservable : SymbolicLoop → Scalar)
    (trace : G → Scalar) (loop : SymbolicLoop) (holonomy : G)
    (hcompat : symbolicObservable loop = trace holonomy) :
    symbolicObservable loop = wilsonObservable trace holonomy := by
  simpa [wilsonObservable] using hcompat

/-- Names and an endpoint do not manufacture symbolic-loop compatibility. -/
theorem endpoint_alone_does_not_identify_symbolic_loop :
    ∃ (symbolicObservable : Bool → Bool) (trace : Bool → Bool)
      (loop holonomy : Bool),
      symbolicObservable loop ≠ trace holonomy :=
  ⟨id, not, false, false, by decide⟩

/-! ## Observer-relative approximation -/

/-- A Wilson approximation is meaningful only relative to an observer's
smoothing map, positive resolution floor, admissibility rule, and error
measurement.  The certificate does not manufacture an algorithm: it records
the evidence a concrete solver must provide. -/
structure ObserverWilsonApproximationCertificate
    (Observer A : Type*) [NormedAddCommGroup A] where
  observer : Observer
  smoothing : Observer → A → A
  resolutionFloor : ℝ
  floor_pos : 0 < resolutionFloor
  resolution : ℕ → ℝ
  approximation : ℕ → A
  target : A
  admissible : ℕ → Prop
  admissible_iff_floor : ∀ n,
    admissible n ↔ resolutionFloor ≤ resolution n
  eventually_admissible : ∀ᶠ n in Filter.atTop, admissible n
  errorBound : ℕ → ℝ
  errorBound_nonneg : ∀ n, 0 ≤ errorBound n
  observed_error_le : ∀ n, admissible n →
    ‖smoothing observer (approximation n) - smoothing observer target‖ ≤
      errorBound n
  errorBound_tendsto_zero : Filter.Tendsto errorBound Filter.atTop (nhds 0)

namespace ObserverWilsonApproximationCertificate

variable {Observer A : Type*} [NormedAddCommGroup A]
  (C : ObserverWilsonApproximationCertificate Observer A)

/-- Beyond the observer's floor, the certified observed error tends to zero.
This is convergence of the smoothed observable, not of a privileged raw
approximation. -/
theorem observed_error_tendsto_zero :
    Filter.Tendsto
      (fun n => ‖C.smoothing C.observer (C.approximation n) -
        C.smoothing C.observer C.target‖)
      Filter.atTop (nhds 0) := by
  have hbound_zero := C.errorBound_tendsto_zero
  rw [Metric.tendsto_atTop] at hbound_zero ⊢
  intro ε hε
  obtain ⟨N₁, hN₁⟩ := hbound_zero ε hε
  obtain ⟨N₂, hN₂⟩ := Filter.eventually_atTop.1 C.eventually_admissible
  refine ⟨max N₁ N₂, fun n hn => ?_⟩
  have hadmissible : C.admissible n :=
    hN₂ n (le_trans (le_max_right N₁ N₂) hn)
  have hbound := hN₁ n (le_trans (le_max_left N₁ N₂) hn)
  have hbound_lt : C.errorBound n < ε := by
    simpa [Real.dist_eq, abs_of_nonneg (C.errorBound_nonneg n)] using hbound
  have herr := C.observed_error_le n hadmissible
  have hlt := lt_of_le_of_lt herr hbound_lt
  simpa [Real.dist_eq, abs_of_nonneg (norm_nonneg _)] using hlt

/-- The certificate therefore converges in the observer's smoothed state
space. -/
theorem observed_approximation_tendsto :
    Filter.Tendsto
      (fun n => C.smoothing C.observer (C.approximation n))
      Filter.atTop (nhds (C.smoothing C.observer C.target)) := by
  exact tendsto_iff_norm_sub_tendsto_zero.2 C.observed_error_tendsto_zero

/-- Admissibility is exactly observer-floor visibility; it is not an
observer-free property of the partition index. -/
theorem admissible_iff_visible_above_floor (n : ℕ) :
    C.admissible n ↔ C.resolutionFloor ≤ C.resolution n :=
  C.admissible_iff_floor n

end ObserverWilsonApproximationCertificate

/-- Cross-observer comparison requires a declared transport map which
intertwines both smoothing operations on the approximation and its target. -/
structure CrossObserverWilsonTransport
    (Observer A B : Type*) [NormedAddCommGroup A] [NormedAddCommGroup B]
    (CA : ObserverWilsonApproximationCertificate Observer A)
    (CB : ObserverWilsonApproximationCertificate Observer B) where
  transport : A → B
  approximation_intertwines : ∀ n,
    transport (CA.smoothing CA.observer (CA.approximation n)) =
      CB.smoothing CB.observer (CB.approximation n)
  target_intertwines :
    transport (CA.smoothing CA.observer CA.target) =
      CB.smoothing CB.observer CB.target

namespace CrossObserverWilsonTransport

variable {Observer A B : Type*} [NormedAddCommGroup A] [NormedAddCommGroup B]
  {CA : ObserverWilsonApproximationCertificate Observer A}
  {CB : ObserverWilsonApproximationCertificate Observer B}
  (T : CrossObserverWilsonTransport Observer A B CA CB)

/-- A cross-observer Wilson claim is the transported target identity carried
by the explicit observer bridge. -/
theorem transported_target_eq :
    T.transport (CA.smoothing CA.observer CA.target) =
      CB.smoothing CB.observer CB.target :=
  T.target_intertwines

/-- Every certified approximation is likewise comparable through the same
observer bridge. -/
theorem transported_approximation_eq (n : ℕ) :
    T.transport (CA.smoothing CA.observer (CA.approximation n)) =
      CB.smoothing CB.observer (CB.approximation n) :=
  T.approximation_intertwines n

end CrossObserverWilsonTransport

/-- One raw endpoint need not have a unique observer presentation.  Thus raw
Wilson transport alone cannot erase observer smoothing. -/
theorem shared_raw_endpoint_does_not_force_shared_observation :
    ∃ (smoothing : Bool → ℝ → ℝ) (target : ℝ),
      smoothing false target ≠ smoothing true target := by
  refine ⟨fun observer x => if observer then -x else x, 1, ?_⟩
  norm_num

/-- Positivity alone does not select a universal observer floor. -/
theorem positive_resolution_floor_not_unique :
    ∃ floor₁ floor₂ : ℝ, 0 < floor₁ ∧ 0 < floor₂ ∧ floor₁ ≠ floor₂ := by
  exact ⟨1, 2, by norm_num⟩
/-! ## A concrete observer-selected constant-coefficient solver -/

/-- Observer data for the first concrete Wilson approximation. Continuity of
smoothing is the bridge that transports raw scalar Euler convergence into the
observer's presentation. -/
structure ScalarWilsonObserver (Observer : Type*) where
  observer : Observer
  smoothing : Observer → ℝ → ℝ
  smoothing_continuous : Continuous (smoothing observer)
  resolutionFloor : ℝ
  floor_pos : 0 < resolutionFloor

/-- The explicit Euler product for the constant scalar Wilson equation
`U' = -a U`, over `n+1` equal steps on `[0,1]`. -/
noncomputable def scalarConstantEulerApproximation (a : ℝ) (n : ℕ) : ℝ :=
  (1 + (-a) / ((n : ℝ) + 1)) ^ (n + 1)

/-- The concrete scalar Euler products converge to the exact constant-field
Wilson transport `exp (-a)`. This is a genuine approximation theorem, but only
for the commutative constant-coefficient case. -/
theorem scalarConstantEulerApproximation_tendsto (a : ℝ) :
    Filter.Tendsto (scalarConstantEulerApproximation a)
      Filter.atTop (nhds (Real.exp (-a))) := by
  have h := Real.tendsto_one_add_div_pow_exp (-a)
  have hshift := (Filter.tendsto_add_atTop_iff_nat 1).2 h
  change Filter.Tendsto
    (fun n : ℕ => (1 + (-a) / ((n : ℝ) + 1)) ^ (n + 1))
    Filter.atTop (nhds (Real.exp (-a)))
  simpa only [Nat.cast_add, Nat.cast_one] using hshift

/-- A continuous observer smoothing carries the concrete scalar Euler solver
to an `ObserverWilsonApproximationCertificate`. Resolving power is indexed by
`floor + n`, hence every stage is visibly above the declared floor. The error
bound is the actual observed error; this proves asymptotic convergence but does
not yet supply a closed-form rate. -/
noncomputable def scalarConstantObserverCertificate
    {Observer : Type*} (O : ScalarWilsonObserver Observer) (a : ℝ) :
    ObserverWilsonApproximationCertificate Observer ℝ where
  observer := O.observer
  smoothing := O.smoothing
  resolutionFloor := O.resolutionFloor
  floor_pos := O.floor_pos
  resolution := fun n => O.resolutionFloor + n
  approximation := scalarConstantEulerApproximation a
  target := Real.exp (-a)
  admissible := fun _ => True
  admissible_iff_floor := by
    intro n
    simp
  eventually_admissible := Filter.Eventually.of_forall (fun _ => trivial)
  errorBound := fun n =>
    ‖O.smoothing O.observer (scalarConstantEulerApproximation a n) -
      O.smoothing O.observer (Real.exp (-a))‖
  errorBound_nonneg := fun _ => norm_nonneg _
  observed_error_le := by
    intro n _
    exact le_rfl
  errorBound_tendsto_zero := by
    apply tendsto_iff_norm_sub_tendsto_zero.1
    exact O.smoothing_continuous.continuousAt.tendsto.comp
      (scalarConstantEulerApproximation_tendsto a)

/-- The concrete certificate exposes its promised observer-relative
convergence through the generic kernel. -/
theorem scalarConstantObserverCertificate_tendsto
    {Observer : Type*} (O : ScalarWilsonObserver Observer) (a : ℝ) :
    Filter.Tendsto
      (fun n => O.smoothing O.observer (scalarConstantEulerApproximation a n))
      Filter.atTop (nhds (O.smoothing O.observer (Real.exp (-a)))) :=
  (scalarConstantObserverCertificate O a).observed_approximation_tendsto
end ForcingAnalysis.Book4WilsonGlobal