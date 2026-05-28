# Running

Record canonical commands for running applications, CLIs, services, workers, demos, local tools, and development servers.

## Runnable Targets

| Target | Command | Working directory | Blocks terminal? | Logs | Success signal | Stop command |
| --- | --- | --- | --- | --- | --- | --- |
| `<target>` | `<command>` | `<path>` | yes/no | `<path or stdout>` | `<health/exit/window>` | `<command>` |

## Required Arguments and Environment

- Required arguments:
- Default environment/profile/platform:
- Valid alternatives:
- Required services:
- Required secrets:

## Preflight

- Stop conflicting debugger/server/processes.
- Confirm build artifacts, migrations, generated files, or seed data are current when needed.
- Confirm ports/devices/emulators/browsers are available.

## Reading Runtime Results

Authoritative output:

- stdout/stderr:
- log file:
- browser/devtools:
- service logs:
- health endpoint:

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
