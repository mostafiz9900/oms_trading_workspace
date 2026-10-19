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
