# thesis-cpu-project

Team Members: 
        Ethan Weldon


## Repository Layout

- `RISC_V/`: active hardware workspace for the thesis CPU
- `archive/legacy_risc_v_2026-04-07/`: preserved copy of the earlier CPU tree
- `docs/`: project journal and long-term planning documents
- `references/`: reference material and ISA notes

## Active Hardware Layout

- `RISC_V/rtl/top/`: top-level CPU module
- `RISC_V/rtl/stages/`: fetch, decode, execute, memory, and writeback stage modules
- `RISC_V/rtl/blocks/`: reusable functional blocks such as ALU, branch predictor, memory, and register file
- `RISC_V/rtl/pipeline_registers/`: pipeline register modules between stages
- `RISC_V/tb/`: active testbenches
- `RISC_V/programs/`: hex files for instruction memory
- `RISC_V/docs/`: active RTL-specific design and verification notes

## Thesis Docs

- `docs/thesis/research-plan.md`: canonical research-plan and scope document
- `docs/long-term-plan.md`: shorter working roadmap
- `docs/project-journal.md`: dated project history

The active layout is intended for ongoing thesis development. The archive keeps the older structure intact for reference and recovery.

