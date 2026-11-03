#!/usr/bin/env bash
# SessionStart hook: inject cost optimization lessons from session history
set -euo pipefail

MCP_BIN="/Applications/AWS Monitor.app/Contents/MacOS/aws-monitor-mcp"

if [[ ! -x "$MCP_BIN" ]]; then
  echo "AWS Monitor app not installed. Install from: https://github.com/Sonic-Web-Dev/aws-monitor-releases/releases"
  exit 0
fi

PROJECT_DIR="${PWD}"
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | "$MCP_BIN" >/dev/null 2>&1
LESSONS=$(echo "{\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"tools/call\",\"params\":{\"name\":\"lessons\",\"arguments\":{\"project\":\"$PROJECT_DIR\"}}}" | "$MCP_BIN" 2>/dev/null | tail -1 | jq -r '.result.content[0].text // empty')

if [[ -n "$LESSONS" ]]; then
  echo "$LESSONS"
fi
