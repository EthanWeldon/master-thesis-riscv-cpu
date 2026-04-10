# Naming Conventions

This document defines preferred naming conventions for the active RTL and related verification work.

## 1. RTL Signal Naming

The current project direction is good and should be kept. The naming scheme should be:

- start with a functional name
- group related signals under a shared prefix when that improves readability
- use suffixes for role and pipeline stage

Recommended form:

`<group_or_signal_name>[_<role>][_stage]`

Examples:

- `instr_f`
- `pc_branch`
- `pc_branch_en_sel`
- `reg_write_addr_w`
- `dmem_read_en_m`

## 2. Core Rules

### Functional Base Name

The first part of the name should identify what the signal means.

Examples:

- `instr`
- `pc`
- `imm_data`
- `reg_write_addr`
- `execute_out`

This is the most important part of the signal name and should stay stable across stages.

### Shared Prefixes For Families

Use a shared prefix when multiple related signals belong to one conceptual group.

Examples:

- `pc_f`, `pc_d`, `pc_e`
- `pc_branch`, `pc_branch_en_sel`
- `reg_write_en_d`, `reg_write_addr_d`, `reg_writedata_w`
- `dmem_read_en_m`, `dmem_write_en_m`

This is a good practice and should stay.

### Role Suffixes

Use role suffixes consistently:

- `_sel`: mux select control
- `_en`: enable control
- `_addr`: address or register index
- `_data`: generic data payload when needed for clarity
- `_in` and `_out`: module boundary direction markers when a local name is not enough

Examples:

- `execute_out_sel_e`
- `dmem_read_en_m`
- `reg_write_addr_w`
- `pc_d_in`
- `pc_d_out`

### Stage Suffixes

When the same conceptual signal exists at multiple pipeline locations, use a stage suffix at the end.

Recommended stage suffixes for the current baseline:

- `_f`: fetch
- `_d`: decode
- `_e`: execute
- `_m`: memory
- `_w`: writeback

This is the right pattern for a pipelined CPU and should remain the default.

## 3. Additions I Recommend

Your current system is strong. I would add a few explicit rules so it scales better as the thesis grows.

### Reserve `_in` And `_out` For Module Boundaries

Use `_in` and `_out` only when talking about a module port boundary, not as a replacement for stage naming.

Good:

- `execute_out_m_in`
- `execute_out_m_out`

Avoid:

- `execute_out_in`
- `execute_out_out`

without a stronger contextual reason.

### Use Full Words For Architectural Meaning

Avoid abbreviations unless they are standard in the project.

Good:

- `reg_write_addr`
- `reg_readdata1`
- `pc_branch_en_sel`

Avoid:

- `rwa`
- `pbes`
- `rrd1`

The current repo already mostly follows this.

### Separate Data Signals From Control Signals

Try to make it visually obvious whether a signal is data or control.

Control examples:

- `_en`
- `_sel`
- `flush_*`
- `stall_*`
- `valid_*` or `*_valid`
- `ready_*` or `*_ready`

Data examples:

- `instr_*`
- `pc_*`
- `imm_data_*`
- `execute_out_*`
- `reg_readdata*_*`

This becomes more important in Stage 2 once valid, ready, complete, and window bookkeeping signals are introduced.

### Be Consistent About Bitfield Families

If a family grows, use a common base name.

For example, if Stage 2 adds window entries, prefer a pattern like:

- `win_valid_d`
- `win_src1_ready_d`
- `win_src2_ready_d`
- `win_dest_addr_d`
- `win_complete_d`

or use `iw_` instead of `win_`, but choose one and keep it consistent.

### Avoid Numbered Suffixes Except For Temporary Bridging

Names like `_1` and `_2` are sometimes necessary during bring-up, but they are not good long-term architectural names.

Examples from the current baseline that should eventually be cleaned up when touched:

- `pc_d_1`
- `pc_d_2`
- `reg_write_en_e_1`
- `reg_write_en_e_2`

Preferred replacements are architectural names tied to stage boundaries, such as:

- `pc_fd`
- `pc_de`

or explicit boundary-oriented names such as:

- `pc_from_fd`
- `pc_into_ex`

You do not need to rename these immediately, but new work should avoid growing this pattern.

## 4. Suggested Extended RTL Convention

Here is a practical rule set for future modules:

1. Base name describes function.
2. Shared prefix groups related signals.
3. `_sel`, `_en`, `_valid`, `_ready`, `_complete`, `_busy`, `_flush`, `_stall` are reserved for control/state semantics.
4. `_addr`, `_data`, `_tag`, `_value` are used when needed for clarity.
5. Stage suffix comes last when the signal exists in multiple pipeline stages.
6. `_in` and `_out` are used only for module interface direction.
7. Avoid numeric suffixes unless temporarily unavoidable.

## 5. Verification Naming Convention

Yes, you should define a similar convention for verification. It does not have to be identical, but it should map cleanly onto the RTL naming.

Recommended verification naming layers:

### Testbench Instance Names

Use instance names that describe role, not just type.

Examples:

- `dut`
- `imem_model`
- `scoreboard`
- `monitor_wb`

For this repo, renaming the current top-level instance from `risc_v_core` to `dut` would be a reasonable long-term cleanup, but it is not urgent.

### Test Names

Use a predictable pattern:

`test_<feature>_<scenario>`

Examples:

- `test_alu_add_basic`
- `test_branch_taken`
- `test_load_use_hazard`
- `test_mul_multicycle_stall`

### Program Image Names

Use a clearer naming scheme as the suite grows:

`prog_<feature>_<scenario>.hex`

Examples:

- `prog_alu_add_basic.hex`
- `prog_branch_taken.hex`
- `prog_load_store_basic.hex`

This is better than a mixed set of names once the project gets larger.

### Expected Result Signals And Checkers

For testbench-local signals, use names that distinguish observed versus expected values.

Examples:

- `exp_reg_write_addr`
- `exp_reg_writedata`
- `obs_reg_write_addr`
- `obs_reg_writedata`
- `test_pass`
- `test_done`

### Counters And Monitors

Use explicit metric-oriented names:

- `cycle_count`
- `retire_count`
- `flush_count`
- `stall_count`
- `mul_busy_count`

If the same metric is tracked per version, keep the same metric name across versions.

## 6. What To Do Next

For the current repo, I recommend:

1. Keep your existing base convention.
2. Add the new reserved suffixes for future Stage 1 and Stage 2 work.
3. Stop introducing new numeric bridge names where possible.
4. Start using a verification naming convention now, especially for tests and program images.

That gives you a clean path from the baseline into the more complex scheduling versions.