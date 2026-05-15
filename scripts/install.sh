#!/bin/bash
# Project install for the bun-typescript-agent-setup plugin.
#
# Idempotent. Safe to re-run. Installs into the current working directory by
# default; pass the target as the first non-flag argument.
#
# Flags:
#   --claude    Install Claude Code project-local rules (.claude/rules/*.md)
#   --cursor    Install Cursor project-local rules (.cursor/rules/*.mdc)
#   --both      Install both. Default if no flag is given.

set -euo pipefail

SOURCE_DIR=$(cd "$(dirname "$0")/.." && pwd)
TARGET_DIR=""
WANT_CLAUDE=0
WANT_CURSOR=0

for arg in "$@"; do
    case "$arg" in
        --claude) WANT_CLAUDE=1 ;;
        --cursor) WANT_CURSOR=1 ;;
        --both)   WANT_CLAUDE=1; WANT_CURSOR=1 ;;
        --help|-h)
            sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
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

if [ "$WANT_CLAUDE" -eq 0 ] && [ "$WANT_CURSOR" -eq 0 ]; then
    WANT_CLAUDE=1
    WANT_CURSOR=1
fi

TARGET_DIR="${TARGET_DIR:-${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$PWD}}}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo "bun-typescript-agent-setup: installing into $TARGET_DIR"

# Emit a Claude-flavoured rule: strip the leading YAML frontmatter (Cursor-only
# metadata) and any blank lines immediately following it.
emit_claude_rule() {
    local src="$1" dst="$2"
    awk '
        BEGIN { in_fm = 0; past_fm = 0; emitting = 0 }
        NR == 1 && /^---[[:space:]]*$/ { in_fm = 1; next }
        in_fm && /^---[[:space:]]*$/ { in_fm = 0; past_fm = 1; next }
        in_fm { next }
        past_fm && !emitting && /^[[:space:]]*$/ { next }
        { emitting = 1; print }
    ' "$src" > "$dst"
}

install_file() {
    local src="$1" dst="$2" mode="$3"
    if [ -e "$dst" ]; then
        echo "  skip   $dst (exists)"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    case "$mode" in
        claude) emit_claude_rule "$src" "$dst" ;;
        copy)   cp "$src" "$dst" ;;
    esac
    echo "  write  $dst"
}

if [ "$WANT_CLAUDE" -eq 1 ]; then
    mkdir -p "$TARGET_DIR/.claude/rules"
    for f in "$SOURCE_DIR/rules"/*.md; do
        [ -f "$f" ] || continue
        install_file "$f" "$TARGET_DIR/.claude/rules/$(basename "$f")" claude
    done
fi

if [ "$WANT_CURSOR" -eq 1 ]; then
    mkdir -p "$TARGET_DIR/.cursor/rules"
    for f in "$SOURCE_DIR/rules"/*.md; do
        [ -f "$f" ] || continue
        name="$(basename "$f" .md).mdc"
        install_file "$f" "$TARGET_DIR/.cursor/rules/$name" copy
    done
fi

while IFS= read -r f; do
    install_file "$f" "$TARGET_DIR/$(basename "$f")" copy
done < <(find "$SOURCE_DIR/templates" -maxdepth 1 -type f)

if command -v bun >/dev/null 2>&1; then
    echo "  run    bun add -d @biomejs/biome @types/bun typescript"
    bun add -d --cwd "$TARGET_DIR" @biomejs/biome @types/bun typescript
else
    echo "  warn   bun not found — run: bun add -d @biomejs/biome @types/bun typescript"
fi

echo "bun-typescript-agent-setup: installed."
