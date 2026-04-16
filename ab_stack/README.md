# ab_stack — AppBuilder Docker + Cypress

Local AppBuilder stack ([`docker-compose.yml`](docker-compose.yml)) and Cypress tests under [`test/`](test/). Parent repo: `testing_agent`.

## Prerequisites

- [Docker Compose](https://docs.docker.com/compose/)
- Node.js 20+ and npm (for Cypress)

## Setup

```sh
cd ab_stack
cp .env.example .env
# Edit .env: WEB_PORT, COMPOSE_PROJECT_NAME (must match docker compose project), image tags if needed.
npm ci
npm run start_ab
```

Wait until the UI answers on `http://localhost:${WEB_PORT}` (default **8088**).

## Import definitions

JSON files in [`defs/`](defs/) are uploaded by:

```sh
npm run setup_definitions
```

Requires default admin user; URLs in [`defs/upload.sh`](defs/upload.sh) follow `WEB_PORT`.

## Cypress

```sh
npm run test:ci    # headless
npm run test       # cypress open
```

- Config: [`test/cypress.config.js`](test/cypress.config.js) — reads `../.env` via dotenv; **`COMPOSE_PROJECT_NAME`** must match the compose project so `cy.RunSQL` can find the `db` container.
- Suite entry: [`test/cypress/e2e/integration.cy.js`](test/cypress/e2e/integration.cy.js); add cases under `test/cypress/e2e/test_cases/` and register them in `testCases`.

Agent workflow for new exports: see repo skill [`.cursor/skills/ab-stack-definition-test/SKILL.md`](../.cursor/skills/ab-stack-definition-test/SKILL.md).

## Troubleshooting

- **RunSQL cannot find db container:** set `COMPOSE_PROJECT_NAME` in `.env` to the prefix you see in `docker ps` (e.g. `ab_stack-db-1` → `ab_stack`).
- **Tear down:** `npm run halt_ab`

## Optional: Swarm / Podman

[`UP.sh`](UP.sh) deploys with `docker stack deploy` or `podman compose` (stack name `demo_ab`). That path differs from `npm run start_ab` (`docker compose`); do not assume the same container names as Cypress `RunSQL` without adjusting env.
