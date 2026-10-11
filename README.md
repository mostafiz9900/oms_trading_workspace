# OMS Trading Flutter workspace

White-label monorepo for OMS broker-house trading apps. `apps/` holds only
deployable broker apps (thin orchestrators); `packages/` holds all common code.
Dart workspace + Melos 8, Flutter 3.47.6 pinned through FVM. State, routing and
storage stay on GetX/GetStorage exactly as in the live app.

## Layout

```text
oms_trading_workspace/
├── .github/workflows/ci.yml     Parallel analyze matrix, tests, Android + iOS builds
├── apps/
│   ├── benemoy/                 Live Benemoy app (no business logic)
│   │   ├── lib/
│   │   │   ├── main_uat.dart    Flavor entry points
│   │   │   ├── main_prod.dart
│   │   │   ├── firebase_options.dart
│   │   │   └── src/
│   │   │       ├── app.dart           GetMaterialApp wrapper
│   │   │       ├── routing/           Route table stitching the features
│   │   │       ├── house_profile.dart Contact page, share text, store ids
│   │   │       └── run.dart           Shared startup for both entry points
│   │   ├── assets/houses/benemoy/     Logo, splash, onboarding images
│   │   ├── config/houses/             uat/prod env JSON, Android flavor, brand manifest
│   │   └── android/ ios/              Copied from the live project (app id, icons,
│   │                                  Firebase, signing, entitlements)
│   └── app_fakhrul/             Starter app, not yet converted
├── packages/
│   ├── core/                    trading_core, trading_ui, broker_config
│   ├── shared/
│   │   ├── localization/        Translations and locale handling
│   │   └── oms_shared/          Screens, controllers, services (transitional, see below)
│   └── features/                auth, market, orders, portfolio, notifications,
│                                research, withdrawals, limits
├── bricks/                      Mason generators
├── tool/validate_house_profiles.dart
└── pubspec.yaml                 Workspace root + Melos config (scripts, versioning)
```

Dependencies only point downward: `apps` → `shared` → `features` → `core`.
Nothing in `packages/` may import an app.

## Running

```sh
fvm dart run melos bootstrap

cd apps/benemoy
fvm flutter run -t lib/main_uat.dart \
  --dart-define-from-file=config/houses/benemoy-uat.json
fvm flutter build appbundle -t lib/main_prod.dart \
  --dart-define-from-file=config/houses/benemoy-prod.json
```

The entry point and the env JSON must agree: `main_uat.dart` with a profile
whose `OMS_ENV` is `uat`, otherwise startup fails immediately. Env JSON files
are git-ignored; `broker.example.json` documents every key. Dart defines are
compiled into the binary, so never put passwords or signing credentials in them.

## What a broker house owns

| Concern | Where |
|---|---|
| API / socket URLs per environment | `config/houses/<house>-uat.json`, `-prod.json` |
| App name, logo, splash, onboarding, colors | `OMS_HOUSE_NAME`, `OMS_BRAND_*` keys + `assets/houses/<house>/` |
| Contact page, share text, store links | `lib/src/house_profile.dart` |
| Which screens exist and their routes | `lib/src/routing/app_pages.dart` |
| App id, bundle id, icon, Firebase, signing, entitlements | `android/`, `ios/` (one native project per house app), `lib/firebase_options.dart` |

## Workspace commands

```sh
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run validate:houses
fvm dart run melos version        # bump versions + CHANGELOGs from conventional commits
```

Each house app has its own plain Flutter `android/` and `ios/` folders (no
Gradle flavors). Benemoy's were copied from the live project; the only edits
are the minimums Flutter 3.47.6 requires: Gradle wrapper 8.13 → 8.14, Kotlin
plugin 2.1.0 → 2.2.20, and two `gradle.properties` flags added by Flutter's
migrator. `config/houses/android/<house>.properties` is metadata that
`validate:houses` checks against the real Gradle `applicationId`.

CI needs one repository secret, `BENEMOY_UAT_PROFILE_JSON`, containing the
UAT env JSON.

## Migration status

| Phase | Scope | Status |
|---|---|---|
| 1 | App rename, flavor entries, app wrapper + routing in app, CI, localization package | Done |
| 2 | Split `core` (network, storage, theme, utils) and `shared/design_system` out of `oms_shared`; remove the `app_pkg.dart` barrel and controller dependencies from services | Planned |
| 3 | Move small modules into `features/*/lib/src/{data,domain,presentation}` (auth, onboarding, splash, contact_us, withdrawals, limits, order_alert, top_share) | Planned |
| 4 | Split the `home` module (~30k LOC, incl. `home_controller.dart`) into market, orders, portfolio, watchlist and notifications | Planned |

`oms_shared` is transitional: it empties out phase by phase into `core`,
`design_system` and the feature packages. No compile errors; it still carries
~590 legacy analyzer warnings/info inherited from the original app. Only
`broker_config` has unit tests.
