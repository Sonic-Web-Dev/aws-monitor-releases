---
name: lean-workflow
description: Route multi-step work so sessions stay cheap - when to clear, how to use subagents, plan/execute with one reviewer per phase, handoff before /clear
---

# Lean workflow

Every API call resends the whole context. Cost grows with context size and with the number of agents
that each carry their own copy. Use these rules to keep both small.

## 1. Pick the shape of the task

- **A few tool calls, target known**: do it inline. No subagent.
- **Wide search across many files, only the conclusion matters**: one Explore or general-purpose subagent.
- **Independent pieces of work**: one subagent per piece, all spawned in a single message.
- **Multi-phase feature or refactor**: plan first (section 3).

## 2. Subagent rules

- One task per agent. Never send a finished agent new work; spawn a fresh one and pass the path to the
  previous output.
- The agent writes its full output to a file and returns only the path, a summary of at most 30 lines,
  and file:line references.
- Workers run on Sonnet. Do not name Opus in a spawn prompt; it overrides the default.
- Spawn agents early, while the lead session is small. Do not fork a session above 150K context.
- No agent teams unless the user asks for parallel review or research. Shut teammates down when done.
- Before editing after a `/clear`, run ListAgents and `git stash list`: background agents survive.

## 3. Plan and execute

With claude-mem installed:

1. `/claude-mem:make-plan` to write a phased plan.
2. `/claude-mem:do` to execute it, with ONE reviewer subagent per phase that checks verification,
   anti-patterns and quality together.
3. The lead commits after each phase. Do not push per phase.

Without claude-mem: write the plan to a markdown file (phases, files touched, how each phase is
verified), then execute phase by phase with the same one-reviewer and commit-per-phase rules.

## 4. When to clear

Clear at task boundaries, and also when any of these hold:

- the session has compacted twice, or context is near 150K;
- a long multi-tool run is about to start late in a session (start it fresh instead);
- you are about to step away for more than 5 minutes with a large context (the cache expires).

Before clearing:

1. Commit the work.
2. Run the `handoff` skill to write the note (Goal, State, In progress, Next steps, Gotchas).
3. Tell the user to run `/clear`; the note loads automatically in the next session.

## 5. Small habits

- Read a file once. Locate with grep -n, then read a range of 80 lines or fewer.
- Cap output: `| tail -40` for test runs, `git diff --stat` before a full diff.
- Wait for background work with run_in_background and its notification, never a sleep loop.
- Use `cost-check` or the `session_status` tool to see what the session costs so far.
