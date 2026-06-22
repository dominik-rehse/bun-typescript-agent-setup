# bun-typescript-agent-setup

Rules for Bun + TypeScript repos.

Each rule in `rules/` is a single Markdown file. The installer copies it into a project's `.claude/rules/`, so there's one source of truth per rule.

## Install

```text
/plugin marketplace add dominik-rehse/bun-typescript-agent-setup
/plugin install bun-typescript-agent-setup@bun-typescript-agent-setup
```

Then run `/bun-typescript-agent-setup:setup` — it runs `scripts/install.sh` in the current project. You can also clone this repo and run the installer directly:

```bash
bash path/to/bun-typescript-agent-setup/scripts/install.sh
```

`install.sh` also writes templates such as `package.json`, `tsconfig.json`, `biome.json`, `dprint.json`, `lefthook.yml`, and `.gitignore` into the project root (skip-if-exists) and runs `bun add -d @biomejs/biome @types/bun dprint lefthook typescript` to install dev dependencies at latest. Biome handles JS/TS/JSON formatting and linting; dprint handles Markdown. The `lefthook.yml` template configures a pre-commit hook that runs each gate (biome, dprint, typecheck, test, build) only when staged files match its glob; `bunx lefthook install` is run automatically if the target is a git repository.
