```json
{
  "title": "NPD Worked Example",
  "description": "A full copy-paste-ready feature (User) showing every layer end to end.",
  "feature": "npd",
  "project": "",
  "tags": ["template", "global", "npd", "kotlin"]
}
```

# NPD Worked Example (Reference Template)

A full `User` feature, JPA-based, for copy-paste when scaffolding a new feature. See
`tech/npd/structure-and-naming.md` and `tech/npd/pipeline-vocabulary.md` for the rules this follows.

```kotlin
// features/user/domain/User.kt
package features.user.domain

data class User(
    val id: Long,
    val firstName: String,
    val lastName: String,
    val zipCode: Int,
    val street: String,
    val city: String,
)
```

```kotlin
// features/user/domain/ports/UserControllerPort.kt
package features.user.domain.ports

import features.user.domain.User

interface UserControllerPort {
    fun getUser(id: Long): User
    fun create(user: User): User
    fun update(user: User): User
}
```

```kotlin
// features/user/domain/ports/UserRepositoryPort.kt
package features.user.domain.ports

import features.user.domain.User

interface UserRepositoryPort {
    fun getUser(id: Long): User
    fun saveUser(user: User): User
    fun updateUser(user: User): User
    fun existsById(user: User): Boolean
}
```

```kotlin
// features/user/domain/UserService.kt
package features.user.domain

const val USER_ZIP_LIMIT = 100000

class UserService {
    fun validateUser(user: User): Boolean = user.zipCode < USER_ZIP_LIMIT
}
```

```kotlin
// features/user/domain/UserCore.kt
package features.user.domain

import exceptions.NotFoundException
import features.user.domain.ports.UserControllerPort
import features.user.domain.ports.UserRepositoryPort
import org.springframework.stereotype.Service
import pipelineExtensions.orElseThrow
import pipelineExtensions.proceedIf

@Service
class UserCore(
    private val userRepositoryPort: UserRepositoryPort,
    private val userService: UserService = UserService(),
) : UserControllerPort {

    override fun getUser(id: Long): User =
        userRepositoryPort.getUser(id)

    override fun create(user: User): User =
        with(userService) {
            user.proceedIf { user -> validateUser(user) }
                .orElseThrow { Exception("User with id ${'$'}{user.id} is not valid") }
                .let { user -> userRepositoryPort.saveUser(user) }
        }

    override fun update(user: User): User =
        with(userService) {
            user.proceedIf { user -> validateUser(user) }
                .orElseThrow { Exception("User with id ${'$'}{user.id} is not valid") }
                .proceedIf { user -> userRepositoryPort.existsById(user) }
                .orElseThrow { NotFoundException("User does not exist") }
                .let { user -> userRepositoryPort.updateUser(user) }
        }
}
```

```kotlin
// features/user/api/User.kt
package features.user.api

import features.user.domain.User as DomainUser

data class User(
    val id: Long,
    val firstName: String,
    val lastName: String,
    val zipCode: Int,
    val street: String,
    val city: String,
)

fun User.toDomainModel(): DomainUser =
    DomainUser(
        id = id,
        firstName = firstName,
        lastName = lastName,
        zipCode = zipCode,
        street = street,
        city = city,
    )

fun DomainUser.toApiModel(): User =
    User(
        id = id,
        firstName = firstName,
        lastName = lastName,
        zipCode = zipCode,
        street = street,
        city = city,
    )
```

```kotlin
// features/user/api/UserController.kt
package features.user.api

import features.user.domain.ports.UserControllerPort
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/user")
class UserController(
    private val userControllerPort: UserControllerPort,
) {

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    fun getUser(userId: Long): User =
        userControllerPort.getUser(userId).toApiModel()

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun create(@Valid @RequestBody user: User): User =
        user.toDomainModel()
            .let { user -> userControllerPort.create(user) }
            .toApiModel()

    @PutMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    fun update(@Valid @RequestBody user: User): User =
        user.toDomainModel()
            .let { user -> userControllerPort.update(user) }
            .toApiModel()
}
```

```kotlin
// features/user/persistence/User.kt
package features.user.persistence

import features.user.domain.User as DomainUser
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "\"user\"")
data class User(
    @Id val id: Long,
    @Column val firstName: String,
    @Column val lastName: String,
    @Column val zipCode: Int,
    @Column val street: String,
    @Column val city: String,
)

fun User.toDomainModel(): DomainUser =
    DomainUser(
        id = id,
        firstName = firstName,
        lastName = lastName,
        zipCode = zipCode,
        street = street,
        city = city,
    )

fun DomainUser.toEntity(): User =
    User(
        id = id,
        firstName = firstName,
        lastName = lastName,
        zipCode = zipCode,
        street = street,
        city = city,
    )
```

```kotlin
// features/user/persistence/UserRepository.kt
package features.user.persistence

import org.springframework.data.jpa.repository.JpaRepository

interface UserRepository : JpaRepository<User, Long>
```

```kotlin
// features/user/persistence/UserRepositoryAdapter.kt
package features.user.persistence

import exceptions.NotFoundException
import features.user.domain.User
import features.user.domain.ports.UserRepositoryPort
import org.springframework.stereotype.Component
import pipelineExtensions.logInfo
import pipelineExtensions.orElseThrow

@Component
class UserRepositoryAdapter(
    private val userRepository: UserRepository,
) : UserRepositoryPort {

    override fun getUser(id: Long): User =
        id.logInfo { "Get user by id ${'$'}id" }
            .run { userRepository.findById(this).orElse(null) }
            .orElseThrow { NotFoundException("User not found") }
            .toDomainModel()

    override fun saveUser(user: User): User =
        user.logInfo { "Save user with id ${'$'}{user.id}" }
            .toEntity()
            .let { entity -> userRepository.save(entity) }
            .toDomainModel()

    override fun updateUser(user: User): User =
        user.logInfo { "Update user with id ${'$'}{user.id}" }
            .toEntity()
            .let { entity -> userRepository.save(entity) }
            .toDomainModel()

    override fun existsById(user: User): Boolean =
        userRepository.existsById(user.id)
}
```

Corresponding test suite: `UserValidation.kt` + `UserService.feature` (domain), `UserCoreTest.kt` +
`UserCore.feature` (orchestration), `UserRepositoryAdapterTest.kt` + `UserRepositoryAdapter.feature`
(persistence), `UserControllerTest.kt` (controller, no feature file), and `UserFactory.kt`.

## Open items

- If the backend ever adopts the reactive stack (WebFlux + R2DBC + Coroutines) instead of blocking
  Spring MVC + JPA, reintroduce `suspend` on every port/service/controller method, swap
  `JpaRepository` for `CoroutineCrudRepository`, and swap `proceedIf`/`orElseThrow` calls in coroutine
  contexts for `suspendProceedIf` — the rest of the conventions carry over unchanged.
- If Hibernate/JPA ever becomes a pain point, Spring Data JDBC is a lighter alternative — no
  persistence context, no lazy loading, `CrudRepository` + relational annotations instead of
  `jakarta.persistence`.
