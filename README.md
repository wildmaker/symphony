# Symphony (Instant-AI Fork)

This repository is a production-focused fork of
[openai/symphony](https://github.com/openai/symphony). It runs a backlog-driven
agent loop with Linear as the tracker and Codex as the coding agent.

[![Symphony demo video preview](.github/media/symphony-demo-poster.jpg)](.github/media/symphony-demo.mp4)

## What this repo contains

- `elixir/`: core Symphony runtime (Elixir/OTP + optional Phoenix dashboard)
- `SPEC.md`: high-level product and architecture specification
- `scripts/cursor-symphony-bridge`: Cursor CLI protocol bridge
- `.agents/` and `.codex/`: local agent workflows and reusable skills

## Highlights in this fork

- Linear GraphQL usage optimized for low token overhead
- Git/PR-centric workflow defaults that work with real repositories
- Built-in conventions for workpad updates, PR feedback sweeps, and merge flow
- Additional automation skills for setup, push/pull/land, and issue handling

## Prerequisites

- Git
- [mise](https://mise.jdx.dev/) for Elixir/Erlang toolchain management
- Linear personal API key (`LINEAR_API_KEY`) for tracker integration
- `codex` CLI available in your shell environment

## Quick start (local)

```bash
git clone https://github.com/wildmaker/symphony
cd symphony/elixir
mise trust
mise install
mise exec -- mix setup
mise exec -- mix build
mise exec -- ./bin/symphony ./WORKFLOW.md
```

## Configure your workflow

1. Copy `elixir/WORKFLOW.md` to your target repository.
2. Set the Linear project slug in YAML frontmatter (`tracker.project_slug`).
3. Configure `hooks.after_create` to clone and bootstrap your target repo.
4. Export `LINEAR_API_KEY` before launching Symphony.
5. Ensure Linear workflow contains the states used by this flow:
   `Todo`, `In Progress`, `Human Review`, `Rework`, `Merging`, `Done`.

## Run tests

```bash
cd elixir
make all
```

Optional live end-to-end test (creates disposable Linear resources and launches a
real Codex app-server turn):

```bash
cd elixir
export LINEAR_API_KEY=...
make e2e
```

## Observability dashboard

Start Symphony with a web dashboard:

```bash
cd elixir
mise exec -- ./bin/symphony ./WORKFLOW.md --port 4000
```

Then open `http://localhost:4000`.

## Security notes

- Never commit `.env` files or raw tokens.
- Prefer environment variables for all secrets (`LINEAR_API_KEY` and other
  service credentials).
- Use disposable test projects/issues when running `make e2e`.

## Documentation

- Runtime details: [elixir/README.md](elixir/README.md)
- Workflow contract example: [elixir/WORKFLOW.md](elixir/WORKFLOW.md)
- Logging details: [elixir/docs/logging.md](elixir/docs/logging.md)
- Token accounting notes: [elixir/docs/token_accounting.md](elixir/docs/token_accounting.md)

## License

[Apache License 2.0](LICENSE)
