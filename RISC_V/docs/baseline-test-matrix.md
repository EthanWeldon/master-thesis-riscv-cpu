# Baseline Test Matrix

This document defines the baseline test set that should be reused across the whole project.

It is not only for the current baseline. It is the reference validation suite that later CPU versions should continue to run unless a test is intentionally replaced by a better standardized version.

## Purpose

The matrix has two roles:

- provide a stable correctness and regression suite across all project versions
- define which tests also produce comparison data for the thesis

This helps keep the project disciplined without turning it into a full verification program.

## How To Read This Matrix

Each test belongs to one of three groups:

- `Regression`: must pass on every CPU version
- `Stress`: focuses on hazard or control behavior important to the thesis
- `Workload`: small end-to-end programs used for realistic comparison

Each test also has a comparison role:

- `Required`: should be part of standard cross-version comparisons
- `Optional`: useful, but not mandatory for every checkpoint
- `Correctness only`: intended mainly to confirm behavior, not to report thesis performance numbers

For comparison metrics, see `RISC_V/docs/comparison-data.md`.

The canonical machine-readable test data for this suite lives in `RISC_V/tests/specs/baseline-suite.yaml`.

## Current Available Program Images

- `RISC_V/programs/imem.hex`
- `RISC_V/programs/simple_add.hex`
- `RISC_V/programs/simple_sub.hex`
- `RISC_V/programs/simple_branch.hex`
- `RISC_V/programs/simple_jump.hex`
- `RISC_V/programs/simple_instr.hex`
- `RISC_V/programs/simple_SW_LW_instr.hex`

## Recommended Standard Test Set

### Group A: Regression Correctness

These tests should be run on every version before any performance comparison is accepted.

| Test Name | Program Image | Group | Purpose | Pass Criteria | Comparison Role |
|---|---|---|---|---|---|
| `test_smoke_default_program` | `imem.hex` | Regression | Confirm the currently selected default program still reaches the intended termination condition | Simulation reaches the known stop condition and no obvious incorrect writeback behavior is observed | Required |
| `test_alu_add_basic` | `simple_add.hex` | Regression | Confirm basic add path correctness | Expected final register result matches the test specification | Required |
| `test_alu_sub_basic` | `simple_sub.hex` | Regression | Confirm basic subtract path correctness | Expected final register result matches the test specification | Required |
| `test_branch_basic` | `simple_branch.hex` | Regression | Confirm branch redirection and flush path correctness | Expected control-flow result and final architectural state are observed | Required |
| `test_jump_basic` | `simple_jump.hex` | Regression | Confirm jump path correctness | Expected jump behavior and final architectural state are observed | Required |
| `test_mem_basic` | `simple_SW_LW_instr.hex` | Regression | Confirm load and store behavior | Expected memory effect and dependent writeback behavior are observed | Required |
| `test_instr_mix_basic` | `simple_instr.hex` | Regression | Confirm mixed-instruction execution still works | Expected final architectural state is observed | Required |

### Group B: Microarchitecture Stress

These tests are especially important for thesis work because they exercise the mechanisms that later versions will modify.

Some may require new small program images to be created. That is expected.

| Test Name | Program Image | Group | Purpose | Pass Criteria | Comparison Role |
|---|---|---|---|---|---|
| `test_dep_alu_back_to_back` | New program recommended | Stress | Exercise back-to-back dependent ALU operations and forwarding behavior | Dependent results are correct with no unintended corruption | Required |
| `test_load_use_dependency` | New program recommended | Stress | Exercise load followed by dependent use | Final result is correct and the design handles the dependency consistently | Required |
| `test_branch_taken` | New program recommended | Stress | Isolate taken-branch behavior | Correct path is taken and wrong-path effects are flushed | Required |
| `test_branch_not_taken` | New program recommended | Stress | Isolate not-taken branch behavior | Sequential path completes with correct architectural state | Required |
| `test_reset_startup` | Testbench-driven | Stress | Confirm reset behavior and initial machine state | PC and architectural state initialize as expected | Optional |

### Group C: End-To-End Workloads

These tests provide more meaningful whole-program data and should be reused throughout the project.

| Test Name | Program Image | Group | Purpose | Pass Criteria | Comparison Role |
|---|---|---|---|---|---|
| `test_small_sort_kernel` | New program recommended | Workload | Provide a compact realistic workload for repeated cross-version comparison | Output data is correctly sorted and expected termination is reached | Required |
| `test_control_heavy_kernel` | New program recommended | Workload | Stress repeated branching and loop behavior | Expected final result is correct | Optional |
| `test_memory_heavy_kernel` | New program recommended | Workload | Stress repeated memory traffic in a simple program | Expected final memory and register state are correct | Optional |

## Recommended Scope For The Whole Project

This is the recommended long-term baseline suite:

- 7 baseline regression tests using the existing program images
- 4 to 5 microarchitecture stress tests
- 1 to 3 compact workload tests

That gives you a project-wide suite of roughly 12 to 15 tests, which is enough to be disciplined without becoming a verification project.

## Bubble Sort Guidance

You do not need to repeat the old undergraduate-scale `1000`-element bubble sort as a baseline requirement.

For this thesis, the better choice is:

- use one small sort kernel as a repeatable workload test
- keep the problem size small enough for practical RTL simulation
- use the same workload across versions for relative comparison

Recommended starting size:

- `8`, `16`, or `32` elements

This is large enough to produce meaningful repeated control and memory behavior, but small enough to remain practical in simulation.

If you later want a larger input for evaluation, that belongs in the performance-evaluation phase, not in the mandatory baseline regression gate.

## Data To Collect For Comparisons

For every `Required` comparison test, collect at least:

- `cpu_version`
- `test_name`
- `program_image`
- `pass_fail`
- `cycles`

Collect these as soon as the observability exists:

- `retired_instr`
- `ipc` or `cpi`
- `flush_cycles`

Collect these only once the relevant feature exists:

- `execute_busy_cycles`
- `operand_wait_cycles`
- `fetch_starvation_cycles`
- `window_occupancy`
- `ready_instruction_cycles`
- `branch_mispred_count`

The canonical metric definitions are in `RISC_V/docs/comparison-data.md`.

## What Must Be Defined Before Freeze

Before the baseline is considered frozen, every `Required` test should have:

- a fixed program image
- an explicit pass condition
- a known expected final architectural state
- a note describing what feature it exercises

Cycle counts do not have to be fixed pass or fail gates yet, but they do have to be recorded once you start cross-version comparison.

## Stage-Specific Extensions

Later stages should extend the same suite rather than replacing it.

### Stage 1 Additions

Add:

- `test_mul_basic`
- `test_mul_latency_2cycle`
- `test_mul_latency_4cycle`
- `test_mul_stall_behavior`

### Stage 2 Additions

Add:

- `test_independent_ops_window_benefit`
- `test_operand_ready_delay`
- `test_in_order_commit_preserved`

### Stage 3 Additions

Add:

- `test_fetch_queue_benefit_branchy`
- `test_fetch_queue_benefit_stalled_backend`
- `test_predictor_variant_compare`

## Practical Next Step

The next concrete improvement to this matrix should be to replace the placeholder pass criteria with exact expected register or memory outcomes for the `Required` tests.

That exact input and output data is now being tracked in `RISC_V/tests/specs/baseline-suite.yaml`. The remaining work is to add the missing program images for the blocked stress and workload tests.