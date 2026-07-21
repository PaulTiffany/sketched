/-
Book4Gauge.lean — typed gauge dictionary and finite path-ordered Wilson kernel
for Principia Symbolica Book 4.
-/
import Mathlib
import Mathlib.Analysis.ODE.ExistUnique

namespace ForcingAnalysis.Book4Gauge

/-- A genuine gauge dictionary carries reversible translations for each of
the four advertised correspondences; shared names alone are not enough. -/
structure GaugeDictionary
    (SymbolicDerivative SymbolicCurvature SymbolicLoop SymbolicConnection
      GaugeDerivative GaugeFieldStrength GaugeWilson GaugeConnection : Type*) where
  derivative : SymbolicDerivative ≃ GaugeDerivative
  curvature : SymbolicCurvature ≃ GaugeFieldStrength
  loop : SymbolicLoop ≃ GaugeWilson
  connection : SymbolicConnection ≃ GaugeConnection

theorem derivative_correspondence_bijective
    {SD SC SL SA GD GF GW GA : Type*}
    (d : GaugeDictionary SD SC SL SA GD GF GW GA) :
    Function.Bijective d.derivative :=
  d.derivative.bijective

theorem curvature_correspondence_bijective
    {SD SC SL SA GD GF GW GA : Type*}
    (d : GaugeDictionary SD SC SL SA GD GF GW GA) :
    Function.Bijective d.curvature :=
  d.curvature.bijective

/-! ### Structural gauge certificate -/

/-- The structural dictionary demanded by the source. Besides reversible
translations, it carries the operations on both sides and proofs that the
connection action, curvature construction, gauge action, and loop holonomy
commute with translation. -/
structure StructuralGaugeCertificate
    (SymbolicField SymbolicDerivative SymbolicCurvature SymbolicLoop
      SymbolicConnection SymbolicGauge
      GaugeField GaugeDerivative GaugeFieldStrength GaugeLoop
      GaugeConnection GaugeTransform : Type*)
    extends GaugeDictionary SymbolicDerivative SymbolicCurvature SymbolicLoop
      SymbolicConnection GaugeDerivative GaugeFieldStrength GaugeLoop
      GaugeConnection where
  field : SymbolicField ≃ GaugeField
  gaugeTransform : SymbolicGauge ≃ GaugeTransform
  symbolicConnectionAction : SymbolicConnection → SymbolicField → SymbolicDerivative
  targetConnectionAction : GaugeConnection → GaugeField → GaugeDerivative
  connectionAction_commutes : ∀ A f,
    toGaugeDictionary.derivative (symbolicConnectionAction A f) =
      targetConnectionAction (toGaugeDictionary.connection A) (field f)
  symbolicCurvature : SymbolicConnection → SymbolicCurvature
  targetCurvature : GaugeConnection → GaugeFieldStrength
  curvature_commutes : ∀ A,
    toGaugeDictionary.curvature (symbolicCurvature A) =
      targetCurvature (toGaugeDictionary.connection A)
  symbolicFieldAction : SymbolicGauge → SymbolicField → SymbolicField
  targetFieldAction : GaugeTransform → GaugeField → GaugeField
  fieldAction_equivariant : ∀ g f,
    field (symbolicFieldAction g f) =
      targetFieldAction (gaugeTransform g) (field f)
  symbolicConnectionGaugeAction : SymbolicGauge → SymbolicConnection → SymbolicConnection
  targetConnectionGaugeAction : GaugeTransform → GaugeConnection → GaugeConnection
  connectionGaugeAction_equivariant : ∀ g A,
    toGaugeDictionary.connection (symbolicConnectionGaugeAction g A) =
      targetConnectionGaugeAction (gaugeTransform g)
        (toGaugeDictionary.connection A)
  symbolicHolonomy : SymbolicConnection → SymbolicLoop
  targetHolonomy : GaugeConnection → GaugeLoop
  holonomy_commutes : ∀ A,
    toGaugeDictionary.loop (symbolicHolonomy A) =
      targetHolonomy (toGaugeDictionary.connection A)

/-- The connection/covariant-derivative square of a structural dictionary
commutes by certificate, not by shared terminology. -/
theorem StructuralGaugeCertificate.connectionAction_square
    {SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans : Type*}
    (d : StructuralGaugeCertificate SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans)
    (A : SA) (f : SF) :
    d.toGaugeDictionary.derivative (d.symbolicConnectionAction A f) =
      d.targetConnectionAction (d.toGaugeDictionary.connection A) (d.field f) :=
  d.connectionAction_commutes A f

/-- Curvature translation preserves the certified construction, including the
orientation convention already chosen by the two curvature operations. -/
theorem StructuralGaugeCertificate.curvature_square
    {SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans : Type*}
    (d : StructuralGaugeCertificate SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans)
    (A : SA) :
    d.toGaugeDictionary.curvature (d.symbolicCurvature A) =
      d.targetCurvature (d.toGaugeDictionary.connection A) :=
  d.curvature_commutes A

/-- Field translation is equivariant for the specified symbolic and target
gauge actions. -/
theorem StructuralGaugeCertificate.fieldAction_square
    {SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans : Type*}
    (d : StructuralGaugeCertificate SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans)
    (g : SG) (f : SF) :
    d.field (d.symbolicFieldAction g f) =
      d.targetFieldAction (d.gaugeTransform g) (d.field f) :=
  d.fieldAction_equivariant g f

/-- Loop translation carries certified symbolic transport to target holonomy. -/
theorem StructuralGaugeCertificate.holonomy_square
    {SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans : Type*}
    (d : StructuralGaugeCertificate SF SD SC SL SA SG GF GD GCurv GLoop GConn GTrans)
    (A : SA) :
    d.toGaugeDictionary.loop (d.symbolicHolonomy A) =
      d.targetHolonomy (d.toGaugeDictionary.connection A) :=
  d.holonomy_commutes A
/-- Merely listing four symbolic and gauge names cannot create the required
dictionary: even its first translation may be type-theoretically impossible. -/
theorem names_alone_do_not_supply_gauge_dictionary :
    ¬ Nonempty (GaugeDictionary Unit Unit Unit Unit Empty Unit Unit Unit) := by
  rintro ⟨d⟩
  exact Empty.elim (d.derivative ())

/-! ### Observer-local data and deduced global geometry -/

/-- An observer atlas exposes only observer-indexed local readouts of a global
carrier. `jointlySeparating` is the epistemic bridge: agreement in every local
view determines a global candidate, even though no observer reads it whole. -/
structure ObserverAtlas (Observer Local Global : Type*) where
  view : Observer → Global → Local
  jointlySeparating : ∀ {x y : Global},
    (∀ observer, view observer x = view observer y) → x = y

/-- A family of local observations is compatible with a proposed global
geometry when every observer recovers its own local component. -/
def ObserverAtlas.CompatibleWith
    {Observer Local Global : Type*}
    (A : ObserverAtlas Observer Local Global)
    (locals : Observer → Local) (global : Global) : Prop :=
  ∀ observer, A.view observer global = locals observer

/-- Observer-local agreement determines at most one global geometry. This is a
deduction theorem, not a claim that any compatible global object exists. -/
theorem ObserverAtlas.global_unique_of_local_compatibility
    {Observer Local Global : Type*}
    (A : ObserverAtlas Observer Local Global)
    {locals : Observer → Local} {x y : Global}
    (hx : A.CompatibleWith locals x) (hy : A.CompatibleWith locals y) :
    x = y := by
  apply A.jointlySeparating
  intro observer
  exact (hx observer).trans (hy observer).symm

/-- The complete family of observer coordinates is a concrete global carrier:
restriction to observer `o` recovers exactly the `o`-local datum. -/
def coordinateObserverAtlas (Observer Local : Type*) :
    ObserverAtlas Observer Local (Observer → Local) where
  view observer global := global observer
  jointlySeparating h := funext h

theorem coordinateObserverAtlas_assembles
    {Observer Local : Type*} (locals : Observer → Local) :
    (coordinateObserverAtlas Observer Local).CompatibleWith locals locals := by
  intro observer
  rfl

/-- Local data alone do not guarantee a global inhabitant for an arbitrary
atlas: an empty global carrier can still have local observations as types. -/
theorem observer_local_types_do_not_force_global_existence :
    Nonempty (Unit → Unit) ∧ ¬ Nonempty Empty := by
  exact ⟨⟨fun _ => ()⟩, by simp⟩
/-! ### Analytic Wilson transport -/

/-- Left-action transport field with the source's negative-sign convention:
`U' = -a(t) U`. The carrier may be a noncommutative complete normed algebra,
such as a finite-dimensional real matrix algebra. -/
def wilsonTransportField {A : Type*} [NormedRing A]
    (coefficient : ℝ → A) (t : ℝ) (U : A) : A :=
  -(coefficient t * U)

/-- Quantitative local certificate for the analytic Wilson transport ODE. It
records exactly the Picard--Lindelöf hypotheses needed on a time interval. -/
structure WilsonTransportCertificate
    (A : Type*) [NormedRing A] [NormedAlgebra ℝ A]
    (coefficient : ℝ → A) (tmin tmax : ℝ) where
  initialTime : Set.Icc tmin tmax
  initialTransport : A
  spatialRadius : NNReal
  initialRadius : NNReal
  velocityBound : NNReal
  lipschitzBound : NNReal
  picard : IsPicardLindelof (wilsonTransportField coefficient)
    initialTime initialTransport spatialRadius initialRadius
    velocityBound lipschitzBound

namespace WilsonTransportCertificate

variable {A : Type*} [NormedRing A] [NormedAlgebra ℝ A] [CompleteSpace A]
  {coefficient : ℝ → A} {tmin tmax : ℝ}

/-- A certified Wilson transport is the actual Picard--Lindelöf solution, not
an ordinary exponential of a noncommutative integral. -/
noncomputable def trajectory
    (cert : WilsonTransportCertificate A coefficient tmin tmax) : ℝ → A :=
  Classical.choose (cert.picard.exists_eq_forall_mem_Icc_hasDerivWithinAt
    (Metric.mem_closedBall_self (NNReal.coe_nonneg cert.initialRadius)))

/-- The certified trajectory begins at the declared initial transport. -/
theorem trajectory_initial
    (cert : WilsonTransportCertificate A coefficient tmin tmax) :
    cert.trajectory cert.initialTime = cert.initialTransport := by
  exact (Classical.choose_spec
    (cert.picard.exists_eq_forall_mem_Icc_hasDerivWithinAt
      (Metric.mem_closedBall_self
        (NNReal.coe_nonneg cert.initialRadius)))).1

/-- The transport trajectory satisfies `U' = -a(t)U` throughout the certified
interval. -/
theorem trajectory_hasDerivWithinAt
    (cert : WilsonTransportCertificate A coefficient tmin tmax)
    (t : ℝ) (ht : t ∈ Set.Icc tmin tmax) :
    HasDerivWithinAt cert.trajectory
      (wilsonTransportField coefficient t (cert.trajectory t))
      (Set.Icc tmin tmax) t := by
  exact (Classical.choose_spec
    (cert.picard.exists_eq_forall_mem_Icc_hasDerivWithinAt
      (Metric.mem_closedBall_self
        (NNReal.coe_nonneg cert.initialRadius)))).2 t ht

/-- Analytic holonomy is the endpoint of the certified transport ODE. -/
noncomputable def holonomy
    (cert : WilsonTransportCertificate A coefficient tmin tmax) : A :=
  cert.trajectory tmax

/-- The endpoint called holonomy is definitionally the terminal value of the
transport solution. -/
theorem holonomy_eq_endpoint
    (cert : WilsonTransportCertificate A coefficient tmin tmax) :
    cert.holonomy = cert.trajectory tmax := rfl

end WilsonTransportCertificate
/-- Finite path ordering: transports are multiplied in their listed order.
This remains meaningful for a noncommutative gauge group. -/
def pathOrderedProduct {G : Type*} [Monoid G] (segments : List G) : G :=
  segments.prod

theorem pathOrderedProduct_nil {G : Type*} [Monoid G] :
    pathOrderedProduct ([] : List G) = 1 := by
  rfl

theorem pathOrderedProduct_append {G : Type*} [Monoid G]
    (first second : List G) :
    pathOrderedProduct (first ++ second) =
      pathOrderedProduct first * pathOrderedProduct second := by
  simp [pathOrderedProduct]

/-- Reversing a two-segment loop reverses the product; equality is exactly
the commutation condition. -/
theorem two_segment_order_independent_iff {G : Type*} [Monoid G] (a b : G) :
    pathOrderedProduct [a, b] = pathOrderedProduct [b, a] ↔ a * b = b * a := by
  simp [pathOrderedProduct]

end ForcingAnalysis.Book4Gauge
