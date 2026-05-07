---
name: ab-plugin
description: Scaffold AppBuilder plugins—ClassManager types (view/object/properties), webpack UMD/ESM bundles, tenant bootstrap contract, and library-only service plugins (e.g. ab_mvc on AB.abMvc).
---

# AB plugins (AppBuilder)

Use when adding or fixing plugins under `developer/plugins/`, wiring tenant plugin URLs, or debugging `pluginRegister` / `ABBootstrap.loadPlugin`.

## Decision tree

| Goal | Pattern |
|------|---------|
| New **view** widgets in Designer (canvas + properties) | Factory extending `ABViewPlugin` / `ABViewPropertiesPlugin` / `ABViewEditorPlugin`; `getPluginType()` → `view`, `properties-view`, `editor-view`; register via `AB.pluginRegister(factory)`. |
| New **object** type + builder UI + model | Like NetSuite: service `service.js` factory returns `[ ObjectClass ]`; web/properties separate entries if needed; `getPluginType()` → `object`, `properties-object`. |
| **Service-only helpers** (validate/persist, no new AB types) | Webpack service entry must still export a **factory function**; attach API on `pluginAPI.AB` (e.g. `pluginAPI.AB.abMvc = lib`) and `return []`. Do **not** export a plain object as UMD `Plugin`. |

## Core contracts

**`AB.pluginRegister(plugin)`** ([`ABFactoryCore`](developer/ab_platform_web/AppBuilder/core/ABFactoryCore.js)): `plugin` is a **function**. It is called as `plugin(pluginAPI)` where `pluginAPI` includes bases from `getPluginAPI()`, plus **`AB`** and **`platform`**. Return value: **one class** or **array of classes**, each with `static getPluginType()` and `static getPluginKey()`.

**`ABClassManager.pluginRegister`** dispatches on `getPluginType()`: `object`, `properties-object`, `view`, `properties-view`, `editor-view`.

**Tenant service bootstrap** ([`ABBootstrap.loadPlugin`](developer/appbuilder/AppBuilder/ABBootstrap.js)): loads script from URL into VM, resolves `module.exports.Plugin`, calls **`newFactory.pluginRegister(Plugin)`**. So **`Plugin` must be the factory function**, not `{ parseBundle, ... }`.

**Shell vs optional plugins**: Plugins are **optional** and **self-contained**—no cross-plugin imports. **`ABDesigner`** (Designer shell under `developer/plugins/ABDesigner/`) **must not** reference optional-plugin APIs (`AB.abMvc`, other plugin-only globals) or depend on another plugin being loaded. Core Designer flows use **platform `AB` + HTTP routes / ClassManager-registered types only**. Server-side services may `require` a plugin’s Node module (e.g. bundle handler); that is **not** Designer consuming the plugin.

## Recent learnings (cross-agent)

- **Process create path (current):** Designer new-process uses platform helpers: `AB.definitionBundleNewMinimalProcess(values)` + `AB.definitionBundleCreate(bundle)` in `ABFactory`; request goes to `POST /definition/bundle/create`; server-side validation/persist runs via `ab_mvc` handler path.
- **Do not couple shell to plugin API:** `ABDesigner` must stay plugin-agnostic; no direct `AB.abMvc` usage in shell code.
- **Minimal process bundle shape:** builder creates process via `AB.processNew()` + `modelNew()`, adds Start trigger (`diagramID: "StartEvent_1"`, `type: "trigger"`), sets translations, sends `{ process, children[] }` definitions bundle.
- **Sync gotcha fixed:** `definitionSync("created")` in `ABFactoryCore` now de-duplicates by `id` before push to avoid duplicates when HTTP parse + RT socket both emit.
- **Browser vs service API:** `persistBundle(req, AB, bundle)` needs service `req`; browser should call HTTP `definitionBundleCreate()`, not call `persistBundle` directly.

## Verification checklist (when changing plugin flow)

- `ab_mvc` service bundle export is callable factory (`module.exports.Plugin` fn), not plain object.
- `ABDesigner` changes use platform `ABFactory` methods only; no optional plugin references.
- Bundle payload passes schema + semantic checks (`xmlDefinition` and child `diagramID` alignment).
- Realtime + local parse do not duplicate process rows in `_allProcesses`.
- Update docs: `plugin_overview.md` + plugin README if API/flow changes.

## Reference implementations

| Plugin | Role |
|--------|------|
| **ABDesigner** | [`index.js`](developer/plugins/ABDesigner/index.js): `window.__AB_Plugins` → `apply` loads `LocalPlugins.load(AB)` then `AB.pluginLoad(ApplicationFactory(AB))`. Extra views in [`src/plugins/index.js`](developer/plugins/ABDesigner/src/plugins/index.js). |
| **NetSuite API** | [`service.js`](developer/plugins/ab_plugin_object_netsuite_api/service.js): `export default function (api) { return [ FNObjectNetsuite(api) ]; }`. Webpack UMD exposes **`Plugin`** as that factory. |
| **ab_mvc** | [`service.js`](developer/plugins/ab_plugin_ab_mvc/service.js): factory sets **`pluginAPI.AB.abMvc`** to `{ parseBundle, validateBundle, persistBundle }`, returns **`[]`**. Rebuild with `npm run build:update` in the plugin dir. Browser/new-process UX: **`AB.definitionBundleNewMinimalProcess`** + **`AB.definitionBundleCreate`** (platform), not `AB.abMvc` / `persistBundle` (needs service `req`). |

## Webpack service bundle

- Output global **`Plugin`** (UMD) must equal the **factory function**.
- Mirror [`ab_plugin_object_netsuite_api/webpack.common.js`](developer/plugins/ab_plugin_object_netsuite_api/webpack.common.js): service entry → UMD; web/properties may be ESM `.mjs`.

## Pitfalls

- **`registerLib`** on `pluginAPI`: not implemented in core paths—do not rely on it unless you add it to the platform. Tenant/custom code may use **`AB.abMvc`** after load—**not** `ABDesigner` shell (see boundary above).
- **Plain object as `Plugin`**: breaks `pluginRegister` (`TypeError: plugin is not a function`).
- **Key alignment**: `getPluginKey()` / view `key` must match definitions / Designer expectations.

## ab_mvc failure modes (fixed)

1. Old `service.js` re-exported the lib object → UMD `Plugin` was not callable.
2. `index.js` used only `registerLib` → never wired on real bootstrap.

Fix: factory + attach on `pluginAPI.AB.abMvc`; optional `index.js` mirrors attach if `API.AB` exists.
