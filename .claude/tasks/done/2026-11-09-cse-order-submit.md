# Task: CSE order submit (new / replace / cancel / status / duplicate)
**Added By**: mostafiz9900
**Date Added**: 2026-11-09
**Priority**: 🔴 High
**Module**: home (trade_mixin, order_list_mixin, home_state), orders, trade, data/models/request
**Assigned To**: mostafiz9900
**Completed By**: mostafiz9900
**Completed Date**: 2026-11-09
**Plan**: `.claude/tasks/plans/2026-11-09-cse-order-submit.md`
**Source**: web trader `useFixEmit` (JS) pasted by the user

## Acceptance Criteria
- [x] Every order request (new, replace, cancel, status, duplicate) sends `exchange` (`DSE` / `CSE`) and `cse_trader_code` (user's code on CSE, null on DSE) — DSE too (user answer 1)
- [x] `cse_trader_code` read from `user_detail`; CSE order without it is not sent and the user is told why (user answer 2)
- [x] `asset_class` on CSE as on DSE (`EQ` / `MF`, via `normalizeCseTick`) (user answer 3)
- [x] CSE orders use the CSE feed's session
- [x] CSE trading open; DSE unchanged apart from the two keys
- [x] Order actions only while the order's exchange is selected; stock looked up in that exchange's feed
- [x] Real CSE order accepted on UAT (TK Shares, Samsung SM A075F, account 936, CTG01: CITYBANK BUY 2 @ 100 → `order_submitted`, reply echoes `exchange: CSE`)
- [x] Tests + mutation checks; `make check` green
- [ ] `exchange` on CSE orders in the order list (execution reports) — not seen yet → moved to `todo/2026-10-31-cse-open-questions.md`
- [ ] Modify / cancel of a CSE order on UAT → moved to the same todo

## Summary
- Commits on `feature/cse_watchlist_socket` (pushed): `2074626` exchange + cse_trader_code on every order request and CSE trading open; `2fdac9c` CSE index list only CASPI/CSE30/CSCX/CSE50/CSI; `75303bf` order summary socket uses the signed-in user's token (was a hard-coded JWT + investor "311"); `f1035b9` DSE/CSE switch lag (bare `update()` rebuilt all 6 tabs; worst frame 187 → 41 ms); `2694841` order confirm SELL badge red + Exchange row for DSE+CSE houses; `9ddfa9a` CustomButton long titles fit; `69a76b0` new_app XML escape; `76f21c8` TK Shares app.
- Live checks: Benemoy as DSE-only (temporary, reverted) → only DSE sockets, no switch, indices as before; TK Shares CSE sockets, login, first CSE order.
- `7485674` login dispose fix (`home_controller.dart` `fieldsDisposeDelay` 100 ms → 1 s + `home_dispose_test.dart`, committed by the user) — verified on the Samsung (3 logins, 0 errors).

## Follow-ups (not part of this task)
- Trade page: `'child._parent == this'` after quick qty + keyboard (TK Shares) — need the first full exception block; not reproduced with TradeWidget alone.
- DSE tab change 130–200 ms (also in prod): HomeView rebuilds all 6 tabs; fix proposed, waiting for the user's OK.
- `apps/tkshares`: iOS signing (Apple agreement), `OMS_CONTRACT_URL` still Benemoy's, chart host not answering.
