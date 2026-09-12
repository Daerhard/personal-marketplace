```json
{
  "title": "NPD Package Structure & Naming",
  "description": "Feature-first package layout, per-layer naming conventions, constant-naming rules, and JPA persistence notes.",
  "feature": "npd",
  "project": "",
  "tags": ["reference", "global", "npd", "kotlin"]
}
```

# NPD Package Structure & Naming

Builds on `tech/conventions/hexagonal-architecture.md` — this doc covers how NPD specifically names
and arranges the layers.

## Package structure

Packages are organized **by feature first, then by hexagonal layer**. Main code nests feature packages
under a top-level `features` package; test code mirrors the same layout **without** the `features.`
prefix.

```
com.example.app/                            # main only
    Application.kt                          # @SpringBootApplication + main()

exceptions/                                 # main only — top-level, framework-agnostic
    NotFoundException.kt

pipelineExtensions/                         # main only — top-level, the NPD vocabulary
    ChainExtensions.kt                      # proceedIf, orElseThrow
    LogExtensions.kt                        # logInfo, logWarning, logError

features/
    <entity>/                               # e.g. "pantry", "recipe", "user"
        api/
            <Entity>.kt                     # API/DTO model + toDomainModel()/toApiModel() mappers
            <Entity>Controller.kt           # @RestController, thin, delegates to the inbound port
        domain/
            <Entity>.kt                     # pure domain model (data class, no annotations)
            <Entity>Core.kt                 # @Service — orchestrator, implements the inbound port
            <Entity>Service.kt              # pure business-rule logic, no framework deps
            ports/
                <Entity>ControllerPort.kt   # inbound port
                <Entity>RepositoryPort.kt   # outbound port
        persistence/
            <Entity>.kt                     # JPA entity + toDomainModel()/toEntity() mappers
            <Entity>Repository.kt           # Spring Data JPA repository interface
            <Entity>RepositoryAdapter.kt    # @Component, implements the outbound port
```

Rules:

- Package names are lowercase, no underscores, singular (`user`, not `users`).
- Cross-cutting, framework-agnostic utility code (`exceptions`, `pipelineExtensions`) lives at the top
  level of `main`, outside both `features` and the app's base package.
- A feature's `domain/` package (including `domain/ports/`) must have **zero** Spring/framework
  imports. `api/` and `persistence/` are where framework annotations belong.
- REST paths are named after the resource only (`/user`, `/pantry`) — the internal `features.`
  package prefix must not leak into the URL.

## Naming conventions

| Element | Convention | Example |
|---|---|---|
| Domain model | `<Entity>` (data class, in `domain/`) | `User` |
| API model | `<Entity>` (data class, in `api/`, same simple name) | `User` |
| Persistence entity | `<Entity>` (data class, in `persistence/`, same simple name) | `User` |
| Orchestrator / use-case class | `<Entity>Core` — implements the inbound port, `@Service` | `UserCore` |
| Pure domain logic helper | `<Entity>Service` — validation/business rules, no annotations | `UserService` |
| Inbound port (driving) | `<Entity>ControllerPort` | `UserControllerPort` |
| Outbound port (driven) | `<Entity>RepositoryPort` | `UserRepositoryPort` |
| REST controller | `<Entity>Controller`, `@RestController`, mapped at `/<entity-lowercase>` | `UserController` |
| Spring Data repository | `<Entity>Repository`, extends `JpaRepository<Entity, Id>` | `UserRepository` |
| Persistence adapter | `<Entity>RepositoryAdapter`, `@Component` | `UserRepositoryAdapter` |
| Domain constants | top-level `const val`, **prefixed with the entity name** | `const val USER_ZIP_LIMIT = 100000` |
| Validation function | `validate<Entity>(entity): Boolean` — a predicate, not nullable-returning | `validateUser(user): Boolean` |

Domain constants are prefixed with the entity name because every feature's `domain` package sits under
the same `features.<entity>.domain` shape — a bare name collides the moment two features' constants
need to be imported into the same file.

Because the domain, API, and persistence models share the same simple name (`User`) by design, files
needing more than one of them import the others with an alias:

```kotlin
import features.user.domain.User as DomainUser
```

Mapper functions are top-level extension functions, named `to<Target>()`, and live in the **adapter's**
file, never in the domain layer:

- `api/User.kt` defines `User.toDomainModel()` and `DomainUser.toApiModel()`.
- `persistence/User.kt` defines `User.toDomainModel()` and `DomainUser.toEntity()`.

## Hexagonal architecture rules, as applied in NPD

- **Domain layer** (`domain/`, `domain/ports/`): pure Kotlin, no framework annotations.
- **Application/orchestration**: folds into `domain/<Entity>Core.kt` — a `@Service`-annotated class,
  the one class in `domain/` allowed a Spring annotation, since it's the seam where the domain is
  wired into the framework as a bean.
- **Adapters** (`api/`, `persistence/`): implement or call the ports. The web adapter depends only on
  the inbound port; the persistence adapter implements the outbound port and is the only place that
  talks to Spring Data.
- **Dependency direction**: adapters depend on `domain` (via the ports); `domain` never imports from
  `api` or `persistence`.
- **One model per layer, mapped at the boundary** — don't reuse the JPA entity as the API response.
- Controllers stay thin: validate input (`@Valid`), delegate to the inbound port, map back. No
  business logic in controllers.
- `<Entity>Service` is pure and stateless — instantiate directly (`UserService()`) inside
  `<Entity>Core` rather than injecting via Spring DI.

## Persistence layer notes (JPA)

Meal Mate uses **Spring Data JPA with Hibernate**:

- Entities use `jakarta.persistence.Entity`, `@Table`, `@Id`, `@Column`.
- Repository interfaces extend `JpaRepository<Entity, Id>`.
- `JpaRepository.findById(id)` returns `java.util.Optional<T>` — resolve inline with `.orElse(null)`
  before `orElseThrow`.
