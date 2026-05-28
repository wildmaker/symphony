---
name: library-cpp-agent-workflow
version: 0.1.0
extends: base-agent-workflow
---

# C++ Library Workflow

Use the base lifecycle and state machine from `base-agent-workflow`, specialized for C++ repositories with solution/project files, generated build files, and platform-specific tooling.

## C++ Context Discovery

- Identify solution/package roots from `Project.md`, `*.sln`, `*.slnx`, `*.vcxproj`, `CMakeLists.txt`, or project-specific build manifests.
- Read `.agents/Guidelines/Tools.md`, `Building.md`, `Testing.md`, `Debugging.md`, `SourceFileManagement.md`, and `DomainSyntax.md`.
- Identify generated, vendored/imported, and release-output directories before editing.

## State Specialization

```text
Build
  [PROJECT_MANIFEST_OUT_OF_DATE] -> FixSourceRegistry
  [COMPILE_FAILED] -> FixBuild
  [PASSED] -> Verify
Verify
  [UNIT_TEST_FAILED] -> FixBehavior
  [GENERATED_CODE_NEEDED] -> RunCodeGeneration
  [PASSED] -> Report
```

## Implement

- Keep platform-specific code in narrow files or modules.
- Update project manifests, filters, package exports, or generated indexes when adding/removing/renaming files.
- Prefer existing utility types and project abstractions over introducing standard-library or third-party alternatives that conflict with local conventions.
- Do not edit imported/vendor or release/generated files unless explicitly required.

## Verify

- Build the affected solution/package first.
- Run targeted tests, then broader suites when shared APIs or core behavior changed.
- Confirm newly added test files are included in project manifests and actually executed.
- Use debugger/instrumentation only after a reproducible signal exists.
