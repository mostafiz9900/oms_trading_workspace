# Monorepo boundaries and migration rules

## Current boundary

- `packages/shared/oms_shared` is the common package (not an app): every screen, controller,
  route, service, and common asset. It starts through `runOmsApp(...)` and must
  not contain broker-specific values; it reads them from `AppConfig.house`
  (env profile) and `AppConfig.profile` (`HouseProfile`).
- `apps/benemoy` is a thin orchestrator: environment entry points
  (`main_uat.dart`, `main_prod.dart`), `src/app.dart` (GetMaterialApp),
  `src/routing/` (route table stitching feature screens), `src/house_profile.dart`,
  Firebase options, brand assets under `assets/houses/benemoy/`, env profiles,
  and native Android/iOS configuration. Route names stay in `oms_shared`
  (`app/routes/app_routes.dart`) because feature code navigates by name.
- `packages/shared/localization` owns GetX translations and locale parsing. Android application id
  and iOS bundle id are unchanged from the live app.
- Values that existing installs depend on are derived from `OMS_HOUSE_ID` so
  they stay byte-identical for Benemoy: notification channel ids
  (`<house>_channel`, `<house>_image_channel`) and the order-id salt
  (`<house>_app`).
- `packages/core/trading_core` owns the generic API result type and stateless
  JWT inspection; app-specific secure storage and navigation remain in each
  deployable app.
- `packages/core/trading_ui` owns broker-neutral responsive layout and surface
  container widgets; broker-specific colors and presentation stay in apps.
- There is no `packages/features/` folder. All DTOs, repository contracts,
  the live market tick store and market calculations live in `oms_shared`
  under the GetX CLI layout: `app/data/models/{request,response}`,
  `app/data/repositories`, `app/data/services`. Screens are GetX modules under
  `app/modules/<name>/{bindings,controllers,views}`.
- `trading_core` owns the generic API error DTO.
- `packages/core/broker_config` owns the typed runtime view of broker-house
  identity, endpoints, logo/splash assets, locale, theme colors, and contract
  URL. Apps supply it only through `--dart-define-from-file`; the legacy
  dotenv fallback is no longer bundled.
- `apps/app_fakhrul` is still a generated Flutter starter, not a broker-house
  deployment. Do not use it as the template for new houses.

## Dependency direction

Dependencies flow `apps` → `packages/shared` → `packages/core`. `apps/` contains only deployable broker shells; all common
code lives under `packages/`. Core packages must not depend on app packages. House identity,
API endpoints, and Firebase registration are deployment configuration, not
copies of the live UI.

## Safe migration rule

Keep the live app stable while introducing workspace/tooling configuration.
Move one cohesive GetX module at a time only when its package boundary, imports,
platform dependencies, and rollback plan are clear. Do not make broker-specific
forks of the full app; use house profiles for configuration and isolated
adapters for behavior that is genuinely different.

## Per-house configuration

- Build-time values such as API and socket endpoints use one UAT or production
  `--dart-define-from-file` profile.
- Native app IDs, icons, Firebase resources, signing, and entitlements live in
  each house app's own plain `android/` and `ios/` project (no Gradle flavors).
- Profiles can choose client capabilities for presentation, but the backend
  remains responsible for authorizing every trading operation.
- Local profiles and signing credentials must not be committed.

### Broker-house app layout

Every app under `apps/<house>/` has the same shape, created by `make new-app`:

| Path | Contents |
|---|---|
| `env/uat.json`, `env/prod.json` | Server URLs, `OMS_HOUSE_ID`, `OMS_HOUSE_NAME`, locale, colors, optional contract URL (git-ignored; `env/example.json` is the template) |
| `assets/brand/` | `logo_light.svg`, `logo_dark.svg`, `splash_light.svg`, `splash_dark.svg`, `onboarding_first.png`, `onboarding_second.png` (fixed names, no config needed; an `OMS_BRAND_*_ASSET` key can override one) |
| `lib/src/house_profile.dart` | Contact page, share text, store ids; `houseId` must equal `OMS_HOUSE_ID` |
| `lib/src/app.dart`, `lib/src/routing/` | GetMaterialApp and the route table |
| `lib/main_uat.dart`, `lib/main_prod.dart` | Entry points; `make run ENV=...` pairs each with its env file |
| `lib/firebase_options.dart`, `android/`, `ios/` | Firebase, app id, bundle id, icons, signing, entitlements |

`make validate` (`tool/validate_apps.dart`) checks every app: env files match
their environment and the house id, URLs and colors are valid, brand assets
exist, Firebase files are present, and Android/iOS ids are unique across apps.
It never prints env values. Env files may be absent in a clean checkout.
