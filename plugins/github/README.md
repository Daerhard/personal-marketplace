```json
{
  "title": "GitHub MCP Plugin",
  "description": "Official GitHub MCP server giving Claude access to GitHub repos, issues, PRs, and the full GitHub API. Managed via the claude-plugins-official marketplace.",
  "feature": "plugins",
  "project": "",
  "tags": ["plugin", "github", "reference", "global"]
}
```

# GitHub MCP Plugin

Official GitHub MCP server by GitHub. Provides full GitHub API access — used for fetching marketplace documents at session start and for any GitHub interaction during sessions.

## Source

Managed by the `claude-plugins-official` marketplace (pre-registered by default in Claude Code).
Plugin ID: `github@claude-plugins-official`

## Enable

Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "github@claude-plugins-official": true
  }
}
```

## Authentication

Uses `GITHUB_PERSONAL_ACCESS_TOKEN` from the `env` block in `~/.claude/settings.json`.

Required token scopes: `repo`, `read:org`

## Used by

- `session-start.md` — fetches marketplace documents at session start
- Any session requiring GitHub repo access
