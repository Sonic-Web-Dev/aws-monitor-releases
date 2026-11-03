#!/usr/bin/env bash
# SessionStart hook (clear|compact): load the project handoff note if it is recent.
set -uo pipefail
[[ -n "${AWS_MONITOR_HANDOFF_RUNNING:-}" ]] && exit 0

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/handoff-lib.sh"

INPUT=$(cat)
CWD=$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null)
[[ -z "$CWD" ]] && CWD="$PWD"

FILE=$(handoff_path "$CWD")
# Fall back to a hand-written note in the project.
[[ -f "$FILE" ]] || FILE="$CWD/.claude/handoff.md"
[[ -f "$FILE" ]] || exit 0

MAX_AGE=$((24 * 3600))
AGE=$(( $(date +%s) - $(stat -f %m "$FILE" 2>/dev/null || stat -c %Y "$FILE") ))
(( AGE > MAX_AGE )) && exit 0

# About 1000 tokens.
echo "Handoff from a previous session ($((AGE / 60)) min old, $FILE):"
head -c 4000 "$FILE"
echo
