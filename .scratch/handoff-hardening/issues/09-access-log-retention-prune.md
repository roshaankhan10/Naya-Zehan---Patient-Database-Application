# 09: Access log retention prune

**Tracker:** GitHub issue #12 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/12

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

The access log is pruned automatically so it cannot grow without bound on limited infrastructure.

A scheduled job removes entries older than the retention window. The window is short by explicit decision — `docs/decisions-log.md` records both that choice and the recommendation for a longer one, along with what the short window costs: incidents that surface months later become unanswerable.

The window must be defined in exactly one place, not scattered between the job and the documentation.

## Acceptance criteria

- [ ] A scheduled job removes access-log entries older than the retention window
- [ ] Entries within the window are untouched
- [ ] The retention window is defined in one place and referenced everywhere else
- [ ] The window and the schedule are documented in `docs/decisions-log.md`
- [ ] The job is safe to run repeatedly and when there is nothing to prune

## Blocked by

- #7

