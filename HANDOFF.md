# Handoff: evaluate & test `bun-typescript-agent-setup`

**For the agent picking this up.** Evaluate this plugin and test it, applying the
lessons from the recent `stdd` v0.2 evaluation and rebuild (see
`~/repos/EVAL-FINDINGS.md` and `~/repos/stdd`). The owner's standing preferences:
**Claude Code only** (no other agents), **reference don't restate** (dedup; one
canonical home + pointers), and **conscious versioning**. Ground every claim in
primary evidence (files, transcripts, git history). A well-evidenced "this isn't
earning its keep" is a valid finding.

## What this plugin is

A setup plugin that vendors a Bun + TypeScript baseline into a project:
`/bun-typescript-agent-setup:setup` runs `scripts/install.sh`, which copies
`rules/*.md` → `.claude/rules/`, writes templates (`biome.json`, `dprint.json`,
`lefthook.yml`, `package.json`, `tsconfig.json`, `.gitignore`) to the project
root (skip-if-exists), runs `bun add -d @biomejs/biome @types/bun dprint lefthook
typescript`, and runs `bunx lefthook install`. **It owns the git pre-commit slot**
— this is what silently clobbered stdd's gate in the consuming repos.

Evidence base: this repo; the three consuming repos (`~/repos/{agent,
email-to-file,capital-provider-db}`); transcripts under
`~/.claude/projects/-home-dominik-repos-bun-typescript-agent-setup*` and the
consuming-repo projects.

## The stdd-composition change already made (verify it)

`templates/lefthook.yml`'s `test` job was changed from `run: bun test` to:

> `run: 'if [ -x ./scripts/stdd-precommit.sh ]; then ./scripts/stdd-precommit.sh; else bun test; fi'`

Intent: when stdd is installed the lefthook test job runs stdd's tiered gate
(honouring `.stdd-off` / `.stdd-integrity`); otherwise plain `bun test`. This is
order-independent and needs no hand-wiring — stdd's setup greps `lefthook.yml`
for `stdd-precommit` and reports the gate already wired.

**Test it both ways** in throwaway repos: (a) stdd absent → `bun test` runs and
gates; (b) stdd present (drop a `scripts/stdd-precommit.sh`) → it runs instead,
`.stdd-off` disables it, a failing unit test blocks the commit; (c) run stdd's
`/stdd:setup` on a bun-ts project and confirm it detects the job as already
wired and its verification passes (no duplicate job added). Report whether the
composition holds and any rough edges.

## What to evaluate

1. **Propagation gap (high priority).** `install.sh` is skip-if-exists with **no
   `--force`/`--check`** (the sibling `language-agnostic-agent-setup` has both).
   So rule and template updates — *including the lefthook change above* — cannot
   reach already-installed projects; `agent`/`capital`/`email-to-file` are frozen
   on whatever template they got at install (their `lefthook.yml` predates the
   `test`/`build` jobs entirely). Evaluate adding `--check`/`--force`, but note
   the nuance stdd didn't have: force-overwriting `package.json`/`tsconfig.json`
   would clobber project customisation. Recommend a per-file policy (safe to
   force: `rules/*`, `lefthook.yml`, `biome.json`, `dprint.json`; never force:
   `package.json`, `tsconfig.json`).

2. **Versioning + freshness.** Unversioned, and unlike stdd there is **no
   SessionStart hook**, so nothing self-heals. Decide consciously: version it
   (and how would updates reach projects without a hook?), or stay unversioned
   and lean on `--check`/`--force`. Tie this to finding 1.

3. **Dedup / reference-don't-restate.** `rules/bun.md` has a `## Testing` snippet
   that duplicates the existence of `rules/testing.md` — collapse one. Check
   overlap/contradiction *across* the rule sets now co-resident in
   `.claude/rules/`: this plugin's `testing.md` says "mock network and SDK calls"
   and "use `:memory:` SQLite", which collide with stdd's "prefer real
   dependencies" and its tiering, and with real-DB projects (`capital` had to
   override with a `database.md`). A deferral note was added to `testing.md`
   ("stdd wins") — verify it's sufficient or whether deeper reconciliation is
   needed. Also cross-check against `language-agnostic-agent-setup`'s rules for
   overlap.

4. **Tooling correctness & idempotency.** `install.sh` runs `bun add -d` (network;
   installs *latest*, which interacts with `tooling.md`'s "never hard-plug
   versions") and `bunx lefthook install`. Confirm: re-running is truly
   idempotent; the lefthook jobs' `bun run typecheck` / `bun run build` match
   scripts the template `package.json` defines (currently they do — `build`,
   `typecheck` exist); the `build` job (`bun build src/index.ts`) is sane for a
   library/CLI vs a project with a different entrypoint.

5. **Setup verification.** Like stdd's gate-verification step, does setup confirm
   the installed toolchain actually works (biome/dprint/lefthook run; a commit is
   gated)? It does not. Recommend a post-install smoke.

6. **Intended vs observed use.** Mine the transcripts: are these rules actually
   followed, contradicted, or ignored? Did the `test`/`build` lefthook jobs ever
   cause friction or get removed (the consuming repos' `lefthook.yml` lack them —
   why)? Was `bun add -d` re-run destructively?

7. **CC-native.** Confirm no Cursor/cross-agent residue (this plugin appears
   clean — no `.cursor`, no dual-format machinery — confirm).

## Deliverable

A findings report: TL;DR, then per-area findings with file/line/transcript
evidence, then prioritized recommendations split into (a) changes to this plugin
and (b) changes to how it composes with stdd and `language-agnostic-agent-setup`.
Flag where evidence is thin. Slash commands (`/bun-typescript-agent-setup:setup`)
are user-invoked — don't call `install.sh` directly when a step needs the skill's
behaviour.
