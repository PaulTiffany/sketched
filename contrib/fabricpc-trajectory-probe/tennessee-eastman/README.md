# Tennessee Eastman alarm-cascade demonstration

This is the first public-data application of the FabricPC trajectory probe.
It uses the Tennessee Eastman Process (TEP), a standard industrial process
control and fault-diagnosis benchmark.

## Public question

> When one disturbance makes alarms appear across a connected factory, which
> measurements reveal transport and which observations actually localize the
> source?

The demonstration compares two closed-loop simulations:

- normal operation; and
- Fault 1, a step change in the A/C feed ratio at stream 4.

Both simulations use the same source, initial state, controller settings,
random seed, duration, and sampling schedule. The disturbance flag is their
only intended difference. The first 160 recorded observations are exactly
equal, providing an empirical pairing check before the intervention.

## Result

Fault 1 begins after eight simulated hours. At the first post-intervention
sample, the standardized whole-state difference is `1.79850`, but its dominant
observed block is the reactor:

| Observed block | Standardized norm |
|---|---:|
| Feed measurements and controls | 0.01700 |
| Recycle/compressor | 0.45380 |
| Reactor | 1.49474 |
| Separator | 0.74237 |
| Stripper | 0.49297 |
| Delayed composition analyzers | 0.00000 |

Three minutes later the separator becomes dominant; nine minutes later the
stripper does. The delayed composition analyzers first respond after six
minutes.

The simulated source is known because we set the Fault 1 flag. It is not
identified from the observed vector alone. The disturbance changes a feed
composition ratio, while the first strong measured response appears
downstream.

```text
known local disturbance
        ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬Å“
downstream observable response
        ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬Å“
plant-wide alarm growth
```

That is the practical point:

```text
whole-system alarm ÃƒÂ¢Ã¢â‚¬Â°Ã‚Â  direct localization of the source
```

## Reproduce

From `C:\src\sketched`:

```powershell
powershell -ExecutionPolicy Bypass -File `
  .\contrib\fabricpc-trajectory-probe\tennessee-eastman\run.ps1
```

The script:

1. downloads the 4.6 MB public archive when needed;
2. verifies its published SHA-256;
3. extracts the licensed simulator into `C:\tmp`;
4. builds paired normal and Fault 1 executables with `gfortran`;
5. runs ten simulated hours, intervening after hour eight; and
6. writes `verification\tep_fault1_certificate.json`.

The raw archive, extracted simulator, executables, and simulator output remain
in temporary storage and are not committed.

## Evidence and claim boundary

- Certificate: `verification/tep_fault1_certificate.json`
- Auditor: `verification/tools/tep_trajectory_probe.py`
- Tests: `verification/tools/test_tep_trajectory_probe.py`
- Source receipt: `SOURCE.json`

## Predictive-coding topology experiment

The same command now trains three real FabricPC networks on one-step prediction
using only the normal pre-intervention observations. All arms use the same
seeds, widths, optimizer, inference schedule, node count, and edge count:

- `process`: coarse material-flow topology;
- `dense`: deliberately mixing topology; and
- `shuffled`: permuted process connectivity.

At the first post-intervention sample, the process arm concentrated its paired
normal/fault energy difference into an effective `3.59` blocks, compared with
`4.36` for dense and `3.85` for shuffled. It was more localized than both
controls in this seeded run. Its final dominant internal block was the
stripper, not the known feed disturbance.

The dense control also achieved the best one-step prediction error:

| Arm | Normal MSE | Fault MSE | Effective blocks |
|---|---:|---:|---:|
| Process | 3.4260 | 3.8019 | 3.5868 |
| Dense | 2.5021 | 2.6466 | 4.3646 |
| Shuffled | 3.3245 | 3.5707 | 3.8467 |

FabricPC's own accumulated training process energy tells the complementary
story:

| Arm | Cumulative process energy | Per-epoch-oracle regret |
|---|---:|---:|
| Process | 659.02 | 0.00 |
| Dense | 697.39 | 38.37 |
| Shuffled | 672.77 | 13.75 |

The process arm had the lowest recorded process energy at every epoch. This is
in-sample process-energy regret, not held-out prediction or causal-localization
regret; the distinction is part of the result.
This is a useful tradeoff, not a victory claim: process topology improved
localization under this metric while reducing predictive accuracy. More
localization did not identify the true source.

Evidence:

- Plant certificate: `verification/tep_fault1_certificate.json`
- FabricPC certificate: `verification/tep_fabricpc_predictive_coding.json`
- Plant auditor: `verification/tools/tep_trajectory_probe.py`
- FabricPC runner: `verification/tools/tep_fabricpc_predictive_coding.py`
- Tests: `verification/tools/test_tep_trajectory_probe.py` and
  `verification/tools/test_tep_fabricpc_predictive_coding.py`
- Source receipt: `SOURCE.json`

This demonstrates controlled counterfactual transport and an exploratory
topology comparison over a public scientific benchmark. It does not establish
a FabricPC defect, global Lipschitz constant, hidden-cause identification,
imagination, or consciousness.

## Alarm-routing falsification

We also tested the obvious operational policy: at each observation, route to
the topology with the lowest final FabricPC inference energy, using no future
data. A 5% relative energy margin triggers advisory human review. The next
plant observation is revealed only after selection and supplies realized loss.

The raw-energy router failed:

| Timeline | Energy-router regret | Random expected | Best fixed arm |
|---|---:|---:|---:|
| Normal holdout | 20.95 | 15.47 | Dense: 6.06 |
| Fault 1 | 226.96 | 160.53 | Dense: 27.45 |

Thus low training process-energy regret does not make inference energy a
calibrated routing utility. The phase/boundary signal may be useful evidence,
but an operational router still needs outcome calibration, constraints, and a
declared selection policy. This is the same bridge Compitum explicitly
supplies.

Reproduce this slower, causally ordered evaluation after generating the paired
simulator runs:

```powershell
$env:PYTHONPATH = (
  (Resolve-Path .\verification\tools).Path + ";" +
  (Resolve-Path .\fabric\FabricPC).Path
)
.\fabric\FabricPC\.venv\Scripts\python.exe `
  .\verification\tools\tep_fabricpc_alarm_router.py `
  --normal-dir C:\tmp\tep-paired\normal `
  --fault-dir C:\tmp\tep-paired\fault1
```