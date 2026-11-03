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

## Example

```
Call session_status to see:
- Context: 87K / 200K (peak: 92K)
- Cost: $1.23 session, $0.45 subagents
- Compactions: 0
- Cache hit: 87%
```
