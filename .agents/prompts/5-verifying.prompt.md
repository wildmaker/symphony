# Verifying

## Goal

Prove the implemented task works and does not regress relevant behavior.

## Process

1. Compare source state against the execution plan; treat unexpected differences as possible user edits.
2. Build/typecheck first when required by `.agents/Guidelines/Building.md`.
3. Run targeted tests, then broader tests when risk warrants.
4. Confirm newly added or changed tests actually executed.
5. Fix failures without deleting tests.
6. Record evidence in `.agents/TaskLogs/Verification.md` when durable evidence is needed.
7. Append or preserve `# !!!VERIFIED!!!` only after checks pass.
