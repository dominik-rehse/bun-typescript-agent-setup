# Tooling

## Package management
- Use `bun` for all package management, testing, and scripts. Never `npm`, `yarn`, or `pnpm`.
- Install dependencies at their latest version programmatically — never hard-code versions.

## Quality gates
- Write tests for new features with `bun:test` (colocated `*.test.ts`).
- After TypeScript changes, run `bun run typecheck` if the project provides it.
- Fix any lint errors your changes introduce.
- Before declaring the task done, run `bun run precommit`. If it can't run, explain why.

## Boundaries
- Never edit `dist/` or `node_modules/`.
- Use agent-browser (CLI or its MCP server) to test and fine-tune anything HTML/browser-viewable.
- Don't set up CI/CD pipelines (e.g. GitHub Actions) unless explicitly requested.
