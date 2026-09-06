```json
{
  "title": "string — max ~5 words, unique identifier for this document",
  "description": "string — 1 to 2 sentences, no more",
  "feature": "string — see feature rules below",
  "project": "string — project name or empty string",
  "tags": ["string — max 5 tags, see tags.md"]
}
```

## Field Rules

**title**
Short and unique. Enough to identify the doc without reading it.

**description**
Maximum 2 sentences. What this document is and when to use it.

**feature**
Describes the functional area of the document.
- For `skills/`, `tech/`, `plugins/`, `hooks/` — use the folder name as the feature value.
- For `projects/<name>/` — use a functional name describing what the doc covers (e.g. `auth service`, `login`, `user-configuration`, `setup`).

**project**
- For any file inside `projects/<name>/` — use the project folder name (e.g. `meal-mate`, `check-mate`).
- For all other folders — use an empty string `""`.

**tags**
- Maximum 5 tags per document.
- Always check `index/tags.md` before writing tags.
- Reuse existing tags wherever possible.
- If no existing tag fits, add the new tag to `tags.md` with a one-line description first, then use it.
- For project documents create very specific tags over generic ones
- Find a good mix of business and technical tags always based on the document. For business more business related tags for tech more tech related tags.

## Example Headers

Document in `skills/`:
```json
{
  "title": "Git Commit Helper",
  "description": "Generates conventional commit messages from staged changes. Use before committing.",
  "feature": "skills",
  "project": "",
  "tags": ["git", "skill", "global"]
}
```

Document in `projects/meal-mate/`:
```json
{
  "title": "Auth Flow",
  "description": "Describes the JWT-based authentication flow for Gamerio. Covers login, refresh, and logout.",
  "feature": "auth",
  "project": "meal-mate",
  "tags": ["jwt", "backend", "auth", "project"]
}
```

## Workflow for New Documents

1. Read `index/tags.md` — find existing tags to reuse.
2. Write the header at the top of the new file inside a fenced `json` block.
3. If you introduced a new tag, append it to `index/tags.md` under the correct category.
4. Add a row for the new file to the correct section in `index/index.md`.
