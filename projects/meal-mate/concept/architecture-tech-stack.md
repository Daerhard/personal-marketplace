```json
{
  "title": "Architecture & Tech Stack",
  "description": "Finalized stack decisions for Android, backend, frontend, DB, and infra, with the reasoning behind each choice.",
  "feature": "architecture",
  "project": "meal-mate",
  "tags": ["reference", "project", "backend", "infra"]
}
```

# Meal Mate — Android App & Backend Tech Stack

Context: solo developer, personal use, but built to a professional standard (clean architecture,
CI/CD, tests, security). Hosting on Oracle Cloud's Always Free tier; CI/CD via GitHub Actions.

> Deployment note: the frontend hosting decision below (Caddy serving the SPA) was later revised —
> the frontend now deploys to Vercel instead. See `milestone-1-status-deploy-guide.md` for the current
> deployment shape and why it changed. Everything else on this page still holds.

## Summary — finalized stack

- **Android app:** Kotlin + Jetpack Compose, MVVM, Hilt, Room, Ktor Client
- **Web frontend:** React + TypeScript (Vite), consumes the same REST API as the Android app
- **Backend:** Kotlin + Spring Boot, hexagonal architecture (ports & adapters), idiomatic use of
  Kotlin scope functions — API-only, no server-rendered or statically-served UI
- **Database:** PostgreSQL, self-hosted via Docker
- **Infra:** Oracle Cloud Always Free (Ampere A1 ARM VM), Docker Compose, Caddy (reverse proxy + auto
  HTTPS)
- **CI/CD:** GitHub Actions — test, build images, push to GHCR, deploy over SSH

## Backend: Spring Boot, hexagonal architecture

Kotlin + Spring Boot, chosen over Ktor for the batteries-included conventions (Spring Security, Spring
Data, Actuator, DI baked in).

Structured as **hexagonal architecture (ports & adapters)** — see `tech/conventions/hexagonal-architecture.md`
for the general pattern, and `tech/npd/` for how this codebase specifically expresses it (naming,
package layout, pipeline vocabulary).

The backend serves the REST API only — it does not serve the web frontend's static files.

## Database: self-hosted PostgreSQL

Self-hosted in Docker on the same VM, rather than Oracle's free Autonomous Database — better
Kotlin/Spring ecosystem support (Spring Data JPA, Flyway, Testcontainers all assume it), and portable
if the app ever moves off Oracle. Migrations via **Flyway**.

## Android app

- **Jetpack Compose** — not the older View/XML system
- **MVVM** with `ViewModel` + `StateFlow`, repository pattern
- **Hilt** for dependency injection
- **Room** for local persistence — important since pantry/grocery-list data should be usable offline
- **Ktor Client** for networking
- **Coroutines/Flow** throughout

## Web frontend: React SPA

- **React + TypeScript**, scaffolded with **Vite** — chosen over Angular for the MVP: lighter to
  stand up, larger ecosystem/more transferable skill.
- Kept as a **separate deployable from the backend** (its own Docker image, its own CI build job)
  rather than having Spring Boot serve its static build output — keeps the backend an API-only
  service with a clean hexagonal boundary, and keeps npm tooling out of the Gradle build.

## Auth & security

- JWT access + refresh tokens (Spring Security)
- Argon2 (or bcrypt) password hashing
- HTTPS everywhere
- Secrets via GitHub Actions secrets + `.env` files on the VM, never committed
- Rate limiting on the API (deferred past Milestone 1)

## Infrastructure: Oracle Cloud Always Free

Ampere A1 shape — up to 4 OCPUs / 24GB RAM, splittable across up to 4 VM instances, free indefinitely.
Also free: 200GB block storage, 10TB/month egress, a container registry, a basic load balancer.

Note: Ampere A1 capacity can be temporarily unavailable in some regions during initial signup — retry
another region or fall back to the free AMD micro shapes short-term.

Run via **Docker Compose** on the VM. Original design had three services (backend, postgres, caddy
serving the SPA too); see the status/deploy doc for how this changed once Vercel took over the
frontend.

## CI/CD: GitHub Actions

On push to `main`: `backend` job (test, build image, push to GHCR), `frontend` job (lint/build,
build/push image or — post-Vercel-split — lint/build check only), `deploy` job (needs both — SSH into
the Oracle VM, `docker compose pull && docker compose up -d`).

Separate workflow for Android: build, test, lint, produce a release AAB as a build artifact. Play
Store publishing not needed for personal use.

## Professional-grade touches worth including

- Structured JSON logging (Logback)
- `/health` endpoint (Actuator)
- OpenAPI spec (springdoc-openapi) for API docs
- Integration tests using Testcontainers (real Postgres per test run)
- Optional later: Prometheus + Grafana, Sentry (free tier) for error tracking

## Repo structure

Monorepo: `/android` (Gradle), `/backend` (Gradle, split into `domain`, `application`, adapter modules
per hexagonal architecture), `/frontend` (npm/Vite), optionally `/shared` for common DTOs. Deployment
config (`docker-compose.yml`, Caddy config) at the repo root or in `/deploy`.

## Related docs

- `milestone-1-status-deploy-guide.md` — current deployment shape (Vercel split) and status
- `tech/npd/` — the backend's coding methodology
- `tech/conventions/hexagonal-architecture.md` — the general architecture pattern
