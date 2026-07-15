/-
Book5ProductSpectrum.lean - independent norm-fracture and memory-resonance axes.

These are transition diagnostics, not permanent identities of an agent or
manifold. Coupling is explicit product data and does not identify the axes.
-/

import ForcingAnalysis.Book5Decoherence
import ForcingAnalysis.Book5
import ForcingAnalysis.Book5Spectrum

namespace ForcingAnalysis.Book5

noncomputable section

open scoped goldenRatio

inductive NormDiagnostic where
  | axisIntegrable
  | euclideanDiagonal
  | supportCollapsed (supportSize : Nat)
  deriving DecidableEq, Repr

def normDiagnosticRatio : NormDiagnostic -> Real
  | .axisIntegrable => 1
  | .euclideanDiagonal => Real.sqrt 2
  | .supportCollapsed n => n

structure CoupledSpectrum where
  norm : NormDiagnostic
  memoryRatio : Real

def balancedSpectrum (norm : NormDiagnostic) : CoupledSpectrum :=
  ⟨norm, φ⟩

theorem normDiagnosticRatio_axis :
    normDiagnosticRatio .axisIntegrable = 1 := rfl

theorem normDiagnosticRatio_euclidean :
    normDiagnosticRatio .euclideanDiagonal = Real.sqrt 2 := rfl

theorem normDiagnosticRatio_support (n : Nat) :
    normDiagnosticRatio (.supportCollapsed n) = n := rfl

theorem balancedSpectrum_memory (norm : NormDiagnostic) :
    (balancedSpectrum norm).memoryRatio = φ := rfl

theorem balancedSpectrum_norm (norm : NormDiagnostic) :
    (balancedSpectrum norm).norm = norm := rfl

theorem balanced_memory_resonance_unique
    {x : Real} (hx : 0 < x) (hCharacteristic : x ^ 2 = x + 1) :
    x = φ :=
  ForcingAnalysis.gold_unique_positive_root hx hCharacteristic

theorem changing_norm_preserves_balanced_memory
    (a b : NormDiagnostic) :
    (balancedSpectrum a).memoryRatio = (balancedSpectrum b).memoryRatio := rfl

theorem norm_and_memory_coordinates_independent :
    (∃ x y : CoupledSpectrum,
      x.memoryRatio = y.memoryRatio ∧ Not (x.norm = y.norm)) ∧
    (∃ x y : CoupledSpectrum,
      x.norm = y.norm ∧ Not (x.memoryRatio = y.memoryRatio)) := by
  constructor
  · exact ⟨balancedSpectrum .axisIntegrable,
      balancedSpectrum .euclideanDiagonal, rfl, by decide⟩
  · exact ⟨⟨.axisIntegrable, 0⟩, ⟨.axisIntegrable, 1⟩, rfl, by norm_num⟩

def concentratedPlane : Plane := ![(1 : Real), 0]

def distributedPlane : Plane := ![(1 : Real), 1]

theorem support_collapse_forgets_distribution :
    supportCost concentratedPlane = supportCost distributedPlane ∧
      Not (axisCost concentratedPlane = axisCost distributedPlane) := by
  constructor <;> norm_num [supportCost, axisCost, concentratedPlane, distributedPlane]

theorem elementary_spectrum_values :
    normDiagnosticRatio .axisIntegrable = 1 ∧
    normDiagnosticRatio .euclideanDiagonal = Real.sqrt 2 ∧
    ∀ n, normDiagnosticRatio (.supportCollapsed n) = n := by
  simp [normDiagnosticRatio]


theorem euclidean_balanced_product_spectrum :
    normDiagnosticRatio (balancedSpectrum .euclideanDiagonal).norm = Real.sqrt 2 ∧
    (balancedSpectrum .euclideanDiagonal).memoryRatio = φ ∧
    Not (φ = Real.sqrt 2) := by
  refine ⟨rfl, rfl, ?_⟩
  exact ForcingAnalysis.constants_complementary.2.2.2.2

theorem balanced_memory_converges_to_spectrum_memory (norm : NormDiagnostic) :
    Filter.Tendsto (fun n => (Nat.fib (n + 1) : Real) / Nat.fib n)
      Filter.atTop (nhds (balancedSpectrum norm).memoryRatio) := by
  simpa [balancedSpectrum] using ForcingAnalysis.balanced_memory_tendsto_gold

theorem fundamental_norm_fracture_kernel :
    (normDiagnosticRatio .axisIntegrable = 1 ∧
      normDiagnosticRatio .euclideanDiagonal = Real.sqrt 2 ∧
      ∀ n, normDiagnosticRatio (.supportCollapsed n) = n) ∧
    (supportCost concentratedPlane = supportCost distributedPlane ∧
      Not (axisCost concentratedPlane = axisCost distributedPlane)) ∧
    Not (φ = Real.sqrt 2) ∧
    ∀ x : Real, 0 < x -> x ^ 2 = x + 1 -> x = φ := by
  refine ⟨elementary_spectrum_values, support_collapse_forgets_distribution,
    ForcingAnalysis.constants_complementary.2.2.2.2, ?_⟩
  intro x hx hCharacteristic
  exact balanced_memory_resonance_unique hx hCharacteristic
end

end ForcingAnalysis.Book5