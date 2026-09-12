```json
{
  "title": "NPD BDD Testing Conventions",
  "description": "Cucumber-per-layer test structure, factory pattern for fixtures, and the MockMvc exception for controllers.",
  "feature": "npd",
  "project": "",
  "tags": ["guide", "global", "npd", "testing"]
}
```

# NPD BDD Testing Conventions

Tests are organized **by architectural layer**, each layer with its own Cucumber feature suite,
mirroring the production package layout under `src/test/kotlin/<entity>/` (without the `features.`
prefix):

| Layer | Test class | Feature file | What is mocked |
|---|---|---|---|
| Domain rules | `<Entity>Validation` | `<Entity>Service.feature` | nothing — pure logic |
| Use case orchestration | `<Entity>CoreTest` | `<Entity>Core.feature` | `<Entity>RepositoryPort` |
| Persistence adapter | `<Entity>RepositoryAdapterTest` | `<Entity>RepositoryAdapter.feature` | `<Entity>Repository` |
| HTTP controller | `<Entity>ControllerTest` | — plain JUnit5, not Cucumber | `<Entity>ControllerPort` |

## Fixture factories

A shared `<Entity>Factory` (in `<entity>/factory/`) provides default test fixtures — every field has a
sensible default, tests override only what the scenario cares about:

```kotlin
class UserFactory {
    companion object {
        fun createUser(
            id: Long = 1,
            firstName: String = "John",
            lastName: String = "Doe",
            zipCode: Int = 86920,
            street: String = "Main Street 1",
            city: String = "Berlin",
        ): User = User(id, firstName, lastName, zipCode, street, city)
    }
}
```

## Behavioral traceability

Each branch in a production pipeline should correspond to one Gherkin scenario:

```kotlin
// UserCore.kt
user.proceedIf { user -> validateUser(user) }
    .orElseThrow { Exception("User with id ${'$'}{user.id} is not valid") }
    .proceedIf { user -> userRepositoryPort.existsById(user) }
    .orElseThrow { NotFoundException("User does not exist") }
    .let { user -> userRepositoryPort.updateUser(user) }
```

```gherkin
# UserCore.feature
Scenario: Update a valid existing user
  Given a core user with zip code 86920
  And the user exists in the repository
  When the user is updated
  Then the user is updated in the repository

Scenario: Reject updating a user that does not exist
  Given a core user with zip code 86920
  And the user does not exist in the repository
  When the user is updated
  Then a NotFoundException is thrown

Scenario: Reject updating a user with an invalid zip code
  Given a core user with zip code 100001
  When the user is updated
  Then an exception is thrown
```

Each Cucumber suite is `@Suite`-annotated, co-located in the same file as its step definitions:

```kotlin
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("user/core")
@ConfigurationParameter(key = GLUE_PROPERTY_NAME, value = "user.core,cucumber")
class UserCoreFeature

class UserCoreTest {
    private val userRepositoryPort: UserRepositoryPort = mockk()
    private val userService = UserService()
    private val userCore = UserCore(userRepositoryPort, userService)
    // @Given/@When/@Then step definitions, using MockK and Kotest matchers
}
```

Gradle must copy `.feature` files out of `src/test/kotlin` alongside compiled step-def classes:

```groovy
processTestResources {
    from('src/test/kotlin') {
        include '**/*.feature'
    }
}
```

## Controller layer — the one exception

HTTP controllers are tested with plain JUnit5 + `@WebMvcTest` + `MockMvc`, mocking the inbound port
via a `@TestConfiguration`:

```kotlin
@WebMvcTest(controllers = [UserController::class])
@Import(UserControllerTest.MockPortConfiguration::class)
class UserControllerTest {

    @TestConfiguration
    class MockPortConfiguration {
        val port: UserControllerPort = mockk()
        @Bean
        fun userControllerPort(): UserControllerPort = port
    }

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Autowired
    private lateinit var mockPortConfiguration: MockPortConfiguration

    @BeforeEach
    fun setUp() = clearMocks(mockPortConfiguration.port)

    @Test
    fun `GET user returns 200 with user body when found`() {
        val user = UserFactory.createUser(id = 1)
        every { mockPortConfiguration.port.getUser(1L) } returns user

        mockMvc.get("/user") { param("userId", "1") }
            .andExpect { status { isOk() } }
    }
}
```

A single shared `CucumberSpringConfiguration` covers the whole app:

```kotlin
package cucumber

@CucumberContextConfiguration
@ContextConfiguration(classes = [CucumberTestConfiguration::class])
class CucumberSpringConfiguration

@Configuration
class CucumberTestConfiguration
```
