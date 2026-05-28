# Project Profile

This file is the project-specific map generated from the base template and overlays. Keep it factual and update it when repository structure or commands change.

## Identity

- Project name:
- Project type:
- Primary tech stack:
- Secondary tech stacks:
- Runtime targets:
- Deployment targets:

## Repository Terms

- `REPO_ROOT`:
- `APP_ROOT` / `PACKAGE_ROOT` / `SOLUTION_ROOT`:
- `SOURCE_ROOTS`:
- `TEST_ROOTS`:
- `GENERATED_ROOTS`:
- `VENDORED_ROOTS`:
- `DOCS_ROOTS`:
- `PROJECT_MANIFESTS`:

## Context Map

Read these in order when relevant:

1. `.agents/instructions.md`
2. `.agents/profile.md`
3. `.agents/WORKFLOW.md`
4. `.agents/Guidelines/Tools.md`
5. `.agents/Guidelines/Building.md`
6. `.agents/Guidelines/Testing.md`
7. `.agents/Guidelines/Debugging.md`
8. `.agents/KnowledgeBase/Index.md`
9. `.agents/Learning/Learning.md`

Add project-specific specs, architecture docs, or package READMEs here:

- `<path>`:

## Source Ownership Matrix

| Path | Class | Rule |
| --- | --- | --- |
| `<path>` | Editable | Normal source/docs/tests. |
| `<path>` | Protected | Explain required care or approval. |
| `<path>` | Generated | Explain generator/source of truth. |
| `<path>` | Vendored | Do not edit unless explicitly required. |
| `<path>` | Protected | Project manifests, registries, or workflow files requiring synchronized edits. |
| `.agents/TaskLogs/` | Task-only | Use for durable task state, not general docs. |

## Canonical Commands

Prefer repository wrappers over raw tools. Fill these with exact commands.

| Purpose | Command | Working directory | Authoritative evidence |
| --- | --- | --- | --- |
| Install dependencies |  |  |  |
| Build |  |  |  |
| Test targeted |  |  |  |
| Test full |  |  |  |
| Lint/typecheck |  |  |  |
| Run app/service/CLI |  |  |  |
| Debug |  |  |  |

## Verification Policy

- Small changes:
- Standard changes:
- Broad or risky changes:
- Required evidence before handoff:

## Open Initialization Items

Use this checklist when the bootstrapper cannot infer facts automatically.

- [ ] Fill repository terms.
- [ ] Classify source ownership.
- [ ] Record canonical commands and evidence sources.
- [ ] Identify generated/vendored/protected paths.
- [ ] Link architecture/spec docs.
- [ ] Fill project-specific KnowledgeBase sections.
