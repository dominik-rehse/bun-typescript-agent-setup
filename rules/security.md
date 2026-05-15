---
description: Use when handling input, secrets, files, shell commands, HTTP, cookies, databases, or auth-sensitive code.
alwaysApply: false
globs: "**/*.ts, **/*.tsx, **/*.js, **/*.jsx"
---

# Security

## External input
- Treat HTTP requests, CLI arguments, files, environment variables, database rows, and third-party SDK responses as untrusted.
- Validate external data at the boundary with the project's schema library before passing it into application logic.
- Return validation errors that identify the invalid field without exposing sensitive values.

## Secrets and configuration
- Never commit secrets, tokens, keys, certificates, cookies, or `.env` files.
- Read configuration only through the validated environment module described in `bun.md`.
- Redact secrets from errors, logs, snapshots, and test fixtures.

## Shell commands
- Prefer Bun and TypeScript APIs over shelling out.
- If `Bun.$` is required, pass untrusted values as interpolated arguments and avoid building command strings manually.
- Do not pass user-controlled values into shell names, flags, redirects, pipes, or file globs without allow-list validation.

## Files and paths
- Treat user-provided paths as untrusted.
- Resolve paths against an explicit base directory and reject paths that escape it.
- Do not expose raw filesystem paths in user-facing errors.

## HTTP and cookies
- Set cookies with `HttpOnly`, `Secure`, and explicit `SameSite` values unless there is a documented reason not to.
- Configure CORS with explicit origins, methods, and headers. Do not use wildcard origins with credentials.
- Keep auth checks close to the route or boundary that requires them.

## Database access
- Use parameterized queries for SQL values.
- Validate identifiers such as table names, column names, and sort keys with allow lists before using them in SQL.
- Keep test databases isolated from development and production data.
