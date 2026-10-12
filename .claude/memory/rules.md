# Rules — Non Negotiable
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.
> Run /r-memory-scan to auto-fill from codebase.

## Live App
✅ DO: refactor only (structure, performance, safety); prove equivalence (verbatim moves, tests, mutation checks)
❌ DON'T: change UI or business logic without the user's explicit OK; list the change and ask first

## Naming Conventions
✅ DO: snake_case file names; one public widget per file; GetX CLI module names (`modules/<name>/{bindings,controllers,views}`)
✅ DO: widgets used by one module → `views/local_widgets/`; by several modules → `global_widgets/`
❌ DON'T: PascalCase or dotted file names (`auth.repo.dart`); broker names (e.g. `benemoy`) in shared code
❌ DON'T: rename `Routes.*` SCREAMING_CASE (GetX CLI style) or enum values sent to the server

## Import Rules
✅ DO: import the exact file you use (relative inside oms_shared, `package:oms_shared/...` from apps/tests)
❌ DON'T: create `export` barrels (app_pkg.dart was removed on purpose)

## Function Rules
✅ DO: keep controllers registered in bindings; keep HomeBinding registration order
❌ DON'T: add new Riverpod providers; start the Riverpod → GetX migration without the user

## Error Handling
✅ DO: tell the user why an order was not sent (network, socket, timeout) and never re-send automatically
✅ DO: catch around async gaps; check `context.mounted` only where it cannot skip intended work
❌ DON'T: swallow errors silently in new code; use `print` (use `printLog`, debug builds only)

## Testing Rules
✅ DO: put tests in `oms_shared/test/` mirroring `lib/app/`; use `test/helpers/` fakes
✅ DO: mutation-check new tests (inject a bug, confirm a test fails)
✅ DO: keep `make check` green (analyze --fatal-infos, all tests, validate)
❌ DON'T: call `onInit` of HomeController in tests (opens every socket); build it directly

## Forbidden Patterns
❌ NEVER: commit env JSON, keystores, key.properties, service-account JSON, .p8/.p12
❌ NEVER: push uat/prod/main directly; promote by PR dev → uat → prod
❌ NEVER: change gateway JSON keys in request models without the backend

## Environment Variables
✅ DO: add new config as a key in `env/*.json` + `example.json`, read through `broker_config` / `AppConfig`, and validate in `tool/validate_apps.dart`
❌ DON'T: hard-code URLs or reintroduce dotenv files
