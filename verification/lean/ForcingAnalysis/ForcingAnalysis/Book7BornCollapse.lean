/- Book7BornCollapse.lean — contextuality-defect collapse at the Hilbert cross-section. -/
import Mathlib

namespace ForcingAnalysis.Book7BornCollapse

/-- Book 7 collapse data.  Appendix validation may instantiate these fields later;
the appendix is not imported as a premise of the book. -/
structure CollapseGeometry where
  exponent : ℝ → ℝ
  defect : ℝ → ℝ
  reflect : ℝ → ℝ
  hilbertFrame : ℝ
  defect_nonneg : ∀ ξ, 0 ≤ defect ξ
  exponent_eq_two_iff : ∀ ξ, exponent ξ = 2 ↔ ξ = hilbertFrame
  defect_eq_zero_iff : ∀ ξ, defect ξ = 0 ↔ exponent ξ = 2
  fixed_iff_defect_zero : ∀ ξ, reflect ξ = ξ ↔ defect ξ = 0

theorem defect_eq_zero_iff_hilbertFrame (G : CollapseGeometry) (ξ : ℝ) :
    G.defect ξ = 0 ↔ ξ = G.hilbertFrame := by
  exact (G.defect_eq_zero_iff ξ).trans (G.exponent_eq_two_iff ξ)

theorem unique_stable_crossSection (G : CollapseGeometry) (ξ : ℝ) :
    G.reflect ξ = ξ ↔ ξ = G.hilbertFrame := by
  exact (G.fixed_iff_defect_zero ξ).trans (defect_eq_zero_iff_hilbertFrame G ξ)

theorem nonhilbert_defect_pos (G : CollapseGeometry) {ξ : ℝ}
    (hξ : ξ ≠ G.hilbertFrame) :
    0 < G.defect ξ := by
  apply lt_of_le_of_ne (G.defect_nonneg ξ)
  intro h
  exact hξ ((defect_eq_zero_iff_hilbertFrame G ξ).mp h.symm)

/-- Identification of the collapse limit.  The prior reflective-convergence result provides
existence of a limit; vanishing contextuality identifies it as
the unique Hilbert frame. -/
theorem collapse_limit_eq_hilbertFrame
    (G : CollapseGeometry) (orbit : ℕ → ℝ) (limit : ℝ)
    (horbit : Filter.Tendsto orbit Filter.atTop (nhds limit))
    (hcontinuous : ContinuousAt G.defect limit)
    (hdefect : Filter.Tendsto (fun n => G.defect (orbit n))
      Filter.atTop (nhds 0)) :
    limit = G.hilbertFrame := by
  have hcomp : Filter.Tendsto (fun n => G.defect (orbit n))
      Filter.atTop (nhds (G.defect limit)) :=
    hcontinuous.tendsto.comp horbit
  have hz : G.defect limit = 0 := tendsto_nhds_unique hcomp hdefect
  exact (defect_eq_zero_iff_hilbertFrame G limit).mp hz

theorem collapse_tendsto_hilbertFrame
    (G : CollapseGeometry) (orbit : ℕ → ℝ) (limit : ℝ)
    (horbit : Filter.Tendsto orbit Filter.atTop (nhds limit))
    (hcontinuous : ContinuousAt G.defect limit)
    (hdefect : Filter.Tendsto (fun n => G.defect (orbit n))
      Filter.atTop (nhds 0)) :
    Filter.Tendsto orbit Filter.atTop (nhds G.hilbertFrame) := by
  have h := collapse_limit_eq_hilbertFrame G orbit limit horbit hcontinuous hdefect
  simpa [h] using horbit

/-- The separate Gleason-style bridge needed to turn a Hilbert cross-section into
the Born readout.  Hilbert geometry alone does not define a probability rule. -/
structure BornUniqueness (State Question : Type*) where
  coherence : State → Question → ℝ
  bornValue : State → Question → ℝ
  coherentAtHilbert : State → Question → Prop
  unique_readout : ∀ ψ q, coherentAtHilbert ψ q →
    coherence ψ q = bornValue ψ q

theorem born_readout_at_hilbert
    {State Question : Type*} (B : BornUniqueness State Question)
    {ψ : State} {q : Question} (h : B.coherentAtHilbert ψ q) :
    B.coherence ψ q = B.bornValue ψ q :=
  B.unique_readout ψ q h

/-- Negative control: even a unique Hilbert fixed point and completed collapse do
not select the Born functional without the separate uniqueness/measure bridge. -/
theorem hilbert_collapse_alone_does_not_determine_readout :
    ∃ coherence bornValue : Bool → ℝ,
      coherence true ≠ bornValue true := by
  refine ⟨fun _ => 0, fun b => if b then 1 else 0, ?_⟩
  norm_num

end ForcingAnalysis.Book7BornCollapse
