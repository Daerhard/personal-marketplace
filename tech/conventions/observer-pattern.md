```json
{
  "title": "Observer Pattern",
  "description": "Standard reference for the Observer design pattern.",
  "feature": "conventions",
  "project": "",
  "tags": ["reference", "global", "observer-pattern"]
}
```

# Observer Pattern

Standard reference — common software-engineering knowledge, kept concise.

A subject maintains a list of dependents (observers) and notifies them automatically of state changes,
without the subject needing to know what the observers actually do with that notification. Decouples
"something happened" from "here's what to do about it."

## Where this shows up in practice

- **Spring application events** (`ApplicationEventPublisher` + `@EventListener`) are the idiomatic
  Spring Boot expression of this pattern — a domain event gets published, and one or more listeners
  react, without the publisher importing or depending on the listeners.
- **Frontend state subscriptions** (React's `useEffect` reacting to a value change, or a store's
  subscribe/notify mechanism) are the same shape on the client side.
- **Kotlin `Flow`/`StateFlow`** (used on the Android side per `architecture-tech-stack.md`) is a
  structured, typed version of the same idea — a producer emits, collectors react.

## When to reach for it

Use it when multiple, potentially-changing parts of the system need to react to one state change
(e.g. "a user registered" triggering both a welcome email and an analytics event later). Don't reach
for a full event/observer mechanism for a single, fixed caller — a direct function call is simpler and
easier to trace.
