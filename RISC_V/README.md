# RISC_V Hardware Workspace

This directory contains the active hardware workspace for the thesis CPU.

## Layout

- `rtl/top/`: top-level processor modules
- `rtl/stages/`: pipeline stage modules
- `rtl/blocks/`: reusable building blocks
- `rtl/pipeline_registers/`: inter-stage pipeline registers
- `tb/`: active testbenches
- `programs/`: instruction-memory hex files
- `docs/planning/`: thesis planning documents used alongside implementation

## Notes

- The older pre-reorganization tree is preserved in `../archive/legacy_risc_v_2026-04-07/`.
- The default instruction-memory image for the active fetch stage points to `RISC_V/programs/imem.hex` when run from the repository root.
- Older files such as `RISC_V_01.sv`, `tb_RISC_V_01.sv`, `Fetch_Stage.sv`, and `Writeback_Unit_Block.sv` were intentionally left in the archive rather than copied into the active workspace.