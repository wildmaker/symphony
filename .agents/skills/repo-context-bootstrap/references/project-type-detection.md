# Project Type Detection

Use explicit user input first. If absent, infer conservatively from files:

- `package.json` + `next.config.*` -> `web-app/nextjs`
- `package.json` + `vite.config.*` -> `web-app/vite-react`
- `mix.exs` + Phoenix dependency -> `backend-service/phoenix`
- `mix.exs` without Phoenix -> `backend-service/elixir`
- `Cargo.toml` + `src/main.rs` -> `cli/rust`
- `Cargo.toml` + `src/lib.rs` -> `library/rust`
- `*.sln`, `*.slnx`, `*.vcxproj`, or `Project.md` -> `library/cpp`
- `Package.swift` + iOS folders -> `mobile-app/ios-swift`
- `*.xcodeproj` or `*.xcworkspace` -> `mobile-app/ios-swift`
- `pyproject.toml` + web framework dependency -> `backend-service/python`
- `tsconfig.json` + no app framework -> `library/typescript`

If uncertain, apply only `base/` and record unknown facts in `.agents/profile.md`.
