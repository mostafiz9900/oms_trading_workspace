# Project Context
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.
> Run /r-memory-scan to auto-fill from codebase.

- **Product Name**: oms_trading_workspace (first live app: Benemoy Securities)
- **Purpose**: Mobile stock trading for Dhaka Stock Exchange clients of OMS broker houses: live market, quotes, watchlists, order entry, portfolio, withdrawals, limits, alerts.
- **Target Users**: Retail investors of each broker house. Each house ships its own app id and brand from the same shared code.
- **Current Phase**: Live in production (Benemoy). Monorepo refactor done (GetX CLI layout, 0 analyzer issues, 102 tests). Release pipeline built, secrets partly set.
- **What Success Looks Like**: Orders always reach the gateway exactly once with the right values; sessions stay valid; market data is live and smooth; a new broker house can be added with `make new-app` and config only.
- **What Must Never Break**: order JSON sent to the gateway, double-tap guard and 15 s no-answer timeout, token refresh/logout, live sockets, existing UI (users rely on it).
- **Known Technical Debt**:
  - Riverpod still used in ~10 places (OTP countdown, token refresh UI, password visibility, clock, order-type lists); migration to GetX deferred by the user.
  - HomeController is a large shell (13 mixins, `order_list_mixin` ~700 lines).
  - App shell (`app.dart`, `app_pages.dart`, `run.dart`) is copied into every app.
  - Android: unused `settings.gradle.kts` / `build.gradle.kts`; Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20 will soon be unsupported by Flutter.
  - `trading_core` and `trading_ui` are tiny packages behind re-export shims.
