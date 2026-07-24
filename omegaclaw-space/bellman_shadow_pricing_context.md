# Bellman Shadow Pricing — public OmegaClaw context

Context version: `bgi-bellman-2026-07-24`

This is a later, separate public Compitum × FabricPC project. It is not part of the published Springer paper *The Hypothesis Surface* and must not be silently rewritten into that paper.

## Research question

Could a bounded FabricPC representation infer hidden scarcity regimes from recent trajectories and turn that belief into a useful sequential routing price inside Compitum?

## What the staged program found

The fixed FabricPC topology did not clear the final economic gate. Predictive coding and same-topology backpropagation tied at regret `0.314`; the fixed topology captured `15.4%` of the recoverable gap. Exact belief, HMM, and ridge achieved regret `0.000`; pacing and no pricing were `0.371`; shuffled FabricPC was `0.457`.

This is not evidence that predictive coding fails generally, and predictive coding did not beat same-topology backpropagation.

## Meta-level success

The FabricPC intervention was nevertheless scientifically and architecturally successful. Compitum had earlier shadow-pricing machinery, but local or retrospective scalar prices were not trusted as the operative rule for selecting whole discrete actions. The FabricPC program reopened the pricing question and exposed the deeper bottleneck:

`scalar local price × lumpy action consumption`

can misprice an action that crosses several regions of future marginal value.

The corrected whole-action Bellman charge is:

`C_t(a) = V_{t+1}(B_t, q_{t+1}) - V_{t+1}(B_t - c_t(a), q_{t+1})`

This exact continuation-value difference reproduced the online Bellman optimum: identical choices, identical cumulative utility, and `mismatches = 0` in the certified adapter.

The correct two-level verdict is:

- **Model verdict:** the bounded FabricPC predictor did not clear the gate.
- **Program verdict:** the FabricPC intervention recovered Compitum’s missing action-pricing mechanism.

A compact formulation is: **The model lost. The experiment succeeded.**

Do not claim that FabricPC itself learned the exact Bellman oracle, directly achieved zero regret, or proved a general failure of predictive coding.

## Certified belief-sensitive result

At `remaining_steps = 1`, `reachable_budget = 4.5`, with an opportunity observed:

- belief `q = 0.05` selects `spend`;
- belief `q = 0.20` selects `opportunity`.

This certifies a genuine interior action change. The exact transition threshold is not asserted.

## Public materials

- Interactive BGI Open Build: https://paultiffany.github.io/come-to-AGI-26/BGI-Open-Build/
- Certified evidence: https://paultiffany.github.io/come-to-AGI-26/BGI-Open-Build/evidence/
- Manim proof-film: https://paultiffany.github.io/come-to-AGI-26/BGI-Open-Build/media/bellman-shadow-pricing.mp4
- Frozen Compitum research tag: https://github.com/PaulTiffany/compitum/tree/fabricpc-compitum-shadow-pricing-v1

## Canonical provenance

- Compitum submission commit: `d4c0bbd103849b8afb1019921684a062482d08cc`
- Compitum research commit: `617f8979daa921d326301266e55740c0746ab95c`
- FabricPC commit: `32ae295182ab944b8f084abaf4a40da2c50bab5f`
- Evidence bundle SHA-256: `6b48262f49e6cad498a23ff6e075f1f8522e831004f8cb3dbaeecfe46e28dc05`
