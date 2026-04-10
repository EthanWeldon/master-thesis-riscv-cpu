# Long-Term Plan

Purpose: keep the thesis work organized at the architecture level, not just as a task list.

How to use this file:
- Update this file when priorities, architecture direction, or milestone sequencing changes.
- Keep sections short and current.
- Move completed items into the journal rather than letting this file grow into a full history log.
- Keep the fuller thesis narrative in `docs/thesis/research-plan.md` and use this file as the shorter working roadmap.

## Thesis Goal

Measure how much performance can be recovered in a single-issue in-order RISC-V core using small dynamic scheduling mechanisms without full out-of-order complexity.

## Baseline

- Current reference core: `RISC_V/rtl/top/RISC_V_02.sv`
- Current structure: modular 5-stage pipeline with stage, block, and pipeline-register separation
- Immediate baseline tasks:
- Freeze current behavior.
- Remove environment-specific friction.
- Define repeatable verification and measurement flow.

## Near-Term Priorities

- Document the current baseline architecture.
- Identify minimal cleanup required before thesis modifications.
- Plan Stage 1 module changes for multi-cycle execution.
- Define the counters and observability needed for IPC and stall analysis.

## Architecture Roadmap

### Stage 0 - Baseline Freeze

- Confirm module boundaries and signal naming.
- Record current fetch, decode, execute, memory, and writeback behavior.
- Stabilize testbench and instruction-memory setup.

### Stage 1 - Multi-Cycle Execution

- Add a configurable multi-cycle multiply path or equivalent execute busy behavior.
- Define stall behavior across fetch/decode/execute.
- Measure IPC degradation and stall breakdown.

### Stage 2 - Window Plus Scoreboard

- Add a small instruction window.
- Add scoreboard-based readiness tracking.
- Preserve single issue and in-order commit.
- Define issue, completion, and commit ownership clearly.

### Stage 3 - Front-End Decoupling

- Add a fetch queue.
- Evaluate branch predictor alternatives.
- Study interaction between front-end buffering and backend scheduling.

## Open Questions

- Which existing modules should be extended versus replaced in Stage 2?
- How should commit be represented structurally: a new module or logic distributed across decode/writeback?
- What benchmark/program set will be used for meaningful evaluation?

## Working Rules

- Prefer incremental, testable architectural changes.
- Do not do broad cleanup unless it directly improves thesis progress.
- Preserve a runnable baseline at all times.