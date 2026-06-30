---
description: Install the bun-typescript-agent-setup stack templates into the current project (package.json, tsconfig, biome, dprint, lefthook, .gitignore), install dev deps, and register the lefthook git hook. The rules load automatically via a SessionStart hook — they are NOT installed here. Supports --check / --force for the config templates. Invoke with /bun-typescript-agent-setup:setup.
argument-hint: "[--check | --force]"
disable-model-invocation: true
---

# /bun-typescript-agent-setup:setup — Install the stack into the current project

Run once per project to lay down the config templates and toolchain. **The rules
are not installed** — a SessionStart hook injects them live from the plugin, so
they're active from the first session and update with the plugin (nothing to
vendor, nothing to re-sync).

## Task

### 1. Run the installer

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" $ARGUMENTS
```

It writes the templates (`package.json`, `tsconfig.json`, `biome.json`,
`dprint.json`, `lefthook.yml`, `.gitignore`) to the project root, runs
`bun add -d @biomejs/biome @types/bun dprint lefthook typescript`, and registers
the git hook via `bunx lefthook install`.

Modes (mutually exclusive), for re-runs after an upstream update — these apply to
the **config templates** (rules need no re-sync, they're injected live):

- _default_ — write only files that are absent; never clobber existing.
- `--check` — read-only diff of the updatable configs (`lefthook.yml`,
  `biome.json`, `dprint.json`, `.gitignore`). Reports `ok`/`miss`/`drift`; exits
  non-zero on drift. `package.json`/`tsconfig.json` are project-owned and not
  checked.
- `--force` — overwrite the updatable configs with upstream. `package.json` and
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
