---
name: cost-check
description: Check session cost and context usage before large tasks
invoke: manual
---

# Cost Check

Run `session_status` to check current session metrics before starting large tasks.

## When to use

- Before launching multiple subagents or long research runs
- About every 50 tool calls during active work
- When approaching or exceeding 150K context (hand off or compact)
- Before taking an idle break (finish or /clear to avoid wasted context)

## What to check

1. **Current context**: Stay under 150K when possible; cost rises sharply above that
2. **Compactions**: Each compaction costs tokens; multiple compactions signal it's time to finish or start fresh
3. **Cache hit rate**: Low cache hits mean you're paying for cold context repeatedly
4. **Subagent spend**: Track cumulative subagent costs

## Compact, hand off, or continue

- **Under 100K context, task unfinished**: continue.
- **100K to 150K**: finish the current step, then run `/compact` with a short focus instruction. The PreCompact
  hook writes a handoff note in the background and the next SessionStart loads it.
- **Over 150K, or after 2 compactions**: stop. Run `/aws-monitor:handoff`, then `/clear`. The note is loaded
  into the fresh session automatically, which is cheaper than carrying a large, repeatedly compacted context.
- **Before an idle break over 5 minutes**: the prompt cache expires, so the next call rewrites the full
  context at cache-write prices. Hand off and clear first if the context is large.
- **Auto-compaction too late**: `suggest_config` can propose an `autoCompactWindow` setting based on your
  history, so compaction happens before the expensive range.

## Example

```
Call session_status to see:
- Context: 87K / 200K (peak: 92K)
- Cost: $1.23 session, $0.45 subagents
- Compactions: 0
- Cache hit: 87%
```

## Handoff recommendations

When `session_status` shows context usage above the handoff threshold:

- **60-70% of autoCompactWindow** (e.g., 120K-140K if window is 200K): Consider writing a handoff and compacting soon
- **At or above 150K tokens**: Write a handoff immediately, then either `/clear` or continue to compaction
- **Before an idle break**: If context is above 100K and you'll be idle >5 hours (cache TTL), run `/aws-monitor:handoff` then `/clear` to avoid paying for cold cache on resume

### How to handoff

Two paths:

1. **Manual** (before /clear): Run `/aws-monitor:handoff` skill to write `.claude/handoff.md`, then `/clear` when ready
2. **Automatic** (before compaction): The PreCompact hook writes the handoff automatically when compaction is triggered (manual `/compact` or auto-compact threshold)

After `/clear` or compaction, the handoff loads automatically at SessionStart (clear|compact matcher).

## Cost estimate

Writing a handoff via the PreCompact hook costs about $0.01-0.03 per handoff (Haiku on ~50K tokens of transcript tail). Compaction itself costs input tokens for the summary, typically $0.10-0.50 depending on session size.
