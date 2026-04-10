# Comparison Data

This document defines the data that should be collected when comparing the baseline CPU against later thesis versions.

## Purpose

The project needs a stable comparison format so that each CPU version is measured consistently.

The goal is not to collect every possible metric. The goal is to collect the set of metrics that directly supports the thesis questions.

## Comparison Levels

There are two useful levels of data collection.

### Level 1: Required For Every Version

Collect these for every standard comparison test:

- CPU version name
- test name
- program image used
- pass or fail result
- total cycle count
- retired instruction count, if available
- CPI or IPC, if available
- notes on any special run conditions

These are the minimum comparison records.

### Level 2: Stage-Aware Microarchitectural Data

Collect these once the corresponding feature exists in the design:

- control flush cycles
- fetch stall or starvation cycles
- execute busy cycles
- operand-not-ready cycles
- window occupancy statistics
- cycles with at least one ready instruction in the window
- branch misprediction count
- memory operation count

Not every metric exists in every version. That is acceptable. The important thing is to keep the metric definitions stable once introduced.

## Standard Result Record

Each run should eventually produce a record shaped like this:

| Field | Meaning |
|---|---|
| `cpu_version` | Name of the frozen or working version under test |
| `test_name` | Standard test identifier |
| `program_image` | Program file used for the run |
| `pass_fail` | Whether the expected outcome was met |
| `cycles` | Total cycles until completion or timeout |
| `retired_instr` | Number of committed or retired instructions |
| `cpi` | Cycles per instruction |
| `ipc` | Instructions per cycle |
| `flush_cycles` | Cycles lost to control flushes |
| `execute_busy_cycles` | Cycles execute was blocked by a long-latency unit |
| `fetch_starvation_cycles` | Cycles backend was ready but frontend had no work |
| `operand_wait_cycles` | Cycles issue could not proceed because operands were not ready |
| `notes` | Any relevant caveats |

## Metrics By Thesis Stage

### Baseline

Baseline should at minimum collect:

- pass or fail
- total cycles
- retired instructions if possible
- CPI or IPC if possible
- flush cycles if branch logic can expose them

### Stage 1: Multi-Cycle Execution

In addition to baseline metrics, collect:

- execute busy cycles
- multiply operation count, if available
- stall cycles caused by multiply latency

### Stage 2: Window Plus Scoreboard

In addition to earlier metrics, collect:

- operand-not-ready cycles
- window occupancy distribution
- number of cycles with at least one ready instruction
- utilization of the instruction window

### Stage 3: Front-End Decoupling

In addition to earlier metrics, collect:

- fetch starvation cycles
- fetch queue occupancy distribution
- branch misprediction count
- branch recovery penalty indicators if exposed

## Recommended Workload Groups

Use the same workload groups across versions.

### Group A: Regression Correctness

Small directed tests that must always pass.

Purpose:
- detect breakage quickly
- confirm architectural correctness before any performance run

### Group B: Microarchitecture Stress

Small tests focused on hazards, stalls, branch behavior, and dependency patterns.

Purpose:
- expose the behavior of the mechanism under study

### Group C: End-To-End Workloads

Small but realistic programs such as sorting or mixed-instruction kernels.

Purpose:
- provide more meaningful whole-program comparison data

## Comparison Rules

To keep results defensible:

1. Always run the same standard correctness suite before collecting comparison metrics.
2. Do not compare performance numbers from runs that fail correctness.
3. Keep the same program image for cross-version comparisons unless the test definition itself changes.
4. Record which metrics were unavailable in a given version rather than fabricating equivalents.
5. Use the same metric names across versions once a metric is introduced.

## Near-Term Recommendation

For the baseline freeze, the first required comparison fields should be:

- `cpu_version`
- `test_name`
- `program_image`
- `pass_fail`
- `cycles`

Then add:

- `retired_instr`
- `ipc` or `cpi`
- `flush_cycles`

as soon as the baseline observability supports them.