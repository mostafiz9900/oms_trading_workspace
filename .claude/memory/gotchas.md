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

#### Exchange — only Market, Watch List, Top Share, Quote, Trade, Orders, Global Search, Favourites and Sector details follow the DSE/CSE switch (so far)
- **What Happens**: `ExchangeService.selected` reloads the market + index sockets (MarketWidget, Top Stocks feed). Everything else (index names DSEX…, boards, sessions, quote/trade/watchlist/orders) is still DSE-hardcoded.
- **Why**: delivered step by step (plan: .claude/tasks/plans/2026-10-18-dse-cse-exchange-support.md, "User decisions 2026-10-19").
- **Model B (2026-10-31)**: CSE has its own `CseMarketService`; screens read `HomeController.shownMarket`; the DSE feed is never cleared or reconnected on a switch. New screens must read `shownMarket`, not `marketList`.
- **How to Avoid**: CSE uses the DSE socket URLs until `OMS_CSE_SOCKET_MARKET_URL` / `OMS_CSE_SOCKET_INDEX_URL` / `OMS_CSE_SOCKET_MARKET_DEPTH_URL` / `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL` are set (all optional, in env JSON); order book ids can be the same on both exchanges, so always clear per-exchange caches on switch. Quote re-selects by **symbol**, not order book; `marketData` is shared with Trade, so never blank it during a switch. New orders are blocked while CSE is selected (no exchange field in the order JSON) — do not remove the gate before the backend defines one. Same gate (`HomeState.canOrderOnSelectedExchange`) blocks modify/cancel/duplicate/status: they look up the stock by order book id in the selected exchange's feed.
- **Discovered**: 2026-10-19

#### Tests — `return Get.put(x)` inside an async function
- **What Happens**: the generic is inferred from the return context as `FutureOr<X>`, so GetX registers the instance under `"FutureOr<X>"`; `Get.isRegistered<X>()` / `Get.find<X>()` then fail (looked like the controller vanished).
- **How to Avoid**: write `Get.put<X>(x)` (or assign to a local first) in async helpers.
- **Discovered**: 2026-10-31

#### Tooling — `dart format` reflows whole files
- **What Happens**: many oms_shared files are not in `dart format` style (longer lines); formatting a folder rewrote 14 files (+583/−203) for a 25-line change.
- **How to Avoid**: format only files you create; for edits in existing files, keep their style and don't run `dart format` on the folder.
- **Discovered**: 2026-10-31

## Template
#### [Module] — [Title]
- **What Happens**:
- **Why**:
- **How to Avoid**:
- **Discovered**:
