# CLAUDE.md — Project Memory

> ⚠️ PROJECT SCOPED: Everything lives in .claude/ only.
> Never read or write outside this project root.
> Auto-loaded by Claude Code every session.

## 🔒 Scope Rules — Non Negotiable
- ALL memory files → .claude/memory/
- ALL module files → .claude/modules/
- ALL task logs → .claude/tasks/logs/
- ALL plans → .claude/tasks/plans/
- ALL todo tasks → .claude/tasks/todo/
- ALL inprogress tasks → .claude/tasks/inprogress/
- ALL done tasks → .claude/tasks/done/
- ALL EOD summaries → .claude/tasks/eod/
- ALL commands → .claude/commands/ (flat; a subfolder adds a `name:` prefix)
- NEVER write any file outside project root
- NEVER read memory from global or external paths
- NEVER create .md files at project root except CLAUDE.md
- Memory/task files must live under .claude/ (code lives in apps/ and packages/)

## 🧭 Project Context
- **Name**: oms_trading_workspace
- **Purpose**: White-label stock-trading app (DSE, Bangladesh) for OMS broker houses. One shared app, one thin shell per broker house.
- **Stack**: Flutter 3.47.6 (pinned with FVM) · Dart workspace + Melos 8 · GetX (state, routing, DI) · GetStorage · WebSockets · Firebase (FCM, Crashlytics) · fastlane
- **Current Phase**: Maintenance of a **live production app** (Benemoy) + monorepo hardening
- **Target Users**: Retail investors of each broker house (Benemoy first)
- **Critical Paths**: placing/replacing/cancelling orders over the order socket · login, OTP, token refresh · live market/order-book sockets · portfolio and balances
- **Current Priorities**: release secrets for CI (Play + iOS) · UAT QA of PR #2 (dev → uat) · decisions on the 3 behaviours in .claude/memory/gotchas.md

## 📁 Project Structure
```text
apps/<house>/                 Thin broker shell (only benemoy today)
  env/uat.json, prod.json     Server URLs etc. (git-ignored; example.json is the template)
  lib/main_uat.dart, main_prod.dart, src/{app.dart, routing/app_pages.dart, house_profile.dart}
  assets/brand/, android/, ios/, fastlane/
packages/core/broker_config   Typed house config from --dart-define-from-file
packages/core/trading_core    ApiResponse, ErrorResponse, JwtToken (tiny)
packages/core/trading_ui      ResponsiveLayout, CustomContainerWidget (tiny)
packages/shared/localization  GetX translations (en, bn)
packages/shared/oms_shared    THE APP, GetX CLI layout:
  lib/app/modules/<name>/{bindings,controllers,views/(local_widgets)}
  lib/app/data/{models/{request,response},providers,repositories,services,api,enums}
  lib/app/routes/app_routes.dart (route names) · global_widgets/ (+ loaders/) · core/{theme,utils,values}
  test/ mirrors lib/app/ · test/helpers/ (fake storage, house config, network, websocket)
tool/new_app.dart, validate_apps.dart · Makefile · .github/workflows/{ci,release}.yml
```

## 🏗️ Architecture
- **Layers**: apps → packages/shared → packages/core (never the other way; packages never import an app)
- **Data Flow**: Providers (GetConnect HTTP) → Repositories → GetX controllers → views (GetBuilder ids / Obx). Live data: WebSocketService (`data/services/socket_db_service.dart`) → HomeController socket mixin → MarketSocketService / tick store → throttled UI updates
- **Auth**: JWT access + refresh in GetStorage; TokenController refreshes 2 min before expiry, logs out on any failure; optional biometric login
- **External Services**: OMS REST API, market/index/depth/news/order/balance websockets, Firebase (FCM, Crashlytics), Google Play, App Store Connect
- **Environment Differences**: UAT vs prod only via `apps/<house>/env/<env>.json` passed with `--dart-define-from-file`; `AppConfig` reads it

## 📏 Non-Negotiable Rules
✅ DO: keep UI and business logic unchanged unless the user approves (live real-money app)
✅ DO: GetX CLI layout, snake_case files, one public widget per file, direct imports
✅ DO: `printLog(...)` for logging; keep every package at 0 analyzer issues (`--fatal-infos`)
✅ DO: commit on `dev`, push `origin dev`; promote by PR dev → uat → prod
❌ DON'T: add `export` barrels, `print`, new Riverpod providers (Riverpod migration is deferred)
❌ DON'T: push to uat/prod/main directly, commit env JSON, keystores or key.properties
❌ DON'T: rename enum values or JSON keys sent to the gateway (`data/enums/app_enum.dart`, request models)

## 🔁 Established Patterns
See .claude/memory/patterns.md (module layout, HomeController mixins, socket handling, tests with fakes).

## ⚠️ Gotchas
See .claude/memory/gotchas.md (route registration per app, open behaviour questions, GetStorage in tests, snackbars in tests).

## 🧩 Module Map
`home` = shell (HomeController + 13 mixins, HomeView with 6 tabs) · tabs: `market`, `quote`, `watchlist` (+ favourites), `portfolio`, `trade` · `orders` (order list, details, replace/cancel dialog) · `auth` (login, OTP, signup, biometric, token, password reset) · `notifications` · `global_search` · `top_share`, `search_watch_list`, `order_alert`, `limit_request`, `withdrawal_request`, `contact_us`, `onboarding`, `splash`, `app_network`

## 🔗 Dependency Map
See .claude/memory/dependencies.md. Highest blast radius: `HomeController` (+ mixins), `WebSocketService`, `StorageService`, `AppConfig`, `data/models/response/market_model.dart`, `global_widgets/`.

## 📌 Key Decisions
See .claude/memory/decisions.md.

## 🛠️ Dev Commands
- Install: `make setup` (first time and after every pull)
- Dev server: `make run` (Benemoy, UAT) · `make run ENV=prod` · `make run APP=<house>`
- Build: `make apk` / `make appbundle` / `make ipa` (production by default)
- Test: `make test`
- Lint: `make analyze` (all packages, strict) · everything: `make check`
- Migrate: n/a (no local database)
- Seed: n/a
- Deploy: merge to `prod` → `.github/workflows/release.yml` (Play draft + TestFlight); manual: `make deploy-android` / `make deploy-ios`
- New broker app: `make new-app ID=x NAME="X Ltd" ANDROID_ID=com.x.app IOS_ID=com.x.app [EXCHANGE=dse|cse|both]` (default dse), then `make validate`
- House exchanges: `exchangeMode:` in `apps/<house>/lib/src/house_profile.dart` (`dseOnly` default · `cseOnly` · `dseAndCse`); code reads `AppConfig.hasDse/hasCse/hasBothExchanges`, never the house id

## ⚙️ Settings
- .claude/settings.json → shared team settings — always commit
- .claude/settings.local.json → personal settings — never commit
- First thing after cloning: add your name to settings.local.json

## 👥 Team Guidelines
- All .claude/ files are shared — commit all changes
- Only settings.local.json and tasks/eod/ are personal/gitignored
- Every developer can work on all modules
- When you update any memory file — commit so team benefits
- After touching a module — update .claude/modules/[name].md
- New gotcha found — add to .claude/memory/gotchas.md and commit
- New pattern found — add to .claude/memory/patterns.md and commit
- Architecture decision made — add to .claude/memory/decisions.md and commit
- Run /r-memory-scan after pulling major changes

## 📋 Task Collaboration
- See all tasks: /r-todo
- Add task for team: /r-add-task [description]
- Pick up a task: /r-pickup
- Mark task done: /r-done
- All tasks are shared — commit and push after adding

## 📋 Before Every Task
1. Re-read this file
2. Read .claude/modules/[relevant].md
3. Read .claude/memory/gotchas.md
4. Read .claude/memory/dependencies.md
5. State plan before writing any code
6. List all files that will change
7. Check blast radius
8. Confirm plan follows all rules above

## 📋 After Every Task
1. Update .claude/modules/[affected].md
2. Append to module changelog
3. Log new gotchas to .claude/memory/gotchas.md
4. Log new patterns to .claude/memory/patterns.md
5. Log new decisions to .claude/memory/decisions.md
6. Update architecture.md if structure changed
7. Update this CLAUDE.md if anything major changed
8. Save task log to .claude/tasks/logs/YYYY-MM-DD-[title].md
9. Set memory confidence flags on updated modules
