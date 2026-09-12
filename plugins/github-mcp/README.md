```json
{
  "title": "GitHub MCP Plugin",
  "description": "Official GitHub MCP server (Docker) giving Claude access to GitHub repos, issues, PRs, and the full GitHub API. Works with a standard PAT, no Copilot required.",
  "feature": "plugins",
  "project": "",
  "tags": ["plugin", "reference", "global"]
}
```

# GitHub MCP Plugin

Official GitHub MCP server by GitHub, running via Docker (`ghcr.io/github/github-mcp-server`). Used for fetching marketplace documents at session start and any GitHub interaction during sessions.

## Setup

Add to `~/.claude/.mcp.json` (or let the marketplace install it via `plugins/github-mcp/.mcp.json`):

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

**This is the step most likely to be missing.** `docker run -e GITHUB_PERSONAL_ACCESS_TOKEN` (no `=value`) only *passes through* the variable if it is already set in the environment Docker is launched from — it does not set it itself. If that variable isn't actually exported wherever the container gets started, the official image silently falls back to interactive OAuth device-code login instead of erroring, which looks like "it's just asking to authorize again" every session.

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
| Repeated "visit github.com/login/device" prompts, different code each time | `GITHUB_PERSONAL_ACCESS_TOKEN` not actually set in the launching environment, so it falls back to OAuth every fresh container | Set the token in `~/.claude/settings.json`'s `env` block (see Authentication above) |
| `401 Unauthorized` | Token missing or not passed | Confirm `GITHUB_PERSONAL_ACCESS_TOKEN` is in `~/.claude/settings.json` env block |
| `403 Forbidden` | Token lacks required scopes | Regenerate PAT with `repo` and `read:org` scopes |
| Session-start fetch returns nothing | MCP not connected in session | Restart Claude Code — Docker must be running before session starts |
| `github@claude-plugins-official` errors | Wrong plugin — Copilot endpoint | Remove it, use this Docker setup instead |

### Verify it works

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | \
  docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
```

Should return a JSON list of available GitHub tools without any login prompt.

### Diagnostics

```bash
# Check Docker is running
docker info

# Check image is present
docker images | grep github-mcp-server

# Test token is set in the env Docker launches from
echo $GITHUB_PERSONAL_ACCESS_TOKEN | cut -c1-10

# Pull latest image
docker pull ghcr.io/github/github-mcp-server
```

## Note

Do NOT use `github@claude-plugins-official` — that plugin uses GitHub Copilot's HTTP MCP endpoint and requires a Copilot token. Use this Docker setup instead.
