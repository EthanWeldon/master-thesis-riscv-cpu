# Research Plan

## Title

Exploring Minimal Dynamic Scheduling Mechanisms in Single-Issue In-Order RISC-V Cores

## 1. Motivation

Modern high-performance processors rely on out-of-order execution to exploit instruction-level parallelism. However, embedded-class and small RISC-V cores remain strictly in-order because of area and complexity constraints.

This project investigates the architectural boundary between strict in-order execution and full out-of-order execution. The goal is to determine how much performance improvement can be achieved in a simple single-issue RISC-V core using minimal dynamic scheduling mechanisms, without introducing:

- register renaming
- a large reorder buffer
- superscalar issue
- memory speculation

The study is intended to evaluate the performance versus complexity tradeoff of small dynamic mechanisms in embedded-style cores.

## 2. Research Question

Primary question:

How much of the performance benefit of out-of-order execution can be recovered in a single-issue in-order RISC-V core using a small instruction window and minimal dynamic scheduling mechanisms?

Secondary questions:

- What is the performance impact of increasing instruction window size from 2 to 4 to 6 entries?
- How sensitive is performance improvement to execution latency, such as a multi-cycle multiplier?
- How does front-end decoupling through fetch buffering affect backend scheduling effectiveness?
- Where do diminishing returns appear in window size and front-end buffering?

## 3. Baseline Architecture

Starting point:

- 5-stage single-issue in-order RISC-V core
- IF -> ID -> EX -> MEM -> WB
- 1-cycle memory model
- basic branch predictor
- strict in-order issue, execution, and commit

This serves as the control configuration.

## 4. Architectural Enhancements

The project proceeds in controlled stages.

### Stage 1: Multi-Cycle Execution Unit

Purpose:

- introduce realistic backend pressure
- create execution-induced stalls

Modifications:

- add configurable multi-cycle multiplier, for example 2, 3, or 4 cycles
- baseline behavior stalls the pipeline while the multiplier is busy

Measurements:

- stall cycle breakdown
- IPC degradation versus a 1-cycle multiplier
- impact of increasing execution latency

### Stage 2: Instruction Window Plus Scoreboard

Purpose:

- allow limited out-of-order execution while maintaining in-order commit

New structures:

- instruction window with size 2, 4, or 6
- scoreboard with one readiness bit per architectural register

Each instruction-window entry contains:

- valid bit
- opcode
- source register IDs
- destination register ID
- operand values
- operand ready bits
- completion bit
- result value

Scoreboard behavior:

- mark `rd` not ready on decode
- mark `rd` ready on execution completion

Issue logic:

- oldest-ready-first selection
- single issue per cycle
- issue from the window into the execution path

Commit logic:

- commit pointer tracks the oldest window entry
- architectural register file updates only when the entry is complete and oldest
- in-order commit is enforced

Constraints:

- single issue
- no reorder buffer
- no register renaming
- no memory speculation

Measurements:

- IPC improvement over baseline
- window utilization statistics
- stall cycle breakdown
- ready-instruction frequency
- sensitivity to window size

### Stage 3: Front-End Decoupling

Purpose:

- prevent fetch starvation when the backend stalls
- study front-end and backend interaction

New structure:

- fetch queue with depth 0, 4, or 8

Behavior:

- fetch continues during backend stalls
- branch predictor runs continuously
- decode consumes from the queue when the window is not full

Branch predictor variants:

- bimodal baseline
- gshare or another lightweight alternative

Measurements:

- IPC versus queue depth
- branch misprediction impact
- front-end starvation cycles
- interaction with window size

Optional extension:

- limited dual-path fetch for short windows

## 5. Evaluation Plan

### Parameter Sweep

Backend:

- window size: 0, 2, 4, 6
- multiplier latency: 1, 2, 4 cycles

Frontend:

- fetch queue depth: 0, 4, 8
- predictor type: bimodal versus gshare

### Metrics

Performance:

- IPC or CPI
- speedup over baseline

Pipeline behavior:

- stall cycle breakdown
- execution unit busy cycles
- operand-not-ready cycles
- control flush cycles
- fetch starvation cycles
- window occupancy distribution
- percentage of cycles with at least one ready instruction

Complexity proxies:

- number of window entries
- scoreboard state bits
- qualitative control-logic growth
- structural comparisons

No physical design, area, or power modeling is required.

## 6. Architectural Boundaries

This project intentionally avoids:

- register renaming
- large reorder buffers
- superscalar issue
- memory disambiguation
- speculative loads and stores
- cache modeling
- physical design exploration

This keeps the study focused on minimal dynamic scheduling mechanisms.

## 7. Expected Contributions

- a minimal OoO-lite scheduling architecture for single-issue RISC-V cores
- a systematic exploration of window size versus performance
- quantification of diminishing returns in small dynamic scheduling
- analysis of front-end and backend interaction in constrained pipelines
- a clear architectural comparison between strict in-order and limited dynamic execution

## 8. Relationship to Prior Work

- scoreboarding in the CDC 6600 demonstrated early dynamic scheduling
- Tomasulo's algorithm introduced renaming and reservation stations
- modern out-of-order cores use reorder buffers and physical register files

This project differs by:

- restricting to single-issue execution
- avoiding register renaming
- using very small windows
- targeting embedded-style RISC-V cores
- focusing on systematic parameter exploration rather than full out-of-order implementation

## 9. Implementation Timeline

### Semester 1

- add multi-cycle execution
- implement instruction window and scoreboard
- validate in-order commit
- run initial performance experiments

### Semester 2

- add fetch queue
- add alternate branch predictor
- perform parameter sweeps
- analyze diminishing returns
- write thesis