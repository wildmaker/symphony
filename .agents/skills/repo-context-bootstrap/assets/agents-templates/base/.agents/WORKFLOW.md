---
name: base-agent-workflow
version: 0.2.0
---

# Base Agent Workflow

This workflow is the base execution contract. Project-type overlays may specialize phases and state transitions, but should preserve the lifecycle and evidence gates.

## Lifecycle

1. Understand
2. Plan
3. Implement
4. Verify
5. Report
6. Learn

## State Machine

Overlays may refine this state machine using the same shape.

```text
Entry
  -> Understand
Understand
  [READY] -> Plan
  [UNKNOWN_ROOT_CAUSE] -> Investigate
Plan
  [APPROVED_OR_CLEAR] -> Implement
  [INSUFFICIENT_REQUIREMENTS] -> ClarifyOrRecordAssumption
Implement
  [BUILD_OR_TYPECHECK_NEEDED] -> Build
  [NO_BUILD_NEEDED] -> Verify
Build
  [PASSED] -> Verify
  [FAILED] -> FixBuild
FixBuild
  [PATCHED] -> Build
Verify
  [PASSED] -> Report
  [FAILED] -> FixBehavior
FixBehavior
  [PATCHED] -> Build
Report
  [DURABLE_LESSON_FOUND] -> Learn
  [NO_LESSON] -> Finished
Learn
  [RECORDED] -> Finished
```

## Phase 1: Understand

- Read `.agents/profile.md`.
- Read relevant guidelines and knowledge-base entries.
- Identify `SOURCE_ROOTS`, `TEST_ROOTS`, generated/vendored/protected paths, and canonical commands.
- Capture acceptance criteria and expected validation evidence.
- If a referenced `.agents/prompts/*.prompt.md` file exists, read and follow it for the current phase.

## Phase 2: Plan

- Keep the plan small, ordered, and verifiable.
- Prefer existing project APIs, wrappers, and patterns.
- Identify files likely to change and registries/manifests that must be updated.
- Identify exact checks that prove completion.
- For unclear root-cause bugs, use an investigation path before committing to a fix.

## Phase 3: Implement

- Make narrowly scoped edits.
- Do not rewrite unrelated code.
- Do not edit generated/vendored/protected paths unless the task explicitly requires it.
- Mark durable task steps as done when using `.agents/TaskLogs/Execution.md`.
- For each build/test failure, record cause, change, and expected proof in fixing attempts when the task is long-running.

## Phase 4: Verify

- Use raw tool output, canonical logs, reports, or CI status as authoritative evidence.
- Wait for completion markers before interpreting logs or reports.
- Run targeted checks first, then broader checks when risk warrants it.
- Confirm newly added or changed tests actually executed.
- If verification fails, fix and repeat.

## Phase 5: Report

- Summarize changed files by responsibility.
- Summarize verification evidence.
- Call out remaining risks and untested areas.
- Do not claim completion without evidence.

## Phase 6: Learn

Add a lesson to `.agents/Learning/Learning.md` only when it is actionable, likely to recur, and has a clear trigger/check. Keep transient task notes in `.agents/TaskLogs/`.
