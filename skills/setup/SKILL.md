---
description: Vendor bun-typescript-agent-setup into the current project. Copies rules to .claude/rules/*.md. Invoke with /bun-typescript-agent-setup:setup.
disable-model-invocation: true
---

# /bun-typescript-agent-setup:setup — Vendor rules into the current project

Run once per project. This is the only install path — there is no SessionStart auto-mirror, so the rules only land in the project after this command runs and they're tracked in source control like any other file.

Safe to re-run; existing files are not overwritten.

## Task

Run the installer that ships with the plugin:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" $ARGUMENTS
```

The installer also writes templates such as `package.json`, `tsconfig.json`, `biome.json`, `dprint.json`, `lefthook.yml`, and `.gitignore` into the project root (skip-if-exists), runs `bun add -d @biomejs/biome @types/bun dprint lefthook typescript`, and registers the lefthook git hook via `bunx lefthook install` if the target is a git repository.

After the script finishes, confirm with:

> bun-typescript-agent-setup installed.
