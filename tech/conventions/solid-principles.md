```json
{
  "title": "SOLID Principles",
  "description": "Standard reference for the five SOLID object-oriented design principles.",
  "feature": "conventions",
  "project": "",
  "tags": ["reference", "global", "solid"]
}
```

# SOLID Principles

Standard reference — common software-engineering knowledge, kept concise rather than re-explained at
length. Apply as guiding principles, not hard rules to force everywhere.

- **S — Single Responsibility**: a class/module should have one reason to change. In NPD terms, this
  is why `<Entity>Service` (pure rules) is separate from `<Entity>Core` (orchestration) and
  `<Entity>RepositoryAdapter` (persistence) — each has exactly one axis of change.
- **O — Open/Closed**: open for extension, closed for modification — prefer adding a new
  implementation of a port/interface over branching inside an existing one.
- **L — Liskov Substitution**: a subtype must be usable anywhere its supertype is expected without
  breaking the caller's assumptions. In practice: don't implement a port in a way that violates the
  contract callers already rely on (e.g. throwing where the interface implies a nullable return).
- **I — Interface Segregation**: prefer several small, focused interfaces (ports) over one large one
  that forces implementers to satisfy methods they don't need — this is most of why NPD splits
  `ControllerPort` from `RepositoryPort` rather than one do-everything port per entity.
- **D — Dependency Inversion**: high-level modules (domain) shouldn't depend on low-level modules
  (persistence, web); both depend on abstractions (ports). This is the core mechanism hexagonal
  architecture uses — see `tech/conventions/hexagonal-architecture.md`.
