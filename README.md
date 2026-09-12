# Personal Marketplace

A structured, GitHub-hosted knowledge base that Claude sessions load context from — project docs, tech
conventions, and coding methodology — kept up to date across every session and surface instead of
re-explained from scratch each time.

## How it works

A hook (`plugins/personal-context/hooks/hooks.json`) fires on the first message of every session and
tells Claude to fetch `session-start.md` from this repo via the GitHub MCP server. That file walks
Claude through:

1. Fetching `index/index.md`, the master list of every document here.
2. Matching index rows against the current prompt (by project name, feature, or tag).
3. Fetching whatever matched, and reporting what got loaded before addressing the actual request.

See `session-start.md` for the exact matching rules, and `hooks/README.md` for how the hook itself is
wired up.

## Structure

```
index/          # navigation: index.md (all docs), tags.md (tag taxonomy), header-schema.md (doc header rules)
plugins/        # Claude Code plugins — one subfolder per plugin (personal-context, github-mcp)
hooks/          # documentation for hooks registered by plugins/personal-context
skills/         # reusable Claude skills (currently empty)
tech/           # general, project-agnostic engineering knowledge
  npd/          #   Narrative Pipeline Development — the pipeline-vocabulary coding methodology
  conventions/  #   Kotlin, TypeScript, React, SOLID, Observer pattern, Hexagonal architecture
projects/       # per-project documents, one `## projects / <name>` section in the index per project
  meal-mate/
    concept/    #   product concept, architecture decisions, milestone specs and status
session-start.md  # entry point read at the start of every session
```

## Adding a new document

1. Read `index/tags.md` — reuse existing tags wherever possible; add a new one there first if nothing fits.
2. Write the doc with a fenced ```json header block at the top, following `index/header-schema.md`.
3. Add a row to the matching section of `index/index.md`.
4. Bump versions per `tech/versioning.md` (new document → minor; folder rename or header schema change → major) in `plugins/*/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.

## Plugins

See `plugins/README.md` for the plugin layout, and each plugin's own README for setup:

- `plugins/personal-context/` — the session-start hook described above
- `plugins/github-mcp/` — the GitHub MCP server (Docker, PAT-based) this whole thing runs on
