# Gotchas
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.
> Run /r-memory-scan to auto-fill from codebase.

#### Trade — Market BUY sends the typed price (open question)
- **What Happens**: `orderConfirmSubmitted` computes `sendPrice` (market price for non-LIMIT BUY) but `_buildReqBody` uses `tradPriceTextEditField`.
- **Why**: `sendPrice` is passed but unused.
- **How to Avoid**: do not "fix" without the user and the backend team; locked by `trade_mixin_test.dart`.
- **Discovered**: 2026-10-11

#### Trade — Empty quantity fails silently (open question)
- **What Happens**: `int.parse('')` throws inside the try; button unlocks, no message.
- **How to Avoid**: needs a user-approved message; locked by a test.
- **Discovered**: 2026-10-11

#### Market — Sector gainer/loser counts grow with repeated ticks (open question)
- **What Happens**: `MarketStatisticsAggregator.processGainerTick` counts every tick, no per-stock de-dupe (share-type counts do de-dupe).
- **Discovered**: 2026-10-11

#### Routing — New screens must be registered in every app
- **What Happens**: `get create page` writes `oms_shared/lib/app/routes/app_pages.dart`, which no app uses; each app has its own `apps/<house>/lib/src/routing/app_pages.dart`.
- **How to Avoid**: add the GetPage to every app's app_pages.dart (or move AppPages into oms_shared — proposed, not done).
- **Discovered**: 2026-10-11

#### Drawer — context is gone after Get.back()
- **What Happens**: the drawer closes before awaits, so its BuildContext is unmounted; a `context.mounted` guard would silently skip biometric toggle/logout.
- **How to Avoid**: don't pass widget contexts into controller flows (enableDisableBiometric/logout take none).
- **Discovered**: 2026-10-11

#### Tests — HomeController and GetStorage
- **What Happens**: HomeController's form fields are created in `onInit` (which also opens sockets); GetStorage needs path_provider.
- **How to Avoid**: construct HomeController directly and create the fields in the test; call `initTestStorage()` in `setUpAll`; `AppConfig.initializeForTesting` via `initTestAppConfig()`.
- **Discovered**: 2026-10-11

#### Tests — GetX snackbars leak between tests
- **What Happens**: snackbar animations from one test crash the next test's first frame.
- **How to Avoid**: pump in 100 ms steps; end with `Get.closeAllSnackbars(); await tester.pumpAndSettle();`.
- **Discovered**: 2026-10-11

#### CI/CD — release.yml and branches
- **What Happens**: release runs on push to `prod` only if `release.yml` exists on `prod`; the Actions "Run workflow" button needs it on the default branch `main`. The `production` environment allows only `prod`.
- **How to Avoid**: promote dev → uat → prod; set all 13 secrets before the first prod merge (see docs/release.md).
- **Discovered**: 2026-10-12

#### Android — two settings files
- **What Happens**: `android/settings.gradle` (used) and `settings.gradle.kts` / `build.gradle.kts` (unused leftovers, older versions) both exist; editing the .kts has no effect.
- **Discovered**: 2026-10-12

#### Tooling — `get` CLI and FVM
- **What Happens**: `get` fails with "dart: command not found" because Flutter comes from FVM.
- **How to Avoid**: put `~/fvm/versions/3.47.6/bin` on PATH before running `get`.
- **Discovered**: 2026-10-11

#### Exchange — only the Market tab follows the DSE/CSE switch (so far)
- **What Happens**: `ExchangeService.selected` reloads the market + index sockets (MarketWidget, Top Stocks feed). Everything else (index names DSEX…, boards, sessions, quote/trade/watchlist/orders) is still DSE-hardcoded.
- **Why**: delivered step by step (plan: .claude/tasks/plans/2026-10-18-dse-cse-exchange-support.md, "User decisions 2026-10-19").
- **How to Avoid**: CSE uses the DSE socket URLs until `OMS_CSE_SOCKET_MARKET_URL` / `OMS_CSE_SOCKET_INDEX_URL` are set; order book ids can be the same on both exchanges, so always clear per-exchange caches on switch.
- **Discovered**: 2026-10-19

## Template
#### [Module] — [Title]
- **What Happens**:
- **Why**:
- **How to Avoid**:
- **Discovered**:
