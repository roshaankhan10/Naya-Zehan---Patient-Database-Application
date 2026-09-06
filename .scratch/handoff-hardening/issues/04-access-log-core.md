# 04: Access log core

**Tracker:** GitHub issue #7 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/7

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

The system starts keeping a record of who did what. Today nothing anywhere records who viewed a Patient record, who edited one, or who signed in — and for a psychiatric institute, unauthorised reading is the realistic incident and the one that currently leaves no trace. This cannot be fixed retrospectively: history that was never captured does not exist.

An append-only access log records the acting account, the action, the affected record where there is one, and the time. It covers sign-in, viewing a Patient record, creating and editing records, and searching.

Searches are recorded as a count of searches performed, never the terms typed. Storing search terms would create a log of every name a clinician entered — a second sensitive dataset needing its own protection.

Logging is written as a consequence of handling a request, not by each screen, so new endpoints are covered automatically rather than by remembering. A logging failure is swallowed: clinical access must never depend on the audit subsystem being healthy.

Removal events (soft delete, restore, purge) are added by their own tickets as those behaviours land.

## Acceptance criteria

- [ ] Signing in writes a log entry identifying the account
- [ ] Viewing a Patient record writes an entry naming the account and the record
- [ ] Creating and editing a record each write an entry
- [ ] Performing a search writes an entry that records that a search occurred and does not store the search terms
- [ ] Entries are append-only: no API path edits or deletes them
- [ ] A failure in the logging path does not fail the user's request
- [ ] Logging happens at the request layer, so a new endpoint is covered without opting in
- [ ] Response times for viewing and searching are not materially affected

## Blocked by

- #4

