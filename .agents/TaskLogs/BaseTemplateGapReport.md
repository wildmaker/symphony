# Base Template Gap Report

# Scope

Assess whether `repo-context-bootstrap` base templates absorbed transferable structure from `.agents/Imported/GacUI/.github/` well enough for a consumer agent to initialize a GacUI-like repository without reading the imported source.

# Extraction Coverage

Subagents inspected these imported areas:

- `Guidelines/`: build/test/debug/run/source-file-management structure.
- `KnowledgeBase/`: decision-oriented KB taxonomy, API selection, design explanation schemas.
- `Learning/`: `Orders` + `Refinements` learning memory pattern.
- `TaskLogs/` and `prompts/`: staged task lifecycle with durable markers.
- `copilot-instructions.md`, `Agent/`, `Scripts/`, `Experiment/`: top-level instruction design, wrapper/tool registry, workflow/state-machine ideas.

# Template Improvements Made

- Expanded `base/.agents/instructions.md` with repository terms, context discovery order, prompt-file contract, source ownership, and adapter policy.
- Expanded `base/.agents/WORKFLOW.md` from a simple lifecycle into a lifecycle plus state-machine and evidence gates.
- Expanded base guidelines:
  - `Tools.md`
  - `Building.md`
  - `Testing.md`
  - `Debugging.md`
  - `Running.md`
  - `SourceFileManagement.md`
  - `DomainSyntax.md`
- Expanded KnowledgeBase templates:
  - `KnowledgeBase/Index.md`
  - `KB_TOPIC_TEMPLATE.md`
  - `KB_DESIGN_TOPIC_TEMPLATE.md`
- Expanded Learning into:
  - `Orders`
  - `Refinements`
  - `Candidates`
  - scoring and retirement policy
- Expanded TaskLogs and prompts into a staged lifecycle:
  - Scrum
  - Design/Task
  - Planning
  - Summarizing
  - Execution
  - Verification
  - Investigate
  - Review
  - KnowledgeBase
  - Learning refinement
- Added `library/cpp` overlay for solution-style C++ repositories.
- Updated render script to:
  - auto-detect project type/tech stack;
  - apply `library/cpp` overlay;
  - generate adapters (`AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/BUGBOT.md`);
  - render detected facts into `.agents/profile.md`;
  - de-duplicate case-insensitive path matches;
  - record project manifests in profile.

# Consumer Simulation

Test directory:

- `/tmp/repo-context-bootstrap-consumer2.pOM2jF/fake-gacui-like-repo`

The consumer subagent was instructed to work only inside the `/tmp` test directory and not read `.agents/Imported/GacUI/.github/`.

Fake repo signals:

- `FakeGacUI.slnx`
- `Project.md`
- `Source/FakeCore.vcxproj`
- `Source/FakeCore.vcxproj.filters`
- `Test/FakeUnitTest.vcxproj`
- `Test/FakeUnitTest.vcxproj.filters`
- `Import/`
- `Release/`

Consumer result:

- Detection selected `project_type=library`, `tech_stack=cpp`.
- Generated `.agents/` tree had no missing required files.
- Generated adapters existed and pointed to `.agents/`.
- C++ overlay gave sufficient solution-style bootstrap safety guidance.

Post-consumer local fix:

- Fixed duplicate `Test/test` profile entries caused by case-insensitive filesystem globbing.
- Added `PROJECT_MANIFESTS` to generated profiles.
- Verified profile now lists:
  - `TEST_ROOTS`: `Test`
  - `PROJECT_MANIFESTS`: `FakeGacUI.slnx`, `Project.md`, `Source/FakeCore.vcxproj`, `Source/FakeCore.vcxproj.filters`, `Test/FakeUnitTest.vcxproj`, `Test/FakeUnitTest.vcxproj.filters`

# Remaining Gap Against GacUI

The result is now structurally close to GacUI's practice, but not equivalent in depth.

Remaining acceptable gaps:

- The bootstrapper cannot invent canonical build/test/debug commands when the target repo does not document wrappers. It leaves those as `TBD`.
- The C++ overlay gives a solution-style checklist, but does not parse project files deeply enough to infer every target/configuration/platform.
- The base template provides KB schemas, but does not auto-generate full domain KB pages like GacUI's `KB_*.md` corpus.
- The base workflow has state-machine support, but it is not yet a full mechanically executed workflow language.
- Spec/snapshot directories are not part of the base contract yet; they can be added later for spec-heavy overlays.

Gap judgment:

- Before this pass: base templates were placeholders and did not function as templates.
- After this pass: base templates now provide a reusable engineering frame, document outlines, evidence gates, lifecycle markers, and C++ solution-style overlay sufficient for a consumer agent to reason without copying GacUI.

# Suggested Next Improvements

- Add a wrapper-discovery pass that scans `scripts/`, `Makefile`, package scripts, `mix.exs`, `package.json`, `Project.md`, and CI workflows to prefill `Guidelines/Tools.md`.
- Add optional `Spec/` and `Snapshot/` base directories for projects that want spec-driven development.
- Add deeper C++ project-file parsing for `.slnx`, `.vcxproj`, and `.filters`.
- Add more overlays: `web-app/vite-react`, `backend-service/fastapi`, `mobile-app/ios-swift`, `library/rust`.
