# Releasing Benemoy (CI/CD)

## What runs where

| Branch | GitHub Actions | Result |
|---|---|---|
| `dev`, `uat`, `main`, any other branch, pull requests | `CI` (`.github/workflows/ci.yml`) | analyze, all tests, app validation, Android + iOS debug builds |
| `prod` | `Release Benemoy` (`.github/workflows/release.yml`) | the same CI checks, then **Android → Google Play** and **iOS → TestFlight** |

A release only starts when every check passes. Two releases never run at the
same time.

What the release does, and what stays manual:

- **Google Play**: uploads a signed App Bundle to the **production** track as a
  **draft**. Nobody gets it until you open Play Console → Benemoy → Production
  and press **Roll out** (choose a staged percentage there if you like).
- **App Store**: uploads a signed build to **TestFlight**. To ship it, open App
  Store Connect, add the build to the version and **Submit for Review**.

## Versions

- **Android** version name comes from `apps/benemoy/pubspec.yaml`
  (`version: 1.0.36+36` → `1.0.36`).
- **iOS** version comes from `apps/benemoy/ios/Runner/Info.plist`
  (`CFBundleShortVersionString`, currently `1.0.26`). The two differ on purpose,
  exactly as in the live app.
- **Build numbers are automatic**: fastlane reads the highest build number
  already in Play / TestFlight and adds 1. You never bump them by hand.

Before a release, raise the version name where needed:

- **Android:** bump the version in `pubspec.yaml`.
- **iOS:** bump it in `Info.plist`, after the previous iOS version has been
  approved.

## Release steps

1. Merge the tested work into `prod` (for example `dev` → `main` → `prod` by
   pull request) and push.
2. Watch **Actions → Release Benemoy**. If the `production` environment has
   reviewers (recommended, see below), approve the release there.
3. Roll out in Play Console and submit for review in App Store Connect.

## One-time setup

All commands run from the workspace root on the Mac that holds the live keys.
`gh` is the GitHub CLI (`brew install gh`, then `gh auth login`).

### 1. GitHub environment `production`

Create it in **Settings → Environments → New environment →
`production`**. Add yourself under **Required reviewers**, so no store upload
starts without a click. Put the release secrets below in this environment
(`--env production`).

### 2. Secrets

| Secret | Used for | How to create |
|---|---|---|
| `BENEMOY_UAT_PROFILE_JSON` (repository secret) | CI builds | `gh secret set BENEMOY_UAT_PROFILE_JSON < apps/benemoy/env/uat.json` |
| `BENEMOY_PROD_ENV_JSON` | release builds | `gh secret set BENEMOY_PROD_ENV_JSON --env production < apps/benemoy/env/prod.json` |
| `BENEMOY_ANDROID_KEYSTORE_BASE64` | Android signing | `base64 -i apps/benemoy/android/oms-app-release-key.jks \| gh secret set BENEMOY_ANDROID_KEYSTORE_BASE64 --env production` |
| `BENEMOY_ANDROID_STORE_PASSWORD`, `BENEMOY_ANDROID_KEY_PASSWORD`, `BENEMOY_ANDROID_KEY_ALIAS` | Android signing | the `storePassword`, `keyPassword`, `keyAlias` values from `apps/benemoy/android/key.properties`, each via `gh secret set NAME --env production` (it prompts for the value) |
| `BENEMOY_PLAY_SERVICE_ACCOUNT_JSON` | Play upload | see 3 below, then `gh secret set BENEMOY_PLAY_SERVICE_ACCOUNT_JSON --env production < play-service-account.json` |
| `BENEMOY_ASC_KEY_ID`, `BENEMOY_ASC_ISSUER_ID`, `BENEMOY_ASC_KEY_P8` | App Store Connect | see 4 below; the `.p8` file: `gh secret set BENEMOY_ASC_KEY_P8 --env production < AuthKey_XXXX.p8` |
| `BENEMOY_IOS_DIST_CERT_P12_BASE64`, `BENEMOY_IOS_DIST_CERT_PASSWORD` | iOS signing | see 5 below |
| `BENEMOY_IOS_PROVISION_PROFILE_BASE64` | iOS signing | see 5 below |

Never commit any of these files. The repo's `.gitignore` blocks env JSON,
keystores, `key.properties`, `.p12`, `.p8`, `.mobileprovision` and
service-account JSON.

### 3. Google Play service account

1. Google Cloud console (the project linked to Play Console) → **IAM &
   Admin → Service accounts** → create one → **Keys → Add key → JSON**.
2. Play Console → **Users and permissions** → invite the service account's
   email. For the Benemoy app, grant: view app information, release to
   production, and release to testing tracks.

### 4. App Store Connect API key

App Store Connect → **Users and Access → Integrations → App Store Connect
API** → generate a key with the **App Manager** role. Note the **Key ID** and
**Issuer ID**, and download the `.p8` file. It can be downloaded only once.

### 5. iOS distribution certificate and profile

1. **Certificate.** In Keychain Access, find **Apple Distribution: …
   (VGW88Y8A73)**, the one used for the live app. Export it with its private
   key as `dist.p12` and choose a password. Then:
   ```sh
   base64 -i dist.p12 | gh secret set BENEMOY_IOS_DIST_CERT_P12_BASE64 --env production
   gh secret set BENEMOY_IOS_DIST_CERT_PASSWORD --env production
   ```
2. **Profile.** In the Apple Developer portal, go to **Profiles** and create (or
   download) an **App Store** profile for `com.benemoysecurities.app` that uses
   that certificate. Then:
   ```sh
   base64 -i Benemoy_AppStore.mobileprovision | gh secret set BENEMOY_IOS_PROVISION_PROFILE_BASE64 --env production
   ```
3. When the certificate or profile expires (yearly), repeat these two commands.

## Releasing from a Mac (without CI)

This uses the same lanes. You need `apps/benemoy/env/prod.json` and
`android/key.properties` with the keystore. iOS uses Xcode's automatic signing
with your Apple account.

```sh
export PLAY_SERVICE_ACCOUNT_JSON_PATH=~/keys/play-service-account.json
make deploy-android

export ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_P8="$(cat ~/keys/AuthKey_XXXX.p8)"
make deploy-ios
```

Optional overrides:

- `PLAY_TRACK=internal`: upload to internal testing instead of production.
- `PLAY_RELEASE_STATUS=completed`: release at once instead of as a draft. Use
  with care.

## Adding another house

`make new-app` copies `fastlane/` with the new app ids. For the new house:

1. Set its Apple team in `apps/<house>/fastlane/` (it is `TODO_TEAM_ID`).
2. Copy `release.yml` as `release-<house>.yml`, using `apps/<house>`, the
   house's own `<HOUSE>_…` secrets, and its own release branch.
