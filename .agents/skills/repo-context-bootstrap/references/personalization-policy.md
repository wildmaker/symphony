# Personalization Policy

Personalization means selecting useful, project-specific context without flooding the repo.

Prefer facts that are:

- executable: the agent can follow them;
- verifiable: the agent can check them;
- local: grounded in files in the target repo;
- stable: unlikely to change every sprint.

Avoid:

- vague advice;
- duplicated rules across adapters;
- unverified assumptions about commands;
- secrets or private tokens;
- copying an entire external knowledge base into `.agents/`.

Put information where it belongs:

- workflow and phase gates -> `.agents/WORKFLOW.md`
- build/test/debug commands -> `.agents/Guidelines/`
- architecture and API selection -> `.agents/KnowledgeBase/`
- historical lessons -> `.agents/Learning/`
- current task state -> `.agents/TaskLogs/`
