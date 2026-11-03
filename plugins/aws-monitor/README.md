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
| `suggest_config` | Proposed changes to settings.json, CLAUDE.md, agent frontmatter |
| `apply_suggestion` | Apply one suggestion with timestamped backup (requires confirm=true) |
| `bedrock_spend` | Bedrock and AWS spend for configured profiles |

## Skills

Run these skills with `/aws-monitor:<skill-name>`:

- **`/aws-monitor:cost-check`**: Check session metrics before large tasks
- **`/aws-monitor:optimize-setup`**: Find and apply configuration improvements
- **`/aws-monitor:weekly-review`**: Compare week-over-week spend and measure impact

## How it works

1. **At session start**: The hook calls the `lessons` tool and injects distilled optimization rules into your context
2. **During work**: Use the skills to check costs and find optimization opportunities
3. **Between sessions**: The app analyzes your transcripts and updates lessons.json with new patterns

## Uninstall

To remove the plugin:

```sh
claude plugin disable aws-monitor
claude plugin uninstall aws-monitor
```

The AWS Monitor app and its MCP server can still be used standalone even without the plugin.
