# Project Journal

Purpose: keep a running record of design decisions, implementation progress, test results, and open issues for the thesis CPU.

Update rules:
- Add a new dated entry for meaningful architecture changes, debugging milestones, benchmark work, or thesis-planning decisions.
- Keep old entries. This file should be append-only except for small factual corrections.
- Prefer concrete facts over vague status notes.
- If a change affects the roadmap, update `docs/long-term-plan.md` in the same work session.

Suggested entry template:

## YYYY-MM-DD - Short Title

Summary:
- What changed.
- Why it changed.

Details:
- Files/modules involved.
- Key signals, interfaces, or behaviors affected.
- Test status or evidence.

Open items:
- Remaining risks.
- Follow-up tasks.

---

## 2026-04-07 - Documentation Structure Created

Summary:
- Created a persistent project journal, roadmap, and AI workspace instructions.
- Established a default place to track thesis progress and future architectural decisions.

Details:
- Added `docs/project-journal.md` for dated progress entries.
- Added `docs/long-term-plan.md` for forward planning.
- Added `AGENTS.md` so future AI assistants know how to work in this repository.

Open items:
- Freeze the current CPU as the baseline architecture.
- Write the Stage 1 module plan for multi-cycle execution.

---

## 2026-04-07 - Repository Structure Reorganized

Summary:
- Archived the original CPU tree and created a cleaner active hardware layout.
- Kept the full legacy implementation intact so older files and experiments are not lost.

Details:
- Moved the previous `RISC_V` tree to `archive/legacy_risc_v_2026-04-07`.
- Built a new active layout with `RISC_V/rtl`, `RISC_V/tb`, `RISC_V/programs`, and `RISC_V/docs/planning`.
- Copied the active baseline files into the new layout and left older or less useful files only in the archive.
- Updated the fetch-stage instruction-memory path to point at the new programs directory.

Open items:
- Add a baseline architecture overview document tied to the new folder layout.
- Decide whether to split future Stage 2 work into additional subfolders such as `rtl/backend` or `rtl/experimental`.

---

## 2026-04-07 - Root Folder Renamed

Summary:
- Renamed the repository root folder to `thesis-cpu-project`.
- Moved the reference material out of `Resources_Docs` into a cleaner `references/isa` location.

Details:
- The top-level path is now `thesis-cpu-project` under the parent workspace directory.
- Reference documentation now lives under `references/isa`.
- Updated the root README to reflect the new project name and reference-doc location.

Open items:
- Update any external scripts or simulator configs outside the repo if they still point to the old root path.

---

## 2026-04-07 - Thesis Plan Integrated Into Docs System

Summary:
- Moved the thesis plan conceptually out of the hardware subtree and integrated it into the main documentation system.
- Established a clean split between thesis-wide documents and RTL-specific design notes.

Details:
- Created `docs/thesis/research-plan.md` as the canonical research-plan document.
- Added `docs/README.md` to define documentation roles and freeze strategy.
- Added `RISC_V/docs/README.md` to reserve the hardware docs area for active RTL-facing notes.
- Kept `docs/long-term-plan.md` as a short roadmap instead of duplicating the full thesis narrative.

Open items:
- Add the first active RTL design note when the baseline architecture is formally frozen.
- Decide the freeze naming convention when the first comparison version is created.

---

## 2026-04-07 - Baseline RTL Docs Created

Summary:
- Added the first active RTL-specific documentation set for the current baseline CPU.
- Established separate baseline docs for architecture, major interfaces, and verification posture.

Details:
- Added `RISC_V/docs/baseline-architecture.md`.
- Added `RISC_V/docs/baseline-signals.md`.
- Added `RISC_V/docs/baseline-verification.md`.
- Updated `RISC_V/docs/README.md` to point at the active baseline docs.

Open items:
- Turn the architecture doc into a more formal baseline freeze document once the run flow is stabilized.
- Add a test matrix and run procedure before performance comparison work begins.

---

## 2026-04-07 - Naming Conventions Defined

Summary:
- Added a written naming convention for RTL and verification artifacts.
- Preserved the existing stage-suffix naming style while adding clearer rules for future thesis work.

Details:
- Added `RISC_V/docs/naming-conventions.md`.
- Documented the current base scheme of functional names, grouped prefixes, role suffixes, and stage suffixes.
- Added guidance for `_valid`, `_ready`, `_complete`, `_busy`, `_flush`, and `_stall` signals expected in later stages of the project.
- Added verification naming guidance for tests, program images, monitors, and counters.

Open items:
- Decide later whether to rename existing numbered bridge signals when those modules are next edited.
- Apply the verification naming rules when the first real test matrix is created.

---

## 2026-04-07 - Stage 1 And Baseline Comparison Docs Added

Summary:
- Added the next planning layer for Stage 1 design and baseline comparison readiness.
- Established concrete documents for both architecture change planning and repeatable baseline validation.

Details:
- Added `RISC_V/docs/stage1-module-plan.md`.
- Added `RISC_V/docs/stage1-interface-changes.md`.
- Added `RISC_V/docs/baseline-run-procedure.md`.
- Added `RISC_V/docs/baseline-test-matrix.md`.

Open items:
- Fill in simulator-specific commands in the run procedure once the chosen tool flow is fixed.
- Replace the test matrix placeholder expectations with concrete expected outcomes.

---

## 2026-04-08 - Project-Wide Baseline Test Set Defined

Summary:
- Expanded the baseline test matrix into a reusable project-wide validation and comparison suite.
- Added a comparison-data document defining which metrics should be collected across CPU versions.

Details:
- Reworked `RISC_V/docs/baseline-test-matrix.md` into regression, stress, and workload groups.
- Defined which tests are required for cross-version comparison.
- Added `RISC_V/docs/comparison-data.md` to standardize metric collection across baseline and later stages.
- Linked the comparison-data guidance into the verification docs and RTL docs index.

Open items:
- Define exact expected architectural outcomes for the required tests.
- Add the new program images for the recommended stress and workload tests.

---

## 2026-04-08 - Baseline Test Spec File Added

Summary:
- Added a single machine-readable baseline suite file to hold exact per-test input and expected output data.
- Captured exact expected architectural state for the currently usable baseline program images.

Details:
- Added `RISC_V/tests/specs/baseline-suite.yaml` as the canonical source of per-test data.
- Marked `imem.hex` and `simple_branch.hex` as blocked because they are not currently clean finite regression tests.
- Filled in exact expected register and memory outcomes for `simple_add.hex`, `simple_sub.hex`, `simple_jump.hex`, `simple_SW_LW_instr.hex`, and `simple_instr.hex`.
- Linked the baseline spec file from the matrix, run procedure, and RTL docs index.

Open items:
- Build the missing branch, dependency, and workload program images so the blocked planned tests become runnable.
- Decide whether the future test harness should consume YAML directly or generate a simpler derived format for simulation.