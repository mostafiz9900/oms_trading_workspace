# Benemoy OMS mobile app

This is the existing Benemoy trading app inside the OMS Dart/Melos workspace.
The live UI and feature implementation remain in place.

## FVM commands

Run from this package directory, pairing each entry point with its profile:

```sh
cd apps/benemoy
fvm flutter run -t lib/main_uat.dart --flavor benemoy \
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
  --flavor benemoy \
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

It generates an environment-specific Dart define JSON and an Android flavor
properties file. Replace all `.invalid` endpoint and Firebase placeholders
before building. Android also needs that house's Firebase file at
`android/app/src/<house>/google-services.json`. Do not put passwords, signing
keys, or other secrets in Dart defines; values compiled into the app can be
read from the binary. CI should inject profiles from a configuration store.

Android flavors are discovered from
`config/houses/android/<house>.properties`. The Benemoy Firebase config and
native app identities are already connected. iOS currently builds the
Benemoy scheme with the existing bundle ID and Firebase plist. An iOS
distribution archive still needs a valid Apple Developer provisioning profile
and signing setup on the release machine; per-house iOS schemes are not yet
generated.
