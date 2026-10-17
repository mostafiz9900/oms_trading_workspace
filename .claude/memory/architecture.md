# Architecture
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.
> Run /r-memory-scan to auto-fill from codebase.

## Stack
Flutter 3.47.6 via FVM (`.fvmrc`) · Dart workspace (`pubspec.yaml` `workspace:`) + Melos 8 · GetX 4.7 (state, routing, DI) · GetStorage · web_socket_channel · connectivity_plus · Firebase core/messaging/crashlytics · syncfusion + fl_chart · Riverpod/hooks in a few legacy places · fastlane (Ruby 3.4 on CI).

## Folder Structure
- `apps/<house>/` – shell: entry points (`main_uat.dart`, `main_prod.dart`), `src/app.dart` (GetMaterialApp), `src/routing/app_pages.dart` (GetPage table), `src/house_profile.dart`, `env/*.json`, brand assets, native projects, fastlane.
- `packages/core/` – `broker_config` (typed house config), `trading_core`, `trading_ui`.
- `packages/shared/localization` – translations.
- `packages/shared/oms_shared/lib/app/` – GetX CLI layout: `modules/`, `data/`, `routes/`, `global_widgets/`, `core/`; plus `bootstrap.dart` (`runOmsApp`) and `oms_shared.dart` (public API for apps).

## System Layers
1. View (GetView / GetBuilder with ids / Obx) – `modules/*/views`
2. Controller (GetxController; HomeController = SuperController with mixins as `part` files) – `modules/*/controllers`
3. Repository (`data/repositories`, contracts like `MarketChartRepository`, `AuthenticationRepository`)
4. Provider (GetConnect REST, `data/providers`, base in `data/api`)
5. Services (`data/services`): WebSocketService, MarketSocketService, StorageService, notification services, market tick store/aggregators.
Registration: `AppBinding` (app-wide, permanent), `DependencyInjection.init()` (`di.dart`), route bindings (`HomeBinding` registers home, market, orders controllers).

## Data Flow
- REST: view → controller → repository → provider → `ApiResponse` back.
- Live: `HomeController.initConnect()` opens market/index/depth/news/order/balance sockets through `WebSocketService` (reconnects forever, reconnects on network/app resume). Messages → socket mixin handlers → models → `update([id])` (throttled, hidden tabs skip rebuilds via VisibleGetBuilder).
- Orders: `TradeMixin.orderConfirmSubmitted` → network check → (connect order socket, wait ≤3 s) → `OrderConfirmRequest.toJson()` → order socket → 15 s timeout; server `order_submitted` / `order_error` handled in `OrderListMixin._handleOrderConfirmMessage`.

## Auth Flow
Login (password or biometric) → access + refresh JWT saved in GetStorage → `TokenController.startTokenCountdown` schedules refresh 2 min before `exp` → refresh via `HomeRepository.refreshTokenIfNeeded` → on any failure `_clearSession()` wipes tokens/user info and goes to `Routes.LOGIN`.

## External Services
OMS API (`OMS_API_BASE_URL`), chart and itch APIs, websockets (`OMS_SOCKET_*`), Firebase project per house (Benemoy: `benemoy-c5dae`), Google Play, App Store Connect.

## Environment Differences
Only `apps/<house>/env/{uat,prod}.json` (17 keys: house id/name, env, URLs, locale, colors, contract URL). Build: `--dart-define-from-file`. CI: UAT from secret `BENEMOY_UAT_PROFILE_JSON` (falls back to `example.json`); release: `BENEMOY_PROD_ENV_JSON` (production environment).

## Key Design Decisions
See decisions.md.
