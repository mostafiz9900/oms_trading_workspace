# Task: CSE — open questions to ask at the office, then finish
**Added By**: mostafiz9900
**Date Added**: 2026-10-31
**Priority**: 🔴 High
**Module**: market feed (CseMarketService), index, orders
**Estimated Effort**: Small–Medium (depends on answers)
**Assigned To**: mostafiz9900

## Description
CSE runs on its own feed (`CseMarketService`, branch `feature/cse_watchlist_socket`, last commit `6acd536`).
The user will ask the backend team at the office and come back with the answers.
Do not change anything below until the user answers.

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
4. **CSE depth and time & sales URLs** (`OMS_CSE_SOCKET_MARKET_DEPTH_URL`, `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL`).
5. **Orders on CSE**: which field / value in the order JSON says CSE? Order list and favourites: exchange field?
   (Orders, modify, cancel, duplicate, status are blocked while CSE is selected until then.)
6. **REST APIs** (candles, historical volume, company fundamentals / dividend / EPS, news): any exchange parameter?
7. **Prod CSE market URL** (UAT is `wss://cse-uat-firstservice.fistradebd.com/market`).

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
