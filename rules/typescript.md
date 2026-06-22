# TypeScript conventions

## Naming
- Files: `kebab-case.ts`
- Classes/Types: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`

## Type safety
- Never use `any` — use `unknown` and narrow types.
- Prefer `interface` over `type` for objects.
- Avoid `enum` — use `as const` or union types.
- Explicit types for parameters and return values.
- No `// @ts-ignore` without explanation.

## Code style
- `const` by default, `let` only when reassigned.
- Template literals over concatenation.
- Use `??` and `?.` operators.
- Prefix unused variables with `_`.

## Imports
Group: runtime built-ins → external → internal → types. Blank lines between groups.

## External data validation
- Never use `as` for external data (API, user input, files).
- Always validate at runtime with a schema library (e.g. Zod, Valibot, ArkType).
- Derive static types from the schema (e.g. `z.infer<typeof Schema>`).

## Error handling
- Prefer returning result objects (`{ data, error }`) over throwing exceptions for expected errors.
- Define a standard result type, e.g., `type Result<T, E = Error> = { data: T; error: null } | { data: null; error: E };`.
- Use `try/catch` only for unexpected crashes or at architectural boundaries.
