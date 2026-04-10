# RTL Documentation

This directory is reserved for documents tied directly to the active RTL.

Examples:

- baseline block diagrams
- per-stage signal lists
- interface specs for new modules
- verification notes for the current working core

Current active docs:

- `baseline-architecture.md`
- `comparison-data.md`
- `baseline-signals.md`
- `baseline-verification.md`
- `baseline-run-procedure.md`
- `baseline-test-matrix.md`
- `naming-conventions.md`
- `stage1-module-plan.md`
- `stage1-interface-changes.md`

Machine-readable test specs:

- `RISC_V/tests/specs/baseline-suite.yaml`

Do not put thesis-wide planning here. Use the top-level `docs/` directory for that.

When the project is frozen at a comparison point, the relevant RTL-facing documents can either:

- stay next to the frozen RTL snapshot
- or be copied into that snapshot if they are needed to interpret results later

That decision should be made at the time of the freeze, not duplicated preemptively.