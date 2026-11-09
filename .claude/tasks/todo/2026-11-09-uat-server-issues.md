# Task: UAT server issues found in the 2026-11-09 health check (backend / devops)
**Added By**: mostafiz9900
**Date Added**: 2026-11-09
**Priority**: 🔴 High (item 1–2), 🟡 Medium (3–4)
**Module**: env / servers (no app code)
**Estimated Effort**: Small (server side)
**Assigned To**: backend / devops (user to report)

## Findings (checked from a dev Mac, Dhaka market open)
1. **`uat-itch-chart.skytrade.us` TLS certificate expired 2026-08-11** and the service behind it answers 502.
   → Company screen Dividend + EPS (`companies_controller.dart`, `OMS_API_CHART_BASE_URL`) fail on UAT. Prod `itch-chart.skytrade.us` is fine (cert to 2027-02-06).
2. **Certificates expiring 2026-11-25**: `uat-api-admin.skytrade.us` (login, REST, order + balance sockets) and `uat-itch.skytrade.us`. After that date UAT login stops working unless renewed.
3. **Prod CSE host** `cse-firstservice.fistradebd.com` (in local prod.json) → HTTP 445 on all 4 paths (same as a made-up subdomain) → not live / wrong name.
4. Old endpoints answer 404 on UAT **and prod**: `api/itch/get-minute-data-from-to` (still called by `MarketIndexController.loadData`, `home_controller.dart:167`) and `api/get_index_chart_data` (`fetchIndexChartData`, no caller). The visible index chart uses `api/candles` (works). News socket `uat-itch…/socket-api/v1/news/ws` → 502, but the app never opens it.

## OK on UAT
- REST: login / refresh answer (400 without credentials), auth routes 401 without token, candles, company fundamentals, historical volume (200 with real data).
- DSE sockets: market (1928 msgs), index (DSEX, DSES, DS30, DSMEX + ATBX, CDSET), depth, events; order / report_cash reject a bad token with 403 (server up).
- CSE UAT sockets: market (872 stocks), index, depth, events — see `2026-10-31-cse-open-questions.md`.
- Not checked: anything behind login (order placement, balance, portfolio) — needs a UAT account.

## Acceptance Criteria
- [ ] Items 1–2 reported to devops; certs renewed
- [ ] Item 3 answered with the real prod CSE host
- [ ] Item 4: user decides whether to remove / keep the dead chart calls (code change → user OK)
