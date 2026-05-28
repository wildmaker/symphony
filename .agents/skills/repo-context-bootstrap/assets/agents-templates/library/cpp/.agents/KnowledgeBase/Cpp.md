# C++ Knowledge

Record project-specific C++ conventions here.

## Global Guidance

- Preferred language standard:
- Preferred string/collection/error types:
- Header guard style:
- Namespace style:
- Platform abstraction strategy:
- Memory ownership model:

## Choosing APIs

#### Collections and Strings

- Use project-preferred types when local abstractions exist.
- Avoid introducing inconsistent standard-library or third-party types into code that follows project-specific conventions.

#### Error Handling

- Use project-preferred assertion, exception, or result types.
- Document which failures are programming errors, recoverable errors, or user-facing errors.

#### Platform APIs

- Keep OS-specific code narrow and isolated.
- Prefer existing cross-platform abstractions.

## Design Explanation

#### Source Registry and Build Manifest Coupling

- Physical files may need matching project/manifest/filter entries.
- Generated build files may not be source of truth.
- Tests can silently fail to execute if files are not included in the relevant target.
