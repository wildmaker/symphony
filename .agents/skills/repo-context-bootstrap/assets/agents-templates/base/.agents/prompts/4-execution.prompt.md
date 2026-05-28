# Execution

## Goal

Apply `.agents/TaskLogs/Execution.md` or the approved plan with minimal, reviewable edits.

## Process

1. Read the execution plan and relevant project guidance.
2. Reread each target file before editing when parallel edits are possible.
3. Apply steps in order.
4. Mark completed steps `[DONE]`.
5. Build or typecheck according to `# AFFECTED PROJECTS` when required.
6. For each failure, add a fixing attempt explaining cause, change, and expected proof.
7. Do not delete user changes or unrelated files.
8. Leave verification evidence for the verifying phase.

## Guardrails

- Do not edit generated/vendored/protected files unless explicitly required.
- Use repository wrappers from `.agents/Guidelines/Tools.md`.
- Preserve tests; do not weaken them to pass.
