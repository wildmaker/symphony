# Testing

This document must tell agents how to choose, run, and interpret tests.

## Canonical Test Commands

- Targeted test command:
- Full suite command:
- Coverage command:
- Working directory:
- Do not bypass:

Prefer wrappers that set required environment, fixtures, services, browsers, devices, or database state.

## Preflight

- Stop conflicting processes.
- Build first when tests depend on compiled or generated artifacts.
- Prepare databases, fixtures, snapshots, devices, browsers, or services when needed.
- Confirm environment variables and secrets required for tests.

## Test Selection and Filters

- Start with the smallest relevant test target.
- Preserve existing test filters, snapshots, fixtures, and local test config unless the current task requires changing them.
- If expected tests are skipped, document the safe config file or command flag to update.
- Widen to broader suites for shared behavior, public APIs, cross-module changes, migrations, concurrency, security, or UI flows.

## Reading Test Results

Authoritative result source:

- Raw output:
- Log/report file:
- CI status:

In-progress signal:

- Process:
- Sentinel file:
- Log heartbeat:

Success pattern:

- Exit code:
- Passed-count/report marker:
- Required test names:

Confirm newly added or changed tests actually executed. Do not count a skipped or filtered-out test as verification.

## Failure Handling

- Treat test failures as product/code failures until evidence shows the test is wrong.
- Do not delete or weaken tests to make a run pass.
- For each fix attempt in a long-running task, record the failure cause, the change, and why the next run should pass.

## Test Config Files

- Safe-to-edit local test config:
- Never delete or reset:
- Generated snapshots/fixtures policy:
