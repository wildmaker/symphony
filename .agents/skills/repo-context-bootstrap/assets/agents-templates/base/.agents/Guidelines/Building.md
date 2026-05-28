# Building

This document must tell agents how to build this repository without guessing.

## Canonical Build Command

- Use:
- Working directory:
- Do not use directly:
- Required setup before first build:

Prefer repository-approved wrappers over raw compilers or low-level build tools. If direct commands are allowed, say when and why.

## Preflight

Before building:

- Stop or release processes that can affect builds, such as debuggers, dev servers, watchers, containers, emulators, databases, or lock-holding tasks.
- Confirm the correct root directory.
- Confirm dependencies and generated sources are current when the build depends on them.

## Target Configuration

- Default target/profile/platform:
- Valid alternatives:
- When to override defaults:
- Required paired options:

Examples: debug/release, platform, browser, device, package target, service profile, database environment.

## Reading Build Results

Define the authoritative build result source:

- Terminal output:
- Log file:
- CI status:
- Generated report:

If the build writes partial logs while running, document the in-progress marker and wait for completion before interpreting results.

Success pattern:

- Exit code:
- Final log line or summary:
- Expected artifacts:

Failure triage:

- Read the first actionable compiler/tool error, not only summary noise.
- Distinguish errors caused by the current change from pre-existing warnings.
- Do not delete build logs unless this guideline explicitly says they are disposable.

## Artifacts

- Build outputs:
- Generated files:
- Files that should be committed:
- Files that should stay local:
