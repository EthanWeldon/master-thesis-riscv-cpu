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