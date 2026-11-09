# T.K. Shares & Securities Ltd

Broker-house app. All screens and logic come from `packages/`; this folder only
holds what is specific to T.K. Shares & Securities Ltd.

| What | Where |
|---|---|
| Server URLs, app name, colors | `env/uat.json`, `env/prod.json` (copy `env/example.json`) |
| Logo, splash, onboarding images | `assets/brand/` |
| Contact page, share text, store ids | `lib/src/house_profile.dart` |
| Screens and routes | `lib/src/routing/app_pages.dart` |
| App id, icons, Firebase, signing | `android/`, `ios/`, `lib/firebase_options.dart` |

Run from the workspace root: `make run APP=tkshares` (UAT) or `make run APP=tkshares ENV=prod`.
