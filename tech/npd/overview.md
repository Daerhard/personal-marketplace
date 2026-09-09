```json
{
  "title": "NPD Overview",
  "description": "What Narrative Pipeline Development is and isn't — the core idea of readable pipelines sharing vocabulary with BDD specs.",
  "feature": "npd",
  "project": "",
  "tags": ["reference", "global", "npd", "kotlin"]
}
```

# Narrative Pipeline Development (NPD)

NPD's core idea: business behavior should be readable directly from the production pipeline, and that
pipeline's steps should share vocabulary with the BDD scenarios that specify them — a reader moves
from code to spec without reconstructing what the code does.

NPD is **not an architecture** — it works alongside hexagonal architecture (see
`tech/conventions/hexagonal-architecture.md`). Architecture answers *where* responsibility belongs;
NPD answers *how* to express it so the behavior is immediately understandable.

It has two flavors: a coroutine/reactive shape and a blocking shape (Spring MVC + Spring Data JPA).
Meal Mate's backend uses the **blocking** shape.

## What NPD is not

NPD is not about putting everything into a chain. If a chain makes behavior *harder* to read, use
`if`/`when` instead — behavioral clarity outranks pipeline syntax.

## The vocabulary at a glance

| Operation | Behavioral role | Type |
|---|---|---|
| `proceedIf { }` | Guard: let the value continue only if the condition holds | `T → T?` |
| `orElseThrow { }` | Resolve absence with a domain exception | `T? → T` |
| `logInfo/Warning/Error { }` | Observe without affecting the value | `T → T` |
| `let { }` | Transform to the next value | `T → R` |
| `also { }` | Observe without affecting the value (standard Kotlin, one-off side effects) | `T → T` |

See `tech/npd/pipeline-vocabulary.md` for the implementation and usage rules,
`tech/npd/structure-and-naming.md` for package layout and naming, `tech/npd/testing-conventions.md`
for the BDD test structure, and `tech/npd/reference-example.md` for a full worked feature.
