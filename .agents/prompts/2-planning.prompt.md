# Planning

## Goal

Create `.agents/TaskLogs/Planning.md` from `.agents/TaskLogs/Task.md`.

## Write Scope

Only update `.agents/TaskLogs/Planning.md` unless the user explicitly asks for implementation.

## Required Sections

- `# !!!PLANNING!!!`
- `# UPDATES`
- `# AFFECTED PROJECTS`
- `# EXECUTION PLAN`
- `# !!!FINISHED!!!`

## Process

1. Read `.agents/TaskLogs/Task.md` and relevant project guidance.
2. Preserve newer user updates in `# UPDATES`.
3. Convert requirements into ordered implementation steps.
4. For each step, include target files/modules, change intent, risks, and verification.
5. Avoid duplicating existing coverage; add tests only where behavior is not already protected.
6. End with `# !!!FINISHED!!!`.
