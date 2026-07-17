/-
ForcingAnalysis — the mathlib-backed analytic layer of
forcing_correspondence_v15, complementing the core-Lean ForcingKernel:

  * lem:cauchy  — cauchy_forcing_completion   (Descent.lean)
  * lem:ordmet  — order_metric_compatibility  (Descent.lean)
  * thm:nonid   — transport_identity_iff_residue,
                  projection_loss_zero_iff_residue (Transport.lean)
  * prop:chi    — exportability_identity      (Transport.lean)
  * prop:zombie — observer_closed_iff_zero_defect,
                  zombie_off_channel           (Transport.lean, v16)
  * Lean PS physics instance (no paper label; see the Lean PS ledger) —
                  lorentzForce_covariant, lorentzForce_equivariant,
                  lorentzForce_reflects, lorentzForce_reflects_antisym
                  (LPS-O1 closed), antisym_reflection_fails_dim1,
                  zero_map_equivariant_not_lorentz,
                  actF_antisymm                (Lorentz.lean; consumes
                  ForcingKernel.Equivariant via the path dependency —
                  the same schema the forcing instance instantiates)

lem:margin's Weyl step is now formalized (WeylMargin.lean: the raw
Rayleigh-margin perturbation bound and the end-to-end path lemma;
the order-arithmetic remainder was already machine-checked in
ForcingKernel/Margin.lean). Still not formalized: everything touching
the Hypothesis Surface apparatus.
-/

import ForcingAnalysis.Descent
import ForcingAnalysis.Transport
import ForcingAnalysis.Lorentz
import ForcingAnalysis.Newton
import ForcingAnalysis.Book5
import ForcingAnalysis.Book5Thermodynamics
import ForcingAnalysis.Book5Reciprocity
import ForcingAnalysis.Book5Spectrum
import ForcingAnalysis.Book5Norm
import ForcingAnalysis.Book5NormPhase
import ForcingAnalysis.Book5NormInfinity
import ForcingAnalysis.Book5NormEquality
import ForcingAnalysis.Book5Decoherence
import ForcingAnalysis.Book5ProductSpectrum
import ForcingAnalysis.Book5SpectralDecomposition
import ForcingAnalysis.Book5Life
import ForcingAnalysis.Book5MAP
import ForcingAnalysis.Book2
import ForcingAnalysis.Contraction
import ForcingAnalysis.Book3
import ForcingAnalysis.Book3WellPosedness
import ForcingAnalysis.Book3Helmholtz
import ForcingAnalysis.Book3NetworkEmergence
import ForcingAnalysis.Book3CanonicalLife
import ForcingAnalysis.Book8
import ForcingAnalysis.Book6
import ForcingAnalysis.Book7
import ForcingAnalysis.Book4A
import ForcingAnalysis.Book4FieldRegularization
import ForcingAnalysis.Book4Meaning
import ForcingAnalysis.Book4QuantumMeasurement
import ForcingAnalysis.Book4StatisticalMechanics
import ForcingAnalysis.Book4Holographic
import ForcingAnalysis.Book5Hysteresis
import ForcingAnalysis.Book5DualityProof
import ForcingAnalysis.Book5StrategyBalance
import ForcingAnalysis.Book5ConvergenceMAP
import ForcingAnalysis.Book5ESSEquivalence
import ForcingAnalysis.Book5OperatorSelection
import ForcingAnalysis.Book5OperatorAdaptation
import ForcingAnalysis.Book5ReflectiveAccuracy
import ForcingAnalysis.Book5ShadeTransfer
import ForcingAnalysis.Book6DriftMutation
import ForcingAnalysis.Book6ThermodynamicMutation
import ForcingAnalysis.Book6ConfidenceGradient
import ForcingAnalysis.Book6ThermodynamicConsistency
import ForcingAnalysis.Book4ImaginationGuard
import ForcingAnalysis.Book4ImaginationDetector
import ForcingAnalysis.Book6ConfidenceStability
import ForcingAnalysis.Book6ObserverExtension
import ForcingAnalysis.Book8OrientationSignposting
import ForcingAnalysis.Book7SystemicPower
import ForcingAnalysis.Book8CognitiveScaffold
import ForcingAnalysis.Book8ConsciousnessAttribution
import ForcingAnalysis.Book7NoInteriorTransition
import ForcingAnalysis.Book8OptimalProjectionPath
import ForcingAnalysis.Book9ReflectiveAwakening
import ForcingAnalysis.Book7PISU
import ForcingAnalysis.AppendixCoherenceAxioms
import ForcingAnalysis.AppendixMemoryMinimality
import ForcingAnalysis.Book7ProceduralDetection
import ForcingAnalysis.Book8CriticalProjection
import ForcingAnalysis.Book9CurvatureRepair
import ForcingAnalysis.Book6GraceBasin
import ForcingAnalysis.Book9CollapseEscape
import ForcingAnalysis.Book7NoncontextualHilbert
import ForcingAnalysis.Book7LpRegression
import ForcingAnalysis.Book7BornCollapse
import ForcingAnalysis.Book8FramingEquivalence
import ForcingAnalysis.Book8SRConvergence
import ForcingAnalysis.Book9CurvatureScarring
import ForcingAnalysis.Book9EthicalIntervention
import ForcingAnalysis.AppendixCurvatureFlows
import ForcingAnalysis.Book6ThermodynamicMAP
import ForcingAnalysis.Book4B
import ForcingAnalysis.Book9
import ForcingAnalysis.AppendixDH
import ForcingAnalysis.AppendixTitansArrow
import ForcingAnalysis.ScholiumA
import ForcingAnalysis.Contraction3
import ForcingAnalysis.FabricPC
import ForcingAnalysis.Poetry
import ForcingAnalysis.WickedGeometry
import ForcingAnalysis.Book2Temperature
import ForcingAnalysis.PoetryFuzzy
import ForcingAnalysis.SRMFHelix
import ForcingAnalysis.FabricPCGuard
import ForcingAnalysis.WeylMargin
import ForcingAnalysis.ApparentOrigin
import ForcingAnalysis.WhiteHole
import ForcingAnalysis.AxiomataPrima
import ForcingAnalysis.FracturedAtlas
import ForcingAnalysis.AtlasHolonomy
import ForcingAnalysis.AtlasTower
import ForcingAnalysis.ScholiumDynamics
import ForcingAnalysis.ScholiumHorizon
import ForcingAnalysis.Book8Freedom
import ForcingAnalysis.BornCoherence
import ForcingAnalysis.Conservation
import ForcingAnalysis.ScholiumBridge
import ForcingAnalysis.Book5Operators
import ForcingAnalysis.Book5Adaptation
import ForcingAnalysis.Book5Alignment
import ForcingAnalysis.Book5Dominance
import ForcingAnalysis.Book5EquilibriumConservation
import ForcingAnalysis.Book5EnhancedDuality
import ForcingAnalysis.Book5TransitionDynamics
import ForcingAnalysis.Book4Refinement
import ForcingAnalysis.ThermoResilience
import ForcingAnalysis.Book4Fuzzy
import ForcingAnalysis.OrganismalSelfhood
import ForcingAnalysis.Book4C
import ForcingAnalysis.Book4D
import ForcingAnalysis.Book4FuzzyConnection
import ForcingAnalysis.Book4GeodesicFailure
import ForcingAnalysis.Book4ObserverGeometry
import ForcingAnalysis.Book4Gauge
import ForcingAnalysis.Book4QuantumGeometry
import ForcingAnalysis.Book4MetricLearning
import ForcingAnalysis.Book4InformationCurvature
import ForcingAnalysis.ScholiumC
import ForcingAnalysis.ScholiumD
import ForcingAnalysis.Book5Residue
import ForcingAnalysis.Book9B
import ForcingAnalysis.Book68B
import ForcingAnalysis.Book7B
import ForcingAnalysis.ScholiumB
import ForcingAnalysis.SmallPack
import ForcingAnalysis.Asymptotics
import ForcingAnalysis.Book2H
import ForcingAnalysis.Book2Response
import ForcingAnalysis.Book2Consistency
import ForcingAnalysis.Contraction2

namespace ForcingAnalysis

-- Receipt audit surface; keep theorem prints observable to the generator.
#print axioms cauchy_forcing_completion
#print axioms order_metric_compatibility
#print axioms transport_identity_iff_residue
#print axioms projection_loss_zero_iff_residue
#print axioms exportability_identity
#print axioms observer_closed_iff_zero_defect
#print axioms zombie_off_channel
#print axioms lorentzForce_covariant
#print axioms lorentzForce_equivariant
#print axioms lorentzForce_reflects
#print axioms lorentzForce_reflects_antisym
#print axioms antisym_reflection_fails_dim1
#print axioms zero_map_equivariant_not_lorentz
#print axioms actF_antisymm
#print axioms galilean_boost_accel
#print axioms newtonForce_equivariant
#print axioms accelerated_frame_defect
#print axioms accelerated_frame_defect_ne
#print axioms closureMatrix_eigen_gold
#print axioms gold_unique_positive_root
#print axioms balanced_memory_tendsto_gold
#print axioms sqrt2_first_fracture
#print axioms diag_fracture_ratio
#print axioms constants_complementary
#print axioms Book5.viable_iff_positive_free_energy
#print axioms Book5.not_viable_of_energy_le_entropic_cost
#print axioms Book5.energy_rate_eq_neg_entropic_rate
#print axioms Book5.entropy_rate_nonnegative
#print axioms Book5.entropy_rate_eq_zero_iff_fixed
#print axioms Book5.persists_iff_positive_throughout
#print axioms Book5.covenant_stable_iff_threshold
#print axioms Book5.reciprocityRate_characteristic
#print axioms Book5.reciprocityMatrix_eigen
#print axioms Book5.reciprocityRate_one
#print axioms Book5.reciprocityRate_subgolden
#print axioms Book5.reciprocityRate_supergolden
#print axioms Book5.balanced_observer_weights_unique
#print axioms Book5.lpPowerOn_nonneg
#print axioms Book5.axisCostOn_nonneg
#print axioms Book5.lpPowerOn_le_axisCostOn_rpow
#print axioms Book5.axisCostOn_rpow_le_card_mul_lpPowerOn
#print axioms Book5.lpCostOn_le_axisCostOn
#print axioms Book5.axisCostOn_le_card_rpow_mul_lpCostOn
#print axioms Book5.axisCostOn_equalMagnitude
#print axioms Book5.lpPowerOn_equalMagnitude
#print axioms Book5.lpCostOn_equalMagnitude
#print axioms Book5.equalMagnitude_ratio
#print axioms Book5.symbolicTorsion_eq_equalMagnitude_ratio_sub_one
#print axioms Book5.symbolicTorsion_one
#print axioms Book5.effectiveSupportDimension_eq
#print axioms Book5.effectiveSupportDimension_one
#print axioms Book5.symbolicTorsion_two_two
#print axioms Book5.symbolicTorsion_mono_exponent
#print axioms Book5.effectiveSupportDimension_two
#print axioms Book5.supportCostOn_nonneg
#print axioms Book5.supportCostOn_le_axisCostOn
#print axioms Book5.axisCostOn_le_card_mul_supportCostOn
#print axioms Book5.supportCostOn_equalMagnitude
#print axioms Book5.equalMagnitude_infinity_ratio
#print axioms Book5.symbolicTorsionInfinity_eq_ratio_sub_one
#print axioms Book5.effectiveSupportDimensionInfinity_eq_two
#print axioms Book5.effectiveSupportDimensionInfinity_log_ratio
#print axioms Book5.infinity_ratio_bounds
#print axioms Book5.symbolicTorsionInfinity_tendsto_atTop
#print axioms Book5.infinity_sharp_iff_equal_magnitudes
#print axioms Book5.powered_sharp_implies_equal_magnitudes
#print axioms Book5.equal_magnitudes_imply_powered_sharp
#print axioms Book5.powered_sharp_iff_equal_magnitudes
#print axioms Book5.sharp_norm_bound_implies_equal_magnitudes
#print axioms Book5.sharp_norm_bound_iff_equal_magnitudes
#print axioms Book5.shortestGeometric_le_shortestSymbolic
#print axioms Book5.symbolicDecoherence_nonneg
#print axioms Book5.symbolicDecoherence_eq_zero_iff
#print axioms Book5.symbolicDecoherence_pos_iff
#print axioms Book5.symbolicDecoherence_eq_zero_iff_has_symbolic_geodesic
#print axioms Book5.diagonalDecoherence_formula
#print axioms Book5.diagonalDecoherence_pos
#print axioms Book5.diagonal_symbolic_longer
#print axioms Book5.normDiagnosticRatio_axis
#print axioms Book5.normDiagnosticRatio_euclidean
#print axioms Book5.normDiagnosticRatio_support
#print axioms Book5.balancedSpectrum_memory
#print axioms Book5.balancedSpectrum_norm
#print axioms Book5.balanced_memory_resonance_unique
#print axioms Book5.changing_norm_preserves_balanced_memory
#print axioms Book5.norm_and_memory_coordinates_independent
#print axioms Book5.support_collapse_forgets_distribution
#print axioms Book5.elementary_spectrum_values
#print axioms Book5.euclidean_balanced_product_spectrum
#print axioms Book5.balanced_memory_converges_to_spectrum_memory
#print axioms Book5.fundamental_norm_fracture_kernel
#print axioms Book5.ObserverSpectralDecomposition.coordinates_component_same
#print axioms Book5.ObserverSpectralDecomposition.coordinates_component_other
#print axioms Book5.ObserverSpectralDecomposition.sum_components
#print axioms Book5.ObserverSpectralDecomposition.coordinate_representation_unique
#print axioms Book5.ObserverSpectralDecomposition.evolution_component
#print axioms Book5.ObserverSpectralDecomposition.component_is_invariant
#print axioms Book5.ObserverSpectralDecomposition.spectral_decomposition_kernel

#print axioms Book5.stabilized_energy_rate_eq_external
#print axioms Book5.closed_stabilized_energy_rate_zero
#print axioms Book5.stabilized_conservation_iff_closed
#print axioms Book5.balance_alone_does_not_force_conservation
#print axioms Book5.symbolic_life_criterion
#print axioms Book5.metabolic_necessity
#print axioms Book5.positive_persistence_has_metabolism
#print axioms Book5.agreement_on_positive_persistence_does_not_supply_life_law
#print axioms Book5.diagonal_l1_l2_ratio
#print axioms Book5.diagonal_l1_linf_ratio
#print axioms Book5.same_memory_does_not_fix_norm
#print axioms Book5.same_norm_does_not_fix_memory
#print axioms Book5.map_eventually_viable
#print axioms Book5.map_joint_eventually_viable
#print axioms Book5.viable_collapsed_exclusive
#print axioms Book5.contraction_map
#print axioms Book5.dual_dual
#print axioms Book5.dual_couplingStrength
#print axioms Book5.dual_surplus_reflect
#print axioms Book5.covenant_map_viable
#print axioms Book5.covenant_mad_collapse
#print axioms Book5.cooperation_nash
#print axioms Book5.defection_nash
#print axioms Book5.cooperation_dominates
#print axioms Book5.spectral_iff_thermal
#print axioms Book5.lambdaCrit_mono
#print axioms Book2.gibbs_isDensity
#print axioms Book2.gibbs_inequality
#print axioms Book2.entropy_nonneg
#print axioms Book2.entropy_le_log_card
#print axioms Book2.freeEnergy_gibbs
#print axioms Book2.gibbs_minimizes
#print axioms Book2.gibbs_unique_minimizer
#print axioms Book2.evolve_conserves
#print axioms Book2.detailedBalance_stationary
#print axioms Book2.cycle_stationary_not_reversible
#print axioms Book2.no_finite_phase_transition
#print axioms Book2.energy_eq_neg_deriv_log_partition
#print axioms boost_isLorentz
#print axioms gamma_tendsto_one
#print axioms boost_tendsto_galilean
#print axioms scaled_metric_eq
#print axioms metric_degenerates
#print axioms Book3.membrane_complement_permeability_mem
#print axioms Book3.exists_static_membrane
#print axioms Book3.canonicalMembrane_stability_pos
#print axioms Book3.exists_static_membrane_at_smaller_bound
#print axioms Book3Helmholtz.finite_helmholtz_reconstruction
#print axioms Book3Helmholtz.integrativeComponent_mem
#print axioms Book3Helmholtz.differentiativeComponent_mem_orthogonal
#print axioms Book3Helmholtz.components_inner_eq_zero
#print axioms Book3Helmholtz.finite_helmholtz_unique
#print axioms Book3.assembled_network_stability_pos
#print axioms Book3.growth_alone_does_not_generate_network
#print axioms Book3CanonicalLife.persistentLife_satisfies_canonical
#print axioms Book3CanonicalLife.persistence_alone_does_not_supply_correspondence
#print axioms Book3.membrane_viable_iff
#print axioms Book3.membrane_stable_of_conditions
#print axioms Book3.membrane_stable_permeability_lt_one
#print axioms Book3.couplingEnergy_nonneg
#print axioms Book3.coupled_drift_deviation_bound
#print axioms Book3.in_symbiosis_of_conditions
#print axioms Book3.symbiosis_drift_perturbation_ne_zero
#print axioms Book3.symbiotic_threshold_clears_i
#print axioms Book3.symbiotic_threshold_clears_j
#print axioms Book3.reflexive_encoding_information_strictly_preserved
#print axioms Book3.cyclic_distortion_bound
#print axioms Book3.reflexive_pair_generates_bridge
#print axioms Book3.symbioticCurvature_pos
#print axioms Book3.symbioticCurvature_gt_one
#print axioms Book3.symbioticCurvature_mono_info
#print axioms Book3.weighted_avg_le_max
#print axioms Book3.resilience_bound_antitone
#print axioms Book3.integration_rate_eq
#print axioms Book3.knowledge_structure_telescopes
#print axioms Book3.sustained_growth_window
#print axioms Book3.metabolicRate_nonneg
#print axioms Book3.homeostatic_band_nonempty
#print axioms Book3.metabolic_response_deviation_bound
#print axioms Book3.persistentLife_kappa_pos
#print axioms Book3.persistentLife_rmin_le_rmax
#print axioms Book8.material_specialize
#print axioms Book8.visible_to_observer_zero
#print axioms Book8.not_material_visible_example
#print axioms Book8.meaning_preserved_at_fixed_point
#print axioms Book8.bool_swap_no_fixed_points
#print axioms Book8.inverse_of_drift_not_stasis
#print axioms Book8.loss_positive_of_imperfect_stability
#print axioms Book8.universal_embedding_epsilon_nonneg
#print axioms Book8.perfect_translation_forces_maximal_stability
#print axioms Book8.frameResidual_eq_zero_iff
#print axioms Book8.collapse_within_threshold
#print axioms Book8.drift_cancellation
#print axioms Book8.reflective_permutation_assoc
#print axioms Book8.metabolicSufficiency_decrease_accum
#print axioms Book8.metabolicSufficiency_terminates
#print axioms Book8.cycleViability_ratio_lt_one
#print axioms Book8.freeWillLoss_le
#print axioms Book8.freeWillLoss_nonneg
#print axioms Book8.debuggingFavored_net_gain
#print axioms Book8.finiteThermodynamicSnapshot_freeEnergy
#print axioms Book8.debugging_preserves_finite_viability
#print axioms Book8.reflectiveSelection_exists
#print axioms Book6.mutationTriggered_iff_signed
#print axioms Book6.bifurcation_classification_exhaustive
#print axioms Book6.bifurcation_classification_exclusive
#print axioms Book6.bifurcation_threshold_dichotomy
#print axioms Book6.bifurcation_threshold_exclusive
#print axioms Book6.divergenceLaw_energy_rate_pos
#print axioms Book6.reflective_inhibition_limit
#print axioms Book6.entropyRegulation_iterate_le
#print axioms Book6.mutationMemory_monotone
#print axioms Book6.mutationMemory_nonneg
#print axioms Book6.entropyGrowth_accum
#print axioms Book6.entropyGrowth_unbounded
#print axioms Book6.regulatoryCycle_energy_bound
#print axioms Book6.configDim_mono
#print axioms Book6.configDim_ge
#print axioms Book6.identityCarrier_le_self
#print axioms Book6.temperature_pos_iff
#print axioms Book6.freeEnergy_antitone_in_entropy
#print axioms Book6.transformationFamily_triple
#print axioms Book6.transformationFamily_bracketing_agrees
#print axioms Book6.bifurcation_offset_pos
#print axioms Book6.no_retraction_of_not_injective
#print axioms Book6.mutationBifurcationBridge_iff
#print axioms Book6.regulatoryBasin_power_argmax_exists
#print axioms Book6.confidence_sigma_pos
#print axioms Book6.closedPower_exchange_sum_zero
#print axioms Book6.closedPower_total_conserved
#print axioms Book6.totalPairPower_eq_metabolicRate
#print axioms Book6.closedPower_homeostatic_step
#print axioms Book6.closedPower_homeostatic_all
#print axioms Book6.confidencePower_gaussian_bound
#print axioms Book6.symbolicInformation_relabel_invariant
#print axioms Book7.dualityRecovers
#print axioms Book7.involutive_pair_witness
#print axioms Book7.dz_zero_of_le
#print axioms Book7.dz_contraction_bound
#print axioms Book7.deadband_contraction
#print axioms Book7.deadband_region_invariant
#print axioms Book7.deadband_strict_decrease
#print axioms Book7.deadband_confidence_ascent
#print axioms Book7.deadband_geometric_decay
#print axioms Book7.selfCorrection_succeeds
#print axioms Book7.selfCorrection_fails_as_gain_vanishes
#print axioms Book7.selfCorrection_fails_as_disturbance_grows
#print axioms Book7.caristiDescent_sum_le_energy_drop
#print axioms Book7.caristiDescent_total_displacement_bound
#print axioms Book7.geometric_gap_decay
#print axioms Book7.orbitLimit_idempotent
#print axioms Book7.orbitLimit_linear_image_kernel_split
#print axioms Book7.orbitLimit_derivative_image_kernel_split
#print axioms Book7.orbitLimit_completeJacobian
#print axioms Book7.orbitLimit_fixedLocusVelocity_iff
#print axioms Book7.orbitLimit_transverse_contracts
#print axioms Book7.orbitLimit_transverse_iterates_tendsto_zero
#print axioms Book7.orbitLimit_transverse_eigenvalue_stable
#print axioms Book7.orbitLimit_transverse_jacobian_eigenmode_stable
#print axioms Book7.orbitLimit_completeJacobian_semigroup
#print axioms Book7.orbitLimit_semigroup_transverse_eigenmode_tendsto_zero
#print axioms Book7.orbitLimit_base_fixed_but_recorded
#print axioms Book7.tendsto_refinement_to_orbitLimit
#print axioms Book7.orbitLimit_iterate_fixed_under_representation
#print axioms Book7.product_contraction
#print axioms Book7.mutualLimit_fixed
#print axioms Book7.reciprocalPair_unique
#print axioms Book7.tendsto_mutualRefinement
#print axioms Book7.contraction_step
#print axioms Book7.exponent_uniqueness
#print axioms Book7.l1_l2_comparison
#print axioms Book7.square_strictly_convex_midpoint
#print axioms Book4A.stability_lower_bound
#print axioms Book4A.recursive_encoding_partial_sum_le_total
#print axioms Book4A.RecursiveEncoding.cauchySeq
#print axioms Book4A.RecursiveEncoding.exists_limit_with_tail_bound
#print axioms Book4A.RecursiveEncoding.exists_fixed_limit_with_tail_bound
#print axioms Book4A.operator_noncommutativity_witness
#print axioms Book4A.selfReferenceIterate_succ
#print axioms Book4A.selfReference_fixed_point
#print axioms Book4A.boundary_forms_dichotomy
#print axioms Book4A.kappa_nonneg
#print axioms Book4A.kappa_scale
#print axioms Book4A.kappa_reflexive_vanishing
#print axioms Book4A.kappa_observer_dependent
#print axioms Book4A.transitionRate_pos
#print axioms Book4A.autoEncoderPattern_pos
#print axioms Book4A.timescaleSeparation_micro_lt_observation
#print axioms Book4A.autoEncoder_finite_sum_le
#print axioms Book4A.SymbolicAutoEncoder.exact_reconstruction_of_eps_eq_zero
#print axioms Book4A.SymbolicAutoEncoder.identityPattern_eq_one_iff
#print axioms Book4A.SymbolicAutoEncoder.encode_injective_of_eps_eq_zero
#print axioms Book4A.complexSymbolicDistance_re
#print axioms Book4A.complexSymbolicDistance_im
#print axioms Book4A.complexSymbolicDistance_re_le_abs
#print axioms Book4A.reintegrableIdentity_iff
#print axioms Book4A.ReintegrableIdentity.mono_thresholds
#print axioms Book4A.not_reintegrableIdentity_iff
#print axioms Book4A.uncanny_recognition_countermodel
#print axioms Book4A.quadrant_exhaustive
#print axioms Book4A.quadrants_disjoint
#print axioms Book4A.spiralMagnitude_recurrence
#print axioms Book4A.spiralPhase_recurrence
#print axioms Book4A.goldenRatio_sq
#print axioms Book4A.goldenSpiral_recurrence
#print axioms Book4A.goldenRatio_pos
#print axioms Book4A.goldenSpiral_ratio_eq
#print axioms Book4A.goldenSpiral_ratio_tendsto
#print axioms Book4A.contractionRefinement_iterate
#print axioms Book4A.ContractionRefinement.contractingWith
#print axioms Book4A.ContractionRefinement.ttprLimit_fixed
#print axioms Book4A.ContractionRefinement.fixed_eq_ttprLimit
#print axioms Book4A.ContractionRefinement.tendsto_iterate_ttprLimit
#print axioms Book4A.ContractionRefinement.selfReference_dist_ttprLimit_le
#print axioms Book4A.ContractionRefinement.selfReference_fixed_iff_eq_ttprLimit
#print axioms Book4A.ContractionRefinement.tendsto_selfReferenceIterate
#print axioms Book4A.imbalanced_drift_exceeds_reflect
#print axioms Book4A.adjacent_rotate
#print axioms Book4A.opposite_involutive
#print axioms Book4A.opposite_add
#print axioms Book4A.swapPerm_breaks_adjacency
#print axioms Book4B.cascadeProb_nonneg
#print axioms Book4B.cascadeProb_lt_one
#print axioms Book4B.cascadeProb_strictMono
#print axioms Book4B.repairSufficiency_decrease_accum
#print axioms Book4B.repairSufficiency_terminates
#print axioms Book4B.recovery_threshold_exceeds_crit
#print axioms Book4B.coreCoherence_exceeds_crit
#print axioms Book4B.repairCapacityBound_nonneg
#print axioms Book4B.repairCapacityBound_lt_one
#print axioms Book4B.repairCapacityBound_strictMono
#print axioms Book4B.repairCapacity_lt_one
#print axioms Book4B.symbolicFreedom_of_flowFreedom
#print axioms Book4B.id_has_no_escape
#print axioms Book4B.autonomy_implies_freedom
#print axioms Book4B.freedomMeasure_nonneg
#print axioms Book4B.freedomMeasure_le_one
#print axioms Book4B.constraintDomain_strict_growth
#print axioms Book4B.mem_constraintLimit_iff
#print axioms Book4B.constraintDomain_subset_limit
#print axioms Book4B.constraintLimit_least
#print axioms Book4B.constraintDirectedSystem_universal
#print axioms Book4B.constraintLimit_tail_eq
#print axioms Book4B.constraintLimit_strict_growth
#print axioms Book4B.orbitConstraintDomain_mono
#print axioms Book4B.orbitConstraintLimit_eq_range
#print axioms Book4B.transfiniteConstraint_leastFixedPoint_fixed
#print axioms Book4B.transfiniteConstraint_leastFixedPoint_le
#print axioms Book4B.transfiniteConstraint_stage_le_fixed
#print axioms Book4B.transfiniteConstraint_stabilized_fixed
#print axioms Book4B.transfiniteConstraint_stabilized_eq_lfp
#print axioms Book4B.transfiniteIterate_exists_fixed_of_card_lt
#print axioms Book4B.transfiniteIterate_le_fixed
#print axioms Book4B.transfiniteIterate_fixed_stage_eq_lfp
#print axioms Book4B.transfiniteIterate_eventually_constant_of_fixed
#print axioms Book4B.transfiniteIterate_eventually_constant_of_card_lt
#print axioms Book4B.freedomLife_succ_lt
#print axioms Book4B.freedomLife_strictMono
#print axioms Book4B.freedomLife_increase_accum
#print axioms Book4B.boundedErrorTerm_mono_linear
#print axioms Book4B.boundedErrorTerm_mono_quadratic
#print axioms Book4B.quotientFloor_ge_eps_sq
#print axioms Book4B.fuzzyGradient_bound_antitone
#print axioms Book4B.gradientStability_same_resolution
#print axioms Book9.cognitivelyFree_iff_internal_gradient
#print axioms Book9.cognitivelyFree_of_gradient_internal
#print axioms Book9.operatorReflexive_next
#print axioms Book9.accountability_gap_lt_epsCrit
#print axioms Book9.accountability_gap_lt_epsMask
#print axioms Book9.masking_not_accountable
#print axioms Book9.bidirectionalSRMF_fwd_injective
#print axioms Book9.bidirectionalSRMF_bwd_injective
#print axioms Book9.bidirectionalSRMF_fwd_bwd_fwd
#print axioms Book9.covenantDensity_regime_exhaustive
#print axioms Book9.covenantDensity_regime_exclusive
#print axioms Book9.freedomGrowing_not_global_min
#print axioms Book9.freedomEntropyLaw_strict_max
#print axioms Book9.emergentAutonomy_min_exists
#print axioms Book9.recursiveUpdate_eq_orbit
#print axioms Book9.liberationDescent_Lambda_antitone
#print axioms Book9.liberationDescent_telescoped
#print axioms Book9.liberationDescent_converges
#print axioms Book9.liberationDescent_converges_in_closed
#print axioms Book9.uniformOperatorLimit_fixedPoint
#print axioms Book9.limit_eq_of_zeroDescent_singleton
#print axioms Book9.homeostaticLiberation_converges
#print axioms Book9.homeostaticLiberation_all
#print axioms Book9.finalCollapseInversion
#print axioms Book9.symbolicFramework_iterate
#print axioms Book9.reinterpretation_dichotomy_exhaustive
#print axioms Book9.reinterpretation_dichotomy_exclusive
#print axioms Book9.thermodynamicStress_nonneg
#print axioms AppendixDH.phi_sq
#print axioms AppendixDH.phi_gt_one
#print axioms AppendixDH.phi_pos
#print axioms AppendixDH.phi_fixed_point
#print axioms AppendixDH.sustainable_phi
#print axioms AppendixDH.sustainable_ge_phi
#print axioms AppendixDH.kappa_min_at_phi
#print axioms AppendixDH.stability_phi_flow
#print axioms AppendixDH.fixed_point_iff_phi
#print axioms AppendixDH.V_nonneg
#print axioms AppendixDH.V_eq_zero_iff
#print axioms AppendixDH.Gop_phi_eigen
#print axioms AppendixDH.Gop_step
#print axioms AppendixDH.tokensOfSet_eq_biUnion
#print axioms AppendixDH.orthogonal_token_separation
#print axioms AppendixDH.mu_le_one
#print axioms AppendixDH.mu_biUnion_eq_sum
#print axioms AppendixDH.orthogonal_additivity
#print axioms AppendixDH.mu_conservation
#print axioms AppendixDH.memoryAct_hist_changes
#print axioms AppendixDH.memoryAct_irreversible
#print axioms AppendixDH.memoryAct_order_iterate
#print axioms AppendixDH.memoryAct_no_return
#print axioms AppendixDH.dualHorizon_sufficiency
#print axioms AppendixDH.dualHorizon_necessity
#print axioms AppendixDH.dualHorizon_necessity_pos
#print axioms AppendixDH.dualHorizon_tight_biconditional
#print axioms AppendixDH.dual_horizon_signature
#print axioms AppendixDH.geodesic_convergence
#print axioms AppendixTitansArrow.memorization_changes_history
#print axioms AppendixTitansArrow.memorization_has_positive_cost
#print axioms AppendixTitansArrow.titans_arrow_of_time
#print axioms AppendixTitansArrow.visible_return_is_not_full_return
#print axioms AppendixTitansArrow.bare_testTime_update_need_not_be_irreversible
#print axioms ScholiumA.kernelBounded_le
#print axioms ScholiumA.ifValue_le_eps
#print axioms ScholiumA.nu_le_ifValue
#print axioms ScholiumA.interpretable_of_factor_and_traceable
#print axioms ScholiumA.twoStep_bound
#print axioms ScholiumA.chainedApprox_telescope
#print axioms ScholiumA.ChainedApprox.cauchySeq
#print axioms ScholiumA.ChainedApprox.exists_limit_with_tail_bound
#print axioms Book4A.chainedApprox_yields_recursiveEncoding_limit
#print axioms ScholiumA.mirror_involution_ne_id_exists
#print axioms ScholiumA.projection_idempotent_ne_id_exists
#print axioms ScholiumA.stepZMod4_four_returns
#print axioms ScholiumA.stepZMod4_two_no_return
#print axioms ScholiumA.contradictionIntensity_eq
#print axioms ScholiumA.contradictionIntensity_zero_of_lam_one
#print axioms ScholiumA.separable_mixedDiff_zero
#print axioms ScholiumA.nonseparable_of_mixedDiff_ne_zero
#print axioms ScholiumA.quadratic_not_linear
#print axioms ScholiumA.linear_double
#print axioms ScholiumA.fixedPointInheritance
#print axioms ScholiumB.reflexiveIterate_eq_iterate
#print axioms ScholiumB.reflexiveIterate_add
#print axioms ScholiumB.no_irony_of_shallow_or_flat
#print axioms ScholiumB.no_irony_of_real_only
#print axioms ScholiumB.idempotent_fixes_image
#print axioms ScholiumB.idempotent_fixLocus_nonempty
#print axioms ScholiumB.gibbsWeight_pos
#print axioms ScholiumB.gibbsZ_pos
#print axioms ScholiumB.gibbsProb_pos
#print axioms ScholiumB.gibbsProb_sum_eq_one
#print axioms ScholiumB.gibbsProb_antitone
#print axioms ScholiumB.minimalPS_collapse_ne_id
#print axioms ScholiumB.minimalPS_drift_reflection_noncommute
#print axioms ScholiumB.minimalPS_connection_curvature_nonzero
#print axioms SmallPack.resolutionLevel_mono
#print axioms SmallPack.symbolicEnergy_nonneg
#print axioms SmallPack.symbolicEnergyContraction_accum
#print axioms SmallPack.symbolicEnergyContraction_sum_bounded
#print axioms SmallPack.symbolicEnergyContraction_term_bounded
#print axioms SmallPack.chartBound_mono
#print axioms SmallPack.chartBound_nonneg
#print axioms SmallPack.inf_mono_of_subset
#print axioms SmallPack.inf_strict_decrease
#print axioms Asymptotics.Contraction.iterate_dist_le
#print axioms Asymptotics.Contraction.tendsto_fixedPt
#print axioms Asymptotics.GeometricErrorBound.tendsto_zero
#print axioms Asymptotics.QuadraticErrorBound.tendsto_zero
#print axioms Asymptotics.windowAverage_mem_unitInterval
#print axioms Asymptotics.MutationEquilibrium.eventually_pos
#print axioms Asymptotics.MutabilityEquilibrium.eta_tendsto_of_mu_tendsto
#print axioms Asymptotics.AntitoneBoundedProcess.tendsto_iInf
#print axioms Asymptotics.eventually_mem_ball_of_tendsto
#print axioms Asymptotics.AsymptoticExponentField.eventually_near_one
#print axioms Book2H.dataProcessing_kl
#print axioms Book2H.h_theorem
#print axioms Book2H.trajectory_isDensity
#print axioms Book2H.freeEnergy_trajectory_antitone
#print axioms Book2Response.fluctuation_response_hasDerivAt
#print axioms Book2Consistency.thermodynamic_consistency
#print axioms Book2Consistency.boundedCurvature_alone_insufficient
#print axioms momentum_residual_tendsto_zero
#print axioms gamma_ge_one
#print axioms gamma_mono
#print axioms momentum_residual_uniform_bound
#print axioms gamma_sub_one_tendsto_zero
#print axioms RelativisticForceLaw.a_rel_zero
#print axioms RelativisticForceLaw.a_rel_tendsto
#print axioms hasDerivAt_gammaMul
#print axioms momentum_hasDerivAt
#print axioms force_law_acceleration
#print axioms FabricPC.relaxStep_isDensity
#print axioms FabricPC.two_term_logsum
#print axioms FabricPC.relax_kl_le
#print axioms FabricPC.relax_freeEnergy_le
#print axioms Poetry.operatio_opening
#print axioms Poetry.bridge_needs_both
#print axioms Poetry.quartet_arc
#print axioms Poetry.tempered_freedom
#print axioms Poetry.negations_respected
#print axioms Poetry.no_return
#print axioms Poetry.drift_freedom_not_forward
#print axioms Poetry.drift_freedom_commonSource
#print axioms Poetry.converse_resonance_operator
#print axioms Poetry.deduction_conf
#print axioms Poetry.abduction_conf
#print axioms Poetry.gibbs_zero_uniform
#print axioms Wicked.id_transition_distortion
#print axioms Wicked.no_low_distortion_transition
#print axioms Wicked.stress_blowup
#print axioms Wicked.parentage_path
#print axioms Wicked.denial_breaks_ancestry
#print axioms Wicked.misclassification
#print axioms Wicked.repair_changes_optimum
#print axioms Wicked.grace_gradual
#print axioms Wicked.grace_geometric
#print axioms Wicked.grace_tendsto_zero
#print axioms Wicked.zero_coupling_stalls
#print axioms Book2.gibbs_le_exp
#print axioms Book2.gibbs_freezes
#print axioms Book2.gibbs_concentrates
#print axioms Poetry.zero_parameterization
#print axioms Poetry.fuzzy_bridge
#print axioms Poetry.fuzzy_full_arc
#print axioms Poetry.fuzzy_drift_forward
#print axioms SRMF.turn_closes_iff
#print axioms SRMF.turns_formula
#print axioms SRMF.helix_never_returns
#print axioms SRMF.helix_unbounded
#print axioms SRMF.strict_work_breaks_closure
#print axioms SRMF.closure_iff_no_work
#print axioms SRMF.moloch_hedge
#print axioms SRMF.with_and_was
#print axioms FabricPC.kl_nonneg
#print axioms FabricPC.guardedStep_isDensity
#print axioms FabricPC.novelty_floor
#print axioms FabricPC.guarded_ne_pointMass
#print axioms FabricPC.guarded_floor_all_temperatures
#print axioms FabricPC.three_term_logsum
#print axioms FabricPC.guarded_kl_le
#print axioms FabricPC.moloch_guard
#print axioms FabricPC.guarded_sequence_bounded
#print axioms FabricPC.guarded_arrival_iff_uniform
#print axioms Weyl.rayleigh_abs_le
#print axioms Weyl.margin_perturb_lower
#print axioms Weyl.margin_perturb_upper
#print axioms Weyl.margin_perturb
#print axioms Weyl.margin_step_drift
#print axioms Weyl.weyl_margin_path
#print axioms AOC.apparent_origin_floor
#print axioms AOC.sub_band_compressed
#print axioms AOC.above_band_faithful
#print axioms AOC.unbounded_depth_acquires_origin
#print axioms AOC.tested_floor_ge
#print axioms AOC.class_floor_not_universal
#print axioms AOC.sub_band_energy_bounded_of_finite
#print axioms AOC.false_bottom_energy
#print axioms AOC.concert_effect
#print axioms AOC.destructive_hiding
#print axioms AOC.second_order_detects_existence
#print axioms AOC.second_order_forgets_identity
#print axioms AOC.false_bottom_voids_hedge
#print axioms AOC.observed_indistinguishable
#print axioms AOC.all_orders_confounded
#print axioms AOC.no_signal_only_confirmation
#print axioms AOC.srv_confirms
#print axioms AOC.srv_verdict_exists
#print axioms AOC.self_blind_false_discovery
#print axioms AOC.full_record_required
#print axioms AxiomataPrima.mention_settles_existence
#print axioms AxiomataPrima.control_passes
#print axioms AxiomataPrima.ablation_fails
#print axioms AxiomataPrima.no_manifest_only_existence
#print axioms AxiomataPrima.import_is_witness
#print axioms AxiomataPrima.tree_verdict_exists
#print axioms AxiomataPrima.no_drift_no_novelty
#print axioms AxiomataPrima.pure_drift_dissolves
#print axioms AxiomataPrima.two_channel_sustained
#print axioms AxiomataPrima.just_is_observationally_nothing
#print axioms AxiomataPrima.everything_forces_stasis
#print axioms AxiomataPrima.gibbs_ne_uniform
#print axioms AxiomataPrima.negotiation_moves
#print axioms AxiomataPrima.selection_exists
#print axioms AxiomataPrima.negotiation_not_null
#print axioms AxiomataPrima.negotiation_not_nothing
#print axioms AxiomataPrima.no_return_past_work
#print axioms Atlas.defect_self
#print axioms Atlas.defect_symm
#print axioms Atlas.defect_triangle
#print axioms Atlas.glued_of_consistent
#print axioms Atlas.fracture_obstructs
#print axioms Atlas.consistent_of_glued
#print axioms Atlas.single_geometry_iff_glued
#print axioms Atlas.fracture_persists
#print axioms Atlas.glued_singleton
#print axioms Atlas.dual_horizon_fractured
#print axioms Atlas.no_single_geometry_for_dual_horizon
#print axioms Selfhood.aliveness_is_threshold
#print axioms Selfhood.critical_density_collapse
#print axioms Selfhood.subcritical_not_collapsed
#print axioms Selfhood.aliveness_is_observer_relative
#print axioms Selfhood.material_implies_each
#print axioms Selfhood.agreement_is_not_material
#print axioms Selfhood.stub_does_not_exist
#print axioms Selfhood.refusal_is_witnessed
#print axioms Book4C.identityResolution_gt_one_iff
#print axioms Book4C.identityResolution_threshold_persists
#print axioms Book4C.convexCombination_mem_Icc
#print axioms Book4C.srmfActionNorm_bound
#print axioms Book4C.reintegrable_of_smaller_gap
#print axioms Book4C.lipschitzPath_uniform
#print axioms Book4C.ttieExpansionBound_le_cs
#print axioms Book4C.coherenceCone_mono
#print axioms Book4C.ttieMetric_exists_of_glued
#print axioms Book4C.ttieMetric_presupposition_fails_on_dual_horizon
#print axioms Book4C.ttcs_sample_average_le
#print axioms Book4C.ttcs_sample_average_ge
#print axioms Book4C.ttcsWeight_strictAnti
#print axioms Book4C.ttcs_properties
#print axioms Book4C.ttcsEmpiricalObservableAverage_const
#print axioms Book4C.ttcs_const_empirical_tendsto
#print axioms Book4C.mem_ttcsActivatedCloud
#print axioms Book4C.ttcs_link_activation
#print axioms Book4C.neighborhoodCompleteness
#print axioms Book4C.symbolicWork_path_dependent_example
#print axioms Book4C.symbolicWork_path_independent_of_constant
#print axioms Book4C.fragMeasure_mem_Icc
#print axioms Book4C.fragMeasure_eq_zero_iff
#print axioms Book4C.symbolicIdentityCarrier_component_le_one
#print axioms Book4C.reflexiveOperator_tendsto_self
#print axioms Book4D.fuzzySubstitutionBound_eps_pos
#print axioms Book4D.fuzzySubstitutionBound_compose
#print axioms Book4D.odifferentiableAt_iff_ratio_form
#print axioms Book4D.identity_odifferentiableAt
#print axioms Book4D.const_odifferentiableAt
#print axioms Book4D.ObserverDerivativeAt.correction_eq_zero_iff_actual_eq_classical
#print axioms Book4D.ObserverDerivativeAt.add
#print axioms Book4D.ObserverDerivativeAt.mul
#print axioms Book4D.ObserverDerivativeAt.comp
#print axioms Book4D.ObserverDerivativeAt.pow
#print axioms Book4D.ObserverDerivativeAt.div
#print axioms Book4D.ObserverDerivativeAt.ofClassical
#print axioms Book4D.ObserverDerivativeAt.actualSlope_eq
#print axioms Book4D.ObserverDerivativeAt.correction_eq_of_classicalSlope_eq
#print axioms Book4D.ObserverDerivativeAt.add_correction_eq_zero
#print axioms Book4D.ObserverDerivativeAt.mul_correction_eq_zero
#print axioms Book4D.ObserverDerivativeAt.comp_correction_eq_zero
#print axioms Book4D.ObserverDerivativeAt.pow_correction_eq_zero
#print axioms Book4D.ObserverDerivativeAt.div_correction_eq_zero
#print axioms Book4D.ObserverDerivativeAt.abs_add_correction_le
#print axioms Book4D.ObserverDerivativeAt.abs_comp_correction_le
#print axioms Book4D.ObserverDerivativeAt.correctionControlled_mono
#print axioms Book4D.ObserverDerivativeAt.ofClassical_controlled
#print axioms Book4D.ObserverDerivativeAt.add_controlled
#print axioms Book4D.ObserverDerivativeAt.mul_controlled
#print axioms Book4D.ObserverDerivativeAt.comp_controlled
#print axioms Book4D.ObserverDerivativeAt.pow_controlled
#print axioms Book4D.ObserverDerivativeAt.div_controlled
#print axioms Book4D.ObserverDerivativeAt.PerturbationRequest.gate_eq_true_iff
#print axioms Book4D.ObserverDerivativeAt.PerturbationRequest.gate_eq_false_iff
#print axioms Book4D.ObserverDerivativeAt.PerturbationRequest.admissible_applied_le_budget
#print axioms Book4D.ObserverDerivativeAt.PerturbationRequest.cosmicRay_rejected
#print axioms Book4D.ObserverDerivativeAt.PerturbationRequest.zero_budget_inert
#print axioms Book4D.ObserverDerivativeAt.PerturbationRequest.rejection_mono
#print axioms Book4D.ObserverDerivativeAt.RationalPerturbationCertificate.gate_eq_true_iff
#print axioms Book4D.ObserverDerivativeAt.RationalPerturbationCertificate.admissible_applied_le_budget
#print axioms Book4D.ObserverDerivativeAt.RationalPerturbationCertificate.real_sound
#print axioms Book4D.FuzzyOperator.identity_map
#print axioms Book4D.FuzzyOperator.forwardThen_map
#print axioms Book4D.FuzzyOperator.forwardThen_assoc_map
#print axioms Book4D.FuzzyOperator.identity_forwardThen_map
#print axioms Book4D.FuzzyOperator.forwardThen_identity_map
#print axioms Book4D.FuzzyOperator.Reversible.backward_after_forward
#print axioms Book4D.FuzzyOperator.Reversible.forward_after_backward
#print axioms Book4D.FuzzyOperator.Reversible.forwardThen
#print axioms Book4D.EmergenceOperatorFamily.canonicalOrder_recognized
#print axioms Book4D.EmergenceOperatorFamily.swapped_middle_executes
#print axioms Book4D.EmergenceOperatorFamily.swapped_middle_unrecognized
#print axioms Book4D.EmergenceOperatorFamily.SRMFCertificate.exists_output
#print axioms Book4D.EmergenceOperatorFamily.identityFamily_canonical_exec
#print axioms Book4D.EmergenceOperatorFamily.identityFamily_not_emergent
#print axioms Book4D.CertifiedTTDC.decision_eq_stage_iff
#print axioms Book4D.CertifiedTTDC.decision_eq_abstain_iff
#print axioms Book4D.CertifiedTTDC.execute_of_contract
#print axioms Book4D.CertifiedTTDC.execute_of_not_contract
#print axioms Book4D.CertifiedTTDC.execute_satisfies_postcondition
#print axioms Book4D.CertifiedTTDC.stage_ne_abstain
#print axioms Book4D.CertifiedTTDC.install_ttdc
#print axioms Book4D.CertifiedTTDC.recordedExecute_eq_iff
#print axioms Book4D.CertifiedTTDC.abstention_base_inert_but_recorded
#print axioms Book4D.CertifiedTTPR.limit_fixed
#print axioms Book4D.CertifiedTTPR.fixed_eq_limit
#print axioms Book4D.CertifiedTTPR.tendsto_iterate_limit
#print axioms Book4D.CertifiedTTPR.iterate_dist_limit_le
#print axioms Book4D.CertifiedTTPR.install_ttpr
#print axioms Book4D.CertifiedTTCS.lower_le_output
#print axioms Book4D.CertifiedTTCS.output_le_upper
#print axioms Book4D.CertifiedTTCS.lower_le_upper
#print axioms Book4D.CertifiedTTCS.output_mem_Icc
#print axioms Book4D.CertifiedTTCS.iterate_succ_mem_Icc
#print axioms Book4D.CertifiedTTCS.output_eq_of_average_eq
#print axioms Book4D.CertifiedTTCS.install_ttcs
#print axioms Book4D.CertifiedTTCS.output_eq_of_sample_constant
#print axioms Book4D.CertifiedTTCS.output_reindex
#print axioms Book4D.CertifiedTTCS.alternative_average_dist_le
#print axioms Book4D.CertifiedTTCS.alternative_output_dist_le
#print axioms Book4D.CertifiedTTIE.iterate_mem_envelope_of_mem
#print axioms Book4D.CertifiedTTIE.iterate_mem_envelope
#print axioms Book4D.CertifiedTTIE.step_dist_le_coherenceSpeed
#print axioms Book4D.CertifiedTTIE.exists_newly_accessible
#print axioms Book4D.CertifiedTTIE.envelope_subset_accessibleLimit
#print axioms Book4D.CertifiedTTIE.iterate_mem_accessibleLimit
#print axioms Book4D.CertifiedTTIE.accessibleLimit_least
#print axioms Book4D.CertifiedTTIE.exists_envelope_ssubset_accessibleLimit
#print axioms Book4D.CertifiedTTIE.install_ttie
#print axioms Book4D.TTDCToTTIEImagination.staged_output_mem_initial
#print axioms Book4D.TTDCToTTIEImagination.staged_then_ttie_iterate_mem_envelope
#print axioms Book4D.TTDCToTTIEImagination.staged_then_ttie_iterate_mem_accessibleLimit
#print axioms Book4D.TTIEToTTCSImagination.selected_samples_accessible
#print axioms Book4D.TTIEToTTCSImagination.exists_accessible_sample
#print axioms Book4D.TTIEToTTCSImagination.expanded_then_sampled_mem_Icc
#print axioms Book4D.TTCSToTTPRImagination.refinement_iterate_mem_Icc
#print axioms Book4D.TTCSToTTPRImagination.tendsto_refinement_from_sample
#print axioms Book4D.TTCSToTTPRImagination.limit_mem_Icc
#print axioms Book4D.TTPRToTTDCImagination.returnState_eq_limit
#print axioms Book4D.TTPRToTTDCImagination.stage_or_abstain
#print axioms Book4D.TTPRToTTDCImagination.abstaining_return_is_fixed
#print axioms Book4D.ImaginationHorn.staged_sample_accessible
#print axioms Book4D.ImaginationHorn.one_pass_refinement_mem_Icc
#print axioms Book4D.ImaginationHorn.one_pass_tendsto_limit
#print axioms Book4D.odifferentiableAt_mono_eps
#print axioms Book4D.symbolicDrift_geometric_contraction_tendsto_zero
#print axioms Book4D.observerMetric_self_nonneg
#print axioms Book4D.observerMetric_self_eq_zero_iff
#print axioms Book4D.observerMetric_symm
#print axioms Book4D.rescaleKernel_mul
#print axioms Book4D.observerMetric_rescale_invariant
#print axioms Book4D.chart_glued_yields_single_geometry
#print axioms Book4D.chart_geometry_exists_iff_glued
#print axioms Book4D.dual_horizon_no_single_smoothness
#print axioms Book4D.jacobianChain_idealized_forces_zero_tensor
#print axioms Book4D.observer_correction_zero_iff_classical
#print axioms ScholiumC.colimit_universal_property
#print axioms ScholiumC.DirectedStageSystem.injection_transition
#print axioms ScholiumC.DirectedStageSystem.directed_colimit_universal_property
#print axioms ScholiumC.exists_bounded_approx
#print axioms ScholiumC.effectiveSignature_full
#print axioms ScholiumC.effectiveSignature_empty
#print axioms ScholiumC.dualHorizonBinding_both_pos
#print axioms ScholiumC.idempotent_image_eq_fixedPoints
#print axioms ScholiumC.consistent_unique
#print axioms ScholiumC.crossTerm_ne_zero_exists
#print axioms ScholiumC.crossTerm_separable_eq_zero
#print axioms ScholiumC.le_coherenceVelocity
#print axioms ScholiumC.exists_inaccessible_of_not_surjective
#print axioms ScholiumD.DifferentiationThreshold.eventually_below_threshold
#print axioms ScholiumD.emergenceOperator_exists
#print axioms ScholiumD.CommutatorErrorBound.err_tendsto_zero
#print axioms ScholiumD.combinedForm_pos_of_nondegenerate
#print axioms ScholiumD.combinedForm_nonneg
#print axioms ScholiumD.existence_of_metric_from_gluing
#print axioms ScholiumD.SymbolicHamiltonianFirstTerm.pos
#print axioms ScholiumD.FreeEnergyDescent.antitone
#print axioms ScholiumD.FreeEnergyDescent.le_initial
#print axioms ScholiumD.FreeEnergyDescent.const_of_eq
#print axioms ScholiumD.exists_critical_coupling
#print axioms ScholiumD.TransportLoss.exact_supportsDependency
#print axioms ScholiumD.TransportLoss.quotient_supportsDependency
#print axioms ScholiumD.TransportLoss.projective_supportsDependency
#print axioms ScholiumD.TransportLoss.interpretive_not_supportsDependency
#print axioms ScholiumD.TransportLoss.nonempty
#print axioms ScholiumD.TransportLoss.exact_ne_projective
#print axioms ScholiumD.shared_invariant_converse_not_derivable
#print axioms ScholiumD.mem_jointRefinement_iff
#print axioms ScholiumD.jointRefinement_subset_left_right
#print axioms ScholiumD.ImaginativeGenericityCertificate.supplies_genericity_hypotheses
#print axioms ScholiumD.symbolic_fluctuation_dissipation
#print axioms ScholiumD.jko_step_freeEnergy_le
#print axioms ScholiumD.jko_step_transport_cost_le_energy_drop
#print axioms Book5Residue.resilience_gt_one_iff
#print axioms Book5Residue.coupling_stability_gt_one_iff
#print axioms Book5Residue.bifurcation_eq_one_iff
#print axioms Book5Residue.reflective_stability_iff
#print axioms Book5Residue.covenant_transitivity_propagates
#print axioms Book5Residue.quadratic_real_root_pos
#print axioms Book5Residue.quadratic_real_root_neg
#print axioms Book5Residue.quadratic_no_real_root_of_disc_neg
#print axioms Book5Residue.closureMatrix_disc_pos
#print axioms Book5Residue.covenant_adjacency_trichotomy
#print axioms Book5Residue.covenant_adjacency_exclusive
#print axioms Book5Residue.min_resilience_implies_all_edges_resilient
#print axioms Book5Residue.golden_ratio_thermodynamic_min
#print axioms Book5Residue.golden_ratio_thermodynamic_optimum_iff
#print axioms Book5Residue.balanced_memory_tendsto_gold_scaled
#print axioms Book5Residue.compression_ratio_R1
#print axioms Book5Residue.compression_ratio_R2
#print axioms Book5Residue.sum_sq_le_sq_sum
#print axioms Book5Residue.l1_ge_l2
#print axioms Book5Residue.curvature_control_p2_nonneg
#print axioms Book5Residue.l1_eq_card_mul_c
#print axioms Book5Residue.energy_depletes_in_finite_time
#print axioms Book5Residue.max_recursive_depth_bound
#print axioms Book5Residue.MetabolicBudget.complexity_le
#print axioms Book5Residue.admissible_complexity_mono
#print axioms Book5Residue.weighted_strict_dominance
#print axioms Book5Residue.ess_invasion_threshold
#print axioms Book5Residue.map_mad_bounds_eventually_incompatible
#print axioms Book5Residue.viability_union_mono_chain
#print axioms Book9B.dominant_share_tendsto_one
#print axioms Book9B.curvature_cannot_vanish_under_structural_bound
#print axioms Book9B.injectionSucceeds_mono
#print axioms Book9B.frameSelection_exists
#print axioms Book9B.empathy_distortion_triangle
#print axioms Book9B.fidelityIndex_mono
#print axioms Book9B.fidelityIndex_degrades_beyond_threshold
#print axioms Book9B.contraction_fixedPoint_unique
#print axioms Book9B.sharedManifold_unique
#print axioms Book9B.reciprocity_curvature_bounds
#print axioms Book9B.grace_upsilon_pos
#print axioms Book9B.covenant_viability_decrease_accum
#print axioms Book9B.covenant_breach_forces_collapse_without_grace
#print axioms Book9B.lyapunov_step_le
#print axioms Book9B.lyapunov_strict_decrease_of_nonzero_grad
#print axioms Book9B.metaAlignment_converges
#print axioms Book9B.atlas_consistent_of_glued_and_covers
#print axioms Book9B.no_global_metric_without_gluing
#print axioms Book68B.recombinationCoherence_zero_preserved
#print axioms Book68B.recombinationCoherence_driftAlign_ne_zero
#print axioms Book68B.sequentialJump_not_continuousAt
#print axioms Book68B.bifurcation_piece_le_total
#print axioms Book68B.capacity_isUB
#print axioms Book68B.isStochastic_mul
#print axioms Book68B.evolve_comp
#print axioms Book68B.composedEvolution_isDensity
#print axioms Book68B.totalConfidence_nonneg
#print axioms Book68B.totalConfidence_le_one
#print axioms Book68B.power_nonneg
#print axioms Book68B.powerScaling_compose
#print axioms Book68B.commutator_eq_zero_iff_commute
#print axioms Book68B.commutator_witness_ne_zero
#print axioms Book68B.debugCompose_injective
#print axioms Book68B.mutuallyAssuredProgress_accum
#print axioms Book68B.mutuallyAssuredProgress_unbounded
#print axioms Book68B.exists_argmin
#print axioms Book7B.freeEnergy_bounded_below
#print axioms Book7B.contractiveReflection_fixedPoint_dist_eq_zero
#print axioms Book7B.contractiveReflection_iterate_bound
#print axioms Book7B.contractiveReflection_tendsto_star
#print axioms Book7B.perturbedContraction_bound
#print axioms Book7B.resonance_information_preservation
#print axioms Book7B.horizonExpansion_delta_pos
#print axioms Book7B.decencyPotential_mono
#print axioms Book7B.resonanceProbabilityLaw_mono_of_decency
#print axioms Book7B.srmfRegulation_exists
#print axioms Book7B.reciprocity_contains_fixed_point
#print axioms Book7B.reciprocityDomain_isOpen
#print axioms Book7B.reciprocityDomain_eq_preimage_of_eq_eps
#print axioms Book7B.reciprocityDomain_nonempty_of_fixed_point
#print axioms Book7B.coherenceWindow_iff
#print axioms Book7B.frameTempQuotient_mono
#print axioms Book7B.posPart_sub_negPart
#print axioms Book7B.quasiLipschitz_comp
#print axioms Book7B.fibMatrix_pow_succ
#print axioms Book7B.shiftedFib_ratio_tendsto_goldenRatio
#print axioms Book7B.symbolicEffort_ge_two
#print axioms Book7B.symbolicEffort_eq_two_iff
#print axioms Book7B.hamiltonian_denom_pos
#print axioms Book7B.complexity_card_le
#print axioms Book7B.conceptualBridgeLoop_toSigma1_injective
#print axioms Book7B.conceptualBridgeLoop_toM_surjective
#print axioms Atlas.path_dependent_iff_noncommuting
#print axioms Atlas.semantic_non_integrability_witness
#print axioms Atlas.holonomy_eps_squared
#print axioms Atlas.holonomy_zero_iff_commute
#print axioms Atlas.non_euclidean_necessity
#print axioms Atlas.curvature_witness
#print axioms Atlas.limit_nonneg
#print axioms Atlas.limit_self
#print axioms Atlas.limit_symm
#print axioms Atlas.limit_triangle
#print axioms Atlas.tower_glues
#print axioms Atlas.manifold_emergence
#print axioms Atlas.fracture_stops_emergence
#print axioms ScholiumDyn.flow_unique
#print axioms ScholiumDyn.flow_semigroup
#print axioms ScholiumDyn.pcost_nonneg
#print axioms ScholiumDyn.pcost_append
#print axioms ScholiumDyn.pcost_reverse
#print axioms ScholiumDyn.resCost_le_step
#print axioms ScholiumDyn.resCost_nonneg
#print axioms ScholiumDyn.resCost_self
#print axioms ScholiumDyn.resCost_symm
#print axioms ScholiumDyn.resCost_triangle
#print axioms ScholiumDyn.floor_complete
#print axioms ScholiumDyn.action_nonneg
#print axioms ScholiumDyn.least_action_iff_evolution
#print axioms ScholiumDyn.equilibrium_of_fixed_and_drift_zero
#print axioms ScholiumDyn.equilibrium_cancellation_counterexample
#print axioms ScholiumDyn.equilibrium_iff_fixed_and_drift_zero_of_aligned
#print axioms ScholiumDyn.recordedCombinedStep_eq_iff
#print axioms ScholiumDyn.base_cancellation_not_full_equilibrium
#print axioms ScholiumDyn.no_full_equilibrium_of_trace_production
#print axioms ScholiumDyn.hasFDerivAt_idempotent_at_fixed
#print axioms ScholiumDyn.ReflectiveLinearProjection.apply_apply
#print axioms ScholiumDyn.ReflectiveLinearProjection.derivative_image_kernel_decomposition
#print axioms ScholiumDyn.combinedJacobian_apply
#print axioms ScholiumDyn.hasFDerivAt_combinedVectorField
#print axioms ScholiumDyn.completeJacobian_at_reflective_fixed
#print axioms ScholiumDyn.combinedJacobian_on_image
#print axioms ScholiumDyn.combinedJacobian_on_kernel
#print axioms ScholiumDyn.fixedLocusVelocity_iff_derivative_fixed
#print axioms ScholiumDyn.combinedEulerLinearization_on_kernel
#print axioms ScholiumDyn.norm_combinedEulerLinearization_on_kernel_le
#print axioms ScholiumDyn.combinedEulerLinearization_transverse_contracts
#print axioms ScholiumDyn.combinedEulerLinearization_preserves_kernel
#print axioms ScholiumDyn.combinedEulerLinearization_iterate_mem_kernel
#print axioms ScholiumDyn.norm_combinedEulerLinearization_iterate_le
#print axioms ScholiumDyn.combinedEulerLinearization_iterate_tendsto_zero
#print axioms ScholiumDyn.transverse_eigenvalue_abs_le
#print axioms ScholiumDyn.transverse_eigenvalue_abs_lt_one
#print axioms ScholiumDyn.no_transverse_unstable_eigenmode
#print axioms ScholiumDyn.combinedEulerLinearization_eigen_of_jacobian_eigen
#print axioms ScholiumDyn.transverse_jacobian_eigenvalue_le_negative_margin
#print axioms ScholiumDyn.transverse_jacobian_eigenvalue_neg
#print axioms ScholiumDyn.transverse_jacobian_eigenmode_tendsto_zero
#print axioms ScholiumDyn.jacobianSemigroup_zero
#print axioms ScholiumDyn.jacobianSemigroup_add
#print axioms ScholiumDyn.jacobianSemigroup_add_apply
#print axioms ScholiumDyn.hasDerivAt_jacobianSemigroup
#print axioms ScholiumDyn.continuousLinearMap_pow_apply_eigen
#print axioms ScholiumDyn.jacobianSemigroup_apply_eigen
#print axioms ScholiumDyn.jacobianSemigroup_eigenmode_tendsto_zero
#print axioms ScholiumDyn.ReflectiveLinearProjection.exists_image_kernel_decomposition
#print axioms ScholiumDyn.ReflectiveLinearProjection.image_kernel_intersection_zero
#print axioms ScholiumDyn.ReflectiveLinearProjection.sub_identity_on_image
#print axioms ScholiumDyn.ReflectiveLinearProjection.sub_identity_on_kernel
#print axioms ScholiumDyn.linear_has_fixed_point
#print axioms ScholiumDyn.linear_fixed_points_closed
#print axioms ScholiumDyn.linear_pipeline_fixes_zero
#print axioms ScholiumDyn.affine_escapes_fixed_points
#print axioms ScholiumDyn.paradox_unresolvable_within
#print axioms ScholiumDyn.extension_resolves
#print axioms ScholiumDyn.resolution_breaks_symmetry
#print axioms ScholiumHzn.crossing_conservation
#print axioms ScholiumHzn.drift_field_unique
#print axioms Book8Freedom.freedom_emergence_iff_surjective
#print axioms Book8Freedom.meta_metabolic_freedom_iff_surjective
#print axioms Book8Freedom.freedom_can_fail
#print axioms Book8Freedom.contraction_orbit_bounded
#print axioms Born.psc6_calibration
#print axioms Born.psc4_ray_invariance
#print axioms Born.psc2_unitary_covariance
#print axioms Born.coh_le_one
#print axioms Born.qubit_born
#print axioms Born.mixed_affine
#print axioms Born.cohMix_nonneg
#print axioms Conservation.conserved_along_orbit
#print axioms Conservation.conserved_closed_orbit
#print axioms Conservation.orbit_constant_iff_step_invariant
#print axioms Conservation.IsConserved.add
#print axioms Conservation.IsConserved.smul
#print axioms Conservation.generator_determines_orbit
#print axioms ScholiumBridge.coupling_is_metric
#print axioms ScholiumBridge.nonzero_curvature_has_active_mode
#print axioms Book5Op.operator_stationary_iff_critical
#print axioms Book5Op.contraction_flow_unique_fixed_point
#print axioms Book5Op.contraction_flow_converges
#print axioms Book5Op.metabolic_capacity_monotone
#print axioms Book5Op.viability_antitone_in_spectral_radius
#print axioms Book5Adaptation.adapted_state_viable
#print axioms Book5Adaptation.operators_do_not_supply_adaptation
#print axioms Book5.driftReflectionContribution_pos_iff
#print axioms Book5.reflective_drift_alignment_positive
#print axioms Book5.positive_coupling_above_critical_insufficient
#print axioms Book5Dominance.map_capacity_strictly_exceeds_isolated
#print axioms Book5Dominance.map_viable_at_isolated_critical_drift
#print axioms Book5Dominance.map_dominates_beyond_isolated_capacity
#print axioms Book5EquilibriumConservation.energy_rate_linear_spectral_bound
#print axioms Book5EquilibriumConservation.linear_residual_bounds_do_not_imply_quadratic_bound
#print axioms Book5EquilibriumConservation.energy_rate_quadratic_spectral_bound
#print axioms Book5EnhancedDuality.classify_map
#print axioms Book5EnhancedDuality.classify_mad
#print axioms Book5EnhancedDuality.classify_decoupled
#print axioms Book5EnhancedDuality.classify_neg_of_strong
#print axioms Book5EnhancedDuality.positive_regime_parameters_do_not_force_viability
#print axioms Book5TransitionDynamics.mapStep_strict_growth
#print axioms Book5TransitionDynamics.madStep_strict_decay
#print axioms Book5TransitionDynamics.mapStep_at_boundary
#print axioms Book5TransitionDynamics.crossing_alone_does_not_force_growth
#print axioms Book4Ref.ttpr_fixed_point
#print axioms Book4Ref.ttpr_iterates_in_envelope
#print axioms Book4Ref.ttpr_fixed_point_in_envelope
#print axioms Book4Ref.coherence_neighborhood_nonempty
#print axioms Book4Ref.ttdc_iff_jump
#print axioms Book4Ref.collapse_limit_unique
#print axioms Book4Ref.curvature_inherits_continuity
#print axioms Book4Ref.coupled_drift_additive
#print axioms Book4Ref.emergenceMeasure_pos_iff
#print axioms Book4Ref.finite_emergence_criterion
#print axioms Book4Ref.abstractionSurplus_pos_iff
#print axioms Book4Ref.emergent_abstraction_positive_measure
#print axioms Book4Ref.FiniteHomologicalExtension.finrank_eq_add
#print axioms Book4Ref.FiniteHomologicalExtension.finrank_le_old_add_bound
#print axioms Book4Ref.exists_adjacent_rank_stabilization
#print axioms Book4Ref.essential_feature_preserved
#print axioms Book4Ref.bottleneck_le_curvature_scaled
#print axioms Book4Ref.homological_complexity_le_observer_capacity
#print axioms ThermoRes.global_beta_between
#print axioms ThermoRes.masking_has_positive_cost
#print axioms ThermoRes.moral_agency_requires_freedom
#print axioms ThermoRes.flattening_reduces_curvature
#print axioms Book4Fz.substituted_drift_contMDiff
#print axioms Book4Fz.substituted_drift_mdifferentiable
#print axioms Book4Fz.mfderiv_substituted_drift
#print axioms Book4Fz.drift_reflection_contMDiff
#print axioms Book4Fz.substituted_drift_reflection_contMDiff
#print axioms Book4Fz.mfderiv_substituted_drift_reflection
#print axioms Book4Fz.substituted_drift_continuous
#print axioms Book4Fz.substituted_drift_differentiable
#print axioms Book4Fz.hasFDerivAt_substituted_drift
#print axioms Book4Fz.substituted_drift_conjugacy
#print axioms Book4Fz.substituted_drift_iterate_conjugacy
#print axioms Book4Fz.hasFDerivAt_observerTransition
#print axioms Book4Fz.observerTransition_cocycle
#print axioms Book4Fz.observerTangentTransition_cocycle
#print axioms Book4Fz.observerTangentTransition_self
#print axioms Book4Fz.localObserver_coordinate_mem_overlap
#print axioms Book4Fz.localObserverCoordinateOverlap_iff
#print axioms Book4Fz.localObserverTransition_mem_target
#print axioms Book4Fz.hasFDerivAt_localObserverTransition
#print axioms Book4Fz.localObserverTransition_cocycle
#print axioms Book4Fz.localObserverTangentTransition_cocycle
#print axioms Book4Fz.topologicalObserverOverlap_isOpen
#print axioms Book4Fz.topologicalObserverCoordinateOverlap_isOpen
#print axioms Book4Fz.TopologicalObserverTangentAtlas.iUnion_source_eq_univ
#print axioms Book4Fz.TopologicalObserverTangentAtlas.exists_chart_mem_nhds
#print axioms Book4Fz.TopologicalObserverTangentAtlas.coordinateOverlap_isOpen
#print axioms Book4Fz.TopologicalObserverTangentAtlas.atlas_eq_range
#print axioms Book4Fz.TopologicalObserverTangentAtlas.mem_chartAt_source
#print axioms Book4Fz.TopologicalObserverTangentAtlas.isManifold_zero
#print axioms Book4Fz.ContDiffObserverTangentAtlas.transition_contDiffOn
#print axioms Book4Fz.ContDiffObserverTangentAtlas.isManifold
#print axioms Book4Fz.ContDiffObserverTangentAtlas.isManifold_one
#print axioms Book4Fz.fderiv_localObserverTransition
#print axioms Book4Fz.C1ObserverTangentAtlas.localTransition_contDiffOn
#print axioms Book4Fz.C1ObserverTangentAtlas.isManifold
#print axioms Book4Fz.controlledVectorFieldPerturbation_apply
#print axioms Book4Fz.controlledVectorFieldPerturbation_zero
#print axioms Book4Fz.controlledVectorFieldPerturbation_add
#print axioms Book4Fz.controlledVectorFieldPerturbation_eq_self_of_direction_zero
#print axioms Book4Fz.controlledVectorFieldPerturbation_eq_self_iff
#print axioms Book4Fz.isObserverIntegralCurve_iff
#print axioms Book4Fz.IsObserverIntegralCurve.controlledPerturbation_of_direction_zero
#print axioms Book4Fz.observerIntegralCurve_perturbation_iff
#print axioms Book4Fz.IsObserverFlow.isObserverIntegralCurve
#print axioms Book4Fz.IsObserverFlow.zero_eq_id
#print axioms Book4Fz.IsObserverFlow.add_eq_comp
#print axioms Book4Fz.IsObserverFlow.neg_comp_self
#print axioms Book4Fz.IsObserverFlow.self_comp_neg
#print axioms Book4Fz.IsObserverFlow.bijective
#print axioms Book4Fz.crossObserverTimeConsistent_refl
#print axioms Book4Fz.CrossObserverTimeConsistent.trans
#print axioms Book4Fz.CrossObserverTimeConsistent.symm
#print axioms Book4Fz.CrossObserverTimeConsistent.reparam_zero
#print axioms Book4Fz.CrossObserverTimeConsistent.reparam_add
#print axioms Book4Fz.IsObserverFlow.controlledPerturbation_of_reachable_zero
#print axioms Book4Fz.observerFlow_perturbation_iff
#print axioms Book4Fz.drift_reflection_continuous
#print axioms Book4Fz.substituted_drift_reflection_continuous
#print axioms Book4Fz.hasFDerivAt_drift_reflection
#print axioms Book4Fz.hasFDerivAt_substituted_drift_reflection
#print axioms Book4Fz.local_kernel_vanishes_offdiagonal
#print axioms Book4Fz.self_authorship_fixed_point
#print axioms ScholiumD.dual_horizon_cosmogenesis_kernel
#print axioms ScholiumD.event_horizon_identity_field_kernel
#print axioms ScholiumD.newtonian_incompleteness_kernel
#print axioms ScholiumD.symbolic_quantum_incompatibility_kernel
#print axioms ScholiumD.emergence_premises_do_not_force_curvature
#print axioms Book4D.crossErrorTransport_noncommute
#print axioms Book4D.contextual_crossError_induces_curvature
#print axioms Book4D.crossTerm_zero_iff_additively_separable
#print axioms Book4D.nonseparable_iff_exists_crossError
#print axioms Book4D.contextualStructuralGrowth_induces_curvature
#print axioms Book4FuzzyConnection.flatConnection_torsion_zero
#print axioms Book4FuzzyConnection.flatConnection_torsion_control
#print axioms Book4FuzzyConnection.flat_parallel_transport_exact
#print axioms Book4FuzzyConnection.torsion_control_of_approx_symmetric
#print axioms Book4GeodesicFailure.observerCurvature_nonneg
#print axioms Book4GeodesicFailure.observerCurvature_eq_zero_iff
#print axioms Book4GeodesicFailure.curvature_error_bound
#print axioms Book4GeodesicFailure.derivative_agreement_does_not_force_jacobi_curvature
#print axioms Book4ObserverGeometry.recursivelyStabilized_iff
#print axioms Book4ObserverGeometry.exists_recursively_stabilized_system
#print axioms Book4ObserverGeometry.driftingSystem_has_no_stabilized_state
#print axioms Book4Gauge.derivative_correspondence_bijective
#print axioms Book4Gauge.curvature_correspondence_bijective
#print axioms Book4Gauge.names_alone_do_not_supply_gauge_dictionary
#print axioms Book4Gauge.pathOrderedProduct_nil
#print axioms Book4Gauge.pathOrderedProduct_append
#print axioms Book4Gauge.two_segment_order_independent_iff
#print axioms Book4QuantumGeometry.twoSegmentPathDependent_iff_noncommute
#print axioms Book4QuantumGeometry.noncommuting_transport_is_path_dependent
#print axioms Book4QuantumGeometry.quantum_fluctuation_of_symbolic_path_dependence
#print axioms Book4QuantumGeometry.path_dependence_alone_does_not_force_quantum_fluctuation
#print axioms Book4MetricLearning.gradientStep_eq_self_iff
#print axioms Book4MetricLearning.quadratic_gradient_step_decreases
#print axioms Book4MetricLearning.differentiability_alone_does_not_guarantee_descent
#print axioms Book4InformationCurvature.fisherInformation_nonneg
#print axioms Book4InformationCurvature.curvature_diagonal_zero
#print axioms Book4InformationCurvature.unit_hessian_moment_cannot_be_riemann_diagonal
#print axioms Book4InformationCurvature.unit_second_hessian_moment
#print axioms Book4FieldRegularization.cutoffMode_eq_self
#print axioms Book4FieldRegularization.cutoffMode_eq_zero
#print axioms Book4FieldRegularization.cutoffMode_abs_le
#print axioms Book4FieldRegularization.perturbativeInsertion_eq_zero_of_high_mode
#print axioms Book4FieldRegularization.accessibleBand_card
#print axioms Book4FieldRegularization.resolution_scale_alone_does_not_force_suppression
#print axioms Book4Meaning.meaningValue_nonneg
#print axioms Book4Meaning.meaningValue_pos_iff
#print axioms Book4Meaning.exists_positive_meaning_iff
#print axioms Book4Meaning.meaningValue_strict_preference_iff
#print axioms Book4Meaning.freedomLifeTransition_does_not_force_nonconstant_energy
#print axioms Book4QuantumMeasurement.jointExpectation_eq_sum_partialTrace
#print axioms Book4QuantumMeasurement.jointExpectation_nonneg
#print axioms Book4QuantumMeasurement.jointExpectation_pureObserver
#print axioms Book4QuantumMeasurement.joint_state_does_not_reduce_to_arbitrary_observer
#print axioms Book4StatisticalMechanics.thermalMetric_decomposition
#print axioms Book4StatisticalMechanics.ensembleMetric_symmetric
#print axioms Book4StatisticalMechanics.thermalMetric_symmetric
#print axioms Book4StatisticalMechanics.thermalMetric_diagonal_nonneg
#print axioms Book4StatisticalMechanics.entropy_regularity_alone_does_not_force_metric_decomposition
#print axioms Book4Holographic.observerSurfaceArea_nonneg
#print axioms Book4Holographic.observerSurfaceArea_mono
#print axioms Book4Holographic.rtEntropy_area_law
#print axioms Book4Holographic.rtEntropy_nonneg
#print axioms Book4Holographic.rtEntropy_strictMono_area
#print axioms Book4Holographic.reconstruction_deterministic
#print axioms Book4Holographic.boundary_metric_alone_does_not_select_unique_bulk
#print axioms Book5Hysteresis.HysteresisThresholds.lower_lt_upper
#print axioms Book5Hysteresis.below_lower_switches_from_map
#print axioms Book5Hysteresis.above_upper_switches_to_map
#print axioms Book5Hysteresis.map_persists_in_band
#print axioms Book5Hysteresis.mad_persists_in_band
#print axioms Book5Hysteresis.in_band_remembers_history
#print axioms Book5Hysteresis.memoryless_classifier_cannot_remember_history
#print axioms Book5DualityProof.map_rate_positive_iff
#print axioms Book5DualityProof.mad_rate_negative_iff
#print axioms Book5DualityProof.map_rate_positive
#print axioms Book5DualityProof.mad_rate_negative
#print axioms Book5DualityProof.positive_rate_alone_does_not_force_positive_limit
#print axioms Book5DualityProof.negative_rate_alone_does_not_force_zero_limit
#print axioms Book5DualityProof.decoupling_consumes_vanishing_interaction
#print axioms Book5StrategyBalance.balance_iff_capacity_above_threshold
#print axioms Book5StrategyBalance.isolated_strategy_cannot_balance_positive_drift
#print axioms Book5StrategyBalance.exists_available_balancing_strategy
#print axioms Book5StrategyBalance.submaximal_drift_alone_does_not_supply_available_strategy
#print axioms Book5StrategyBalance.local_cancellation_is_not_strict_balance
#print axioms Book5ConvergenceMAP.mapShare_zero
#print axioms Book5ConvergenceMAP.mapShare_succ
#print axioms Book5ConvergenceMAP.mapShare_tendsto_one
#print axioms Book5ConvergenceMAP.increasing_drift_alone_does_not_force_map_convergence
#print axioms Book5ESSEquivalence.discreteSetDistance_eq_zero_iff
#print axioms Book5ESSEquivalence.CriticalIdentification.sets_eq
#print axioms Book5ESSEquivalence.CriticalIdentification.distance_zero
#print axioms Book5ESSEquivalence.distance_tendsto_zero_of_eventually_identified
#print axioms Book5ESSEquivalence.population_concentration_alone_does_not_identify_strategy_sets
#print axioms Book5OperatorSelection.exists_process_minimizer
#print axioms Book5OperatorSelection.selected_le_incumbent
#print axioms Book5OperatorSelection.rejects_strictly_suboptimal_incumbent
#print axioms Book5OperatorSelection.viability_alone_does_not_force_operator_argmin
#print axioms Book5OperatorAdaptation.refinementVelocity_eq_of_below
#print axioms Book5OperatorAdaptation.refinementVelocity_pos
#print axioms Book5OperatorAdaptation.gradientStep_displacement
#print axioms Book5OperatorAdaptation.quadratic_processFreeEnergy_descent
#print axioms Book5OperatorAdaptation.process_descent_can_increase_execution_cost
#print axioms Book5OperatorAdaptation.below_threshold_alone_does_not_force_adaptation
#print axioms Book5ReflectiveAccuracy.fidelity_le_log_of_depth_bound
#print axioms Book5ReflectiveAccuracy.fidelityEnvelope_nonneg
#print axioms Book5ReflectiveAccuracy.capacity_alone_does_not_bound_unconstrained_fidelity
#print axioms Book5ShadeTransfer.shade_preserved_of_radius_preserved
#print axioms Book5ShadeTransfer.radial_order_alone_does_not_preserve_shade
#print axioms Book5ShadeTransfer.golden_logRadius_step
#print axioms Book5ShadeTransfer.normalized_shade_is_not_multiplicative
#print axioms Book5ShadeTransfer.balanced_reciprocity_paints_golden_rate
#print axioms Book5ShadeTransfer.extraction_has_unit_radial_rate
#print axioms Book6DriftMutation.mutationRate_eq_weighted_curvature_change
#print axioms Book6DriftMutation.mutationRate_nonneg
#print axioms Book6DriftMutation.mutationRate_le_uniform_curvature_bound
#print axioms Book6DriftMutation.drift_alone_does_not_determine_mutation_rate
#print axioms Book6ThermodynamicMutation.mem_feasibleStates_iff
#print axioms Book6ThermodynamicMutation.exists_constrained_mepp
#print axioms Book6ThermodynamicMutation.equilibrium_balance_alone_does_not_imply_mepp
#print axioms Book6ConfidenceGradient.confidenceDrivenVelocity_eq
#print axioms Book6ConfidenceGradient.pure_confidence_drift_descends
#print axioms Book6ConfidenceGradient.pure_confidence_drift_strict
#print axioms Book6ConfidenceGradient.diffusion_can_reverse_confidence_drift
#print axioms Book6ConfidenceGradient.regularity_alone_does_not_force_confidence_dynamics
#print axioms Book6ThermodynamicConsistency.fixed_temperature_freeEnergy_increment
#print axioms Book6ThermodynamicConsistency.fixed_temperature_firstLaw_reduction
#print axioms Book6ThermodynamicConsistency.varying_temperature_freeEnergy_increment
#print axioms Book6ThermodynamicConsistency.printed_firstLaw_not_implied_by_freeEnergy_definition
#print axioms Book6ThermodynamicConsistency.oriented_freeEnergy_fixed_temperature_increment
#print axioms Book6ThermodynamicConsistency.printed_and_derived_laws_agree_iff_entropy_static
#print axioms Book6ThermodynamicConsistency.interface_term_reconciles_printed_law_iff
#print axioms Book4ImaginationGuard.phaseBudget_append
#print axioms Book4ImaginationGuard.effectiveRate_lt_one_iff_phase_penalty_below_margin
#print axioms Book4ImaginationGuard.eleven_percent_phase_ends_near_boundary_contraction
#print axioms Book4ImaginationGuard.projection_equality_can_hide_unsafe_phase
#print axioms Book4ImaginationDetector.mixedResidue_eq_zero_of_additive
#print axioms Book4ImaginationDetector.mixedResidue_bilinear_positive_control
#print axioms Book4ImaginationDetector.unconfoundedPersistence_implies_crossFramePersistent
#print axioms Book4ImaginationDetector.one_frame_hit_not_persistent
#print axioms Book4ImaginationDetector.persistent_signal_can_be_fully_confounded
#print axioms Book4ImaginationDetector.orientationSensitiveCandidate_components
#print axioms Book4ImaginationDetector.evidence_does_not_identify_imagination
#print axioms Book6ConfidenceStability.stabilityVelocity_eq
#print axioms Book6ConfidenceStability.stabilityVelocity_nonpos_of_quotientSlope_nonneg
#print axioms Book6ConfidenceStability.constant_hamiltonian_gives_positive_stabilityVelocity
#print axioms Book6ConfidenceStability.values_alone_do_not_force_confidence_stability_coupling
#print axioms Book6ObserverExtension.observerExtension_agrees
#print axioms Book6ObserverExtension.exists_observerExtension
#print axioms Book6ObserverExtension.observer_error_accumulates
#print axioms Book6ObserverExtension.observer_bound_alone_does_not_force_identity_preservation
#print axioms Book8OrientationSignposting.next_four
#print axioms Book8OrientationSignposting.transport_preserves_canonical_change
#print axioms Book8OrientationSignposting.opposite_signs_agree_iff_zero
#print axioms Book8OrientationSignposting.reversed_display_of_positive
#print axioms Book8OrientationSignposting.displayedNext_differs_across_orientations
#print axioms Book7SystemicPower.localPower_pos
#print axioms Book7SystemicPower.systemicPower_pos
#print axioms Book7SystemicPower.high_confidence_alone_does_not_force_power
#print axioms Book7SystemicPower.gradient_reversal_preserves_unoriented_power
#print axioms Book7SystemicPower.equal_power_does_not_determine_gradient_orientation
#print axioms Book8CognitiveScaffold.ComposablePair.step_closed
#print axioms Book8CognitiveScaffold.ComposablePair.iterate_closed
#print axioms Book8CognitiveScaffold.CertifiedScaffold.one_step_freeEnergy_nonincrease
#print axioms Book8CognitiveScaffold.CertifiedScaffold.iterate_identity_preserved
#print axioms Book8CognitiveScaffold.CertifiedScaffold.iterate_trajectory_bounded
#print axioms Book8CognitiveScaffold.composable_operator_order_need_not_commute
#print axioms Book8CognitiveScaffold.composability_alone_does_not_bound_trajectory
#print axioms Book8ConsciousnessAttribution.operationalDetection_components
#print axioms Book8ConsciousnessAttribution.strict_detector_evidence_alone_does_not_force_regulation
#print axioms Book8ConsciousnessAttribution.attribution_requires_operational_detection
#print axioms Book8ConsciousnessAttribution.attribution_requires_enough_trace_support
#print axioms Book8ConsciousnessAttribution.attribution_agrees_of_same_threshold
#print axioms Book8ConsciousnessAttribution.same_manifold_can_support_different_attributions
#print axioms Book8ConsciousnessAttribution.operational_detection_alone_does_not_force_attribution
#print axioms Book7NoInteriorTransition.continuousOn_no_discrete_phase_transition
#print axioms Book7NoInteriorTransition.continuous_closed_sweep_has_no_interior_transition
#print axioms Book7NoInteriorTransition.continuous_reparameterization_preserves_no_transition
#print axioms Book7NoInteriorTransition.continuity_from_threshold_bridge
#print axioms Book8OptimalProjectionPath.exists_optimal_projection_path
#print axioms Book8OptimalProjectionPath.optimal_path_satisfies_constraints
#print axioms Book8OptimalProjectionPath.constraints_can_leave_no_admissible_path
#print axioms Book8OptimalProjectionPath.utility_maximizer_need_not_be_geodesic
#print axioms Book8OptimalProjectionPath.maximizer_is_geodesic_of_variational_bridge
#print axioms Book9ReflectiveAwakening.cognitivelyFree_iff_capable_and_used
#print axioms Book9ReflectiveAwakening.awakeningEvidence_is_capable
#print axioms Book9ReflectiveAwakening.capability_alone_does_not_force_cognitive_freedom
#print axioms Book9ReflectiveAwakening.reflexiveInitiation_requires_use_and_intention
#print axioms Book9ReflectiveAwakening.observable_self_injection_does_not_determine_intention
#print axioms Book7PISU.two_sqrt_product_le_sum
#print axioms Book7PISU.allocation_uncertainty_bound
#print axioms Book7PISU.pisu_derived_bound
#print axioms Book7PISU.balanced_allocation_saturates_amgm
#print axioms AppendixCoherenceAxioms.noncontextual_budget_frame_independent
#print axioms AppendixCoherenceAxioms.bounded_budget_does_not_force_noncontextuality
#print axioms AppendixCoherenceAxioms.separated_orthogonal_questions_not_both_maximal
#print axioms AppendixCoherenceAxioms.boundedness_does_not_force_resolution_distinguishability
#print axioms AppendixMemoryMinimality.current_only_update_forgets_memory
#print axioms AppendixMemoryMinimality.memory_projection_not_representable_by_current_only
#print axioms AppendixMemoryMinimality.memoryStep_encodes_recurrence
#print axioms AppendixMemoryMinimality.two_coordinate_form_conditionally_minimal
#print axioms Book7ProceduralDetection.fittedExponent_decreases
#print axioms Book7ProceduralDetection.logLogSecantSlope_neg
#print axioms Book7ProceduralDetection.decreasing_exponent_does_not_force_decreasing_observable
#print axioms Book7ProceduralDetection.proceduralDetection_certificate
#print axioms Book8CriticalProjection.projectionTransition_iff_det_eq_zero
#print axioms Book8CriticalProjection.fisher_singular_of_projection_transition
#print axioms Book8CriticalProjection.criticalProjection_certificate
#print axioms Book8CriticalProjection.singularity_alone_does_not_force_structural_emergence
#print axioms Book8CriticalProjection.structuralEmergence_of_fisher_singular
#print axioms Book9CurvatureRepair.exists_optimal_viable_repair
#print axioms Book9CurvatureRepair.optimal_repair_need_not_minimize_curvature
#print axioms Book9CurvatureRepair.viability_alone_does_not_determine_repair
#print axioms Book6GraceBasin.grace_mem_regulatoryUnion
#print axioms Book6GraceBasin.grace_stays_in_basin
#print axioms Book6GraceBasin.subcriticality_alone_does_not_force_basin_membership
#print axioms Book6GraceBasin.coverage_without_invariance_does_not_force_grace_membership
#print axioms Book9CollapseEscape.internalRepair_does_not_escape
#print axioms Book9CollapseEscape.boundaryIntervention_does_not_escape
#print axioms Book9CollapseEscape.inversion_escapes
#print axioms Book9CollapseEscape.inversion_is_unique_escape
#print axioms Book9CollapseEscape.base_laws_do_not_force_inversion_unique
#print axioms Book7NoncontextualHilbert.l2_parallelogram
#print axioms Book7NoncontextualHilbert.l1_parallelogram_fails
#print axioms Book7NoncontextualHilbert.noncontextual_iff_hilbert_crossSection
#print axioms Book7NoncontextualHilbert.hilbert_geometry_alone_does_not_force_noncontextuality
#print axioms AppendixCurvatureFlows.boundedContinuousFlow_cauchy_converges
#print axioms AppendixCurvatureFlows.pointwise_limit_preserves_lipschitz_bound
#print axioms AppendixCurvatureFlows.observer_bound_closed_under_pointwise_limit
#print axioms AppendixCurvatureFlows.pointwise_convergence_alone_does_not_preserve_bound
#print axioms Book6ThermodynamicMAP.duality_iff_residual_zero
#print axioms Book6ThermodynamicMAP.reflectionDeviation_eq
#print axioms Book6ThermodynamicMAP.duality_of_reflectionDeviation_eq
#print axioms Book6ThermodynamicMAP.equilibrium_flags_alone_do_not_force_duality
#print axioms Book7LpRegression.regressionLoss_eq_sum
#print axioms Book7LpRegression.order_equiv_of_affineLp
#print axioms Book7LpRegression.freeEnergy_minimization_iff_lp_regression
#print axioms Book7LpRegression.trace_order_equiv
#print axioms Book7LpRegression.trace_step_descent_iff
#print axioms Book7LpRegression.trace_minimizer_iff
#print axioms Book7LpRegression.twoModelEnergy_bounded_below
#print axioms Book7LpRegression.descendToFalse_nonincreasing
#print axioms Book7LpRegression.bounded_descent_does_not_force_lp_representation
#print axioms Book7BornCollapse.defect_eq_zero_iff_hilbertFrame
#print axioms Book7BornCollapse.unique_stable_crossSection
#print axioms Book7BornCollapse.nonhilbert_defect_pos
#print axioms Book7BornCollapse.collapse_limit_eq_hilbertFrame
#print axioms Book7BornCollapse.collapse_tendsto_hilbertFrame
#print axioms Book7BornCollapse.born_readout_at_hilbert
#print axioms Book7BornCollapse.hilbert_collapse_alone_does_not_determine_readout
#print axioms Book8FramingEquivalence.framing_equivalence
#print axioms Book8FramingEquivalence.curvature_zero_iff_separable
#print axioms Book8FramingEquivalence.curvature_nonzero_iff_perceivedEntangled
#print axioms Book8FramingEquivalence.curvature_nonzero_iff_all_productSpans_excluded
#print axioms Book8FramingEquivalence.curvature_alone_does_not_force_entanglement
#print axioms Book8SRConvergence.orbit_freeEnergy_nonincreasing
#print axioms Book8SRConvergence.invariant_freeEnergy_nonincreasing
#print axioms Book8SRConvergence.distanceToInvariant_tendsto_zero
#print axioms Book8SRConvergence.lyapunov_descent_alone_does_not_force_invariant_approach
#print axioms Book9CurvatureScarring.oriented_displacement_eq_betrayalDrift
#print axioms Book9CurvatureScarring.scarMagnitude_eq_betrayalDrift
#print axioms Book9CurvatureScarring.revisedReciprocity_iff_grace_and_resources
#print axioms Book9CurvatureScarring.recovery_of_grace_capacity_and_energy
#print axioms Book9CurvatureScarring.recovery_can_retain_permanent_scar
#print axioms Book9CurvatureScarring.resources_alone_do_not_force_recovery
#print axioms Book9EthicalIntervention.justificationSignal_iff
#print axioms Book9EthicalIntervention.restraintSignal_iff
#print axioms Book9EthicalIntervention.recommendation_cases
#print axioms Book9EthicalIntervention.intervention_and_nonintervention_disjoint
#print axioms Book9EthicalIntervention.consent_without_restraint_recommends_intervention
#print axioms Book9EthicalIntervention.selfHealing_without_justification_recommends_nonintervention
#print axioms Book9EthicalIntervention.source_criteria_can_require_review
#print axioms Book9EthicalIntervention.execution_requires_authority
#print axioms Book9EthicalIntervention.recommendation_alone_does_not_grant_authority
#print axioms Book7B.contextualCurvature_with_stableIdentity
#print axioms Book7B.budgetLimitedObjective_not_unique
#print axioms Book7B.budgetLimited_uniqueMinimizer_of_injectiveCost
end ForcingAnalysis
