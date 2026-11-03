#!/usr/bin/env bash
# Shared helpers for the handoff hooks. Handoffs live outside the repo so they never pollute git.
HANDOFF_ROOT="${AWS_MONITOR_HANDOFF_DIR:-$HOME/.claude/aws-monitor/handoffs}"

# Stable per-project file name derived from the project directory.
handoff_path() {
  local dir="$1"
  local slug
  slug=$(printf '%s' "$dir" | sed 's#[^A-Za-z0-9._-]#-#g; s#^-*##')
  printf '%s/%s.md' "$HANDOFF_ROOT" "${slug:-root}"
}
