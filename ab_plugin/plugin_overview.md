# AB plugins — overview

Short index for agents working in `developer/plugins/`.

| Doc | Purpose |
|-----|---------|
| **[plugin_skill.md](plugin_skill.md)** | Full checklist: `pluginRegister` factory contract, ClassManager types, ABBootstrap URL loading, NetSuite vs ABDDesigner vs library-only (`ab_mvc`). |

**Working examples**

- Designer shell + extra view registrations: [`developer/plugins/ABDesigner/`](../../plugins/ABDesigner/)
- Object + properties + model (multi-entry webpack): [`developer/plugins/ab_plugin_object_netsuite_api/`](../../plugins/ab_plugin_object_netsuite_api/)
- Service helpers only: [`developer/plugins/ab_plugin_ab_mvc/service.js`](../../plugins/ab_plugin_ab_mvc/service.js) → runtime: **`req.AB.abMvc`** / **`AB.abMvc`** after plugin load (`parseBundle`, `validateBundle`, `persistBundle`)

**Platform anchors**

- [`developer/ab_platform_web/AppBuilder/platform/ABClassManager.js`](../../ab_platform_web/AppBuilder/platform/ABClassManager.js) — `pluginRegister`, `getPluginAPI`
- [`developer/ab_platform_web/AppBuilder/ABFactory.js`](../../ab_platform_web/AppBuilder/ABFactory.js) — `definitionBundleNewMinimalProcess()`, `definitionBundleCreate()`
- [`developer/ab_platform_web/AppBuilder/core/definitionBundleMinimalProcess.js`](../../ab_platform_web/AppBuilder/core/definitionBundleMinimalProcess.js) — minimal process bundle builder
- [`developer/appbuilder/AppBuilder/ABBootstrap.js`](../../appbuilder/AppBuilder/ABBootstrap.js) — tenant plugin URL → `pluginRegister`

**Latest lessons**

- Plugins optional + self-contained; `ABDesigner` must not depend on optional plugin APIs.
- Process creation now runs through platform bundle helpers + `/definition/bundle/create`; `ab_mvc` validates/persists server-side.
- Keep `definitionSync("created")` idempotent to avoid duplicate process entries during mixed HTTP + socket updates.

Rebuild **`ABAbMvc_service.js`** after changing `ab_mvc` service entry: `cd developer/plugins/ab_plugin_ab_mvc && npm run build:update`.
