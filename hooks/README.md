# Hooks

Claude Code hook scripts organized by event type.

## Registration

Hooks are registered via the plugin system in `.claude-plugin/plugin/hooks/hooks.json`.
The plugin is loaded globally through `~/.claude/settings.json` (`personal-context@daerhard`).

## Active hooks

### UserPromptSubmit — session context loader

Fires on the **first message of every session only** (subsequent messages skipped via session lock in `/tmp`).

Tells Claude to fetch `session-start.md` from `Daerhard/personal-marketplace` via GitHub MCP and load relevant context before responding.

**Requires:** GitHub MCP server configured (see `plugins/github/README.md`)
