```json
{
  "title": "Kotlin Style Conventions",
  "description": "General Kotlin formatting and idiom rules — the parts that aren't NPD-specific.",
  "feature": "conventions",
  "project": "",
  "tags": ["reference", "global", "kotlin"]
}
```

# Kotlin Style Conventions

Baseline Kotlin style, independent of any one project's architecture or the NPD vocabulary
(`tech/npd/`) layered on top of it.

## Formatting

- **4-space indentation**, no tabs.
- **Trailing commas** on multi-line constructor parameter lists / data class properties.
- No wildcard imports; imports are a flat alphabetical list, with aliasing (`as DomainUser`) used in
  place of grouping when the same simple name is needed from two packages in one file.
- No redundant `public` modifiers — rely on Kotlin's default visibility.

## General idiom notes

- Prefer `data class` for models with no behavior.
- Prefer immutable (`val`) properties; reach for `var` only when mutation is the actual point.
- Prefer expression-bodied functions (`fun foo() = ...`) for single-expression logic.
- Null handling: prefer `?:`, safe calls (`?.`), and `requireNotNull`/`checkNotNull` with a message
  over silent `!!`.
