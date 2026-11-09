# 2026-11-09 — UAT recheck + CSE index list

## Done
- Live UAT check (no login): DSE + CSE sockets OK; REST OK except chart host (expired cert, 502). Server issues → `.claude/tasks/todo/2026-11-09-uat-server-issues.md`.
- CSE T&S URL typo fixed by the user (`se-uat` → `cse-uat`); CSE index + T&S now on CSE UAT. Replayed recorded CSE UAT messages through `CseMarketService` / `IndexModel` (temp test, deleted).
- CSE index list shows only CASPI, CSE30, CSCX, CSE50, CSI (user request): `LiveIndexController._handleIndexMessage` drops other names when CSE is selected. DSE path unchanged.
- Tests: `live_index_controller_test.dart` +2 (CSE only the 5; DSE keeps every index).

## Verified
- `make check` exit 0: 0 analyzer issues (9 packages), oms_shared 218 tests pass, validate ok.
- Mutation 2/2 (filter removed → CSE test fails; filter on DSE too → DSE test fails).

## Open
- Prod CSE host `cse-firstservice.fistradebd.com` → HTTP 445 (not live).
- UAT certs `uat-api-admin` / `uat-itch` expire 2026-11-25.

## Later 2026-11-09
- CSE trading open (`2074626`); every order request sends `exchange` + `cse_trader_code` (DSE too).
- Order summary socket: signed-in user's token (`75303bf`).
- **First real CSE order** (TK Shares UAT, Samsung SM A075F, account 936, `cse_trader_code` CTG01): CITYBANK BUY 2 @ 100 → `order_submitted`; reply echoes `"exchange": "CSE"`. Order list showed 0 orders on next login → `exchange` in order-list items still unconfirmed (needed for modify/cancel of CSE orders).
- New app `apps/tkshares` (dseAndCse, Firebase in `benemoy-c5dae`); iOS signing blocked until the Apple account holder accepts the new agreement.
- Fixes: onboarding button overflow (long house name, `CustomButton` scales down), `tool/new_app.dart` XML-escapes `&` and no "Ltd Ltd", order confirm SELL badge red + Exchange row (DSE+CSE houses), DSE/CSE switch lag (bare `update()` rebuilt all 6 tabs: worst frame 187 → 41 ms, profile, Samsung).
- DSE-only check (Benemoy as `dseOnly`, temporary, reverted): only the 4 DSE sockets, no switch, indices as before, no errors.

## Open
- Confirm `exchange` on CSE orders in the order list; modify/cancel a CSE order on UAT.
- DSE-only "buttons feel slow": measuring in profile mode (debug builds are several times slower).
- `apps/tkshares/env/*.json`: `OMS_CONTRACT_URL` still Benemoy's; chart host not answering.
