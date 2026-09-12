#!/usr/bin/env bash
# Wrapper around the github-mcp-server container.
#
# Why this exists: `docker run -e GITHUB_PERSONAL_ACCESS_TOKEN ...` only forwards the variable if
# it's already set in the environment this script runs in — it does not supply a value. If the
# token is missing, the official image does NOT error — it silently falls back to an interactive
# OAuth device-code flow instead, which is invisible to whoever is waiting on the other end of the
# MCP connection and looks like "it keeps asking to re-authenticate" for no obvious reason.
#
# This wrapper fails loudly and immediately instead, and adds one fallback so a single missing env
# var can't silently break the whole thing again.
set -euo pipefail

# Fallback source: a local token file, in case the env var didn't propagate from
# ~/.claude/settings.json for some reason (that has happened before).
TOKEN_FILE="${GITHUB_MCP_TOKEN_FILE:-$HOME/.config/github-mcp/token}"

if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ] && [ -f "$TOKEN_FILE" ]; then
  GITHUB_PERSONAL_ACCESS_TOKEN="$(cat "$TOKEN_FILE")"
  export GITHUB_PERSONAL_ACCESS_TOKEN
fi

if [ -z "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_PERSONAL_ACCESS_TOKEN is not set, and no token file found at $TOKEN_FILE." >&2
  echo "" >&2
  echo "Fix one of:" >&2
  echo "  1. Set GITHUB_PERSONAL_ACCESS_TOKEN in the \"env\" block of ~/.claude/settings.json (preferred)." >&2
  echo "  2. Write the token (and nothing else) to $TOKEN_FILE." >&2
  echo "" >&2
  echo "See plugins/github-mcp/README.md for full setup and troubleshooting." >&2
  exit 1
fi

exec docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
