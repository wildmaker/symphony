#!/usr/bin/env python3
import json
import sys
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


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    print(json.dumps(detect(root), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
