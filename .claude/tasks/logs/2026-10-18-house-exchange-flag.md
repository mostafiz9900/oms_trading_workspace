# 2026-10-18 — House exchange flag (DSE / CSE)

## Done
- `ExchangeMode { dseOnly, cseOnly, dseAndCse }` (enum: no invalid empty state) next to
  `StockExchange` in `packages/core/broker_config/lib/src/stock_exchange.dart`.
- `HouseProfile.exchangeMode`, default `dseOnly`; replaces the uncommitted `Set<StockExchange> exchanges`
  and its runtime empty-set check.
- `AppConfig.exchangeMode / exchanges / hasDse / hasCse / hasBothExchanges / defaultExchange`.
- Benemoy and Fakhrul: `exchangeMode: ExchangeMode.dseOnly` (Fakhrul was `{cse}`; user: all houses DSE by default).
- `make new-app … EXCHANGE=dse|cse|both` (default dse) → `tool/new_app.dart --exchange`; rejects other values.
- Docs: `docs/new-app.md` (exchange table), `CLAUDE.md` dev commands.
- Removed debug probe `apps/fakhrul/test/zz_exchange_probe_test.dart` (used `print`); added
  `apps/{benemoy,fakhrul}/test/house_profile_test.dart`.
- Braces on 5 single-statement `if`s in `global_widgets/custom_drawer.dart` (lint from an earlier reformat; no logic change).
- Plans: `.claude/tasks/plans/2026-10-18-dse-cse-exchange-support.md` (code audit, backend questions),
  `.claude/tasks/plans/2026-10-18-exchange-ui-architecture.md` (common vs exchange-specific UI design).
- No UI or business logic touched.

## Verified
- `make analyze`: 0 issues in all packages; `dart analyze --fatal-infos tool`: 0
- `make test`: broker_config 8, oms_shared 103 passed; app tests: benemoy 1, fakhrul 1 passed
- `make validate`: ok (fakhrul still has TODO store values)
- `new_app.dart` dry run in a scratch clone: `--exchange cse` → `cseOnly`, none → `dseOnly`, `nse` → error

## Next
- Backend questions, then Phase 1 of the UI architecture plan.
