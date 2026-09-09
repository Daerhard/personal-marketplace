```json
{
  "title": "Milestone 1 — Status & Deploy Guide",
  "description": "Current build status, the Vercel/Oracle deployment split (and why), and the deploy runbook.",
  "feature": "deployment",
  "project": "meal-mate",
  "tags": ["guide", "project", "infra", "deployment"]
}
```

# Milestone 1 (Auth MVP) — Status & Deployment Guide

Scaffolding pass complete as of 2026-08-25. Code lives in the local `Meal Mate` project folder, not in
this marketplace repo — this doc tracks status and explains how to run/deploy it. Full original spec:
see `milestone-1-auth-mvp.md`.

## Deployment split (revised from the original architecture doc)

**Backend + Postgres on the Oracle VM (Docker Compose). Frontend on Vercel**, connected directly to
the GitHub repo — not the single-origin Caddy-serves-everything design originally documented.
`architecture-tech-stack.md` itself hasn't been updated to reflect this inline; this doc is the
current source of truth for deployment shape.

### What changed technically

- **CORS is now real**: backend has a `cors.allowed-origins` (`ALLOWED_ORIGINS` env var) Spring
  Security CORS config, since frontend and backend are different origins. No credentials/cookies
  needed — the access token travels as a Bearer header, so it's a simple explicit-origin-list policy.
- **No more `/api` prefix stripping**: the Oracle Caddy instance now only terminates HTTPS in front of
  the backend (`reverse_proxy backend:8080`, no path routing). Frontend calls the backend's real
  domain directly via `VITE_API_BASE_URL`.
- **A domain for the backend is now required, not optional**: Vercel is always HTTPS; browsers block
  an HTTPS page calling a plain-HTTP API (mixed content). A free DuckDNS subdomain works if a
  purchased domain isn't ready yet.
- `docker-compose.yml` dropped the frontend-serving `caddy` build entirely; `caddy` is now just an
  HTTPS terminator in front of `backend` only.
- `.github/workflows/deploy.yml` dropped the frontend GHCR build/push job — Vercel's own GitHub
  integration builds and deploys the frontend independently. A lightweight `frontend` job remains as a
  lint/build CI check only (no deploy).
- `frontend/Dockerfile` and `frontend/Caddyfile` kept but marked unused/legacy — an escape hatch back
  to self-hosting the SPA on the Oracle VM if Vercel ever gets dropped.

### Why Vercel (the tradeoff, for the record)

Pro: free, zero-config CI/CD and preview deployments per PR, better DX than babysitting a static Caddy
image on a resource-capped free-tier VM. Con: gives up the original design's two guarantees —
same-origin (no CORS surface) and atomic deploys (frontend+backend always live together). Neither con
is a big deal for a solo personal project.

## What's done

- **Backend** — Kotlin + Spring Boot 4.1.0, Kotlin 2.3.21, blocking Spring MVC + JPA, hexagonal
  architecture, NPD pipeline vocabulary. `features/user` (register, `GET /me`) and `features/auth`
  (login/logout/refresh), Argon2 password hashing, JWT access tokens (jjwt, HS256, 15 min TTL) +
  opaque refresh tokens hashed in Postgres (30 day TTL, revoked on logout), Flyway migrations, Spring
  Security stateless filter chain + CORS, Actuator health, auto-generated OpenAPI/Swagger UI. Cucumber
  BDD suites per hexagonal layer + MockMvc controller tests, including a regression test that a
  refresh token stops working right after logout.
- **Frontend** — React + TypeScript + Vite, `react-router-dom`. Register/Login/Home pages, route
  guarding, an `authClient.ts` fetch wrapper (cross-origin-aware via `VITE_API_BASE_URL`), refresh
  token in `localStorage` + access token in-memory only (tradeoff documented in a code comment), Vite
  dev proxy so local dev needs zero env vars. `npm run build` and lint verified clean.
- **Infra** — root `docker-compose.yml` (backend + postgres + `caddy` as HTTPS terminator only), root
  `Caddyfile`, `.env.example`, `.github/workflows/deploy.yml` (backend: test → build+push to GHCR →
  SSH deploy; frontend: lint+build check only).

## Known gap — verify before trusting it

The scaffolding session's sandbox had no network access to Maven Central / the Gradle Plugin Portal
(only npm was allowlisted), so **`./gradlew test` has never actually been run to completion**. The
code was reviewed by hand (two real bugs already found and fixed this way: a `Long` vs `String`
principal-type mismatch in the JWT filter/controller, and a Jackson dependency groupId fix —
`com.fasterxml.jackson.module` doesn't exist for Spring Boot 4.1.0's Jackson 3.x stack, needed
`tools.jackson.module`), but it is genuinely unverified by a compiler.

**First thing to do:**

```bash
cd backend && ./gradlew test
```

on a machine with normal internet, or let CI do it on first push. Expect to spend a little time fixing
whatever that first real run turns up. The frontend, by contrast, *was* fully build/lint-verified
in-session.

## Deploying the backend to the Oracle Cloud VM

1. **Provision the VM**: Ampere A1 shape, Ubuntu 24.04. Retry another region or fall back to a free
   AMD micro shape if capacity is temporarily unavailable.
2. **Open firewall ports** 80/443 (and 22) in the Security List/NSG and `ufw`.
3. **Install Docker**: `curl -fsSL https://get.docker.com | sudo sh`.
4. **Get a domain pointed at the VM** — required (mixed-content, see above). A free DuckDNS subdomain
   is the fastest unblock.
5. **Set up `/opt/mealmate`** on the VM with the repo's `docker-compose.yml` + `Caddyfile`, and a real
   `.env`: DB password, `JWT_SECRET` (`openssl rand -base64 48`), `ALLOWED_ORIGINS` set to the real
   Vercel URL, `BACKEND_DOMAIN` set to the domain from step 4.
6. **GHCR auth on the VM** (if private): `docker login ghcr.io` with a PAT that has `read:packages`.
7. **GitHub repo secrets**: `ORACLE_VM_HOST`, `ORACLE_VM_USER`, `ORACLE_VM_SSH_KEY` (dedicated deploy
   keypair).
8. **Push to `main`.** Tests the backend, builds+pushes its image, SSHes in, runs
   `docker compose pull && docker compose up -d`.

## Deploying the frontend to Vercel

1. vercel.com → Add New → Project → import the GitHub repo.
2. Root Directory: `frontend`. Framework preset: Vite (auto-detected).
3. Project Settings → Environment Variables → `VITE_API_BASE_URL` = backend's HTTPS URL, Production +
   Preview.
4. Deploy. Every push to `main` (and every PR, as preview) deploys automatically — no GitHub Actions
   involvement.
5. Add the resulting Vercel URL(s) to the backend's `ALLOWED_ORIGINS` and restart the backend
   container so CORS actually allows it.

## Recommended order of operations from here

1. `cd backend && ./gradlew test` locally — fix whatever the real compiler finds.
2. `docker compose up --build` locally, then `cd frontend && npm run dev` against it — walk
   register → login → home → logout.
3. `git init`, push to a new GitHub repo.
4. Get a domain (or DuckDNS subdomain), provision the Oracle VM, set the three deploy secrets.
5. Connect the repo to Vercel, set `VITE_API_BASE_URL`.
6. Push to `main`, watch both deploys, verify the live site end to end.
