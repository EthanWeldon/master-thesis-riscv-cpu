# Stage 1 Module Plan

This document defines the intended module-level changes for Stage 1: adding a multi-cycle execution unit while keeping the baseline core otherwise in-order and single-issue.

## Stage 1 Goal

Introduce realistic backend pressure by making multiply execution take multiple cycles and forcing the rest of the pipeline to respond correctly.

This stage is intentionally smaller than Stage 2. It should preserve the current top-level architecture as much as possible.

## Design Intent

Stage 1 should answer this question:

How does a simple in-order baseline behave when one execution class becomes multi-cycle and blocks progress?

The recommended behavior for the first Stage 1 version is:

- multiply operations take a configurable number of cycles
- the pipeline stalls while the multiply unit is busy
- issue remains strictly in order
- commit remains strictly in order
- no scoreboard or instruction window is added yet

## Modules Likely To Change

### `RISC_V/rtl/stages/Execute_Stage.sv`

This is the main Stage 1 change point.

Likely modifications:
- add multi-cycle multiply state or interface
- distinguish between ALU-complete-in-one-cycle and MUL-takes-N-cycles behavior
- output a busy or stall-related control signal
- preserve branch and execute-result behavior for non-multiply instructions

### `RISC_V/rtl/top/RISC_V_02.sv`

Top level will likely need to:
- route new stall or busy signals
- hold pipeline state when execute is busy
- possibly expose instrumentation counters later

### Pipeline Register Modules

Likely touch points:
- `RISC_V/rtl/pipeline_registers/FE_DE.sv`
- `RISC_V/rtl/pipeline_registers/DE_EX.sv`
- possibly `RISC_V/rtl/pipeline_registers/EX_MEM.sv`

Expected change:
- add support for holding state during a stall instead of always advancing

### `RISC_V/rtl/stages/Decode_Stage.sv`

Decode may not need structural changes beyond participating in a stall protocol.

The main expectation is:
- when execute is busy, decode should not push a new instruction forward

### `RISC_V/rtl/stages/Fetch_Stage_bp.sv`

Fetch may need a hold behavior so that `pc_f` does not advance while the backend is stalled.

For the first Stage 1 version, the simplest behavior is:
- freeze fetch while execute is busy

## Recommended New Structure

There are two reasonable approaches.

### Option A: Add Busy State Inside `Execute_Stage`

Pros:
- minimal module count increase
- fastest path to a working Stage 1 prototype

Cons:
- execute stage becomes more complex
- later refactoring may be needed if Stage 2 wants a cleaner backend boundary

### Option B: Add A Dedicated Multiplier Block

Example:
- `RISC_V/rtl/blocks/Multiplier_Block.sv`

Pros:
- cleaner separation of concerns
- easier to reason about latency and busy behavior
- better foundation if execution latency experiments become richer

Cons:
- slightly more design work now

Recommendation:
- use Option B if you want cleaner long-term structure
- use Option A only if the immediate goal is a quick experimental baseline

For thesis quality, Option B is the stronger choice.

## Minimal New Signals

Stage 1 will likely need some subset of these signals:

- `mul_busy_e`
- `mul_start_e`
- `mul_done_e`
- `stall_fd`
- `stall_de`
- `stall_ex`
- `execute_busy_e`

These names should follow the conventions in `RISC_V/docs/naming-conventions.md`.

## Recommended First-Cut Stall Policy

For the first Stage 1 implementation:

- if a multiply instruction enters execute, start the multi-cycle unit
- while the unit is busy, hold fetch and decode
- hold `DE_EX` so the current multiply remains resident in execute
- do not allow a younger instruction to enter execute
- once multiply completes, allow the pipeline to resume

This is simple, measurable, and aligned with the Stage 1 goal.

## What Should Not Change In Stage 1

To keep Stage 1 controlled, avoid introducing:

- register renaming
- instruction window logic
- scoreboard readiness tracking
- fetch queue decoupling
- speculative memory behavior

## Deliverables For Stage 1 Completion

Stage 1 should be considered architecturally complete when you have:

- a configurable multi-cycle multiply path
- a documented stall mechanism
- repeatable tests for multiply and stall behavior
- baseline-versus-Stage-1 measurements for cycles and IPC