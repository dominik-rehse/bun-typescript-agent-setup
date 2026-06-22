#!/bin/bash
# Project install for the bun-typescript-agent-setup plugin.
#
# Idempotent. Safe to re-run. Installs Claude Code project-local rules into
# .claude/rules/*.md in the current working directory by default; pass the
# target directory as the first non-flag argument. Existing files are never
# overwritten.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
TARGET_DIR=""

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        --*)
            echo "bun-typescript-agent-setup install: unknown flag: $arg" >&2
            exit 1
            ;;
        *)
            TARGET_DIR="$arg"
            ;;
    esac
done

TARGET_DIR="${TARGET_DIR:-${CLAUDE_PROJECT_DIR:-$PWD}}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo "bun-typescript-agent-setup: installing into $TARGET_DIR"

install_file() {
    local src="$1" dst="$2"
    if [ -e "$dst" ]; then
        echo "  skip   $dst (exists)"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  write  $dst"
}

mkdir -p "$TARGET_DIR/.claude/rules"
for f in "$SOURCE_DIR/rules"/*.md; do
    [ -f "$f" ] || continue
    install_file "$f" "$TARGET_DIR/.claude/rules/$(basename "$f")"
done

while IFS= read -r f; do
    install_file "$f" "$TARGET_DIR/$(basename "$f")"
done < <(find "$SOURCE_DIR/templates" -maxdepth 1 -type f)

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

echo "bun-typescript-agent-setup: installed."
