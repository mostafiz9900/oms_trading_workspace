# Task: CSE — open questions to ask at the office, then finish
**Added By**: mostafiz9900
**Date Added**: 2026-10-31
**Priority**: 🔴 High
**Module**: market feed (CseMarketService), index, orders
**Estimated Effort**: Small–Medium (depends on answers)
**Assigned To**: mostafiz9900

## Status (2026-11-08) — read this first on any PC
- Branch `feature/cse_watchlist_socket` (pushed). `git checkout feature/cse_watchlist_socket && git pull`, then `make setup`.
- CSE runs on its own objects in `CseMarketService`: market, depth, time & sales sockets (same models as DSE, separate lists); screens read `HomeController.shownMarket`; DSE is never cleared or reconnected on a switch; CSE sockets close / reopen with the DSE ones.
- All 4 `OMS_CSE_SOCKET_*` keys exist in uat/prod.json; keys without a CSE URL hold the DSE URL → when the backend sends a CSE URL, **only change the JSON**.
- `uat.json` / `prod.json` are git-ignored: copy them privately to a new PC.
- Last log: `.claude/tasks/logs/2026-11-08-cse-depth-time-sales.md`. Plan: `.claude/tasks/plans/2026-10-18-dse-cse-exchange-support.md` (steps B1–B11).
- Still waiting on the backend for the questions below; do not change the related code until answered.

## Live recheck (2026-11-09, UAT, market open)
- Depth: DSE + CSE UAT answer; CSE switch sequence (unsub → sub) gets ack + snapshot each time.
- **Index** `wss://cse-uat-firstservice.tksharesbd.com/index` ✅ same `IndexModel` keys; names include CASPI, CSE30, CSCX, CSE50, CSI (app guess correct). Feed also sends sectors, test indices (CASPI2, TEST30, TESTIND1, INDEX05/06, CSE30Index, CSE50Index) and **DSEX / DS30 / DSMEX** → these are appended to the CSE index list (same rule as DSE extras). ~~Ask backend whether DSE names on the CSE feed are UAT-only.~~ Resolved by the user 2026-11-09: CSE shows only CASPI, CSE30, CSCX, CSE50, CSI (`LiveIndexController` drops other names on CSE; DSE unchanged).
- **Time & sales** `wss://cse-uat-firstservice.tksharesbd.com/events` ✅ same protocol as DSE (`tsm` / `tsb` / `news_hist` acked, `d: []` — no CSE trades on UAT today, 0 of 872 traded).
  Env had `wss://se-uat-…` (typo, missing `c`) → HTTP 445, connection fails.
- `prod.json` CSE keys point to CSE **UAT** servers (no prod CSE URL yet — question 7).
- Later 2026-11-09: user fixed T&S typo; `prod.json` now `wss://cse-firstservice.fistradebd.com/{market,index,marketdepth,events}` → **all HTTP 445** (a made-up `*.fistradebd.com` host gives the same 445; DSE prod connects) → that host is not live / wrong name. Ask backend for the real prod CSE host.
- UAT replay (recorded live messages → real `CseMarketService` / `IndexModel`, temp test, deleted): 875 ticks → 872 quotes, `EQUITY`/`Mutual Fund` normalized, close = lp, session `continuous`, 19 sectors, 3 boards; depth BEXIMCO buy 80 × 10 then dropped on switch; T&S replies handled; all 36 index messages parse. Extra CSE `it` values not mapped: CorpBond, OPT, FUT, MLEG, GOVDBT (ask backend whether DSE uses other codes for these). `make check` exit 0 (216 tests).

## Description
CSE runs on its own feed (`CseMarketService`, branch `feature/cse_watchlist_socket`).
The user asks the backend team and comes back with the answers.

## Questions for the backend (user to ask)
1. **`c` (close) on the CSE feed**: is it the previous close (= reference `r`)?
   On CSE UAT `c` == `r` while `lp` changes (ASIAPACINS: lp 53, c 48, r 48, d 10.4 %).
   The app now uses `lp` as close for CSE (`CseMarketService.normalizeCseTick`).
   - If the backend will send `c` like DSE (today's close) → remove the `c` part of `normalizeCseTick`.
2. **`it` (instrument type) on CSE**: `EQUITY` / `Mutual Fund` vs DSE `EQ` / `MF`.
   The app maps them for CSE only. If the backend sends `EQ` / `MF` → remove the mapping.
   (User said "MarketModel is the same for DSE and CSE" — confirm whether this means the feed values are the same too.)
3. **CSE index URL** (`OMS_CSE_SOCKET_INDEX_URL`) and the real CSE index names (app guesses CASPI, CSE30, CSCX, CSE50, CSI).
   Index is the last part still cleared + reconnected on a switch (LiveIndexController).
4. ~~CSE depth URL~~ done (UAT). CSE time & sales: code done, uses the DSE URL until the backend sends the CSE one (same response) — **put the real `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL` in uat/prod.json when it comes** (`OMS_CSE_SOCKET_MARKET_DEPTH_URL`, `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL`).
5. **Orders on CSE**: which field / value in the order JSON says CSE? Order list and favourites: exchange field?
   (Orders, modify, cancel, duplicate, status are blocked while CSE is selected until then.)
6. **REST APIs** (candles, historical volume, company fundamentals / dividend / EPS, news): any exchange parameter?
7. **Prod CSE market URL** (UAT is `wss://cse-uat-firstservice.tksharesbd.com/market`).

## Acceptance Criteria
- [ ] Answers recorded here
- [ ] `normalizeCseTick` kept or removed per answers 1–2 (tests in `cse_market_service_test.dart`, `top_share_exchange_test.dart`)
- [ ] Index moved to a separate CSE index socket once the URL exists (like `CseMarketService`)
- [ ] Env keys filled in `apps/benemoy/env/{uat,prod}.json` (git-ignored) and GitHub secrets

## Notes
- DSE is live: CSE code runs only after the switch; DSE feed is never cleared or reconnected (model B).
- Plan: `.claude/tasks/plans/2026-10-18-dse-cse-exchange-support.md` (steps B1–B8, "Remaining gaps").

## Related Files
- `packages/shared/oms_shared/lib/app/data/services/cse_market_service.dart`
- `packages/shared/oms_shared/lib/app/modules/market/controllers/live_index_controller.dart`
- `packages/shared/oms_shared/lib/app/modules/home/controllers/home/home_state.dart` (`canOrderOnSelectedExchange`, `shownMarket`)
