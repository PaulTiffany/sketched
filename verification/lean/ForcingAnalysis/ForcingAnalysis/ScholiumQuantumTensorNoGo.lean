/- ScholiumQuantumTensorNoGo.lean — a typed finite-dimensional tensor no-go. -/
import Mathlib

namespace ForcingAnalysis.ScholiumQuantumTensorNoGo

open scoped TensorProduct

/-- A nontrivial finite-dimensional state space cannot be linearly identified
with its self-tensor product. This is the typed dimension obstruction hidden by
the source equation whose two sides lived in different spaces. -/
theorem no_self_tensor_linearEquiv
    {K H : Type*} [Field K] [AddCommGroup H] [Module K H] [FiniteDimensional K H]
    (hnontrivial : 1 < Module.finrank K H) :
    ¬ Nonempty ((H ⊗[K] H) ≃ₗ[K] H) := by
  rintro ⟨equiv⟩
  have hdim := equiv.finrank_eq
  rw [Module.finrank_tensorProduct] at hdim
  nlinarith

/-- Any proposed lossless linear closure of tensor pairing back into the same
nontrivial finite-dimensional carrier contradicts the dimension theorem. -/
theorem no_lossless_tensor_closure
    {K H : Type*} [Field K] [AddCommGroup H] [Module K H] [FiniteDimensional K H]
    (hnontrivial : 1 < Module.finrank K H)
    (encode : (H ⊗[K] H) ≃ₗ[K] H) : False :=
  no_self_tensor_linearEquiv hnontrivial ⟨encode⟩

/-- Dimension one is the sharp boundary: the tensor square can be linearly
identified with the original carrier. Thus linearity alone is not a universal
incompatibility theorem. -/
theorem self_tensor_linearEquiv_exists_dim_one (K : Type*) [Field K] :
    Nonempty (((K ⊗[K] K)) ≃ₗ[K] K) := by
  apply FiniteDimensional.nonempty_linearEquiv_of_finrank_eq
  simp [Module.finrank_tensorProduct]

/-- The obstruction is exactly the elementary equation n^2 = n: for positive
finite dimension it forces n = 1. -/
theorem self_tensor_finrank_eq_forces_one
    {K H : Type*} [Field K] [AddCommGroup H] [Module K H] [FiniteDimensional K H]
    (hpositive : 0 < Module.finrank K H)
    (heq : Module.finrank K (H ⊗[K] H) = Module.finrank K H) :
    Module.finrank K H = 1 := by
  rw [Module.finrank_tensorProduct] at heq
  nlinarith

end ForcingAnalysis.ScholiumQuantumTensorNoGo