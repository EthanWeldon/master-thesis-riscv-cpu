# Baseline Run Procedure

This document is the starting point for a repeatable baseline run flow.

## Purpose

The baseline must be runnable in a consistent way before later CPU versions can be compared against it.

## Current Active Design

- top-level RTL: `RISC_V/rtl/top/RISC_V_02.sv`
- active testbench: `RISC_V/tb/tb_RISC_V.sv`
- default program image: `RISC_V/programs/imem.hex`

## Current Testbench Behavior

The active testbench:

- drives the clock continuously
- asserts reset at startup
- enables instruction-memory reads
- stops when register `x12` is written with value `1`

## Minimum Repeatable Run Definition

A repeatable baseline run should record at least:

- RTL top file used
- testbench used
- program image used
- simulator command used
- pass condition observed

The per-test expected input and output data should come from `RISC_V/tests/specs/baseline-suite.yaml`.

## Manual Run Checklist

Before a baseline run:

1. confirm the intended program image is loaded into `RISC_V/programs/imem.hex` or update the instruction-memory configuration intentionally
2. confirm the active top-level and testbench files are the baseline versions
3. confirm there are no unintentional RTL edits in progress

During the run:

1. compile the baseline RTL and testbench
2. run simulation until the current pass condition or failure condition occurs
3. record whether the expected stop condition was reached

After the run:

1. record the program image used
2. record whether the test passed
3. record any cycle counts or observability data available

## Recommended Future Improvements

To make this truly comparison-ready, add:

- a documented simulator command line
- a named set of standard baseline programs
- a pass or fail log format
- architectural counters for cycles and retired work

## Relationship To Future Versions

When Stage 1 and later versions are created, this procedure should be copied or adapted into version-specific run procedures only if the run flow materially differs.

Until then, this file should describe the canonical baseline run process.