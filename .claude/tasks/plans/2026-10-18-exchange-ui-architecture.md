# Exchange UI architecture (DSE / CSE): common vs exchange-specific UI

Status: **design only — not implemented. Live app: no UI change until approved.**
Created: 2026-10-18 · Companion: `2026-10-18-dse-cse-exchange-support.md` (code audit, backend questions)

## 0. What exists today (done, no UI effect)

```dart
// apps/<house>/lib/src/house_profile.dart
exchangeMode: ExchangeMode.dseOnly,   // dseOnly (default) | cseOnly | dseAndCse
```

| API (`AppConfig`) | dseOnly | cseOnly | dseAndCse |
|---|---|---|---|
| `exchangeMode` | dseOnly | cseOnly | dseAndCse |
| `exchanges` | {dse} | {cse} | {dse, cse} |
| `hasDse` | true | false | true |
| `hasCse` | false | true | true |
| `hasBothExchanges` | false | false | true |
| `defaultExchange` | dse | cse | dse |

- Enum (`packages/core/broker_config/lib/src/stock_exchange.dart`), so an invalid state (no exchange) cannot compile.
- New app: `make new-app … EXCHANGE=dse|cse|both` (default dse).
- All houses (Benemoy, Fakhrul) are `dseOnly`. Locked by `apps/<house>/test/house_profile_test.dart`.

## 1. Golden rules

1. **Never branch on the house.** No `if (houseId == 'fakhrul')`. Only `AppConfig.hasDse / hasCse / hasBothExchanges` or the selected exchange.
2. **Widgets don't hold exchange constants.** `'DSEX'`, `'Main Board'`, 10:00–14:30, `'PUBLIC'` … move into `ExchangeProfile` data. A widget asks the profile, it never compares strings.
3. **Single-exchange houses look exactly as today.** Switcher and badges render `SizedBox.shrink()` unless `hasBothExchanges`.
4. **DSE profile = today's hardcoded values, byte for byte.** Lock with tests *before* moving any constant → Benemoy unchanged.
5. GetX CLI layout, one public widget per file, direct imports, no barrels (project rules).

## 2. The four kinds of UI

| Kind | Meaning | How it is built | Examples |
|---|---|---|---|
| **A. Common** | Same for every house and exchange | Untouched | Login/OTP, balance, withdrawal, notifications, contact, settings, trade form layout, order form dialog |
| **B. Exchange-aware common** | Same widget, data differs per exchange | Reads `ExchangeService.profile` (current exchange) | Index list + default index, index chart hours, market summary/treemap board filter, watchlist filter chips, top share, sector/category, search hint, market session pill, limit-request market dropdown |
| **C. Exchange-only** | Exists only on one exchange | Wrapped in `ExchangeOnly(exchange: …)` | A DSE-only board (e.g. SME) or a CSE-only feature |
| **D. Both-exchange only** | Needed only when a house has both | Render nothing unless `hasBothExchanges` | `ExchangeSwitcher` (DSE \| CSE), `ExchangeBadge`, exchange picker on trade, exchange filter on orders/portfolio |

Rule of thumb: most work is **B** (data); **C** is rare; **D** is invisible for `dseOnly` / `cseOnly`.

## 3. Building blocks (planned)

### 3.1 `ExchangeProfile` — pure data (`packages/core/broker_config/lib/src/exchange_profile.dart`)

```dart
class ExchangeProfile {
  const ExchangeProfile({
    required this.exchange,
    required this.label,            // 'DSE' / 'CSE'
    required this.indices,          // ordered: ['DSEX','DSES','DS30','DSMEX']
    required this.defaultIndex,     // 'DSEX'
    required this.hiddenIndices,    // {'DSE SME Index','CDSET'}
    required this.sessionOpen,      // (10, 0)
    required this.sessionClose,     // (14, 30)
    required this.mainBoard,        // 'Main Board'
    required this.smeBoard,         // 'Small Cap Board'
    required this.publicGroup,      // 'PUBLIC'
    // + categories, watchlist chips, limit-request markets, search hint
  });
  static const dse = ExchangeProfile(/* exactly today's values */);
  static const cse = ExchangeProfile(/* from backend answers */);
  static ExchangeProfile of(StockExchange e) => switch (e) { … };
}
```
Pure Dart, `const`, unit-tested; no Flutter or GetX.

### 3.2 `ExchangeService` — current exchange (`oms_shared/lib/app/data/services/exchange_service.dart`)

```dart
class ExchangeService extends GetxService {
  final selected = AppConfig.defaultExchange.obs;      // restored from StorageService
  List<StockExchange> get available => AppConfig.exchanges.toList();
  ExchangeProfile get profile => ExchangeProfile.of(selected.value);
  void select(StockExchange e) { /* only if available; persist; notify */ }
}
```
- Registered `permanent: true` with the other services at bootstrap.
- Single-exchange house: `selected` never changes → identical to a constant.
- A GetxService rather than another HomeController mixin, because market, quote, trade, watchlist, orders, portfolio and limit_request all need it (HomeController is already the highest blast radius).

### 3.3 Widgets (`oms_shared/lib/app/global_widgets/exchange/`)

| File | Widget | Behaviour |
|---|---|---|
| `exchange_switcher.dart` | `ExchangeSwitcher` | Segmented DSE \| CSE; `SizedBox.shrink()` unless `hasBothExchanges` |
| `exchange_badge.dart` | `ExchangeBadge(exchange)` | Small "DSE"/"CSE" chip; hidden unless `hasBothExchanges` |
| `exchange_only.dart` | `ExchangeOnly(exchange:, child:)` | Shows `child` only when the **selected** exchange matches (kind C) |

## 4. Screen-by-screen

| Screen / module | Kind | dseOnly | cseOnly | dseAndCse |
|---|---|---|---|---|
| Market tab header | D | as today | as today | + `ExchangeSwitcher` |
| Index list / chart (`index_mixin`, `live_index_controller`, `market_index_controller`) | B | DSEX… | CASPI… | follows switcher |
| Market summary, treemap, sector, top share | B | Main/SME | CSE boards | follows switcher |
| Market session pill (`call_now_widget`) | B | DSE session | CSE session | session of selected |
| Marquee / ticker | B | PUBLIC group | CSE group | selected exchange |
| Quote | B + D | as today | CSE data | + badge |
| Trade | A + D | as today | as today | + exchange picker if listed on both; order carries exchange |
| Watchlist / favourites | B + D | DSE chips | CSE chips | chips of selected + badge |
| Global search | B + D | as today | CSE results | + badge |
| Orders list / details / replace / cancel | A + D | as today | as today | combined + badge + filter |
| Portfolio | A + D | as today | as today | combined + badge; price lookup by exchange |
| Limit request | B | public/block/Debt | CSE markets | markets of selected |
| Balance, withdrawal, auth, notifications, contact, drawer | A | — | — | — |

## 5. Data layer (needed before kind D works)

- Tick store / depth / T&S / watchlist keyed by `ob` only → if backend says ids can collide, key by `(exchange, ob)`.
- `MarketModel` gets an `exchange` (from feed field or from which socket it came).
- `OrderConfirmRequest` / `UpdateOrderHolder` get the exchange **only in the form the gateway defines** (never rename existing keys).
- Per-exchange socket ids / URLs in `BrokerHouseConfig` + env JSON, if feeds are separate.

## 6. Delivery phases

| Phase | Scope | Backend needed | Risk |
|---|---|---|---|
| **0** ✅ | `ExchangeMode` flag, `AppConfig` getters, `make new-app EXCHANGE=` | no | none (unused) |
| **1** | `ExchangeProfile.dse` + tests that it equals today's constants; replace hardcoded values (kind B); `ExchangeService` with fixed exchange | no | low — DSE values unchanged |
| **2** | `ExchangeProfile.cse`; a `cseOnly` house works end-to-end | CSE feed values (Q1, Q4, Q5) | medium (only cseOnly houses) |
| **3** | Kind D: switcher, badges, picker, exchange-keyed data, exchange in orders | all backend questions | high — order path; full UAT |

Each phase: separate PR dev → uat, UAT QA on a DSE house first (must look identical), then the CSE house.

## 7. Testing strategy

- `ExchangeProfile.dse` snapshot test against today's literals (guard for Benemoy).
- Widget tests for `ExchangeSwitcher` / `ExchangeBadge` / `ExchangeOnly` under all three modes (`AppConfig.initializeForTesting` with each `ExchangeMode`).
- Controller tests: index default, board filters, session per exchange.
- Existing 103 `oms_shared` tests must stay green without edits in Phases 1–2.
