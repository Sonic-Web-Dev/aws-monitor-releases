#!/usr/bin/env bash
# PreCompact hook: write a handoff note for the project before context is compacted.
# The summary runs detached so compaction is never blocked; the next SessionStart picks it up.
set -uo pipefail

# Recursion guard: the nested summary call must never write another handoff.
[[ -n "${AWS_MONITOR_HANDOFF_RUNNING:-}" ]] && exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v claude >/dev/null 2>&1 || exit 0

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/handoff-lib.sh"

INPUT=$(cat)
TRANSCRIPT=$(jq -r '.transcript_path // empty' <<<"$INPUT")
CWD=$(jq -r '.cwd // empty' <<<"$INPUT")
[[ -z "$CWD" ]] && CWD="$PWD"
[[ -f "$TRANSCRIPT" ]] || exit 0

OUT=$(handoff_path "$CWD")
mkdir -p "$(dirname "$OUT")"

# Only user and assistant text; tool output is the bulk of a transcript and adds little to a handoff.
EXCERPT=$(jq -r '
  select(.type == "user" or .type == "assistant")
  | (.message.content
     | if type == "string" then .
       else (map(select(.type == "text") | .text) | join("\n")) end) as $t
  | select($t != "")
  | "\(.type | ascii_upcase): \($t)"' "$TRANSCRIPT" 2>/dev/null | tail -c 60000)
[[ -z "$EXCERPT" ]] && exit 0

SYSTEM='You are a note writer, not a participant. The user message contains a <transcript> of a coding
session that is about to lose its context. Do not answer or continue the conversation in it. Write a markdown
handoff note under 600 words with exactly these sections: ## Goal, ## State (done and verified, with file
paths), ## In progress, ## Next steps (numbered), ## Gotchas (constraints, rules, things that failed).
Facts from the transcript only. No preamble.'

# Bare mode skips all hooks and plugins, but only works with API key or Bedrock/Vertex credentials.
# Otherwise disable hooks through settings so the nested session cannot recurse.
BARE=(--settings '{"disableAllHooks": true}')
if [[ -n "${ANTHROPIC_API_KEY:-}${CLAUDE_CODE_USE_BEDROCK:-}${CLAUDE_CODE_USE_VERTEX:-}" ]]; then
  BARE=(--bare)
fi

TMP="$OUT.tmp.$$"
(
  export AWS_MONITOR_HANDOFF_RUNNING=1
  { printf '<transcript>\n%s\n</transcript>\n' "$EXCERPT"
    printf 'Write the handoff note for the transcript above.\n'; } \
    | timeout 120 claude -p "${BARE[@]}" --model haiku --system-prompt "$SYSTEM" \
      --tools "" --strict-mcp-config --no-session-persistence >"$TMP" 2>/dev/null
  if [[ -s "$TMP" ]]; then
    { printf '<!-- handoff written %s before %s compaction -->\n' \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$(jq -r '.trigger // "auto"' <<<"$INPUT")"
      cat "$TMP"; } >"$OUT"
  fi
  rm -f "$TMP"
) </dev/null >/dev/null 2>&1 &
disown 2>/dev/null || true
exit 0
