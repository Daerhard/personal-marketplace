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

The plugin's `.mcp.json` runs the container through `run.sh` (in this same folder) instead of calling
`docker` directly — the script **fails immediately with a clear error** if no PAT is available,
rather than silently falling back to an interactive OAuth device-code login the way the bare image
does. That silent fallback is what caused repeated "visit github.com/login/device" prompts in the
past, with no indication of why.

```json
{
  "github": {
    "type": "stdio",
    "command": "bash",
    "args": ["${CLAUDE_PLUGIN_ROOT}/run.sh"]
  }
}
```

If installing the server manually outside the plugin system, point `~/.claude/.mcp.json` at the same
script, or replicate its logic directly:

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

(Without `run.sh`'s guard, this form is exactly what silently falls back to OAuth if the token isn't set — avoid it if possible.)

## Authentication

**Primary:** set `GITHUB_PERSONAL_ACCESS_TOKEN` in the `env` block of `~/.claude/settings.json`.

**Fallback:** `run.sh` also checks `~/.config/github-mcp/token` (a plain file containing just the
token) if the env var isn't set. This exists so a single misconfigured/lost env var can't silently
regress back to the OAuth loop — keep at least one of the two set. Override the fallback path with
the `GITHUB_MCP_TOKEN_FILE` env var if needed.

Required token scopes: `repo`, `read:org`

No GitHub Copilot subscription required.

**Token expiry:** if this is a fine-grained or expiring classic PAT, its expiration date is a future
failure point — when it lapses, `run.sh` will fail loudly (good), but that's still an interruption.
Either use a non-expiring classic PAT scoped tightly to `repo`/`read:org`, or set a reminder to
rotate it before expiry.

## Used by

- `session-start.md` — fetches marketplace documents at session start
- Any session requiring GitHub repo access

## Troubleshooting

| Signal | Likely cause | Fix |
|--------|-------------|-----|
| Container exits immediately / no output | Docker not running | Start Docker Desktop |
| `Unable to find image` | Image not pulled yet | Run `docker pull ghcr.io/github/github-mcp-server` |
| Clear `ERROR: GITHUB_PERSONAL_ACCESS_TOKEN is not set` message | Neither the env var nor the fallback token file is set | Set one of the two per Authentication above |
| "visit github.com/login/device" prompt at all | You're not running `run.sh` — something is still invoking the bare `docker run` form without the guard | Confirm `.mcp.json` points at `run.sh`, not `docker` directly |
| `401 Unauthorized` | Token invalid, revoked, or expired | Regenerate the PAT |
| `403 Forbidden` | Token lacks required scopes | Regenerate PAT with `repo` and `read:org` scopes |
| Session-start fetch returns nothing | MCP not connected in session | Restart Claude Code — Docker must be running before session starts |
| `github@claude-plugins-official` errors | Wrong plugin — Copilot endpoint | Remove it, use this Docker setup instead |

### Verify it works

```bash
GITHUB_PERSONAL_ACCESS_TOKEN=your_token_here \
  echo '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | \
  bash run.sh
```

Should return a JSON list of available GitHub tools with no login prompt. If the token is missing,
you'll get the explicit error message instead of a hang or a device-code prompt.

### Diagnostics

```bash
# Check Docker is running
docker info

# Check image is present
docker images | grep github-mcp-server

# Confirm the primary source is set
echo $GITHUB_PERSONAL_ACCESS_TOKEN | cut -c1-10

# Confirm the fallback source, if used
cat ~/.config/github-mcp/token 2>/dev/null | cut -c1-10

# Pull latest image
docker pull ghcr.io/github/github-mcp-server
```

## Note

Do NOT use `github@claude-plugins-official` — that plugin uses GitHub Copilot's HTTP MCP endpoint and requires a Copilot token. Use this Docker setup instead.
