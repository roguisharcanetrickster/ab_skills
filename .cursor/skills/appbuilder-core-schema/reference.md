# AppBuilder export — quick shape

Full sample: [app_miniApp_20260416.json](../../../app_miniApp_20260416.json).

## Top-level

```json
{
  "abVersion": "0.0.0",
  "filename": "<slug>",
  "date": "YYYYMMDD",
  "definitions": [ /* application, objects, fields */ ],
  "files": {},
  "siteObjectConnections": {},
  "roles": []
}
```

## Tree

- **application** — one row; `json.json.objectIDs` lists object UUIDs; nested `versionData`, `translations`, empty ID arrays.
- **object** — `tableName`, `primaryColumnName: "uuid"`, `fieldIDs`, `createdInAppID`.
- **field** — `key` + `columnName` + `settings` + `translations`.

## 1:N connectObject (abbreviated)

From sample: **Diners** (parent, many children conceptually from diner side field) ↔ **Reservation** (child holds FK).

**Child / FK side** (`Reservation->Customer`, `isSource: 1`):

- `linkType`: `"one"`, `linkViaType`: `"many"`, `linkObject`: `<DinersObjectId>`, `linkColumn`: `<DinersReservationFieldId>`.

**Parent inverse** (`Diners->Reservation`, `isSource: 0`):

- `linkType`: `"many"`, `linkViaType`: `"one"`, `linkObject`: `<ReservationObjectId>`, `linkColumn`: `<ReservationCustomerFieldId>`.

`linkColumn` always points to the **paired** field’s `id`, not the object id.

## Many-to-many style (junction)

Not in sample; pattern for **Group Memberships**:

- Two `connectObject` pairs: Membership ↔ Mother, Membership ↔ Group.
- On **Group Memberships**, both outgoing links use `isSource: 1` (FK columns on junction table).
- On **Mothers** and **Groups**, each inverse membership link uses `isSource: 0`.

Each pair still obeys one/many cross from the two field definitions.

## Scalar keys (from sample)

| key         | icon      | Notable settings |
|------------|-----------|------------------|
| AutoIndex  | key       | `displayLength`, `previewText`, `delimiter` |
| string     | font      | `maxLength`, `default`, `supportMultilingual` |
| number     | hashtag   | `typeFormat`, decimals, rounding, thousands |
| datetime   | clock-o   | `dateFormat`, `timeFormat`, default value ISO |
| connectObject | external-link | `linkObject`, `linkType`, `linkViaType`, `linkColumn`, `isSource` |
