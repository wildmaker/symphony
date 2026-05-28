#!/usr/bin/env python3
import argparse
import json
import shutil
from pathlib import Path


def exists(root: Path, pattern: str) -> bool:
    return any(root.glob(pattern))


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError:
        return ""


def detect(root: Path) -> dict:
    facts = {
        "repo": str(root),
        "project_type": "unknown",
        "tech_stack": "unknown",
        "signals": [],
    }

    package_json = root / "package.json"
    mix_exs = root / "mix.exs"
    nested_mix = list(root.glob("*/mix.exs"))

    if package_json.exists():
        facts["signals"].append("package.json")
        if exists(root, "next.config.*"):
            facts.update(project_type="web-app", tech_stack="nextjs")
            facts["signals"].append("next.config.*")
        elif exists(root, "vite.config.*"):
            facts.update(project_type="web-app", tech_stack="vite-react")
            facts["signals"].append("vite.config.*")
        elif (root / "tsconfig.json").exists():
            facts.update(project_type="library", tech_stack="typescript")
            facts["signals"].append("tsconfig.json")

    if mix_exs.exists() or nested_mix:
        candidate = mix_exs if mix_exs.exists() else nested_mix[0]
        facts["signals"].append(str(candidate.relative_to(root)))
        mix_text = read_text(candidate)
        if "phoenix" in mix_text.lower():
            facts.update(project_type="backend-service", tech_stack="phoenix")
            facts["signals"].append("phoenix dependency")
        else:
            facts.update(project_type="backend-service", tech_stack="elixir")

    if (root / "Cargo.toml").exists():
        facts["signals"].append("Cargo.toml")
        if (root / "src/main.rs").exists():
            facts.update(project_type="cli", tech_stack="rust")
        elif (root / "src/lib.rs").exists():
            facts.update(project_type="library", tech_stack="rust")

    if exists(root, "*.sln") or exists(root, "*.slnx") or exists(root, "**/*.vcxproj") or (root / "Project.md").exists():
        facts.update(project_type="library", tech_stack="cpp")
        if exists(root, "*.sln"):
            facts["signals"].append("*.sln")
        if exists(root, "*.slnx"):
            facts["signals"].append("*.slnx")
        if exists(root, "**/*.vcxproj"):
            facts["signals"].append("*.vcxproj")
        if (root / "Project.md").exists():
            facts["signals"].append("Project.md")

    if exists(root, "*.xcodeproj") or exists(root, "*.xcworkspace") or (root / "Package.swift").exists():
        facts.update(project_type="mobile-app", tech_stack="ios-swift")
        facts["signals"].append("Apple project files")

    return facts


def copy_tree(src: Path, dst: Path, overwrite: bool, created: set[Path]) -> None:
    if not src.exists():
        return
    for path in src.rglob("*"):
        rel = path.relative_to(src)
        target = dst / rel
        if path.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        if target.exists() and not overwrite and target not in created:
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
        created.add(target)


def relative_paths(root: Path, patterns: list[str]) -> list[str]:
    paths: list[str] = []
    root_resolved = root.resolve()
    for pattern in patterns:
        for path in root.glob(pattern):
            if not path.exists():
                continue
            try:
                rel = path.resolve().relative_to(root_resolved)
            except ValueError:
                rel = path.relative_to(root)
            paths.append(str(rel))
    return sorted(set(paths))


def render_profile(repo: Path, facts: dict, overwrite: bool, created: set[Path]) -> None:
    profile = repo / ".agents" / "profile.md"
    if profile.exists() and not overwrite and profile not in created:
        return

    source_roots = relative_paths(repo, ["Source", "src", "lib", "app", "elixir/lib"])
    test_roots = relative_paths(repo, ["Test", "test", "tests", "elixir/test"])
    generated_roots = relative_paths(repo, ["Release", "dist", "build", "_build"])
    vendored_roots = relative_paths(repo, ["Import", "vendor", "third_party", "deps"])
    docs_roots = relative_paths(repo, ["docs", "README.md", "SPEC.md", "Project.md"])
    solution_roots = relative_paths(repo, ["*.sln", "*.slnx", "Project.md", "mix.exs", "package.json", "Cargo.toml"])
    project_manifests = relative_paths(repo, ["*.sln", "*.slnx", "**/*.vcxproj", "**/*.vcxitems", "**/*.filters", "CMakeLists.txt", "Project.md", "mix.exs", "package.json", "Cargo.toml"])

    def fmt(items: list[str]) -> str:
        return ", ".join(f"`{item}`" for item in items) if items else "TBD"

    content = f"""# Project Profile

This file is generated from repository signals. Keep it factual and update it when repository structure or commands change.

## Identity

- Project name: {repo.name}
- Project type: {facts.get("project_type", "unknown")}
- Primary tech stack: {facts.get("tech_stack", "unknown")}
- Detection signals: {", ".join(facts.get("signals", [])) or "none"}
- Runtime targets: TBD
- Deployment targets: TBD

## Repository Terms

- `REPO_ROOT`: `{repo}`
- `APP_ROOT` / `PACKAGE_ROOT` / `SOLUTION_ROOT`: {fmt(solution_roots)}
- `SOURCE_ROOTS`: {fmt(source_roots)}
- `TEST_ROOTS`: {fmt(test_roots)}
- `GENERATED_ROOTS`: {fmt(generated_roots)}
- `VENDORED_ROOTS`: {fmt(vendored_roots)}
- `DOCS_ROOTS`: {fmt(docs_roots)}
- `PROJECT_MANIFESTS`: {fmt(project_manifests)}

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

## Source Ownership Matrix

| Path | Class | Rule |
| --- | --- | --- |
| {fmt(source_roots)} | Editable | Normal source. Follow local patterns and update registries/manifests. |
| {fmt(test_roots)} | Editable | Tests and fixtures. Confirm added tests actually execute. |
| {fmt(generated_roots)} | Generated | Prefer changing source inputs or generators. |
| {fmt(vendored_roots)} | Vendored | Do not edit unless explicitly required. |
| {fmt(project_manifests)} | Protected | Update when file registries/build membership change. |
| `.agents/TaskLogs/` | Task-only | Use for durable task state, not general docs. |

## Canonical Commands

Prefer repository wrappers over raw tools. Fill unknown commands before relying on them.

| Purpose | Command | Working directory | Authoritative evidence |
| --- | --- | --- | --- |
| Install dependencies | TBD | TBD | TBD |
| Build | TBD | TBD | TBD |
| Test targeted | TBD | TBD | TBD |
| Test full | TBD | TBD | TBD |
| Lint/typecheck | TBD | TBD | TBD |
| Run app/service/CLI | TBD | TBD | TBD |
| Debug | TBD | TBD | TBD |

## Verification Policy

- Small changes: targeted checks near the edit.
- Standard changes: targeted checks plus relevant build/test wrapper.
- Broad or risky changes: full project gate where available.
- Required evidence before handoff: command output read, expected files present, and untested risk named explicitly.

## Open Initialization Items

- [ ] Fill unknown canonical commands.
- [ ] Confirm generated/vendored/protected paths.
- [ ] Link architecture/spec docs.
- [ ] Fill project-specific KnowledgeBase sections.
"""

    profile.parent.mkdir(parents=True, exist_ok=True)
    profile.write_text(content, encoding="utf-8")
    created.add(profile)


def upsert_managed_block(path: Path, content: str) -> None:
    begin = "<!-- repo-context-bootstrap:BEGIN -->"
    end = "<!-- repo-context-bootstrap:END -->"
    block = f"{begin}\n{content.strip()}\n{end}\n"
    if path.exists():
        old = path.read_text(encoding="utf-8")
        if begin in old and end in old:
            prefix = old.split(begin, 1)[0]
            suffix = old.split(end, 1)[1]
            path.write_text(prefix + block + suffix.lstrip("\n"), encoding="utf-8")
            return
        path.write_text(old.rstrip() + "\n\n" + block, encoding="utf-8")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    title = "# Agent Instructions\n\n" if path.name == "AGENTS.md" else f"# {path.stem.replace('-', ' ').title()}\n\n"
    path.write_text(title + block, encoding="utf-8")


def create_adapters(repo: Path) -> None:
    adapter = """Canonical agent context lives in `.agents/`.

Start with:

- `.agents/instructions.md`
- `.agents/profile.md`
- `.agents/WORKFLOW.md`

Use tool-specific files only as adapters. Do not duplicate long-lived project rules across root, `.github`, and `.cursor`."""
    upsert_managed_block(repo / "AGENTS.md", adapter)

    copilot = """Canonical agent guidance lives in `.agents/`.

Before changing files, read:

- `AGENTS.md`
- `.agents/instructions.md`
- `.agents/profile.md`
- `.agents/WORKFLOW.md`
- relevant files under `.agents/Guidelines/` and `.agents/KnowledgeBase/`."""
    upsert_managed_block(repo / ".github" / "copilot-instructions.md", copilot)

    bugbot = """Canonical review context lives in `.agents/`.

Reviewers should consult:

- `.agents/instructions.md`
- `.agents/profile.md`
- `.agents/WORKFLOW.md`
- `.agents/Guidelines/`
- `.agents/KnowledgeBase/`

Focus review on behavior regressions, workflow safety, source ownership, and validation gaps."""
    upsert_managed_block(repo / ".cursor" / "BUGBOT.md", bugbot)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("repo")
    parser.add_argument("--project-type", default="")
    parser.add_argument("--tech-stack", default="")
    parser.add_argument("--overwrite", action="store_true")
    parser.add_argument("--no-adapters", action="store_true")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    templates = Path(__file__).resolve().parents[1] / "assets" / "agents-templates"
    facts = detect(repo)
    project_type = args.project_type or facts["project_type"]
    tech_stack = args.tech_stack or facts["tech_stack"]
    facts["project_type"] = project_type
    facts["tech_stack"] = tech_stack

    created: set[Path] = set()
    copy_tree(templates / "base", repo, args.overwrite, created)
    if project_type and tech_stack:
        copy_tree(templates / project_type / tech_stack, repo, args.overwrite, created)
    render_profile(repo, facts, args.overwrite, created)
    if not args.no_adapters:
        create_adapters(repo)

    print(json.dumps(facts, indent=2, sort_keys=True))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
