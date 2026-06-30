#!/bin/bash
# Project install for the bun-typescript-agent-setup plugin (Claude Code).
#
# Idempotent. Installs project-local rules into .claude/rules/*.md and stack
# templates into the project root. Pass the target as the first non-flag arg.
#
# Modes:
#   (default)   Write each file only if it doesn't already exist. Never clobbers.
#   --check     Dry-run. Report files absent or differing from upstream. No
#               writes. Exits 0 iff every UPDATABLE file is byte-identical to
#               upstream. Use from CI to detect rule/config drift.
#   --force     Overwrite UPDATABLE files (rules/*, lefthook.yml, biome.json,
#               dprint.json, .gitignore) with upstream. package.json and
#               tsconfig.json are project-owned and are NEVER force-overwritten
#               (only written when absent) — they carry per-project edits.
#
# In --check/--force, scope is the updatable set only; package.json/tsconfig.json
# are reported as project-owned and left untouched.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
TARGET_DIR=""
MODE="install"
DRIFT=0

for arg in "$@"; do
    case "$arg" in
        --check)
            [ "$MODE" = install ] || { echo "install: --check and --force are mutually exclusive" >&2; exit 1; }
            MODE="check" ;;
        --force)
            [ "$MODE" = install ] || { echo "install: --check and --force are mutually exclusive" >&2; exit 1; }
            MODE="force" ;;
        --help|-h)
            sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        --*)
            echo "bun-typescript-agent-setup install: unknown flag: $arg" >&2
            exit 1 ;;
        *)
            TARGET_DIR="$arg" ;;
    esac
done

TARGET_DIR="${TARGET_DIR:-${CLAUDE_PROJECT_DIR:-$PWD}}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

case "$MODE" in
    install) echo "bun-typescript-agent-setup: installing into $TARGET_DIR" ;;
    check)   echo "bun-typescript-agent-setup: checking $TARGET_DIR (read-only)" ;;
    force)   echo "bun-typescript-agent-setup: force-updating in $TARGET_DIR" ;;
esac

# package.json and tsconfig.json carry per-project customisation — only ever
# written when absent, never force-overwritten or drift-checked.
is_project_owned() {
    case "$(basename "$1")" in
        package.json|tsconfig.json) return 0 ;;
        *) return 1 ;;
    esac
}

install_file() {
    local src="$1" dst="$2"
    case "$MODE" in
        install)
            if [ -e "$dst" ]; then echo "  skip   $dst (exists)"; return; fi
            mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; echo "  write  $dst" ;;
        check)
            if is_project_owned "$dst"; then echo "  own    $dst (project-owned, not checked)"; return; fi
            if [ ! -e "$dst" ]; then echo "  miss   $dst"; DRIFT=1
            elif cmp -s "$dst" "$src"; then echo "  ok     $dst"
            else echo "  drift  $dst"; diff -u "$dst" "$src" | sed 's/^/         /' || true; DRIFT=1; fi ;;
        force)
            if is_project_owned "$dst"; then
                if [ -e "$dst" ]; then echo "  own    $dst (project-owned, kept)"; return; fi
                mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; echo "  write  $dst"; return
            fi
            mkdir -p "$(dirname "$dst")"
            if [ -e "$dst" ] && cmp -s "$dst" "$src"; then echo "  ok     $dst"; return; fi
            cp "$src" "$dst"; echo "  write  $dst" ;;
    esac
}

mkdir -p "$TARGET_DIR/.claude/rules"
for f in "$SOURCE_DIR/rules"/*.md; do
    [ -f "$f" ] || continue
    install_file "$f" "$TARGET_DIR/.claude/rules/$(basename "$f")"
done

while IFS= read -r f; do
    install_file "$f" "$TARGET_DIR/$(basename "$f")"
done < <(find "$SOURCE_DIR/templates" -maxdepth 1 -type f)

if [ "$MODE" = check ]; then
    if [ "$DRIFT" -eq 0 ]; then
        echo "bun-typescript-agent-setup: in sync with upstream."
        exit 0
    fi
    echo "bun-typescript-agent-setup: drift detected. Run --force to update (project-owned files are kept)." >&2
    exit 1
fi

# install / force only: dependencies and the git hook (read-only --check skips these).
if command -v bun >/dev/null 2>&1; then
    echo "  run    bun add -d @biomejs/biome @types/bun dprint lefthook typescript"
    bun add -d --cwd "$TARGET_DIR" @biomejs/biome @types/bun dprint lefthook typescript
    if [ -d "$TARGET_DIR/.git" ]; then
        echo "  run    bunx lefthook install"
        (cd "$TARGET_DIR" && bunx lefthook install) || \
            echo "  warn   lefthook install failed — run 'bunx lefthook install' manually"
    else
        echo "  skip   bunx lefthook install (no .git directory)"
    fi
else
    echo "  warn   bun not found — run: bun add -d @biomejs/biome @types/bun dprint lefthook typescript"
fi

echo "bun-typescript-agent-setup: ${MODE} done."
