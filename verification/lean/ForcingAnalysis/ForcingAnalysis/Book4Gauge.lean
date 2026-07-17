/-
Book4Gauge.lean — typed gauge dictionary and finite path-ordered Wilson kernel
for Principia Symbolica Book 4.
-/
import Mathlib

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

/-- Merely listing four symbolic and gauge names cannot create the required
dictionary: even its first translation may be type-theoretically impossible. -/
theorem names_alone_do_not_supply_gauge_dictionary :
    ¬ Nonempty (GaugeDictionary Unit Unit Unit Unit Empty Unit Unit Unit) := by
  rintro ⟨d⟩
  exact Empty.elim (d.derivative ())

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
