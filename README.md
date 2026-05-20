# bun-typescript-agent-setup

Rules for Bun + TypeScript repos.

Each rule in `rules/` is a single Markdown file with Cursor frontmatter. The installer renames it to `.mdc` for Cursor and strips the frontmatter for Claude Code, so there's one source of truth per rule.

## Install

### Claude Code

```text
/plugin marketplace add dominik-rehse/bun-typescript-agent-setup
/plugin install bun-typescript-agent-setup@bun-typescript-agent-setup
```

Then run `/bun-typescript-agent-setup:setup` — it runs `scripts/install.sh` in the current project.

### Cursor

Clone this repo, then run `scripts/install.sh` directly:

```bash
bash path/to/bun-typescript-agent-setup/scripts/install.sh
```

Pass `--claude` or `--cursor` to install only one target (default: both).

`install.sh` also writes templates such as `package.json`, `tsconfig.json`, `biome.json`, `dprint.json`, and `.gitignore` into the project root (skip-if-exists) and runs `bun add -d @biomejs/biome @types/bun dprint typescript` to install dev dependencies at latest. Biome handles JS/TS/JSON formatting and linting; dprint handles Markdown.
