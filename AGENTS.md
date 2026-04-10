# AGENTS.md

This repository contains a thesis-oriented RISC-V CPU project. Future AI assistants should optimize for architectural clarity, incremental changes, and traceable design decisions.

## Primary Working Rules

- Treat the current CPU as the baseline unless the user explicitly says otherwise.
- Preserve a runnable baseline when making thesis-related changes.
- Prefer minimal, staged modifications over broad refactors.
- Do not rewrite large parts of the CPU unless the architecture plan requires it.
- Keep naming explicit and structural. This project values signal-level clarity.

## Documentation Responsibilities

- For meaningful work, update `docs/project-journal.md` with a dated entry.
- If priorities, sequencing, or architecture direction changes, update `docs/long-term-plan.md`.
- Treat `docs/thesis/research-plan.md` as the canonical thesis-scope and research-plan document.
- Keep the journal append-only except for minor factual corrections.
- Record assumptions, open questions, and validation status when they matter.

## Architecture Context

- The current reference design is a modular 5-stage RISC-V pipeline.
- Active HDL now lives under `RISC_V/rtl`, testbenches under `RISC_V/tb`, programs under `RISC_V/programs`, thesis-wide docs under `docs/`, and RTL-specific docs under `RISC_V/docs/`.
- The pre-reorganization tree is preserved under `archive/legacy_risc_v_2026-04-07`.
- The thesis direction is to explore minimal dynamic scheduling mechanisms, not full out-of-order execution.
- Avoid introducing register renaming, large reorder buffers, superscalar issue, or memory speculation unless the user explicitly changes the thesis scope.

## Preferred Workflow

1. Read the current architecture before proposing changes.
2. Identify whether the task is baseline cleanup, Stage 1 planning, Stage 2 planning, or Stage 3 planning.
3. Make the smallest coherent change.
4. Verify syntax and obvious behavioral correctness.
5. Update the journal and roadmap if the work was substantial.

## Planning Guidance

- Before coding a new architectural feature, define module boundaries and interfaces first.
- For Stage 2 in particular, decide ownership of instruction storage, readiness tracking, completion, and commit before naming every new wire.
- Prefer documents and diagrams that describe deltas from the baseline architecture.
- Follow the RTL and verification naming guidance in `RISC_V/docs/naming-conventions.md` for new work.

## Repo Notes

- Be cautious with environment-specific paths.
- Keep test and measurement setup reproducible.
- If a task changes evaluation methodology, record that change in the journal.

## Testbench System (added 2026-04-10)

The baseline test suite lives in `RISC_V/tb/` and `RISC_V/tests/specs/`.

Key files:
- `RISC_V/tb/cpu_if.sv`         — SystemVerilog interface with clocking block and modports (tb / dut)
- `RISC_V/tb/cpu_test_pkg.sv`   — Package: shared types (test_descriptor_t, reg_check_t, mem_check_t), parse utilities
- `RISC_V/tb/tb_cpu_suite.sv`   — Top testbench containing: yaml_loader (module), cpu_suite_runner (program), tb_cpu_suite (top module)
- `RISC_V/tests/specs/baseline-suite.yaml` — Machine-readable test spec: expected register and memory state per test

How it works:
1. yaml_loader reads baseline-suite.yaml at sim start and populates test_descriptor_t array
2. cpu_suite_runner iterates enabled tests, calls $readmemh to reload ROM per test, resets DUT, runs until x12==1 or timeout
3. Shadow register file tracks every WB-bus write; compared against YAML expected values at end of each test
4. Memory checks use hierarchical reference to Data_Memory_Block.data_memory (byte array, big-endian)

Stop condition: simulation stops when x12 (reg 12) is written with value 1. All test programs must terminate this way.

VCS compile + run (from repo root):
```
vcs -sverilog -timescale=1ns/1ps \
    RISC_V/tb/cpu_test_pkg.sv \
    RISC_V/tb/cpu_if.sv \
    RISC_V/rtl/blocks/ALU_Block.sv \
    RISC_V/rtl/blocks/Branch_Predictor_Block.sv \
    RISC_V/rtl/blocks/Control_Unit_Block.sv \
    RISC_V/rtl/blocks/Data_Memory_Block.sv \
    RISC_V/rtl/blocks/Forwarding_Unit_Block.sv \
    RISC_V/rtl/blocks/Immediate_Generator_Block.sv \
    RISC_V/rtl/blocks/Instruction_Memory_Block.sv \
    RISC_V/rtl/blocks/Register_File_Block.sv \
    RISC_V/rtl/pipeline_registers/DE_EX.sv \
    RISC_V/rtl/pipeline_registers/EX_MEM.sv \
    RISC_V/rtl/pipeline_registers/FE_DE.sv \
    RISC_V/rtl/pipeline_registers/MEM_WB.sv \
    RISC_V/rtl/stages/Decode_Stage.sv \
    RISC_V/rtl/stages/Execute_Stage.sv \
    RISC_V/rtl/stages/Fetch_Stage_bp.sv \
    RISC_V/rtl/stages/Memory_Stage.sv \
    RISC_V/rtl/stages/Writeback_Stage.sv \
    RISC_V/rtl/top/RISC_V_02.sv \
    RISC_V/tb/tb_cpu_suite.sv \
    -top tb_cpu_suite -o simv
./simv
```

Known baseline RTL issues (pre-existing, do not fix without thesis justification):
- Data_Memory_Block uses $urandom init — load tests must SW before LW
- Branch predictor state resets to 00 (predict not-taken); first taken branch always causes a flush
- reg_write_en signal is not exposed on the WB bus output of RISC_V_02; shadow copy uses reg_writeaddr != 0 as write-enable proxy