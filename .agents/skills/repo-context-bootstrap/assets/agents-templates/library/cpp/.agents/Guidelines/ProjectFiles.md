# C++ Project Files

Use this when the repository has solution/project/manifest files in addition to physical source files.

## Registries to Check

- Solution files: `*.sln`, `*.slnx`
- Project files: `*.vcxproj`, `*.vcxitems`, `CMakeLists.txt`, package manifests, or local equivalents
- IDE/filter files: `*.filters` or local equivalents
- Generated build files: makefiles, build.ninja, generated project files

## Solution-Style Initialization Checklist

When bootstrapping a solution-style C++ repo, fill these fields before the agent attempts edits:

- Solution root:
- Primary solution file:
- Main library/application project file:
- Main unit-test project file:
- Shared item/property-sheet files:
- Filter/IDE metadata files:
- Generated build files and their generator:
- Imported/vendor directories:
- Release/generated output directories:
- Canonical build wrapper:
- Canonical test wrapper:
- Canonical debugger start/stop/command wrappers:
- Authoritative build/test logs:
- Default configuration/platform:
- Valid alternate configurations/platforms:

## Adding Files

- Add the physical source/header/test file.
- Add it to every required project/manifest file.
- Add it to IDE/filter/group metadata when the repo uses it.
- Add tests to the correct test target and verify they execute.

## Renaming or Removing Files

- Update project manifests and filters.
- Search for stale includes/imports/references.
- Regenerate build files only through the documented generator.
- Do not edit generated build outputs directly unless the repo documents that as canonical.
