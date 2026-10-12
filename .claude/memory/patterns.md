# Established Patterns
> ⚠️ PROJECT SCOPED: This file lives in .claude/memory/ only.
> Run /r-memory-scan to auto-fill from codebase.

#### GetX CLI module
- **When to use**: every new screen or flow
- **Example**: `packages/shared/oms_shared/lib/app/modules/withdrawal_request/{bindings,controllers,views}` (create with `get create page:<name>` inside oms_shared, PATH must include the FVM Flutter `bin`)
- **Anti-pattern**: a top-level `features/` package; putting a new tab's widgets into `home/`
- **Note**: the route must also be added to `apps/<house>/lib/src/routing/app_pages.dart` in EVERY app (see gotchas)

#### HomeController as a shell with mixins
- **When to use**: state that must survive tab switches and share the live sockets
- **Example**: `modules/home/controllers/home_controller.dart` + `home/*_mixin.dart` (`part of`), state in `home/home_state.dart`
- **Anti-pattern**: a separate controller opening its own copy of a socket

#### Targeted rebuilds
- **When to use**: live data that changes several times a second
- **Example**: `update(['total_amount_update'])`, `VisibleGetBuilder` (skips hidden tabs), `UpdateThrottle`
- **Anti-pattern**: bare `update()` on every tick or keystroke

#### Order submission guard
- **When to use**: any action that sends something to the gateway
- **Example**: `TradeMixin.orderConfirmSubmitted`: set loading before any await, network check, wait ≤3 s for socket, send once, 15 s timeout with a user message
- **Anti-pattern**: re-sending on timeout; allowing a second tap while in flight

#### Tests with fakes
- **When to use**: controller/service tests
- **Example**: `test/modules/home/controllers/trade_mixin_test.dart`; helpers `initTestStorage()`, `initTestAppConfig()`, `setTestNetwork('none')`, `FakeChannel`; `pumpFor` in 100 ms steps; `finish()` closes snackbars
- **Anti-pattern**: one big `tester.pump(20s)` (breaks snackbar animations across tests)

## Template
#### [Pattern Name]
- **When to use**:
- **Example**: [file path + snippet]
- **Anti-pattern**:
