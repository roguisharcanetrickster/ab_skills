---
name: appbuilder-core-schema
description: >-
  Build AppBuilder export JSON from object names + relationships. Matches
  definitions[] shape (application, object, field) like repo
  app_miniApp_*.json. Use when user wants Object-builder–style schema JSON,
  core tables, or standardized AB definitions.
---

# AppBuilder core-schema JSON

## When to use

- User lists **object / table names** (e.g. five core entities) and wants **export JSON** for AppBuilder.
- User says **AppBuilder**, **Object builder**, **definitions**, **`connectObject`**, or **`AB_{App}_Table`** pattern.
- Task: output **one valid JSON document** matching structure observed in project reference `app_miniApp_20260416.json`.

## Inputs (ask if missing)

1. **App display name** — e.g. `miniApp` (used in `application.json.name`, nested `json.name`, labels).
2. **App slug** — short identifier for `filename` and `tableName` prefix (no spaces), e.g. `miniApp` → `AB_miniApp_Mothers`.
3. **Object list** — ordered display names for each **object** row (spaces OK in labels; derive safe `json.name` / PascalCase where needed).
4. **Optional**: relationship overrides, extra fields, different `isSource` side. If absent, use **Default domain model** below.

## Output rules

- Emit **exactly one** markdown fenced block: `json` — **valid JSON only**, no comments inside fence.
- Top-level keys: `abVersion` (`"0.0.0"`), `filename` (slug), `date` (`YYYYMMDD` string), `definitions` (array), `files` (`{}`), `siteObjectConnections` (`{}`), `roles` (`[]`).
- Every definition row: `id` (UUID v4), `name`, `type`, `json`, `createdAt`, `updatedAt` (ISO-8601 UTC with `Z`).
- Use **`roleAccess": []`** on application unless user supplies real role UUIDs.

## definitions[] structure

### 1) application (exactly one)

Mirror `type: "application"` shape from reference:

- Outer + inner `json.id` = application UUID.
- `json.json.objectIDs` = array of **all custom object** UUIDs (order matches user object list unless user specifies).
- `json.json`: `translations`, `name`, `versionData` (minimal changelog entry `1.0.0`), `objectListSettings`, empty `hintIDs`, `queryIDs`, `datacollectionIDs`, `pageIDs`, `processIDs`.
- `json`: `appType: "web"`, `icon` (e.g. `"fa-rocket"`), `isSystemObject: 0`, `roleAccess`, `translations`, `isAccessManaged` / `isTranslationManaged` / `isTutorialManaged` booleans, `accessManagers` / `translationManagers` / `tutorialManagers` objects (copy numeric/null pattern from reference).

### 2) object (one per table)

- `json.type`: `"object"`.
- `json.name`: object display name (match user).
- `json.tableName`: `AB_{AppSlug}_{ObjectNameNoSpaces}` — strip spaces from object part for DB segment; keep consistent casing (reference uses PascalCase after prefix: `AB_miniApp_Diners`).
- `json.primaryColumnName`: `"uuid"`.
- `json.transColumnName`: `""`, `json.urlPath`: `""`, `json.labelFormat`: `""`, `json.labelSettings.isNoLabelDisplay`: `0`.
- `json.isImported`: `0`, `json.isExternal`: `0`, `json.isSystemObject`: `0`.
- `json.objectWorkspace`: `sortFields`, `filterConditions` empty arrays; `frozenColumnID`, `hiddenFields` as in reference.
- `json.translations`: `[{ "language_code": "en", "label": "<ObjectName>" }]`.
- `json.fieldIDs`: ordered list of **all** field UUIDs for this object (see field order below).
- `json.importedFieldIDs`: `[]`, `json.indexIDs`: `[]`.
- `json.createdInAppID`: application UUID.

**Outer `name`**: same as object name (reference pattern).

### 3) field (one row per column / link)

**Naming**: outer `name` = `{ObjectName}->{FieldLabel}` (reference: `Diners->Name`).

**Common**: `json.type`: `"field"`, `json.isImported`: `0`, `json.translations` with `language_code: "en"` and `label` matching UI label.

**Order inside each object’s `fieldIDs`**

1. **AutoIndex** — `key: "AutoIndex"`, `icon: "key"`, `columnName: "index"`, settings: `showIcon`, `required`, `unique`, `validationRules: "[]"`, `prefix`, `delimiter: "none"`, `displayLength` (integer), `previewText` (zeros string same length), `width`.
2. **Scalar fields** — `string` / `datetime` as needed; copy **settings keys** from reference for same `key` (do not invent new keys for known types).
3. **connectObject** fields — last among links for that object; each edge uses **two** field rows (see below).

#### string

- `key: "string"`, `icon: "font"`, `settings`: `default`, `maxLength`, `supportMultilingual`, `width`, plus `showIcon`, `required`, `unique`, `validationRules`.

#### datetime

- `key: "datetime"`, `icon: "clock-o"`, `settings`: `dateFormat`, `defaultDate`, `defaultDateValue`, `validateCondition`, `validateRangeUnit`, `validateRangeBefore`/`After`, `validateStartDate`/`EndDate`, `timeFormat`, `defaultTime`, `defaultTimeValue`, `width`, plus common flags. Use ISO strings for default values (current UTC fine).

#### connectObject (FK / relation)

Each **binary** relation = **two** `field` definitions (A on object X, B on object Y). They **mutually reference** via `settings.linkColumn` = the **other** field’s UUID.

- `key: "connectObject"`, `icon: "external-link"`.
- `columnName`: storage column name on **this** object’s table (often same as related object name or FK name; reference uses `Customer` on Reservation).
- `settings.linkObject`: UUID of the **other** object (not field).
- `settings.linkType` + `settings.linkViaType`: one side `"one"`, other `"many"` (match reference: child / FK side `"one"` + `"many"` paired with parent inverse `"many"` + `"one"`).
- **`settings.isSource`**: `1` on the object that **stores the FK column** (Reservation `Customer` in reference); `0` on the inverse (Diners `Reservation`).
- `settings.linkColumn`: UUID of the paired field.
- Include `isCustomFK`, `indexField`, `indexField2` as in reference; on `isSource: 1` side reference also includes `validationRules`, `required`, `unique`, `netsuiteOneColumn` where present — **mirror reference row** for the same `isSource` value.

**Rule of thumb**: many rows point to one parent → FK on the **many** side → that side’s connect field gets **`isSource: 1`**.

## Default domain model (five core objects)

When user gives only the five names **Mothers**, **Groups**, **Group Meetings**, **Applications**, **Group Memberships**:

| Object            | Scalars (after AutoIndex)                                                                 | Relations |
|-------------------|-------------------------------------------------------------------------------------------|-----------|
| Mothers           | `name`, `description` (strings); `createdAt`, `updatedAt` (datetime)                      | Inverse links: `Applications`, `Group Memberships` (`isSource: 0`) |
| Groups            | same scalars                                                                              | Inverse: `Meetings`, `Applications`, `Group Memberships` (`isSource: 0`) |
| Group Meetings    | `name`, `description` (strings); `scheduledAt` (datetime)                                 | `Group` → Groups (`isSource: 1` on Group Meetings) |
| Applications      | same scalars as Mothers                                                                   | `Mother` → Mothers (`isSource: 1`); `Group` → Groups (`isSource: 1`) |
| Group Memberships | same scalars as Mothers                                                                   | `Mother` → Mothers (`isSource: 1`); `Group` → Groups (`isSource: 1`) |

**Edge list** (create both ends for each):

1. Group Meetings ↔ Groups (many meetings, one group; FK on Group Meetings).
2. Applications ↔ Mothers (many applications, one mother; FK on Applications).
3. Applications ↔ Groups (many applications, one group; FK on Applications).
4. Group Memberships ↔ Mothers (FK on membership).
5. Group Memberships ↔ Groups (FK on membership).

**Inverse field labels** (parent side, `isSource: 0`): e.g. Groups → `Group Meetings`, `Applications`, `Group Memberships`; Mothers → `Applications`, `Group Memberships`. Use clear labels; `columnName` can differ (follow reference style).

## Algorithm

1. Generate a **UUID v4** for application, each object, each field. No duplicates.
2. Build **application** definition; store `appId`.
3. For each object, build **object** definition with **placeholder `fieldIDs: []`** — fill after fields exist, or compute full field id list first in scratchpad then assign.
4. For each object add **AutoIndex** + scalar fields; append field rows to `definitions` in a consistent global order (objects interleaved with their fields is OK if reference-matching; reference interleaves all definitions — **either** group fields after their object **or** follow reference style: object blocks then field blocks — **prefer same ordering style as** `app_miniApp_20260416.json`: object, then its fields, then next object…).
5. Add **connectObject** pairs: for each edge allocate two field UUIDs, set `linkObject` and `linkColumn` cross-refs, append both fields to `definitions`, push both UUIDs into respective `json.fieldIDs` in correct order (connect fields after scalars).
6. Set `application.json.json.objectIDs` to all object UUIDs.
7. Set every object’s `createdInAppID` to `appId`.
8. Run **validation checklist** mentally before send.

## Validation checklist

- [ ] Every `fieldIDs` UUID appears as some `definitions[].id` with `type: "field"`.
- [ ] Every `connectObject` has `linkObject` pointing to an object UUID and `linkColumn` pointing to the paired field UUID.
- [ ] Each relation has exactly one field with `isSource: 1` and one with `isSource: 0`.
- [ ] `tableName` values unique; match `AB_{slug}_*` pattern.
- [ ] JSON parses; no trailing commas.

## Limits

- Only field `key` values **proven in repo reference**: `AutoIndex`, `string`, `number`, `datetime`, `connectObject`. Do not add `longtext` / `image` without a new sample export.

## Reference file in this repo

Use [app_miniApp_20260416.json](../../../app_miniApp_20260416.json) as the **canonical** key/layout source. More notes: [reference.md](reference.md).
