---
description: Vendor bun-typescript-agent-setup into the current project. Copies rules to .claude/rules/*.md and stack templates to the project root, installs dev deps, and registers the lefthook git hook. Supports --check (read-only drift detection) and --force (update rules/configs, keep project-owned files) for re-runs after upstream updates. Invoke with /bun-typescript-agent-setup:setup.
argument-hint: "[--check | --force]"
disable-model-invocation: true
---

# /bun-typescript-agent-setup:setup — Vendor the stack into the current project

Run once per project. There is no SessionStart auto-mirror — rules and templates
only land after this runs, and are tracked in source control like any other file.

## Task

### 1. Run the installer

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" $ARGUMENTS
```

It copies `rules/*.md` → `.claude/rules/`, writes templates (`package.json`,
`tsconfig.json`, `biome.json`, `dprint.json`, `lefthook.yml`, `.gitignore`) to the
project root, runs `bun add -d @biomejs/biome @types/bun dprint lefthook
typescript`, and registers the git hook via `bunx lefthook install`.

Modes (mutually exclusive), for re-runs after an upstream update:

- _default_ — write only files that are absent; never clobber existing.
- `--check` — read-only diff of the updatable files (`rules/*`, `lefthook.yml`,
  `biome.json`, `dprint.json`, `.gitignore`). Reports `ok`/`miss`/`drift`; exits
  non-zero on drift. `package.json`/`tsconfig.json` are project-owned and not
  checked.
- `--force` — overwrite the updatable files with upstream. `package.json` and
  `tsconfig.json` are **never** force-overwritten (only written when absent), so
  project customisation is preserved. Run `--check` first to preview.

### 2. Verify it actually works

Don't assume — confirm the toolchain runs and the commit gate is registered:

```bash
bun run typecheck && bunx biome check . && echo "toolchain ok"
git rev-parse --git-path hooks/pre-commit   # lefthook should own this path
```

If the project is a git repo, prove the gate blocks a failing test (the failure
mode is a silently dormant hook): stage a trivial failing `*.test.ts`, attempt a
commit, confirm it is blocked, then discard the probe. If `bunx lefthook install`
did not run (no `.git` at install time), run it now.

### 3. Confirm

> bun-typescript-agent-setup installed — toolchain verified, commit gate active.

If verification failed, say so plainly and what is needed (e.g. run
`bunx lefthook install`).
