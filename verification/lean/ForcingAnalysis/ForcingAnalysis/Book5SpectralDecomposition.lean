/-
Book5SpectralDecomposition.lean - observer-resolved four-channel decomposition.

Existence of a decomposition is explicit structure data. The theorems prove
reconstruction, uniqueness, and invariance once that data is supplied.
-/

import ForcingAnalysis.Book5ProductSpectrum

namespace ForcingAnalysis.Book5

noncomputable section

inductive SpectralChannel where
  | axis
  | euclidean
  | support
  | memory
  deriving DecidableEq, Fintype, Repr

variable (V : Type*) [AddCommMonoid V] [Module Real V]

structure ObserverSpectralDecomposition where
  coordinates : V ≃ₗ[Real] (SpectralChannel -> Real)
  evolution : V →ₗ[Real] V
  multiplier : SpectralChannel -> Real
  diagonalizes : ∀ x i,
    coordinates (evolution x) i = multiplier i * coordinates x i

namespace ObserverSpectralDecomposition

variable {V : Type*} [AddCommMonoid V] [Module Real V]

def component (D : ObserverSpectralDecomposition V)
    (i : SpectralChannel) (x : V) : V :=
  D.coordinates.symm (Pi.single i (D.coordinates x i))

theorem coordinates_component_same
    (D : ObserverSpectralDecomposition V) (i : SpectralChannel) (x : V) :
    D.coordinates (D.component i x) i = D.coordinates x i := by
  simp [component]

theorem coordinates_component_other
    (D : ObserverSpectralDecomposition V) {i j : SpectralChannel}
    (hij : Not (j = i)) (x : V) :
    D.coordinates (D.component i x) j = 0 := by
  simp [component, Pi.single, hij]

theorem sum_components (D : ObserverSpectralDecomposition V) (x : V) :
    Finset.univ.sum (fun i => D.component i x) = x := by
  apply D.coordinates.injective
  funext j
  simp [component]

theorem coordinate_representation_unique
    (D : ObserverSpectralDecomposition V) (x : V) (a : SpectralChannel -> Real) :
    Finset.univ.sum
        (fun i => D.coordinates.symm (Pi.single i (a i))) = x ↔
      a = D.coordinates x := by
  constructor
  · intro h
    apply funext
    intro j
    have hCoord := congrArg (fun y => D.coordinates y j) h
    simpa using hCoord
  · rintro rfl
    exact D.sum_components x

theorem evolution_component
    (D : ObserverSpectralDecomposition V) (i : SpectralChannel) (x : V) :
    D.evolution (D.component i x) =
      D.multiplier i • D.component i x := by
  apply D.coordinates.injective
  funext j
  by_cases hji : j = i
  · subst j
    simp [component, D.diagonalizes]
  · simp [component, Pi.single, hji, D.diagonalizes]

theorem component_is_invariant
    (D : ObserverSpectralDecomposition V) (i : SpectralChannel) :
    ∀ x, ∃ c : Real, D.evolution (D.component i x) = c • D.component i x := by
  intro x
  exact ⟨D.multiplier i, D.evolution_component i x⟩

theorem spectral_decomposition_kernel
    (D : ObserverSpectralDecomposition V) (x : V) :
    Finset.univ.sum (fun i => D.component i x) = x ∧
    (∀ a : SpectralChannel -> Real,
      Finset.univ.sum
          (fun i => D.coordinates.symm (Pi.single i (a i))) = x ->
        a = D.coordinates x) ∧
    (∀ i, ∃ c : Real,
      D.evolution (D.component i x) = c • D.component i x) := by
  refine ⟨D.sum_components x, ?_, ?_⟩
  · intro a h
    exact (D.coordinate_representation_unique x a).mp h
  · intro i
    exact ⟨D.multiplier i, D.evolution_component i x⟩

end ObserverSpectralDecomposition

end

end ForcingAnalysis.Book5