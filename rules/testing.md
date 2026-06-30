# Testing with `bun:test`

> When the **stdd** plugin is installed, it owns the test *methodology*: follow
> its spec-first red-green-refactor loop, its test tiers (a fast unit gate vs.
> slow tests under `integration/` / `e2e/`), and its coverage audit. This file
> then covers `bun:test` *mechanics* only — where the rules below differ from
> stdd (e.g. mocking vs. real dependencies), stdd wins.

## Structure
- Place `*.test.ts` alongside the code being tested.
- Use `describe()` for grouping, `test()` for cases.
- Use `beforeEach()` / `afterEach()` for setup and cleanup.

## Key commands
```bash
bun test                    # all tests
bun test path/to/file.ts    # specific file
bun test --coverage         # with coverage
```

## Mocking external APIs
- Mock network and SDK calls in tests.
- Use `mock()` from `bun:test`.
- Verify call counts with `toHaveBeenCalledTimes()`.

## Database testing
- For SQLite-backed code, an in-memory `:memory:` database is a fast default;
  close it in `afterEach()`.
- For any other engine (Postgres, MySQL, Dolt, …), a `:memory:` SQLite shim does
  not exercise the real dialect — use the real engine, in the integration tier
  (under an `integration/` directory) rather than a substitute. When stdd is
  installed, its tiers and prefer-real-dependencies stance govern this.

## Rules
- Never skip tests with `.skip()` — fix them.
- Test behaviour, not implementation.
- Clean up resources after every test.
