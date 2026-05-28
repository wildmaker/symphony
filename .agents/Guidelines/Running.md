# Running

Record canonical commands for running applications, CLIs, services, workers, demos, local tools, and development servers.

## Runnable Targets

| Target | Command | Working directory | Blocks terminal? | Logs | Success signal | Stop command |
| --- | --- | --- | --- | --- | --- | --- |
| Symphony runtime | `mise exec -- ./bin/symphony /path/to/WORKFLOW.md` | `elixir/` | yes | stdout/logs-root | server starts, polls configured tracker | interrupt process |

## Required Arguments and Environment

- Required arguments: workflow file path for non-default runtime usage.
- Default environment/profile/platform: local Elixir environment via `mise`.
- Valid alternatives: `--port`, `--logs-root`, and alternate workflow paths.
- Required services: Linear tracker for live runs.
- Required secrets: Linear API key for live polling; GitHub auth for PR operations when workflow requires it.

## Preflight

- Stop conflicting debugger/server/processes.
- Confirm build artifacts, migrations, generated files, or seed data are current when needed.
- Confirm ports/devices/emulators/browsers are available.
- Do not let multiple runtimes poll the same ticket pool unless intentionally split by project, assignee, or state strategy.

## Reading Runtime Results

Authoritative output:

- stdout/stderr: primary local runtime output.
- log file: configured logs-root when provided.
- browser/devtools: dashboard/static UI when relevant.
- service logs: Phoenix/Logger output.
- health endpoint: document per runtime if enabled.

In-progress signal:

- PID:
- port:
- log heartbeat:
- readiness probe:

## Long-Running Processes

- How to start in background:
- How to inspect logs:
- How to stop safely:
- Commands or shortcuts agents should avoid:
