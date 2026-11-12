#!/usr/bin/env bash
# SessionStart hook (clear|compact): load the handoff note of this chat if it is recent.
set -uo pipefail
[[ -n "${AWS_MONITOR_HANDOFF_RUNNING:-}" ]] && exit 0

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/handoff-lib.sh"

INPUT=$(cat)
CWD=$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null)
SID=$(jq -r '.session_id // empty' <<<"$INPUT" 2>/dev/null)
SOURCE=$(jq -r '.source // empty' <<<"$INPUT" 2>/dev/null)
[[ -z "$CWD" ]] && CWD="$PWD"

FILE=""
[[ -n "$SID" ]] && FILE=$(handoff_path "$CWD" "$SID")

# Compaction keeps the session id, so only this chat's own note counts. /clear starts a new session
# id: take over the newest recent note of the project, so it follows the chat and no other chat
# picks it up later.
if [[ -n "$FILE" && ! -f "$FILE" && "$SOURCE" != "compact" ]]; then
  LATEST=$(handoff_recent "$CWD" | head -1)
  [[ -n "$LATEST" ]] && mv "$LATEST" "$FILE" 2>/dev/null
fi

# Fall back to a hand-written note in the project.
[[ -n "$FILE" && -f "$FILE" ]] || FILE="$CWD/.claude/handoff.md"
[[ -f "$FILE" ]] || exit 0

AGE=$(handoff_age "$FILE")
(( AGE > HANDOFF_MAX_AGE )) && exit 0

# About 1000 tokens.
echo "Handoff from a previous session ($((AGE / 60)) min old, $FILE):"
head -c 4000 "$FILE"
echo

# Notes of other chats in this project: listed, never loaded.
OTHERS=$(handoff_recent "$CWD" | grep -vxF "$FILE" | head -5)
if [[ -n "$OTHERS" ]]; then
  echo "Other chats in this project have their own handoff notes. They are not this chat's work;"
  echo "read one only if the note above is clearly about something else:"
  printf '%s\n' "$OTHERS"
fi
