---
name: backend-service-phoenix-agent-workflow
version: 0.2.0
extends: base-agent-workflow
---

# Phoenix Backend Service Workflow

Use the base lifecycle and state machine from `base-agent-workflow`, specialized for Phoenix/Elixir backend services.

## Phoenix Context Discovery

- Read `.agents/profile.md`.
- Read `.agents/Guidelines/Tools.md`, `Building.md`, `Testing.md`, and `Running.md`.
- Inspect `mix.exs`, config files, routers, contexts, schemas, jobs, and tests relevant to the change.
- Prefer existing context boundaries and configuration surfaces.

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

- Prefer existing Phoenix context boundaries.
- Add or update specs for public functions when the project requires them.
- Keep migrations reversible when possible.
- Avoid ad-hoc environment reads; use existing config surfaces.
- Preserve telemetry, logging, and supervision semantics.

## Verify

- Run formatter checks when code changed.
- Run targeted tests first, then the full project gate when risk warrants it.
- Validate migrations and database behavior when touched.
- Validate API contracts, serialization, and error behavior when endpoints or clients are touched.
