# Adding a broker-house app

Step-by-step guide for a developer adding a new broker house (example:
Fakhrul Securities). Run every command from the workspace root.

## 0. Collect from the company first

| Item | Used in |
|---|---|
| App name and registered company name | steps 2, 5 |
| Android package id and iOS bundle id (e.g. `com.fakhrulsecurities.app`) | step 2 |
| UAT and production server URLs | step 3 |
| Logo (light/dark), splash (light/dark), two onboarding images, brand colors | steps 3, 4 |
| App icon, 1024×1024 PNG | step 6 |
| Phone, WhatsApp, email, website, office address | step 5 |
| Access to their Firebase project, Apple Developer team, Play Console | steps 6, 7, 9 |

## 1. Prepare the workspace

```sh
git pull
make setup
```

## 2. Create the app

```sh
rm -rf apps/app_fakhrul        # only for Fakhrul: remove the old starter app
make new-app ID=fakhrul NAME="Fakhrul Securities" \
  ANDROID_ID=com.fakhrulsecurities.app IOS_ID=com.fakhrulsecurities.app
```

This copies Benemoy's app and sets the new name, Android package id, iOS
bundle id and `MainActivity` package everywhere. It never copies Benemoy's
env files, Firebase files or signing keys. It ends by printing the checklist
that the steps below follow.

## 3. Server URLs and brand settings: `apps/fakhrul/env/`

```sh
cp apps/fakhrul/env/example.json apps/fakhrul/env/uat.json
cp apps/fakhrul/env/example.json apps/fakhrul/env/prod.json
```

- `uat.json`: UAT server URLs.
- `prod.json`: production server URLs and `"OMS_ENV": "prod"`.
- Keep `OMS_HOUSE_NAME`, colors and locale identical in both files.
- Both files are git-ignored automatically. Never put passwords or keys in
  them; their values are compiled into the app.

## 4. Brand images: `apps/fakhrul/assets/brand/`

Replace these six files, keeping exactly these names (they start out as
Benemoy's images):

```text
logo_light.svg     logo_dark.svg
splash_light.svg   splash_dark.svg
onboarding_first.png   onboarding_second.png
```

Use `apps/benemoy/assets/brand/` as the size reference.

## 5. Company details: `apps/fakhrul/lib/src/house_profile.dart`

Fill in every `TODO`: legal name, phone, WhatsApp, email, website, office
address. `appStoreId` and `appStoreShareUrl` exist only after the App Store
listing is created; until then the `TODO` only produces a warning.

## 6. Firebase and app icon

```sh
cd apps/fakhrul && flutterfire configure && cd ../..
```

- Choose the house's Firebase project and both Android and iOS. This writes
  `lib/firebase_options.dart`, `android/app/google-services.json` and
  `ios/Runner/GoogleService-Info.plist`.
- For iOS push notifications, upload the house's Apple APNs key in the
  Firebase console.
- Open **Crashlytics** in the house's Firebase console once. The app already
  reports uncaught errors from release builds (`lib/src/run.dart`).
- App icon:
  - Android: replace `android/app/src/main/res/mipmap-*/` (Android Studio →
    Image Asset generates all sizes).
  - iOS: replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

## 7. Signing

- **Android:** create a new keystore and put `key.properties` plus the `.jks`
  in `apps/fakhrul/android/` (same format as Benemoy). Both are git-ignored.
  **Back up the keystore**: without it the app can never be updated on the
  Play Store.
- **iOS:** open `apps/fakhrul/ios/Runner.xcworkspace` in Xcode → Signing &
  Capabilities. It starts with Benemoy's team (`VGW88Y8A73`); change it if
  the house publishes under its own Apple account.

## 8. Validate and run

```sh
make validate                       # lists anything still missing; fix all
make run APP=fakhrul                # test on UAT
make run APP=fakhrul ENV=prod       # one check against production
```

Test login, splash, onboarding, the contact page and notifications.

If the house should not have a screen, remove its route from
`apps/fakhrul/lib/src/routing/app_pages.dart`. Shared code stays untouched.

## 9. Release and commit

```sh
make appbundle APP=fakhrul          # Play Store
make ipa APP=fakhrul                # App Store
git add apps/fakhrul .vscode/launch.json
git commit -m "Add Fakhrul Securities app"
```

To build the new app in CI, add it to the build job in
`.github/workflows/ci.yml` and create a `FAKHRUL_UAT_PROFILE_JSON` repository
secret.

`make validate` can be run at any point. It reports missing env files,
images, Firebase files, open `TODO`s and app ids that clash with another app.
