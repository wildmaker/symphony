# Template Contract

`.agents/` is the canonical project context system. Tool-specific files are adapters.

## Required base files

Every base template must provide:

- `.agents/instructions.md`
- `.agents/profile.md`
- `.agents/WORKFLOW.md`
- `.agents/Guidelines/Tools.md`
- `.agents/Guidelines/Building.md`
- `.agents/Guidelines/Testing.md`
- `.agents/Guidelines/Debugging.md`
- `.agents/Guidelines/Running.md`
- `.agents/Guidelines/SourceFileManagement.md`
- `.agents/Guidelines/DomainSyntax.md`
- `.agents/KnowledgeBase/Index.md`
- `.agents/KnowledgeBase/KB_TOPIC_TEMPLATE.md`
- `.agents/KnowledgeBase/KB_DESIGN_TOPIC_TEMPLATE.md`
- `.agents/Learning/Learning.md`
- `.agents/TaskLogs/Scrum.md`
- `.agents/TaskLogs/Task.md`
- `.agents/TaskLogs/Planning.md`
- `.agents/TaskLogs/Execution.md`
- `.agents/TaskLogs/Verification.md`
- `.agents/TaskLogs/Investigate.md`
- `.agents/TaskLogs/KnowledgeBase.md`
- `.agents/TaskLogs/Review.md`
- `.agents/prompts/0-scrum.prompt.md`
- `.agents/prompts/1-design.prompt.md`
- `.agents/prompts/2-planning.prompt.md`
- `.agents/prompts/3-summarizing.prompt.md`
- `.agents/prompts/4-execution.prompt.md`
- `.agents/prompts/5-verifying.prompt.md`
- `.agents/prompts/investigate.prompt.md`
- `.agents/prompts/review.prompt.md`
- `.agents/prompts/kb.prompt.md`
- `.agents/prompts/refine.prompt.md`
- `.agents/prompts/code.prompt.md`
- `.agents/prompts/ask.prompt.md`

## Overlay rules

Apply overlays after base templates.

- Overlay files may replace placeholder sections in base files.
- Overlay files may add new files.
- Overlay files should not remove base files.
- `.agents/WORKFLOW.md` must remain derived from base workflow phases.
- Overlay files should preserve the base document's role: commands may specialize, but evidence, preflight, ownership, and lifecycle sections should remain.

## Quality bar for base templates

Base templates must provide a thinking frame, not blank files.

Each base guideline should answer:

- What is the canonical wrapper or command slot?
- What must happen before running it?
- What output is authoritative?
- How does an agent know the operation is complete?
- What commands or edits should be avoided?

Task logs must include durable markers such as `UPDATES`, `AFFECTED PROJECTS`, `EXECUTION PLAN`, `FIXING ATTEMPTS`, and `FINISHED` / `VERIFIED` markers where relevant.

## Managed block markers

Use these markers when updating existing adapter files:

```md
<!-- repo-context-bootstrap:BEGIN -->
...
<!-- repo-context-bootstrap:END -->
```

Only content inside the block is owned by this skill.
