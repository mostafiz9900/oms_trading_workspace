# 2026-10-24 — DSE/CSE step 3: Top Share + env recovery

## Done
- Recreated git-ignored `apps/benemoy/env/uat.json` and `prod.json` (new laptop) from URLs the user pasted; `OMS_CONTRACT_URL` is still a placeholder (`https://benemoysecurities.com`).
- Analyzer fix in `quote_top_details_section.dart` (unused import + 2 unused locals from 7007fcd).
- Step 3: DSE/CSE switcher on Top Share (see plan "Step 3"). Files: `top_share_controller.dart`, `top_share_view.dart`, new `test/modules/top_share/top_share_exchange_test.dart`.
- Benemoy `house_profile.dart` set to `dseAndCse` by the user (uncommitted at time of writing).

- Step 4: Quote (see plan "Step 4"). Files: `quote_mixin.dart`, `home_state.dart`, `socket_mixin.dart`, `market_feed_mixin.dart`, `quote_widget.dart`, `exchange_reload_test.dart`.
- Step 5: Trade (see plan "Step 5"); user chose: no new orders while CSE is selected. Files: `trade_mixin.dart`, `home_controller.dart` (import), `quote_mixin.dart`, `trade_widget.dart`, tests.
- Step 6: Orders (see plan "Step 6"); user chose: CSE selected → modify/cancel/duplicate/status ask to switch to DSE. Files: `order_list_mixin.dart`, `home_state.dart`, `trade_mixin.dart`, `order_history_widget.dart`, `portfolio_widget.dart`, tests.
- Step 7: Global Search + per-exchange recent searches. Files: `recent_search_service.dart`, `socket_mixin.dart`, `global_search_view.dart`, tests. Audit of remaining screens → plan "Remaining gaps".
- Step 8: Favourites, sector details, Quote › Price Table. Files: `fav_market_mixin.dart`, `socket_mixin.dart`, `market_feed_mixin.dart`, `home_state.dart`, `quote_mixin.dart`, `fav_market_view.dart`, `sector_horizontal_list.dart`, tests. User rule recorded in memory/rules.md: DSE must stay exactly as is.
- Full recheck: all 6 bottom tabs + Top Share, Global Search, Sector details have the switch; other screens are account-only or unreachable. Positions: user wants CSE prices on CSE (already so); added redraw during the switch window.
- Step 9: stock details (depth, T&S) follow the exchange; 2 new optional env keys. Files: `broker_house_config.dart`, `app_config.dart`, `validate_apps.dart`, `socket_mixin.dart`, `quote_mixin.dart`, `home_state.dart`, tests.

## Verified
- `make analyze`: 0 issues; `make test`: oms_shared 147 passed, broker_config +2 (`make check` green); new tests mutation-checked 4/4 (Top Share) + 4/4 (Quote) + 4/4 (Trade) + 4/4 (Orders).
- Prod sockets probed: market, index, marketdepth, events → 101; `wss://itch.skytrade.us/socket-api/v1/news/ws` timed out from home network.

## Next
- Real contract URL; set GitHub secrets BENEMOY_PROD_ENV_JSON (production env) and BENEMOY_UAT_PROFILE_JSON.
- All screens done; backend: exchange field for CSE orders/order list; CSE URLs (market, index, depth, T&S); CSE depth + T&S socket URLs from backend.
