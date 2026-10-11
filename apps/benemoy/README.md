# Benemoy OMS mobile app

This is the existing Benemoy trading app inside the OMS Dart/Melos workspace.
The live UI and feature implementation remain in place.

## FVM commands

Run from this package directory, pairing each entry point with its profile:

```sh
cd apps/benemoy
fvm flutter run -t lib/main_uat.dart \
  --dart-define-from-file=config/houses/benemoy-uat.json
```

Use `lib/main_prod.dart` with `benemoy-prod.json` for production. A mismatched
pair fails at startup. The two local profile files are git-ignored. All screens
and logic live in `packages/shared/oms_shared`; this app only owns
`lib/src/house_profile.dart`, `lib/src/app.dart`, `lib/src/routing/`, brand
assets, env profiles and native configuration.

## Android release

Build the signed Benemoy App Bundle with the original release key:

```sh
fvm flutter build appbundle \
  -t lib/main_prod.dart \
  --release \
  --dart-define-from-file=config/houses/benemoy-prod.json
```

The original Android release key is loaded from the local, git-ignored
`android/key.properties` and `android/oms-app-release-key.jks`. Release builds
do not fall back to the debug key. Keep a secure backup of the original key.

## Broker-house profiles

Create a new local profile with the repo's Mason brick:

```sh
fvm exec mason make house_profile --output-dir apps/benemoy
```

It generates an environment-specific Dart define JSON and Android metadata
(`config/houses/android/<house>.properties`, checked by `validate:houses`
against the real Gradle `applicationId`). Replace all `.invalid` endpoint and
Firebase placeholders before building. Do not put passwords, signing keys, or
other secrets in Dart defines; values compiled into the app can be read from
the binary. CI should inject profiles from a configuration store.

`android/` and `ios/` are a plain Flutter native project copied from the live
Benemoy app (no flavors): app id, bundle id, Firebase files
(`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`),
signing and push entitlements are exactly as in production, except the Gradle
wrapper (8.14) and Kotlin plugin (2.2.20) minimums Flutter 3.47.6 requires.
An iOS distribution archive still needs the Apple provisioning profile on the
release machine.
