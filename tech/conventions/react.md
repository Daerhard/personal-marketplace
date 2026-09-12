```json
{
  "title": "React Conventions",
  "description": "Component structure, routing, and API-client patterns — thin right now, drafted from Milestone 1.",
  "feature": "conventions",
  "project": "",
  "tags": ["reference", "global", "react", "frontend"]
}
```

# React Conventions

> Living doc — drafted from Meal Mate's Milestone 1 implementation, not a definitive style guide yet.

## Current baseline (observed)

- **Routing**: `react-router-dom`, with protected routes implemented as a wrapper component that
  redirects to `/login` when there's no valid session, rather than guarding inside each page.
- **API client**: a small hand-written fetch wrapper per domain (e.g. `authClient.ts`), not a generic
  HTTP client library — keeps the bearer-token attachment and error shape explicit and colocated with
  the calls that need it.
- **State**: component-local state / lightweight patterns for now; no global state library introduced
  yet — revisit once cross-page shared state (e.g. pantry contents) is actually needed.
- **Token storage**: access token in-memory only, refresh token in `localStorage` — a documented
  tradeoff (simplicity over XSS-hardening) for the MVP, not a final security posture. Revisit before
  the app handles anything beyond auth.
- **Env config**: `VITE_API_BASE_URL` for the backend origin, with a Vite dev-server proxy so local
  dev needs zero env vars.

## Open questions to settle as the codebase grows

- Component organization (feature folders vs. flat `components/`) once there are more than the three
  Milestone 1 screens.
- Form-handling approach (currently basic native form validation — revisit if forms get more complex
  than register/login).
- Whether state management needs a real library once pantry/recipe data enters the picture.
