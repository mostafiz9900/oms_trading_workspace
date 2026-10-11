# OMS Trading Flutter workspace

White-label monorepo for OMS broker-house trading apps. `apps/` holds only
deployable broker apps (thin shells); `packages/` holds all common code.
`packages/shared/oms_shared` contains every screen and service and is shipped
under each broker's identity by its shell. Dart workspace + Melos 8, Flutter 3.47.6 pinned through FVM.

## Layout

```text
apps/
  app_benemoy/                 Live Benemoy shell (only house-specific code)
    lib/main.dart              runOmsApp(profile, Firebase options, FCM handler)
    lib/house_profile.dart     Company details: contact page, share text, store ids
    lib/firebase_options.dart  House Firebase project
    assets/houses/benemoy/     Logo, splash, onboarding images
    config/houses/             Env profiles (uat/prod JSON), Android flavor, brand manifest
    android/ ios/              App id, bundle id, icons, Firebase files, signing
  app_fakhrul/                 Starter app, not yet converted to a house shell
packages/
  core/                        trading_core, trading_ui, broker_config (HouseProfile, env config)
  features/                    auth, market, orders, portfolio, notifications, research,
                               withdrawals, limits (DTOs and repository contracts)
  shared/oms_shared/           Common code for every app: screens, controllers, routes,
                               services, common assets
bricks/                        Mason generators (house_profile, feature_package)
tool/validate_house_profiles.dart
```

## What a broker house owns

| Concern | Where |
|---|---|
| API / socket URLs per environment | `config/houses/<house>-uat.json`, `<house>-prod.json` via `--dart-define-from-file` |
| App name, logo, splash, onboarding images, theme colors | Env profile keys `OMS_HOUSE_NAME`, `OMS_BRAND_*` + files in `assets/houses/<house>/` |
| Contact page, share text, store links / update check | `lib/house_profile.dart` (`HouseProfile`) |
| App id, bundle id, launcher icon, Firebase, signing | `android/`, `ios/`, `config/houses/android/<house>.properties`, `lib/firebase_options.dart` |

Everything else (UI, logic, networking, state) lives in `oms_shared` and the
feature packages and is shared by every house. `OMS_HOUSE_ID` in the env
profile must match `HouseProfile.houseId`; startup fails fast otherwise.

## Commands

```sh
fvm dart run melos bootstrap
fvm dart run melos run analyze
fvm dart run melos run validate:houses

cd apps/app_benemoy
fvm flutter run --flavor benemoy --dart-define-from-file=config/houses/benemoy-uat.json
fvm flutter build appbundle --flavor benemoy --dart-define-from-file=config/houses/benemoy-prod.json
```

Env profile JSON files are git-ignored; `broker.example.json` documents every
key. Provide real profiles to CI from a secret store. Dart defines are compiled
into the binary and are not a secret store: never put passwords, private keys
or signing credentials in them.

## Status

- No compile errors. `oms_shared` carries ~590 legacy analyzer warnings/info
  inherited from the original app; the shells and other packages analyze clean.
- The Benemoy UAT debug APK build is the integration gate. Only
  `broker_config` has unit tests.

## Mason

```sh
fvm exec mason get
fvm exec mason make house_profile --output-dir apps/<app>
fvm exec mason make feature_package --output-dir .
```

Run `fvm dart run melos bootstrap` after generating a package.

## Layers

Dependencies only point downward: `apps` → `shared` → `features` → `core`.
Nothing in `packages/` may import an app.
