```json
{
  "title": "NPD Pipeline Vocabulary",
  "description": "proceedIf/orElseThrow/logInfo and how they combine with Kotlin scope functions, plus lambda-naming rules.",
  "feature": "npd",
  "project": "",
  "tags": ["reference", "global", "npd", "kotlin"]
}
```

# NPD Pipeline Vocabulary

A domain validation function is a plain predicate (`(T) -> Boolean`). A small, shared vocabulary of
extension functions turns predicates and lookups into a pipeline where each `.step()` reads as one
line of behavior with an explicit failure mode next to it.

## Core extensions

`pipelineExtensions/ChainExtensions.kt`:

```kotlin
package pipelineExtensions

inline fun <T> T.proceedIf(check: (T) -> Boolean): T? =
    if (check(this)) this else null

inline fun <T> T?.orElseThrow(exception: () -> Exception): T =
    this ?: throw exception()
```

`proceedIf` is a **condition gate, not a predicate filter about the value itself** — the check can be
any external condition:

```kotlin
user.proceedIf { user -> validateUser(user) }
user.proceedIf { user -> userRepositoryPort.existsById(user) }
user.proceedIf { permissionCache.hasPermission(it.id) }
```

`orElseThrow` resolves the resulting `null` into a specific, named exception at the point where the
caller actually knows which one is appropriate — the gate itself stays generic.

`pipelineExtensions/LogExtensions.kt` — observable behavior, without breaking the chain:

```kotlin
package pipelineExtensions

import io.github.oshai.kotlinlogging.KotlinLogging

private val logger = KotlinLogging.logger {}

fun <T> T.logInfo(message: (T) -> String): T = also { logger.info { message(it) } }
fun <T> T.logWarning(message: (T) -> String): T = also { logger.warn { message(it) } }
fun <T> T.logError(message: (T) -> String): T = also { logger.error { message(it) } }
```

## Standard Kotlin scope functions, as used alongside this vocabulary

**`let` — pipeline steps, named lambda param once the chain has 2+ steps:**

```kotlin
user.toDomainModel()
    .let { user -> userControllerPort.create(user) }
    .toApiModel()
```

**`with(receiver) { ... }` — scope a whole function body to a collaborator:**

```kotlin
override fun create(user: User): User =
    with(userService) {
        user.proceedIf { user -> validateUser(user) }
            .orElseThrow { Exception("User with id ${'$'}{user.id} is not valid") }
            .let { user -> userRepositoryPort.saveUser(user) }
    }
```

**`run { ... }` — reference the previous value as `this` mid-chain, typically after a `logInfo`:**

```kotlin
override fun getUser(id: Long): User =
    id.logInfo { "Get user by id ${'$'}id" }
        .run { userRepository.findById(this).orElse(null) }
        .orElseThrow { NotFoundException("User not found") }
        .toDomainModel()
```

**`also` — genuine side effects only, never to feed a result into the next step.** This is why
`logInfo`/`logWarning`/`logError` exist as named wrappers rather than `also { logger.info(...) }`
inline every time, and why an existence check belongs in `proceedIf` (which surfaces its result),
never in a bare `also` (which discards it):

```kotlin
// Wrong — also always returns the original user; the check's result is discarded.
validatedUser.also { userRepositoryPort.existsById(it) }.orElseThrow { NotFoundException(...) }

// Right — proceedIf surfaces the check's result so orElseThrow can actually gate on it.
validatedUser.proceedIf { user -> userRepositoryPort.existsById(user) }
    .orElseThrow { NotFoundException("User does not exist") }
```

**`apply`** — for configuring-then-returning an object (`SomeBuilder().apply { field = x }`) when the
receiver itself is needed back.

## Explicit lambda parameter names

Name lambda parameters explicitly whenever the parameter is used inside the lambda. Don't rely on
`it`, and don't rely on an outer-scope variable of the same name without naming the lambda parameter.

Prefer:

```kotlin
user.proceedIf { user -> validateUser(user) }
    .let { user -> userRepositoryPort.updateUser(user) }
```

Avoid:

```kotlin
user.proceedIf { validateUser(it) }        // unclear what flows into validateUser
user.proceedIf { validateUser(user) }      // shadows the outer variable silently
    .let { userRepositoryPort.updateUser(it) }  // it has no name
```

When a lambda parameter is genuinely unused, omit it entirely:

```kotlin
user.proceedIf { featureFlags.isEnabled("new-flow") }
```

## Meaningful functions

Functions should express what the system is doing, not how it's technically implemented. Prefer
`validateUser(user)`, `existsById(user)`, `updateUser(user)` over spreading implementation details
into the flow (`repository.findById(user.id).map { mapper.map(it) }`). A meaningful function name
answers: **what is the system doing?**
