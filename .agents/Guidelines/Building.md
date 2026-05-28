# Building

This document must tell agents how to build this repository without guessing.

## Canonical Build Command

- Use: `make all`
- Working directory: `elixir/`
- Do not use directly: lower-level checks as a substitute for the final full gate when the change affects shared runtime behavior.
- Required setup before first build: `mise trust && mise exec -- mix deps.get` when dependencies are missing.

Prefer repository-approved wrappers over raw compilers or low-level build tools. If direct commands are allowed, say when and why.

## Preflight

Before building:

- Stop or release processes that can affect builds, such as debuggers, dev servers, watchers, containers, emulators, databases, or lock-holding tasks.
- Confirm the correct root directory.
- Confirm dependencies and generated sources are current when the build depends on them.
- For this repo, run build/check commands from `elixir/` unless a command explicitly says otherwise.

## Target Configuration

- Default target/profile/platform: local Elixir/Mix environment from `elixir/mise.toml`.
- Valid alternatives: targeted `mix test`, `mix specs.check`, or `mix pr_body.check` during iteration.
- When to override defaults: use targeted commands while iterating; return to `make all` for broad changes when feasible.
- Required paired options: workflow runtime commands need an explicit workflow file path.

Examples: debug/release, platform, browser, device, package target, service profile, database environment.

## Reading Build Results

Define the authoritative build result source:

- Terminal output: primary local evidence.
- Log file: runtime logs when running Symphony with logs-root.
- CI status: GitHub Actions when available.
- Generated report: coverage/Dialyzer output surfaced by `make all`.

If the build writes partial logs while running, document the in-progress marker and wait for completion before interpreting results.

Success pattern:

- Exit code: 0.
- Final log line or summary: all wrapper checks complete without errors.
- Expected artifacts: no unexpected generated files unless the task changes build outputs.

Failure triage:

- Read the first actionable compiler/tool error, not only summary noise.
- Distinguish errors caused by the current change from pre-existing warnings.
- Do not delete build logs unless this guideline explicitly says they are disposable.

## Artifacts

- Build outputs:
- Generated files:
- Files that should be committed:
- Files that should stay local:
