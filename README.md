# OMS Trading Flutter workspace

This repository is a Dart workspace managed with Melos 8, pinned to Flutter
3.47.6 through FVM. The live Benemoy app remains under `apps/app_benemoy`;
this workspace conversion does not redesign its UI or move its Dart screens.

## Workspace layout

```text
apps/                  Deployable Flutter applications
packages/core/         Shared platform-independent and visual foundations
packages/features/     Reusable bounded feature packages
bricks/                Mason generators for house profiles and feature packages
```

`trading_core`, `trading_ui`, and `broker_config` are shared package
foundations. `auth` owns login and profile/onboarding DTOs, while `market` owns
market data models, repository contracts, tick handling, and market
calculations. `orders` owns reusable order request and response models, and
`withdrawals` owns withdrawal request/history DTOs. Benemoy keeps compatibility
exports for migrated types; its screens and live feature flows remain in the
app while cohesive slices move. `portfolio` owns reusable balance and position
response models, and `notifications` owns notification and order-alert DTOs.
`research` owns issuer fundamentals, dividends, EPS, and issuer news models.
`limits` owns the client limit response model.

## FVM and Melos

Use the pinned FVM SDK for all Flutter and Dart commands:

```sh
fvm flutter --version
fvm dart run melos bootstrap
fvm dart run melos list
fvm dart run melos run analyze
```

Melos 8 configuration lives in the root `pubspec.yaml` alongside the Dart
workspace. Workspace member globs include new apps under `apps/*` and packages
under `packages/*/*` automatically.

The current full-workspace analyzer reports 605 legacy diagnostics in
`app_benemoy` (warnings/info, including existing lint and deprecation findings).
The other 11 workspace packages analyze clean when checked with
`melos exec --ignore=app_benemoy -- fvm dart analyze .`; touched app compatibility
entry points are also analyzed directly. The Benemoy UAT debug APK build is the
integration compile gate. Unit/widget test suites have not been run.

## Mason

Mason is installed globally but should run with the workspace's FVM Dart:

```sh
fvm exec mason get
fvm exec mason list
fvm exec mason make house_profile --output-dir apps/app_benemoy
fvm exec mason make feature_package --output-dir .
```

`house_profile` creates local Dart define and Android flavor metadata.
`feature_package` creates a workspace package skeleton with the standard
data/domain/presentation folders. Add generated feature packages immediately
with `fvm dart run melos bootstrap`.

## Benemoy house profiles

Local UAT/production profiles live at:

```text
apps/app_benemoy/config/houses/benemoy-uat.json
apps/app_benemoy/config/houses/benemoy-prod.json
```

These files are git-ignored. Build with the profile for the matching
environment:

```sh
cd apps/app_benemoy
fvm flutter run --flavor benemoy \
  --dart-define-from-file=config/houses/benemoy-uat.json
```

The profile also selects `OMS_ENV`. Use `benemoy-prod.json` for production builds. Dart defines
are compiled into the app and are not a secure secret store; never put passwords,
private keys, or signing credentials in them. Provide profiles to CI from a
secret/configuration store. The existing Benemoy dotenv files remain as a local
backward-compatible fallback.

Android flavor identity is in
`apps/app_benemoy/config/houses/android/benemoy.properties`. Firebase's native
Android and iOS configuration stays platform-specific. Signing files and local
house profiles are excluded from source control.
