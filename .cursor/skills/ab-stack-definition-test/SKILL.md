---
name: ab-stack-definition-test
description: Validates new AppBuilder definition JSON against the local Docker Compose stack and Cypress E2E suite under ab_stack. Use when the user adds or changes AppBuilder exports, defs/*.json, ab_stack, Cypress tests, docker compose for AB, or wants regression checks after schema or UI definition changes.
---

# AB stack definition testing

## Preconditions

- Docker and Docker Compose available.
- Node/npm for Cypress (`ab_stack/package.json`).

## Where definitions go

- [`ab_stack/defs/upload.sh`](../../../ab_stack/defs/upload.sh) uploads every `*.json` in [`ab_stack/defs/`](../../../ab_stack/defs/).
- Exports at repo root (e.g. `app_miniApp_*.json`) must be **copied or moved** into `ab_stack/defs/` before upload unless the upload script is extended.

## Environment

1. From [`ab_stack`](../../../ab_stack): copy [`.env.example`](../../../ab_stack/.env.example) to `.env`.
2. Set **`COMPOSE_PROJECT_NAME`** in `.env` to match the Docker Compose project name (default in examples: `ab_stack`). Cypress `RunSQL` greps `${COMPOSE_PROJECT_NAME}-db` to find the MySQL container—if this mismatches `docker compose`’s project, SQL setup fails.
3. Align `WEB_PORT` / `SITE_URL` with Cypress `baseUrl` in [`ab_stack/test/cypress.config.js`](../../../ab_stack/test/cypress.config.js) (default site `http://localhost:8088`).

## Stack and definitions

From **`ab_stack`** directory:

1. `npm ci` (once per lockfile change).
2. `npm run start_ab` — `docker compose create && docker compose up -d`.
3. Wait until the web UI responds on `WEB_PORT`.
4. `npm run setup_definitions` — runs `defs/upload.sh` (login + `/definition/import` for each JSON).

**Alternative deploy:** [`ab_stack/UP.sh`](../../../ab_stack/UP.sh) uses `docker stack deploy` or `podman compose` with stack name `demo_ab`. Do not mix that with `npm run start_ab` unless you understand Swarm vs Compose naming; Cypress helpers assume **Compose** container naming.

## Cypress layout

- Config: [`ab_stack/test/cypress.config.js`](../../../ab_stack/test/cypress.config.js).
- Main runner: [`ab_stack/test/cypress/e2e/integration.cy.js`](../../../ab_stack/test/cypress/e2e/integration.cy.js) — `require()` each case from `test_cases/` and lists them in `testCases`.
- Case files live under [`ab_stack/test/cypress/e2e/test_cases/`](../../../ab_stack/test/cypress/e2e/test_cases/); they are **excluded** from direct spec discovery so only `integration.cy.js` drives them.
- SQL seeds: [`ab_stack/test/cypress/e2e/test_setup/sql/`](../../../ab_stack/test/cypress/e2e/test_setup/sql/), applied via `cy.RunSQL` in [`ab_stack/test/cypress/support/e2e.js`](../../../ab_stack/test/cypress/support/e2e.js).
- Prefer stable `data-cy` selectors from the exported app.

## Commands

| Goal | Command (from `ab_stack`) |
|------|---------------------------|
| Headless (CI-style) | `npm run test:ci` |
| Interactive | `npm run test` or `npm run cypress:open` |

## New definition + test checklist

1. Place or copy JSON into `ab_stack/defs/`.
2. Ensure `.env` has correct `COMPOSE_PROJECT_NAME` and credentials.
3. `npm run start_ab` then `npm run setup_definitions`.
4. Add or extend a module under `test/cypress/e2e/test_cases/`, export a factory function like existing cases, and register it in `integration.cy.js` `testCases`.
5. Run `npm run test:ci` and fix failures before merging.

## CI parity

GitHub workflow (if repo uses [`ab_stack/.github/workflows/run.yml`](../../../ab_stack/.github/workflows/run.yml)): compose up, upload defs, `npm run test:ci`. Set `COMPOSE_PROJECT_NAME` the same as local `.env` when the job runs `docker compose` from the same working directory.
