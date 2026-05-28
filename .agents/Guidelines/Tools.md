# Tools and Scripts

Use this registry to prevent agents from guessing commands.

## Policy

- Prefer repository-provided wrappers over direct tool invocation.
- Use direct low-level tools only when this registry allows it or when no wrapper exists.
- Record authoritative logs and completion markers for wrappers.
- Document platform-specific command differences.

## Tool Registry

| Purpose | Preferred command/script | Working directory | Parameters | Output/logs | Completion marker | Forbidden direct commands |
| --- | --- | --- | --- | --- | --- | --- |
| Build/full gate | `make all` | `elixir/` | none | terminal output | exit code 0 | bypassing wrapper for final gate |
| Targeted test | `mix test <path>` | `elixir/` | test path/name | ExUnit output | exit code 0 | deleting/weakening tests |
| Spec check | `mix specs.check` | `elixir/` | none | terminal output | exit code 0 | ignoring public function spec policy |
| PR body lint | `mix pr_body.check --file <file>` | `elixir/` | PR body file | lint output | exit code 0 | hand-validating PR format only |
| Run Symphony | `mise exec -- ./bin/symphony <WORKFLOW.md>` | `elixir/` | workflow path, optional port/log args | runtime logs | server starts/polls as expected | running against wrong workflow path |
| Format/lint | covered by `make all` | `elixir/` | none | terminal output | exit code 0 | skipping before handoff for broad changes |
| Code generation | none currently canonical |  |  |  |  |  |

## Platform Policy

### macOS

- Preferred wrappers: `mise`, `mix`, `make` from `elixir/`.
- Commands to avoid: ad-hoc global dependency installs when project wrapper exists.

### Linux

- Preferred wrappers: same as macOS when toolchain is installed.
- Commands to avoid: running Symphony against the source repo workspace.

### Windows

- Preferred wrappers: not currently documented for this repo.
- Commands to avoid: assuming Unix shell examples work unchanged.
- Shell syntax requirements: document before using Windows as a target.

## Logs and Completion

For each script that writes logs:

- final log path:
- in-progress marker: terminal process still running unless a command documents another marker.
- stale log handling: do not infer current status from old logs.
- success marker: exit code 0 and expected final summary.
- failure marker: nonzero exit or explicit error output.
