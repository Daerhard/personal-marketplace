```json
{
  "title": "Session Start Guide",
  "description": "Entry point for every new session. Explains how to load context from the marketplace before responding.",
  "feature": "guide",
  "project": "",
  "tags": ["reference", "global", "guide"]
}
```

# Session Start Guide

This is the personal marketplace — a structured knowledge base for Claude sessions.
It lives on GitHub at `Daerhard/personal-marketplace`.

The GitHub MCP server is available. Use it to fetch files from this repo throughout the session.

---

## What to do at session start

Follow these steps **before responding to the user's first message**.

### 1. Fetch the index

Use the GitHub MCP server to fetch `index/index.md` from `Daerhard/personal-marketplace`.

### 2. Match against the user's prompt

Parse every table row in the index. For each row check — case-insensitive — whether any of the following appear in the user's prompt:

- The project name (from the section header, e.g. `meal-mate`, `gamerio`)
- The feature value
- Any tag
- Any significant word from the title

Rows that match are candidates. Group them:
- **Project docs** — rows under a `## projects / <name>` section
- **Tech docs** — rows under `## tech`
- **General docs** — rows under `## skills`, `## plugins`, `## hooks`

### 3. Fetch matched documents

For every matched row, fetch the full file content from `Daerhard/personal-marketplace` via GitHub MCP.

### 4. Report to the user

Open your response with a compact summary of what was loaded **before** addressing the user's request.

**Format when matches are found:**
```
Loaded context:
- meal-mate / 3 docs: Auth Flow, Backend Setup, API Conventions
- tech / 2 docs: Kotlin Guide, Spring Boot Patterns
- general / 1 doc: Git Workflow
```

**Format when nothing matches:**
```
Nothing found in the marketplace for this task. Should I proceed without additional context?
```

---

## Reference files

| File | Purpose |
|------|---------|
| `index/index.md` | Master list of all marketplace documents |
| `index/tags.md` | All available tags with descriptions |
| `index/header-schema.md` | Rules for document headers |
