# Monorepo boundaries and migration rules

## Current boundary

- `apps/app_benemoy` is the deployable live app and owns its existing screens,
  navigation, and app startup.
- `packages/core/trading_core` owns the generic API result type and stateless
  JWT inspection; app-specific secure storage and navigation remain in each
  deployable app.
- `packages/core/trading_ui` owns broker-neutral responsive layout and surface
  container widgets; broker-specific colors and presentation stay in apps.
- `packages/features/market` owns market/index/depth/watchlist/chart DTOs,
  time-and-sales/market-feed/marquee models, repository contracts, live tick
  stores, sector filtering/aggregation, and market calculations. Benemoy uses
  compatibility exports at migrated paths and app-owned adapters for its
  existing API and storage implementations.
- `packages/features/auth` owns login, profile, registration, OTP, and media
  DTOs plus the `AuthenticationRepository` contract. Benemoy keeps compatibility
  exports and implements the contract in its app-owned API adapter; auth
  screens, state, providers, and API orchestration still live in the app.
- `packages/features/orders` owns reusable order submission/cancellation DTOs
  and order list/status/summary response models plus the `OrderRepository`
  command contract. Benemoy's websocket service implements that contract;
  controllers and UI keep importing through compatibility exports.
- `packages/features/withdrawals` owns withdrawal request/history DTOs. The
  existing Benemoy API, validation, controller, and UI remain app-owned.
- `packages/features/portfolio` owns cash/balance and position response DTOs;
  its position payload reuses the market security model. Benemoy's portfolio
  controllers, API integration, calculations, and UI remain app-owned.
- `packages/features/notifications` owns notification feed and order-alert
  DTOs. Push/local notification services, websocket lifecycle, app routing,
  state, and screens remain in Benemoy.
- `packages/features/research` owns issuer profile/fundamental, dividend, EPS,
  and issuer news DTOs. Benemoy's fetch/caching logic and research UI remain in
  the app.
- `packages/features/limits` owns the client limit response DTO. Limit request
  networking, pagination, form state, and presentation stay in the app.
- `trading_core` owns the generic API error DTO; `auth` owns the general user
  profile DTO alongside the authentication DTOs.
- `packages/core/broker_config` owns the typed runtime view of broker-house
  identity, endpoints, logo/splash assets, locale, theme colors, and contract
  URL. Benemoy resolves it from Dart defines with dotenv endpoint fallback.
- `apps/app_fakhrul` is still a generated Flutter starter, not a broker-house
  deployment. Do not use it as the template for new houses.

## Dependency direction

Target dependencies flow from an app to feature packages and from features to
core packages. Core packages must not depend on app packages. House identity,
API endpoints, and Firebase registration are deployment configuration, not
copies of the live UI.

## Safe migration rule

Keep the live app stable while introducing workspace/tooling configuration.
Move one cohesive feature at a time only when its package boundary, imports,
platform dependencies, and rollback plan are clear. Do not make broker-specific
forks of the full app; use house profiles for configuration and isolated
adapters for behavior that is genuinely different.

## Per-house configuration

- Build-time values such as API and socket endpoints use one UAT or production
  `--dart-define-from-file` profile.
- Native app IDs, icons, Firebase resources, and signing remain in the platform
  flavor/configuration for that house.
- Profiles can choose client capabilities for presentation, but the backend
  remains responsible for authorizing every trading operation.
- Local profiles and signing credentials must not be committed.

### House branding configuration

The `house_profile` Mason brick emits an environment Dart-define JSON and a
branding manifest at `config/houses/brands/<house>/manifest.json`. Runtime
defines are consumed by `broker_config` for app title, logos/splashes, locale,
theme colors, endpoints, and an optional contract URL. The manifest remains a
catalog/scaffold for support details and optional client capabilities; those
capability flags are not yet consumed by the live UI. Contract page routing,
native launcher icons, and per-house iOS schemes still need integration.
Client capability flags must never replace server-side authorization.

Run `fvm dart run tool/validate_house_profiles.dart` or
`fvm dart run melos run validate:houses` before adding a house profile. The
validator checks manifest structure, locale defaults, capability types,
unique Android application IDs, and every locally available environment JSON
for matching house identity, environment, locale, asset/color fields, and URL
schemes. It never prints profile values. Profiles may be absent in a clean
checkout because local/CI profile JSON is git-ignored.
