# Agent Instructions

`.agents/` is the canonical project context system. Root files and tool-specific files should point here instead of duplicating long-lived rules.

## Repository Terms

Instantiate these aliases for each project in `.agents/profile.md` before relying on them:

- `REPO_ROOT`: repository root.
- `APP_ROOT` / `PACKAGE_ROOT` / `SOLUTION_ROOT`: primary application, package, or solution root when different from `REPO_ROOT`.
- `SOURCE_ROOTS`: editable source directories.
- `TEST_ROOTS`: test directories.
- `GENERATED_ROOTS`: generated output directories.
- `VENDORED_ROOTS`: third-party or imported code directories.

Use these names consistently in guidelines, workflow, task logs, and prompts.

## Context Discovery Order

Before editing, read only the layers needed for the task:

1. `AGENTS.md` or other tool adapter that invoked this context.
2. `.agents/instructions.md`.
3. `.agents/profile.md`.
4. `.agents/WORKFLOW.md`.
5. Relevant files in `.agents/Guidelines/`.
6. `.agents/KnowledgeBase/Index.md` and topic files when API, architecture, domain, or integration choices are involved.
7. `.agents/Learning/Learning.md` when the task touches known recurring failure modes.
8. `.agents/TaskLogs/` when resuming or handing off durable task work.

## Prompt File Contract

Files under `.agents/prompts/*.prompt.md` are executable task-phase instructions.

If a user or task document explicitly references a prompt file, read it and follow it as task-scoped guidance under normal instruction precedence. Do not treat prompt files as passive examples when referenced.

## Parallel Editing Guardrail

Before writing to a source file, read it again if there is any chance it changed since your last read. Preserve user changes and unrelated local edits.

## Source Ownership

`.agents/profile.md` must classify important paths as one of:

- `Editable`: normal source, tests, docs, and config the agent may change.
- `Protected`: files requiring explicit instruction or extra care.
- `Generated`: generated outputs; change the generator or source input where possible.
- `Vendored`: third-party/imported code; do not edit unless explicitly required.
- `Task-only`: scratch/task logs whose content is specific to an active task.

## Tool Adapters

Tool-specific adapters such as `AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/BUGBOT.md`, and runtime workflow launch files should remain thin. They should route tools to `.agents/` and avoid copying the full canonical guidance.

## Knowledge Hygiene

- Put build/test/debug/run procedures in `.agents/Guidelines/`.
- Put API, architecture, integration, and domain knowledge in `.agents/KnowledgeBase/`.
- Put recurring lessons in `.agents/Learning/`.
- Put current task state in `.agents/TaskLogs/`.
- Keep facts source-anchored and executable.
