#!/bin/bash
# SessionStart hook (Claude Code): inject this plugin's rules into the session
# context, read live from the plugin. There is no vendored copy in the project,
# so a plugin update applies on the next session — nothing goes stale.
#
# Migration safety: any rule a project has ALREADY vendored into
# .claude/rules/<name>.md (a legacy install) is skipped here, so there is no
# double-load during the transition. Delete the vendored copy to switch that
# rule to live injection.
#
# Mechanism: SessionStart hook stdout is injected into the session context.

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
RULES_DIR="$SCRIPT_DIR/../rules"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

[ -d "$RULES_DIR" ] || exit 0

shopt -s nullglob
emitted=0
for f in "$RULES_DIR"/*.md; do
    name=$(basename "$f")
    # Skip a legacy vendored copy to avoid double-loading the same rule.
    [ -f "$PROJECT_DIR/.claude/rules/$name" ] && continue
    if [ "$emitted" -eq 0 ]; then
        printf '<!-- bun-typescript-agent-setup rules (injected live from the plugin; edit upstream, not here) -->\n\n'
        emitted=1
    fi
    cat "$f"
    printf '\n\n'
done

exit 0
