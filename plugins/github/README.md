```json
{
  "title": "GitHub MCP Plugin",
  "description": "Official GitHub MCP server (Docker) giving Claude access to GitHub repos, issues, PRs, and the full GitHub API. Works with a standard PAT, no Copilot required.",
  "feature": "plugins",
  "project": "",
  "tags": ["plugin", "github", "reference", "global"]
}
```

# GitHub MCP Plugin

Official GitHub MCP server by GitHub, running via Docker (`ghcr.io/github/github-mcp-server`). Used for fetching marketplace documents at session start and any GitHub interaction during sessions.

## Setup

Add to `~/.claude/.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ]
    }
  }
}
```

## Authentication

Set `GITHUB_PERSONAL_ACCESS_TOKEN` in the `env` block of `~/.claude/settings.json`.

Required token scopes: `repo`, `read:org`

No GitHub Copilot subscription required.

## Used by

- `session-start.md` — fetches marketplace documents at session start
- Any session requiring GitHub repo access

## Troubleshooting

| Signal | Likely cause | Fix |
|--------|-------------|-----|
| Container exits immediately / no output | Docker not running | Start Docker Desktop |
| `Unable to find image` | Image not pulled yet | Run `docker pull ghcr.io/github/github-mcp-server` |
| `401 Unauthorized` | Token missing or not passed | Confirm `GITHUB_PERSONAL_ACCESS_TOKEN` is in `~/.claude/settings.json` env block |
| `403 Forbidden` | Token lacks required scopes | Regenerate PAT with `repo` and `read:org` scopes |
| Session-start fetch returns nothing | MCP not connected in session | Restart Claude Code — Docker must be running before session starts |
| `github@claude-plugins-official` errors | Wrong plugin — Copilot endpoint | Remove it, use this Docker setup instead |

### Verify it works

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | \
  docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
```

Should return a JSON list of available GitHub tools.

### Diagnostics

```bash
# Check Docker is running
docker info

# Check image is present
docker images | grep github-mcp-server

# Test token is set
echo $GITHUB_PERSONAL_ACCESS_TOKEN | cut -c1-10

# Pull latest image
docker pull ghcr.io/github/github-mcp-server
```

## Note

Do NOT use `github@claude-plugins-official` — that plugin uses GitHub Copilot's HTTP MCP endpoint and requires a Copilot token. Use this Docker setup instead.
