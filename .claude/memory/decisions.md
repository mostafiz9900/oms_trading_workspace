# Architecture Decisions
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.

[Decisions will be logged here as they are made]

## Template
#### [date] — [Title]
- **Problem**:
- **Options Considered**:
- **Decision**:
- **Reason**:
- **Tradeoffs**:
- **Revisit If**:

---

#### 2026-10-12 — Initial Setup
- **Problem**: Need a structured AI-assisted development system
- **Decision**: Claude Code with .claude/ memory system
- **Reason**: Project-scoped, team-shared, native Claude Code support
- **Tradeoffs**: Requires Claude Code installation
- **Revisit If**: Team grows beyond 10 developers

#### 2026-10-11 — GetX CLI layout only, no feature packages
- **Problem**: Code was split between `oms_shared/lib/app/modules` and `packages/features/*`; developers did not know where code goes.
- **Options Considered**: keep feature packages; clean-architecture packages per feature; GetX CLI layout in one package
- **Decision**: fold `packages/features/*` into `oms_shared/lib/app/data`; split `home` into GetX modules; one widget per file
- **Reason**: matches `get create page`, the team already uses GetX CLI
- **Tradeoffs**: one big package; boundaries enforced by convention and review
- **Revisit If**: several teams need independent release cycles per feature

#### 2026-10-11 — No barrels, strict analysis
- **Problem**: `app_pkg.dart` + 17 barrels hid dependencies and caused cycles; 315 analyzer issues
- **Decision**: direct imports only; every package at 0 issues with `dart analyze --fatal-infos` in CI and melos
- **Revisit If**: never lower the bar; fix issues instead

#### 2026-10-11 — Riverpod stays for now
- **Problem**: GetX and Riverpod both used
- **Decision**: user deferred the migration; no new Riverpod providers
- **Revisit If**: the user schedules the Riverpod → GetX work (needs QA: OTP countdown, token refresh UI)

#### 2026-10-11 — CI/CD and branch flow
- **Decision**: CI (analyze, test, Android/iOS debug build) on every branch and PR except `prod`; push to `prod` runs CI then fastlane → Play (draft) + TestFlight. Flow dev → uat → prod. `production` environment limited to `prod`.
- **Reason**: nothing reaches the store without passing checks; going live stays a manual click
- **Revisit If**: more broker apps need releases (add per-house release workflows/matrix)

#### 2026-10-11 — Characterisation tests for live behaviour
- **Problem**: no tests on trading flows; some current behaviour looks wrong
- **Decision**: tests lock CURRENT behaviour (incl. 3 questionable ones, see gotchas); behaviour changes only with user approval
- **Tradeoffs**: tests must be updated when a questionable behaviour is fixed

#### 2026-10-18 — Exchanges per house (DSE / CSE)
- **Problem**: CSE support is coming; some houses will trade on CSE, most stay on DSE
- **Options Considered**: `Set<StockExchange>` (allows an empty, invalid set → runtime check); CSE on/off bool (can't express CSE-only); 3-value enum · in `house_profile.dart` vs env JSON
- **Decision**: `HouseProfile.exchangeMode` = `ExchangeMode.dseOnly` (default) | `cseOnly` | `dseAndCse`, set in each app's `house_profile.dart` (same for UAT and prod) and by `make new-app EXCHANGE=dse|cse|both`. Code reads `AppConfig.hasDse / hasCse / hasBothExchanges / defaultExchange`, never the house id. Flag only for now: no UI uses it. UI design in `.claude/tasks/plans/2026-10-18-exchange-ui-architecture.md`.
- **Reason**: user's rule — every house DSE by default, DSE+CSE or CSE-only per house; an enum makes the invalid "no exchange" state impossible; committed code is reviewed, unlike git-ignored env files
- **Revisit If**: a house needs different exchanges in UAT and prod
