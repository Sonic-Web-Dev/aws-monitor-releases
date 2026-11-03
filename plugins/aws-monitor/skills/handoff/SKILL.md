---
name: handoff
description: Write a handoff note before /clear so the next session can continue where this one stopped
---

# Handoff

No hook fires before `/clear`, so write the note yourself. The PreCompact hook covers compaction automatically.

## Steps

1. Find the target path: `~/.claude/aws-monitor/handoffs/<slug>.md`, where `<slug>` is the absolute project
   directory with every character outside `A-Za-z0-9._-` replaced by `-` and leading dashes removed
   (for example `/Users/me/app` becomes `Users-me-app.md`). Create the directory if needed.
2. Write the note, under 600 words, with exactly these sections:
   - `## Goal`: one or two sentences.
   - `## State`: what is done and verified, with file paths, commits, and release versions.
   - `## In progress`: unfinished work, including running background agents and their output paths.
   - `## Next steps`: numbered, concrete, in order.
   - `## Gotchas`: constraints, user rules, and approaches that failed.
3. State facts only. Never mark something as verified unless it was checked in this session.
4. Tell the user the note is saved and that `/clear` will load it automatically (notes older than 24 hours are ignored).
