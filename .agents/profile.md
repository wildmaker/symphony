# Project Profile

This file is the project-specific map for Symphony. Keep it factual and update it when repository structure or commands change.

## Identity

- Project name: Symphony
- Project type: backend-service / agent orchestration platform
- Primary tech stack: Elixir, Phoenix
- Secondary tech stacks: Linear API, GitHub tooling, Codex app-server protocol, Cursor ACP bridge
- Runtime targets: local Symphony runtime polling Linear and launching coding agents
- Deployment targets: local/global CLI-style installation via the Elixir service

## Repository Terms

- `REPO_ROOT`: `/Users/wildmaker/Documents/Projects/symphony`
- `APP_ROOT` / `PACKAGE_ROOT`: `elixir/`
- `SOURCE_ROOTS`: `elixir/lib`, `scripts`, `.agents/skills`
- `TEST_ROOTS`: `elixir/test`
- `GENERATED_ROOTS`: build outputs under Elixir/Mix-managed directories
- `VENDORED_ROOTS`: none currently identified in this repo
- `DOCS_ROOTS`: `README.md`, `SPEC.md`, `docs/`, `elixir/README.md`, `.agents/`

## Context Map

Read these in order when relevant:

1. `.agents/instructions.md`
2. `.agents/profile.md`
3. `.agents/WORKFLOW.md`
4. `elixir/AGENTS.md` for Elixir implementation changes
5. `.agents/Guidelines/Tools.md`
6. `.agents/Guidelines/Building.md`
7. `.agents/Guidelines/Testing.md`
8. `.agents/Guidelines/Debugging.md`
9. `.agents/KnowledgeBase/Index.md`
10. `SPEC.md` for intended runtime behavior
11. `docs/customizing-workflow.md` for workflow authoring behavior

## Source Ownership Matrix

| Path | Class | Rule |
| --- | --- | --- |
| `elixir/lib` | Editable | Main implementation. Follow `elixir/AGENTS.md`; public functions generally need adjacent `@spec`. |
| `elixir/test` | Editable | Test coverage for runtime behavior. Preserve existing coverage and add regression tests for behavior changes. |
| `README.md`, `SPEC.md`, `docs/`, `elixir/README.md` | Editable | Update when behavior/config/setup changes. |
| `elixir/WORKFLOW.md` | Protected | Current Symphony runtime workflow example/config; do not replace casually with `.agents/WORKFLOW.md`. |
| `.agents/Imported/GacUI/` | Vendored/reference | Imported reference material only; do not treat as canonical Symphony guidance. |
| `.agents/skills/repo-context-bootstrap/assets/agents-templates/` | Editable | Canonical template assets for repo-context-bootstrap. |
| `.agents/TaskLogs/` | Task-only | Use for durable task state, not general docs. |

## Canonical Commands

Prefer repository wrappers over raw tools.

| Purpose | Command | Working directory | Authoritative evidence |
| --- | --- | --- | --- |
| Install dependencies | `mise trust && mise exec -- mix deps.get` | `elixir/` | command exit code and Mix output |
| Build/full gate | `make all` | `elixir/` | command exit code; format/lint/coverage/Dialyzer output |
| Test targeted | `mix test <path>` | `elixir/` | ExUnit output |
| Test full | `mix test` | `elixir/` | ExUnit output |
| Spec check | `mix specs.check` | `elixir/` | command exit code and reported missing specs |
| PR body validation | `mix pr_body.check --file /path/to/pr_body.md` | `elixir/` | command exit code and lint output |
| Run service | `mise exec -- ./bin/symphony /path/to/WORKFLOW.md` | `elixir/` | runtime logs, server port, Linear polling behavior |

## Verification Policy

- Small docs/template changes: inspect rendered files and run script syntax checks when scripts changed.
- Elixir implementation changes: run targeted `mix test`, `mix specs.check` when public functions changed, and `make all` when feasible.
- Workflow/config/orchestration changes: run targeted tests plus broader gate; verify docs and examples stay aligned.
- Required evidence before handoff: command outputs read, expected files present, adapters point to `.agents/`, and any untested risk named explicitly.
