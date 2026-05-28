---
name: symphony-agent-context-workflow
version: 0.2.0
extends: base-agent-workflow
---

# Symphony Agent Context Workflow

Use the base lifecycle and state machine from `base-agent-workflow`, specialized for Symphony's Elixir orchestration service and project-level agent infrastructure.

## Phoenix Context Discovery

- Read `.agents/profile.md`.
- Read `.agents/Guidelines/Tools.md`, `Building.md`, `Testing.md`, and `Running.md`.
- For Elixir implementation changes, read `elixir/AGENTS.md`.
- For workflow/config changes, read `docs/customizing-workflow.md` and relevant parts of `SPEC.md`.
- Identify whether the change affects runtime orchestration, Linear integration, agent protocol, project setup, or documentation.
- Preserve the distinction between `.agents/WORKFLOW.md` as agent-context infrastructure and `elixir/WORKFLOW.md` as the current Symphony runtime workflow example/config.

## State Specialization

```text
Build
  [MIX_FORMAT_NEEDED] -> FixFormat
  [COMPILE_FAILED] -> FixBuild
  [PASSED] -> Verify
Verify
  [TEST_FAILED] -> FixBehavior
  [MIGRATION_OR_DB_TOUCHED] -> VerifyDatabase
  [API_TOUCHED] -> VerifyContract
  [PASSED] -> Report
```

## Implement

- Prefer existing module boundaries under `elixir/lib/symphony_elixir`.
- Add or update specs for public functions when the project requires them.
- Prefer `SymphonyElixir.Config` for runtime config access.
- Keep workspace safety semantics intact: agents must operate in isolated workspaces, not the source repo.
- Preserve telemetry, logging, and supervision semantics.
- Do not duplicate long-lived agent guidance across root, `.github`, and `.cursor`; point adapters to `.agents/`.

## Verify

- Run formatter checks when code changed.
- Run targeted tests first, then the full project gate when risk warrants it.
- Run `cd elixir && mix specs.check` for public function spec changes.
- Run `cd elixir && make all` before handoff for orchestration, config, workflow, or shared behavior changes when feasible.
- For adapter/template changes, verify expected files exist and point back to `.agents/`.
