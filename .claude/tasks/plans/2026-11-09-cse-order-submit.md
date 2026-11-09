# Plan: CSE order submit (new / replace / cancel / status / duplicate)
**Date**: 2026-11-09 · **Branch**: `feature/cse_watchlist_socket` · **Status**: steps 1–3 + 5 done 2026-11-09 (CSE trading open, user: "DSE stays as is, CSE trades"); step 4 needs a real CSE order to confirm `exchange` in order data

Source: web trader `useFixEmit` (JS, pasted by the user 2026-11-09). Same order socket (`fixSocket`), same actions; CSE is chosen by fields in the JSON.

## Web vs app
| Field / rule | Web (`useFixEmit`) | App today | CSE work |
|---|---|---|---|
| `exchange` | `"DSE"` / `"CSE"` on ORDER, REPLACE, CANCEL, STATUS | not sent | send `"CSE"` when CSE is selected |
| `cse_trader_code` | `userData.cse_trader_code` when CSE, else `null` | not in `UserDetail` | add field to `UserDetail` (key from login/profile API) and send when CSE |
| `session` | session context | DSE `currentSession` (status: hard-coded `"continuous"`) | CSE orders: `CseMarketService.session` |
| `asset_class` | `instrument_type` as the feed sends it | `marketData.instrumentType` | CSE ticks are normalized `EQUITY`→`EQ`, `Mutual Fund`→`MF` → keep the raw value for orders or confirm gateway accepts EQ/MF |
| `isin, security_code, board, group, market_type, category, order_book_id, symbol` | from selected instrument | from `marketData` | CSE feed sends all (`ic,t,b,g,mt,st,ob,sn`; isin missing/"0" on ~10 of 872) |
| market BUY price | `market_and_best_price` | new order: typed price (open gotcha); replace: `reference` | decide for CSE |
| validation | client code, qty, LIMIT price | qty empty fails silently (open gotcha) | decide for CSE |
| replace `order_book_id` | not sent | sent | keep as app (DSE unchanged) |
| cancel `client_code`, `user_id` | sent | sent | + `exchange`, `cse_trader_code` |
| status | `trader_id, client_order_id, symbol, side, session, exchange, cse_trader_code` | + `request_sender`, session `"continuous"` | + `exchange`, `cse_trader_code` |

## Steps (each: DSE JSON byte-identical test + mutation check)
1. `UserDetail.cseTraderCode` (`cse_trader_code`). ✅
2. `OrderConfirmRequest` + `UpdateOrderHolder` + status map: add `exchange`, `cse_trader_code` on every request, DSE too (user answer 1). ✅
3. CSE values: session from `CseMarketService`, raw `it` for `asset_class` (per answer), stock from the CSE feed.
4. Order list: which exchange each order is on (needs `exchange` in order list / order_summary data) → modify / cancel / duplicate / status look up the right feed.
5. Open `canOrderOnSelectedExchange` for CSE only after 1–4 + UAT order test with a CSE-enabled account.

## User answers (2026-11-09)
1. Send `exchange` on DSE too (same socket) → every request now has `exchange` (`DSE`/`CSE`) + `cse_trader_code` (null on DSE), like the web.
2. `cse_trader_code` is in `user_detail`; without it CSE orders are blocked (`HomeState.cseTraderCodeMissingMessage`).

## Done (2026-11-09)
- `UserDetail.cseTraderCode`; `OrderConfirmRequest` / `UpdateOrderHolder` / status map: `exchange`, `cse_trader_code` (after `session`).
- `HomeState.orderExchange / orderCseTraderCode / orderSession` (CSE session from `CseMarketService` when CSE is shown; DSE unchanged); new, replace, duplicate, cancel, status use them.
- CSE gate (`canOrderOnSelectedExchange`) still closed for dseAndCse houses.
- Tests + mutation 5/5; make check exit 0.

## Done (2026-11-09, later)
- Gate removed: CSE new orders sent (`exchange: CSE`, `cse_trader_code`, CSE session). Market BUY price same as DSE (user: "DSE jonno ja ja hoto").
- `UserOrder.exchange` (missing → house default, DSE); `HomeState.exchangeOfOrder / canActOnOrder / orderOnOtherExchangeMessage`; order actions look up the stock in the selected feed (`_marketForOrderBook`, `_symbolForOrderBook`); DSE lookups unchanged.
- Tests 241 pass, mutation 4/4. Phone (UAT) test pending: account 00007 has `cse_trader_code: null`.

## Questions (user / backend)
1. ~~DSE exchange field~~ answered: send `DSE`.
2. ~~`cse_trader_code` location~~ answered: `user_detail`; missing → blocked.
3. ~~CSE `asset_class`~~ answered (user 2026-11-09): same as DSE → `EQ` / `MF` (already so via `normalizeCseTick`); no change.
4. Do order list, order_summary socket and order responses carry `exchange`?
5. CSE market BUY price: web sends best/market price; app (DSE) sends typed price — same as DSE or like web?
6. CSE UAT test account with `cse_trader_code` for end-to-end test.
