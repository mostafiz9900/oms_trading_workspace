# 2026-10-31 — CSE Watch List on its own socket (model B, step 1)

## Done
- Branches: `feature/cse_api`, `feature/cse_watchlist_socket` (from `feature/cse_ui` @ d03ff3f)
- Verified CSE UAT feed `wss://cse-uat-firstservice.fistradebd.com/market`: same quote keys as DSE; boards Main / Derivatives / Alternative Trading; session `{"cs":"end_message"}`
- `apps/benemoy/env/uat.json`: `OMS_CSE_SOCKET_MARKET_URL` (local, git-ignored)
- `CseMarketService` + `AppConfig.cseMarketSocketId` + DI; `WatchListController` reads it when CSE is selected (dseAndCse only)
- Tests: `test/data/services/cse_market_service_test.dart`, `test/modules/watchlist/controllers/watchlist_controller_test.dart`
- New gotcha: async `return Get.put(x)` registers `FutureOr<X>`

- Step B2 Market tab: `MarketFeedView`, `HomeController.shownMarket` (+ DSE adapter), CSE figures in `CseMarketService`; 7 Market widgets read `shownMarket`. Tests: service figures, shownMarket (dseOnly/cseOnly/dseAndCse); mutation 5/5
- Found: CSE `it` values `EQUITY`/`Mutual Fund` vs DSE `EQ`/`MF` → CSE sector-gainer chart empty
- Step B3 Top Shares on the CSE service (no new socket); tests rewritten
- Step B4 Quote/Trade on the CSE feed; selected stock saved per exchange
- Step B5 Global Search on the CSE feed
- Step B6 Portfolio on the CSE feed
- Step B7 Favourites; Step B8 DSE kept on switch (no clear, no reconnect, instant return)

## Verified
- `make check`: 0 analyzer issues, oms_shared 191 tests pass (end of day), validate ok
- Mutation checks 6/6 (single-exchange houses, CSE source, refresh, close/drop, DSE-only socket)

## Next
- Move Market tab, Top Shares, Quote/Trade, Search, Portfolio to `CseMarketService`; then remove the shared-feed reconnect on switch
