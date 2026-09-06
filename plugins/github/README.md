```json
{
  "title": "GitHub MCP Plugin",
  "description": "Official GitHub MCP server giving Claude access to the marketplace repo and any other GitHub repos. Required for session-start context loading.",
  "feature": "plugins",
  "project": "",
  "tags": ["plugin", "github", "reference", "global"]
}
```

# GitHub MCP Plugin

Official GitHub MCP server. Provides Claude with GitHub API access — used to fetch marketplace documents at session start and throughout sessions.

## Required for

- Session start context loading (`hooks/user-prompt-submit/marketplace-context.sh` + `session-start.md`)
- Reading and updating marketplace files without a local clone

## Setup

Add to your Claude Code MCP config (`~/.claude/settings.json` or project `.claude/settings.json`):

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

Required token scopes: `repo`, `read:org`

## Target repo

`Daerhard/personal-marketplace`
