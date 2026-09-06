```json
{
  "title": "Plugin Error Handling Standard",
  "description": "Defines how Claude reports plugin failures and what every plugin must document about its failure modes. Required reading before adding a new plugin.",
  "feature": "tech",
  "project": "",
  "tags": ["reference", "guide", "global", "plugin", "troubleshooting"]
}
```

# Plugin Error Handling Standard

Every plugin in this marketplace must document its failure modes. Claude must never fail silently — any plugin or tool failure must be reported explicitly before continuing.

---

## Claude's required behaviour on failure

When a plugin, MCP server, hook, or tool fails, Claude must report:

```
Plugin: <plugin-name>
Status: FAILED
Error: <exact error message or signal>
Likely cause: <one-line diagnosis>
Fix: <concrete next step>
```

If multiple plugins fail, report each one. Only after reporting all failures should Claude continue with the user's request — and only if the failure does not block the task.

**Never:**
- Skip reporting a failed tool silently
- Assume a missing result means "no data" without checking for an error
- Proceed as if a failed plugin succeeded

---

## What every plugin document must include

Each `plugins/<name>/README.md` must have a `## Troubleshooting` section with:

1. **Known failure modes** — table of error signal → likely cause → fix
2. **How to verify the plugin is working** — a simple manual test
3. **Diagnostic commands** — shell commands that help isolate the problem

### Template

```markdown
## Troubleshooting

| Signal | Likely cause | Fix |
|--------|-------------|-----|
| `connection refused` | Service not running | Start the service |
| `unauthorized` | Token missing or wrong scopes | Check token + scopes |
| `command not found` | Dependency not installed | Install dependency |

### Verify it works

<one-liner to confirm the plugin is operational>

### Diagnostics

<shell commands to run when something is wrong>
```

---

## Common failure patterns across plugins

| Pattern | Signal | Cause |
|---------|--------|-------|
| Docker MCP server | Container exits immediately | Docker not running, image not pulled, token not passed |
| HTTP MCP server | `401` / `403` | Wrong token or missing scopes |
| Hook script | Non-zero exit, no output | Script not executable, dependency missing |
| npx MCP server | `command not found` | Node/npm not installed or not on PATH |
| Session-start fetch | Silent empty result | MCP not connected, repo private, token missing |

---

## Adding a new plugin — checklist

Before committing a new plugin to the marketplace:

- [ ] `plugins/<name>/README.md` exists with a `## Troubleshooting` section
- [ ] Known failure modes are documented (minimum 3)
- [ ] A verify command is included
- [ ] Diagnostic commands are included
- [ ] Bump marketplace version (minor) per `tech/versioning.md`
