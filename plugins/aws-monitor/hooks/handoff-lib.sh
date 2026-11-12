#!/usr/bin/env bash
# Shared helpers for the handoff hooks. Handoffs live outside the repo so they never pollute git.
# Layout: <root>/<project slug>/<session id>.md, so several chats in one project never share a note.
HANDOFF_ROOT="${AWS_MONITOR_HANDOFF_DIR:-$HOME/.claude/aws-monitor/handoffs}"
HANDOFF_MAX_AGE=$((24 * 3600))

_handoff_slug() {
  printf '%s' "$1" | sed 's#[^A-Za-z0-9._-]#-#g; s#^-*##'
}

# Stable per-project directory derived from the project directory.
handoff_dir() {
  local slug
  slug=$(_handoff_slug "$1")
  printf '%s/%s' "$HANDOFF_ROOT" "${slug:-root}"
}

# Note of one session in one project.
handoff_path() {
  local sid
  sid=$(_handoff_slug "$2")
  printf '%s/%s.md' "$(handoff_dir "$1")" "${sid:-unknown}"
}

# Age of a file in seconds (macOS and Linux stat).
handoff_age() {
  echo $(( $(date +%s) - $(stat -f %m "$1" 2>/dev/null || stat -c %Y "$1") ))
}

# Notes of a project younger than the maximum age, newest first, one path per line.
handoff_recent() {
  local dir f
  dir=$(handoff_dir "$1")
  [[ -d "$dir" ]] || return 0
  # shellcheck disable=SC2012
  ls -t "$dir"/*.md 2>/dev/null | while IFS= read -r f; do
    (( $(handoff_age "$f") <= HANDOFF_MAX_AGE )) && printf '%s\n' "$f"
  done
}
