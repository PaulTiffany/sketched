/- AppendixTitansArrow.lean — downstream test-time memory and temporal orientation. -/
import ForcingAnalysis.AppendixDH

namespace ForcingAnalysis.AppendixTitansArrow

open ForcingAnalysis.AppendixDH

/-- The precise bridge needed to read an external test-time learning process
as an instance of the Appendix C memory dynamics.  The empirical system must
supply the history order and positive memory-cost laws; its name alone does
not supply them. -/
structure TitansWitness (X H : Type) where
  memoryAct : MemoryAct X H

def memorize {X H : Type} (p : TitansWitness X H) (s : X × H) : X × H :=
  p.memoryAct.step s

theorem memorization_changes_history {X H : Type}
    (p : TitansWitness X H) (s : X × H) :
    (memorize p s).2 ≠ s.2 :=
  memoryAct_hist_changes p.memoryAct s

theorem memorization_has_positive_cost {X H : Type}
    (p : TitansWitness X H) (s : X × H) :
    0 < p.memoryAct.cost s :=
  memoryAct_irreversible p.memoryAct s

/-- Conditional kernel of the printed arrow-of-time theorem: once the
test-time process is witnessed as a memory act, no positive iterate returns
to its original history. -/
theorem titans_arrow_of_time {X H : Type}
    (p : TitansWitness X H) (s : X × H) (n : ℕ) (hn : 0 < n) :
    (p.memoryAct.step^[n] s).2 ≠ s.2 :=
  memoryAct_no_return p.memoryAct s n hn

/-- Even an exact return in the visible/model coordinate is not a return of
the full history-bearing state. -/
theorem visible_return_is_not_full_return {X H : Type}
    (p : TitansWitness X H) (s : X × H)
    (hvisible : (memorize p s).1 = s.1) :
    (memorize p s).1 = s.1 ∧ memorize p s ≠ s := by
  refine ⟨hvisible, ?_⟩
  intro hfull
  exact memorization_changes_history p s (congrArg Prod.snd hfull)

/-- Countermodel to the unguarded empirical inference: a bare test-time
state update can be reversible.  An external implementation must therefore
be shown to satisfy the history and cost fields of `TitansWitness`. -/
theorem bare_testTime_update_need_not_be_irreversible :
    ∃ (step : Bool → Bool) (s : Bool), step (step s) = s := by
  exact ⟨not, false, rfl⟩

end ForcingAnalysis.AppendixTitansArrow
