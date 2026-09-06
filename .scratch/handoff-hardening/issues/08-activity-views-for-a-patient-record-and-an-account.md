# 08: Activity views for a Patient record and an account

**Tracker:** GitHub issue #11 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/11

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

An Admin can read the access log inside the app, so an access question can be answered on site without a developer.

Two views, matching the two questions that will actually be asked: the recent activity for one Patient record ("who has looked at this file?"), and the recent activity for one account ("what did this departing employee do?").

This is not a general-purpose log browser. Users cannot see it at all — ordinary staff should not be browsing colleagues' activity.

## Acceptance criteria

- [ ] An Admin can see recent activity for a given Patient record, showing who did what and when
- [ ] An Admin can see recent activity for a given account
- [ ] A User cannot reach either view in the app
- [ ] A User is refused by the server if they call the endpoints directly
- [ ] Search entries appear without exposing search terms
- [ ] Both views are reachable from an obvious place in the app

## Blocked by

- #7

