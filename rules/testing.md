# Testing with `bun:test`

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
- Use `:memory:` SQLite for tests.
- Close the DB in `afterEach()`.

## Rules
- Never skip tests with `.skip()` — fix them.
- Test behaviour, not implementation.
- Clean up resources after every test.
