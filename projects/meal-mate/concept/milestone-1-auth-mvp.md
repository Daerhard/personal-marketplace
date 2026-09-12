```json
{
  "title": "Milestone 1 — Auth MVP Spec",
  "description": "Scope and success criteria for the auth slice: register/login/logout/refresh, both backend and frontend.",
  "feature": "auth",
  "project": "meal-mate",
  "tags": ["guide", "project", "auth", "backend"]
}
```

# Milestone 1 — Auth MVP

## Goal

A person can create an account, log in, see they're logged in, and log out — running locally via
Docker Compose and deployed to the Oracle Cloud VM via GitHub Actions.

## Scope — in

**Backend** (Kotlin + Spring Boot, hexagonal architecture, NPD style per `tech/npd/`):

- A `user` feature under `features/user/...` per NPD package conventions.
- `POST /auth/register` — email + password, Argon2 hashed, email format + min length validated,
  duplicates rejected with 409/validation error.
- `POST /auth/login` — email + password → short-lived JWT access token + refresh token. Refresh
  tokens stored server-side (hashed, Postgres via Flyway) so they can be revoked.
- `POST /auth/logout` — revokes the caller's refresh token server-side. Access tokens are stateless
  and simply expire (short TTL, e.g. 15 min) — no access-token blacklisting this milestone.
- `POST /auth/refresh` — exchanges a valid, non-revoked refresh token for a new access token.
- Spring Security wired for stateless JWT auth; Argon2 password encoder.
- Flyway migrations for `users` and `refresh_tokens`.
- `GET /me` (protected) — proves the auth filter works end to end; the frontend's "logged in" screen
  calls this.
- Follow `tech/npd/` throughout: package layout, `proceedIf`/`orElseThrow`/`logInfo` vocabulary,
  Boolean-returning domain validation, BDD test structure.
- Actuator health endpoint.

**Frontend** (React + TypeScript, Vite):

- Three screens: Register, Login, Home (protected — redirects to `/login` if not authenticated).
- Home shows a welcome message from `GET /me` and a Logout button.
- A small API client wrapping fetch calls to `/api/auth/*`, bearer header on protected calls.
- Client-side route guarding so `/home` is unreachable without a valid session.
- Token storage kept simple for the MVP (in-memory + refresh-on-load, or localStorage) — tradeoff
  noted in a code comment rather than over-engineered now.
- Basic form validation and error display.

**Infra & deployment:**

- `docker-compose.yml` at repo root: backend, postgres, caddy.
- Backend Dockerfile: multi-stage Gradle build → slim JRE runtime.
- Frontend + Caddy: multi-stage Dockerfile (node build stage, caddy stage serving `dist/`). A
  Caddyfile serving the SPA at `/` and reverse-proxying `/api/**` to the backend — single origin, no
  CORS. *(Superseded — see status/deploy doc: frontend now on Vercel, cross-origin.)*
- `.env`/secrets via environment variables, never committed; documented in `.env.example`.
- GitHub Actions workflow on push to `main`: `backend`, `frontend`, `deploy` (needs both).

## Scope — out (deferred to later milestones)

- Password reset / forgot-password / email verification
- Rate limiting on the API
- OpenAPI docs, Prometheus/Grafana, Sentry
- Refresh-token rotation/hardening beyond simple revocation-on-logout
- Any account/profile management beyond create + login + logout
- The Android app

## Success criteria

- `docker compose up` locally brings up backend + Postgres + Caddy; the full
  register → login → home → logout flow works through the browser.
- Backend tests (BDD suite + controller test) pass; `gradle test` is green.
- Pushing to `main` triggers the GitHub Actions workflow, deploying both images to the Oracle VM,
  reachable over HTTPS.
- After logout, the previously-issued refresh token no longer works (verified by a test).

## Related docs

- `milestone-1-status-deploy-guide.md` — implementation status and how this was actually deployed
- `tech/npd/` — the coding methodology this milestone follows
