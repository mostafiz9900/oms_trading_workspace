# 2026-11-01 — Position top summary: Gain after intraday sell

## Done
- New `PositionController.summaryCost / summaryGain / summaryGainPercentage`, used only by `_TopSummaryDashboard`.
  summaryCost = Σ initial_quantity × avg_price + intraday_buy × intraday_buy_price_avg (user: avg_price excludes intraday buys).
- Market Value (`currentPortfolioValue`) unchanged. `totalInvestment` / `totalUnrealizedPnL*` unchanged → Account Summary and rows not affected (user: only the top summary).
- Test: `test/modules/portfolio/position_summary_test.dart` (screenshot: MV 1,16,34,876.50, cost 1,16,71,834.48, Gain −36,957.98 / −0.32 %; Account Summary getters still Σ total_cost).

## Verified
- make analyze: 0 issues; oms_shared 200 tests pass; mutation 2/2.

## Open
- Rows (Market Val / Unrealized) still mix initial qty with total_cost — user decides.
- Not committed; made on `feature/cse_watchlist_socket`.
