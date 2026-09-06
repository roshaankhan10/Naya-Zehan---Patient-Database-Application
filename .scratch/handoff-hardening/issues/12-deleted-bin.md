# 12: Deleted bin

**Tracker:** GitHub issue #15 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/15

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

An Admin can find records that were removed, and bring one back.

A deleted bin lists the removed Patient records with who removed them and when, and offers restore directly from the list. This is what makes soft delete useful rather than merely safe: an accidental deletion is recoverable on site, in the app, without technical help.

Users cannot see the bin at all.

## Acceptance criteria

- [ ] An Admin can see a list of removed Patient records
- [ ] The list shows who removed each record and when
- [ ] An Admin can restore a record directly from the list
- [ ] A restored record and its Admissions reappear in ordinary search and lists
- [ ] A User cannot reach the bin in the app and is refused by the server directly
- [ ] Restores performed from the bin are written to the access log

## Blocked by

- #13

