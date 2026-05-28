---
name: web-app-nextjs-agent-workflow
version: 0.2.0
extends: base-agent-workflow
---

# Next.js Web App Workflow

Use the base lifecycle and state machine from `base-agent-workflow`, specialized for Next.js web applications.

## Next.js Context Discovery

- Identify affected routes, layouts, components, server actions, API routes, middleware, data dependencies, and deployment/runtime mode.
- Read component, design-system, accessibility, and testing guidance before UI edits.
- Check whether the affected code runs on server, client, edge, or build time.

## State Specialization

```text
Verify
  [TYPECHECK_FAILED] -> FixBuild
  [UNIT_OR_COMPONENT_TEST_FAILED] -> FixBehavior
  [UI_CHANGED] -> VisualVerify
  [ROUTE_OR_DATA_CHANGED] -> RuntimeVerify
  [PASSED] -> Report
```

## Implement

- Prefer existing component composition patterns.
- Keep client components narrow and intentional.
- Preserve loading, empty, error, disabled, and long-content states.
- Avoid unnecessary dependencies and global CSS churn.

## Verify

- Run typecheck and lint when available.
- Run targeted unit/component tests.
- For UI changes, run browser verification and capture key viewport evidence.
- Check responsive layout, accessibility basics, text wrapping, and interaction states.
