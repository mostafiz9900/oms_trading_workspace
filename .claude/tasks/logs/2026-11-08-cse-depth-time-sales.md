# 2026-11-06 → 11-08 — CSE depth, time & sales, lifecycle, env keys

Branch `feature/cse_watchlist_socket` (all pushed; last code commit `05a92e0`).

## Done
- `2283eae` CSE market depth on its own socket (same `MarketDepthModel`, separate `buys`/`sells` in `CseMarketService`); DSE depth socket always DSE URL, never reconnected on a switch; Quote + Trade depth panels read `shownMarket.buys/sells`.
- `c9c0f80` position_summary_test updated to the user's 2026-11-02 formulas (MV = Σ total_qty × last, cost = Σ total_cost); no logic change.
- `e93b3ab` CSE sockets suspend / resume with HomeController (app pause, detach, logout; `initConnect` on resume).
- `db1de26` CSE time & sales on its own socket (same `TimeAndSalesModel` / `NewsModel`, separate lists; `tsm` / `tsb` / `news_hist`); general market news stays on DSE.
- `05a92e0` CSE env keys hold the DSE URL until the CSE feeds exist; CSE depth opens whenever its key is set (`AppConfig.hasCseDepthFeed`); benemoy `example.json` lists all 4 `OMS_CSE_SOCKET_*` keys.
- Local only (git-ignored): `apps/benemoy/env/prod.json` → all 4 CSE keys = DSE prod URLs; `uat.json` → market + depth = CSE UAT (`wss://cse-uat-firstservice.fistradebd.com/market`, `/marketdepth`), index + T&S = DSE UAT.
- Restored deleted `apps/benemoy/ios/Runner.xcodeproj` / `Runner.xcworkspace` (`git restore`, user OK).

## Verified
- `make check` exit 0: analyze 0 issues (9 packages), oms_shared 216 tests pass, validate ok (4 apps).
- Mutation checks: depth 7/7, lifecycle 4/4, T&S 7/7, env rule 1/1.
- Live CSE UAT depth socket answers (`status: synced`); on 2026-11-06 (Friday) no CSE orders → empty depth (not a bug).

## Next
- Real CSE URLs (T&S, index, prod market / depth) → only change `uat.json` / `prod.json`.
- Index still model A (LiveIndexController clears + reconnects on a switch) until a CSE index URL exists.
- Open backend questions: `.claude/tasks/todo/2026-10-31-cse-open-questions.md`.
