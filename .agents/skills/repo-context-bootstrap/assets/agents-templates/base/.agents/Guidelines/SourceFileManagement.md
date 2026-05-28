# Source File Management

This document must tell agents how to add, rename, remove, and classify files.

## Layout

- Source roots:
- Test roots:
- Fixture roots:
- Documentation roots:
- Generated roots:
- Vendored roots:

Follow existing source, test, fixture, and generated-file locations. Place new files near the feature or behavior they support.

## Adding Files

When adding files, update every registry used by this repo:

- build manifests;
- package exports;
- project files;
- route tables;
- module indexes;
- generated barrels;
- schema lists;
- migrations;
- docs indexes;
- test fixtures;
- IDE/filter/project metadata.

Record project-specific registries here:

- `<registry>`:

## Renaming or Removing Files

- Update all references, manifests, generated indexes, tests, and docs.
- Search for stale references after the move.
- Run the smallest build or test that proves the registry update is correct.

## Generated, Vendored, and Local Files

- Generated files:
- Vendored/imported files:
- Local config files:
- Committed config files:

Do not edit generated or vendored files unless the task explicitly requires it. Prefer changing the generator, source input, or overlay.

## Working Tree Safety

- Preserve user changes.
- Before writing a file, reread it if it may have changed.
- Keep diffs small and reviewable.
- Do not perform destructive cleanup without explicit instruction.
