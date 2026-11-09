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
