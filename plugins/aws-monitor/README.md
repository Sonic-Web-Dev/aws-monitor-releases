# AWS Monitor Plugin for Claude Code

Track AWS costs and optimize Claude Code session efficiency with automatic lessons from your session history.

## Features

- **SessionStart hook**: Automatically loads cost optimization lessons at the start of each session (under 300 tokens)
- **MCP server integration**: Access 8 tools for cost tracking and configuration optimization
- **Skills**: Practical workflows for checking costs, optimizing setup, and reviewing trends

## Installation

### From marketplace (recommended)

```sh
claude plugin marketplace add Sonic-Web-Dev/aws-monitor-releases
claude plugin install aws-monitor@sonic-web-dev
```

### Requirements

The plugin requires the AWS Monitor app installed at `/Applications/AWS Monitor.app`. The app includes the MCP server binary and keeps it updated automatically.

Download the latest release: [AWS Monitor releases](https://github.com/Sonic-Web-Dev/aws-monitor-releases/releases)

If the app is not installed, the SessionStart hook will print a one-line hint and exit gracefully without breaking your session.

## Available Tools

The MCP server provides these tools:

| Tool | Purpose |
| --- | --- |
| `session_status` | Current session context, cost, compactions, cache hit rate |
| `waste_report` | Ranked waste: cold cache rewrites, 150K+ spend, subagent costs |
| `context_hogs` | Largest tool results by tool, MCP server, file, command |
| `mcp_usage` | Configured MCP servers vs actually called (find unused servers) |
| `lessons` | Distilled rules from session history (under 300 tokens) |
| `suggest_config` | Proposed changes to settings.json, CLAUDE.md, agent frontmatter (now includes autoCompactWindow suggestion based on 30-day history) |
| `apply_suggestion` | Apply one suggestion with timestamped backup (requires confirm=true) |
| `bedrock_spend` | Bedrock and AWS spend for configured profiles |

## Skills

Run these skills with `/aws-monitor:<skill-name>`:

- **`/aws-monitor:cost-check`**: Check session metrics before large tasks, with handoff recommendations
- **`/aws-monitor:handoff`**: Manually write a handoff note before /clear (PreCompact hook covers compaction automatically)
- **`/aws-monitor:optimize-setup`**: Find and apply configuration improvements
- **`/aws-monitor:weekly-review`**: Compare week-over-week spend and measure impact

## How it works

### Session lifecycle

1. **At session start** (startup|resume): The hook calls the `lessons` tool and injects distilled optimization rules into your context
2. **During work**: Use the skills to check costs and find optimization opportunities
3. **Before compaction**: The PreCompact hook writes a handoff note in the background with Haiku to `~/.claude/aws-monitor/handoffs/<project>.md` (outside the repo). After `/clear` or compaction, notes under 24 hours old are loaded automatically (about 1000 tokens)
4. **After /clear or compaction**: The SessionStart hook loads the handoff note if it's younger than 24 hours
5. **Between sessions**: The app analyzes your transcripts and updates lessons.json with new patterns

### Handoff workflow

- **Automatic before compaction**: PreCompact hook runs in background (60s timeout, recursion guard), writes handoff, always exits 0
- **Manual before /clear**: Run `/aws-monitor:handoff` skill to write a note, then `/clear`
- **Auto-loaded**: SessionStart (clear|compact) loads handoff if <24h old, plus lessons
- **Cost**: ~$0.01-0.03 per automatic handoff (Haiku on ~50K tokens transcript tail)

### autoCompactWindow suggestion

The `suggest_config` tool now analyzes your 30-day session history (peak context, compaction frequency, cost above 150K) and suggests an optimal autoCompactWindow setting:
- **150000**: suggested when average peak context exceeds 140K, sessions compact repeatedly, or more than $20 was spent above 150K in 30 days. Compacting at 150K keeps sessions out of the most expensive range.

## Uninstall

To remove the plugin:

```sh
claude plugin disable aws-monitor
claude plugin uninstall aws-monitor
```

The AWS Monitor app and its MCP server can still be used standalone even without the plugin.
