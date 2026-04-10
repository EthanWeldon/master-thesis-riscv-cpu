# Baseline Verification Notes

This document records the current verification posture of the baseline CPU and identifies the minimum work needed before thesis comparisons begin.

## Current Testbench

Primary active testbench:
- `RISC_V/tb/tb_RISC_V.sv`

Current behavior:
- drives `clk`
- asserts reset at startup
- enables instruction-memory reads
- stops simulation when register `x12` is written with value `1`

This is a useful smoke test but not yet a full verification strategy.

## What The Current Baseline Can Prove

With the current testbench, you can confirm at least the following:
- the design elaborates and runs under a simple program image
- the pipeline can reach a known terminating condition
- register writeback visibility is wired correctly enough for the stop condition

## What Is Missing

Before using this baseline for thesis comparisons, verification should become more explicit in these areas:

- deterministic program selection for each test run
- test naming and expected outcome tracking
- branch-behavior validation
- load/store validation
- multiply-path validation
- hazard and forwarding validation
- reset-state validation

## Recommended Baseline Verification Layers

### 1. Smoke Tests

Keep simple bring-up programs that confirm:
- arithmetic works
- branches redirect correctly
- load/store instructions function
- jump behavior works

The existing program images in `RISC_V/programs/` are a good starting point.

### 2. Directed Functional Tests

Add separate tests or program images for:
- ALU operations
- multiply behavior
- branch taken and not-taken cases
- load followed by dependent use
- back-to-back dependent ALU operations to exercise forwarding

### 3. Measurement Readiness

Before performance studies begin, add counters or observability for:
- retired instructions
- total cycles
- flush cycles
- memory-read and memory-write activity
- future execute-busy cycles

These counters do not need to be architecturally visible forever, but they should be defined in a repeatable way.

The standard cross-version metric definitions are documented in `RISC_V/docs/comparison-data.md`.

## Baseline Freeze Checklist

The baseline should be considered frozen only after the following are true:

- the active top-level and testbench are fixed for comparison use
- instruction-memory setup is reproducible
- at least a small suite of directed tests passes
- the run procedure is documented
- baseline measurement counters are defined

## Suggested Next Verification Artifacts

The next useful documents in this area would be:
- `baseline-test-matrix.md`
- `baseline-run-procedure.md`
- `stage1-verification-plan.md`

These can be added once the baseline is being prepared for formal comparison against the first modified core.

The current baseline suite and comparison-data definitions should now be treated as the reference starting point.