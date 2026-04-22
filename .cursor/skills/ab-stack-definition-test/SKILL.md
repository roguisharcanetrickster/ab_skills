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

**Alternative deploy:** [`ab_stack/UP.sh`](../../../ab_stack/UP.sh) uses `docker stack deploy` or `podman compose` with stack name `ab_stack`. Do not mix that with `npm run start_ab` unless you understand Swarm vs Compose naming; Cypress helpers assume **Compose** container naming.

## Cypress layout

- Config: [`ab_stack/test/cypress.config.js`](../../../ab_stack/test/cypress.config.js).
- Main runner: [`ab_stack/test/cypress/e2e/integration.cy.js`](../../../ab_stack/test/cypress/e2e/integration.cy.js) — `require()` each case from `test_cases/` and lists them in `testCases`.
- Case files live under [`ab_stack/test/cypress/e2e/test_cases/`](../../../ab_stack/test/cypress/e2e/test_cases/); they are **excluded** from direct spec discovery so only `integration.cy.js` drives them.
- Prefer stable `data-cy` selectors from the exported app.

### SQL seeds — required location

**Expectation:** any Cypress work that needs DB seed data (shared defaults, per-app fixtures, permissions, resets) ships as one or more `.sql` files **in this directory only**:

`testing_agent/ab_stack/test/cypress/e2e/test_setup/sql/`

Do not put seed SQL under `test_cases/`, repo root, or ad-hoc paths. `cy.RunSQL` in [`ab_stack/test/cypress/support/e2e.js`](../../../ab_stack/test/cypress/support/e2e.js) loads files by **basename** from that folder (e.g. `init_db_default.sql`, `init_db_<app>.sql`, `reset_db.sql`). Wire new files into the `cy.RunSQL([...])` array in [`integration.cy.js`](../../../ab_stack/test/cypress/e2e/integration.cy.js).

## Commands

| Goal | Command (from `ab_stack`) |
|------|---------------------------|
| Headless (CI-style) | `npm run test:ci` |
| Interactive | `npm run test` or `npm run cypress:open` |

## New definition + test checklist

1. Place or copy JSON into `ab_stack/defs/`.
2. Ensure `.env` has correct `COMPOSE_PROJECT_NAME` and credentials.
3. `npm run start_ab` then `npm run setup_definitions`.
4. **Add or update an `.sql` file under** `ab_stack/test/cypress/e2e/test_setup/sql/` for that app’s fixtures (or extend an existing one), and include it in `integration.cy.js` → `cy.RunSQL([...])`.
5. Add or extend a module under `test/cypress/e2e/test_cases/`, export a factory function like existing cases, and register it in `integration.cy.js` `testCases`.
6. Run `npm run test:ci` and fix failures before merging.

### Init SQL for the target app

All seed SQL lives under [`ab_stack/test/cypress/e2e/test_setup/sql/`](../../../ab_stack/test/cypress/e2e/test_setup/sql/) (repo path: `testing_agent/ab_stack/test/cypress/e2e/test_setup/sql`). Build **app-specific** init SQL from the same definition JSON you import under [`ab_stack/defs/`](../../../ab_stack/defs/). Reference shape: [`init_db_default.sql`](../../../ab_stack/test/cypress/e2e/test_setup/sql/init_db_default.sql) (Movies: `AB_ExampleApp_Movies`, `AB_MoviesApp_Actors`, join `AB_JOINMN_Actors_Movies_Films`).

**Source of truth (definition JSON)**

- Each `definitions[]` row with `type: "object"` → `json.tableName`, `json.primaryColumnName` (usually `uuid`).
- For that object’s `fieldIDs`, resolve each `type: "field"` row → `json.columnName` for physical columns. Backtick names in SQL when they have spaces or are reserved (e.g. `` `Date Released` `` in Movies, `` `Group` `` when the column name matches a reserved word).
- Include `properties` on inserts if the live table has it (see Movies example).

### Definitions → MySQL shape (read the export; skip DESCRIBE when possible)

Use the definition JSON as the **primary** map to seed SQL. Reserve `DESCRIBE \`Table\`;` / `SHOW CREATE TABLE` for unknown `connectObject` layouts, custom FKs, or after an AB version upgrade if inserts fail.

#### Base columns on every imported object table

After `setup_definitions`, each `type: "object"` table named `json.tableName` typically includes:

| Column | Notes |
|--------|--------|
| `uuid` | Primary key; value from `json.primaryColumnName` (almost always `uuid`). |
| `created_at`, `updated_at` | AppBuilder system timestamps (snake_case); safe to set explicitly in seed SQL. |
| `properties` | `TEXT`, often `NULL` in fixtures. |
| `index` | Auto-increment display index; omit from `INSERT` unless you need a fixed value (usually let the DB assign). |
| …user fields | One physical column per non-virtual field (see below). |

**Dual datetimes:** exports may also define `datetime` fields whose `columnName` is `createdAt` / `updatedAt` (camelCase). Those are **separate** columns from `created_at` / `updated_at`. Seed scripts often only need to set `created_at` / `updated_at`; the camelCase columns may have DB defaults—if `INSERT` fails, add them explicitly using the same timestamps.

#### Non-`connectObject` fields → columns

- `string`, `number`, `date`, `datetime`, `AutoIndex` (handled via table `index`), etc. → a column literally named `json.columnName` on that object’s `json.tableName`.
- Multiline / JSON / other keys follow the same rule: column name is always `json.columnName` on the owning object table.

#### `connectObject` → which table gets the UUID column (`isSource`)

For relations stored **without** a dedicated `AB_JOINMN_*` row in the export (in-app 1:N / “via” links):

- Walk `definitions[]` and find every `type: "field"` with `json.key === "connectObject"`.
- If `json.settings.isSource === 1`, that field’s **owning object** (the object named before `->` in the definition `name`, e.g. `Applications->Mother` → object **Applications**) has a physical column `json.columnName` holding the **related row’s** `uuid`.
- If `json.settings.isSource === 0`, that field does **not** add a persisted FK column on that owning object’s table for this link in the common bible-study–style layout; persistence is on the `isSource: 1` side.

**Insertion order (FKs ON):** insert parent objects first, then rows on tables that hold `isSource: 1` FK columns pointing at them (e.g. Mothers + Groups before Applications and GroupMemberships; Groups before GroupMeetings when `GroupMeetings.Group` is `isSource: 1`). Example tables from [`app_bibleStudyGroup_20260416.json`](../../../ab_stack/defs/app_bibleStudyGroup_20260416.json): `AB_bibleStudyGroup_Mothers`, `AB_bibleStudyGroup_Groups` (no link FK columns for Mothers↔Applications in this pattern), then `AB_bibleStudyGroup_GroupMeetings`, `AB_bibleStudyGroup_GroupMemberships`, `AB_bibleStudyGroup_Applications`.

#### Many-to-many and join tables

- If the live DB has `AB_JOINMN_*` (or similar) and the export does not list them as `type: "object"`, infer column names from the **field** `columnName` values on that join definition block, or mirror [`init_db_default.sql`](../../../ab_stack/test/cypress/e2e/test_setup/sql/init_db_default.sql) (`AB_JOINMN_Actors_Movies_Films`).

#### `cy.RunSQL` file order

[`e2e.js`](../../../ab_stack/test/cypress/support/e2e.js) concatenates **all** basenames in the `cy.RunSQL([...])` array into one script in **array order** before executing MySQL—order seeds so `reset` / permissions run before app data.

**Statement shape**

- Start with `SET FOREIGN_KEY_CHECKS = 0;`, end with `SET FOREIGN_KEY_CHECKS = 1;`.
- Per table: `LOCK TABLES \`TableName\` WRITE;` → `INSERT IGNORE INTO \`TableName\` (...) VALUES (...);` → `UNLOCK TABLES;`.

**FK order and relations**

- Insert rows **before** any row that references them (Movies: directors, then movie with `Films` FK, then M:N join).
- Use **`connectObject` + `isSource`** (section above) to decide which tables own FK columns; use that to order `INSERT`s without opening MySQL.
- `connectObject` / many-to-many join tables may **not** appear as their own `type: "object"` in the export—use `AB_JOINMN_*` patterns from [`init_db_default.sql`](../../../ab_stack/test/cypress/e2e/test_setup/sql/init_db_default.sql) or one-time `SHOW TABLES LIKE 'AB_%';` if the join name is unclear.
- If inserts still fail after following the rules above, run **`DESCRIBE \`YourTable\`;`** once, fix the seed file, and optionally add a one-line comment in that `.sql` file documenting any surprising column so the next person skips live inspection.

**Example table names**

- Movies object table: `AB_ExampleApp_Movies` (from [`app_Movies_App_20250216.json`](../../../ab_stack/defs/app_Movies_App_20250216.json)).
- Bible study object table: `AB_bibleStudyGroup_Mothers` (from [`app_bibleStudyGroup_20260416.json`](../../../ab_stack/defs/app_bibleStudyGroup_20260416.json)).

**Wire into Cypress**

- Add a new **`.sql` file in** `ab_stack/test/cypress/e2e/test_setup/sql/` (e.g. `init_db_<shortApp>.sql`). This is mandatory for new apps: the suite should not rely on manual DB state without a checked-in file here.
- Pass it to `cy.RunSQL([...])` in [`integration.cy.js`](../../../ab_stack/test/cypress/e2e/integration.cy.js) instead of or in addition to `init_db_default.sql` when testing that app. Order in the array is concat order before MySQL runs it ([`e2e.js`](../../../ab_stack/test/cypress/support/e2e.js) `RunSQL`).

**Shortcut**

- Seed once via UI, then copy stable UUIDs / rows from MySQL (`mysqldump` or manual `SELECT`)—column names should still match `object.tableName` + field `columnName` / `isSource` rules above; use `DESCRIBE` only to reconcile gaps.

## CI parity

GitHub workflow (if repo uses [`ab_stack/.github/workflows/run.yml`](../../../ab_stack/.github/workflows/run.yml)): compose up, upload defs, `npm run test:ci`. Set `COMPOSE_PROJECT_NAME` the same as local `.env` when the job runs `docker compose` from the same working directory.
