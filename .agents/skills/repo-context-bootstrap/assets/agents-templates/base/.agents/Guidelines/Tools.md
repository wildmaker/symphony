# Tools and Scripts

Use this registry to prevent agents from guessing commands.

## Policy

- Prefer repository-provided wrappers over direct tool invocation.
- Use direct low-level tools only when this registry allows it or when no wrapper exists.
- Record authoritative logs and completion markers for wrappers.
- Document platform-specific command differences.

## Tool Registry

| Purpose | Preferred command/script | Working directory | Parameters | Output/logs | Completion marker | Forbidden direct commands |
| --- | --- | --- | --- | --- | --- | --- |
| Build |  |  |  |  |  |  |
| Test |  |  |  |  |  |  |
| Run |  |  |  |  |  |  |
| Debug start |  |  |  |  |  |  |
| Debug command |  |  |  |  |  |  |
| Debug stop |  |  |  |  |  |  |
| Format/lint |  |  |  |  |  |  |
| Code generation |  |  |  |  |  |  |

## Platform Policy

### macOS

- Preferred wrappers:
- Commands to avoid:

### Linux

- Preferred wrappers:
- Commands to avoid:

### Windows

- Preferred wrappers:
- Commands to avoid:
- Shell syntax requirements:

## Logs and Completion

For each script that writes logs:

- final log path:
- in-progress marker:
- stale log handling:
- success marker:
- failure marker:
