# Baseline Signals And Interfaces

This document captures the main architectural interfaces in the active baseline. It is not intended to list every internal net inside every block. It focuses on the signals that define stage boundaries and major control behavior.

## Top-Level Ports

Module:
- `RISC_V/rtl/top/RISC_V_02.sv`

Inputs:
- `clk`: pipeline clock
- `reset`: synchronous reset input used across pipeline registers and fetch state
- `imem_read_en`: instruction-memory read enable

Outputs:
- `reg_writedata`: writeback data exposed externally
- `reg_writeaddr`: writeback destination register exposed externally

## Stage Boundary Signals

### Fetch To FE_DE

Key fetch outputs:
- `pc_f`: current fetch PC
- `instr_f`: fetched instruction
- `flush_fd`: flush control for `FE_DE`
- `flush_de`: flush control for `DE_EX`

Stored in:
- `FE_DE`

FE_DE outputs:
- `instr_d`
- `pc_d_1`

### Decode To DE_EX

Key decode outputs:
- destination/writeback control:
  - `reg_write_en_d`
  - `reg_write_addr_d`
  - `reg_writedata_sel_d`
- PC and branch-input control:
  - `pcadder_in1_sel_d`
  - `pcadder_in2_sel_d`
  - `pcadder_out_sel_d`
  - `pcadder_out_merge_sel_d`
- execute control:
  - `alu_en_d`
  - `alu_op_d`
  - `alu_mul_data2_sel_d`
  - `mul_en_d`
  - `execute_out_sel_d`
- memory control:
  - `dmem_read_en_d`
  - `dmem_write_en_d`
- register-specifier and operand data:
  - `reg_read_addr1_d`
  - `reg_read_addr2_d`
  - `reg_readdata1_d`
  - `reg_readdata2_d`
  - `imm_data_d`
  - `pc_d_2`

Stored in:
- `DE_EX`

### Execute Inputs And Outputs

Primary execute inputs after `DE_EX`:
- `pc_e`
- `reg_readdata1_e`
- `reg_readdata2_e_1`
- `imm_data_e`
- execute control bundle mirrored from decode

Forwarding-control inputs:
- `alumul_data1_sel_e`
- `alumul_forward_sel_e`

Primary execute outputs:
- `execute_out_e`
- `pc_branch`
- `pc_branch_en_sel`
- metadata forwarded toward memory:
  - `reg_write_addr_e_2`
  - `reg_write_en_e_2`
  - `dmem_read_en_e_2`
  - `dmem_write_en_e_2`
  - `reg_writedata_sel_e_2`
  - `reg_readdata2_e_2`

Stored in:
- `EX_MEM`

### Memory To MEM_WB

Memory-stage outputs:
- `dmem_readdata_m`
- `execute_out_m_2`
- `reg_write_addr_m_2`
- `reg_write_en_m_2`
- `reg_writedata_sel_m_2`

Stored in:
- `MEM_WB`

### Writeback Outputs

Writeback-stage outputs:
- `reg_writedata_w`
- `reg_write_addr_w`
- `reg_write_en_w`

These feed:
- `Decode_Stage` for register-file updates
- top-level outputs for testbench observation

## Major Supporting Interfaces

### Branch Redirection

Key signals:
- `pc_branch`
- `pc_branch_en_sel`
- `flush_fd`
- `flush_de`

These connect execute-time branch outcomes back into fetch/pipeline-control behavior.

### Forwarding

Forwarding inputs:
- `reg_write_addr_m_1`
- `reg_read_addr1_e`
- `reg_read_addr2_e`
- `reg_write_addr_w`

Forwarding outputs:
- `alumul_data1_sel_e`
- `alumul_forward_sel_e`

This is the current hazard-mitigation mechanism for execute-stage data dependencies.

### Program Inputs

Instruction memory default image:
- `RISC_V/programs/imem.hex`

Other available program images:
- `RISC_V/programs/simple_add.hex`
- `RISC_V/programs/simple_sub.hex`
- `RISC_V/programs/simple_branch.hex`
- `RISC_V/programs/simple_jump.hex`
- `RISC_V/programs/simple_instr.hex`
- `RISC_V/programs/simple_SW_LW_instr.hex`

## Signals Worth Watching In Future Versions

When Stage 1 begins, these are the first interface areas likely to change:
- execute busy or multiply busy indication
- stall or hold signals into fetch, decode, and pipeline registers
- instrumentation counters for busy cycles and flush cycles

When Stage 2 begins, these are likely to be replaced or heavily reworked:
- direct decode-to-execute operand/control interface
- forwarding-only hazard handling model
- writeback-as-commit assumption