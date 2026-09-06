# 03: Close the Django admin door

**Tracker:** GitHub issue #6 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/6

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

There is currently a second, unguarded door into every patient record. Django's admin site is reachable on the public internet and offers full create, edit and destroy over all ~223,000 Patient records through session authentication, bypassing the role permission class entirely — and, once the audit and soft-delete work lands, bypassing those guarantees too.

Close it, so the API is the only path into patient data.

This must land before or alongside the audit work. Leaving it open would make every guarantee the access log offers false from the day it ships.

## Acceptance criteria

- [ ] The Django admin site is either removed from the URL configuration or restricted so it is not reachable by an ordinary web request in production
- [ ] If retained in any form, access to it is restricted to superusers and documented in `docs/decisions-log.md` as the deliberate management console
- [ ] A request to the admin path in a production-like configuration does not return a usable login form to an anonymous visitor
- [ ] The API continues to work unchanged for both Admin and User
- [ ] The choice made and its reasoning are recorded in `docs/decisions-log.md`

## Blocked by

- None (can start immediately)

