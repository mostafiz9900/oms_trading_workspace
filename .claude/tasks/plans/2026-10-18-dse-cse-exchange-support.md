# Plan: DSE / CSE exchange support

Status: **Phase 0 done. Step 1 (MarketWidget) and Step 2 (Watch List) done 2026-10-19. Connection model A (only the selected exchange is connected) — user decision. Next steps one screen at a time.**
Created: 2026-10-18

## User decisions (2026-10-19)

- CSE has **separate sockets**; until its URLs exist, CSE uses the **DSE URLs** (`OMS_CSE_SOCKET_MARKET_URL`, `OMS_CSE_SOCKET_INDEX_URL`, optional).
- **Order book ids can be the same** on DSE and CSE → clear per-exchange data on every switch; key by (exchange, ob) where both are kept.
- **UI is identical** for DSE and CSE; only a **Trade Fast-style switcher** is added.
- Switcher: **custom `DSE | CSE` toggle switch (Trade Fast style, not a dropdown) in the app bar next to search**; shown only when `hasBothExchanges`.
- **Benemoy = `dseAndCse`**; Fakhrul stays `dseOnly`.
- Work **step by step, one screen at a time**; start with MarketWidget only.

## Step 1 — MarketWidget (done 2026-10-19)

- `BrokerHouseConfig.cseMarketSocketUrl / cseIndexSocketUrl` (+ `marketSocketUrlFor` / `indexSocketUrlFor`, fallback DSE); `AppConfig.marketUrlFor / indexUrlFor`
- `ExchangeService` (`data/services/exchange_service.dart`): selected exchange, remembered in GetStorage (`selected_exchange`), registered in `di.dart`
- `ExchangeSwitcher` (`global_widgets/exchange/exchange_switcher.dart`) in MarketWidget app bar
- Switch → `HomeController.reloadMarketForExchange()` (clears market + Top Stocks feed, reconnects) and `LiveIndexController.reloadIndexForExchange()`
- Tests: exchange_service_test, exchange_switcher_test, exchange_reload_test, broker_config cse_socket_url_test (mutation-checked)

## Step 2 — Watch List (done 2026-10-19)

- `ExchangeSwitcher(padding:)` in the Watch List app bar (padding only when shown → single-exchange layouts unchanged)
- Switch now also clears `marketListAll`, `marketFeedList`, `marketListForDilog`, `marqueeList` (step 1 left them, so watchlist / quote lookup / sector charts / marquee kept the old exchange's prices) and refreshes `WatchListController`
- Connection model: **A** — only the selected exchange's market + index sockets are open; other exchange's price later via per-instrument subscription if needed

## Step 3 — Top Share (done 2026-10-24)

- `ExchangeSwitcher` in the Top Share app bar, before search
- `TopShareController.reloadForExchange()` (worker on `ExchangeService.selected`): clears rows, resets sector to All (sector list is per exchange), keeps top menu / duration / sort, shows the loader
- List and sectors rebuilt from the first non-empty `MarketSocketService.marketFeedList` after the switch; loader gives up after 10 s (`exchangeLoadTimeout`)
- Outside a switch, behaviour unchanged (list still built once on open; rows tick via `updateSingleRowFromService`)
- Tests: `test/modules/top_share/top_share_exchange_test.dart` (mutation-checked 4/4)

## Step 4 — Quote (done 2026-10-24)

- `ExchangeSwitcher` in the Quote app bar (before Buy/Sell)
- `HomeController.reloadMarketForExchange()` now first calls `_resetQuoteForExchange()`: unsubscribes depth for the old order book, clears depth, time & sales and news-for-stock; **keeps `marketData`** (Trade reads it — never blank it)
- Every market list flush calls `_selectQuoteAfterExchangeSwitch()`: once the new feed has the same **symbol**, select it (new order book) via `markerInfo()` and re-subscribe T&S; after `QuoteMixin.quoteSwitchFallback` (5 s) take the new exchange's first stock
- Depth and T&S sockets still use the DSE URLs (no CSE keys yet)
- Tests: 2 new in `exchange_reload_test.dart` (mutation-checked 4/4)

## Step 5 — Trade (done 2026-10-24)

- `ExchangeSwitcher` in the Trade app bar (before search); stock follows Quote's re-selection (step 4); on Trade the price box is refilled with the new stock's `activePrice` (same as opening Trade)
- **User decision 2026-10-24: no new orders while CSE is selected.** The order JSON has no exchange field, so a "CSE" order would be identical to a DSE one. Gate: `TradeMixin.canOrderOnSelectedExchange` — checked on the Buy/Sell button (snackbar) and first thing in `orderConfirmSubmitted` for `ActionsType.ORDER` (alert "Order not sent"). Replace/cancel of existing orders not blocked.
- To open CSE trading: backend must define how the exchange is sent (field + values); then remove the gate
- Tests: 2 in `trade_mixin_test.dart` ("DSE/CSE house"), 1 in `exchange_reload_test.dart` (price refresh); mutation-checked 4/4

## Step 6 — Orders (done 2026-10-24)

- `ExchangeSwitcher` in the Portfolio app bar (Position / Orders / Account Summary tabs)
- Order list unchanged: rows show `order.name` from the server; orders have **no exchange field**, so they cannot be split by exchange (all are DSE today)
- Risk found: modify / duplicate / cancel / status resolve symbol, ISIN, board … from the **selected exchange's** feed by `order_book_id`; with real CSE URLs that id can be another stock
- **User decision 2026-10-24:** while CSE is selected, modify / cancel / duplicate (and status) send nothing and say "Your orders are on DSE. Switch to DSE …" (`OrderListMixin.cseOrderActionBlockedMessage`); Modify is stopped before its form opens
- Gate moved to `HomeState.canOrderOnSelectedExchange` (used by Trade and Orders)
- Tests: 5 in `trade_mixin_test.dart` ("DSE/CSE house"); each of the 4 gates mutation-checked

## Step 7 — Global Search (done 2026-10-24)

- `ExchangeSwitcher` left of the search box; switching re-runs `GlobalSearchController.syncLiveData()` (results empty, refilled from the new feed; query kept)
- Recent searches per exchange (`RecentSearchService`): DSE keeps the old key `recent_search_ids` (no data lost), CSE uses `recent_search_ids_cse`
- Tests: `test/data/services/recent_search_service_test.dart` (4) + 1 in `exchange_reload_test.dart`; mutation-checked 4/4

## Step 8 — Favourites, sector details, Price Table (done 2026-10-24)

- Favourites tab + sector details: `ExchangeSwitcher` in the app bar
- Switch clears `favMarketParseList`, `chartData`, `chartDataShareType`, `sectorSummaryList`, distribution counts
- Favourites re-matched against the new feed only during a 5 s window after a switch (`_favRebuildWindow` Timer); otherwise a snapshot, as on DSE. Saved by (ticker, DSE order book) → on CSE they show only where both match
- Sector details (`'sectorSummary'` builder, a snapshot on DSE) refreshed once when the new exchange's sectors exist (`_refreshSectorSummaryAfterSwitch`)
- Quote › Price Table: if open, `HistoricalVolumeController.loadData` for the re-selected stock
- Tests: 5 in `exchange_reload_test.dart` (incl. "after the window, favourites are a snapshot again"); mutation-checked 6/6

## Step 9 — Stock details follow the exchange (done 2026-10-24)

- Tapping a stock in search / watch list / top shares / favourites opens Quote with the **selected exchange's** stock (lists only hold that exchange's feed — connection model A)
- New optional keys `OMS_CSE_SOCKET_MARKET_DEPTH_URL`, `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL` (broker_config, fallback to DSE; validated as ws/wss; listed in `tool/validate_apps.dart`)
- Depth and news/T&S sockets open on `AppConfig.*UrlFor(ExchangeService.current)`; on a switch they reconnect **only if the URL differs** (`_reconnectIfUrlChanged`)
- While Quote re-selects after a switch, the auto re-subscribe on (re)connect is skipped (`_quoteReselectPending`), so the old DSE id is never subscribed on the CSE feed
- Tests: broker_config 2, `exchange_reload_test.dart` "Stock details" 2; mutation-checked 4/4

## Step 10 — single-exchange houses + indices (done 2026-10-24)

- **Bug fixed:** `canOrderOnSelectedExchange` blocked every order of a `cseOnly` house. Now the CSE gate applies only to `dseAndCse` houses; DSE-only and CSE-only always trade (tests for both)
- Index per exchange (`LiveIndexController.baseIndicesByExchange`): DSE `DSEX, DSES, DS30, DSMEX` (unchanged), CSE `CASPI, CSE30, CSCX, CSE50, CSI` (names to confirm with the CSE feed). Start/switch selects the exchange's main index and clears the old chart
- CSE only, until the user taps an index: follow the feed (first listed index present, else the first received) — so a different CSE naming still works. DSE untouched
- HomeController's own index mixin (`selectedSn = 'DSEX'`) is not read by any screen — left as is
- Tests: `test/modules/market/controllers/live_index_controller_test.dart` (6), 4 in `trade_mixin_test.dart`; mutation-checked 5/5
- Pre-CSE test suite (`6db7350`) re-run against current code: all pass

## Connection model B — CSE apart from DSE (started 2026-10-31, branch `feature/cse_watchlist_socket`)

User decision 2026-10-31: CSE data in its **own objects**; the DSE socket and lists are never cleared or reconnected for CSE. Same JSON format on both feeds (verified: identical quote keys, CSE UAT `wss://cse-uat-firstservice.fistradebd.com/market`).

- Step B1 — Watch List (done): `CseMarketService` (`data/services/cse_market_service.dart`, registered in `di.dart`): own socket `AppConfig.cseMarketSocketId`, own `MarketTickStore`, `RxList<MarketModel> quotes` (one pending flush, 500 ms). Only for `dseAndCse` houses; connects while CSE is selected, closes and drops quotes on DSE. `WatchListController.showsCse` → reads `quotes`, else HomeController lists as before. Tests: `cse_market_service_test.dart` (7), `watchlist_controller_test.dart` (5); mutation-checked 6/6
- Step B2 — Market tab (done): `MarketFeedView` (`data/services/market_feed_view.dart`) = quotes, marquee, sector/share-type charts, sector summary, distribution, session. `HomeController.shownMarket` → `CseMarketService` while CSE is shown, else `_HomeFeedView` (reads the same HomeController fields as before). `CseMarketService` computes the CSE figures with the same `MarketSnapshotAnalytics` / `MarketSectorSummaryAggregator` (charts every 2 s) and redraws HomeController's GetBuilder ids. Market tab widgets read `shownMarket.X`. Index (LiveIndexController) not moved yet — needs `OMS_CSE_SOCKET_INDEX_URL`
- Step B3 — Top Shares (done): no new socket. `TopShareController.marketFeedList` = CSE quotes (PUBLIC, Main/SME board, same as MarketSocketService) while CSE is shown, else `MarketSocketService.marketFeedList` as before. List built once after a switch; CSE rows refreshed in place on each CSE flush (`_onCseFeed`); `updateSingleRowFromService` ignores DSE ticks while CSE is shown. `CseMarketService.isShown` now false when the service is not registered. Tests rewritten (`top_share_exchange_test.dart`, 7); mutation 5/5
- CSE feed sends `it` = `EQUITY` / `Mutual Fund` (DSE analytics expects `EQ` / `MF`), so the CSE sector-gainer chart stays empty — ask backend or map in CseMarketService (user decision)
- Interim: other screens still use model A (switch clears + reconnects the shared feed), so on CSE two CSE sockets are open — remove when the last screen moves
- Next: Market tab, Top Shares, Quote/Trade, Search, Portfolio onto `CseMarketService`; then drop the shared-feed clear/reconnect from `reloadMarketForExchange`

## Remaining gaps

1. ~~Positions~~ — **User decision 2026-10-24: CSE selected → holdings at CSE prices** (as the code does: by ISIN from the selected feed). Position is redrawn on every flush during the 5 s switch window (else only the first flush, with ~1 stock); test "Position is redrawn … and only then"
2. News: `news` not cleared; one news socket for both exchanges (backend)
3. CSE index names: app uses CASPI/CSE30/CSCX/CSE50/CSI and follows the feed if they differ — confirm with the CSE feed
4. REST market URLs carry no exchange (candles, historical volume, minute data, company fundamentals/dividend/EPS) — backend
5. CSE URLs for depth and time & sales: keys exist now (`OMS_CSE_SOCKET_MARKET_DEPTH_URL`, `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL`) — values from backend
6. Order JSON / order list exchange field — backend (orders blocked on CSE until then)
7. `SearchWatchListView` not refreshed (probably unreachable). Hint `"DSES .."` in watch list / favourites dialogs is an example list name, not exchange data — left as is
8. Adding a favourite while on CSE saves the CSE order book with no exchange (backend: favourites per exchange?)

## Phase 0 — house flag (done)

- `ExchangeMode { dseOnly, cseOnly, dseAndCse }` + `StockExchange { dse, cse }` in
  `packages/core/broker_config/lib/src/stock_exchange.dart`
- `HouseProfile.exchangeMode`, default `dseOnly`; all houses (Benemoy, Fakhrul) are `dseOnly`
- `AppConfig.exchangeMode / exchanges / hasDse / hasCse / hasBothExchanges / defaultExchange`
- `make new-app … EXCHANGE=dse|cse|both` (default dse)
- **Nothing reads the flag yet → no behaviour change.**
- UI design: `2026-10-18-exchange-ui-architecture.md`

## Finding: no code knows about exchanges

No socket message, endpoint, model or env key carries an exchange field. Paths below are
under `packages/shared/oms_shared/lib/app/`.

### Common (same for both exchanges, no change)

| Part | Why |
|---|---|
| Login, OTP, token, biometric | per user |
| Order / balance / position / order-summary sockets (`socket_mixin.dart:154,178`, `position_controller.dart:182`, `order_summary_controller.dart:49`) | keyed by `boId` / `investorCode` |
| Cash balance (`user_balance.dart`) | one balance |
| Portfolio holdings (`position_response.dart`) | by ISIN; shares sell on either exchange (CDBL) |
| Withdrawal, notifications, contact, onboarding, settings | no exchange concept |
| `WebSocketService`, tick parsing (`market_tick_message.dart`), depth / T&S subscribe | pass through whatever the feed sends |
| Trade form layout | same; only the target exchange differs |
| Localization | no DSE/CSE strings |

### Exchange-specific (hardcoded DSE today)

| Item | Where | DSE value | CSE needs |
|---|---|---|---|
| Index list / order | `home/controllers/home/index_mixin.dart:28`, `market/controllers/live_index_controller.dart:281` | DSEX, DSES, DS30, DSMEX | CASPI, CSE30, CSCX, CSI |
| Default index | `home_state.dart:78`, `socket_mixin.dart:286`, `live_index_controller.dart:22,24`, `market_index_controller.dart:18` | `'DSEX'` | `'CASPI'` |
| Hidden indices | `index_mixin.dart:10-11`, `live_index_controller.dart:42-43` | 'DSE SME Index', 'CDSET' | CSE list |
| Chart trading hours | `market_index_controller.dart:236-249` | 10:00–14:30 | CSE hours |
| Board names | `market_socket_service.dart:45`, `market_snapshot_analytics.dart:29,69,84,142,158`, `market_sector_summary_aggregator.dart:11`, `market_statistics_aggregator.dart:19`, `market_treemap.dart:147`, `watchlist_controller.dart:127-135`, `home_state.dart:112` | "Main Board", "Small Cap Board" (→ SME) | CSE feed names |
| Group `'PUBLIC'` | `market_feed_mixin.dart:191`, `global_search_controller.dart:29`, `position_controller.dart:280`, `watchlist_controller.dart:126` | PUBLIC | confirm |
| Sectors / types / categories | `market_sector_filter_store.dart:13`, `market_snapshot_analytics.dart:72,79,145,153,157-180`, `top_sector_by_category_widget.dart:107-117` | TBond/CorpBond, EQ/MF, A/B/N/Z | confirm |
| Watchlist filter chips | `watch_list_widget.dart:129,146,163` | Main/SME, Public/Spot, A/B/N/P/S/Z | CSE values |
| Search hint | `fav_market_view.dart:232`, `watch_list_widget.dart:414` | `"DSES .."` | neutral hint |
| Limit request market | `limit_request_controller.dart:201` | public / block / Debt | CSE boards |
| Market session | `market_feed_mixin.dart:19-21`, `call_now_widget.dart:46-60`; sent as `session` in orders | one global session | one per exchange |
| Socket / itch URLs | `core/values/app_config.dart:68-88`, `broker_config/lib/src/broker_house_config.dart` | one set | one set per exchange? |

### Fields that could carry the exchange

- `MarketModel.board` (`b`), `marketType` (`mt`), `group` (`g`), `firmId` (`fid`) — none is "exchange" today
- `OrderConfirmRequest` (`order_confirm_request.dart`, `toJson` / `toJsonReplaceOrder`) sends `board, market_type, group, session` — natural place for an `exchange` key if the gateway needs one
- Cancel (`update_order_holder.dart`) has no board / market type at all
- Index chart endpoints take the index name (`code=`, `symbol=`, `fsym`)

## Risks

- **Order book id collisions**: ticks (`market_tick_store.dart:8`), depth, T&S, watchlist favourites
  and order lookup (`quote_mixin.dart:99-104`, `order_list_mixin.dart:548,628`) are keyed by `ob` only.
  If DSE and CSE ids overlap, replace / cancel / duplicate can pick the wrong instrument.
- Portfolio price lookup `isinCode == isin && group == 'PUBLIC'` (`position_controller.dart:275-281`)
  is ambiguous when one ISIN is listed on both exchanges.

## Questions for backend / gateway (block Phase 2)

1. CSE market + index feed: separate socket URLs, or same feed with an exchange field? Does Fakhrul's feed serve CSE?
2. Can DSE and CSE `ob` (order book id) collide?
3. How does an order say which exchange: new key, or inferred from `board` / `market_type`? Same for cancel.
4. CSE values for `b`, `g`, `mt`, categories, sectors.
5. Does the itch chart API serve CSE indices (`code=CASPI`)?
6. Do order / position responses return the exchange (for badges on a mixed list)?

## Proposed UI approach

### Phase 1 — single-exchange houses (no backend needed, low risk) — details in exchange-ui-architecture.md

- Add an `ExchangeProfile` (in `broker_config`) per exchange: index list, default index, hidden
  indices, trading hours, board / group names.
- Replace the hardcoded values above with the profile of the house's exchange.
- DSE profile = today's values exactly → Benemoy behaviour unchanged (lock with tests first).
- No toggle; UI looks the same. Fakhrul gets correct CSE values.

### Phase 2 — houses on both exchanges (after backend answers)

- **DSE | CSE segmented switch** at the top of the Market tab, remembered in GetStorage; drives
  index, top share, sector, treemap, market session.
- **Exchange badge** next to symbols in quote, trade, watchlist; exchange picker on the trade
  screen when a symbol is listed on both.
- Order list and portfolio stay combined, with a badge and a filter.
- Per-exchange socket ids / URLs if the feeds are separate; exchange-qualified keys if ids collide.

## Unrelated bugs found (need user OK before fixing — live app)

- `limit_request_controller.dart`: default market `'public'` (line 35) but `clearForm` resets to `'block'` (line 479)
- Index socket is only opened by `LiveIndexController`; `HomeController.refreshIndex()` (`socket_mixin.dart:264-266`) does nothing; `MarketIndexMixin._handleIndexMessage` is dead code
- `order_list_mixin.dart:646` sends a hardcoded `'session': "continuous"`
