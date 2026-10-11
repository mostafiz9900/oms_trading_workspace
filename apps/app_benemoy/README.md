# Benemoy OMS mobile app

This is the existing Benemoy trading app inside the OMS Dart/Melos workspace.
The live UI and feature implementation remain in place.

## FVM commands

Run from this package directory:

```sh
cd apps/app_benemoy
fvm flutter run \
  --flavor benemoy \
  --dart-define-from-file=config/houses/benemoy-uat.json
```

Use `benemoy-prod.json` for production. The two local profile files are
git-ignored. The existing dotenv files remain as a
backward-compatible fallback, but checked-in config templates use invalid
placeholder URLs so they cannot silently point another house at Benemoy.
The shared `broker_config` package provides the app's title, endpoint, brand
asset, default locale, theme colors, and optional contract URL. Benemoy's
defaults preserve its current appearance. Native launcher icons, per-house
iOS schemes, contract-page navigation, and manifest capability handling still
need separate integration work.

## Android release

Build the signed Benemoy App Bundle with the original release key:

```sh
fvm flutter build appbundle \
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
fvm exec mason make house_profile --output-dir apps/app_benemoy
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
