# bun-typescript-agent-setup

Bun + TypeScript stack rules and project scaffolding for Claude Code.

The **rules** in `rules/` are injected live by a `SessionStart` hook — they are
not vendored into the project, so they're active from the first session and a
plugin update applies on the next session, with nothing to re-sync. The **stack
templates** (`package.json`, `tsconfig.json`, `biome.json`, `dprint.json`,
`lefthook.yml`, `.gitignore`) are real config files tools read from disk, so they
are written into the project by `/bun-typescript-agent-setup:setup`.

## Install

```text
/plugin marketplace add dominik-rehse/bun-typescript-agent-setup
/plugin install bun-typescript-agent-setup@bun-typescript-agent-setup
```

The rules are now active. Then, in a project, lay down the scaffolding:

```text
/bun-typescript-agent-setup:setup
```

`setup` writes the templates (skip-if-exists), runs
`bun add -d @biomejs/biome @types/bun dprint lefthook typescript`, and runs
`bunx lefthook install` in a git repo. Biome handles JS/TS/JSON; dprint handles
Markdown; `lefthook.yml` runs each gate (biome, dprint, typecheck, test, build)
only when staged files match its glob. The `test` gate composes with the `stdd`
plugin (it runs stdd's tiered gate when installed, else `bun test`); the `build`
gate runs only when a `build` script exists.

(Legacy installs that vendored the rules into `.claude/rules/*.md` still work —
the SessionStart hook skips any rule already present there to avoid
double-loading. Delete the vendored copy to switch that rule to live injection.)

## Upgrades

```text
/plugin marketplace update bun-typescript-agent-setup
/plugin update bun-typescript-agent-setup@bun-typescript-agent-setup
```

Start a new session afterwards; the rules load fresh from the updated plugin. The
**config templates** do not auto-update — re-run `/bun-typescript-agent-setup:setup
--check` to see drift and `--force` to pick it up (`package.json`/`tsconfig.json`
are project-owned and never force-overwritten). The plugin is versioned — bump
`version` in `plugin.json` to ship a release.
