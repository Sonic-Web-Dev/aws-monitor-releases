---
name: handoff
description: Write a handoff note before /clear so the next session can continue where this one stopped
---

# Handoff

No hook fires before `/clear`, so write the note yourself. The PreCompact hook covers compaction automatically.

## Steps

1. Find the target path: `~/.claude/aws-monitor/handoffs/<slug>/<session id>.md`. Each chat has its own
   note, so several chats in one project never overwrite each other.
   - `<slug>` is the absolute project directory with every character outside `A-Za-z0-9._-` replaced by
     `-` and leading dashes removed (for example `/Users/me/app` becomes `Users-me-app`).
   - The session id of this chat: run `echo "$CLAUDE_CODE_SESSION_ID"` with the Bash tool. It is the same
     id the hooks receive as `session_id` and the name of this chat's transcript file. Cross-check: it
     should equal `${CLAUDE_SESSION_ID}`. Never guess it and never take the newest transcript file,
     which may belong to another chat.
   - Create the directory if needed. Never write to or edit another session's note in that directory.
2. Write the note, under 600 words. The first line is `<!-- handoff written by session <session id> -->`,
   followed by exactly these sections:
   - `## Goal`: one or two sentences.
   - `## State`: what is done and verified, with file paths, commits, and release versions.
   - `## In progress`: unfinished work, including running background agents and their output paths.
   - `## Next steps`: numbered, concrete, in order.
   - `## Gotchas`: constraints, user rules, and approaches that failed.
3. State facts only. Never mark something as verified unless it was checked in this session.
4. Tell the user the note is saved and that `/clear` will load it automatically (notes older than 24 hours are ignored).
   After `/clear` the newest note of the project is loaded, so the user should clear right after saving.
