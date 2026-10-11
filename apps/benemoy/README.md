# Benemoy

Live Benemoy Securities app. All screens and logic come from `packages/`; this
folder only holds what is specific to Benemoy.

| What | Where |
|---|---|
| Server URLs, app name, colors | `env/uat.json`, `env/prod.json` (copy `env/example.json`) |
| Logo, splash, onboarding images | `assets/brand/` |
| Contact page, share text, store ids | `lib/src/house_profile.dart` |
| Screens and routes | `lib/src/routing/app_pages.dart` |
| App id, icons, Firebase, signing | `android/`, `ios/`, `lib/firebase_options.dart` |

Run from the workspace root:

```sh
make run              # UAT
make run ENV=prod     # production servers
make appbundle        # Play Store release (production)
make ipa              # App Store release (production)
```

`android/` and `ios/` are copied from the live project. The only changes are
what Flutter 3.47.6 requires: Gradle wrapper 8.14, Kotlin plugin 2.2.20 and two
`gradle.properties` flags. Release signing reads the git-ignored
`android/key.properties` and `android/oms-app-release-key.jks`; keep a secure
backup of the key. iOS release needs the Apple team's provisioning profile.
