# Dependency updates with Bun

## Bumping versions
- `bun update` moves dependencies within their `package.json` ranges. That is the safe default.
- To cross a range, name the package: `bun add pkg@latest`, or `bun add -d pkg@latest` for a dev dependency.
- Never run a blind `bun update --latest`. It writes the literal specifier `latest` into `bun.lock` for every direct dependency instead of keeping the `package.json` ranges. It also jumps peer pins: one run installed zod 4 under a dependent that pins `"zod": "3.x"` and produced 8 type errors.

## Checking the lockfile
- A fast "no changes" from `bun install` proves nothing. Bun trusts its existing install state and skips re-resolution, so the run finishes in milliseconds while a stale or duplicated `node_modules` survives.
- The honest fixed-point check is a cold install in a throwaway worktree:

```bash
git worktree add --detach ../cold-check
(cd ../cold-check && bun install --ignore-scripts && git diff --exit-code bun.lock)
git worktree remove --force ../cold-check
```

## After an update
- Look for duplicate nested copies before you trust green types: `find node_modules -type d -name <pkg>`.
- Two copies of one package break `instanceof` across a package boundary while types stay green. Bun kept an old `hono` nested under an SDK and the runtime check failed.
- `bun install --force` does not clear a duplicate. Align the version constraints so every dependent accepts one copy.
