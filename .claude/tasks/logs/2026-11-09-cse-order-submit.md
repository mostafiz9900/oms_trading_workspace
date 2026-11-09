# 2026-11-09 — CSE order submit (done)

Task: `.claude/tasks/done/2026-11-09-cse-order-submit.md` · Plan: `.claude/tasks/plans/2026-11-09-cse-order-submit.md`

## Done
- Every order request carries `exchange` + `cse_trader_code` (DSE: "DSE" / null); CSE session; CSE trading open; order actions by the order's exchange.
- First real CSE order accepted on UAT (TK Shares, CITYBANK BUY 2 @ 100, `exchange: CSE`, `cse_trader_code: CTG01`).
- Related fixes the same day: switch lag, confirm page SELL colour + exchange row, onboarding button, new_app XML escape, order summary token, TK Shares app.

## Verified
- `make check` exit 0 (250 tests incl. uncommitted dispose test); mutation checks on every change; device checks on Samsung SM A075F (profile + debug).

## Open (moved to todo/2026-10-31-cse-open-questions.md)
- `exchange` on CSE orders in the order list; modify / cancel of a CSE order.

## Also
- `7485674` login "used after being disposed" fix (fieldsDisposeDelay 1 s + home_dispose_test.dart), committed by the user.
