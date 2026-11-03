---
name: optimize-setup
description: Find and apply configuration improvements to reduce AWS costs
invoke: manual
---

# Optimize Setup

Analyze Claude Code configuration and suggest cost-saving changes.

## Workflow

1. **Run diagnostics** (call all these tools):
   - `waste_report`: Find cold cache rewrites, 150K+ spend, subagent costs
   - `context_hogs`: Identify largest tool results by tool, MCP server, file, command
   - `mcp_usage`: List configured vs actually-used MCP servers

2. **Get suggestions**: Call `suggest_config` for specific changes to:
   - settings.json (MCP server config, permissions)
   - CLAUDE.md (token discipline, subagent contracts)
   - Agent frontmatter (model selection)

3. **Review and apply**: Present each suggestion with its dollar impact. Apply ONE at a time using `apply_suggestion` with `confirm=true` (makes a timestamped backup first).

## Key findings to look for

- Unused MCP servers costing tokens per call
- Tools with large results that could use summary modes
- Subagent configurations using expensive models unnecessarily
- Missing token discipline rules in CLAUDE.md

## Safety

Always get explicit user confirmation before calling `apply_suggestion`. The tool requires `confirm=true` and creates backups, but changes are immediate.
