# Module Dependencies
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.
> Run /r-memory-scan to auto-fill from codebase.

## Module Dependency Map
- `home` (shell) → HomeController mixins use: `market` controllers (LiveIndex, MarketIndex, Companies), `quote` (HistoricalVolume), `portfolio` (Position), `watchlist` (Watchlist), `orders` (order models/views), `auth` (Biometric, Token)
- Tabs (`market`, `quote`, `watchlist`, `portfolio`, `trade`) → read/write `HomeController` state
- `orders` → HomeController (order list, replace/cancel via `orderConfirmSubmittedReplaceOrder`)
- `auth` → AuthRepository, TokenController, BiometricController, StorageService
- `global_search`, `notifications`, `top_share` → HomeController + market models
- apps → `oms_shared` (bootstrap, routes, modules), `broker_config`, `localization`

## Shared Utilities
`data/services/storage_service.dart`, `socket_db_service.dart` (WebSocketService), `market_socket_service.dart`, `core/values/app_config.dart`, `core/utils/helpers/{app_helper,log_helper,hex_color}.dart`, `core/utils/extensions/app_context.dart`, `global_widgets/` (loaders/, appbar_right_search_tap, index-related widgets), `data/models/response/market_model.dart`

## High Risk Modules
1. `modules/home/controllers/` (HomeController + mixins) — every tab, every socket, order entry
2. `data/services/socket_db_service.dart` — all live data and orders
3. `data/models/request/order_confirm_request.dart`, `data/enums/app_enum.dart` — gateway protocol
4. `modules/auth/controllers/token_controller.dart` — session lifetime
5. `core/values/app_config.dart`, `packages/core/broker_config` — every URL

## External Package Usage
get (everything) · get_storage (StorageService) · web_socket_channel (WebSocketService) · connectivity_plus (NetworkUtil, reconnect) · firebase_* (push, crash reports) · syncfusion_flutter_charts/treemap, fl_chart (charts) · local_auth (biometric) · hooks_riverpod/flutter_hooks (legacy screens) · jwt_decoder (trading_core) · image_picker (signup media)

## Circular Dependencies
None known at package level (apps → shared → core). Inside oms_shared, HomeController ↔ tab widgets reference each other by design.
