---
name: library-typescript-agent-workflow
version: 0.2.0
extends: base-agent-workflow
---

# TypeScript Library Workflow

Use the base lifecycle and state machine from `base-agent-workflow`, specialized for TypeScript libraries.

## Library Context Discovery

- Identify public API surface, package exports, generated declarations, docs examples, and compatibility expectations.
- Read package manager, build, and release guidelines before changing exports.

## State Specialization

```text
Verify
  [TYPECHECK_FAILED] -> FixBuild
  [TEST_FAILED] -> FixBehavior
  [PUBLIC_API_CHANGED] -> VerifyCompatibility
  [PACKAGE_EXPORTS_CHANGED] -> VerifyPackaging
  [PASSED] -> Report
```

## Implement

- Preserve backward compatibility unless explicitly changing it.
- Keep runtime behavior and type-level behavior aligned.
- Avoid expanding public API without tests and docs.
- Keep package exports and generated declarations consistent.

## Verify

- Run typecheck.
- Run targeted tests.
- Validate package exports and declarations when touched.
- Update examples/docs when public behavior changes.
