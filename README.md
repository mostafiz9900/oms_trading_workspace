# OMS Trading Flutter workspace

White-label monorepo for OMS broker-house trading apps. Each broker house is a
small app in `apps/`; every screen and all logic live in `packages/` and are
shared. Dart workspace + Melos 8, Flutter 3.47.6 pinned through FVM. State,
routing and storage stay on GetX/GetStorage exactly as in the live app.

## Quick start

```sh
make setup              # once: install dependencies
make run                # Benemoy on UAT (pick the device when asked)
```

Everything else:

```sh
make run ENV=prod       # production servers
make run APP=fakhrul    # another broker house
make appbundle          # Play Store release   (defaults to prod)
make ipa                # App Store release    (defaults to prod)
make check              # analyze + test + validate
make                    # list all commands
```

In VS Code, pick **Benemoy UAT** or **Benemoy Prod** in Run and Debug and press F5.

A run needs `apps/<app>/env/<env>.json`. These files hold server URLs and are
git-ignored; copy `env/example.json` to create them. Never put passwords or
signing keys in them, since their values are compiled into the app.

## Layout

```text
oms_trading_workspace/
├── apps/                        One folder per broker house
│   └── benemoy/
│       ├── env/                 uat.json, prod.json (git-ignored), example.json
│       ├── assets/brand/        Logo, splash, onboarding images
│       ├── lib/
│       │   ├── main_uat.dart    Entry points
│       │   ├── main_prod.dart
│       │   └── src/
│       │       ├── house_profile.dart   Contact page, share text, store ids
│       │       ├── app.dart             GetMaterialApp
│       │       └── routing/             Route table
│       └── android/ ios/        Native projects (copied from the live app)
├── packages/
│   ├── core/                    trading_core, trading_ui, broker_config
│   ├── shared/
│   │   ├── localization/        Translations
│   │   └── oms_shared/          Screens, controllers, services (transitional)
│   └── features/                auth, market, orders, portfolio, notifications,
│                                research, withdrawals, limits
├── tool/                        new_app.dart, validate_apps.dart
├── Makefile                     Day-to-day commands
└── pubspec.yaml                 Workspace root + Melos config
```

Dependencies only point downward: `apps` → `shared` → `features` → `core`.
Nothing in `packages/` may import an app.

## Adding a broker house

```sh
make new-app ID=fakhrul NAME="Fakhrul Securities" \
  ANDROID_ID=com.fakhrulsecurities.app IOS_ID=com.fakhrulsecurities.app
```

This copies Benemoy's app (never its env files, Firebase files or signing
keys), sets the new app id, bundle id and name everywhere, and prints the
remaining checklist: env files, brand images, contact details, `flutterfire
configure`, launcher icons and signing. `make validate` reports whatever is
still missing.

## CI

`.github/workflows/ci.yml` analyzes every package in parallel, runs tests and
`make validate`, then builds Benemoy for Android and iOS. It needs one
repository secret, `BENEMOY_UAT_PROFILE_JSON`, with the contents of
`apps/benemoy/env/uat.json`.

## Migration status

| Phase | Scope | Status |
|---|---|---|
| 1 | App layout, entry points, routing in app, CI, localization package, live native projects | Done |
| 2 | Split `core` (network, storage, theme, utils) and `shared/design_system` out of `oms_shared`; remove the `app_pkg.dart` barrel | Planned |
| 3 | Move small modules into `features/*/lib/src/{data,domain,presentation}` | Planned |
| 4 | Split the `home` module (~30k LOC) into market, orders, portfolio, watchlist, notifications | Planned |

`oms_shared` empties out phase by phase. It has no compile errors but still
carries ~590 legacy analyzer warnings/info from the original app. Only
`broker_config` has unit tests.
