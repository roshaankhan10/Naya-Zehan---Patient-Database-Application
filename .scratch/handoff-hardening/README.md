# Handoff hardening

Local snapshots of the GitHub issues for the remaining work before handover.
**GitHub is the source of truth** — these files are a point-in-time copy and will
drift once issues are edited or closed. Re-read the live issue before starting.

## Specs (parents)

- #1 — Soft delete, purge, and the access log
- #2 — Duplicate prevention: generated Hospital IDs and search-first registration
- #3 — Account management: create, reset, deactivate

## Tickets, in dependency order

| # | Ticket | Issue | Blocked by |
|---|--------|-------|------------|
| 01 | Test harness and SQLite test settings | #4 | — |
| 02 | Remove decoys and dead code | #5 | — |
| 03 | Close the Django admin door | #6 | — |
| 04 | Access log core | #7 | #4 |
| 05 | Generated Hospital IDs for new Patient records | #8 | #4 |
| 06 | Search-first registration: candidate lookup | #9 | #4 |
| 07 | Optional NIC capture and duplicate measurement | #10 | #4 |
| 08 | Activity views for a Patient record and an account | #11 | #7 |
| 09 | Access log retention prune | #12 | #7 |
| 10 | Soft delete and restore | #13 | #4, #7 |
| 11 | Account list and creation | #14 | #4, #7 |
| 12 | Deleted bin | #15 | #13 |
| 13 | Purge a single Patient record | #16 | #13 |
| 14 | Field-level history for Patient and Admission | #17 | #13 |
| 15 | Admin password reset | #18 | #14 |
| 16 | Deactivate and reactivate an account | #19 | #14 |
| 17 | Bulk purge the deleted bin | #20 | #15, #16 |

Startable immediately: **#4, #5, #6**.

Read `CONTEXT.md` and `docs/adr/` before starting any of these. `docs/decisions-log.md`
carries the reasoning that did not warrant an ADR, plus open items and known dead code.
