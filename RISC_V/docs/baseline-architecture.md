# Baseline Architecture

This document describes the current baseline CPU implementation before thesis-specific architectural changes.

## Scope

Baseline reference:
- top-level module: `RISC_V/rtl/top/RISC_V_02.sv`
- testbench: `RISC_V/tb/tb_RISC_V.sv`

This baseline is the control design that later versions should be compared against.

## High-Level Structure

The active baseline is a modular 5-stage single-issue RISC-V pipeline:

- IF: fetch stage with branch-predictor-driven next-PC selection
- ID: decode, control generation, register file reads, immediate generation
- EX: ALU, multiply path, branch target calculation, forwarding muxes
- MEM: data memory access and pass-through of writeback metadata
- WB: selection between memory data and execute result for register writeback

Inter-stage state is held in dedicated pipeline-register modules:

- `FE_DE`
- `DE_EX`
- `EX_MEM`
- `MEM_WB`

## Module Breakdown

### Top Level

`RISC_V_02.sv` wires together the full pipeline and exposes only a minimal external interface:

- `clk`
- `reset`
- `imem_read_en`
- `reg_writedata`
- `reg_writeaddr`

The writeback outputs are currently exposed mainly for testbench visibility.

### Fetch

Primary module:
- `RISC_V/rtl/stages/Fetch_Stage_bp.sv`

Responsibilities:
- maintain `pc_f`
- obtain the next PC from `Branch_Predictor_Block`
- fetch the instruction from `Instruction_Memory_Block`
- generate `flush_fd` and `flush_de` through branch-predictor logic

Notes:
- instruction memory is initialized from `RISC_V/programs/imem.hex`
- fetch currently assumes a simple instruction-memory model

### Decode

Primary module:
- `RISC_V/rtl/stages/Decode_Stage.sv`

Responsibilities:
- decode the fetched instruction through `Control_Unit_Block`
- read source operands from `Register_File_Block`
- generate immediates via `Immediate_Generator_Block`
- forward control and operand information into the `DE_EX` register

Notes:
- register file writes arrive from writeback in the same architectural path used by the testbench-observable outputs

### Execute

Primary module:
- `RISC_V/rtl/stages/Execute_Stage.sv`

Responsibilities:
- select forwarded operands
- perform ALU operations
- perform multiply operations
- calculate branch target and branch control outputs
- form the execute-stage result selected for downstream stages

Supporting block:
- `RISC_V/rtl/blocks/Forwarding_Unit_Block.sv`

Notes:
- forwarding is currently targeted at the execute stage
- multiply is present as part of the execute-stage datapath but is not yet a multi-cycle unit

### Memory

Primary module:
- `RISC_V/rtl/stages/Memory_Stage.sv`

Responsibilities:
- access `Data_Memory_Block`
- pass through destination register and writeback-control metadata

Notes:
- current memory handling is simple and suitable as a baseline model

### Writeback

Primary module:
- `RISC_V/rtl/stages/Writeback_Stage.sv`

Responsibilities:
- choose between execute result and memory read data
- emit register write address, enable, and data

## Current Control Behavior

The baseline is still conceptually an in-order single-issue pipeline.

Current visible control features include:
- branch-predictor-directed fetch redirection
- pipeline flush support from fetch to downstream pipeline registers
- execute-stage forwarding from memory and writeback results

The baseline does not yet include the thesis mechanisms under study:
- no multi-cycle execution stall framework
- no instruction window
- no scoreboard
- no decoupled fetch queue

## Why This Matters For The Thesis

This baseline is the reference point for later experimental versions. It should remain stable enough that changes in performance or behavior can be attributed to the thesis mechanisms rather than unrelated cleanup.

The next architectural planning step should be to describe exactly how Stage 1 changes this baseline, especially:
- where execute busy state lives
- which stages stall when multiply is busy
- what new observability counters are required