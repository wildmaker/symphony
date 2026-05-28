---
name: repo-context-bootstrap
description: Initialize or refresh a repository's canonical `.agents/` context system from a base template plus project-type/tech-stack overlays, then create thin tool adapters such as `AGENTS.md`, `.github/copilot-instructions.md`, and `.cursor/BUGBOT.md`.
version: 0.1.0
---

# repo-context-bootstrap

## What this skill does

Build a durable agent context system for a repository.

It treats `.agents/` as the canonical source of truth and keeps tool-specific files thin:

- `AGENTS.md` points agents to `.agents/`.
- `.github/copilot-instructions.md` points GitHub Copilot to `.agents/`.
- `.cursor/BUGBOT.md` points Cursor/Bugbot to `.agents/`.
- `.agents/WORKFLOW.md` is generated from the base workflow plus a project-type/tech-stack overlay.

The base template is not an empty scaffold. It carries transferable engineering practice:

- root aliases and source ownership rules;
- tool-wrapper and evidence contracts;
- build/test/debug/run document outlines;
- task-log lifecycle files;
- prompt-phase contracts;
- KnowledgeBase and Learning schemas.

## Template model

Templates live under `assets/agents-templates/`:

```text
assets/agents-templates/
├── base/
└── <project-type>/<tech-stack>/
```

Always apply `base/` first, then apply zero or more overlays. The preferred overlay key is two-level:

- `web-app/nextjs`
- `backend-service/phoenix`
- `library/typescript`

Add more overlays as project needs stabilize.

## Inputs

- `repo_path`: target repository path. Defaults to current working directory.
- `project_type`: optional explicit project type.
- `tech_stack`: optional explicit tech stack.
- `overwrite`: optional, default false. When false, existing non-managed files are preserved.

## Steps

1. Detect the repository root.
2. Detect project type and tech stack, unless the user provided explicit values.
3. Apply `assets/agents-templates/base/` into the repository.
4. Apply the matching `assets/agents-templates/<project-type>/<tech-stack>/` overlay when present.
5. Render project facts into `.agents/profile.md`.
6. Create or update thin adapters:
   - `AGENTS.md`
   - `.github/copilot-instructions.md`
   - `.cursor/BUGBOT.md`
7. Verify:
   - `.agents/instructions.md` exists.
   - `.agents/profile.md` exists.
   - `.agents/WORKFLOW.md` exists.
   - `.agents/Guidelines/Tools.md`, `Building.md`, `Testing.md`, `Debugging.md`, `Running.md`, and `SourceFileManagement.md` exist.
   - `.agents/KnowledgeBase/Index.md` exists.
   - `.agents/Learning/Learning.md` exists.
   - numbered phase prompts exist under `.agents/prompts/`.
   - Tool adapters point back to `.agents/`.

## Merge policy

- Do not delete user-authored content outside managed blocks.
- Do not overwrite existing files unless they are generated from this skill or the user asks.
- Prefer controlled blocks for adapters:
  - `repo-context-bootstrap:BEGIN`
  - `repo-context-bootstrap:END`
- Keep `.agents/TaskLogs/` skeletal by default; task-specific content belongs to active work.
- Keep `.agents/Learning/` compact and executable. Avoid vague lessons.
- Preserve base template outlines when adding overlays. Overlays may specialize content but should not collapse required sections back into placeholders.

## Useful bundled scripts

- `scripts/detect_project.py <repo>` prints detected project facts as JSON.
- `scripts/render_agents_template.py <repo> --project-type <type> --tech-stack <stack>` applies base plus overlay templates.

Read `references/template-contract.md` before changing template layout.
