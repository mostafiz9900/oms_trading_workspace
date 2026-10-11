# OMS Trading Flutter workspace

White-label monorepo for OMS broker-house trading apps. Each broker house is a
small app in `apps/`; every screen and all logic live in `packages/` and are
shared. Dart workspace + Melos 8, Flutter 3.47.6 pinned through FVM. State,
routing and storage stay on GetX/GetStorage exactly as in the live app.

## Daily workflow

Everything runs from the workspace root with `make`. You never need to `cd`
into an app.

```sh
make setup              # first time, and after every git pull
make run                # develop: Benemoy on UAT
```

| I want to... | Command |
|---|---|
| Work on a feature / fix a bug | `make run` (always UAT while developing) |
| Check a production-only issue | `make run ENV=prod` |
| Test another broker house | `make run APP=fakhrul` |
| Release to Play Store / App Store | `make appbundle` / `make ipa` (production automatically) |
| Before pushing | `make check` |
| iOS build complains about pods | `make pods` |
| Strange build errors | `make clean`, then `make run` |
| See every command | `make` |

Rules of thumb:

- **UAT vs prod:** develop and test on UAT. Production is only for release
  builds (which pick it automatically) or reproducing a live issue.
- **Benemoy vs other houses:** shared code is the same for every house, so
  develop on Benemoy (the default). Switch `APP=` only for house-specific work.
- **`fvm flutter ...`:** only for commands `make` does not cover, e.g.
  `fvm flutter pub add <package>` inside a package. Always prefix with `fvm`
  so the pinned Flutter 3.47.6 is used. VS Code uses the same SDK after
  `make setup`.
- **Pods:** `make run`/`make ipa` run `pod install` themselves; use
  `make pods` only when iOS reports a pods error.
- **Melos** runs inside `make` (multi-package analyze, `melos version`);
  you do not call it directly.

In VS Code you can also pick **Benemoy UAT** / **Benemoy Prod** in Run and
Debug and press F5.

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
│   │   └── oms_shared/          The app itself, in GetX CLI layout (below)
├── tool/                        new_app.dart, validate_apps.dart
├── Makefile                     Day-to-day commands
└── pubspec.yaml                 Workspace root + Melos config
```

Dependencies only point downward: `apps` → `shared` → `core`.
Nothing in `packages/` may import an app.

## Where code goes (GetX CLI layout)

All screens and logic live in `packages/shared/oms_shared/lib/app/`, in the
same layout `get create page` produces. There is no separate `features/`
folder: a new screen is a new module.

```text
lib/app/
├── modules/<name>/        bindings/, controllers/, views/  (one per screen/flow)
├── data/
│   ├── models/            request/ and response/ DTOs
│   ├── providers/         API calls
│   ├── repositories/      Repositories and repository contracts
│   └── services/          Sockets, storage, market tick store, aggregators
├── routes/                app_routes.dart (route names; pages are in the app)
├── global_widgets/        Widgets shared by several modules
└── core/                  theme, utils, values
```

To add a screen, run `get create page:<name>` inside
`packages/shared/oms_shared` (or copy an existing module), then register the
route in `apps/<house>/lib/src/routing/`.

## Adding a broker house

```sh
make new-app ID=fakhrul NAME="Fakhrul Securities" \
  ANDROID_ID=com.fakhrulsecurities.app IOS_ID=com.fakhrulsecurities.app
```

This copies Benemoy's app (never its env files, Firebase files or signing
keys), sets the new app id, bundle id and name everywhere, and prints the
remaining checklist: env files, brand images, contact details, `flutterfire
configure`, launcher icons and signing. `make validate` reports whatever is
still missing. Full step-by-step guide: [docs/new-app.md](docs/new-app.md).

## CI/CD

- **Every branch and PR** (`.github/workflows/ci.yml`): analyze every package,
  all tests, `make validate`, Benemoy Android + iOS debug builds.
- **Push to `prod`** (`.github/workflows/release.yml`): the same checks, then
  fastlane uploads Benemoy to **Google Play** (production, as a draft to roll
  out) and **TestFlight**.

Secrets, store setup and the release steps: [docs/release.md](docs/release.md).

## Migration status

| Phase | Scope | Status |
|---|---|---|
| 1 | App layout, entry points, routing in app, CI, localization package, live native projects | Done |
| 2 | Split `core` (network, storage, theme, utils) and `shared/design_system` out of `oms_shared`; remove the `app_pkg.dart` barrel | Planned |
| 3 | Fold the old `packages/features/*` DTO packages back into `oms_shared/lib/app/data` (GetX CLI layout only) | Done |
| 4 | Split the `home` module (~30k LOC) into GetX modules: market, orders, portfolio, watchlist, notifications | Planned |

`oms_shared` empties out phase by phase. It has no compile errors but still
carries ~590 legacy analyzer warnings/info from the original app. Only
`broker_config` has unit tests.
# oms_trading_workspace
# oms_trading_workspace
