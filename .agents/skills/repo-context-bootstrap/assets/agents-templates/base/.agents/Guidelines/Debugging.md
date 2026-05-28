# Debugging

Use debugging when logs, tests, and code inspection do not expose enough state.

## When to Debug

Debug when:

- the failure is reproducible but the cause is hidden;
- the process crashes, hangs, races, or exits silently;
- state differs between expected and observed behavior;
- instrumentation would be less reliable than inspecting runtime state.

Prefer simpler evidence first: failing tests, logs, traces, screenshots, dumps, metrics, or minimal reproduction commands.

## Start

- Canonical start command:
- Working directory:
- Start mode: foreground / background / attached / remote
- Initial state: paused / running / waiting for attach
- Required target executable/service/test:
- Required arguments/environment:

If the debugger or inspector blocks the terminal, document how to launch it without blocking future commands.

## Stop

- Canonical stop command:
- Safe cleanup command:
- Do not stop via:

Always document unsafe stop methods, such as direct process kills, debugger quit commands, or shortcuts that leave locks, ports, devices, or build artifacts in a bad state.

## Sending Commands / Inspecting State

- Canonical command channel:
- State persistence rules:
- Recommended commands:
- Commands to avoid:

State persistence examples: selected stack frame, breakpoints, environment, process state, session variables, loaded symbols, browser page state, device/emulator state.

## Evidence to Capture

Capture enough to make the conclusion reviewable:

- reproduction command or steps;
- breakpoint or inspection point;
- stack trace or call path;
- key variables/state;
- logs or trace identifiers;
- final verification after the fix.

## Cleanup

- Remove temporary logging, breakpoints, debug-only code, and local instrumentation unless the task intentionally adds them.
- Stop long-running debug sessions before build/test.
