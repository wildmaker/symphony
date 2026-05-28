# Testing

This document must tell agents how to choose, run, and interpret tests.

## Canonical Test Commands

- Targeted test command: `mix test <path>`
- Full suite command: `mix test`
- Coverage/full gate command: `make all`
- Public spec check: `mix specs.check`
- Working directory: `elixir/`
- Do not bypass: `make all` before handoff for broad orchestration/config/workflow behavior when feasible.

Prefer wrappers that set required environment, fixtures, services, browsers, devices, or database state.

## Preflight

- Stop conflicting processes.
- Build first when tests depend on compiled or generated artifacts.
- Prepare databases, fixtures, snapshots, devices, browsers, or services when needed.
- Confirm environment variables and secrets required for tests.
- Most unit tests should not require live Linear/GitHub credentials; identify live/integration requirements explicitly.

## Test Selection and Filters

- Start with the smallest relevant test target.
- Preserve existing test filters, snapshots, fixtures, and local test config unless the current task requires changing them.
- If expected tests are skipped, document the safe config file or command flag to update.
- Widen to broader suites for shared behavior, public APIs, cross-module changes, migrations, concurrency, security, or UI flows.

## Reading Test Results

Authoritative result source:

- Raw output: ExUnit and Mix command output.
- Log/report file: coverage/Dialyzer output surfaced by `make all` when applicable.
- CI status: GitHub Actions checks when available.

In-progress signal:

- Process: running `mix`/`make` command.
- Sentinel file: none currently canonical.
- Log heartbeat: command output.

Success pattern:

- Exit code: 0.
- Passed-count/report marker: ExUnit summary and wrapper success.
- Required test names: any newly added or changed tests relevant to the task.

Confirm newly added or changed tests actually executed. Do not count a skipped or filtered-out test as verification.

## Failure Handling

- Treat test failures as product/code failures until evidence shows the test is wrong.
- Do not delete or weaken tests to make a run pass.
- For each fix attempt in a long-running task, record the failure cause, the change, and why the next run should pass.

## Test Config Files

- Safe-to-edit local test config: document before changing.
- Never delete or reset: existing regression tests without proving they are obsolete.
- Generated snapshots/fixtures policy: update only when behavior intentionally changes and review the diff.
