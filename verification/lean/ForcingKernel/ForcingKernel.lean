/-
ForcingKernel — the smallest proof-assistant formalization target of
forcing_correspondence_v15: the abstract site/forcing/generic kernel.

Verified here (relative to core Lean 4 + classical choice only):
  * lem:sitebound  — site_bound            (Site.lean)
  * lem:pers       — Forces…persist + forces_consistent (Forcing.lean)
  * lem:dec        — deciding_dense        (Forcing.lean)
  * lem:atomic (⇒) — stab_forces_atom      (Forcing.lean)
  * Rasiowa–Sikorski — rasiowa_sikorski    (Generic.lean)
  * thm:prop       — truth_lemma, exists_generic_truth (Generic.lean)
  * schema (D)     — Commutes / RelationallyCommutes / Equivariant
                     + forces_relationallyCommutes (Schema.lean); the
                     paper's common-schema claim is abstract-level prose
                     with no label yet — see the Lean PS ledger
  * witness kernel — WitnessSystem / CertifiedTransport / AdmissibleClass
                     (Witness.lean, Principia-anchored): local M-Pers
                     DERIVED from witness restriction (stable_persist +
                     the Persistent instance), material persistence across
                     an admissible class, preservation/reflection
                     separated (ProjectiveExample), and two axiom-free
                     countermodels: agreement-is-not-persistence and the
                     naturality gap — see ledger LPS-O3
  * deployed spine — Spine.lean: the model checker's 7-condition spine
                     model with generator-anchor certificates; M-Pers for
                     the deployed Stab DERIVED (the Python
                     `assert M.persistent()` becomes a theorem), E2
                     promoted to all formulas / every topology,
                     restriction functoriality, and the TTIE
                     boundary-agreement expansion theorem

Not formalized (modeling layer, by design): everything mentioning the
Hypothesis Surface apparatus — Γ, certificates, channel margins, metric
completion (needs mathlib analysis), Cacophony contracts. Those enter
only as the named hypotheses [Persistent V] (M-Pers), enum (M-Bound),
and hdense (Site Bound for the deployed generators).
-/

import ForcingKernel.Site
import ForcingKernel.Forcing
import ForcingKernel.Generic
import ForcingKernel.Margin
import ForcingKernel.Schema
import ForcingKernel.Witness
import ForcingKernel.Process
import ForcingKernel.Spine

namespace ForcingKernel

/- Axiom audit: the kernel should use only propext / Classical.choice /
Quot.sound. The build prints the dependency of each headline theorem. -/
#print axioms site_bound
#print axioms forces_consistent
#print axioms deciding_dense
#print axioms rasiowa_sikorski
#print axioms truth_lemma
#print axioms exists_generic_truth
#print axioms margin_path_form
#print axioms per_step_bound_insufficient
#print axioms equivariant_iff_commutes
#print axioms Commutes.relationallyCommutes
#print axioms forces_relationallyCommutes
#print axioms WitnessSystem.stable_persist
#print axioms AdmissibleClass.material_persistence
#print axioms CertifiedTransport.reflects_of_inverse
#print axioms agreement_not_persistent
#print axioms no_witness_realization
#print axioms ProjectiveExample.preserves_not_reflects
#print axioms NaturalityGap.naturality_defect
#print axioms seasons_may_overlap
#print axioms no_season_may_apply
#print axioms deterministicOnly_excludes_human
#print axioms properties_independent
#print axioms restrict_functorial
#print axioms restrict_refl
#print axioms stableA_a_iff
#print axioms stableA_b_iff
#print axioms stableA_a_fails_right
#print axioms spine_forces_persist
#print axioms spine_stab_forces_atom
#print axioms plus_certificate_unique
#print axioms ttie_boundary_agreement
#print axioms shared_boundary_resolved_at_leaf

end ForcingKernel
