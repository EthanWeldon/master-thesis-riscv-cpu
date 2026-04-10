# Stage 1 Interface Changes

This document captures the expected interface-level deltas between the baseline core and the Stage 1 multi-cycle execution version.

## Purpose

Before changing the RTL, define which interfaces are expected to change so the implementation stays deliberate.

## Expected New Control Concepts

Stage 1 introduces one new architectural concept:

- execute can be busy for multiple cycles

That concept will likely appear in the interfaces as:

- busy indication
- start or launch control for multiply
- done or complete indication
- stall signals for earlier stages or pipeline registers

## Candidate New Signals

### Execute-Local Control

- `mul_start_e`: pulse to launch a multiply operation
- `mul_busy_e`: multiply unit is still working
- `mul_done_e`: multiply result is ready
- `execute_busy_e`: broader execute-stage busy indication if you want one signal above the multiplier level

### Stall Control

- `stall_fd`: hold fetch-to-decode state
- `stall_de`: hold decode-to-execute state
- `stall_pc_f`: prevent program-counter advance in fetch

You may collapse some of these into fewer signals, but the semantics should remain clear.

## Interface Areas Likely To Change

### Top Level

`RISC_V/rtl/top/RISC_V_02.sv`

Likely additions:
- new internal wires for busy and stall control
- stall wiring into fetch and pipeline-register modules

### Fetch Stage

`RISC_V/rtl/stages/Fetch_Stage_bp.sv`

Possible new input:
- `stall_f` or `stall_pc_f`

Expected behavior:
- do not advance `pc_f` while stalled

### FE_DE Pipeline Register

Likely new input:
- `stall_fd`

Expected behavior:
- retain the current contents when stalled

### Decode Stage

Decode may not need new data ports, but it may participate in a held pipeline state indirectly through `DE_EX`.

### DE_EX Pipeline Register

Likely new input:
- `stall_de`

Expected behavior:
- retain current execute inputs while the multiply operation is still in progress

### Execute Stage

Likely new ports:
- input for multiply latency configuration if made parameterized
- outputs such as `mul_busy_e` and `mul_done_e`

Potential optional port:
- `stall_ex`

This is not always necessary if execute owns the busy state internally.

## Suggested Boundary Decision

The cleanest boundary for Stage 1 is:

- execute owns multiply progress
- top level owns stall distribution
- pipeline registers own hold behavior

This keeps each block's responsibility understandable.

## Signals To Avoid For Now

Avoid introducing Stage 2 concepts early, such as:

- window valid bits
- operand ready arrays
- issue-ready arbitration outputs
- commit pointers

Those belong to later interfaces.

## Verification Impact

The interface changes should be reflected in tests that can observe:

- multiply takes more than one cycle
- earlier pipeline stages stop advancing during the busy interval
- execution resumes correctly after completion

## Exit Criteria

This interface plan is good enough when you can answer these questions unambiguously:

- where does multiply busy state live?
- which stages are held during busy cycles?
- who generates stall signals?
- which module is responsible for preserving each pipeline register during a stall?