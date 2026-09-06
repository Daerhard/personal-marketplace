```json
{
  "title": "Plugin Versioning Guide",
  "description": "Defines the semantic versioning strategy for all marketplace plugins and the marketplace itself. Agents must follow this when making any change.",
  "feature": "tech",
  "project": "",
  "tags": ["reference", "guide", "global", "plugin", "versioning"]
}
```

# Plugin Versioning Guide

All plugins and the marketplace itself use **semantic versioning**: `major.minor.patch`

---

## Version bump rules

| Type | Format | When to use |
|------|--------|-------------|
| **Patch** | `x.x.+1` | Typo fix, wording tweak in existing doc, bug fix in hook or script |
| **Minor** | `x.+1.0` | New document added, new tag, new skill, new hook feature |
| **Major** | `+1.0.0` | Breaking structural change — folder renamed, header schema changed, plugin removed, index format changed |

When in doubt: if existing documents or agents relying on the structure would need to update, it is a **major**. If something is only added, it is a **minor**. If nothing structural changes, it is a **patch**.

---

## What gets versioned

| File | Field |
|------|-------|
| `plugin/.claude-plugin/plugin.json` | `"version"` |
| `.claude-plugin/marketplace.json` | `"version"` + the plugin entry's `"version"` |

Both bump together. When the plugin version changes, update the marketplace.json plugin entry version to match.

---

## Agent workflow — required on every change

Before finishing any change to the marketplace:

1. Determine the change type (patch / minor / major)
2. Bump `version` in `plugin/.claude-plugin/plugin.json`
3. Bump `version` in `.claude-plugin/marketplace.json` (top-level)
4. Update the plugin entry `version` in `.claude-plugin/marketplace.json` to match step 2
5. If a new file was added → add a row to `index/index.md`
6. If a new tag was introduced → add it to `index/tags.md` first

---

## Examples

| Change | Type | Old → New |
|--------|------|-----------|
| Fix typo in `tech/kotlin.md` | patch | `1.2.3` → `1.2.4` |
| Add `projects/gamerio/auth.md` | minor | `1.2.3` → `1.3.0` |
| Add new tag `versioning` to `tags.md` | minor | `1.2.3` → `1.3.0` |
| Rename `tech/` to `technologies/` | major | `1.2.3` → `2.0.0` |
| Change header schema (add/remove field) | major | `1.2.3` → `2.0.0` |
