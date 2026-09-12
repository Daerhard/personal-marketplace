```json
{
  "title": "TypeScript Conventions",
  "description": "Baseline TS conventions — currently thin, drafted from what Milestone 1 already implies, needs fleshing out.",
  "feature": "conventions",
  "project": "",
  "tags": ["reference", "global", "typescript"]
}
```

# TypeScript Conventions

> Living doc — this is a starting baseline drafted from what Meal Mate's Milestone 1 frontend already
> implies, not a definitive style guide yet. Flesh out as real conventions solidify across projects.

## Current baseline (observed)

- `strict` mode on (Vite's TS template default) — keep it on, don't loosen it to unblock a build.
- Prefer explicit function return types on exported functions/hooks; inference is fine for local
  variables.
- API response shapes get their own `interface`/`type`, colocated with the client function that
  returns them (e.g. `authClient.ts` defines its own response types) rather than a shared
  do-everything `types.ts`.
- Avoid `any`; prefer `unknown` + narrowing when a type genuinely can't be known upfront.

## Open questions to settle as the codebase grows

- ESLint/Prettier ruleset — not yet formalized beyond Vite's scaffolded defaults.
- Naming convention for API client error types (currently ad hoc per Milestone 1).
- Whether to introduce a shared `/shared` DTO package between the Android app and web frontend (raised
  in `architecture-tech-stack.md`, not yet decided).
