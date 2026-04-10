# Documentation Structure

This repository uses two documentation layers:

- `docs/`: thesis-wide and project-wide documents
- `RISC_V/docs/`: design notes tied to the active hardware implementation

## Current Canonical Docs

- `docs/thesis/research-plan.md`: the polished thesis research plan and scope document
- `docs/long-term-plan.md`: the living roadmap for upcoming work
- `docs/project-journal.md`: dated history of design decisions, progress, and repo changes

## When To Use Each Area

Use `docs/` when the document is about:
- thesis scope
- research questions
- evaluation methodology
- milestone planning
- project history

Use `RISC_V/docs/` when the document is about:
- active module boundaries
- signal inventories
- pipeline diagrams
- implementation notes tied to the current working RTL
- verification notes for the current working version

## Freeze Strategy

Do not duplicate all docs on every small change.

When a hardware version is intentionally frozen for comparison, create a versioned snapshot that includes:
- the frozen RTL
- the frozen testbench or program setup
- the small set of docs needed to interpret that version

Recommended pattern:
- keep thesis-wide documents in `docs/` as the single evolving source of truth
- keep version-specific design documents near the relevant RTL or in a version snapshot only when a freeze actually happens

This avoids heavy documentation overhead during active development while still allowing rigorous comparisons later.