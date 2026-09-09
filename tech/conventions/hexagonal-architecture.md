```json
{
  "title": "Hexagonal Architecture",
  "description": "The general ports-and-adapters pattern, independent of any project-specific vocabulary layered on top of it.",
  "feature": "conventions",
  "project": "",
  "tags": ["reference", "global", "hexagonal-architecture"]
}
```

# Hexagonal Architecture (Ports & Adapters)

Standard reference — the general pattern. See `tech/npd/structure-and-naming.md` for how this is
specifically named and packaged in NPD-style codebases (Meal Mate's backend included).

## The core idea

The application's core logic (the **domain**) is isolated from the outside world — frameworks,
databases, HTTP, external APIs — behind **ports** (interfaces the domain defines for what it needs, or
exposes for what it offers). **Adapters** implement or call those ports, translating between the outer
world's technology and the domain's own model.

```
            ┌───────────────────────────┐
  HTTP  --> │  Web Adapter (inbound)    │ --\
            └───────────────────────────┘    \
                                               v
                                    ┌─────────────────────┐
                                    │   Domain / Core      │
                                    │ (business logic,      \
                                    │  no framework deps)    \
                                    └─────────────────────┘  /
                                               ^             /
            ┌───────────────────────────┐    /
  Postgres <│ Persistence Adapter        │ --/
            │ (outbound)                 │
            └───────────────────────────┘
```

- **Inbound (driving) ports**: what the outside world can ask the domain to do (a use-case interface).
  A web controller is an inbound adapter — it calls into an inbound port.
- **Outbound (driven) ports**: what the domain needs from the outside world (persistence, external
  APIs, messaging). A repository implementation is an outbound adapter — it implements an outbound
  port.
- **Dependency direction always points inward**: adapters depend on the domain via its ports; the
  domain never depends on any adapter or framework type.

## Why it's worth the extra indirection

- The domain is testable without spinning up a database, an HTTP server, or a framework context —
  swap in a fake/in-memory adapter behind the same port.
- Swapping a technology (e.g. Postgres → another store, REST → GraphQL) touches only the adapter layer,
  not the business logic.
- It's a concrete, mechanical way to honor the Dependency Inversion Principle — see
  `tech/conventions/solid-principles.md`.

## What it doesn't prescribe

Hexagonal architecture says *where* responsibility lives (domain vs. adapter, via ports). It says
nothing about naming conventions, package layout details, or how business logic should read internally
— that's the layer a project-specific methodology like NPD adds on top.
