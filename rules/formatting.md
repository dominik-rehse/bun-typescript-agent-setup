# Code formatting and linting

Prefer [Biome](https://biomejs.dev/) as the formatter + linter for JS/TS/JSON in Bun projects — one fast tool, no extra runtime dependencies, configured via `biome.json`. Biome does not format Markdown, so use [dprint](https://dprint.dev/) with its markdown plugin for `.md` files, configured via `dprint.json`.

Run them via Bun:
- `bunx biome check --write .` — format and lint JS/TS/JSON in one pass
- `bunx dprint fmt` — format Markdown
- `bun run lint` / `bun run format` — if the project defines these scripts in `package.json` (the bundled `format` script runs both Biome and dprint)

## Before committing
Run `bun run precommit` (or equivalent). If none is configured, run `bunx biome check --write . && bunx dprint fmt` manually.
