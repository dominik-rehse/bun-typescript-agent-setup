# Bun runtime

## CLI (use Bun, not Node/npm/yarn/pnpm)
- `bun <file>` not `node` or `ts-node`
- `bun install` not `npm install`
- `bun test` not `jest` or `vitest`
- `bun build` not `webpack` or `esbuild`
- `bunx <pkg>` not `npx`
- Bun auto-loads `.env` — don't use `dotenv`.

## Environment variables
- Validate `Bun.env` at runtime using a schema library (e.g., Zod or Valibot) during application startup.
- Create a dedicated file (e.g., `src/env.ts`) that parses and exports the validated environment variables.
- Never use `Bun.env.VAR_NAME` directly in application logic; always import from the validated `env.ts` file to ensure the app fails fast if configuration is missing.

## Built-in APIs (prefer over npm packages)
- Files: `Bun.file()`, `Bun.write()` over `node:fs`
- SQLite: `import { Database } from "bun:sqlite"` not `better-sqlite3`
- Testing: `import { test, expect } from "bun:test"`
- Shell: `` Bun.$`cmd` `` not `execa`
- Server: `Bun.serve()` not `express`
- WebSocket: built-in `WebSocket` not `ws`

## Async and performance
- Leverage Bun's native, highly-optimized APIs for asynchronous operations.
- Use `Bun.file().stream()` or `Bun.file().text()` for file reading instead of `fs.promises`.
- Use `Bun.write()` for file writing.
- Prefer `Bun.serve()` for HTTP servers over Node-based frameworks when performance is critical.

## Testing
```ts
import { test, expect } from "bun:test";

test("example", () => {
  expect(1).toBe(1);
});
```
