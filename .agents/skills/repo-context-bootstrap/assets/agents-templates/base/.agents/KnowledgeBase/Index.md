# Knowledge Base

Use this folder for stable project knowledge that helps agents choose existing APIs, respect architecture boundaries, and avoid re-discovering project rules.

Knowledge here should be durable, source-anchored, and decision-oriented. Prefer short index guidance with links to focused `KB_*.md` topic pages.

## Global Guidance

Record project-wide conventions that apply across multiple modules:

- preferred existing utilities, data types, and abstractions;
- cross-cutting error-handling or logging rules;
- dependency and integration constraints;
- testing hooks, determinism rules, or lifecycle constraints;
- naming, file organization, or registration conventions.

For lessons learned during implementation, prefer [`../Learning/Learning.md`](../Learning/Learning.md) unless the lesson has become stable reference knowledge.

## Subsystem Template

Create one section per major subsystem, package, bounded context, or integration.

```md
## [Subsystem Name]

Source locations:
- `path/to/source`
- `path/to/tests`

External references:
- [Official or upstream docs](https://example.com)

Purpose:
[What this subsystem owns.]

Use this when:
- [Task or scenario.]
- [Extension/debugging scenario.]

### Choosing APIs

#### [Task-Oriented Topic]

[One-sentence summary.]

- Use `[ExistingApiOrPattern]` when [condition].
- Use `[AlternativeApiOrPattern]` when [condition].
- Avoid `[AntiPattern]` because [reason].
- Check `path/to/source` for canonical examples.

[API Explanation](./KB_[Subsystem]_[Topic].md)

### Design Explanation

#### [Architecture or Extension Pattern]

- [Problem solved.]
- [Main components and ownership boundaries.]
- [Lifecycle or data/control flow.]
- [Extension points and constraints.]
- [Testing or verification hooks.]

[Design Explanation](./KB_[Subsystem]_Design_[Pattern].md)
```

## Topic File Naming

Use predictable names so agents can find knowledge quickly:

- `KB_[Subsystem]_[Topic].md` for API selection and usage guidance.
- `KB_[Subsystem]_Design_[Pattern].md` for architecture, lifecycle, and extension patterns.
- `KB_[Subsystem]_Testing_[Topic].md` for test harnesses, fixtures, and verification patterns.
- `KB_[Integration]_[Topic].md` for external services or protocol integrations.

## Per-Topic Doc Schema

Each `KB_*.md` should usually include:

```md
# [Topic Name]

## Overview
[What problem this topic solves and when to use it.]

## When To Use
- Use this when [condition].
- Prefer this over [alternative] when [reason].
- Do not use this for [out-of-scope case].

## Core APIs / Components
### [API or Component]
- Purpose:
- Source location:
- Key methods / options:
- Ownership or lifecycle rules:
- Error behavior:
- Concurrency or runtime notes, if relevant:

## Selection Guide
- If [condition], use [API/pattern].
- If [condition], use [alternative].
- If [condition], avoid [unsafe pattern].

## Standard Pattern
[Minimal recipe or canonical example.]

## Extension / Integration Points
- Required files:
- Registration/configuration points:
- Dependency direction:
- Compatibility constraints:

## Edge Cases and Pitfalls
- [Pitfall] - [prevention.]
- [Lifecycle/platform/runtime hazard] - [handling.]

## Testing Guidance
- Happy-path verification:
- Failure/edge verification:
- Mocks, fixtures, or deterministic setup:

## Related Knowledge
- [Related topic](./KB_Subsystem_OtherTopic.md)
- Source examples: `path/to/example`
```

## Design Doc Schema

Architecture and design topic files should usually include:

```md
# [Design / Architecture Topic]

## Scope and Purpose
## Components and Responsibilities
## Data / Control Flow
## Lifecycle
## Ownership Boundaries
## Extension Points
## Invariants and Constraints
## Failure Modes
## Testing Strategy
## Common Pitfalls
## Implementation Checklist
## Related Knowledge
```

## Maintenance Rules

- Keep the index concise; move detailed guidance into topic files.
- Anchor claims to source files, tests, specs, or official docs when practical.
- Write guidance as decisions: "Use X when Y," not just "X exists."
- Capture constraints and pitfalls explicitly, especially lifecycle, platform, concurrency, serialization, and compatibility rules.
- Avoid duplicating transient task notes; store those in task logs or learning files.
