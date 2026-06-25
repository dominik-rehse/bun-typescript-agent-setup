# Tooling

- Use `bun` for all package management, testing, and script execution. Never use `npm`, `yarn`, or `pnpm`.
- Never edit `dist/` or `node_modules/`.
- Write tests for new features using `bun:test`.
- Run `bun run typecheck` after TypeScript changes when the project provides it.
- Fix any linting errors introduced by your changes.
- Never hard-plug dependency versions. Always install the latest version programmatically.
- Run `bun run precommit` before declaring the task done. If it cannot be run, explain why.
- Do not generate or configure CI/CD pipelines (e.g., GitHub Actions) unless explicitly requested.
- Use the Playwright MCP to test and fine-tune anything HTML/browser-viewable during development.
