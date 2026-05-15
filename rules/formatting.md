---
description: Use when asked about code formatting or linting.
alwaysApply: false
---

# Code formatting and linting

Prefer [Biome](https://biomejs.dev/) as the single formatter + linter for Bun projects — one fast tool, no extra runtime dependencies, configured via `biome.json`.

Run it via Bun:
- `bunx biome check --write .` — format and lint in one pass
- `bun run lint` / `bun run format` — if the project defines these scripts in `package.json`

## Before committing
Run `bun run precommit` (or equivalent). If none is configured, run `bunx biome check --write .` manually.
